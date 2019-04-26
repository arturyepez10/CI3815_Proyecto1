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
	
	msgList: .asciiz "Los elementos de la lista son: "
	printedList: .asciiz "[Presione enter para continuar]"
	
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
			
			#Si el valor es mayor procede a crear el nodo
			jal Nodo
			
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
			
			la $a0, menu4
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
			addi $a3, $zero, 4
			
			#Se compara la respuesta obtenida mediante Branchs y dependiendo manda a esa función
			beq $v0, $a0, main_loop
			beq $v0, $a1, Salida
			beq $v0, $a2, print_list
			beq $v0, $a3, Salida
		

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
	#Dirección Primer Nodo, Dirección Ultimo Nodo, Cantidad de Nodos en la lista
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
	sw $ra, -12($sp)
	#----------
	
	node_creation:
		#Se reserva espacio para:
		#Elemento, Dirección del Siguiente Nodo
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
		lw $a1, 4($sp)	#Dirección del Nodo
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
		lw $ra, -8($sp)
		
		jr  $ra
	
# IMPRIMIR NODO DE LA LISTA	
print_Nodo:  #Se utiliza $a0, $a1, $t1 para pasar como parametro la dirección donde está el nodo
	#Se salvan los registros a utilizar
	sw $ra, -8($sp)
	#----------
	
	#Se asigna a $a2 el número 2 para usar para una comparación
	addi $a2, $zero, 2
	
	#Si el número del nodo actual es mayor o igual a 2 salta a regular_nodes
	bge $t1, $a2, regular_nodes
	
	# Se divide la sección en 2 branches por como deben ser interpretado los datos, en ambos casos como se interpretan
	# y cargos .los datos y los valores en sus respectivas posiciones del arreglo donde están ubicados.
	first_node_to_print:
		#Cargar en $a0 el primer campo de Head
		lw $a0, ($a1)
		#Carga en $a0 la dirección de $sp del nodo actual
		lw $a0, ($a0)
		#Carga el key del nodo en $a0
		lw $a0, ($a0)
		
		j end_print
		
	regular_nodes:
		#Carga en $a0 la dirección del $sp del nodo actual
		lw $a0, ($a1)
		#Carga el key del nodo en $a0
		lw $a0, ($a0)
		
	end_print:
		#Hace print del key del nodo, actualmente alojado en $a0
		li $v0, 1
		syscall
	
	#----------
	#Se recuperan los registros
	lw $ra, -8($sp)
	
	jr $ra

# IMPRIMIR TODOS LOS NODOS DE LA LISTA
print_list:
	#Se salvan los registros a utilizar
	sw $ra, -4($sp)
	#----------
	
	#Se accede al Head para buscar el valor de la dirección donde está alojado el primer nodo
	lw $a1, Head
	
	#Se guarda en $t0 la cantidad de nodos que posee la lista al momento
	lw $t0, 8($a1)
	
	#Se toma $t1 como contador de nodos impresos, comenzando en 0
	addi $t1, $zero, 0
	
	#Se imprime una línea en blanco
	jal newline
	
	#Imprimmos el mensaje para indicar que viene la lista, salvando el valor de $a0 para su uso posterior
	sw $a0, -8($sp)
	#---#
	la $a0, msgList
	jal print_string
	jal newline
	#---#
	lw $a0, -8($sp)
	
	#Loop para la impresión de nodos	
	loop_list:
		#Compara el valor del contador de elementos impresos con el de elementos totales para ver si sigue el loop
		beq $t0, $t1, return_PrintList
		
		#Se suma 1 al contador de nodos impresos
		addi $t1, $t1, 1
		
		#Se imprime el nodo actual
		jal print_Nodo
		
		#Imprimimos un espacio, salvando el valor de $a0 para su uso posterior 
		sw $a0, -8($sp)
		#---#
		la $a0, espacio
		jal print_string
		#---#
		lw $a0, -8($sp)
		
		# Checamos en que nodo nos encontramos y así poder interpretarlo de la forma correcta
		#Asignamos en $a2 el número 1 para una comparación
		addi $a2, $zero, 2
		
		#Si la posición del nodo es mayor o igual que la 2
		bge $t1, $a2, content_regular_node
		
		content_first_node:
			#Ponemos en $a1 la dirección donde está ubicado el 2do Nodo
			lw $a1, ($a1)
			#Nos ubicamos en el key del nodo
			lw $a1, ($a1)
			#Vamos a la casilla Dirección del Siguiente del Nodo
			addi $a1, $a1, 4
			
			j loop_list
			
		content_regular_node:
			#Nos ubicamos en el key del nodo
			lw $a1, ($a1)
			#Vamos a la casilla Dirección del Siguiente del Nodo
			addi $a1, $a1, 4
		
			j loop_list
	
	return_PrintList:
	jal newline
	
	#Imprimimos un mensaje y pedimos entrada de usuario para forzar que el usuario pueda ver la lista impresa
	jal newline
	
	la $a0, printedList
	jal print_string
	
	li $v0, 8
	syscall
	
	jal newline
	
	#----------
	#Se recuperan los registros
	lw $ra, -4($sp)
	
	j main_menu
