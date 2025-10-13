.data
test_basic_add_sub.tv:
        .zero   8
        .half   16256
        .half   16256
        .half   16384
        .zero   2
        .half   16256
        .half   16128
        .half   16320
        .half   16128
        .half   16384
        .half   49024
        .half   16256
        .half   16448
        .half   49088
        .half   16128
        .half   49024
        .half   49152
        .half   49024
        .half   16256
        .zero   2
        .half   49152
        .half   16256
        .half   49024
        .zero   2
        .half   16384
        .half   16384
        .half   15232
        .half   16384
        .half   16384

.text
start:
        j       main
test_basic_add_sub:
        addi    sp, sp, -48
        sw      ra, 44(sp)
        sw      s0, 40(sp)
        addi    s0, sp, 48
        li      a0, 0
        sw      a0, -16(s0)
        j       LBB0_1
LBB0_1:
        lw      a1, -16(s0)
        li      a0, 7
        bltu    a0, a1, LBB0_20
        j       LBB0_2
LBB0_2:
        lw      a0, -16(s0)
        slli    a1, a0, 3
        lui     a0, %hi(test_basic_add_sub.tv)
        addi    a0, a0, %lo(test_basic_add_sub.tv)
        sw      a0, -48(s0)
        add     a1, a0, a1
        lh      a1, 0(a1)
        sh      a1, -18(s0)
        lw      a1, -16(s0)
        slli    a1, a1, 3
        add     a0, a0, a1
        lh      a0, 2(a0)
        sh      a0, -20(s0)
        lhu     a0, -18(s0)
        lhu     a1, -20(s0)
        call    bf16_add
        mv      a1, a0
        lw      a0, -48(s0)
        sh      a1, -22(s0)
        lw      a1, -16(s0)
        slli    a1, a1, 3
        add     a1, a0, a1
        lhu     a0, -22(s0)
        lhu     a1, 4(a1)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_4
        j       LBB0_3
LBB0_3:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_4:
        lhu     a0, -20(s0)
        lhu     a1, -18(s0)
        call    bf16_add
        sh      a0, -24(s0)
        lw      a0, -16(s0)
        slli    a1, a0, 3
        lui     a0, %hi(test_basic_add_sub.tv)
        addi    a0, a0, %lo(test_basic_add_sub.tv)
        add     a1, a0, a1
        lhu     a0, -24(s0)
        lhu     a1, 4(a1)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_6
        j       LBB0_5
LBB0_5:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_6:
        lhu     a0, -18(s0)
        lhu     a1, -20(s0)
        call    bf16_sub
        sh      a0, -26(s0)
        lw      a0, -16(s0)
        slli    a1, a0, 3
        lui     a0, %hi(test_basic_add_sub.tv)
        addi    a0, a0, %lo(test_basic_add_sub.tv)
        add     a1, a0, a1
        lhu     a0, -26(s0)
        lhu     a1, 6(a1)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_8
        j       LBB0_7
LBB0_7:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_8:
        lhu     a0, -20(s0)
        lhu     a1, -18(s0)
        call    bf16_sub
        sh      a0, -28(s0)
        lhu     a0, -26(s0)
        call    neg
        sh      a0, -30(s0)
        lhu     a0, -28(s0)
        lhu     a1, -30(s0)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_10
        j       LBB0_9
LBB0_9:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_10:
        li      a0, 0
        sh      a0, -34(s0)
        lhu     a0, -18(s0)
        lhu     a1, -34(s0)
        call    bf16_add
        sh      a0, -32(s0)
        lhu     a0, -32(s0)
        lhu     a1, -18(s0)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_12
        j       LBB0_11
LBB0_11:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_12:
        li      a0, 0
        sh      a0, -38(s0)
        lhu     a0, -38(s0)
        lhu     a1, -18(s0)
        call    bf16_add
        sh      a0, -36(s0)
        lhu     a0, -36(s0)
        lhu     a1, -18(s0)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_14
        j       LBB0_13
LBB0_13:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_14:
        li      a0, 0
        sh      a0, -42(s0)
        lhu     a0, -18(s0)
        lhu     a1, -42(s0)
        call    bf16_sub
        sh      a0, -40(s0)
        lhu     a0, -40(s0)
        lhu     a1, -18(s0)
        call    eq_allow_signed_zero
        bnez    a0, LBB0_16
        j       LBB0_15
