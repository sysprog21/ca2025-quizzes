.data
msg_mis: .string "mismatch: fl="
msg_val: .string ", val="
msg_enc: .string ", enc="
msg_le:  .string "non-increasing: fl="
okmsg:   .string "All tests passed."

.text
start:
        j      main
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
        
test:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        li      a5,-1
        sw      a5,-20(s0)
        li      a5,1
        sb      a5,-21(s0)
        sw      zero,-28(s0)
        j       L22
L25:
        lw      a5,-28(s0)
        sb      a5,-29(s0)
        lbu     a5,-29(s0)
        mv      a0,a5
        call    uf8_decode
        mv      a5,a0
        sw      a5,-36(s0)
        lw      a5,-36(s0)
        mv      a0,a5
        call    uf8_encode
        mv      a5,a0
        sb      a5,-37(s0)
        lbu     a4,-29(s0)
        lbu     a5,-37(s0)
        beq     a4,a5,L23
        lbu     a5,-29(s0)
        lbu     a4,-37(s0)
        mv      a3,a4
        lw      a2,-36(s0)
        mv      a1,a5
        
        la   a0, msg_mis      #; a0 = "mismatch: fl="
        li   a7, 4
        ecall

        mv   a0, a1           #; fl (original byte)
        li   a7, 1            #; print integer
        ecall

        la   a0, msg_val
        li   a7, 4
        ecall

        mv   a0, a2           #; decoded value
        li   a7, 1
        ecall

        la   a0, msg_enc
        li   a7, 4
        ecall

        mv   a0, a3           #; re-encoded byte
        li   a7, 1
        ecall

        li   a0, 10           #; newline
        li   a7, 11
        ecall
        
        sb      zero,-21(s0)
L23:
        lw      a4,-36(s0)
        lw      a5,-20(s0)
        bgt     a4,a5,L24
        lbu     a5,-29(s0)
        lw      a3,-20(s0)
        lw      a2,-36(s0)
        mv      a1,a5
        
        la   a0, msg_le
        li   a7, 4
        ecall

        mv   a0, a1           #; fl
        li   a7, 1
        ecall

        la   a0, msg_val
        li   a7, 4
        ecall

        mv   a0, a2           #; value
        li   a7, 1
        ecall

        la   a0, msg_enc      #; reuse label; reads as ", enc=" (or make a ", prev=" string)
        li   a7, 4
        ecall

        mv   a0, a3           #; previous_value
        li   a7, 1
        ecall    

        li   a0, 10
        li   a7, 11
        ecall
        
        sb      zero,-21(s0)
L24:
        lw      a5,-36(s0)
        sw      a5,-20(s0)
        lw      a5,-28(s0)
        addi    a5,a5,1
        sw      a5,-28(s0)
L22:
        lw      a4,-28(s0)
        li      a5,255
        ble     a4,a5,L25
        lbu     a5,-21(s0)
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16
        call    test
        mv      a5,a0
        beq     a5,zero,L28

        la   a0, okmsg
        li   a7, 4
        ecall

        li   a0, 10
        li   a7, 11
        ecall
        
        li      a5,0
        j       L29
L28:
        li      a5,1
L29:
        mv      a0,a5
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        j       Exit
Exit:
        li   a7, 10                  # exit syscall in Ripes
        ecall
        
        
