.data
buffer:         .space 512       # Buffer circular de 512 bytes
buffer_tam:    .word 512        # Tamaño del buffer
cabeza:           .word 0          # Puntero de escritura
cola:           .word 0          # Puntero de lectura
timeout:        .word 20         # Temporizador de 20 segundos
ini_tiempo:     .word 0          # Tiempo de inicio
act_char:   .byte 0          # Caracter actual leído

# Mensajes
timeout_msg:    .asciiz "\nTiempo completado. Contenido del buffer:\n"
nueva_linea:        .asciiz "\n"

.text
.globl main

main:
    # Inicialización
    la $s0, buffer               # $s0 = dirección base del buffer
    lw $s1, buffer_tam          # $s1 = tamaño del buffer
    sw $zero, cabeza               # Inicializar la cabeza del buffer a 0
    sw $zero, cola               # Inicializar la cola del buffer a 0
    
main_loop:
    # Obtener tiempo actual (simulado)
    jal get_tiempo_act
    sw $v0, ini_tiempo          # Guardar tiempo de inicio
    li $s2, 0
    
input_loop:
    # Verificar si ha pasado el tiempo
    jal get_tiempo_act
    lw $t0, ini_tiempo
    lw $t1, timeout
    add $t0, $t0, $t1            # Tiempo de finalización = tiempo de inicio + timeout (los 20 seg)
    bge $v0, $t0, imprimir_buffer   # Si tiempo actual >= Tiempo de finalización, imprimir buffer
    
    # Leer caracter del teclado (simulado)
    jal leer_char
    
    # Si no hay caracter disponible, continuar
    beqz $v0, input_loop
    
    # Almacenar caracter en buffer
    lb $t2, act_char         # Cargar caracter leído
    lw $t3, cabeza                 # Cargar posición actual de la cabeza del buffer
    add $t4, $s0, $t3            # Calcular dirección de escritura (dirección del buffer + la dirección de la cabeza)
    sb $t2, 0($t4)               # Almacenar caracter en buffer (en la posicíon antes calculada)
    
    # Actualizar cabeza (buffer circular)
    addi $t3, $t3, 1             # Incrementar la cabeza del buffer
    blt $t3, $s1, no_wrap_cabeza   # Si cabeza < Buffer_tam, no hacer wrap
    move $t3, $zero              # Si no, cabeza = 0
    li $s2, 1					# También, va a haber un registro ($s2) que nos indique cuando se hizo wrap
no_wrap_cabeza:
    sw $t3, cabeza                 # Guardar nuevo valor de la cabeza del buffer
    
    j input_loop                 # Continuar leyendo caracteres

imprimir_buffer:
    # Imprimir mensaje de timeout
    li $v0, 4
    la $a0, timeout_msg
    syscall
    
    # Imprimir contenido del buffer
    lw $t0, cola                 # Cargar cola
    lw $t1, cabeza                 # Cargar cabeza
    
    # Comprueba si ha habido un wrap (Caso especial)
    beqz $s2, sin_caso_especial_warp
    
    # Se guarda el valor de la cola como el byte que le sigue a la cabeza
    addi $t0, $t1, 1
    
    # Saltamos a imprimir el buffer
    j imprimir_loop
    
sin_caso_especial_warp:  
    beq $t0, $t1, buffer_vacio   # Si tail == head, buffer vacío
    
imprimir_loop:
    # Calcular dirección de lectura
    add $t2, $s0, $t0            # buffer + cola
    
    # Leer y imprimir caracter
    lb $a0, 0($t2)
    li $v0, 11                   # Syscall para imprimir caracter
    syscall
    
    # Actualizar tail (buffer circular)
    addi $t0, $t0, 1             # Incrementar cola
    blt $t0, $s1, no_wrap_cola   # Si cola < buffer_tam, no hacer wrap
    move $t0, $zero              # Si no, cola = 0
no_wrap_cola:
    
    # Verificar si hemos llegado a la cabeza
    bne $t0, $t1, imprimir_loop     # Continuar si tail != head
    
buffer_vacio:
    # Imprimir nueva línea
    li $v0, 4
    la $a0, nueva_linea
    syscall
    
    # Reiniciar punteros del buffer
    sw $zero, cabeza
    sw $zero, cola
    
    j main_loop                  # Repetir proceso

# Función para obtener tiempo actual (simulado)
get_tiempo_act:
    li $v0, 30                   # Syscall para obtener tiempo (simulado)
    syscall
    srl $v0, $a0, 10             # Convertir a segundos (aproximación)
    jr $ra

# Función para leer caracter del teclado (simulado)
leer_char:
    li $v0, 12                   # Syscall para leer caracter
    syscall
    beqz $v0, no_char            # Si no hay caracter, retornar 0
    sb $v0, act_char	         # Guardar caracter leído
    li $v0, 1                    # Retornar 1 (hay caracter)
    jr $ra
no_char:
    li $v0, 0                    # Retornar 0 (no hay caracter)
    jr $ra
