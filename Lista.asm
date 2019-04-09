### ESTRUCTURA DE DATOS: Lista Simplemente Enlazada

.data
	msg1: .asciiz "La lista no tiene ningún elemento."
	msg2: .asciiz "¿Desea crear un nuevo nodo? Marque 1 para si y 0 para no"
	msg3: .asciiz "Se ha creado un nuevo nodo"
	msg_key: .asciiz "Elija el key de su elemento"
	
	collect_answer: .asciiz "Respuesta= "
	answer: .word


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
			move $v0, $a1
			
			#Si el valor es 0 señala a la etiqueta de salida
			beqz $a1, Salida
			
			#Si el valor es 1 procede a crear el nodo
		

	Salida:
	li $v0, 10
	syscall
	

## Funciones
	
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
	#Dirección Primer Nodo, Direción Ultimo Nodo, Número de Elementos en Lista
	add $a0, $zero, 12
	li $v0, 9
	syscall
	jr $ra
	
# NODO DE LISTA
Nodo:
	#Se salvan las variables
	sw $a0, 4($sp)
	#----------

	#Se reserva espacio para:
	#Elemento, Dirección de Siguiente
	add $a0, $zero, 8
	li $v0, 9
	syscall
	
	#----------
	#Se recuperan las variables
	lw $a0, 4($sp)
	
	jr  $ra