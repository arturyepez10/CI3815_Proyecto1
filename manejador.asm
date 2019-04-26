### TAD_Manejador: Manejador de memoria 
.data	
	# Auxiliares
	salto_de_linea: .asciiz "\n"
	msg1: .asciiz "La prueba corre"
	Error_init: .word	
	# Mensajes de error
	
	
	# Definimos el arreglo donde se manejar� la maemoria
	size: .word # Cantidad de memoria que solicita el usario
	memory: .space 4 #Establecemos un word como espacio incial de 4 bytes que luego varíará
.text
main:
	# Creamos el indice de $t0 
	la $t0, memory
	
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
	slt  $t1,$t2,1
	beq $t1,0, SendToPerror_init
	
	while:
		# Cargamos en t7 el valor de size y hacemos la verificación.
		# Cuando el indice sea igual al tamaño del arreglo
		la $t7,size
		beq $t0, $a0, exit
		
		
	
	exit: jr $ra
	
	SendToPerror_init:
		# Cargamos el codigo de error en $a1 y lo pasamos a perror
		li $a1,1
		jal perror
		jr $ra
	
		
malloc:

free:

perror:
	# Hacemos la verificación de errores por cada uno
	
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
### Funciones de error
#-----------------------
error_init1:

