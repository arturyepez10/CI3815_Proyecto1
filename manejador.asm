### TAD_Manejador: Manejador de memoria 
.data	
	# Variables base
	InitMax: .word 500
	size: .word # Cantidad de memoria que solicita el usuario
	blocksize: .word 
	memorystart: .word
	refstart: .word
	test: .byte
	started_manager: .word 1 
	# Auxiliares
	
	
	# Mensajes de error
	msginit1: .asciiz "[ERROR: Init01] La cantidad de memoria a reservar no puede ser menor a 1"
	msginit2: .asciiz "[ERROR: Init02] La cantidad de memoria a reservar es superior al maximo permitido de 1000"
	msgmalloc1: .asciiz "[ERROR: Malloc01] No se pudo realizar la reserva de memoria"
	msgfree1: .asciiz "[ERROR: Free01] El espacio de memoria solicitado ya está vacío"
	msggenerico: .asciiz "[ERROR] El manejador no ha sido inicializado"

	# Definimos el arreglo donde se manejar� la maemoria
	Ref_List: .byte 0:500
	memory: .byte 1 #Establecemos un word como espacio incial de 4 bytes que luego varíará

.text
	main_manejador:
		# Creamos el indice de $t0 y un valor de referencia de apuntador para el arreglo de memoria
		la $t0, memory
		sw $t0 memorystart

		# Creamos el indice de $t1 y un valor de referencia de apuntador para el arreglo de rreferencia
		la $t1, Ref_List
		sw $t1, refstart

		# Leemos el tamaño de la memoria a reservar
		li $v0,5
		syscall
		
		sw $v0, size

		# Cargamos en $a0 el valor de size para pasarlo a Init y llamamos a la función
		move $a0, $v0
		
		jal init

		jr $ra
	#---------------
	### Funciones
	#--------------
	init:
		#Verifincamos que la cantidad de bytes sea mayor igual que 1
		li $t3,1
		slt  $t2,$a0,$t3
		
		beq $t2,1, SendToPerror_init1


		# Verificamos que no sobrepase la cota superior
		lw $t4,InitMax
		sgt $t2,$a0,$t4
		beq $t2,1, SendToPerror_init2

		# Guardamos el espacio de memoria nuevo
		li $v0,9
		syscall	

		# Asignamos el nuevo inicio del arreglo a $t0
		la $t0, ($v0)
	
		# Se hace un ciclo donde se rellena con 0 todo el espacio reservado
		la $t5, 0
		li $t6,-1

		# Ciclo para reservar la memoria
		while1:
			beq $t5,$a0,while_exit1 #Condición de salida
			addi $t5,$t5,1 #Sumamos el contador
			
			sb $t6,($t0) 
			addi $t0,$t0,1
			
			j while1

		while_exit1: 
			# Devolvemos el apuntador al inicio de nuestro arreglo
			sub $t0,$t0,$t5
		
		li $t5,0 #Reinicio del contador

		# Ciclo para definir el espacio de referencia
		while2:
			beq $t5,$a0,while_exit2 #Condición de salida
			addi $t5,$t5,1 #Sumamos el contador
			
			sb $t6,Ref_List($t1)
			addi $t1,$t1,1
			
			j while2

		while_exit2: 
			# Devolvemos el apuntador al inicio de nuestro arreglo
			sub $t1,$t1,$t5
		
		li $t6,2
		sw $t6, started_manager
	jr $ra

	malloc:
		lw $t6, started_manager

		beq $t6,1,sendtoperror_malloc2
		
		# Verificamos usando la ref_list que hay espacio suficiente
		la $s1, size # Cargamos en una variable el tamaño de nuestro arreglo
		
		#se salvan registros a utilizar
		sw $ra, -4($sp)
		
		jal malloc_linear_search
		
		#se salvan registros a utilizar
		lw $ra, -4($sp)
		
		beq $t4,$zero,sendtoperror_malloc1 #Si no cosniguió espacio libre, lanza un error

		la $t1,($s0) # Cargamos la dirección inicial en el registro del arreglo
		la $t2, 0

		while5:
			# Rellenamos con 1 en la ref_list el bloque solciitado para denotar que ese
			# espacio de memoria está reservados
			beq $t1,$s0,while_exit5

			sb $t1,1
			addi $t1,$t1,1
			j while5

			while_exit5:
				# Cargamos en $s2 la dirección de retorno de la función malloc sumando
				# el contador del while inicial con la dirección inicial del arreglo
				add $s2,$t0,$t3 
		
		la $v0,($s2)

	jr $ra
	
	
	free:
		li $t5, 1
		lw $t6, started_manager

		beq $t5,$t6,sendtoperror_malloc2

		# Calculamos la dirección de reflist donde está el bloque de memoria solicitado		
		la $t3,memorystart
		la $t4, refstart
		
		sub $t5, $a0, $t3 #Cantidad de bytes que hay del incio al bloque solicitado
		add $t1,$t5,$t4 #Sumamos para tener la dirección de la reflist

		lw $t2, ($t1)
		beq $t2,-1, sendtoperror_free1 # Si el espacio de memoria esta vacío, no hay anda que borrar

		#se salvan registros a utilizar
		sw $ra, -4($sp)
		
		jal freespacecounter
		
		#se salvan registros a utilizar
		lw $ra, -4($sp)

		sw $t6, blocksize

		# Sabiendo cuanto hay que borrar en cada arreglo de memoria, procedemos a eliminar
		la $t0,($a0)
		
		#se salvan registros a utilizar
		sw $ra, -4($sp)
		
		jal free_memory
		
		#se salvan registros a utilizar
		lw $ra, -4($sp)
		
		#se salvan registros a utilizar
		sw $ra, -4($sp)

		jal free_reference
		
		#se salvan registros a utilizar
		lw $ra, -4($sp)

	perror:
		# Hacemos la verificación de errores por cada uno
		beq $a0, -1, error_init1
		beq $a0, -2, error_init2
		beq $a0, -3, error_malloc1
		beq $a0, -4, error_free1
		beq $a0, -5, error_generico

		jr $ra

	#-----------------------
	### Subfunciones del Init
	#-----------------------	

	SendToPerror_init1:
		# Cargamos el codigo de error en $a1 y lo pasamos a perror
		li $a1,-1
		j perror

	SendToPerror_init2:
		# Cargamos el codigo de error en $a1 y lo pasamos a perror
		li $a1,-2
		j perror

	#-----------------------
	### Subfunciones del malloc
	#-----------------------
	malloc_linear_search:
		la $t5, 0
		la $t3, 0
		li $t4,0 #Verificador que consiguió espacio. Si al final de la función es cero, no sonsiguió

		while3:
			beq $t5,$s1,while_exit3 #Condición de salida
			addi $t5,$t5,1 #Sumamos el contador
			
			sb $t1,test
			lb $t2,test
			bne $t2,1, whileverifyspace
			addi $t2,$t2,1

			j while3

			while_exit3:
				jr $ra

		
		whileverifyspace:
			la $s0, ($t2) #Salvamos la dirección incial del espacio tentativo

			while4:
				beq $t3,$a0,while_exit4
				addi $t3,$t3,1 #Sumamos el contador

				sb $t1,test
				lb $t2,test
				bne $t2,-1, gobackwhile3
				j while4

				while_exit4:
					li $t4,1 # Significa que el espacio está disponible
					jr $ra
		gobackwhile3:
			j while3

	sendtoperror_malloc1:
		li $a0,-3
		j perror

	sendtoperror_malloc2:
		li $a0,-5
		j perror

	#-----------------------
	### Subfunciones del free
	#-----------------------
	sendtoperror_free1:
		li $a0,-4
		j perror

	freespacecounter:
		la $t6,0 # Definimos el contador
		la $t7, ($t1) # Salvar mi dirección inicial

		while6:
			lw $t5,($t1)
			beq $t5,-1,while_exit6
			addi $t6,$t6,1
			addi $t1,$t1,1

			while_exit6:
				sub,$t1,$t1,$t6 #restauramos el indice original del arreglo
				jr $ra

	free_memory:
		lw $t2, blocksize
		li $t5,-1
		while7:
			beq $t2,0,while_exit7
			subi $t2,$t2,1

			sw $t5,($t0)
			addi $t0,$t0,1
			j while7

			while_exit7:
				lw $t2, blocksize
				sub $t0,$t0,$t2
				jr $ra
	
	free_reference:
		lw $t2, blocksize
		li $t5,-1
		while8:
			beq $t2,0,while_exit8
			subi $t2,$t2,1

			sb $t5,($t1)
			addi $t1,$t1,1
			j while8

			while_exit8:
				lw $t2, blocksize
				sub $t1,$t1,$t2
				jr $ra
				
	#-----------------------
	### Funciones de error
	#-----------------------
	error_init1:
	#se salvan registros a utilizar
	sw $ra, -4($sp)
	#----------
		la $a0, msginit1
		jal print_string
		jal newline
	#----------
	#se salvan registros a utilizar
	sw $ra, -4($sp)
	
	

	error_init2:
	#se salvan registros a utilizar
	sw $ra, -4($sp)
	#----------
		la $a0, msginit2
		jal print_string
		jal newline
	#se salvan registros a utilizar
	sw $ra, -4($sp)

	error_malloc1:
	#se salvan registros a utilizar
	sw $ra, -4($sp)
		la $a0, msgmalloc1
		jal print_string
		jal newline
	#se salvan registros a utilizar
	sw $ra, -4($sp)
	
	error_free1:
	#se salvan registros a utilizar
	sw $ra, -4($sp)
		la $a0, msgfree1
		jal print_string
		jal newline
	#se salvan registros a utilizar
	sw $ra, -4($sp)

	error_generico:
	#se salvan registros a utilizar
	sw $ra, -4($sp)
		la $a0, msggenerico
		jal print_string
		jal newline
	#se salvan registros a utilizar
	sw $ra, -4($sp)
