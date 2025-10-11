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
# register roles:
#   a0 : uint32_t value (input)
#   s0 : frame pointer
#   t0 : input value copy
#   t1 : msb (most significant bit position)
#   t2 : exponent
#   t3 : overflow (offset for current exponent)
#   t4 : e (temporary for exponent calculation)
#   t5 : next_overflow (offset for next exponent)
#   t6 : mantissa
#   a1 : temporary constant
# stack frame (from s0, growing down):
#   -4(s0)  : ra
#   -8(s0)  : saved s0
#   -12(s0) : uint32_t value (spill)

#   initialize stack frame
        addi    sp,sp,-12
        sw      ra,8(sp)
        sw      s0,4(sp)
        addi    s0,sp,12

#   quick return for value <= 15
        addi    a1,zero,15        # a1 = 15
        bgtu    a0,a1,init_exponent_guess  # if (value <= 15) return value
        j       uf8_encode_return
init_exponent_guess:
#   initialize variables for exponent guessing loop
        sw      a0,0(sp)               # save value across call
        call    clz                    # call clz(value)
        li      t1,31                  # t1 = msb = 31
        lw      t0,0(sp)               # t0 = value
        sub     t1,t1,a0               # msb = 31 - clz(value)

        li      t2,0                    # t2 = exponent = 0
        li      t3,0                    # t3 = overflow = 0

#   Estimate exponent
        addi    a1,x0,4                  # a1 = 4
        ble     t1,a1,find_exact_exponent   # if (msb <= 4) goto find_exact_exponent
        addi    t2,t1,-4                   # exponent = msb - 4
#   Handle exponent overflow
        addi    a1,x0,15                    # a1 = 15
        bleu    t2,a1,estimate_exponent_and_overflow    # if (exponent <= 15) goto estimate_exponent
        addi    t2,x0,15                    # exponent = 15

estimate_exponent_and_overflow:
#   Calculate overflow for current exponent
        addi    t4,x0,0                   # t4 = e = 0

        j       Loop_condition_1

Loop_1:
        slli    t3,t3,1                   # overflow <<= 1
        addi    t3,t3,16                  # overflow += 16
        addi    t4,t4,1                   # e += 1

Loop_condition_1:
        bltu    t4,t2,Loop_1
        
adjust_e_o:
#   adjust exponent and overflow
        beq     t2,x0,find_exact_exponent   # if (exponent == 0) goto find_exact_exponent
        bge     t0,t3,find_exact_exponent   # if (value >= overflow) go to estimating
        addi    t3,t3,-16                 # overflow -= 16
        srli    t3,t3,1                   # overflow >>= 1
        addi    t2,t2,-1                  # exponent -= 1
        j       adjust_e_o

find_exact_exponent:
#   Find exact exponent
        addi    a1,x0,14                   # a1 = 14
        bgtu    t2,a1,finalize            # if (exponent > 14) goto finalize
        slli    t5,t3,1                   # next_overflow = overflow << 1
        addi    t5,t5,16                  # next_overflow += 16
        bltu    t0,t5,finalize            # if (value < next_overflow) goto finalize
        addi    t3,t5,0                   # overflow = next_overflow
        addi    t2,t2,1                   # exponent += 1

        j       find_exact_exponent
finalize:
#   Calculate mantissa
        sub    t6,t0,t3          # mantissa = value - overflow
        srl    t6,t6,t2          # mantissa >>= exponent
        andi   t6,t6,15          # mantissa &= 0x0f
#   Combine exponent and mantissa
        slli   t2,t2,4           # exponent <<= 4
        slli   t2,t2,24
        srai   t2,t2,24
        or     a0,t2,t6          # return (exponent << 4) | mantissa
        slli   a0,a0,24
        srai   a0,a0,24

uf8_encode_return:
        lw      ra,8(sp)          # epilogue: restore ra
        lw      s0,4(sp)          # restore s0
        addi    sp,sp,12           # free frame
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