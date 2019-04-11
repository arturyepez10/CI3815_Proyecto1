### ESTRUCTURA DE DATOS: Lista Simplemente Enlazada

.data
	answer: .word
	
	Head: .word

	msg1: .asciiz "La lista no tiene ningún elemento."
	msg2: .asciiz "¿Desea crear un nuevo nodo? Marque 1 para si y 0 para no"
	msg3: .asciiz "Se ha creado un nuevo nodo"
	msg_key: .asciiz "Elija el key de su elemento"
	
	collect_answer: .asciiz "Respuesta: "


	salto_de_linea: .asciiz "\n"
	

.text
	main:
		#La lista comienza vacía, por lo que se imprime mensaje de lista vacía
		la $a0, msg1
		jal print_string
		
		jal newline
		
		#Se crea nodo Cabeza/1er Nodo
		jal Cabeza_Lista
		
		
		#Al retornar $v0 contiene la dirección de espacio reservada,
		#que procedemos a guardar datos en $sp
		
		#Almacenamos en $sp
		sw $v0, ($sp)
		#Movemos el apuntador de $sp
		sub $sp, $sp, 4
		#Se inicializa el contador de elementos de la lista en $t0
		sub $t0, $zero, $zero
		
		
		#Ahora debe comenzar un loop para añadir nodos añadiendo nodos
		main_loop:
			#Se pregunta si desea añadir algún nodo
			la $a0, msg2
			jal print_string
			
			jal newline
			
			#Se recolecta respuesta
			la $a0, collect_answer
			jal print_string			
			li $v0, 5
			syscall
			
			jal newline
			
			#Movemos el valor de la respuesta a $a1
			move $a1, $v0
			
			#Si el valor es 0 señala a la etiqueta de salida
			beqz $a1, Salida
			
			#Si el valor es 1 procede a crear el nodo
			jal Nodo
			
		

	Salida:
	li $v0, 10
	syscall
	

## FUNCIONES
	
# Imprimir String
print_string:
	li $v0, 4
	syscall
	jr $ra
	
# Salto de linea
newline:
	li $v0, 4
	la $a0, salto_de_linea
	syscall
	jr $ra
	
# 1er NODO DE LISTA
Cabeza_Lista:
	#Se reserva el espacio para:
	#Dirección Primer Nodo, Direción Ultimo Nodo, Tamaño de la lista
	add $a0, $zero, 12
	li $v0, 9
	syscall
	
	#Comenzamos el contador de Tamaño en 0
	sw $zero, 8($v0)
	
	#Guardamos la dirección en memoria en la dirección Head para su facil acceso luego
	sw $v0, Head
	
	jr $ra
	
# NODO DE LISTA
Nodo:
	#Se salvan los registros a utilizar
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $ra, 12($sp)
	#----------
	
	#Sumamos 1 al size 
	lw $a0, Head+8
	addi $a0, $a0, 1
	sw $a0, Head+8	
	
	#Se reserva espacio para:
	#Elemento, Dirección del Siguiente
	add $a0, $zero, 8
	li $v0, 9
	syscall
		
	#Guardamos la dirección en $sp y movemos el registro para reubicar la cabeza de $sp
	sw $v0, ($sp)
	sub $sp, $sp, 4
	
	#Display del mensaje para pedir key del nodo
	la $a0, msg_key
	jal print_string
	
	jal newline
	
	la $a0, collect_answer
	jal print_string
	
	#Se lee la respuesta (Input debe ser entero)
	li $v0, 5
	syscall
	
	#Se guarda la respuesta en la 1era Palabra de la dirección reservada
	lw $a1, 4($sp)
	sw $v0, ($a1)
	
	#----------
	#Se recuperan las variables
	addi $sp, $sp, 4
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $ra, 12($sp)
	
	jr  $ra

##############
	#### UTIL PARA IMPRIMIR NODOS
		#Carga la palabra guardada en el stack (la palabra guardada es la dirección donde está el contenido de la key)
		lw $a0, 4($sp)
		#Carga el contenido interpretando esa palabra como la dirección donde se encuentra el contenido del key
		lw $a0, ($a0)
		#Ejecuta la lectura del contenido de la dirección en $ao
		li $v0, 1
		syscall