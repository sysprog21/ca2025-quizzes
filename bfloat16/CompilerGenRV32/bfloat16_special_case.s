.text
start:
        j       main

# RV32 register-variable mapping (across functions)
#   a0 : function argument / return value
#   a4 : temporary for masked bits or compares
#   a5 : primary temporary / boolean result
#   s0 : frame pointer
#   ra : return address
# stack frame layout (offsets from s0)
#   -20 : local bf16 input
#   -24 : s0 saved
#   -28 : ra saved

# bf16_isnan(bf16 a): return ((a & EXP)==EXP) && ((a & MANT)!=0)
bf16_isnan:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32

        # Load input into stack-local; compute (a & 0x7F80) then test equals 0x7F80; then test mantissa != 0; return 1/0
        sh      a0,-20(s0)
        lhu     a5,-20(s0)
        mv      a4,a5
        li      a5,32768
        addi    a5,a5,-128
        and     a4,a4,a5
        li      a5,32768
        addi    a5,a5,-128
        bne     a4,a5,L2
        lhu     a5,-20(s0)
        andi    a5,a5,127
        beq     a5,zero,L2
        li      a5,1
        j       L3
L2:
        li      a5,0
L3:
        # Normalize boolean to 0/1 and return
        andi    a5,a5,1
        andi    a5,a5,0xff
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra

# bf16_isinf(bf16 a): return ((a & EXP)==EXP) && ((a & MANT)==0)
bf16_isinf:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32

        # Load input; test exponent all-ones; then test mantissa equals zero; return 1/0
        sh      a0,-20(s0)
        lhu     a5,-20(s0)
        mv      a4,a5
        li      a5,32768
        addi    a5,a5,-128
        and     a4,a4,a5
        li      a5,32768
        addi    a5,a5,-128
        bne     a4,a5,L6
        lhu     a5,-20(s0)
        andi    a5,a5,127
        bne     a5,zero,L6
        li      a5,1
        j       L7
L6:
        li      a5,0
L7:
        # Normalize boolean to 0/1 and return
        andi    a5,a5,1
        andi    a5,a5,0xff
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra

# bf16_iszero(bf16 a): return (a & 0x7FFF) == 0
bf16_iszero:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32

        # Load input; clear sign bit; test zero; return 1/0
        sh      a0,-20(s0)
        lhu     a5,-20(s0)
        slli    a5,a5,17
        srli    a5,a5,17
        seqz    a5,a5
        andi    a5,a5,0xff
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra

# test_bf16_special_cases(): construct test constants and validate predicates; return 1 if all pass else 0
test_bf16_special_cases:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48

        # Initialize constants: nan1, nan2, +inf, -inf, +0, -0, num=1.0 (store to stack locals)
        li      a5,-32768
        xori    a5,a5,-63
        sh      a5,-20(s0)
        li      a5,-32768
        xori    a5,a5,-1
        sh      a5,-24(s0)
        li      a5,-32768
        xori    a5,a5,-128
        sh      a5,-28(s0)
        li      a5,-128
        sh      a5,-32(s0)
        sh      zero,-36(s0)
        li      a5,-32768
        sh      a5,-40(s0)
        li      a5,16384
        addi    a5,a5,-128
        sh      a5,-44(s0)

        # Assert: isnan(nan1) && isnan(nan2)
        lhu     a5,-20(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L12
        li      a5,0
        j       L22
L12:
        lhu     a5,-24(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L14
        li      a5,0
        j       L22

        # Assert: isinf(+inf) && isinf(-inf)
L14:
        lhu     a5,-28(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L15
        li      a5,0
        j       L22
L15:
        lhu     a5,-32(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L16
        li      a5,0
        j       L22

        # Assert: iszero(+0) && iszero(-0)
L16:
        lhu     a5,-36(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L17
        li      a5,0
        j       L22
L17:
        lhu     a5,-40(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        xori    a5,a5,1
        andi    a5,a5,0xff
        beq     a5,zero,L18
        li      a5,0
        j       L22

        # Assert: !isnan(num) && !isinf(num) && !iszero(num)
L18:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_isnan
        mv      a5,a0
        beq     a5,zero,L19
        li      a5,0
        j       L22
L19:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_isinf
        mv      a5,a0
        beq     a5,zero,L20
        li      a5,0
        j       L22
L20:
        lhu     a5,-44(s0)
        mv      a0,a5
        call    bf16_iszero
        mv      a5,a0
        beq     a5,zero,L21
        li      a5,0
        j       L22

        # All assertions passed �� return true
L21:
        li      a5,1
L22:
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra

# main(): run tests; map boolean to process exit code 0/1 and issue Ripes exit ecall
main:
        addi    sp,sp,-16
        sw      ra,12(sp)
        sw      s0,8(sp)
        addi    s0,sp,16

        # Call test; invert to exit code: success->0, fail->1; return to simulator
        call    test_bf16_special_cases
        mv      a5,a0
        beq     a5,zero,L24
        li      a5,0
        j       L25
L24:
        li      a5,1
L25:
        mv      a0,a5
        lw      ra,12(sp)
        lw      s0,8(sp)
        addi    sp,sp,16
        j       Exit

Exit:
        # Ripes environment: ecall with a7=10 exits the program
        li   a7,10
        ecall