LBB0_15:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_16:
        lhu     a1, -18(s0)
        mv      a0, a1
        call    bf16_sub
        sh      a0, -44(s0)
        lhu     a0, -44(s0)
        call    is_zero_mag
        bnez    a0, LBB0_18
        j       LBB0_17
LBB0_17:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_18:
        j       LBB0_19
LBB0_19:
        lw      a0, -16(s0)
        addi    a0, a0, 1
        sw      a0, -16(s0)
        j       LBB0_1
LBB0_20:
        li      a0, 1
        sb      a0, -9(s0)
        j       LBB0_21
LBB0_21:
        lbu     a0, -9(s0)
        lw      ra, 44(sp)
        lw      s0, 40(sp)
        addi    sp, sp, 48
        ret

############################################################
# bf16_add
# ABI: a0=input a.bits (u16), a1=input b.bits (u16), a0=return bits (u16)
# Callee-saved: s0. Caller-saved: a0–a7.
#
# Stack frame (48 bytes):
#   [sp+44] ra
#   [sp+40] s0
#   Locals (relative to s0):
#     -10: u16 result_bits
#     -12: u16 a_bits
#     -14: u16 b_bits
#     -16: u16 sign_a
#     -18: u16 sign_b
#     -20: i16 exp_a
#     -22: i16 exp_b
#     -24: u16 mant_a (7-bit field, later with implicit 1)
#     -26: u16 mant_b (7-bit field, later with implicit 1)
#     -28: i16 exp_diff
#     -30: u16 result_sign
#     -32: i16 result_exp
#     -36..-33: u32 result_mant (temp, uses word ops)
#
# Sections:
#   Prologue: create frame, spill a/b.
############################################################
bf16_add:
        addi    sp, sp, -48
        sw      ra, 44(sp)
        sw      s0, 40(sp)
        addi    s0, sp, 48
        sh      a0, -12(s0)
        sh      a1, -14(s0)

############################################################
# Unpack fields:
#   sign_a/sign_b = bits>>15 & 1
#   exp_a/exp_b   = bits[14:7]
#   mant_a/mant_b = bits[6:0]
############################################################
        lhu     a0, -12(s0)
        srli    a0, a0, 15
        sh      a0, -16(s0)
        lhu     a0, -14(s0)
        srli    a0, a0, 15
        sh      a0, -18(s0)
        lhu     a0, -12(s0)
        slli    a0, a0, 17
        srli    a0, a0, 24
        sh      a0, -20(s0)
        lhu     a0, -14(s0)
        slli    a0, a0, 17
        srli    a0, a0, 24
        sh      a0, -22(s0)
        lhu     a0, -12(s0)
        andi    a0, a0, 127
        sh      a0, -24(s0)
        lhu     a0, -14(s0)
        andi    a0, a0, 127
        sh      a0, -26(s0)

############################################################
# Special cases on a:
#   if exp_a==0xFF:
#     if mant_a!=0 -> return a (NaN)
#     else if exp_b==0xFF:
#       if mant_b!=0 or sign_a==sign_b -> return b
#       else -> return qNaN
#     else -> return a (Inf)
############################################################
        lh      a0, -20(s0)
        li      a1, 255
        bne     a0, a1, LBB1_10
LBB1_1:
        lhu     a0, -24(s0)
        beqz    a0, LBB1_3
LBB1_2:
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_3:
        lh      a0, -22(s0)
        li      a1, 255
        bne     a0, a1, LBB1_9
LBB1_4:
        lhu     a0, -26(s0)
        bnez    a0, LBB1_6
LBB1_5:
        lhu     a0, -16(s0)
        lhu     a1, -18(s0)
        bne     a0, a1, LBB1_7
LBB1_6:
        lh      a0, -14(s0)              # return b (Inf or NaN)
        sh      a0, -10(s0)
        j       LBB1_8
LBB1_7:
        lui     a0, 8                     # return qNaN 0x7FC0
        addi    a0, a0, -64
        sh      a0, -10(s0)
LBB1_8:
        j       LBB1_50
LBB1_9:
        lh      a0, -12(s0)              # return a (Inf)
        sh      a0, -10(s0)
        j       LBB1_50

