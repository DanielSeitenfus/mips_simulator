.eqv        PROGRAMA_EXECUTADO_SUCESSO  0
.eqv        SERVICO_IMPRIME_STRING      4
.eqv 	    SERVICO_IMPRIME_CARACTER    11
.eqv 	    SERVICO_ABRE_ARQUIVO	13
.eqv        SERVICO_ESCREVE_ARQUIVO     14
.eqv        SERVICO_TERMINA_PROGRAMA    17
.eqv        SERVICO_IMPRIME_HEX 	34

# Uso: imprime_str()
.macro imprime_str(%string)
.data  
string: .asciiz %string
.text
	li $v0, SERVICO_IMPRIME_STRING
        la $a0, string
        syscall
.end_macro

# Uso: imprime_caracter()
.macro imprime_caracter(%char)
.text
        li   $v0, SERVICO_IMPRIME_CARACTER
	li   $a0, %char
	syscall
.end_macro

# Uso: nova_linha()
.macro nova_linha()
       imprime_caracter('\n')
.end_macro

# Uso: imprime_virgula()
.macro imprime_virgula()
       imprime_str(", ")
.end_macro

# Uso: imprime_espaco()
.macro imprime_espaco()
       imprime_str(" ")
.end_macro