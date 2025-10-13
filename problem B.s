    .data
# 訊息
msg_mismatch_a: .string "fl = "
msg_mismatch_b: .string " produces value "
msg_mismatch_c: .string " but encodes back to "
msg_order_a:    .string "fl = "
msg_order_b:    .string " value "
msg_order_c:    .string " <= previous_value "
ok_msg:         .string "All tests passed."
nl:             .byte 10

    .text

# =========================================================
# clz_fast(uint32_t x)  -- branchless binary search (leaf)
# - 若 x==0，回傳 32
# - 否則回傳前導零數 (0..31)
# =========================================================
    .globl clz_fast
clz_fast:
    beq   a0, x0, L_clz_zero          # x==0 → 32

    # r = 0; 逐段測試高半/高 8/高 4/高 2/高 1 bits
    li    t5, 0                        # r

    srli  t0, a0, 16                   # t0 = x>>16
    sltu  t1, x0, t0                   # t1 = (t0!=0)?1:0
    slli  t2, t1, 4                    # t2 = 16 or 0
    srl   a0, a0, t2                   # x >>= t2
    or    t5, t5, t2                   # r |= t2

    srli  t0, a0, 8
    sltu  t1, x0, t0
    slli  t2, t1, 3                    # 8 or 0
    srl   a0, a0, t2
    or    t5, t5, t2

    srli  t0, a0, 4
    sltu  t1, x0, t0
    slli  t2, t1, 2                    # 4 or 0
    srl   a0, a0, t2
    or    t5, t5, t2

    srli  t0, a0, 2
    sltu  t1, x0, t0
    slli  t2, t1, 1                    # 2 or 0
    srl   a0, a0, t2
    or    t5, t5, t2

    srli  t0, a0, 1
    sltu  t1, x0, t0                   # 1 or 0
    add   t5, t5, t1                   # r += 1 if (x>>1)!=0

    li    t0, 31
    sub   a0, t0, t5                   # clz = 31 - r
    jalr  x0, ra, 0

L_clz_zero:
    li    a0, 32
    jalr  x0, ra, 0

# =========================================================
# uf8_decode_fast(uint8_t fl)
# value = (mant<<exp) + ((1<<(exp+4))-16)  ; offset = (16<<exp) - 16
# =========================================================
    .globl uf8_decode_fast
uf8_decode_fast:
    andi  t0, a0, 0x0F                 # mant
    srli  t1, a0, 4                    # exp
    addi  t2, x0, 1
    addi  t3, t1, 4                    # (exp + 4)
    sll   t2, t2, t3                   # t2 = 1<<(exp+4)
    addi  t2, t2, -16                  # offset = (1<<(exp+4)) - 16
    sll   t0, t0, t1                   # mant<<exp
    add   a0, t0, t2
    jalr  x0, ra, 0

# =========================================================
# uf8_encode_fast(uint32_t v)
# e  = clamp( floor_log2(v+16) - 4, 0..15 )
# off= (16<<e) - 16
# m  = ((v - off) >> e) & 0xF
# ret= (e<<4) | m
# =========================================================
    .globl uf8_encode_fast
uf8_encode_fast:
    # a0 = v
    addi  a1, a0, 16                   # a1 = v + 16  (一定 >0)
    # floor_log2(a1) = 31 - clz(a1)
    addi  sp, sp, -4
    sw    ra, 0(sp)
    addi  a0, a1, 0
    jal   ra, clz_fast
    li    t0, 31
    sub   t0, t0, a0                   # t0 = floor_log2(v+16)

    addi  t1, t0, -4                   # e = floor_log2(v+16) - 4
    slti  t2, t1, 0                    # t2 = (e<0)?1:0
    beq   t2, x0, L_e_nonneg
    li    t1, 0
L_e_nonneg:
    li    t3, 15
    bge   t1, t3, L_e_clip_max
    j     L_e_done
L_e_clip_max:
    li    t1, 15
L_e_done:
    # off = (16<<e) - 16
    li    t4, 16
    sll   t4, t4, t1                   # 16<<e
    addi  t4, t4, -16                  # off

    sub   t5, a1, t4                   # (v+16) - off = v - off + 16
    srl   t5, t5, t1                   # >> e
    andi  t5, t5, 0x0F                 # mant = &0xF
    slli  t6, t1, 4
    or    a0, t6, t5                   # (e<<4) | mant

    lw    ra, 0(sp)
    addi  sp, sp, 4
    jalr  x0, ra, 0

# =========================================================
# test(): 驗證 0..255 的往返與嚴格遞增；只在失敗時輸出
# =========================================================
    .globl test
test:
    addi  sp, sp, -32
    sw    ra, 28(sp)
    sw    s0, 24(sp)      # i
    sw    s1, 20(sp)      # previous_value
    sw    s2, 16(sp)      # passed
    sw    s3, 12(sp)      # fl2
    sw    s4,  8(sp)      # value

    li    s0, 0
    li    s1, -1
    li    s2, 1

L_loop_i:
    li    t0, 256
    beq   s0, t0, L_test_done

    andi  a0, s0, 0xFF
    jal   ra, uf8_decode_fast
    addi  s4, a0, 0

    addi  a0, s4, 0
    jal   ra, uf8_encode_fast
    addi  s3, a0, 0

    andi  t1, s0, 0xFF
    beq   t1, s3, L_check_order

    # fl != fl2  -> 印詳細
    la    a0, msg_mismatch_a ; li a7, 4 ; ecall
    addi  a0, t1, 0          ; li a7, 1 ; ecall
    la    a0, msg_mismatch_b ; li a7, 4 ; ecall
    addi  a0, s4, 0          ; li a7, 1 ; ecall
    la    a0, msg_mismatch_c ; li a7, 4 ; ecall
    addi  a0, s3, 0          ; li a7, 1 ; ecall
    la    a0, nl             ; li a7, 4 ; ecall
    li    s2, 0

L_check_order:
    blt   s1, s4, L_next_i

    # value 未嚴格遞增 -> 印詳細
    la    a0, msg_order_a ; li a7, 4 ; ecall
    andi  a0, s0, 0xFF    ; li a7, 1 ; ecall
    la    a0, msg_order_b ; li a7, 4 ; ecall
    addi  a0, s4, 0       ; li a7, 1 ; ecall
    la    a0, msg_order_c ; li a7, 4 ; ecall
    addi  a0, s1, 0       ; li a7, 1 ; ecall
    la    a0, nl          ; li a7, 4 ; ecall
    li    s2, 0

L_next_i:
    addi  s1, s4, 0
    addi  s0, s0, 1
    j     L_loop_i

L_test_done:
    addi  a0, s2, 0
    lw    ra, 28(sp)
    lw    s0, 24(sp)
    lw    s1, 20(sp)
    lw    s2, 16(sp)
    lw    s3, 12(sp)
    lw    s4,  8(sp)
    addi  sp, sp, 32
    jalr  x0, ra, 0

# =========================================================
# main()
# =========================================================
    .globl main
main:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    jal   ra, test
    beq   a0, x0, L_main_fail

    la    a0, ok_msg ; li a7, 4 ; ecall
    la    a0, nl     ; li a7, 4 ; ecall
    li    a0, 0
    j     L_main_done
L_main_fail:
    li    a0, 1
L_main_done:
    lw    ra, 12(sp)
    addi  sp, sp, 16
    li    a7, 10
    ecall