############################################################
# Special cases on b:
#   if exp_b==0xFF -> return b
#   if a==0 -> return b
#   if b==0 -> return a
#   If normalized, set implicit 1: mant|=0x80
############################################################
LBB1_10:
        lh      a0, -22(s0)
        li      a1, 255
        bne     a0, a1, LBB1_12
LBB1_11:
        lh      a0, -14(s0)              # return b
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_12:
        lhu     a0, -20(s0)
        bnez    a0, LBB1_15
LBB1_13:
        lhu     a0, -24(s0)
        bnez    a0, LBB1_15
LBB1_14:
        lh      a0, -14(s0)              # a==0 -> return b
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_15:
        lhu     a0, -22(s0)
        bnez    a0, LBB1_18
LBB1_16:
        lhu     a0, -26(s0)
        bnez    a0, LBB1_18
LBB1_17:
        lh      a0, -12(s0)              # b==0 -> return a
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_18:
        lhu     a0, -20(s0)
        beqz    a0, LBB1_20
LBB1_19:
        lh      a0, -24(s0)              # mant_a |= 0x80
        ori     a0, a0, 128
        sh      a0, -24(s0)
LBB1_20:
        lhu     a0, -22(s0)
        beqz    a0, LBB1_22
LBB1_21:
        lh      a0, -26(s0)              # mant_b |= 0x80
        ori     a0, a0, 128
        sh      a0, -26(s0)

############################################################
# Exponent alignment:
#   exp_diff = exp_a - exp_b
#   If exp_diff>0:
#     result_exp=exp_a; if exp_diff>=9 -> return a; shift mant_b>>=exp_diff
#   Else if exp_diff<0:
#     result_exp=exp_b; if exp_diff<=-9 -> return b; shift mant_a>>=-exp_diff
#   Else result_exp=exp_a
############################################################
LBB1_22:
        lh      a0, -20(s0)
        lh      a1, -22(s0)
        sub     a0, a0, a1
        sh      a0, -28(s0)
        lh      a1, -28(s0)
        li      a0, 0
        bge     a0, a1, LBB1_26          # exp_diff <= 0?
LBB1_23:                                  # exp_diff > 0
        lh      a0, -20(s0)
        sh      a0, -32(s0)              # result_exp = exp_a
        lh      a0, -28(s0)
        li      a1, 9
        blt     a0, a1, LBB1_25
LBB1_24:                                  # gap >= 9 -> return a
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_25:
        lh      a1, -28(s0)
        lhu     a0, -26(s0)
        srl     a0, a0, a1                # mant_b >>= exp_diff
        sh      a0, -26(s0)
        j       LBB1_32
LBB1_26:                                  # exp_diff <= 0
        lh      a0, -28(s0)
        bgez    a0, LBB1_30               # exp_diff == 0
LBB1_27:                                  # exp_diff < 0
        lh      a0, -22(s0)
        sh      a0, -32(s0)               # result_exp = exp_b
        lh      a1, -28(s0)
        li      a0, -9
        blt     a0, a1, LBB1_29
LBB1_28:                                  # gap <= -9 -> return b
        lh      a0, -14(s0)
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_29:
        lh      a1, -28(s0)
        li      a0, 0
        sub     a1, a0, a1                # -exp_diff
        lhu     a0, -24(s0)
        srl     a0, a0, a1                # mant_a >>= -exp_diff
        sh      a0, -24(s0)
        j       LBB1_31
LBB1_30:                                  # exp_diff == 0
        lh      a0, -20(s0)
        sh      a0, -32(s0)               # result_exp = exp_a
LBB1_31:
        j       LBB1_32

############################################################
# Same-sign path:
#   if sign_a==sign_b:
#     result_sign=sign_a
#     result_mant=mant_a+mant_b
#     if carry -> shift right, result_exp++
#       if result_exp>=0xFF -> return signed Inf
############################################################
LBB1_32:
        lhu     a0, -16(s0)
        lhu     a1, -18(s0)
        bne     a0, a1, LBB1_38
LBB1_33:
        lh      a0, -16(s0)
        sh      a0, -30(s0)               # result_sign
        lhu     a0, -24(s0)
        lhu     a1, -26(s0)
        add     a0, a0, a1
        sw      a0, -36(s0)               # result_mant
        lbu     a0, -35(s0)
        andi    a0, a0, 1
        beqz    a0, LBB1_37               # no carry
