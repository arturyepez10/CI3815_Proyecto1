### TAD_Manejador: Manejador de memoria 
.data	
	# Variables base
	InitMax: .word 200
	size: .word # Cantidad de memoria que solicita el usuario
	counter: .word 0

	# Auxiliares
	salto_de_linea: .asciiz "\n"
	msg1: .asciiz "La prueba corre"
		
	
	# Mensajes de error
	msginit1: .asciiz "[ERROR] La cantidad de memoria a reservar no puede ser menor a 1"
	msginit2: .asciiz "[ERROR] La cantidad de memoria a reservar es superior al maximo permitido de 1000"
	msgmalloc1: .asciiz "[ERROR] No se pudo realizar la reserva de memoria"
	
	# Definimos el arreglo donde se manejar� la maemoria
	Ref_List: .byte 0:1000
	memory: .byte 1 #Establecemos un word como espacio incial de 4 bytes que luego varíará
.text
	main:
		# Creamos el indice de $t0 
		la $t0, memory
		la $t1, Ref_List

		# Leemos el tamaño de la memoria a reservar
		li $v0,5
		syscall
		sw $v0, size

		# Cargamos en $a0 el valor de size para pasarlo a Init y llamamos a la función
		move $a0, $v0
		jal init

	#---------------
	### Funciones
	#--------------
	init:
		#Verifincamos que la cantidad de bytes sea mayor igual que 1
		slt  $t2,$a0,1
		beq $t2,0, SendToPerror_init1

		# Verificamos que no sobrepase la cota superior
		lw $t4,InitMax
		sgt $t2,$a0,$t4
		beq $t2,1, SendToPerror_init2

		# Guardamos el espacio de memoria nuevo
		li $v0,9
		syscall	
	
		# Se hace un ciclo donde se rellena con 0 todo el espacio reservado
		la $t5, counter
		li $t6,-1

		while:
			beq $t5,$a0,exit #Condición de salida
			addi $t5,$t5,1 #Sumamos el contador
			
			sw $t6,myarray($t0)
			addi $t0,$t0,4

			j while

		exit: 
			jr $ra

	malloc:


	free:


	perror:
		# Hacemos la verificación de errores por cada uno
		beq $a0, -1, error_Init1
		beq $a0, -2, error_Init2

	#-----------------------
	### Funciones auxiliares
	#-----------------------

	# Imprimir String
	print_string:
		li $v0, 4
		syscall
		jr $ra

	# Imprimir Entero
	print_integer:
		li $v0, 1
		syscall
		jr $ra

	# Salto de linea
	newline:
		li $v0, 4
		la $a0, salto_de_linea
		syscall
		jr $ra

	#-----------------------
	### Subfunciones del Init
	#-----------------------	

	SendToPerror_init1:
		# Cargamos el codigo de error en $a1 y lo pasamos a perror
		li $a1,-1
		jal perror
		jr $ra

	SendToPerror_init2:
		# Cargamos el codigo de error en $a1 y lo pasamos a perror
		li $a1,-2
		jal perror
		jr $ra


	#-----------------------
	### Funciones de error
	#-----------------------
	error_init1:
		la $a0, msginit1
		jal print_string
		jr $ra

	error_init2:
		la $a0, msginit2
		jal print_string
		jr $ra