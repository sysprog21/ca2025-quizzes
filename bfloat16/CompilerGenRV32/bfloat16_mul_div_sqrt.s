.text
start:
        j       main
test_mul_div_sqrt:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        lui     a0, 4
        sw      a0, -28(s0)
        addi    a1, a0, 288
        sh      a1, -12(s0)
        sh      a0, -14(s0)
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_mul
        lw      a1, -28(s0)
        sh      a0, -16(s0)
        lhu     a0, -16(s0)
        addi    a1, a1, 416
        blt     a0, a1, LBB0_2
        j       LBB0_1
LBB0_1:
        lhu     a0, -16(s0)
        lui     a1, 4
        addi    a1, a1, 418
        blt     a0, a1, LBB0_3
        j       LBB0_2
LBB0_2:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_3:
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_div
        sh      a0, -18(s0)
        lhu     a0, -18(s0)
        lui     a1, 4
        addi    a1, a1, 160
        blt     a0, a1, LBB0_5
        j       LBB0_4
LBB0_4:
        lhu     a0, -18(s0)
        lui     a1, 4
        addi    a1, a1, 162
        blt     a0, a1, LBB0_6
        j       LBB0_5
LBB0_5:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_6:
        lui     a0, 4
        sw      a0, -32(s0)
        addi    a0, a0, 128
        sh      a0, -20(s0)
        lhu     a0, -20(s0)
        call    bf16_sqrt
        lw      a1, -32(s0)
        sh      a0, -22(s0)
        lhu     a0, -22(s0)
        blt     a0, a1, LBB0_8
        j       LBB0_7
LBB0_7:
        lhu     a0, -22(s0)
        lui     a1, 4
        addi    a1, a1, 1
        blt     a0, a1, LBB0_9
        j       LBB0_8
