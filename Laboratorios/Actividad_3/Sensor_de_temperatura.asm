.data
SensorControl: .word 0       # Registro de control (0x2 para inicializar)
SensorEstado:  .word 0       # 0=No listo, 1=Listo, -1=Error
SensorDatos:   .word 0       # Dato de temperatura
TimeOut: .asciiz "TimeOut: Error en la Inicialización, Delvuelto -1."
InicializadoControl: "Sensor de Control: Inicializado."
ExitoInicializadoEstado: .asciiz "Sensor de Estado: Inicializado."
ErrorInicializadoEstado: .asciiz "Sensor de Estado: Error al inicializar."
ValorTemp: "Valor de la Temperatura: "
ValorCod: "Valor de Código: "
Nueva_linea:    .asciiz "\n"

.text
InicializarSensor:
    # Guardar registros
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    # Inicializar contador de delay en $s1 de (Supongamos) 10 ms, si se alcanza devuelve -1 en TimeOut
    li $s1, 10            # Cargamos el valor directamente

    # Escribir 0x2 en SensorControl
    li $t0, 0x2
    la $t1, SensorControl
    sw $t0, 0($t1)
    
    # Muestra mensaje por pantalla de la inicialización de SensorControl
    li $v0, 4
	la $a0, InicializadoControl
	syscall
	
	li $v0, 4
	la $a0, Nueva_linea
	syscall

    # Esperar respuesta del sensor
    la $s0, SensorEstado

esperar_inicializacion:
	# Se guarda la dirrección de SensorEstado en $t0 ($t0 = SensorEstado)
    lw $t0, 0($s0)
    # Se chequea el estado de SensorEstado
    beq $t0, 1, inicializado
    beq $t0, -1, error_inicializacion

    # Simular el paso del tiempo/cambio de estado: Decrementar contador y verificar timeout
    addi $s1, $s1, -1
    blez $s1, timeout
    
    # Después del "delay", actualizamos manualmente el estado
    # Esto simularía que el hardware completó la inicialización (De igual forma se puede simular mientras se ejecuta)
    # Supongamos que devuelve el valor 1 de listo despues de esperar 3 ms
    bge $s1, 8, senal_aun_no_recibida
	li $t3, 1
    sw $t3, 0($s0)           # Forzar estado = 1 (éxito)
   
senal_aun_no_recibida:
    # Volver a Esperar 
    j esperar_inicializacion

inicializado:
	# Muestra mensaje por pantalla de la exitosa inicialización de SensorEstado
	li $v0, 4
	la $a0, ExitoInicializadoEstado
	syscall
	# Devuelve valor 1 como exito
    li $v0, 1
    j fin_inicializar

error_inicializacion:
	# Muestra mensaje por pantalla de el error de inicialización de SensorEstado
	li $v0, 4
	la $a0, ErrorInicializadoEstado
	syscall
	# Devuelve valor -1 como error
    li $v0, -1
    j fin_inicializar

timeout:
	# Al alcanzar el TimeOut, el programa devuele -1
    li $v0, -1
    # Muestra mensaje por pantalla del error
    li $v0, 4
	la $a0, TimeOut
	syscall

fin_inicializar:
    # Restaurar registros
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    
    li $v0, 4
	la $a0, Nueva_linea
	syscall

# Procedimiento: LeerTemperatura
# Descripción: Lee el valor de temperatura del sensor
# Retorna: $v0 = valor de temperatura
#          $v1 = código de resultado (0 = éxito, -1 = error)
LeerTemperatura:
    # Guardar registros en la pila
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    # Verificar estado del sensor (Si ha sido inicializado correctamente)
    la $s0, SensorEstado
    lw $t0, 0($s0)
    
    beq $t0, 1, leer_dato     # Si estado == 1, leer dato
    li $v0, 0                 # Si no está listo, retornar error
    li $v1, -1
    j fin_leer
    
leer_dato:
    # Leer valor de temperatura
    la $s0, SensorDatos
    # (ponemos valor de ejemplo en SensorDatos)
    li $t0, 23
    sw $t0, 0($s0)
    # Leemos el valor en SensorDatos y devolvermos exito
    lw $v0, 0($s0)            # $v0 = valor de temperatura
    li $v1, 0                 # $v1 = 0 (éxito)
    
fin_leer:
    # Restaurar registros de la pila
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8

    # Mostramos por pantalla los valores
   	# Guardamos el valor de $v0 (El resultado de la temperatura)
   	move $t2, $v0
   	
    li $v0, 4
	la $a0, ValorTemp
	syscall
	
    move $a0, $t2
    li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, Nueva_linea
	syscall
	
	li $v0, 4
	la $a0, ValorCod
	syscall
	
    li $v0, 1
    move $a0, $v1
	syscall