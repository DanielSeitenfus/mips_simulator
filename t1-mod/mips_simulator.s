.include "macros.s"
.text
.globl      main

main:
	addiu  	$sp, $sp, -8

	la     	$t0, banco_registradores    # Carrega banco_registradores em $t0
	la     	$t1, sp			    # Carrega dado inicial de $sp em $t1
	sw     	$t1 ,116($t0)		    # banco_registradores[29] recebe $sp
	
	la     	$t0, pc			    # Carrega endereco da variavel PC em $t0
	lw     	$t1, endereco_inicial_text  # $t1 recebe endereco inicial (0x00004000)
	sw     	$t1, 0($t0)		    # PC recebe valor inicial (0x00004000)
	
	##### Abertura do arquivo TEXT.BIN
	la     	$a0, nome_arquivo_text      # $a0 <- endereco da string com o nome do arquivo
	li     	$a1, 0 		            # Flags: 0 - indica modo de leitura
	li     	$a2, 0 		            # Modo - ignorado pelo servico
	jal ABRE_ARQUIVO_TEXT
	
	##### Armazena dados na memoria_text
	lw     	$a0, 0($sp)          	    # $a0 <- o descritor do arquivo
	la     	$a1, memoria_text    	    # $a1 <- endereco do buffer de entrada
	li     	$a2, 4               	    # $a2 <- numero de bytes que serao lidos
	jal ARMAZENA_TEXT
	
	##### Abertura do arquivo DATA.BIN
	la     	$a0, nome_arquivo_data 	    # $a0 <- endereco da string com o nome do arquivo
	li     	$a1, 0 		       	    # Flags: 0 - indica modo de leitura
	li     	$a2, 0 			    # Modo - ignorado pelo servico
	jal ABRE_ARQUIVO_DATA
	
	##### Armazena dados na memoria_data
        lw     	$a0, 0($sp)          	    # $a0 <- o descritor do arquivo
	la     	$a1, memoria_data    	    # $a1 <- endereco do buffer de entrada
	li     	$a2, 4        	    	    # $a2 <- numero de bytes que serao lidos
	jal ARMAZENA_DATA
	
	##### Solicita ao usuario numero de instrucoes a executar
	IMPRIME_STRING("\nInforme o numero de instrucoes a executar: ")
        li     	$v0, 5			    # Codigo para ler um inteiro
	syscall				    # Executa SYSCALL para leitura  

	##### Argumentos para processar intrucoes
	la     	$a1, IR			    # IR
	la     	$a2, memoria_text	    # memoria_text
	move   	$a3, $v0	     	    # CONTADOR DE INTRUCOES ($a3 = valor lido em $v0)
	jal    	Processa_Instrucoes	    # Procedimento responsavel pela execucao das instrucoes
	jal    	Fim_Programa		    # Apos processar instrucoes, encerra o programa
	
ABRE_ARQUIVO_TEXT:
	li     	$v0, SERVICO_ABRE_ARQUIVO    # $v0 armazena descritor do arquivo	
	syscall         
	sw     	$v0, 0($sp) 	             # salva o retorno da leitura em 0($sp) 
	slt    	$t0, $v0, $zero              # $t1 = 1, caso ocorra erro na abertura
	bne    	$t0, $zero, Fim_Programa     # verifica $t1; se $t1 != 0, encerra
        jr     	$ra
    	  
ARMAZENA_TEXT:
	li     	$v0, SERVICO_LEITURA_ARQUIVO # $v0 <- numero de bytes lidos
	syscall
	add    	$a1, $a1, $a2		     # Incrementa endereco do vetor
    	slti   	$t0, $v0, 4		     # Se nao foram lidos 4 bytes, $t0 = 1
    	beqz   	$t0, ARMAZENA_TEXT   	     # Enquanto $t0 = 0, faz a leitura e guarda no vetor    	
	jr     	$ra

