# Fib
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
		move $a0, $t0 # argumento
		bge $t0, 3, fib
		regreso_fib:
		
		# fin de programa
		regreso_caso_error:
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

	fib:
		# valores base
		li $t0, 3
		li $t1, 0
		li $t2, 1
		
		# loop
		loop:
			bgt $t0, $a0, loop_fin
			# calcular $t3
			add $t3, $t1, $t2

			# cambiar $t2 a $t1
			move $t1, $t2

			# cambiar $t3 a $t2
			move $t2, $t3
						
			# aumentar indice $t0
			addi $t0, $t0, 1
			
			# regresar al loop
			j loop
			
		loop_fin:
			# fin del bucle
			move $a0, $t3
			jal mostrar
			j regreso_fib
		
		
