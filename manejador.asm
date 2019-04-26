### Manejador: Manejador de memoria 

# Importamos las funciones auxiliares
.include "aux"

.data
	# Mensajes
	msgaux: .asciiz "El Init funciona bien"
	
	# Definimos el arreglo donde se manejar� la maemoria
	memory: .space 4 #Establecemos un word como espacio incial de 4 bytes que luego varíará
.text
main:
	jal newline

### Funciones
init:
	#Inicializamos el arreglo con 
	
	
