.data
TensionControl: .word 0    # Dirección del registro de control
TensionEstado:  .word 0    # Dirección del registro de estado
TensionSistol:  .word 0    # Dirección para tensión sistólica
TensionDiastol: .word 0    # Dirección para tensión diastólica
Nueva_linea:    .asciiz "\n"
InicializadoControl: "Tensión de Control: Inicializado."
ExitoInicializadoEstado: .asciiz "Tensión de Estado: Inicializado."
Espera: .asciiz "Espera mientras se mide..."
ValorSist: "Valor de la Tensión sistólica: "
ValorDiast: "Valor de la Tensión diastólica: "

.text
.globl main

main:
	# inicialiamos contador de delay de 5 Seg
	li $s2, 5
	
# Procedimiento: controlador_tension
# Descripción: Inicia una medición de tensión arterial y espera los resultados
# Retorna: $v0 = valor sistólico
#          $v1 = valor diastólico
controlador_tension:
    # Guardar registros en la pila
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    # Iniciar medición (escribir 1 en TensionControl)
    li $t0, 1
    la $s0, TensionControl
    sw $t0, 0($s0)
    
    li $v0, 4
    la $a0, InicializadoControl
    syscall
    
    li $v0, 4
    la $a0, Nueva_linea
    syscall
    
    li $v0, 4
    la $a0, Espera
    syscall
    
    li $v0, 4
    la $a0, Nueva_linea
    syscall
    # Esperar a que la medición esté lista (TensionEstado == 1)
    la $s0, TensionEstado
esperar_medicion:
    lw $t1, 0($s0)
    beq $t1, 1, valores_medidos
    # Simulamos una espera de 5 seg, que es la espera de el dispositivo midiendo
    addi $s2, $s2, -1
    
    li $v0, 32       # Código de syscall para "sleep"
	li $a0, 1000     # Milisegundos a esperar (1000 ms = 1 segundo)
	syscall
    # Condicion de los 5 segundos, al pasar, cambia el valor de TensionEstado a 1
    bge $s2, 1, sigue_la_espera
	li $t0, 1
	sw $t0, 0($s0)
	
sigue_la_espera:

	li $v0, 1
    move $a0, $s2
    syscall
    
    li $v0, 4
    la $a0, Nueva_linea
    syscall
    
    j esperar_medicion

valores_medidos:
	# Guardamos valores de prueba
	li $t0, 120
	la $s0, TensionSistol
	sw $t0, 0($s0)
	li $t0, 80
	la $s1, TensionDiastol
	sw $t0, 0($s1)
	
medicion_lista:
    # Leer resultados
    la $s0, TensionSistol
    lw $v0, 0($s0)          # $v0 = valor sistólico
    
    la $s1, TensionDiastol
    lw $v1, 0($s1)          # $v1 = valor diastólico
    
    # Restaurar registros de la pila
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    
mostrar:
	# Mostrar los valores almacenados en $v0 y $v1
	# (Guardar el valor de $v0 en $t0)
	move $t0, $v0
	
	li $v0, 4
    la $a0, ValorSist
    syscall
    
	move $a0, $t0
	li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, Nueva_linea
    syscall
    
    li $v0, 4
    la $a0, ValorDiast
    syscall
    
    move $a0, $v1
	li $v0, 1
    syscall