ABRE_ARQUIVO_DATA:
	li     	$v0, SERVICO_ABRE_ARQUIVO    # $v0 possui descritor do arquivo	
	syscall         
	sw     	$v0, 0($sp) 	             #  salva o retorno da leitura em 0($sp) 
	slt    	$t0, $v0, $zero              # se tiver algum erro, termina o programa
	bne    	$t0, $zero, Fim_Programa     # caso contrario, continua a execucao
	jr     	$ra
    	
ARMAZENA_DATA:
    	li     	$v0, SERVICO_LEITURA_ARQUIVO # $v0 <- numero de bytes lidos
    	syscall
	add    	$a1, $a1, $a2 		    # Incrementa endereco do vetor
    	slti   	$t0, $v0, 4	    	    # Se nao foram lidos 4 bytes, $t0 = 1
    	beqz   	$t0, ARMAZENA_DATA	    # Enquanto $t0 = 0, faz a leitura e guarda no vetor
    	jr     	$ra

Processa_Instrucoes:

	la     	$a0, pc			    # Carrega PC em $a0
	lw     	$a1, pc			    # Carrega conteudo de PC em $a1
	add    	$a1, $a1, 4		    # Incrementa conteudo de PC
	sw     	$a1, 0($a0)		    # Armazena novo conteudo em PC
	lw     	$a1, 0($a0)		    # IR (guarda instrucao atual)
	add    	$a2, $a2, 4 		    # Vetor de texto: memoria_text
	
	# Isola o OPCODE (32bits - 6) = 26 bits
	srl    	$t0, $a1, 26		    # $t0 = 6 primeiros bits da instrucao (IR)
       
      	##### Decodificacao das instrucoes
        jal    	isola_CAMPOS_R
        jal    	TIPO_R        	 
        jal    	isola_CAMPOS_J
        jal    	TIPO_J
        jal    	isola_CAMPOS_I
        jal    	TIPO_I
        	
	# Verifica se o contador equivale ao numero de instrucoes informado
	addiu   $a3, $a3, -1	            # Decrementa o contador
	bnez    $a3, Processa_Instrucoes    # Enquanto contador != 0, continua
	jal 	Fim_Programa

isola_CAMPOS_R:	
	la 	$t1, campo_rs
	la 	$t2, campo_rt
	la 	$t3, campo_rd
	la 	$t4, campo_shamt
	la 	$t5, campo_funct
	
	la 	$t6, 0		# Variavel auxiliar
	sll    	$t6, $a1, 6	# RS
	srl   	$t6, $t6, 27	# RS
	sw     	$t6, 0($t1)	# RS
	 
	sll    	$t6, $a1, 11	# RT
	srl    	$t6, $t6, 27	# RT
	sw     	$t6, 0($t2)	# RT
	
	sll     $t6, $a1, 16	# RD
	srl     $t6, $t6, 27	# RD
	sw      $t6, 0($t3)	# RD

	sll     $t6, $a1, 21	# SHAMT
	srl     $t6, $t6, 27	# SHAMT
	sw      $t6, 0($t4)	# SHAMT
	
	sll     $t6, $a1, 26	# FUNCT 
	srl     $t6, $t6, 26	# FUNCT
	sw      $t6, 0($t5)	# FUNCT
	jr      $ra	
	
isola_CAMPOS_J:

	la      $t1, campo_imm26 # CONST 26
	la	$t2, 0		 # Variavel auxiliar
	sll     $t2, $a1, 6	 
	srl     $t2, $t2, 6
	sw      $t2, 0($t1)	
	jr      $ra
	
isola_CAMPOS_I:	

	la      $t1, campo_rs	 
	la      $t2, campo_rt
	la      $t3, campo_imm16
		
	la	$t4, 0		# Variavel auxiliar
	sll     $t4, $a1, 6	# RS
	srl     $t4, $t4, 27	# RS
	sw      $t4, 0($t1)	# RS
	
	sll     $t4, $a1, 11	# RT
	srl     $t4, $t4, 27	# RT
	sw      $t4, 0($t2)	# RT
	
	sll     $t4, $a1, 16	# CONST 16
	srl     $t4, $t4, 16	# CONST 16
	sw      $t4, 0($t3)	# CONST 16
	jr      $ra

