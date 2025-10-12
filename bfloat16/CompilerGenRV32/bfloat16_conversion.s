# Global register conventions used here
#   a0    : arg / return
#   a1    : temp or second arg
#   a4/a5 : temps in leaf code
#   s0    : frame pointer
#   ra    : return address

.data
test_basic_conversions.bf16_cases:
        .half   0          # +0
        .half   32768      # -0
        .half   16256      # 1.0
        .half   49024      # -1.0
        .half   16384      # 2.0
        .half   16128      # 0.5
        .half   16457      # ~pi
        .half   49225      # ~-pi
        .half   32640      # +Inf
        .half   65408      # -Inf
        .half   32705      # qNaN
        .half   128        # small subnormal
        .half   127        # smallest nz subnormal
        .half   31743      # max finite

.text
start:
        j       main

# -----------------------------------------------------------------------------
# bool test_basic_conversions()
# Registers:
#   a0 : loop index i / call arg / return bool
#   a1 : byte offset into table
#   a5 : temps
# Stack frame (32B):
#   -16(s0) : i (uint32_t)
#   -18(s0) : orig.bits (uint16_t)
#   -24(s0) : f32bits scratch (uint32_t) from bf16_to_f32
#   -26(s0) : back.bits (uint16_t)
#   -9(s0)  : result byte (bool)
test_basic_conversions:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32

        # i = 0; loop over table of 14 entries
        li      a0, 0
        sw      a0, -16(s0)

LBB0_1:
        # loop condition: i <= 13
        lw      a1, -16(s0)
        li      a0, 13
        bltu    a0, a1, LBB0_6

        # load bf16_cases[i] -> orig.bits; do bf16->f32 then f32->bf16
        lw      a0, -16(s0)
        slli    a1, a0, 1
        lui     a0, %hi(test_basic_conversions.bf16_cases)
        addi    a0, a0, %lo(test_basic_conversions.bf16_cases)
        add     a0, a0, a1
        lh      a0, 0(a0)
        sh      a0, -18(s0)

        # f = bf16_to_f32(orig)
        lhu     a0, -18(s0)
        call    bf16_to_f32
        sw      a0, -24(s0)

        # back = f32_to_bf16(f)
        lw      a0, -24(s0)
        call    f32_to_bf16
        sh      a0, -26(s0)

        # compare round trip: back.bits == orig.bits ? continue : return false
        lhu     a0, -26(s0)
        lhu     a1, -18(s0)
        beq     a0, a1, LBB0_4

LBB0_3:
        # early exit false
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_7

LBB0_4:
        # i++
        lw      a0, -16(s0)
        addi    a0, a0, 1
        sw      a0, -16(s0)
        j       LBB0_1

LBB0_6:
        # all matched ¡÷ true
        li      a0, 1
        sb      a0, -9(s0)

LBB0_7:
        # return result
        lbu     a0, -9(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

# -----------------------------------------------------------------------------
# float bf16_to_f32(bf16 val)
#   Build 32-bit pattern by placing bf16 in high 16 bits, then bit-cast to float.
# Registers:
#   a0 : arg bf16.bits (low 16 in a0) / returns f32bits
# Stack frame (32B):
#   -10(s0) : bf16.bits (int16_t local copy)
#   -16(s0) : f32bits (uint32_t)
#   -20(s0) : result copy (uint32_t)
bf16_to_f32:
# Initialize stack frame (16B)
        addi    sp, sp, -8
        sw      ra, 4(sp)
        sw      s0, 0(sp)
        addi    s0, sp, 8

# Shifting 16 bits left to convert bf16 to f32
        slli    a0, a0, 16
# epilogue
        lw      ra, 4(sp)
        lw      s0, 0(sp)
        addi    sp, sp, 8
        jr      ra

# -----------------------------------------------------------------------------
# bf16_t f32_to_bf16(float val)
#   If exp==0xFF ¡÷ just truncate top 16 bits (Inf/NaN preserve payload).
#   Else round-to-nearest-even: add LSB of cut part plus 0x7FFF, then take top 16.
# Registers:
#   a0 : arg f32bits / returns bf16.bits (in low 16)
#   a1 : temps (exp calc, constants)
# Stack frame (32B):
#   -16(s0) : f32bits
#   -20(s0) : f32bits (working)
#   -10(s0) : bf16.bits (uint16_t out)
#   -18(s0) : scratch (unused load/store pair for flow)

f32_to_bf16:
# Register Roles:
# t0: saved result of input value of (f32bits >> 23) & 0xFF
# t1: saved constant 0xFF
# t2: saved result of input value of (f32bits >> 16) & 0x7FFF

# Initialize stack frame (16B)
        addi    sp, sp, -8
        sw      ra, 4(sp)
        sw      s0, 0(sp)
        addi    s0, sp, 8
        add     t0, a0, zero

# Calculate (f32bits >> 23) & 0xFF
        srli    t0, t0, 23
        andi    t0, t0, 0xFF
        li      t1, 0xFF
        beq     t0, t1, handling_inf_nan
# Not Inf or NaN case
# Rounding to Nearest, Ties to Even
        srli    t2, t0, 16
        andi    t2, t2, 1
        li      t2, 32767
        add     a0, a0, t2

# Shift right 16 to convert f32 to bf16
        srli    a0, a0, 16
        j       f32_to_bf16_epilogue
handling_inf_nan:
# Inf or NaN case: just shift right 16 bits to convert f32 to bf16
        srli    a0, a0, 16
        li      a0, 65535
f32_to_bf16_epilogue:
# epilogue
        lw      ra, 4(sp)
        lw      s0, 0(sp)
        addi    sp, sp, 8
        jr      ra

# -----------------------------------------------------------------------------
# int main()
#   Run test_basic_conversions; map true¡÷0, false¡÷1; exit via ecall.
# Registers:
#   a0 : test result / exit code
# Stack frame (16B):
#   -12(s0) : exit code
main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16

        # call test; set exit code: success¡÷0, fail¡÷1
        li      a0, 0
        sw      a0, -12(s0)
        call    test_basic_conversions
        beqz    a0, LBB3_2
LBB3_1:
        li      a0, 0
        sw      a0, -12(s0)
        j       LBB3_3
LBB3_2:
        li      a0, 1
        sw      a0, -12(s0)
LBB3_3:
        lw      a0, -12(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        j       Exit

Exit:
        # Ripes exit syscall
        li      a7, 10
        ecall
