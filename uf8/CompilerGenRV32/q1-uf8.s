.data
msg_mis: .string "mismatch: fl="
msg_val: .string ", val="
msg_enc: .string ", enc="
msg_le:  .string "non-increasing: fl="
okmsg:   .string "All tests passed."

.text

        j      main
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
uf8_decode:
        addi    sp,sp,-48
        sw      ra,44(sp)
        sw      s0,40(sp)
        addi    s0,sp,48
        mv      a5,a0
        sb      a5,-33(s0)
        lbu     a5,-33(s0)
        andi    a5,a5,15
        sw      a5,-20(s0)
        lbu     a5,-33(s0)
        srli    a5,a5,4
        sb      a5,-21(s0)
        lbu     a5,-21(s0)
        li      a4,15
        sub     a5,a4,a5
        li      a4,32768
        addi    a4,a4,-1
        sra     a5,a4,a5
        slli    a5,a5,4
        sw      a5,-28(s0)
        lbu     a5,-21(s0)
        lw      a4,-20(s0)
        sll     a4,a4,a5
        lw      a5,-28(s0)
        add     a5,a4,a5
        mv      a0,a5
        lw      ra,44(sp)
        lw      s0,40(sp)
        addi    sp,sp,48
        jr      ra
uf8_encode:
        addi    sp,sp,-64
        sw      ra,60(sp)
        sw      s0,56(sp)
        addi    s0,sp,64
        sw      a0,-52(s0)
        lw      a4,-52(s0)
        li      a5,15
        bgtu    a4,a5,L8
        lw      a5,-52(s0)
        andi    a5,a5,0xff
        j       L9
L8:
        lw      a0,-52(s0)
        call    clz
        mv      a5,a0
        sw      a5,-32(s0)
        li      a4,31
        lw      a5,-32(s0)
        sub     a5,a4,a5
        sw      a5,-36(s0)
        sb      zero,-17(s0)
        sw      zero,-24(s0)
        lw      a4,-36(s0)
        li      a5,4
        ble     a4,a5,L16
        lw      a5,-36(s0)
        andi    a5,a5,0xff
        addi    a5,a5,-4
        sb      a5,-17(s0)
        lbu     a4,-17(s0)
        li      a5,15
        bleu    a4,a5,L11
        li      a5,15
        sb      a5,-17(s0)
L11:
        sb      zero,-25(s0)
        j       L12
L13:
        lw      a5,-24(s0)
        slli    a5,a5,1
        addi    a5,a5,16
        sw      a5,-24(s0)
        lbu     a5,-25(s0)
        addi    a5,a5,1
        sb      a5,-25(s0)
L12:
        lbu     a4,-25(s0)
        lbu     a5,-17(s0)
        bltu    a4,a5,L13
        j       L14
L15:
        lw      a5,-24(s0)
        addi    a5,a5,-16
        srli    a5,a5,1
        sw      a5,-24(s0)
        lbu     a5,-17(s0)
        addi    a5,a5,-1
        sb      a5,-17(s0)
L14:
        lbu     a5,-17(s0)
        beq     a5,zero,L16
        lw      a4,-52(s0)
        lw      a5,-24(s0)
        bltu    a4,a5,L15
        j       L16
L19:
        lw      a5,-24(s0)
        slli    a5,a5,1
        addi    a5,a5,16
        sw      a5,-40(s0)
        lw      a4,-52(s0)
        lw      a5,-40(s0)
        bltu    a4,a5,L20
        lw      a5,-40(s0)
        sw      a5,-24(s0)
        lbu     a5,-17(s0)
        addi    a5,a5,1
        sb      a5,-17(s0)
L16:
        lbu     a4,-17(s0)
        li      a5,14
        bleu    a4,a5,L19
        j       L18
L20:
        nop
L18:
        lw      a4,-52(s0)
        lw      a5,-24(s0)
        sub     a4,a4,a5
        lbu     a5,-17(s0)
        srl     a5,a4,a5
        sb      a5,-41(s0)
        lb      a5,-17(s0)
        slli    a5,a5,4
        slli    a4,a5,24
        srai    a4,a4,24
        lb      a5,-41(s0)
        or      a5,a4,a5
        slli    a5,a5,24
        srai    a5,a5,24
        andi    a5,a5,0xff
L9:
        mv      a0,a5
        lw      ra,60(sp)
        lw      s0,56(sp)
        addi    sp,sp,64
        jr      ra
        
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
        jr      ra
        
