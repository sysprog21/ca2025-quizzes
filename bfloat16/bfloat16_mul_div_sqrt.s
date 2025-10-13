.text
start:
        j       main
test_mul_div_sqrt:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        lui     a0, 4
        sw      a0, -28(s0)
        addi    a1, a0, 288
        sh      a1, -12(s0)
        sh      a0, -14(s0)
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_mul
        lw      a1, -28(s0)
        sh      a0, -16(s0)
        lhu     a0, -16(s0)
        addi    a1, a1, 416
        blt     a0, a1, LBB0_2
        j       LBB0_1
LBB0_1:
        lhu     a0, -16(s0)
        lui     a1, 4
        addi    a1, a1, 418
        blt     a0, a1, LBB0_3
        j       LBB0_2
LBB0_2:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_3:
        lhu     a0, -12(s0)
        lhu     a1, -14(s0)
        call    bf16_div
        sh      a0, -18(s0)
        lhu     a0, -18(s0)
        lui     a1, 4
        addi    a1, a1, 160
        blt     a0, a1, LBB0_5
        j       LBB0_4
LBB0_4:
        lhu     a0, -18(s0)
        lui     a1, 4
        addi    a1, a1, 162
        blt     a0, a1, LBB0_6
        j       LBB0_5
LBB0_5:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_6:
        lui     a0, 4
        sw      a0, -32(s0)
        addi    a0, a0, 128
        sh      a0, -20(s0)
        lhu     a0, -20(s0)
        call    bf16_sqrt
        lw      a1, -32(s0)
        sh      a0, -22(s0)
        lhu     a0, -22(s0)
        blt     a0, a1, LBB0_8
        j       LBB0_7
LBB0_7:
        lhu     a0, -22(s0)
        lui     a1, 4
        addi    a1, a1, 1
        blt     a0, a1, LBB0_9
        j       LBB0_8
LBB0_8:
        li      a0, 0
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_9:
        li      a0, 1
        sb      a0, -9(s0)
        j       LBB0_10
LBB0_10:
        lbu     a0, -9(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

# ABI: a0=a.bits (u16), a1=b.bits (u16) -> a0=result bits (u16)
bf16_mul:
        mv      a6, a0                      # save originals
        mv      a7, a1

        srli    t0, a0, 15                  # sign_a
        andi    t0, t0, 1
        srli    t2, a0, 7                   # exp_a
        andi    t2, t2, 255
        andi    t4, a0, 127                 # mant_a

        srli    t1, a1, 15                  # sign_b
        andi    t1, t1, 1
        srli    t3, a1, 7                   # exp_b
        andi    t3, t3, 255
        andi    t5, a1, 127                 # mant_b

        xor     t0, t0, t1                  # result_sign

# ---- handle a is Inf/NaN ----
        li      t6, 255
        bne     t2, t6, check_b_inf_nan
        bnez    t4, return_a_original       # a is NaN -> return a
        or      t6, t3, t5                  # b == 0 ?
        beqz    t6, return_nan              # Inf * 0 -> NaN
        j       return_inf                  # signed Inf

check_b_inf_nan:
        li      t6, 255
        bne     t3, t6, zero_shortcut
        bnez    t5, return_b_original       # b is NaN -> return b
        or      t6, t2, t4                  # a == 0 ?
        beqz    t6, return_nan              # 0 * Inf -> NaN
        j       return_inf                  # signed Inf

# ---- zero shortcut ----
zero_shortcut:
        or      t6, t2, t4
        beqz    t6, return_signed_zero      # a == 0
        or      t6, t3, t5
        beqz    t6, return_signed_zero      # b == 0

# ---- normalize denormals ----
        mv      a2, x0                      # exp_adjust = 0

# A side
        beqz    t2, norm_a_loop_entry
        ori     t4, t4, 128                 # mant_a |= 0x80
        j       after_norm_a
norm_a_loop_entry:
norm_a_loop:
        andi    t6, t4, 128
        bnez    t6, norm_a_done
        slli    t4, t4, 1
        addi    a2, a2, -1
        j       norm_a_loop
norm_a_done:
        li      t2, 1
after_norm_a:

# B side
        beqz    t3, norm_b_loop_entry
        ori     t5, t5, 128                 # mant_b |= 0x80
        j       after_norm_b
norm_b_loop_entry:
norm_b_loop:
        andi    t6, t5, 128
        bnez    t6, norm_b_done
        slli    t5, t5, 1
        addi    a2, a2, -1
        j       norm_b_loop
norm_b_done:
        li      t3, 1
after_norm_b:

# ---- mantissa multiply ----
        mv      a0, t4
        mv      a1, t5
        call    mul16x16_u32               # a0 = result_mant (u32)
        mv      a4, a0

# ---- exponent compute ----
        add     a3, t2, t3
        add     a3, a3, a2
        addi    a3, a3, -127               # result_exp

# ---- normalize product ----
        srli    a5, a4, 15
        andi    a5, a5, 1
        beqz    a5, no_carry
        srli    a4, a4, 8                  # (result_mant >> 8) & 0x7F
        andi    a4, a4, 127
        addi    a3, a3, 1
        j       after_norm
no_carry:
        srli    a4, a4, 7                  # (result_mant >> 7) & 0x7F
        andi    a4, a4, 127
after_norm:

# ---- overflow / underflow ----
        li      a5, 255
        blt     a3, a5, check_underflow    # if result_exp < 255 -> continue
        j       return_inf                  # overflow -> Inf

check_underflow:
        blt     x0, a3, pack_and_return    # if result_exp > 0 -> normal
        li      a5, -6
        blt     a3, a5, return_signed_zero # if result_exp < -6 -> zero
        li      a5, 1
        sub     a5, a5, a3                  # shift = 1 - result_exp
        srl     a4, a4, a5                  # denorm mant
        li      a3, 0

# ---- pack result ----
pack_and_return:
        slli    a0, t0, 15
        andi    a5, a3, 255
        slli    a5, a5, 7
        or      a0, a0, a5
        andi    a4, a4, 127
        or      a0, a0, a4
        ret

# ---- small return helpers ----
return_signed_zero:
        slli    a0, t0, 15
        ret

return_inf:
        slli    a0, t0, 15
        lui     a5, 8                      # 0x7F80
        addi    a5, a5, -128
        or      a0, a0, a5
        ret

return_nan:
        lui     a0, 8                      # 0x7FC0
        addi    a0, a0, -64
        ret

return_a_original:
        slli    a0, a6, 16                 # zext16(a)
        srli    a0, a0, 16
        ret

return_b_original:
        slli    a0, a7, 16                 # zext16(b)
        srli    a0, a0, 16
        ret


# bf16_div
# ABI: a0=input a.bits (u16), a1=input b.bits (u16), a0=return bits (u16)

bf16_div:
    # Extract a fields
    srli   t0,a0,15          # sign_a
    andi   t0,t0,1
    srli   t2,a0,7           # exp_a
    andi   t2,t2,255
    andi   t4,a0,127         # mant_a

    # Extract b fields
    srli   t1,a1,15          # sign_b
    andi   t1,t1,1
    srli   t3,a1,7           # exp_b
    andi   t3,t3,255
    andi   t5,a1,127         # mant_b

    xor    t6,t0,t1          # result_sign (0/1)

    # if b is Inf or NaN
    li     a3,255
    beq    t3,a3, check_b_is_inf_or_nan

    # if b == 0
    or     a3,t3,t5
    beqz   a3, handle_b_zero

    # if a is Inf or NaN
    li     a3,255
    beq    t2,a3, handle_a_inf_or_nan

    # if a == 0 -> signed zero
    or     a3,t2,t4
    beqz   a3, return_signed_zero

    # Normalize mantissas (add hidden 1 for normals)
    beqz   t2, skip_set_a_hidden
    ori    t4,t4,0x80
skip_set_a_hidden:
    beqz   t3, skip_set_b_hidden
    ori    t5,t5,0x80
skip_set_b_hidden:

    # Restoring division: quotient = ((mant_a<<15) / mant_b)
    slli   a3,t4,15          # dividend
    slli   a4,t5,15          # divisor_shifted
    li     a5,0              # quotient
    li     a2,16             # 16 bits

div_loop:
    slli   a5,a5,1
    bgtu   a4,a3, no_subtract
    sub    a3,a3,a4
    ori    a5,a5,1
no_subtract:
    srli   a4,a4,1
    addi   a2,a2,-1
    bnez   a2, div_loop

    # result_exp = exp_a - exp_b + 127 (+denorm adjust)
    sub    t1,t2,t3
    addi   t1,t1,127
    beqz   t2, exp_dec_for_denorm_a
    j      exp_after_a
exp_dec_for_denorm_a:
    addi   t1,t1,-1
exp_after_a:
    beqz   t3, exp_inc_for_denorm_b
    j      exp_done
exp_inc_for_denorm_b:
    addi   t1,t1,1
exp_done:

    # Normalize quotient to have bit15 set, then shift to 7-bit mantissa
    li     t0,0x8000
    and    t2,a5,t0
    bnez   t2, shift_right_8

norm_loop:
    and    t2,a5,t0
    bnez   t2, shift_right_8
    li     t3,2
    blt    t1,t3, shift_right_8
    slli   a5,a5,1
    addi   t1,t1,-1
    j      norm_loop

shift_right_8:
    srli   a5,a5,8
    andi   a5,a5,127

    # Overflow -> Inf with sign
    li     t2,255
    bge    t1,t2, return_signed_inf

    # Underflow (exp <= 0) -> signed zero
    slti   t2,t1,1
    bnez   t2, return_signed_zero

    # Assemble result
    slli   t1,t1,7           # exp field
    slli   t6,t6,15          # sign bit
    or     a0,t6,t1
    or     a0,a0,a5
    ret

# --- Special cases ---

check_b_is_inf_or_nan:         # exp_b == 0xFF
    bnez   t5, return_b        # NaN: return b
    li     a3,255
    bne    t2,a3, return_signed_zero       # a not Inf => 0 with sign
    beqz   t4, return_nan                   # a==Inf => NaN
    j      return_signed_zero               # a is NaN => 0 with sign

handle_b_zero:                 # b == 0
    or     a3,t2,t4
    bnez   a3, return_signed_inf            # a != 0 => Inf with sign
    li     a0,0x7FC0                        # 0/0 => NaN
    ret

handle_a_inf_or_nan:           # exp_a == 0xFF
    bnez   t4, return_a                      # NaN: return a
    slli   a0,t6,15                          # Inf with sign
    li     a6,0x7F80
    or     a0,a0,a6
    ret

return_b:
    mv     a0,a1
    ret

return_a:
    ret

return_signed_inf:
    slli   a0,t6,15
    li     a6,0x7F80
    or     a0,a0,a6
    ret

return_signed_zero:
    slli   a0,t6,15
    ret

return_nan:
    li     a0,0x7FC0
    ret


# bf16_sqrt
# a0=input a.bits (u16), a0=return bits (u16)
bf16_sqrt:
    addi   sp,sp,-16
    sw     ra,12(sp)

    mv     a6,a0                 # keep original a for NaN/+Inf returns

    # Extract fields
    srli   t0,a0,15              # sign
    andi   t0,t0,1
    srli   t1,a0,7               # exp
    andi   t1,t1,255
    andi   t2,a0,127             # mant

    # exp == 0xFF ?
    li     t3,255
    beq    t1,t3, case_exp_ff

    # zero? (exp==0 && mant==0)
    or     t3,t1,t2
    beqz   t3, ret_zero

    # negative finite -> NaN
    bnez   t0, ret_nan

    # denormal -> 0
    beqz   t1, ret_zero

    # e = exp - 127 ; m = 0x80 | mant
    addi   t3,t1,-127            # e
    ori    t4,t2,0x80            # m
    andi   t2,t3,1
    beqz   t2, exp_even

    # e odd: m <<= 1 ; new_exp = ((e-1)>>1)+127
    slli   t4,t4,1
    addi   t3,t3,-1
    srai   t5,t3,1               # new_exp
    addi   t5,t5,127
    j      exp_ready

exp_even:
    srai   t5,t3,1
    addi   t5,t5,127

exp_ready:
    # Binary search on [90,256], result=128
    li     a6,90                 # low
    li     a7,256                # high
    li     a5,128                # result

bin_loop_cond:
    bltu   a7,a6, bin_done       # while (low <= high)
    add    a4,a6,a7
    srli   a4,a4,1               # mid

    mv     a0,a4                 # sq = (mid*mid)>>7
    mv     a1,a4
    jal    mul16x16_u32
    srli   a0,a0,7

    bltu   t4,a0, bin_high       # if (m < sq) high=mid-1
    mv     a5,a4                 # else result=mid, low=mid+1
    addi   a6,a4,1
    j      bin_loop_cond
bin_high:
    addi   a7,a4,-1
    j      bin_loop_cond

bin_done:
    # Post-adjust result and exponent
    li     t1,256
    bltu   a5,t1, check_small
    srli   a5,a5,1               # result >>= 1
    addi   t5,t5,1               # new_exp++
    j      post_norm

check_small:
    li     t1,128
    bgeu   a5,t1, post_norm
norm_small_loop:                 # while (result<128 && new_exp>1)
    bgeu   a5,t1, post_norm
    slti   t2,t5,2
    bnez   t2, post_norm
    slli   a5,a5,1
    addi   t5,t5,-1
    j      norm_small_loop

post_norm:
    andi   a5,a5,127             # new_mant

    # Overflow/underflow on exponent
    li     t1,255
    bge    t5,t1, ret_pos_inf    # new_exp >= 255
    slti   t1,t5,1
    bnez   t1, ret_zero          # new_exp <= 0

    # Pack: sign=0
    slli   t5,t5,7
    or     a0,t5,a5
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

# --- Special cases ---
case_exp_ff:                    # exp == 0xFF
    bnez   t2, ret_a            # NaN payload -> return a
    bnez   t0, ret_nan          # -Inf -> NaN
    mv     a0,a6                # +Inf -> return a
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

ret_a:
    mv     a0,a6
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

ret_pos_inf:
    li     a0,0x7F80
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

ret_zero:
    li     a0,0
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

ret_nan:
    li     a0,0x7FC0
    lw     ra,12(sp)
    addi   sp,sp,16
    ret

main:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        li      a0, 0
        sw      a0, -12(s0)
        call    test_mul_div_sqrt
        beqz    a0, LBB4_2
        j       LBB4_1
LBB4_1:
        li      a0, 0
        sw      a0, -12(s0)
        j       LBB4_3
LBB4_2:
        li      a0, 1
        sw      a0, -12(s0)
        j       LBB4_3
LBB4_3:
        lw      a0, -12(s0)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        j       Exit

# uint32_t mul16x16_u32(uint16_t x, uint16_t y)
# a0=x, a1=y -> a0=result
mul16x16_u32:
        slli    a0, a0, 16        # x = zext16(x)
        srli    a0, a0, 16
        slli    a1, a1, 16        # y = zext16(y)
        srli    a1, a1, 16
        li      a2, 0             # r = 0
mul_loop:
        beqz    a1, mul_done      # while (y)
        andi    a3, a1, 1         # if (y & 1) r += x
        beqz    a3, mul_skip_add
        add     a2, a2, a0
mul_skip_add:
        slli    a0, a0, 1         # x <<= 1
        srli    a1, a1, 1         # y >>= 1
        bnez    a1, mul_loop
mul_done:
        mv      a0, a2
        ret

Exit:
        li      a7,10
        ecall