.text:
start:
        j       main
# RV32 register-variable mapping (across functions)
# a0: input bfloat16 number a and return value (1 if NaN, 0 otherwise)
# s0: stack frame pointer
# ra: return address
# Stack frame layout (offsets from s0, across functions):
# -8 : saved s0
# -4 : saved ra
bf16_isnan:
# Register Role:
# t0: store result of a & Exp_mask (0x7F80)
# t1: store result of a & Mant_mask (0x007F)
# t2: store Exp_mask (0x7F80)

    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      s0, 0(sp)
    addi    s0, sp, 8

    li      t2,32640        # Load Exp_mask into t2
    and     t0, a0, t2              # t0 = a & Exp_mask
    beq     t0, t2, isnan_check_mantissa  # If (a & Exp_mask) == Exp_mask, check mantissa
    li      a0, 0               # Not NaN
    j       end_bf16_isnan

isnan_check_mantissa:
    andi    t1, a0, 127          # t1 = a & Mant_mask
    bne     t1, zero, is_nan      # If (a & Mant_mask) != 0, it is NaN
    li      a0, 0                 # Not NaN
    j       end_bf16_isnan

is_nan:
    li      a0, 1                 # Is NaN

end_bf16_isnan:
    lw      ra, 4(sp)
    lw      s0, 0(sp)
    addi    sp, sp, 8
    jr      ra
bf16_isinf:
# Register Role:
# t0: store result of a & Exp_mask (0x7F80)
# t1: store result of !(a & Mant_mask (0x007F))
# t2: store Exp_mask (0x7F80)
    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      s0, 0(sp)
    addi    s0, sp, 8

    li      t2,32640        # Load Exp_mask into t2
    and     t0, a0, t2              # t0 = a & Exp_mask
    beq     t0, t2, isinf_check_mantissa  # If (a & Exp_mask) == Exp_mask, check mantissa
    li      a0, 0               # Not Inf
    j       end_bf16_isinf
isinf_check_mantissa:
    andi    t1, a0, 127          # t1 = a & Mant_mask
    beq     t1, zero, is_inf      # If (a & Mant_mask) == 0, it is Inf
    li      a0, 0                 # Not Inf
    j       end_bf16_isinf
is_inf:
    li      a0, 1                 # Is Inf
end_bf16_isinf:
    lw      ra, 4(sp)
    lw      s0, 0(sp)
    addi    sp, sp, 8
    jr      ra
bf16_iszero:
# Register Role:
# t0: store result of !(a & ~Sign_mask (0x7FFF))
    addi    sp, sp, -8
    sw      ra, 4(sp)
    sw      s0, 0(sp)
    addi    s0, sp, 8

    li      t0, 32767              # Load ~Sign_mask into t0
    and     t0, a0, t0              # t0 = a & ~Sign_mask
    xori    t0, t0, 1                # Negate the result for zero check
    add     a0, t0, zero            # Move result to a0
    lw      ra, 4(sp)
    lw      s0, 0(sp)
    addi    sp, sp, 8
    jr      ra

# test_bf16_special_cases(): construct test constants and validate predicates; return 1 if all pass else 0
test_bf16_special_cases:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48

        # Initialize constants: nan1, nan2, +inf, -inf, +0, -0, num=1.0 (store to stack locals)
        li      a5,-32768
        xori    a5,a5,-63
        sh      a5,-20(s0)
        li      a5,-32768
        xori    a5,a5,-1
        sh      a5,-24(s0)
        li      a5,-32768
        xori    a5,a5,-128
        sh      a5,-28(s0)
        li      a5,-128
        sh      a5,-32(s0)
        sh      zero,-36(s0)
        li      a5,-32768
        sh      a5,-40(s0)
        li      a5,16384
        addi    a5,a5,-128
        sh      a5,-44(s0)

        # Assert: isnan(nan1) && isnan(nan2)
        lhu     a5,-20(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L12
        li      a5,0
        j       L22
L12:
        lhu     a5,-24(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L14
        li      a5,0
        j       L22

        # Assert: isinf(+inf) && isinf(-inf)
L14:
        lhu     a5,-28(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L15
        li      a5,0
        j       L22
L15:
        lhu     a5,-32(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L16
        li      a5,0
        j       L22

        # Assert: iszero(+0) && iszero(-0)
L16:
        lhu     a5,-36(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L17
        li      a5,0
        j       L22
L17:
        lhu     a5,-40(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L18
        li      a5,0
        j       L22

        # Assert: !isnan(num) && !isinf(num) && !iszero(num)
L18:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        beq     a5,zero,L19
        li      a5,0
        j       L22
L19:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        beq     a5,zero,L20
        li      a5,0
        j       L22
L20:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        beq     a5,zero,L21
        li      a5,0
        j       L22

        # All assertions passed �� return true
L21:
        li      a5,1
L22:
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra

# main(): run tests; map boolean to process exit code 0/1 and issue Ripes exit ecall
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16

        # Call test; invert to exit code: success->0, fail->1; return to simulator
        call    test_bf16_special_cases
        mv      a5,a0
        beq     a5,zero,L24
        li      a5,0
        j       L25
L24:
        li      a5,1
L25:
        mv      a0,a5
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        j       Exit

Exit:
        # Ripes environment: ecall with a7=10 exits the program
        li   a7,10
        ecall