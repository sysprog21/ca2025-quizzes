#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define fatal(args...)     \
    do {                   \
        printf("Fatal: "); \
        printf(args);      \
        exit(-1);          \
    } while (0)

enum {
    /* I-type integer computation */
    INTEGER_COMP_RI = 0x13,

    /* Load instructions */
    LOAD = 0x03,

    /* Store instructions */
    STORE = 0x23,

    /* Jump and link register */
    JALR = 0x67,

    /* Add upper immediate to PC */
    AUIPC = 0x17,

    /* ECALL */
    ECALL = 0x73,
};

/* FUNCT3 for INTEGER_COMP_RI */
enum {
    ADDI = 0x0,
    XORI = 0x4,
    ORI = 0x6,
};

/* FUNCT3 for LOAD */
enum {
    LW = 0x2,
};

/* FUNCT3 for STORE */
enum {
    SW = 0x2,
};

enum { OPCODE_MASK = 0x7F, REG_ADDR_MASK = 0x1F };
enum {
    RD_SHIFT = 7,
    RS1_SHIFT = 15,
    RS2_SHIFT = 20,
    FUNCT3_SHIFT = 12,
};
enum { FUNCT3_MASK = 0x7 };

enum {
    RAM_SIZE = 1024 * 1024 * 2, /* 2 MiB */
    RAM_BASE = 0x0,
};

typedef struct {
    uint8_t *mem;
} ram_t;

typedef struct {
    uint32_t regs[32];
    size_t pc;
    ram_t *ram;
} cpu_t;

typedef struct {
    uint8_t opcode;
    uint8_t rd, rs1, rs2, funct3;
} insn_t;

ram_t *ram_new(uint8_t *code, size_t len)
{
    ram_t *ram = malloc(sizeof(ram_t));
    ram->mem = malloc(RAM_SIZE);
    memset(ram->mem, 0, RAM_SIZE);
    memcpy(ram->mem, code, len);
    return ram;
}

void ram_free(ram_t *mem)
{
    free(mem->mem);
    free(mem);
}

static inline void check_addr(int32_t addr)
{
    size_t index = addr - RAM_BASE;
    if (index >= RAM_SIZE) fatal("out of memory.\n");
}

static uint32_t ram_load32(ram_t *mem, uint32_t addr)
{
    size_t index = addr - RAM_BASE;
    return ((uint32_t) mem->mem[index] | ((uint32_t) mem->mem[index + 1] << 8) |
            ((uint32_t) mem->mem[index + 2] << 16) |
            ((uint32_t) mem->mem[index + 3] << 24));
}

uint32_t ram_load(ram_t *mem, uint32_t addr)
{
    check_addr(addr);
    return ram_load32(mem, addr);
}

static void ram_store32(ram_t *mem, uint32_t addr, uint32_t value)
{
    size_t index = addr - RAM_BASE;
    mem->mem[index] = value & 0xFF;
    mem->mem[index + 1] = (value >> 8) & 0xFF;
    mem->mem[index + 2] = (value >> 16) & 0xFF;
    mem->mem[index + 3] = (value >> 24) & 0xFF;
}

void ram_store(ram_t *mem, uint32_t addr, uint32_t value)
{
    check_addr(addr);
    ram_store32(mem, addr, value);
}

cpu_t *cpu_new(uint8_t *code, size_t len)
{
    cpu_t *cpu = malloc(sizeof(cpu_t));
    memset(cpu->regs, 0, sizeof(cpu->regs));
    cpu->regs[0] = 0;
    /* Stack pointer */
    cpu->regs[2] = RAM_BASE + RAM_SIZE;
    cpu->pc = RAM_BASE;

    cpu->ram = ram_new(code, len);
    return cpu;
}

void cpu_free(cpu_t *cpu)
{
    ram_free(cpu->ram);
    free(cpu);
}

uint32_t cpu_load(cpu_t *cpu, uint32_t addr)
{
    return ram_load(cpu->ram, addr);
}

void cpu_store(cpu_t *cpu, uint32_t addr, uint32_t value)
{
    ram_store(cpu->ram, addr, value);
}

uint32_t cpu_fetch(cpu_t *cpu) { return cpu_load(cpu, cpu->pc); }

void cpu_decode(uint32_t raw, insn_t *inst)
{
    uint8_t opcode = raw & OPCODE_MASK;
    uint8_t rd = (raw >> RD_SHIFT) & REG_ADDR_MASK;
    uint8_t rs1 = (raw >> RS1_SHIFT) & REG_ADDR_MASK;
    uint8_t rs2 = (raw >> RS2_SHIFT) & REG_ADDR_MASK;
    uint8_t funct3 = (raw >> FUNCT3_SHIFT) & FUNCT3_MASK;

    inst->opcode = opcode;
    inst->rd = rd, inst->rs1 = rs1, inst->rs2 = rs2;
    inst->funct3 = funct3;
}