TIPO_R: 
	# Campo FUNCT armazenado em $t5
	beq    $t5, 0x20, inst_ADD 
	beq    $t5, 0x21, inst_ADDU
	beq    $t5, 0x24, inst_AND
	beq    $t5, 0x22, inst_SUB
	beq    $t5, 0x23, inst_SUBU
	beq    $t5, 0x27, inst_NOR
	beq    $t5, 0x26, inst_XOR
	beq    $t5, 0x2A, inst_SLT
	beq    $t5, 0x2B, inst_SLTU
	beq    $t5, 0x23, inst_SUBU
	beq    $t5, 0x00, inst_SLL
	beq    $t5, 0x02, inst_SRL
	beq    $t5, 0x0C, inst_SYSCALL
	beq    $t5, 0x08, inst_JR
	jr     $ra

TIPO_I:
	# Campo OPCODE armazenado em $t0
	beq    $t0, 0x08, inst_ADDI 
        beq    $t0, 0x04, inst_BEQ
        beq    $t0, 0x05, inst_BNE 
        beq    $t0, 0x23, inst_LW  
        beq    $t0, 0x2b, inst_SW 
        beq    $t0, 0x20, inst_LB  
        beq    $t0, 0x28, inst_SB
        beq    $t0, 0x24, inst_LI
        beq    $t0, 0x09, inst_ADDIU 
	jr     $ra

TIPO_J:
	# Campo OPCODE armazenado em $t0
	beq    $t0, 0x02, inst_J    
        beq    $t0, 0x03, inst_JAL
     	jr $ra

IMPRIME_REG: 

	# Verifica qual registrador deve imprimir
	beq    $t0, 0x00, reg_zero # $zero
	beq    $t0, 0x01, reg_at   # $at
	beq    $t0, 0x02, reg_v0   # $v0
	beq    $t0, 0x03, reg_v1   # $v1
	beq    $t0, 0x04, reg_a0   # $a0
	beq    $t0, 0x05, reg_a1   # $a1
	beq    $t0, 0x06, reg_a2   # $a2
	beq    $t0, 0x07, reg_a3   # $a3
	beq    $t0, 0x08, reg_t0   # $t0
	beq    $t0, 0x09, reg_t1   # $t1
	beq    $t0, 0x0a, reg_t2   # $t2
	beq    $t0, 0x0b, reg_t3   # $t3
	beq    $t0, 0x0c, reg_t4   # $t4
	beq    $t0, 0x0d, reg_t5   # $t5
	beq    $t0, 0x0e, reg_t6   # $t6
	beq    $t0, 0x0f, reg_t7   # $t7
	beq    $t0, 0x10, reg_s0   # $s0
	beq    $t0, 0x11, reg_s1   # $s1
	beq    $t0, 0x12, reg_s2   # $s2
	beq    $t0, 0x13, reg_s3   # $s3                	 	    	                	            
	beq    $t0, 0x14, reg_s4   # $s4
	beq    $t0, 0x15, reg_s5   # $s5
	beq    $t0, 0x16, reg_s6   # $s6
	beq    $t0, 0x17, reg_s7   # $s7
	beq    $t0, 0x18, reg_t8   # $t8
	beq    $t0, 0x19, reg_t9   # $t9
	beq    $t0, 0x1a, reg_k0   # $k0
	beq    $t0, 0x1b, reg_k1   # $k1
	beq    $t0, 0x1c, reg_gp   # $gp
	beq    $t0, 0x1d, reg_sp   # $sp
	beq    $t0, 0x1e, reg_fp   # $fp
	beq    $t0, 0x1f, reg_ra   # $ra
	jr     $ra
	
inst_ADDI:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("addi ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
	## Coloca no banco na posicao CAMPO_RT a soma do conteudo dos registradores CAMPO_RS + CAMPO_IMM16
	## banco_registradores[CAMPO_RT] = banco_registradores[CAMPO_RS] + banco_registradores[CAMPO_IMM16]

inst_ADD:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("add ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RD a soma do conteudo dos registradores CAMPO_RS + CAMPO_RT
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] + banco_registradores[CAMPO_RT]

inst_ADDU:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("addu ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
	## Coloca no banco na posicao CAMPO_RD a soma do conteudo dos registradores CAMPO_RS + CAMPO_RT
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] + banco_registradores[CAMPO_RT]
	
inst_SUB:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sub ")
	lw     	$t0, campo_rd
	jal   	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RD a diferenca do conteudo dos registradores CAMPO_RS + CAMPO_RT
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] - banco_registradores[CAMPO_RT]

inst_SUBU:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("subu ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RD a diferenca do conteudo dos registradores CAMPO_RS + CAMPO_RT
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] - banco_registradores[CAMPO_RT]

inst_LI:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("li ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
	## Coloca no banco na posicao CAMPO_RT o conteudo do registrador CAMPO_IMM16
	## banco_registradores[CAMPO_RT] = banco_registradores[CAMPO_IMM16]
	
inst_LW:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("lw ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	IMPRIME_STRING("(")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	IMPRIME_STRING(")")
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RT O conteudo do registrador CAMPO_RS deslocado CAMPO_IMM16 bits
	## banco_registradores[CAMPO_RT] = banco_registradores[CAMPO_RS + CAMPO_IMM16]

inst_SW:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sw ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	mul    	$t2, $t0, 4
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	IMPRIME_STRING("(")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	mul    	$t3, $t0, 4
	IMPRIME_STRING(")")
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RS + CAMPO_IMM16 o conteudo do registrador CAMPO_RT
	## banco_registradores[CAMPO_RS + CAMPO_IMM16] = banco_registradores[CAMPO_RT]
	 
inst_SLL:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sll ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG	
	imprime_virgula()
	lw     	$a0, campo_rt
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
	## Coloca no banco na posicao CAMPO_RD o conteudo do registrador CAMPO_RS deslocado CAMPO_RT bits
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] deslocado CAMPO_RT bits

inst_SRL:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("srl ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG	
	imprime_virgula()
	lw     	$a0, campo_rt
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

	## Coloca no banco na posicao CAMPO_RD a diferenca do conteudo dos registradores CAMPO_RS + CAMPO_RT
	## banco_registradores[CAMPO_RD] = banco_registradores[CAMPO_RS] - banco_registradores[CAMPO_RT]


inst_AND:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("and ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_NOR:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("nor ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
inst_XOR:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("xor ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
inst_BEQ:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("beq ")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_BNE:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("bne ")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_SLT:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("slt ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_SLTI:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("slti ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_SLTIU:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sltiu ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 36
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
inst_SLTU:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sltu ")
	lw     	$t0, campo_rd
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_J:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("j ")
	lw     	$a0, campo_imm26
	li     	$v0, 34
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_JAL:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("jal ")
	lw     	$a0, campo_imm26
	li     	$v0, 34
	syscall
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
	
inst_JR:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("jr ")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra
		
inst_LB:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("lb ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	IMPRIME_STRING("(")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	IMPRIME_STRING("(")
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_ADDIU:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("addiu ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG	
	mul    	$t2, $t0, 4
	imprime_virgula()
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	mul    	$t3, $t0, 4
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 36
	syscall
	
	la     	$t4, ($a0)
	la     	$t5, 0
	la     	$t6, 0
	
	la     	$t5, banco_registradores($t2)
	lw     	$t6, banco_registradores($t3)
	add    	$t6, $t6, $a0
	sw     	$t6,($t5)
	
	nova_linha()
	lw 	$ra, 4($sp)
	jr 	$ra

inst_SB:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("sb ")
	lw     	$t0, campo_rt
	jal    	IMPRIME_REG
	imprime_virgula()
	lw     	$a0, campo_imm16
	li     	$v0, 1
	syscall
	IMPRIME_STRING("(")
	lw     	$t0, campo_rs
	jal    	IMPRIME_REG
	IMPRIME_STRING("(")
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra

inst_SYSCALL:
	sw 	$ra, 4($sp)
	IMPRIME_STRING("syscall ")
	nova_linha()
	lw 	$ra, 4($sp) 
	jr 	$ra 
	  
# Registradores: 
reg_zero:
	IMPRIME_STRING("$zero")
        jr  $ra  
reg_at:
	IMPRIME_STRING("$at")
	jr $ra		    
reg_v0:
	IMPRIME_STRING("$v0")
	jr $ra
reg_v1:
	IMPRIME_STRING("$v1")
	jr $ra
reg_a0:
	IMPRIME_STRING("$a0")
	jr $ra
reg_a1:
	IMPRIME_STRING("$a1")
	jr $ra
reg_a2:
	IMPRIME_STRING("$a2")
	jr $ra
reg_a3:
	IMPRIME_STRING("$a3")
	jr $ra
reg_t0:
	IMPRIME_STRING("$t0")
	jr $ra
reg_t1:
	IMPRIME_STRING("$t1")
	jr $ra
reg_t2:
	IMPRIME_STRING("$t2")
	jr $ra
reg_t3:
	IMPRIME_STRING("$t3")
	jr $ra
reg_t4:
	IMPRIME_STRING("$t4")
	jr $ra
reg_t5:
	IMPRIME_STRING("$t5")
	jr $ra
reg_t6:
	IMPRIME_STRING("$t6")
	jr $ra
reg_t7:
	IMPRIME_STRING("$t7")
	jr $ra
reg_s0:
	IMPRIME_STRING("$s0")
	jr $ra
reg_s1:
	IMPRIME_STRING("$s1")
	jr $ra
reg_s2:
	IMPRIME_STRING("$s2")
	jr $ra
reg_s3:
	IMPRIME_STRING("$s3")
	jr $ra
reg_s4:
	IMPRIME_STRING("$s4")
	jr $ra
reg_s5:
	IMPRIME_STRING("$s5")
	jr $ra
reg_s6:
	IMPRIME_STRING("$s6")
	jr $ra
reg_s7:
	IMPRIME_STRING("$s7")
	jr $ra
reg_t8:
	IMPRIME_STRING("$t8")
	jr $ra
reg_t9:
	IMPRIME_STRING("$t9")
	jr $ra
reg_k0:
	IMPRIME_STRING("$k0")
	jr $ra
reg_k1:
	IMPRIME_STRING("$k1")
	jr $ra
reg_gp:
	IMPRIME_STRING("$gp")
	jr $ra
reg_sp:
	IMPRIME_STRING("$sp")
	jr $ra
reg_fp:
	IMPRIME_STRING("$sp")
	jr $ra
reg_ra:
	IMPRIME_STRING("$ra")
	jr $ra	

Fim_Programa:
	addiu  	$sp, $sp, 8
    	
    	IMPRIME_STRING("\nBANCO REGISTRADORES:\n")
    	la 	$t0, 0
    	la 	$t1, 0
    	la 	$t2, 0
    	jal 	imprime_banco
    	li     	$v0, SERVICO_TERMINA_PROGRAMA
	syscall
	
imprime_banco:
	
	la     	$t0, banco_registradores
	add    	$t1, $t1, 4
	add    	$t0, $t0, $t1
	
	# Imprime inteiro
    	lw     $a0, 0($t0)
        li     $v0, 1
        syscall
       	nova_linha()
    	
	add    $t2, $t2, 1
	bne    $t2, 32, imprime_banco
    	
    	IMPRIME_STRING("\nPC: ")
    	lw     $a0, pc
    	li     $v0, 34
        syscall
        
        IMPRIME_STRING("\nIR: ")
        lw     $a0, IR
    	li     $v0, 34
        syscall
    	jr     $ra

.data
#Variaveis do SIMULADOR
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
				.align 2
campo_rs:			.space 4
				.align 2
campo_rt:			.space 4
				.align 2	
campo_rd:			.space 4
				.align 2
campo_shamt:			.space 4
				.align 2
campo_funct:			.space 4
				.align 2
campo_imm16:			.space 4
				.align 2
campo_imm26:			.space 4
				.align 2

# Banco de registradores
banco_registradores:		.space 128
				.align 2
sp: 				.word 2147479548
				.align 2
#Contador de programa
pc:				.space 4
				.align 2	
#Registrador de instrucao
IR:				.space 4
				.align 2