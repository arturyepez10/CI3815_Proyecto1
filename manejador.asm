### TAD_Manejador: Manejador de memoria 
.data	
	# Variables base
	InitMax: .word 500
	size: .word # Cantidad de memoria que solicita el usuario
	
	# Auxiliares
	salto_de_linea: .asciiz "\n"
	msg1: .asciiz "La prueba corre"
		
	
	# Mensajes de error
	msginit1: .asciiz "[ERROR] La cantidad de memoria a reservar no puede ser menor a 1"
	msginit2: .asciiz "[ERROR] La cantidad de memoria a reservar es superior al maximo permitido de 500"
	msgmalloc1: .asciiz "[ERROR] No se pudo realizar la reserva de memoria"
	
	# Definimos el arreglo donde se manejar� la maemoria
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
	
	# Guardamos el espacio de memoria nuevo
	li $v0,9
	syscall	
	
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
	beq $a0, 1, Error_Init1
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
	la $a0, msginit1
	jal print_string
	jr $ra
	
