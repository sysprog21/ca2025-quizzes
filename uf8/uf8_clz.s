.text
.globl main

start:
        j       main
clz:
# a0 -> function arg x on entry; return value on exit.
# ra -> return address (saved to stack).
# s0 -> frame pointer.
# t0 -> x (current working value).
# t1 -> n.
# t2 -> c.
# t3 -> y (temporary, store x >> c).

# initialize stack frame
        addi    sp,sp,-8          # prologue: make 48B stack frame
        sw      ra,4(sp)          # save ra
        sw      s0,0(sp)          # save s0
        addi    s0,sp,8           # s0 = frame pointer

        add     t0,x0,a0,         # x = arg
        addi    t1,x0,32          # n = 32
        addi    t2,x0,16          # c = 16

# do { ... } while (c);
WHILE_LOOP:
        srl     t3,t0,t2          # y = x >> c
        beq     t3,x0,SKIP        # if (y) skip if
        sub     t1,t1,t2          # n -= c;
        add     t0,x0,t3          # x = y;
SKIP:
        srai    t2,t2,1           # c >>= 1;
        bne     t2,x0,WHILE_LOOP  # while (c) loop
        sub     a0,t1,t0          # return n - x;
        lw      ra,4(sp)          # epilogue
        lw      s0,0(sp)
        addi    sp,sp,8
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