LBB1_34:                                  # carry path
        lw      a0, -36(s0)
        srli    a0, a0, 1                 # mant >>= 1
        sw      a0, -36(s0)
        lh      a1, -32(s0)
        slli    a0, a1, 16
        addi    a1, a1, 1                 # result_exp++
        sh      a1, -32(s0)
        lui     a1, 16
        add     a0, a0, a1
        srai    a0, a0, 16
        li      a1, 255
        blt     a0, a1, LBB1_36
LBB1_35:                                  # overflow -> signed Inf
        lh      a0, -30(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128              # 0x7F80
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_36:
        j       LBB1_37
LBB1_37:
        j       LBB1_49

############################################################
# Different-sign path:
#   subtract larger mantissa from smaller
#   result_sign = sign of larger
#   if zero -> return +0
#   normalize left until bit7 set, decrement result_exp each shift
#   if result_exp <= 0 -> return 0
############################################################
LBB1_38:
        lhu     a0, -24(s0)
        lhu     a1, -26(s0)
        blt     a0, a1, LBB1_40
LBB1_39:                                  # mant_a >= mant_b
        lh      a0, -16(s0)
        sh      a0, -30(s0)               # result_sign = sign_a
        lhu     a0, -24(s0)
        lhu     a1, -26(s0)
        sub     a0, a0, a1
        sw      a0, -36(s0)               # result_mant
        j       LBB1_41
LBB1_40:                                  # mant_b > mant_a
        lh      a0, -18(s0)
        sh      a0, -30(s0)               # result_sign = sign_b
        lhu     a0, -26(s0)
        lhu     a1, -24(s0)
        sub     a0, a0, a1
        sw      a0, -36(s0)
LBB1_41:
        lw      a0, -36(s0)
        bnez    a0, LBB1_43               # non-zero
LBB1_42:
        li      a0, 0                      # exact cancel -> +0
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_43:                                  # normalize left
LBB1_44:
        lbu     a0, -36(s0)
        andi    a0, a0, 128                # test bit7
        bnez    a0, LBB1_48
LBB1_45:
        lw      a0, -36(s0)
        slli    a0, a0, 1
        sw      a0, -36(s0)
        lh      a1, -32(s0)
        slli    a0, a1, 16
        addi    a1, a1, -1                 # result_exp--
        sh      a1, -32(s0)
        lui     a1, 1048560                # bounds check (<=0) -> zero
        add     a0, a0, a1
        srai    a1, a0, 16
        li      a0, 0
        blt     a0, a1, LBB1_47
LBB1_46:
        li      a0, 0
        sh      a0, -10(s0)
        j       LBB1_50
LBB1_47:
        j       LBB1_44

############################################################
# Pack result:
#   bits = (result_sign<<15) | (result_exp<<7) | (result_mant & 0x7F)
############################################################
LBB1_48:
        j       LBB1_49
LBB1_49:
        lh      a0, -30(s0)
        slli    a0, a0, 15
        lbu     a1, -32(s0)
        slli    a1, a1, 7
        or      a0, a0, a1
        lw      a1, -36(s0)
        andi    a1, a1, 127
        or      a0, a0, a1
        sh      a0, -10(s0)

############################################################
# Epilogue: move result to a0 and return.
############################################################
LBB1_50:
        lhu     a0, -10(s0)
        lw      ra, 44(sp)
        lw      s0, 40(sp)
        addi    sp, sp, 48
        ret

eq_allow_signed_zero:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        sh      a1, -12(s0)
        lhu     a0, -12(s0)
        call    is_zero_mag
        beqz    a0, LBB2_2
        j       LBB2_1
LBB2_1:
        lhu     a0, -10(s0)
        call    is_zero_mag
        sw      a0, -16(s0)
        j       LBB2_3
LBB2_2:
        lhu     a0, -10(s0)
        lhu     a1, -12(s0)
        xor     a0, a0, a1
        seqz    a0, a0
        sw      a0, -16(s0)
        j       LBB2_3
LBB2_3:
        lw      a0, -16(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

############################################################
# bf16_sub
# ABI: a0=a.bits, a1=b.bits. Returns a0 = (a - b).bits.
#
# Stack frame (16 bytes):
#   [sp+12] ra
#   [sp+8]  s0
#   Locals:
#     -12: u16 a_bits
#     -14: u16 b_bits (to be negated)
#     -10: u16 result_bits
#
# Sections:
#   Prologue: save inputs.
#   Flip sign of b (xor with 0x8000).
#   Call bf16_add(a, -b).
#   Epilogue: return result.
############################################################
bf16_sub:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -12(s0)
        sh      a1, -14(s0)
        lh      a0, -14(s0)
        lui     a1, 8              # 0x8000
        xor     a0, a0, a1         # negate b
        sh      a0, -14(s0)
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_add
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret


neg:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -12(s0)
        lh      a0, -12(s0)
        lui     a1, 8
        xor     a0, a0, a1
        sh      a0, -12(s0)
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

is_zero_mag:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        slli    a0, a0, 17
        seqz    a0, a0
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

test_inf_nan:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        addi    s0, sp, 64
        lui     a0, 4
        addi    a1, a0, -128
        sh      a1, -10(s0)
        sh      a0, -12(s0)
        lui     a0, 8
        addi    a1, a0, -128
        sh      a1, -14(s0)
        li      a1, -128
        sh      a1, -16(s0)
        addi    a0, a0, -64
        sh      a0, -18(s0)
        lhu     a0, -18(s0)
        lhu     a1, -10(s0)
        call    bf16_add
        sh      a0, -20(s0)
        lhu     a0, -20(s0)
        call    is_nan
        bnez    a0, LBB6_2
        j       LBB6_1
LBB6_1:
        j       LBB6_2
LBB6_2:
        lhu     a0, -10(s0)
        lhu     a1, -18(s0)
        call    bf16_add
        sh      a0, -22(s0)
        lhu     a0, -22(s0)
        call    is_nan
        bnez    a0, LBB6_4
        j       LBB6_3
LBB6_3:
        j       LBB6_4
LBB6_4:
        lhu     a1, -18(s0)
        mv      a0, a1
        call    bf16_add
        sh      a0, -24(s0)
        lhu     a0, -24(s0)
        call    is_nan
        bnez    a0, LBB6_6
        j       LBB6_5
LBB6_5:
        j       LBB6_6
LBB6_6:
        lhu     a0, -18(s0)
        lhu     a1, -10(s0)
        call    bf16_sub
        sh      a0, -26(s0)
        lhu     a0, -26(s0)
        call    is_nan
        bnez    a0, LBB6_8
        j       LBB6_7
LBB6_7:
        j       LBB6_8
LBB6_8:
        lhu     a0, -10(s0)
        lhu     a1, -18(s0)
        call    bf16_sub
        sh      a0, -28(s0)
        lhu     a0, -28(s0)
        call    is_nan
        bnez    a0, LBB6_10
        j       LBB6_9
LBB6_9:
        j       LBB6_10
LBB6_10:
        lhu     a1, -18(s0)
        mv      a0, a1
        call    bf16_sub
        sh      a0, -30(s0)
        lhu     a0, -30(s0)
        call    is_nan
        bnez    a0, LBB6_12
        j       LBB6_11
LBB6_11:
        j       LBB6_12
LBB6_12:
        lhu     a0, -14(s0)
        lhu     a1, -12(s0)
        call    bf16_add
        sh      a0, -32(s0)
        lhu     a0, -32(s0)
        call    is_pinf
        bnez    a0, LBB6_14
        j       LBB6_13
LBB6_13:
        j       LBB6_14
LBB6_14:
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_add
        sh      a0, -34(s0)
        lhu     a0, -34(s0)
        call    is_pinf
        bnez    a0, LBB6_16
        j       LBB6_15
LBB6_15:
        j       LBB6_16
LBB6_16:
        lhu     a0, -16(s0)
        lhu     a1, -12(s0)
        call    bf16_add
        sh      a0, -36(s0)
        lhu     a0, -36(s0)
        call    is_ninf
        bnez    a0, LBB6_18
        j       LBB6_17
LBB6_17:
        j       LBB6_18
LBB6_18:
        lhu     a0, -12(s0)
        lhu     a1, -16(s0)
        call    bf16_add
        sh      a0, -38(s0)
        lhu     a0, -38(s0)
        call    is_ninf
        bnez    a0, LBB6_20
        j       LBB6_19
LBB6_19:
        j       LBB6_20
LBB6_20:
        lhu     a0, -12(s0)
        lhu     a1, -16(s0)
        call    bf16_sub
        sh      a0, -40(s0)
        lhu     a0, -40(s0)
        call    is_pinf
        bnez    a0, LBB6_22
        j       LBB6_21
LBB6_21:
        j       LBB6_22
LBB6_22:
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_sub
        sh      a0, -42(s0)
        lhu     a0, -42(s0)
        call    is_ninf
        bnez    a0, LBB6_24
        j       LBB6_23
LBB6_23:
        j       LBB6_24
LBB6_24:
        lhu     a1, -14(s0)
        mv      a0, a1
        call    bf16_add
        sh      a0, -44(s0)
        lhu     a0, -44(s0)
        call    is_pinf
        bnez    a0, LBB6_26
        j       LBB6_25
LBB6_25:
        j       LBB6_26
LBB6_26:
        lhu     a1, -16(s0)
        mv      a0, a1
        call    bf16_add
        sh      a0, -46(s0)
        lhu     a0, -46(s0)
        call    is_ninf
        bnez    a0, LBB6_28
        j       LBB6_27
LBB6_27:
        j       LBB6_28
LBB6_28:
        lhu     a0, -14(s0)
        lhu     a1, -16(s0)
        call    bf16_add
        sh      a0, -48(s0)
        lhu     a0, -48(s0)
        call    is_nan
        bnez    a0, LBB6_30
        j       LBB6_29
LBB6_29:
        j       LBB6_30
LBB6_30:
        lhu     a0, -16(s0)
        lhu     a1, -14(s0)
        call    bf16_add
        sh      a0, -50(s0)
        lhu     a0, -50(s0)
        call    is_nan
        bnez    a0, LBB6_32
        j       LBB6_31
LBB6_31:
        j       LBB6_32
LBB6_32:
        lhu     a1, -14(s0)
        mv      a0, a1
        call    bf16_sub
        sh      a0, -52(s0)
        lhu     a0, -52(s0)
        call    is_nan
        bnez    a0, LBB6_34
        j       LBB6_33
LBB6_33:
        j       LBB6_34
LBB6_34:
        lhu     a0, -14(s0)
        lhu     a1, -16(s0)
        call    bf16_sub
        sh      a0, -54(s0)
        lhu     a0, -54(s0)
        call    is_pinf
        bnez    a0, LBB6_36
        j       LBB6_35
LBB6_35:
        j       LBB6_36
LBB6_36:
        lhu     a0, -16(s0)
        lhu     a1, -14(s0)
        call    bf16_sub
        sh      a0, -56(s0)
        lhu     a0, -56(s0)
        call    is_ninf
        bnez    a0, LBB6_38
        j       LBB6_37
LBB6_37:
        j       LBB6_38
LBB6_38:
        li      a0, 1
        lw      ra, 60(sp)
        lw      s0, 56(sp)
        addi    sp, sp, 64
        ret

is_nan:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        lui     a1, 8
        addi    a1, a1, -128
        and     a0, a0, a1
        li      a2, 0
        sw      a2, -16(s0)
        bne     a0, a1, LBB7_2
        j       LBB7_1
LBB7_1:
        lhu     a0, -10(s0)
        andi    a0, a0, 127
        snez    a0, a0
        sw      a0, -16(s0)
        j       LBB7_2
LBB7_2:
        lw      a0, -16(s0)
        andi    a0, a0, 1
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

is_pinf:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        lui     a1, 8
        addi    a1, a1, -128
        xor     a0, a0, a1
        seqz    a0, a0
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

is_ninf:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        lhu     a0, -10(s0)
        lui     a1, 16
        addi    a1, a1, -128
        xor     a0, a0, a1
        seqz    a0, a0
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -12(s0)
        call    test_basic_add_sub
        beqz    a0, LBB10_3
        j       LBB10_1
LBB10_1:
        call    test_inf_nan
        beqz    a0, LBB10_3
        j       LBB10_2
LBB10_2:
        li      a0, 0
        sw      a0, -12(s0)
        j       LBB10_4
LBB10_3:
        li      a0, 1
        sw      a0, -12(s0)
        j       LBB10_4
LBB10_4:
        lw      a0, -12(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        j       Exit
Exit:
        li      a7, 10
        ecall
