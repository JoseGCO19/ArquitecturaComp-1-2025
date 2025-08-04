.data
    msg_green:      .asciiz "Semáforo en verde, esperando pulsador.\n"
    msg_pressed:    .asciiz "Pulsador activado: en 20 segundos, el semáforo cambiará a amarillo.\n"
    msg_yellow:     .asciiz "Semáforo en amarillo, en 10 segundos, semáforo en rojo.\n"
    msg_red:        .asciiz "Semáforo en rojo, en 30 segundos, semáforo en verde.\n"
    newline:        .asciiz "\n"
    count_prefix:   .asciiz "Tiempo restante: "
    count_suffix:   .asciiz " segundos"

.text
main:
    # Inicializar el semáforo en verde
    li $v0, 4
    la $a0, msg_green
    syscall

loop:
    # Esperar pulsador (tecla 's')
    li $v0, 12          # Leer carácter
    syscall
    li $t0, 's'         # Comparar con 's'
    beq $v0, $t0, pressed

    j loop              # Volver a esperar

pressed:
    # Mensaje de pulsador activado
    li $v0, 4
    la $a0, msg_pressed
    syscall

    # Temporizador de 20 segundos con conteo
    li $t1, 20          # Cargar 20 segundos
    jal countdown       # Llamar a la función de conteo

    # Cambiar a amarillo
    li $v0, 4
    la $a0, msg_yellow
    syscall

    # Temporizador de 10 segundos con conteo
    li $t1, 10          # Cargar 10 segundos
    jal countdown       # Llamar a la función de conteo

    # Cambiar a rojo
    li $v0, 4
    la $a0, msg_red
    syscall

    # Temporizador de 30 segundos con conteo
    li $t1, 30          # Cargar 30 segundos
    jal countdown       # Llamar a la función de conteo

    # Volver a verde y repetir
    j main

# Función de conteo regresivo
# Entrada: $t1 = número de segundos a esperar
countdown:
    move $t3, $t1       # Guardar el tiempo inicial
    
count_loop:
    # Mostrar el conteo
    li $v0, 4
    la $a0, count_prefix
    syscall
    
    li $v0, 1
    move $a0, $t3
    syscall
    
    li $v0, 4
    la $a0, count_suffix
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    # Esperar 1 segundo (1000 ms)
    li $v0, 32
    li $a0, 1000
    syscall
    
    # Decrementar contador
    subi $t3, $t3, 1
    bgtz $t3, count_loop
    
    jr $ra              # Volver de la función