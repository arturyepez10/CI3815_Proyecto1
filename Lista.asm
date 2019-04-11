### ESTRUCTURA DE DATOS: Lista Simplemente Enlazada

.data
	# Se declaran las palabras reservadas para evitar que se deban alinear
	
	answer: .word
	Head: .word
	
	# Se declaran los mensajes necesarios para el usuario
	
	msg1: .asciiz "La lista no tiene ningún elemento."
	msg2: .asciiz "¿Desea crear un nuevo nodo? Marque 1 para si y 0 para no"
	msg3: .asciiz "Se ha creado un nuevo nodo"
	msg_key: .asciiz "Elija el key de su elemento"
	
	menu1: .asciiz "¿Desea añadir otro nodo? Marque 1 para Si y 0 para No"
	
	prueba: .asciiz "La cantidad de elementos en la lista es: "
	
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
		
		
		#Ahora debe comenzar un loop para añadir nodos
		main_loop:
			#Checa el tamaño del size de la lista, si es 0 crea nodo automaticamente
			lw $a0, Head
			lw $a0, 8($a0)
			beqz $a0, Nodo
			
			#Se pregunta si desea añadir algún nodo
			la $a0, msg2
			jal print_string
			
			jal newline
			
			#Se recolecta respuesta
			la $a0, collect_answer
			jal print_string			
			li $v0, 5
			syscall
			
			#Si el valor es 0 se sale del loop y pasa al menu
			beqz $v0, main_menu
			
			jal newline
			
			#Si el valor es 1 procede a crear el nodo
			jal Nodo
			
			#Se repite el loop para ver si se añade otro nodo
			jal main_loop
			
			
		main_menu:
			
			
			
			
		

	Salida:
	li $v0, 10
	syscall
	

## FUNCIONES
	
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
	
# 1er NODO DE LISTA
Cabeza_Lista:
	#Se reserva el espacio para:
	#Dirección Primer Nodo, Direción Ultimo Nodo, Tamaño de la lista
	addi $a0, $zero, 12
	li $v0, 9
	syscall
	
	#Comenzamos el contador de Tamaño en 0
	sw $zero, 8($v0)
	
	#Guardamos la dirección reservada en la dirección de Head para su facil acceso luego
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
	lw $a1, Head
	lw  $a0, 8($a1)
	addi $a0, $a0, 1
	sw $a0, 8($a1) 	
	
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
	
	#AÑADIR CONECTAR CON EL SIGUIENTE NODO
	
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
		
	### UTIL PARA IMPRIMIR EL CONTADOR DE ELEMENTOS EN LA LISTA (A partir de la línea 137)
			#nueva linea
			jal newline
			#carga a $a1 dirección donde está guardada Cabeza_Lista
			lw $a1, Head
			#dada el contenido de $a1 lo interpreta como dirección+8 y carga ese contenido en $a2 (ese contenido es el contador)
			lw  $a2, 8($a1)
			#carga en $a0 el mensaje de prueba y lo imprime
			la $a0, prueba
			jal print_string
			#carga en $a0 el contenido de la dirección de $a2 y lo imprime
			la $a0, ($a2)
			jal print_integer
			jal newline