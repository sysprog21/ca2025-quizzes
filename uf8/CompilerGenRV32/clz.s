.data
msg1: .string "Leading Zero of "
msg2: .string " = "
msg3: .string " .\n"

.text
.globl main

main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,128              # input x
        sw      a5,-20(s0)
        li      a0,128               # input x
        call    clz
        mv      a2,a0                # clz result
        
        # print "Leading Zero of "
        la   a0, msg1
        li   a7, 4
        ecall
        # print x
        lw   a0, -20(s0)
        li   a7, 1
        ecall
        
        # print " = "
        la   a0, msg2
        li   a7, 4
        ecall
        
        # print clz(x)
        mv   a0, a2
        li   a7, 1
        ecall
        
        # print " .\n"
        la   a0, msg3
        li   a7, 4
        ecall

        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        j       Exit                # program termination

clz:
# a0 -> function arg x on entry; return value on exit.
# ra -> return address (saved to stack).
# s0 -> frame pointer.
# a4, a5 -> temporaries.
# Stack frame (at s0):
# -36(s0) -> x (current working value).
# -20(s0) -> n.
# -24(s0) -> c.
# -28(s0) -> y (temporary).

        addi    sp,sp,-48          # prologue: make 48B stack frame
        sw      ra,44(sp)          # save ra
        sw      s0,40(sp)          # save s0
        addi    s0,sp,48           # s0 = frame pointer
        sw      a0,-36(s0)         # x = arg

        li      a5,32
        sw      a5,-20(s0)         # n = 32
        li      a5,16
        sw      a5,-24(s0)         # c = 16

# do { ... } while (c);
L3:
        lw      a5,-24(s0)         # a5 = c
        lw      a4,-36(s0)         # a4 = x
        srl     a5,a4,a5           # a5 = x >> c
        sw      a5,-28(s0)         # y = x >> c

        lw      a5,-28(s0)         # if (y)
        beq     a5,zero,L2         #   skip if y == 0

        lw      a4,-20(s0)         # n -= c;
        lw      a5,-24(s0)
        sub     a5,a4,a5
        sw      a5,-20(s0)

        lw      a5,-28(s0)         # x = y;
        sw      a5,-36(s0)

L2:
        lw      a5,-24(s0)         # c >>= 1;
        srai    a5,a5,1
        sw      a5,-24(s0)

        lw      a5,-24(s0)         # while (c) loop back
        bne     a5,zero,L3

        lw      a4,-20(s0)         # return n - x;
        lw      a5,-36(s0)
        sub     a5,a4,a5
        mv      a0,a5              # a0 = result

        lw      ra,44(sp)          # epilogue
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra


Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall

