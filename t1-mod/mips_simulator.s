.include "macros.s"
.text
.globl      main

#Passos do MIPS
# 1) BUSCA:
#	IR = memoria_text[PC]	
#	PC = PC+4 (PC guarda a instrucao a ser executada, assim, l�-se a instru��o refer�ncia a posi��o PC no vetor
# 2) DECODIFICA��O:
#	(Essa parte j� est� desenvolvida, s� adaptar para o nosso caso)
#	A = registradores[IR[25-21]]
#	B = registradores[IR[20-16]] (Acredito que isso seja os dois registradores que ser�o manipulados, caso a instru��o use 2)
#	UALSa�da = PC + extens�o de sinal (IR[15-0] << 2) (UALSa�da, o que �?)
# 3) EXECU��O, C�LCULO DO ENDERE�O DE MEM�RIA OU EFETIVA��O DO DESVIO CONDICIONAL:
#    A) Refer�ncia � mem�ria:
#	UALSa�da = A + extens�o de sinal IR[15-0]
#    B) Instru��o aritm�tica ou l�gica (Tipo R)
#	UALSa�da = A op B
#    C) Desvio condicional:
#	Se (A==B) ent�o PC=UALSa�da
#
#
#
#
main:
	# Reserva espaco na pilha para variaveis
	addiu  $sp, $sp, -8
				          
	# Abertura do arquivo TEXT.BIN
	jal ABRE_ARQUIVO_TEXT
	     
ABRE_ARQUIVO_TEXT:

	# $v0 possui descritor do arquivo
	la     $a0, nome_arquivo_text  # $a0 <- endereco da string com o nome do arquivo
	li     $a1, 0 		       # Flags: 0 - indica modo de leitura
	li     $a2, 0 		       # Modo - eh ignorado pelo servico
	li     $v0, SERVICO_ABRE_ARQUIVO	
	syscall         
      	
	# Salva retorno da leitura em $sp
	sw     $v0, 0($sp) 	         # salva o retorno da leitura do arquivo 
	slt    $t0, $v0, $zero           # se tiver algum erro, termina o programa
	bne    $t0, $zero, Fim_Programa  # caso contrario, continua a execucao
        
	imprime_str("\nInforme o numero de instrucoes a executar: ")
      
	jal LEITURA_INTEIRO      # chama funcao para ler
    	la  $t6, 0($v0)	     	 # carrega o inteiro lido em $t6     
    	li  $t7, 0	     	 # inicializa contador em $t7 = 0
    	
    	jal ARMAZENA_TEXT        # pula para funcao que guarda no vetor
    	
ARMAZENA_TEXT:

	# Leitura das instrucoes
	lw     $a0, 0($sp)          # $a0 <- o descritor do arquivo
	la     $a1, memoria_text    # $a1 <- endereco do buffer de entrada
	li     $a2, 4               # $a2 <- numero de bytes que serao lidos
	li     $v0, SERVICO_LEITURA_ARQUIVO # $v0 <- numero de bytes lidos
	syscall
       	
    	# Verifica se alguma instrucao foi lida
    	slti   $t0, $v0, 4	    	# Se $v0 (caracteres lidos) eh menor que 4, $t0 = 1
    	bnez   $t0, ABRE_ARQUIVO_DATA   # caso nao lidos 4 bytes, encerra
	jal ARMAZENA_TEXT

ABRE_ARQUIVO_DATA:

	# $v0 possui descritor do arquivo
	la     $a0, nome_arquivo_data  # $a0 <- endereco da string com o nome do arquivo
	li     $a1, 0 		       # Flags: 0 - indica modo de leitura
	li     $a2, 0 		       # Modo - eh ignorado pelo servico
	li     $v0, SERVICO_ABRE_ARQUIVO	
	syscall         
      	
	# Salva retorno da leitura em $sp
	sw     $v0, 0($sp) 	         # salva o retorno da leitura do arquivo 
	slt    $t0, $v0, $zero           # se tiver algum erro, termina o programa
	bne    $t0, $zero, Fim_Programa  # caso contrario, continua a execucao
        
    	jal ARMAZENA_DATA        # pula para funcao que guarda no vetor
    	
ARMAZENA_DATA:

	lw     $a0, 0($sp)          # $a0 <- o descritor do arquivo
	la     $a1, memoria_data    # $a1 <- endereco do buffer de entrada
    	li     $a2, 4        	    # $a2 <- numero de bytes que serao lidos
    	li     $v0, SERVICO_LEITURA_ARQUIVO # $v0 <- numero de bytes lidos
    	syscall
       	
    	# Verifica se alguma instrucao foi lida
    	slti   $t0, $v0, 4	    	# Se $v0 (caracteres lidos) eh menor que 4, $t0 = 1
    	bnez   $t0, Processa_Instrucoes	# caso nao lidos 4 bytes, encerra
    	jal   ARMAZENA_DATA

LEITURA_INTEIRO:

	li $v0, 5	# codigo para ler um inteiro
	syscall		# executa a chamada do SO para ler
	jr $ra		# volta para o lugar de onde foi chamado

Fim_Programa:

	addiu  $sp, $sp, 8
    	li     $a0, 0
    	li     $v0, SERVICO_TERMINA_PROGRAMA
	syscall

Processa_Instrucoes:

	#Verifica se o contador eh igual a qnt de IR (int) informada
	beq $t6, $t7, Fim_Programa # chama fim do programa
	addi $t7, $t7, 1	   # incrementa o contador
	j Processa_Instrucoes

.data

.align 2

RS:	.space 1
RT:  	.space 1
RD:  	.space 1   
SHAMT:  .space 1
FUNCT:  .space 1
Const16:.space 4
Const26:.space 4

#Variaveis do SIMULADOR

.align 2
memoria_text:			.space 4096
memoria_data:			.space 4096
memoria_pilha:			.space 4096
endereco_inicial_text:		.word 0x00400000
endereco_final_text:		.word 0x00400FFF
endereco_inicial_data:		.word 0x10010000
endereco_final_data:		.word 0x10010FFF
endereco_inicial_pilha:		.word 0x7FFFDFFD
endereco_final_pilha:		.word 0x7FFFEFFC

# Ficheiros de entrada:
nome_arquivo_text: 		.asciiz "text.bin"
nome_arquivo_data: 		.asciiz "data.bin"

#Campos intrucoes em IR
campo_op:			.space 4
campo_rs:			.space 4
campo_rt:			.space 4	
campo_rd:			.space 4
campo_imm16:			.space 4
campo_imm26:			.space 4
campo_shamt:			.space 4

banco_registradores:
reg_zero:   .space 4
reg_at:     .space 4
reg_v0:     .space 4
reg_v1:     .space 4
reg_a0:     .space 4
reg_a1:     .space 4
reg_a2:     .space 4
reg_a3:     .space 4
reg_t0:     .space 4
reg_t1:     .space 4
reg_t2:     .space 4
reg_t3:     .space 4
reg_t4:     .space 4
reg_t5:     .space 4
reg_t6:     .space 4
reg_t7:     .space 4
reg_t8:     .space 4
reg_t9:     .space 4
reg_s0:     .space 4
reg_s1:     .space 4
reg_s2:     .space 4
reg_s3:     .space 4
reg_s4:     .space 4
reg_s5:     .space 4
reg_s6:     .space 4
reg_s7:     .space 4
reg_sp:     .space 4
reg_gp:     .space 4
reg_fp:     .space 4
reg_ra:     .space 4
reg_k0:     .space 4
reg_k1:     .space 4

#Contador de programa
pc:				.space 4	
#Registrador de instru��o
IR:				.space 4

	
