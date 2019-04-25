### ESTRUCTURA DE DATOS: Lista Simplemente Enlazada

.data
	# Se declaran las palabras reservadas para evitar que se deban alinear
	
	answer: .word
	Head: .word
	
	# Se declaran los mensajes necesarios para el usuario
	
	msg1: .asciiz "La lista no tiene ningún elemento."
	msg2: .asciiz "¿Desea crear un nuevo nodo? Marque 1 para si y 0 para no"
	msg3: .asciiz "Se ha creado un nuevo nodo"
	msg_key: .asciiz "Ingrese el key del elemento"
	
	menu: .asciiz "LISTA SIMPLEMENTE ENLAZADA"
	menu1: .asciiz "1) Crear un nuevo Nodo para la Lista"
	menu2: .asciiz "2) Elimina un nodo existente de la Lista"
	menu3: .asciiz "3) Imprimir Lista"
	menu4: .asciiz "4) Salir del programa"
	
	collect_answer: .asciiz "Respuesta: "

	salto_de_linea: .asciiz "\n"
	espacio: .asciiz " "
	separador: .asciiz "#---------------------------------------#"
	

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
			
			beqz $a0, label
			
			label: jal Nodo
			
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
			#Imprime el header entre separadores
			la $a0, separador
			jal print_string
			jal newline
			
			la $a0, menu
			jal print_string
			jal newline
			
			la $a0, separador
			jal print_string
			jal newline
			
			#Imprimimos las opciones a realizar del menu		
			la $a0, menu1
			jal print_string
			jal newline
			
			la $a0, menu2
			jal print_string
			jal newline
			
			la $a0, menu3
			jal print_string
			jal newline
			
			#Recolectamos la respuesta del usuario
			la $a0, collect_answer
			jal print_string			
			li $v0, 5
			syscall
			
			#Añadimos en variables los posibles valores de respuesta
			addi $a0, $zero, 1
			addi $a1, $zero, 2
			addi $a2, $zero, 3
			
			#Se compara la respuesta obtenida mediante Branchs
			beq $v0, $a0, main_loop
			beq $v0, $a1, Salida
			beq $v0, $a2, Salida 
			
			
		

	Salida:
	li $v0, 10
	syscall
	
##------------------------------
## FUNCIONES
##------------------------------
	
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
	#sw $a0, -4($sp)
	#sw $a1, -8($sp)
	sw $ra, -12($sp)
	#----------
	node_creation:
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
		
	checking_node:
		#Sumamos 1 al size de Cabeza_Lista
		lw $a1, Head
		lw  $a0, 8($a1)
		addi $a0, $a0, 1
		sw $a0, 8($a1)
		
		#Checa el tamaño del size de la lista, si es mayor que 1 procede a modificar el next del nodo anterior
		lw $a0, Head
		lw $a0, 8($a0)
		addi $a1, $zero, 1
		bgt $a0, $a1, regular_node
	
	first_node:
		#Accedemos a la dirección donde está almacenada Cabeza_Lista
		lw $a0, Head
		
		#Recuperamos la dirección reservada del nodo
		la $a1, 4($sp)
		
		#Guardamos en la primera dirección de Cabeza_Lista la dirección de memoria reservada del nodo actual
		sw $a1, ($a0)
		
		j last_node
		
	regular_node:
		#Accedo a la dirección donde está almacenado el nodo anterior
		lw $a0, 8($sp)
		
		#Recuperamos la dirección reservada del nodo actual
		lw $a1, 4($sp)
		
		#Guardamos en la 2da Palabra del Nodo anterior (el Next) la dirección de Memoria reservada del nodo actual
		sw $a1, 4($a0)
	
	last_node:
		#Accedo a la dirección donde está almacenada Cabeza_Lista
		lw $a0, Head
		
		#Recuperamos la dirección reservada del nodo actual
		la $a1, 4($sp)
		
		#Guardamos en la 2da Palabra de Cabeza_Lista la dirección actual, para convertirla en ultimo nodo
		sw $a1, 4($a0)

	#----------
	return_Nodo:
		#Se recuperan los registros tomando en cuenta la modificación al $sp
		#lw $a0, ($sp)
		#lw $a1, -4($sp)
		lw $ra, -8($sp)
		
		jr  $ra # NO ESTÁ AGARRANDO BIEN EL $ra PARA 2DO NODO (se devuelve a la 79, que es el último $ra)
		
print_Nodo:
	#Se salvan los registros a utilizar
	#sw $a0, -4($sp) #Se utiliza $a0 para pasar como parametro la dirección donde está el nodo
	sw $a1, -4($sp)
	sw $ra, -8($sp)
	#----------
	
	#Carga el contenido interpretando esa palabra como dirección donde se encuentra ubicado el key
	lw $a0, ($a0)
	#Ejecuta la lectura del contenido  de la dirección en $a0
	li $v0, 1
	syscall
	
	#----------
	#Se recuperan los registros
	#lw $a0, -4($sp)
	lw $a1, -4($sp)
	lw $ra, -8($sp)
	
	jr $ra
	
print_tree: 
	

##############
	#### UTIL PARA IMPRIMIR NODOS
		#Carga la palabra guardada en el stack (la palabra guardada es la dirección donde está el contenido de la key)
		lw $a0, 4($sp)
		#Carga el contenido interpretando esa palabra como la dirección donde se encuentra el contenido del key
		lw $a0, ($a0)
		#Ejecuta la lectura del contenido de la dirección en $a0
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
		#la $a0, prueba
		jal print_string
		#carga en $a0 el contenido de la dirección de $a2 y lo imprime
		la $a0, ($a2)
		jal print_integer
		jal newline