LBB0_8:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_9:
        li      a0, 1
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_10:
        lbu     a0, -9(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

bf16_mul:
        addi    sp, sp, -48
        sw      ra, 44(sp)
        sw      s0, 40(sp)
        addi    s0, sp, 48
        sh      a0, -12(s0)
        sh      a1, -14(s0)
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
        lh      a0, -16(s0)
        lh      a1, -18(s0)
        xor     a0, a0, a1
        sh      a0, -28(s0)
        lh      a0, -20(s0)
        li      a1, 255
        bne     a0, a1, LBB1_7
        j       LBB1_1
LBB1_1:
        lhu     a0, -24(s0)
        beqz    a0, LBB1_3
        j       LBB1_2
LBB1_2:
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_3:
        lhu     a0, -22(s0)
        bnez    a0, LBB1_6
        j       LBB1_4
LBB1_4:
        lhu     a0, -26(s0)
        bnez    a0, LBB1_6
        j       LBB1_5
LBB1_5:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_6:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_7:
        lh      a0, -22(s0)
        li      a1, 255
        bne     a0, a1, LBB1_14
        j       LBB1_8
LBB1_8:
        lhu     a0, -26(s0)
        beqz    a0, LBB1_10
        j       LBB1_9
LBB1_9:
        lh      a0, -14(s0)
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_10:
        lhu     a0, -20(s0)
        bnez    a0, LBB1_13
        j       LBB1_11
LBB1_11:
        lhu     a0, -24(s0)
        bnez    a0, LBB1_13
        j       LBB1_12
LBB1_12:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_13:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_14:
        lhu     a0, -20(s0)
        bnez    a0, LBB1_16
        j       LBB1_15
LBB1_15:
        lhu     a0, -24(s0)
        beqz    a0, LBB1_18
        j       LBB1_16
LBB1_16:
        lhu     a0, -22(s0)
        bnez    a0, LBB1_19
        j       LBB1_17
LBB1_17:
        lhu     a0, -26(s0)
        bnez    a0, LBB1_19
        j       LBB1_18
LBB1_18:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_19:
        li      a0, 0
        sh      a0, -30(s0)
        lhu     a0, -20(s0)
        bnez    a0, LBB1_24
        j       LBB1_20
LBB1_20:
        j       LBB1_21
LBB1_21:
        lhu     a0, -24(s0)
        andi    a0, a0, 128
        bnez    a0, LBB1_23
        j       LBB1_22
LBB1_22:
        lh      a0, -24(s0)
        slli    a0, a0, 1
        sh      a0, -24(s0)
        lh      a0, -30(s0)
        addi    a0, a0, -1
        sh      a0, -30(s0)
        j       LBB1_21
LBB1_23:
        li      a0, 1
        sh      a0, -20(s0)
        j       LBB1_25
LBB1_24:
        lh      a0, -24(s0)
        ori     a0, a0, 128
        sh      a0, -24(s0)
        j       LBB1_25
LBB1_25:
        lhu     a0, -22(s0)
        bnez    a0, LBB1_30
        j       LBB1_26
LBB1_26:
        j       LBB1_27
LBB1_27:
        lhu     a0, -26(s0)
        andi    a0, a0, 128
        bnez    a0, LBB1_29
        j       LBB1_28
LBB1_28:
        lh      a0, -26(s0)
        slli    a0, a0, 1
        sh      a0, -26(s0)
        lh      a0, -30(s0)
        addi    a0, a0, -1
        sh      a0, -30(s0)
        j       LBB1_27
LBB1_29:
        li      a0, 1
        sh      a0, -22(s0)
        j       LBB1_31
LBB1_30:
        lh      a0, -26(s0)
        ori     a0, a0, 128
        sh      a0, -26(s0)
        j       LBB1_31
LBB1_31:
        lhu     a0, -24(s0)
        lhu     a1, -26(s0)
        call    mul16x16_u32
        sw      a0, -36(s0)
        lh      a0, -20(s0)
        lh      a1, -22(s0)
        add     a0, a0, a1
        lh      a1, -30(s0)
        add     a0, a0, a1
        addi    a0, a0, -127
        sw      a0, -40(s0)
        lbu     a0, -35(s0)
        andi    a0, a0, 128
        beqz    a0, LBB1_33
        j       LBB1_32
LBB1_32:
        lw      a0, -36(s0)
        slli    a0, a0, 17
        srli    a0, a0, 25
        sw      a0, -36(s0)
        lw      a0, -40(s0)
        addi    a0, a0, 1
        sw      a0, -40(s0)
        j       LBB1_34
LBB1_33:
        lw      a0, -36(s0)
        slli    a0, a0, 18
        srli    a0, a0, 25
        sw      a0, -36(s0)
        j       LBB1_34
LBB1_34:
        lw      a0, -40(s0)
        li      a1, 255
        blt     a0, a1, LBB1_36
        j       LBB1_35
LBB1_35:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_36:
        lw      a1, -40(s0)
        li      a0, 0
        blt     a0, a1, LBB1_40
        j       LBB1_37
LBB1_37:
        lw      a1, -40(s0)
        li      a0, -7
        blt     a0, a1, LBB1_39
        j       LBB1_38
LBB1_38:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_39:
        lw      a1, -40(s0)
        li      a0, 1
        sub     a1, a0, a1
        lw      a0, -36(s0)
        srl     a0, a0, a1
        sw      a0, -36(s0)
        li      a0, 0
        sw      a0, -40(s0)
        j       LBB1_40
LBB1_40:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lbu     a1, -40(s0)
        slli    a1, a1, 7
        or      a0, a0, a1
        lw      a1, -36(s0)
        andi    a1, a1, 127
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB1_41
LBB1_41:
        lhu     a0, -10(s0)
        lw      ra, 44(sp)
        lw      s0, 40(sp)
        addi    sp, sp, 48
        ret

bf16_div:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        addi    s0, sp, 64
        sh      a0, -12(s0)
        sh      a1, -14(s0)
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
        lh      a0, -16(s0)
        lh      a1, -18(s0)
        xor     a0, a0, a1
        sh      a0, -28(s0)
        lh      a0, -22(s0)
        li      a1, 255
        bne     a0, a1, LBB2_7
        j       LBB2_1
LBB2_1:
        lhu     a0, -26(s0)
        beqz    a0, LBB2_3
        j       LBB2_2
LBB2_2:
        lh      a0, -14(s0)
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_3:
        lh      a0, -20(s0)
        li      a1, 255
        bne     a0, a1, LBB2_6
        j       LBB2_4
LBB2_4:
        lhu     a0, -24(s0)
        bnez    a0, LBB2_6
        j       LBB2_5
LBB2_5:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_6:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_7:
        lhu     a0, -22(s0)
        bnez    a0, LBB2_13
        j       LBB2_8
LBB2_8:
        lhu     a0, -26(s0)
        bnez    a0, LBB2_13
        j       LBB2_9
LBB2_9:
        lhu     a0, -20(s0)
        bnez    a0, LBB2_12
        j       LBB2_10
LBB2_10:
        lhu     a0, -24(s0)
        bnez    a0, LBB2_12
        j       LBB2_11
LBB2_11:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_12:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_13:
        lh      a0, -20(s0)
        li      a1, 255
        bne     a0, a1, LBB2_17
        j       LBB2_14
LBB2_14:
        lhu     a0, -24(s0)
        beqz    a0, LBB2_16
        j       LBB2_15
LBB2_15:
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_16:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_17:
        lhu     a0, -20(s0)
        bnez    a0, LBB2_20
        j       LBB2_18
LBB2_18:
        lhu     a0, -24(s0)
        bnez    a0, LBB2_20
        j       LBB2_19
LBB2_19:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_20:
        lhu     a0, -20(s0)
        beqz    a0, LBB2_22
        j       LBB2_21
LBB2_21:
        lh      a0, -24(s0)
        ori     a0, a0, 128
        sh      a0, -24(s0)
        j       LBB2_22
LBB2_22:
        lhu     a0, -22(s0)
        beqz    a0, LBB2_24
        j       LBB2_23
LBB2_23:
        lh      a0, -26(s0)
        ori     a0, a0, 128
        sh      a0, -26(s0)
        j       LBB2_24
LBB2_24:
        lhu     a0, -24(s0)
        slli    a0, a0, 15
        sw      a0, -32(s0)
        lhu     a0, -26(s0)
        sw      a0, -36(s0)
        li      a0, 0
        sw      a0, -40(s0)
        sw      a0, -44(s0)
        j       LBB2_25
LBB2_25:
        lw      a1, -44(s0)
        li      a0, 15
        blt     a0, a1, LBB2_30
        j       LBB2_26
LBB2_26:
        lw      a0, -40(s0)
        slli    a0, a0, 1
        sw      a0, -40(s0)
        lw      a0, -32(s0)
        lw      a1, -36(s0)
        lw      a3, -44(s0)
        li      a2, 15
        sub     a2, a2, a3
        sll     a1, a1, a2
        bltu    a0, a1, LBB2_28
        j       LBB2_27
LBB2_27:
        lw      a0, -36(s0)
        lw      a2, -44(s0)
        li      a1, 15
        sub     a1, a1, a2
        sll     a1, a0, a1
        lw      a0, -32(s0)
        sub     a0, a0, a1
        sw      a0, -32(s0)
        lw      a0, -40(s0)
        ori     a0, a0, 1
        sw      a0, -40(s0)
        j       LBB2_28
LBB2_28:
        j       LBB2_29
LBB2_29:
        lw      a0, -44(s0)
        addi    a0, a0, 1
        sw      a0, -44(s0)
        j       LBB2_25
LBB2_30:
        lh      a0, -20(s0)
        lh      a1, -22(s0)
        sub     a0, a0, a1
        addi    a0, a0, 127
        sw      a0, -48(s0)
        lhu     a0, -20(s0)
        bnez    a0, LBB2_32
        j       LBB2_31
LBB2_31:
        lw      a0, -48(s0)
        addi    a0, a0, -1
        sw      a0, -48(s0)
        j       LBB2_32
LBB2_32:
        lhu     a0, -22(s0)
        bnez    a0, LBB2_34
        j       LBB2_33
LBB2_33:
        lw      a0, -48(s0)
        addi    a0, a0, 1
        sw      a0, -48(s0)
        j       LBB2_34
LBB2_34:
        lbu     a0, -39(s0)
        andi    a0, a0, 128
        beqz    a0, LBB2_36
        j       LBB2_35
LBB2_35:
        lw      a0, -40(s0)
        srli    a0, a0, 8
        sw      a0, -40(s0)
        j       LBB2_42
LBB2_36:
        j       LBB2_37
LBB2_37:
        lbu     a0, -39(s0)
        andi    a0, a0, 128
        li      a1, 0
        sw      a1, -52(s0)
        bnez    a0, LBB2_39
        j       LBB2_38
LBB2_38:
        lw      a0, -48(s0)
        slti    a0, a0, 2
        xori    a0, a0, 1
        sw      a0, -52(s0)
        j       LBB2_39
LBB2_39:
        lw      a0, -52(s0)
        andi    a0, a0, 1
        beqz    a0, LBB2_41
        j       LBB2_40
LBB2_40:
        lw      a0, -40(s0)
        slli    a0, a0, 1
        sw      a0, -40(s0)
        lw      a0, -48(s0)
        addi    a0, a0, -1
        sw      a0, -48(s0)
        j       LBB2_37
LBB2_41:
        lw      a0, -40(s0)
        srli    a0, a0, 8
        sw      a0, -40(s0)
        j       LBB2_42
LBB2_42:
        lw      a0, -40(s0)
        andi    a0, a0, 127
        sw      a0, -40(s0)
        lw      a0, -48(s0)
        li      a1, 255
        blt     a0, a1, LBB2_44
        j       LBB2_43
LBB2_43:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lui     a1, 8
        addi    a1, a1, -128
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_44:
        lw      a1, -48(s0)
        li      a0, 0
        blt     a0, a1, LBB2_46
        j       LBB2_45
LBB2_45:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_46:
        lh      a0, -28(s0)
        slli    a0, a0, 15
        lbu     a1, -48(s0)
        slli    a1, a1, 7
        or      a0, a0, a1
        lw      a1, -40(s0)
        andi    a1, a1, 127
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB2_47
LBB2_47:
        lhu     a0, -10(s0)
        lw      ra, 60(sp)
        lw      s0, 56(sp)
        addi    sp, sp, 64
        ret

bf16_sqrt:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        addi    s0, sp, 64
        sh      a0, -12(s0)
        lhu     a0, -12(s0)
        srli    a0, a0, 15
        sh      a0, -14(s0)
        lhu     a0, -12(s0)
        slli    a0, a0, 17
        srli    a0, a0, 24
        sh      a0, -16(s0)
        lhu     a0, -12(s0)
        andi    a0, a0, 127
        sh      a0, -18(s0)
        lh      a0, -16(s0)
        li      a1, 255
        bne     a0, a1, LBB3_6
        j       LBB3_1
LBB3_1:
        lhu     a0, -18(s0)
        beqz    a0, LBB3_3
        j       LBB3_2
LBB3_2:
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_3:
        lhu     a0, -14(s0)
        beqz    a0, LBB3_5
        j       LBB3_4
LBB3_4:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_5:
        lh      a0, -12(s0)
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_6:
        lhu     a0, -16(s0)
        bnez    a0, LBB3_9
        j       LBB3_7
LBB3_7:
        lhu     a0, -18(s0)
        bnez    a0, LBB3_9
        j       LBB3_8
LBB3_8:
        li      a0, 0
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_9:
        lhu     a0, -14(s0)
        beqz    a0, LBB3_11
        j       LBB3_10
LBB3_10:
        lui     a0, 8
        addi    a0, a0, -64
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_11:
        lhu     a0, -16(s0)
        bnez    a0, LBB3_13
        j       LBB3_12
LBB3_12:
        li      a0, 0
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_13:
        lh      a0, -16(s0)
        addi    a0, a0, -127
        sw      a0, -24(s0)
        lhu     a0, -18(s0)
        ori     a0, a0, 128
        sw      a0, -32(s0)
        lbu     a0, -24(s0)
        andi    a0, a0, 1
        beqz    a0, LBB3_15
        j       LBB3_14
LBB3_14:
        lw      a0, -32(s0)
        slli    a0, a0, 1
        sw      a0, -32(s0)
        lw      a0, -24(s0)
        addi    a0, a0, -1
        srai    a0, a0, 1
        addi    a0, a0, 127
        sw      a0, -28(s0)
        j       LBB3_16
LBB3_15:
        lw      a0, -24(s0)
        srai    a0, a0, 1
        addi    a0, a0, 127
        sw      a0, -28(s0)
        j       LBB3_16
LBB3_16:
        li      a0, 90
        sw      a0, -36(s0)
        li      a0, 256
        sw      a0, -40(s0)
        li      a0, 128
        sw      a0, -44(s0)
        j       LBB3_17
LBB3_17:
        lw      a1, -36(s0)
        lw      a0, -40(s0)
        bltu    a0, a1, LBB3_22
        j       LBB3_18
LBB3_18:
        lw      a0, -36(s0)
        lw      a1, -40(s0)
        add     a0, a0, a1
        srli    a0, a0, 1
        sw      a0, -48(s0)
        lhu     a1, -48(s0)
        mv      a0, a1
        call    mul16x16_u32
        srli    a0, a0, 7
        sw      a0, -52(s0)
        lw      a1, -52(s0)
        lw      a0, -32(s0)
        bltu    a0, a1, LBB3_20
        j       LBB3_19
LBB3_19:
        lw      a0, -48(s0)
        sw      a0, -44(s0)
        lw      a0, -48(s0)
        addi    a0, a0, 1
        sw      a0, -36(s0)
        j       LBB3_21
LBB3_20:
        lw      a0, -48(s0)
        addi    a0, a0, -1
        sw      a0, -40(s0)
        j       LBB3_21
LBB3_21:
        j       LBB3_17
LBB3_22:
        lw      a0, -44(s0)
        li      a1, 256
        bltu    a0, a1, LBB3_24
        j       LBB3_23
LBB3_23:
        lw      a0, -44(s0)
        srli    a0, a0, 1
        sw      a0, -44(s0)
        lw      a0, -28(s0)
        addi    a0, a0, 1
        sw      a0, -28(s0)
        j       LBB3_32
LBB3_24:
        lw      a1, -44(s0)
        li      a0, 127
        bltu    a0, a1, LBB3_31
        j       LBB3_25
LBB3_25:
        j       LBB3_26
LBB3_26:
        lw      a1, -44(s0)
        li      a2, 0
        li      a0, 127
        sw      a2, -60(s0)
        bltu    a0, a1, LBB3_28
        j       LBB3_27
LBB3_27:
        lw      a0, -28(s0)
        slti    a0, a0, 2
        xori    a0, a0, 1
        sw      a0, -60(s0)
        j       LBB3_28
LBB3_28:
        lw      a0, -60(s0)
        andi    a0, a0, 1
        beqz    a0, LBB3_30
        j       LBB3_29
LBB3_29:
        lw      a0, -44(s0)
        slli    a0, a0, 1
        sw      a0, -44(s0)
        lw      a0, -28(s0)
        addi    a0, a0, -1
        sw      a0, -28(s0)
        j       LBB3_26
LBB3_30:
        j       LBB3_31
LBB3_31:
        j       LBB3_32
LBB3_32:
        lw      a0, -44(s0)
        andi    a0, a0, 127
        sh      a0, -54(s0)
        lw      a0, -28(s0)
        li      a1, 255
        blt     a0, a1, LBB3_34
        j       LBB3_33
LBB3_33:
        lui     a0, 8
        addi    a0, a0, -128
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_34:
        lw      a1, -28(s0)
        li      a0, 0
        blt     a0, a1, LBB3_36
        j       LBB3_35
LBB3_35:
        li      a0, 0
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_36:
        lbu     a0, -28(s0)
        slli    a0, a0, 7
        lh      a1, -54(s0)
        or      a0, a0, a1
        sh      a0, -10(s0)
        j       LBB3_37
LBB3_37:
        lhu     a0, -10(s0)
        lw      ra, 60(sp)
        lw      s0, 56(sp)
        addi    sp, sp, 64
        ret

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -12(s0)
        call    test_mul_div_sqrt
        beqz    a0, LBB4_2
        j       LBB4_1
LBB4_1:
        li      a0, 0
        sw      a0, -12(s0)
        j       LBB4_3
LBB4_2:
        li      a0, 1
        sw      a0, -12(s0)
        j       LBB4_3
LBB4_3:
        lw      a0, -12(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        j       Exit

mul16x16_u32:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sh      a0, -10(s0)
        sh      a1, -12(s0)
        li      a0, 0
        sw      a0, -16(s0)
        j       LBB5_1
LBB5_1:
        lhu     a0, -12(s0)
        beqz    a0, LBB5_5
        j       LBB5_2
LBB5_2:
        lhu     a0, -12(s0)
        andi    a0, a0, 1
        beqz    a0, LBB5_4
        j       LBB5_3
LBB5_3:
        lhu     a1, -10(s0)
        lw      a0, -16(s0)
        add     a0, a0, a1
        sw      a0, -16(s0)
        j       LBB5_4
LBB5_4:
        lh      a0, -10(s0)
        slli    a0, a0, 1
        sh      a0, -10(s0)
        lhu     a0, -12(s0)
        srli    a0, a0, 1
        sh      a0, -12(s0)
        j       LBB5_1
LBB5_5:
        lw      a0, -16(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

Exit:
        li      a7,10
        ecall