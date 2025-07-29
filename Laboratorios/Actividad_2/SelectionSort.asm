.data
    mensaje:     .asciiz "Ingrese el número de elementos del array (máximo 20): "
    mensaje_elemento_1: .asciiz "Ingrese el elemento ["
    mensaje_elemento_2: .asciiz "]: "
    mensaje_array_original: .asciiz "\nArray original: "
    mensaje_array_ordenado:   .asciiz "\nArray ordenado: "
    espacio:      .asciiz " "
    nueva_linea:    .asciiz "\n"
    error: .asciiz "Error: Valor introducido No valido"
    array:      .word 0:20       # Reservamos espacio para 20 elementos (4 bytes cada uno)

.text
.globl main

main:
    # Pedir al usuario el número de elementos
    li $v0, 4
    la $a0, mensaje
    syscall
    
    # Leer el número de elementos (n)
    li $v0, 5
    syscall
    move $s0, $v0                # $s0 = n (número de elementos)
    
    # Validar que n <= 20 y que no se cumple n <= 0
    ble $s0, 0, caso_error
    ble $s0, 20, tamano_valido
    
caso_error:
	
	# Muestra por pantalla que ha habido un error por introducir un valor erroneo y termina el programa
	li $v0, 4
	la $a0, error
	syscall
	
	j terminar
	
tamano_valido:
    
    # Inicializar contador para leer elementos
    li $t0, 0                    # $t0 = i = 0
    la $s1, array                # $s1 = dirección base del array
    
entrada_loop:
    beq $t0, $s0, fin_entrada      # Si i == n, terminar
    
    # Pedir al usuario el elemento i
    li $v0, 4
    la $a0, mensaje_elemento_1
    syscall
    
    li $v0, 1
    move $a0, $t0
    syscall
    
    li $v0, 4
    la $a0, mensaje_elemento_2
    syscall
    
    # Leer el elemento
    li $v0, 5
    syscall
    sw $v0, 0($s1)               # Almacenar el valor en array[i]
    
    # Incrementar contadores
    addi $t0, $t0, 1             # i++
    addi $s1, $s1, 4             # Avanzar al siguiente elemento (4 bytes)
    j entrada_loop
    
fin_entrada:
    # Mostrar el array original
    li $v0, 4
    la $a0, mensaje_array_original
    syscall
    
    jal imprimir_array
    
    # Llamar a selection sort
    jal selection_sort
    
    # Mostrar el array ordenado
    li $v0, 4
    la $a0, mensaje_array_ordenado
    syscall
    
    jal imprimir_array
    
terminar:    
    # Terminar programa
    li $v0, 10
    syscall

# Funcion: selection_sort
# Ordena el array usando el algoritmo Selection Sort
selection_sort:
    la $a1, array                # $a1 = dirección base del array
    li $t0, 0                    # $t0 = i = 0
    addi $t1, $s0, -1            # $t1 = n-1 (límite para i)
    
externo_loop:
    bge $t0, $t1, fin_loop_externo      # Si i >= n-1, terminar
    
    move $t2, $t0                # $t2 = indice_menor = i
    addi $t3, $t0, 1             # $t3 = j = i+1
    
interno_loop:
    bge $t3, $s0, fin_interno      # Si j >= n, terminar
    
    # Calcular direcciones de array[j] y array[indice_menor]
    sll $t4, $t2, 2              # $t4 = indice_menor * 4
    add $t4, $a1, $t4            # $t4 = dirección de array[indice_menor]
    lw $t5, 0($t4)               # $t5 = array[indice_menor]
    
    sll $t6, $t3, 2              # $t6 = j * 4
    add $t6, $a1, $t6            # $t6 = dirección de array[j]
    lw $t7, 0($t6)               # $t7 = array[j]
    
    bge $t7, $t5, no_es_minimo     # Si array[j] >= array[indice_menor], saltar
    move $t2, $t3                # indice_menor = j
    
no_es_minimo:
    addi $t3, $t3, 1             # j++
    j interno_loop
    
fin_interno:
    beq $t2, $t0, no_cambio		# Si indice_menor == i, no intercambiar
    
    # Intercambiar array[i] y array[indice_menor]
    sll $t4, $t0, 2              # $t4 = i * 4
    add $t4, $a1, $t4            # $t4 = dirección de array[i]
    lw $t5, 0($t4)               # $t5 = array[i]
    
    sll $t6, $t2, 2              # $t6 = indice_menor * 4
    add $t6, $a1, $t6            # $t6 = dirección de array[indice_menor]
    lw $t7, 0($t6)               # $t7 = array[indice_menor]
    
    sw $t7, 0($t4)               # array[i] = array[indice_menor]
    sw $t5, 0($t6)               # array[indice_menor] = array[i]
    
no_cambio:
    addi $t0, $t0, 1             # i++
    j externo_loop
    
fin_loop_externo:
    jr $ra                       # Retornar

# Funcion: imprimir_array
# Imprime los elementos del array
imprimir_array:
    la $t0, array                # $t0 = dirección base del array
    li $t1, 0                    # $t1 = i = 0
    
imprimir_loop:
    bge $t1, $s0, fin_imprimir      # Si i >= n, terminar
    
    # Imprimir array[i]
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    # Imprimir espacio
    li $v0, 4
    la $a0, espacio
    syscall
    
    # Incrementar contadores
    addi $t1, $t1, 1             # i++
    addi $t0, $t0, 4             # Avanzar al siguiente elemento
    j imprimir_loop
    
fin_imprimir:
    # Imprimir nueva línea
    li $v0, 4
    la $a0, nueva_linea
    syscall
    
    jr $ra                       # Retornar
