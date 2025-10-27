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
    LOAD = 0x03,
    STORE = 0x23,
    JALR = 0x67,
    AUIPC = 0x17,
    ECALL = 0x73,
};

/* FUNCT3 for INTEGER_COMP_RI */
enum {
    ADDI = 0x0,
    XORI = 0x4,
    ORI = 0x6,
};

/* FUNCT3 for LOAD/STORE */
enum {
    LW = 0x2,
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

    /* Cache frequently used pointers for faster access */
    uint8_t *mem = cpu->ram->mem;
    uint32_t *regs = cpu->regs;

    /* Jump table for computed goto dispatch */
    static void *dispatch_table[256] = {
        [0x13] = &&op_integer_comp_ri,
        [0x03] = &&op_load,
        [0x23] = &&op_store,
        [0x67] = &&op_jalr,
        [0x17] = &&op_auipc,
        [0x73] = &&op_ecall,
    };

    /* Decode macros - extract fields on demand */
    #define OPCODE(insn) ((insn) & 0x7F)
    #define RD(insn)     (((insn) >> 7) & 0x1F)
    #define RS1(insn)    (((insn) >> 15) & 0x1F)
    #define RS2(insn)    (((insn) >> 20) & 0x1F)
    #define FUNCT3(insn) (((insn) >> 12) & 0x7)

    /* Immediate extraction macros */
    #define I_IMM(insn)  ((int32_t)(insn) >> 20)
    #define S_IMM(insn)  ((int32_t)(((insn) & 0xFE000000) | (((insn) >> 20) & 0xFE0)) >> 20)
    #define U_IMM(insn)  ((int32_t)((insn) & 0xFFFFF000))

    /* Direct memory access - assumes little-endian host */
    #define LOAD32(addr)  (*(uint32_t *)(&mem[(addr) - RAM_BASE]))
    #define STORE32(addr, val) (*(uint32_t *)(&mem[(addr) - RAM_BASE]) = (val))

    /* Fetch and dispatch macro */
    #define FETCH_AND_DISPATCH() do {                       \
        if (cpu->pc >= code_size) goto end;                 \
        raw = LOAD32(cpu->pc);                              \
        cpu->pc += 4;                                       \
        opcode = OPCODE(raw);                               \
        void *target = dispatch_table[opcode];              \
        if (!target) goto illegal_instruction;              \
        goto *target;                                       \
    } while (0)

    uint32_t raw;
    uint8_t opcode;

    /* Start of interpreter loop */
    FETCH_AND_DISPATCH();

    /*
     * Instruction implementations using computed goto
     * Each label handles one instruction type, then fetches the next
     */

op_integer_comp_ri: {
    int32_t imm = I_IMM(raw);
    uint8_t rd = RD(raw);
    uint8_t rs1 = RS1(raw);
    uint8_t funct3 = FUNCT3(raw);

    switch (funct3) {
    case ADDI:
        regs[rd] = regs[rs1] + imm;
        break;
    case XORI:
        regs[rd] = regs[rs1] ^ imm;
        break;
    case ORI:
        regs[rd] = regs[rs1] | imm;
        break;
    default:
        fatal("Unknown FUNCT3 for INTEGER_COMP_RI: 0x%x\n", funct3);
    }
    regs[0] = 0;  /* x0 always zero */
    FETCH_AND_DISPATCH();
}

op_load: {
    int32_t imm = I_IMM(raw);
    uint8_t rd = RD(raw);
    uint8_t rs1 = RS1(raw);
    uint8_t funct3 = FUNCT3(raw);

    if (funct3 != LW)
        fatal("Unknown FUNCT3 for LOAD: 0x%x\n", funct3);

    uint32_t addr = regs[rs1] + imm;
    regs[rd] = LOAD32(addr);
    regs[0] = 0;
    FETCH_AND_DISPATCH();
}

op_store: {
    /* S-type immediate: imm[11:5] = inst[31:25], imm[4:0] = inst[11:7] */
    uint32_t imm_11_5 = (raw >> 25) & 0x7F;
    uint32_t imm_4_0 = (raw >> 7) & 0x1F;
    int32_t imm = (imm_11_5 << 5) | imm_4_0;
    if (imm & 0x800)
        imm |= 0xFFFFF000;

    uint8_t rs1 = RS1(raw);
    uint8_t rs2 = RS2(raw);
    uint8_t funct3 = FUNCT3(raw);

    if (funct3 != SW)
        fatal("Unknown FUNCT3 for STORE: 0x%x\n", funct3);

    uint32_t addr = regs[rs1] + imm;
    STORE32(addr, regs[rs2]);
    FETCH_AND_DISPATCH();
}

op_jalr: {
    int32_t imm = I_IMM(raw);
    uint8_t rd = RD(raw);
    uint8_t rs1 = RS1(raw);

    uint32_t target = (regs[rs1] + imm) & ~1;
    regs[rd] = cpu->pc;
    cpu->pc = target;
    regs[0] = 0;
    FETCH_AND_DISPATCH();
}

op_auipc: {
    int32_t imm = U_IMM(raw);
    uint8_t rd = RD(raw);

    regs[rd] = cpu->pc - 4 + imm;  /* PC already incremented */
    regs[0] = 0;
    FETCH_AND_DISPATCH();
}

op_ecall: {
    if (raw == 0x100073) {
        /* EBREAK - ignore */
        FETCH_AND_DISPATCH();
    }
    ecall_handler(cpu);
    FETCH_AND_DISPATCH();
}

illegal_instruction:
    fatal("Illegal Instruction 0x%x at PC 0x%lx\n", opcode, cpu->pc - 4);

end:
    cpu_free(cpu);
    return 0;
}
