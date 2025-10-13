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

# bf16_add
# ABI:
# a0=input a.bits (u16), a1=input b.bits (u16), a0=return bits (u16)
# Register Role:
# t0: sign_a
# t1: sign_b
# t2: exp_a
# t3: exp_b
# t4: mant_a
# t5: mant_b
# t6: exp_diff
# a2: result sign
# a3: result exp
# a4: result mant
# a5: temporary constant/ result

bf16_add:
        addi    sp, sp, -8
        sw      ra, 4(sp)
        sw      s0, 0(sp)
        addi    s0, sp, 8

# unpack
        srli    t0,a0,15
        andi    t0,t0,1
        srli    t1,a1,15
        andi    t1,t1,1
        srli    t2,a0,7
        andi    t2,t2,0xFF
        srli    t3,a1,7
        andi    t3,t3,0xFF
        andi    t4,a0,0x7F
        andi    t5,a1,0x7F

# ---- Special: exp_a==0xFF ----
        li      a5,0xFF
        bne     t2,a5, L_check_b_ff
        # exp_a==0xFF
        bnez    t4, L_ret_a              # mant_a!=0 => NaN, return a
        # mant_a==0 => a=Inf
        bne     t3,a5, L_ret_a           # b not Special => return a (Inf)
        # both Special
        bnez    t5, L_ret_b              # b NaN => return b
        # mant_b==0, both Inf: if sign_a==sign_b return b else qNaN
        bne     t0,t1, L_ret_qnan
        j       L_ret_b

# ---- Special: exp_b==0xFF ----
L_check_b_ff:
        li      a5,0xFF
        bne     t3,a5, L_check_a_zero
L_ret_b:
        add     a0,zero,a1
        j       L_epilogue
L_ret_a:
        add     a0,zero,a0
        j       L_epilogue
L_ret_qnan:
        li      a0,0x7FC0
        j       L_epilogue

# ---- a==0? (!exp_a && !mant_a) -> b ----
L_check_a_zero:
        beqz    t2, 1f
        j       L_check_b_zero
1:
        beqz    t4, L_ret_b
        j       L_check_b_zero

# ---- b==0? (!exp_b && !mant_b) -> a ----
L_check_b_zero:
        beqz    t3, 2f
        j       L_set_implicit
2:
        beqz    t5, L_ret_a

# ---- implicit leading 1 when normalized ----
L_set_implicit:
        beqz    t2, 3f
        ori     t4,t4,0x80
3:
        beqz    t3, 4f
        ori     t5,t5,0x80
4:

# ---- exponent alignment ----
        sub     t6,t2,t3                 # exp_diff
        bgtz    t6, L_diff_pos
        bltz    t6, L_diff_neg
        add     a3,zero,t2               # diff==0
        j       L_sign_check
L_diff_pos:
        add     a3,zero,t2
        li      a5,9
        bge     t6,a5, L_ret_a           # diff>=9 -> return a
        srl     t5,t5,t6                 # mant_b >>= diff
        j       L_sign_check
L_diff_neg:
        add     a3,zero,t3
        li      a5,-8
        blt     t6,a5, L_ret_b           # diff<-8 -> return b
        neg     a5,t6                    # a5 = -diff
        srl     t4,t4,a5                 # mant_a >>= -diff

# ---- sign check ----
L_sign_check:
        bne     t0,t1, L_sign_diff

# same sign: add
        add     a2,zero,t0
        add     a4,t4,t5                 # 0..510
        andi    a5,a4,0x100              # carry?
        beqz    a5, L_pack
        srli    a4,a4,1                  # >>1
        addi    a3,a3,1                  # exp++
        li      a5,0xFF
        blt     a3,a5, L_pack            # if exp<255 ok
        # overflow -> signed Inf
        slli    a0,a2,15
        li      a5,0x7F80
        or      a0,a0,a5
        j       L_epilogue

# different sign: subtract larger mant
L_sign_diff:
        blt     t4,t5, 5f
        add     a2,zero,t0
        sub     a4,t4,t5
        j       6f
5:
        add     a2,zero,t1
        sub     a4,t5,t4
6:
        beqz    a4, L_ret_zero

# normalize left until bit7 set; exp--
L_norm:
        andi    a5,a4,0x80
        bnez    a5, L_pack
        slli    a4,a4,1
        addi    a3,a3,-1
        blez    a3, L_ret_zero
        j       L_norm

# pack result
L_pack:
        slli    a0,a2,15
        andi    a3,a3,0xFF
        slli    a5,a3,7
        or      a0,a0,a5
        andi    a4,a4,0x7F
        or      a0,a0,a4
        j       L_epilogue

L_ret_zero:
        add     a0,zero,zero

L_epilogue:
        lw      ra, 4(sp)
        lw      s0, 0(sp)
        addi    sp, sp, 8
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

bf16_sub:
        addi    sp, sp, -8
        sw      ra, 4(sp)
        sw      s0, 0(sp)
        addi    s0, sp, 8

        xori    a1,a1,0x8000
        call    bf16_add

        lw      ra, 4(sp)
        lw      s0, 0(sp)
        addi    sp, sp, 8
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
