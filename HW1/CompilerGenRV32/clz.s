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
        j       Exit                 # or: jal zero, Exit

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

Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall

