.text
start:
        j      main
uf8_decode:
# Register roles:
#   a0  = argument fl on entry; return value on exit
#   a4  = temporary (builds 0x7FFF and holds (mantissa<<exponent))
#   a5  = temporary (holds fl, exponent, intermediate math, final sum)
#   s0  = frame pointer (FP)
#   ra  = return address
#
# Stack frame (relative to s0):
#   -33(s0) : byte  fl
#   -21(s0) : byte  exponent
#   -20(s0) : word  mantissa
#   -28(s0) : word  offset

        addi    sp,sp,-48          # prologue: allocate 48B frame
        sw      ra,44(sp)          # save ra
        sw      s0,40(sp)          # save s0
        addi    s0,sp,48           # s0 = sp + 48 (set FP)

        mv      a5,a0              # a5 = fl (from a0)
        sb      a5,-33(s0)         # store fl (byte)

        lbu     a5,-33(s0)         # a5 = fl
        andi    a5,a5,15           # a5 = fl & 0x0f
        sw      a5,-20(s0)         # mantissa = a5

        lbu     a5,-33(s0)         # a5 = fl
        srli    a5,a5,4            # a5 = fl >> 4
        sb      a5,-21(s0)         # exponent = a5 (byte)

        # offset = (0x7FFF >> (15 - exponent)) << 4
        lbu     a5,-21(s0)         # a5 = exponent
        li      a4,15              # a4 = 15
        sub     a5,a4,a5           # a5 = 15 - exponent
        li      a4,32768           # a4 = 0x8000
        addi    a4,a4,-1           # a4 = 0x7FFF
        sra     a5,a4,a5           # a5 = 0x7FFF >> (15 - exponent)
        slli    a5,a5,4            # a5 = a5 << 4
        sw      a5,-28(s0)         # offset = a5

        # return (mantissa << exponent) + offset
        lbu     a5,-21(s0)         # a5 = exponent
        lw      a4,-20(s0)         # a4 = mantissa
        sll     a4,a4,a5           # a4 = mantissa << exponent
        lw      a5,-28(s0)         # a5 = offset
        add     a5,a4,a5           # a5 = (mantissa<<exponent) + offset
        mv      a0,a5              # return value in a0

        # epilogue
        lw      ra,44(sp)          # restore ra
        lw      s0,40(sp)          # restore s0
        addi    sp,sp,48           # free frame
        jr      ra                 # return
test_uf8_decode_0x53:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,83
        sb      a5,-17(s0)
        li      a5,592
        sw      a5,-24(s0)
        lbu     a5,-17(s0)
        mv      a0,a5
        call    uf8_decode
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L4
        li      a5,0
        j       L5
L4:
        li      a5,1
L5:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_uf8_decode_0x0F:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,15
        sb      a5,-17(s0)
        li      a5,15
        sw      a5,-24(s0)
        lbu     a5,-17(s0)
        mv      a0,a5
        call    uf8_decode
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L7
        li      a5,0
        j       L8
L7:
        li      a5,1
L8:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_uf8_decode_0xff:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,-1
        sb      a5,-17(s0)
        li      a5,1015808
        addi    a5,a5,-16
        sw      a5,-24(s0)
        lbu     a5,-17(s0)
        mv      a0,a5
        call    uf8_decode
        sw      a0,-28(s0)
        lw      a4,-28(s0)
        lw      a5,-24(s0)
        beq     a4,a5,L10
        li      a5,0
        j       L11
L10:
        li      a5,1
L11:
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
        call    test_uf8_decode_0x53
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_uf8_decode_0x0F
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_uf8_decode_0xff
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        lbu     a5,-17(s0)
        beq     a5,zero,L13
        li      a5,0
        j       L14
L13:
        li      a5,1
L14:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        j       Exit
Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall
        