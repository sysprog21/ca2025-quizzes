.text
uf8_decode:
# 
        addi    sp,sp,-48          # prologue: allocate 48B frame
        sw      ra,44(sp)          # save ra
        sw      s0,40(sp)          # save s0
        addi    s0,sp,48           # s0 = sp + 48 (set FP)

