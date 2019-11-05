# Prog de prueba para Pr�ctica 2. Ej 1

.data 0
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8 
num3: .word 8 # posic 12 
num4: .word 16 # posic 16 
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44
.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero) # lw $r9, 0($r0)
  lw $t2, 4($zero) # lw $r10, 4($r0)
  lw $t3, 8($zero) # lw $r11, 8($r0)
  lw $t4, 12($zero) # lw $r12, 12($r0)
  lw $t5, 16($zero) # lw $r13, 16($r0)
  lw $t6, 20($zero) # lw $r14, 20($r0)
  nop
  nop
  nop
  nop
  add $t3, $t2, $t5 # 12 + 4 = 16 Salto no Efectivo
  beq $t3, $t5, jmp1
  nop
  nop
  nop
  add $t3, $t2, $t5 # 12 + 4 = 16 Salto Efectivo
  beq $t3, $t3, jmp2
  jmp1: add $t1, $t2, $t3
  nop
  nop
  nop
  jmp2: add $t7, $t6, $t5
  nop
  nop
  nop
  nop
  lw $t3, 16($zero) # lw r3 16 Salto no Efectivo
  beq $t3, $t5, jmp3
  nop
  nop
  nop
  lw $t3, 16($zero) # lw r3 16 Salto Efectivo
  beq $t3, $t3, jmp4
  jmp3: add $t1, $t2, $t3
  nop
  nop
  nop
  jmp4: add $t7, $t6, $t5