# Bubble Sort en MIPS
.data
    list: .word 9, 2, 8, 4, 3, 6, 1, 7, 5, 10, 12, 11
    list_size: .word 12

.text
.globl main
    main:
        # --------------------------------------------
        #  MOSTRAR LISTA ANTES DE ORDENAR
        # --------------------------------------------
        la   $t7, list
        lw   $t8, list_size
        li   $t9, 0

        print_before:
            lw   $a0, 0($t7)
            li   $v0, 1
            syscall

            # imprimir espacio
            li   $v0, 11
            li   $a0, 32
            syscall

            addi $t7, $t7, 4
            addi $t9, $t9, 1
            blt  $t9, $t8, print_before

            # salto de línea
            li   $v0, 11
            li   $a0, 10
            syscall

        # --------------------------------------------
        #  ORDENAR LISTA CON BUBBLE SORT
        # --------------------------------------------
        la   $t0, list         # $t0 apunta al inicio de la lista
        lw   $t1, list_size    # $t1 contiene el tamaño de la lista
        addi $s0, $t1, -1      # $s0 = list_size - 1 (límite del bucle interno)

        main_loop:
            li   $t3, 0            # $t3 = índice interno (j)
            li   $t4, 0            # $t4 = indicador de intercambio

        inner_loop:
            # cargar el elemento actual y el siguiente
            lw   $t5, 0($t0)       # $t5 = list[j]
            lw   $t6, 4($t0)       # $t6 = list[j+1]

        # comparar y ordenar
        bge  $t5, $t6, no_swap # si list[j] >= list[j+1], no intercambiar
        sw   $t6, 0($t0)       # list[j] = list[j+1]
        sw   $t5, 4($t0)       # list[j+1] = list[j]
        li   $t4, 1            # marcar que se hizo un intercambio

        no_swap:
            addi $t3, $t3, 1       # incrementar j
            addi $t0, $t0, 4       # mover al siguiente elemento

            # verificar si hemos llegado al final del bucle interno
            blt  $t3, $s0, inner_loop

            # reiniciar el puntero de la lista y verificar si se hizo un intercambio
            la   $t0, list
            bne  $t4, $zero, main_loop

        # --------------------------------------------
        #  MOSTRAR LISTA DESPUÉS DE ORDENAR
        # --------------------------------------------
        la   $t7, list
        lw   $t8, list_size
        li   $t9, 0

        print_after:
            lw   $a0, 0($t7)
            li   $v0, 1
            syscall

            # imprimir espacio
            li   $v0, 11
            li   $a0, 32
            syscall

            addi $t7, $t7, 4
            addi $t9, $t9, 1
            blt  $t9, $t8, print_after

            # salto de línea
            li   $v0, 11
            li   $a0, 10
            syscall

        # --------------------------------------------
        #  FIN DEL PROGRAMA
        # --------------------------------------------
        li   $v0, 10
        syscall