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

Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall