.text
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
        
        # restore callee-saved registers
        lw      ra,4(sp)
        lw      s0,0(sp)
        addi    sp,sp,8
        jr      ra
uf8_encode:

# Register roles:
#   a0  = arg value on entry; return uf8 on exit
#   a4  = temporary (ALU, comparisons, shifted intermediates)
#   a5  = primary temporary (loop vars, intermediates, final byte)
#   s0  = frame pointer (FP)
#   ra  = return address
#-------------------------------------------------------------------
# Stack frame (relative to s0):
#   -52(s0) : uint32_t value
#   -32(s0) : int lz
#   -36(s0) : int msb
#   -24(s0) : uint32_t overflow
#   -17(s0) : uint8_t exponent
#   -25(s0) : uint8_t e (loop counter for initial overflow build)
#   -40(s0) : uint32_t next_overflow
#   -41(s0) : uint8_t mantissa

# Initialize stack frame
        addi    sp,sp,-64          # prologue: allocate 64B
        sw      ra,60(sp)          # save ra
        sw      s0,56(sp)          # save s0
        addi    s0,sp,64           # set FP
        sw      a0,-52(s0)         # store input value

# Quick return for value <= 15
        lw      a4,-52(s0)         # a4 = value
        li      a5,15              # a5 = 15
        bgtu    a4,a5,L6           # if (value > 15) goto L6
        lw      a5,-52(s0)         # a5 = value
        andi    a5,a5,0xff         # zero-extend to byte
        j       L7                 # return value

# value >= 16 path
L6:
        lw      a0,-52(s0)         # a0 = value
        call    clz                # a0 = clz(value)
        mv      a5,a0              # a5 = lz
        sw      a5,-32(s0)         # lz = a5

        li      a4,31              # a4 = 31
        lw      a5,-32(s0)         # a5 = lz
        sub     a5,a4,a5           # a5 = 31 - lz
        sw      a5,-36(s0)         # msb = a5

        sb      zero,-17(s0)       # exponent = 0
        sw      zero,-24(s0)       # overflow = 0

        lw      a4,-36(s0)         # a4 = msb
        li      a5,4               # a5 = 4
        ble     a4,a5,L14          # if (msb <= 4) skip estimate block

        # exponent = msb - 4; if (exponent > 15) exponent = 15;
        lw      a5,-36(s0)         # a5 = msb
        andi    a5,a5,0xff         # keep low byte
        addi    a5,a5,-4           # a5 = msb - 4
        sb      a5,-17(s0)         # exponent = a5
        lbu     a4,-17(s0)         # a4 = exponent
        li      a5,15              # a5 = 15
        bleu    a4,a5,L9           # if (exponent <= 15) ok
        li      a5,15              # a5 = 15
        sb      a5,-17(s0)         # exponent = 15
L9:
        sb      zero,-25(s0)       # e = 0 (byte)

        # for (e=0; e<exponent; e++) overflow = (overflow<<1)+16;
        j       L10
L11:
        lw      a5,-24(s0)         # a5 = overflow
        slli    a5,a5,1            # a5 = overflow << 1
        addi    a5,a5,16           # a5 += 16
        sw      a5,-24(s0)         # overflow = a5
        lbu     a5,-25(s0)         # a5 = e
        addi    a5,a5,1            # e++
        sb      a5,-25(s0)         # store e
L10:
        lbu     a4,-25(s0)         # a4 = e
        lbu     a5,-17(s0)         # a5 = exponent
        bltu    a4,a5,L11          # loop while e < exponent

        # while (exponent > 0 && value < overflow) { overflow = (overflow-16)>>1; exponent--; }
        j       L12
L13:
        lw      a5,-24(s0)         # a5 = overflow
        addi    a5,a5,-16          # a5 = overflow - 16
        srli    a5,a5,1            # a5 = (overflow - 16) >> 1
        sw      a5,-24(s0)         # overflow = a5
        lbu     a5,-17(s0)         # a5 = exponent
        addi    a5,a5,-1           # exponent--
        sb      a5,-17(s0)         # store exponent
L12:
        lbu     a5,-17(s0)         # a5 = exponent
        beq     a5,zero,L14        # if (exponent == 0) stop
        lw      a4,-52(s0)         # a4 = value
        lw      a5,-24(s0)         # a5 = overflow
        bltu    a4,a5,L13          # if (value < overflow) adjust down
        j       L14

        # while (exponent < 15) { next_overflow=(overflow<<1)+16; if (value < next_overflow) break; overflow=next_overflow; exponent++; }
L17:
        lw      a5,-24(s0)         # a5 = overflow
        slli    a5,a5,1            # a5 = overflow << 1
        addi    a5,a5,16           # a5 += 16
        sw      a5,-40(s0)         # next_overflow = a5

        lw      a4,-52(s0)         # a4 = value
        lw      a5,-40(s0)         # a5 = next_overflow
        bltu    a4,a5,L18          # if (value < next_overflow) break
        lw      a5,-40(s0)         # a5 = next_overflow
        sw      a5,-24(s0)         # overflow = next_overflow
        lbu     a5,-17(s0)         # a5 = exponent
        addi    a5,a5,1            # exponent++
        sb      a5,-17(s0)         # store exponent
L14:
        lbu     a4,-17(s0)         # a4 = exponent
        li      a5,14              # a5 = 14
        bleu    a4,a5,L17          # loop while exponent <= 14  (i.e., < 15)
        j       L16
L18:
        nop                        # break

# mantissa = (value - overflow) >> exponent; return (exponent<<4)|mantissa;
L16:
        lw      a4,-52(s0)         # a4 = value
        lw      a5,-24(s0)         # a5 = overflow
        sub     a4,a4,a5           # a4 = value - overflow
        lbu     a5,-17(s0)         # a5 = exponent
        srl     a5,a4,a5           # a5 = (value - overflow) >> exponent
        sb      a5,-41(s0)         # mantissa = a5 (byte)

        lb      a5,-17(s0)         # a5 = sign-extended exponent byte
        slli    a5,a5,4            # a5 = exponent << 4
        slli    a4,a5,24           # pack to 32 then
        srai    a4,a4,24           # sign-correct to low byte
        lb      a5,-41(s0)         # a5 = mantissa (sign-extended byte)
        or      a5,a4,a5           # a5 = (exponent<<4) | mantissa
        slli    a5,a5,24           # zero-extend to 8-bit in 32-bit reg
        srai    a5,a5,24
        andi    a5,a5,0xff         # ensure 8-bit result

L7:
        mv      a0,a5              # return in a0

        lw      ra,60(sp)          # epilogue: restore ra
        lw      s0,56(sp)          # restore s0
        addi    sp,sp,64           # free frame
        jr      ra                 # return

test_uf8_encode_0xA:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,10
        sw      a5,-20(s0)
        li      a5,10
        sb      a5,-21(s0)
        lw      a0,-20(s0)
        call    uf8_encode
        mv      a5,a0
        sb      a5,-22(s0)
        lbu     a4,-22(s0)
        lbu     a5,-21(s0)
        beq     a4,a5,L20
        li      a5,0
        j       L21
L20:
        li      a5,1
L21:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_uf8_encode_0x1A:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,26
        sw      a5,-20(s0)
        li      a5,21
        sb      a5,-21(s0)
        lw      a0,-20(s0)
        call    uf8_encode
        mv      a5,a0
        sb      a5,-22(s0)
        lbu     a4,-22(s0)
        lbu     a5,-21(s0)
        beq     a4,a5,L23
        li      a5,0
        j       L24
L23:
        li      a5,1
L24:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
test_uf8_encode_0xfffff:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        li      a5,1015808
        addi    a5,a5,-16
        sw      a5,-20(s0)
        li      a5,-1
        sb      a5,-21(s0)
        lw      a0,-20(s0)
        call    uf8_encode
        mv      a5,a0
        sb      a5,-22(s0)
        lbu     a4,-22(s0)
        lbu     a5,-21(s0)
        beq     a4,a5,L26
        li      a5,0
        j       L27
L26:
        li      a5,1
L27:
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
        call    test_uf8_encode_0xA
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_uf8_encode_0x1A
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        call    test_uf8_encode_0xfffff
        mv      a5,a0
        mv      a4,a5
        lbu     a5,-17(s0)
        and     a5,a5,a4
        snez    a5,a5
        sb      a5,-17(s0)
        lbu     a5,-17(s0)
        beq     a5,zero,L29
        li      a5,0
        j       L30
L29:
        li      a5,1
L30:
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        j       Exit                 # jump to Exit
Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall