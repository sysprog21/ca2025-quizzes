.text
start:
        j       main
clz:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        sw      a0,-36(s0)
        li      a5,32
        sw      a5,-20(s0)
        li      a5,16
        sw      a5,-24(s0)
L3:
        lw      a5,-24(s0)
        lw      a4,-36(s0)
        srl     a5,a4,a5
        sw      a5,-28(s0)
        lw      a5,-28(s0)
        beq     a5,zero,L2
        lw      a4,-20(s0)
        lw      a5,-24(s0)
        sub     a5,a4,a5
        sw      a5,-20(s0)
        lw      a5,-28(s0)
        sw      a5,-36(s0)
L2:
        lw      a5,-24(s0)
        srai    a5,a5,1
        sw      a5,-24(s0)
        lw      a5,-24(s0)
        bne     a5,zero,L3
        lw      a4,-20(s0)
        lw      a5,-36(s0)
        sub     a5,a4,a5
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra
test_clz_0x1:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,1
        sw      a5,-20(s0)
        li      a5,31
        sw      a5,-24(s0)
        lw      a0,-20(s0)
        call    clz
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L6
        li      a5,0
        j       L7
L6:
        li      a5,1
L7:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_clz_0x80:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,128
        sw      a5,-20(s0)
        li      a5,24
        sw      a5,-24(s0)
        lw      a0,-20(s0)
        call    clz
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L9
        li      a5,0
        j       L10
L9:
        li      a5,1
L10:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_clz_0x0:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      zero,-20(s0)
        li      a5,32
        sw      a5,-24(s0)
        lw      a0,-20(s0)
        call    clz
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L12
        li      a5,0
        j       L13
L12:
        li      a5,1
L13:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,1
        sb      a5,-17(s0)
        call    test_clz_0x1
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_clz_0x80
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_clz_0x0
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        lbu     a5,-17(s0)
        beq     a5,zero,L15
        li      a5,0
        j       L16
L15:
        li      a5,1
L16:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        j       Exit
Exit:
        li      a7,10
        ecall