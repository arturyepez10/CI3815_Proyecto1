 # CI3815 - Organización del Computador
 # Proyecto 1 - Manejo de memoria y estructuras de datos
 # main.asm
 # Autores:
 #   Luis Pino (15-11138)
 #   Arturo Yepez (15-11551)
 .text
   li $a0, 500
   jal init

   jal main

   li $v0,10
   syscall
   
### LIBRER�?AS DEL PROYECTO ###
 .include "manejador.asm"
 .include "Lista.asm"