# Fib recursivo
.data
	input: .asciiz "Ingrese en numero n: "
	output: .asciiz "Resultado: "
	error: .asciiz "Valor no permitido"
	
.text
.globl main
	main:
		# mostrar mensaje
		li $v0, 4
		la $a0, input
		syscall
		
		# leer valor n
		li $v0, 5
		syscall
		move $t0, $v0
		
		add $t0, $t0, 1
		
		# si $t0 < 1
		blt $t0, 1, caso_error
		# si $t0 == 1
		beq $t0, 1, caso_1
		regreso_caso_1:
		# si $t0 == 2
		beq $t0, 2, caso_2
		regreso_caso_2:
		# si $t0 >=3
		move $a0, $t0 	# argumento 1 N
		li $a1, 0 		# argumento 2 0
		li $a2, 1 		# argumento 3 1
		bge $t0, 3, llamadafibRecursivo

		
		# fin de programa
		regreso_caso_error:
		li $v0, 10
		syscall
		
		llamadafibRecursivo:
			jal fibRecursivo
			
			# mostrar resultado
			move $a0, $v0
			jal mostrar
			
			# fin de programa
			li $v0, 10
			syscall
			
	caso_error:
		# devolver 0
		li $v0, 4
		la $a0, error
		syscall
		
		# regresar
		j regreso_caso_error
		
	caso_1:
		# devolver 0
		li $a0, 0
		jal mostrar
		
		# regresar
		j regreso_caso_1
	
	caso_2:
		# devolver 1
		li $a0, 1
		jal mostrar
		
		# regresar
		j regreso_caso_2
		
	mostrar:
		# guardar en pila
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# guardar valor a mostrar
		move $t6, $a0
		
		# mostrar mensaje
		li $v0, 4
		la $a0, output
		syscall
	
		# mostrar el valor
		li $v0, 1
		move $a0, $t6
		syscall
		
		# cargar desde pila
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# regresar
		jr $ra

	fibRecursivo: # (N, 0, 1)
		# Reservamos espacio en la pila
		addi $sp, $sp, -16
		sw $ra, 0($sp)
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a2, 12($sp)
		
		beq $a0, 3, caso_base
		# llamada recursiva
		move $t0, $a2
		add $a2, $a1, $t0
		move $a1, $t0
		addi $a0, $a0, -1
		
		jal fibRecursivo
		
		# recuperar de la pila
		addi $sp, $sp, 16
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		
		# regresar
		jr $ra

		
		caso_base:
			# caso base
			add $v0, $a1, $a2
			
			# regresar
			jr $ra
