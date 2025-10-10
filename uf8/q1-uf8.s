# RISC-V RV32I assembly translation of q1-uf8.c
# - No extensions required (no Zbb CLZ); software clz implemented
# - Uses libc printf for output
# - ABI: ilp32 (RV32), System V RISC-V psABI
# CoPilot Generated

	.text
	.align 2
	.globl clz
	.type clz, @function
# unsigned clz(uint32_t x)
clz:
	# Prologue (keep stack 16-byte aligned)
	addi	sp, sp, -16
	sw	ra, 12(sp)
	# a0 = x
	mv	t0, a0          # t0 = x
	li	t1, 32          # t1 = n
	li	t2, 16          # t2 = c
1:
	srl	t3, t0, t2     # t3 = y = x >> c
	beqz	t3, 2f
	sub	t1, t1, t2     # n -= c
	mv	t0, t3          # x = y
2:
	# c >>= 1
	srli	t2, t2, 1
	bnez	t2, 1b
	sub	a0, t1, t0     # return n - x
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret

	.size clz, .-clz

	.align 2
	.globl uf8_decode
	.type uf8_decode, @function
# uint32_t uf8_decode(uint8_t fl)
uf8_decode:
	# a0 = fl
	andi	t0, a0, 0x0f    # mantissa
	srli	t1, a0, 4       # exponent
	li	t2, 15
	sub	t2, t2, t1      # t2 = 15 - exponent
	li	t3, 0x7fff
	srl	t3, t3, t2      # 0x7fff >> (15 - exponent)
	slli	t3, t3, 4       # << 4
	sll	t4, t0, t1      # mantissa << exponent
	add	a0, t4, t3      # return value
	ret
	.size uf8_decode, .-uf8_decode

	.align 2
	.globl uf8_encode
	.type uf8_encode, @function
# uint8_t uf8_encode(uint32_t value)
uf8_encode:
	addi	sp, sp, -48
	sw	ra, 44(sp)
	sw	a0, 0(sp)       # save value
	# if (value < 16) return value
	sltiu	t0, a0, 16
	bnez	t0, .Luf8_small
	# lz = clz(value)
	lw	a0, 0(sp)
	call	clz
	mv	t1, a0          # t1 = lz
	# msb = 31 - lz
	li	t2, 31
	sub	t2, t2, t1      # t2 = msb
	# exponent = 0; overflow = 0
	mv	t3, zero        # t3 = exponent
	mv	t4, zero        # t4 = overflow
	# if (msb >= 5)
	slti	t5, t2, 5       # t5 = (msb < 5)
	bnez	t5, .Lskip_estimate
	# exponent = msb - 4
	addi	t3, t2, -4
	# if (exponent > 15) exponent = 15
	sltiu	t6, t3, 16
	bnez	t6, 3f
	li	t3, 15
3:
	# overflow = 0; for (e=0;e<exponent;e++) overflow = (overflow<<1)+16
	mv	t6, t3          # t6 = remaining count
	beqz	t6, 4f
.Lfor_overflow:
	slli	t4, t4, 1
	addi	t4, t4, 16
	addi	t6, t6, -1
	bnez	t6, .Lfor_overflow
4:
	# while (exponent > 0 && value < overflow) { overflow=(overflow-16)>>1; exponent--; }
.Ladjust:
	beqz	t3, .Lafter_adjust
	lw	t0, 0(sp)       # value
	bltu	t0, t4, 5f
	j	.Lafter_adjust
5:
	addi	t4, t4, -16
	srli	t4, t4, 1
	addi	t3, t3, -1
	j	.Ladjust
.Lafter_adjust:
.Lskip_estimate:
	# while (exponent < 15)
.Lwhile_refine:
	sltiu	t0, t3, 15
	beqz	t0, .Lafter_refine
	# next_overflow = (overflow<<1)+16
	slli	t5, t4, 1
	addi	t5, t5, 16
	lw	t0, 0(sp)       # value
	bltu	t0, t5, .Lafter_refine
	mv	t4, t5
	addi	t3, t3, 1
	j	.Lwhile_refine
.Lafter_refine:
	# mantissa = (value - overflow) >> exponent
	lw	t0, 0(sp)
	sub	t6, t0, t4
	srl	t6, t6, t3
	# return (exponent<<4) | mantissa
	slli	t3, t3, 4
	or	a0, t3, t6
	lw	ra, 44(sp)
	addi	sp, sp, 48
	ret

.Luf8_small:
	# return value (already in a0)
	lw	ra, 44(sp)
	addi	sp, sp, 48
	ret
	.size uf8_encode, .-uf8_encode

	.section .rodata
	.align 2
fmt_mismatch:
	.asciz "%02x: produces value %d but encodes back to %02x\n"
fmt_nondecr:
	.asciz "%02x: value %d <= previous_value %d\n"
msg_all_ok:
	.asciz "All tests passed.\n"

	.text
	.align 2
	.globl test
	.type test, @function
# static bool test(void)
test:
	addi	sp, sp, -64
	sw	ra, 60(sp)
	# previous_value = -1
	li	t0, -1
	sw	t0, 56(sp)
	# passed = 1
	li	t0, 1
	sw	t0, 52(sp)
	# i = 0
	mv	t0, zero
	sw	t0, 48(sp)
.Lfor_i:
	lw	t0, 48(sp)
	li	t1, 256
	bgeu	t0, t1, .Ldone_loop
	andi	t2, t0, 0xff    # fl
	# value = uf8_decode(fl)
	mv	a0, t2
	call	uf8_decode
	mv	t3, a0
	sw	t3, 44(sp)
	# fl2 = uf8_encode(value)
	mv	a0, t3
	call	uf8_encode
	andi	t4, a0, 0xff    # fl2
	# if (fl != fl2)
	bne	t2, t4, .Lmismatch
	j	.Lcheck_order
.Lmismatch:
	la	a0, fmt_mismatch
	mv	a1, t2
	mv	a2, t3
	mv	a3, t4
	call	printf
	sw	zero, 52(sp)   # passed = false
.Lcheck_order:
	lw	t3, 44(sp)      # value
	lw	t6, 56(sp)      # previous_value
	# if (value <= previous_value)
	blt	t6, t3, .Lupdate_prev   # if previous < value, skip the error
	la	a0, fmt_nondecr
	mv	a1, t2
	mv	a2, t3
	mv	a3, t6
	call	printf
	sw	zero, 52(sp)
.Lupdate_prev:
	sw	t3, 56(sp)      # previous_value = value
	# i++
	lw	t0, 48(sp)
	addi	t0, t0, 1
	sw	t0, 48(sp)
	j	.Lfor_i

.Ldone_loop:
	lw	a0, 52(sp)      # return passed
	lw	ra, 60(sp)
	addi	sp, sp, 64
	ret
	.size test, .-test

	.align 2
	.globl main
	.type main, @function
main:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	call	test
	beqz	a0, .Lfail
	la	a0, msg_all_ok
	call	printf
	li	a0, 0
	j	.Ldone
.Lfail:
	li	a0, 1
.Ldone:
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
	.size main, .-main

	.ident "Translated to RISC-V RV32I"
