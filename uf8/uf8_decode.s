.text
start:
        j       main

uf8_decode:
# Register role:
# a0 = input argument fl on entry; return value on exit
# s0 = frame pointer (FP)
# ra = return address
# t0 = mantissa (holds fl & 0x0f)
# t1 = exponent (holds fl >> 4)
# t2 = offset (holds (0x7FFF >> (15 - exponent)) << 4)
# t3 = 0x7FFF (constant)
#
# Stack frame (relative to s0):
# -48(s0) : reserved ra (save area)
# -44(s0) : reserved s0 (save area)
        addi    sp,sp,-8          # prologue: allocate 8B frame
        sw      ra,4(sp)          # save ra
        sw      s0,0(sp)          # save s0
        addi    s0,sp,8           # s0 = sp + 8 (set FP)

        andi    t0,a0,15           # mantissa = fl & 0x0f
        srli    t1,a0,4            # exponent = fl >> 4

        li      t2,15              # t2 = 15
        sub     t2,t2,t1           # t2 = 15 - exponent
        li      t3,32768           # t3 = 0x8000
        addi    t3,t3,-1           # t3 = 0x7FFF
        srl     t2,t3,t2           # t2 = 0x7FFF >> (15 - exponent)
        slli    t2,t2,4            # offset = t2 = t2 << 4

        sll     a0,t0,t1           # a0 = mantissa << exponent
        add     a0,a0,t2           # return (mantissa << exponent) + offset

        lw      ra,4(sp)          # epilogue
        lw      s0,0(sp)          # restore s0
        addi    sp,sp,8           # free frame
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
        