static inline int32_t i_imm(uint32_t raw)
{
    /* imm[11:0] = inst[31:20] */
    return ((int32_t) raw) >> 20;
}

static inline int32_t s_imm(uint32_t raw)
{
    /* imm[11:5] = inst[31:25], imm[4:0] = inst[11:7] */
    uint32_t imm_11_5 = (raw >> 25) & 0x7F;
    uint32_t imm_4_0 = (raw >> 7) & 0x1F;
    int32_t imm = (imm_11_5 << 5) | imm_4_0;
    /* Sign extend from bit 11 */
    if (imm & 0x800) {
        imm |= 0xFFFFF000;
    }
    return imm;
}

static inline int32_t u_imm(uint32_t raw)
{
    /* imm[31:12] = inst[31:12] */
    return ((int32_t) raw & 0xFFFFF000);
}

void ecall_handler(cpu_t *cpu)
{
    uint32_t syscall_nr = cpu->regs[17];

    switch (syscall_nr) {
    case 1: {  /* Ripes print integer */
        int32_t value = cpu->regs[10];
        printf("%d", value);
        break;
    }

    case 10: {  /* Ripes exit */
        int32_t exit_code = cpu->regs[10];
        exit(exit_code);
        break;
    }

    case 11: {  /* Ripes print character */
        char c = cpu->regs[10] & 0xFF;
        printf("%c", c);
        break;
    }

    default:
        fatal("unknown syscall number %d.\n", syscall_nr);
    }
}

static insn_t inst;
void cpu_execute(cpu_t *cpu, uint32_t raw)
{
    cpu_decode(raw, &inst);
    cpu->regs[0] = 0;

    switch (inst.opcode) {
    case INTEGER_COMP_RI: {
        int32_t imm = i_imm(raw);
        switch (inst.funct3) {
        case ADDI:
            cpu->regs[inst.rd] = cpu->regs[inst.rs1] + imm;
            break;
        case XORI:
            cpu->regs[inst.rd] = cpu->regs[inst.rs1] ^ imm;
            break;
        case ORI:
            cpu->regs[inst.rd] = cpu->regs[inst.rs1] | imm;
            break;
        default:
            fatal("Unknown FUNCT3 for INTEGER_COMP_RI: 0x%x\n", inst.funct3);
        }
        break;
    }

    case LOAD: {
        int32_t imm = i_imm(raw);
        uint32_t addr = cpu->regs[inst.rs1] + imm;
        if (inst.funct3 != LW)
            fatal("Unknown FUNCT3 for LOAD: 0x%x\n", inst.funct3);
        cpu->regs[inst.rd] = cpu_load(cpu, addr);
        break;
    }

    case STORE: {
        int32_t imm = s_imm(raw);
        uint32_t addr = cpu->regs[inst.rs1] + imm;
        if (inst.funct3 != SW)
            fatal("Unknown FUNCT3 for STORE: 0x%x\n", inst.funct3);
        cpu_store(cpu, addr, cpu->regs[inst.rs2]);
        break;
    }

    case JALR: {
        int32_t imm = i_imm(raw);
        uint32_t target = (cpu->regs[inst.rs1] + imm) & ~1;
        cpu->regs[inst.rd] = cpu->pc;
        cpu->pc = target;
        return; /* Don't increment PC */
    }

    case AUIPC: {
        int32_t imm = u_imm(raw);
        cpu->regs[inst.rd] = cpu->pc + imm;
        break;
    }

    case ECALL:
        if (raw == 0x100073) break;  /* EBREAK */
        ecall_handler(cpu);
        break;

    default:
        fatal("Illegal Instruction 0x%x at PC 0x%lx\n", inst.opcode, cpu->pc);
    }
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        printf("Usage: %s [filename]\n", argv[0]);
        exit(-1);
    }

    const char *filename = argv[1];
    FILE *file = fopen(filename, "rb");
    if (!file) {
        printf("Failed to open %s\n", filename);
        exit(-1);
    }
    fseek(file, 0L, SEEK_END);
    size_t code_size = ftell(file);
    rewind(file);

    uint8_t *code = malloc(code_size);
    fread(code, sizeof(uint8_t), code_size, file);
    fclose(file);
    cpu_t *cpu = cpu_new(code, code_size);

    while (1) {
        uint32_t raw = cpu_fetch(cpu);
        size_t old_pc = cpu->pc;
        cpu->pc += 4;
        if (cpu->pc > code_size) break;

        cpu_execute(cpu, raw);

        if (!cpu->pc) break;
    }

    cpu_free(cpu);
    return 0;
}
