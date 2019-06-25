.include "macros060.s"
.text
.globl      main

#Passos do MIPS
# 1º) BUSCA:
#	IR = memoria_text[PC]	
#	PC = PC+4 (PC guarda a instrução a ser executada, assim, lê-se a instrução referência a posição PC no vetor
# 2º) DECODIFICAÇÃO:
#	(Essa parte já está desenvolvida, só adaptar para o nosso caso)
#	A = registradores[IR[25-21]]
#	B = registradores[IR[20-16]] (Acredito que isso seja os dois registradores que serão manipulados, caso a instrução use 2)
#	UALSaída = PC + extensão de sinal (IR[15-0] << 2) (UALSaída, o que é?)
# 3º) EXECUÇÃO, CÁLCULO DO ENDEREÇO DE MEMÓRIA OU EFETIVAÇÃO DO DESVIO CONDICIONAL:
#    A) Referência à memória:
#	UALSaída = A + extensão de sinal IR[15-0]
#    B) Instrução aritmética ou lógica (Tipo R)
#	UALSaída = A op B
#    C) Desvio condicional:
#	Se (A==B) então PC=UALSaída
#
#
#
#


main:
	# Reserva espaco na pilha para variaveis
	addiu  $sp, $sp, -8
				          
	# Abertura do arquivo
        # $v0 contÃ©m descritor do arquivo
        la     $a0, Entrada 	     # $a0 <- endereco da string com o nome do arquivo
        li     $a1, 0 		     # Flags: 0 - indica modo de leitura
        li     $a2, 0 		     # Modo - eh ignorado pelo servico
        li     $v0, SERVICO_ABRE_ARQUIVO	
        syscall         
      	
      	# Salva retorno da leitura em $sp
        sw     $v0, 0($sp) 	     # salva o retorno da leitura do arquivo 
        slt    $t0, $v0, $zero       # se tiver algum erro, termina o programa
        bne    $t0, $zero, MSG_ERRO  # caso contrario, continua a execucao
        
        imprime_str("\nInforme o numero de instrucoes a executar: ")
        
        jal LEITURA_INTEIRO  # chama funcao para ler
        la  $t6, 0($v0)	     # carrega o inteiro lido em $t6     
      	li  $t7, 0	     # inicializa contador em $t7 = 0
        j   Fim_Arquivo	     # pula para funcao que decodifica
               
               
LEITURA_INTEIRO:
	li $v0, 5	# codigo para ler um inteiro
	syscall		# executa a chamada do SO para ler
	jr $ra		# volta para o lugar de onde foi chamado

MSG_ERRO:

	imprime_str("Erro ao abrir o ficheiro de entrada")
	addiu  $sp, $sp, 8
        li     $a0, 1 # se o valor!=0, finaliza programa
        li     $v0, SERVICO_TERMINA_PROGRAMA
	syscall
	
Fim_Programa:
	addiu  $sp, $sp, 8
        li     $a0, 0
        li     $v0, SERVICO_TERMINA_PROGRAMA
	syscall

Fim_Arquivo:

	#Verifica se o contador eh igual a qnt de instrucoes (int) informada
	beq $t6, $t7, Fim_Programa # chama fim do programa
	addi $t7, $t7, 1	   # incrementa o contador
	
	# Leitura das instrucoes
	lw     $a0, 0($sp)          # $a0 <- o descritor do arquivo
	la     $a1, instrucoes      # $a1 <- endereco do buffer de entrada
        li     $a2, 4               # $a2 <- numero de bytes que serao lidos
        li     $v0, SERVICO_LEITURA_ARQUIVO # $v0 <- numero de bytes lidos
       	syscall
       	
        # Se $v0 (caracteres lidos) eh menor que 4, $t0 = 1
        slti   $t0, $v0, 4	    # teste para verificar se foram lidos 32 bits
        beq    $t0, $zero, IMPRIME  # caso $t0 = 0 (lidos 4 bytes), continua
        j   Fim_Programa	    # senao, encerra o programa

IMPRIME:	
	jal    imprime_endereco
	jal    imprime_codigo_maquina
	jal    imprime_inst
	j      Fim_Programa
	 
imprime_endereco:
	# Carrega em $t0 endereco da variavel "Endereco"
	# Carrega conteudo da variavel Endereco em $t1
	# Move para $a0 por default e chama syscall
	la     $t0, Endereco
	lw     $t1, 0($t0)
	move   $a0, $t1
	li     $v0, SERVICO_IMPRIME_HEX
	syscall
	
	imprime_espaco()
	# Incrementa endereco em 4
	# Salva novo valor em $t0
	addi   $t1, $t1, 4
	sw     $t1, 0($t0)
	jr     $ra

imprime_codigo_maquina:
	# Carrega em $t0 endereco da variavel "instrucoes"
	# Carrega conteudo da variavel instrucoes em $a0
	# Chama syscall
	la     $t0, instrucoes
	lw     $a0, 0($t0)
	li     $v0, SERVICO_IMPRIME_HEX
	syscall
	imprime_espaco()
	jr     $ra

imprime_inst:
	la     $t0, instrucoes	# Carrega em $t0 endereco da variavel "instrucoes"
	lw     $t1, 0($t0)	# Carrega conteudo da variavel instrucoes em $t1
        srl    $t3, $t1, 26     # Isola o opcode deslocando 26 bits = 32bits-6
        #move   $a0, $t3
        
        # Se $t3==0, instrucao tipo R	
        beqz   $t3, TIPO_R
        
        #Senao, 
        jal    isola_CAMPOS_J
        beq    $t3, 0x02, inst_J    
        beq    $t3, 0x03, inst_JAL   
        
        jal    isola_CAMPOS_I
        beq    $t3, 0x08, inst_ADDI 
        beq    $t3, 0x04, inst_BEQ
        beq    $t3, 0x05, inst_BNE 
        beq    $t3, 0x23, inst_LW  
        beq    $t3, 0x2b, inst_SW 
        beq    $t3, 0x20, inst_LB  
        beq    $t3, 0x28, inst_SB
        beq    $t3, 0x24, inst_LI
        beq    $t3, 0x09, inst_ADDIU 
  	imprime_str("(Instrucao desconhecida)\n")  
  	j      Fim_Arquivo
  	
isola_CAMPOS_R:
	la     $t0, instrucoes
	lw     $t1, 0($t0)	
	la     $s0, RS
	la     $s1, RT
	la     $s2, RD
	la     $s3, SHAMT
	la     $s4, FUNCT	
	 
	sll    $t2, $t1, 6	#rs 
	srl    $t2, $t2, 27
	sw     $t2, 0($s0)	
	 
	sll    $t2, $t1, 11	#rt
	srl    $t2, $t2, 27
	sw     $t2, 0($s1)	
	
	sll    $t2, $t1, 16	#rd
	srl    $t2, $t2, 27
	sw     $t2, 0($s2)	

	sll    $t2, $t1, 21	#shamt
	srl    $t2, $t2, 27
	sw     $t2, 0($s3)	
	
	sll    $t2, $t1, 26	#funct 
	srl    $t2 $t2, 26
	sw     $t2, 0($s4)	
	jr     $ra	
	
isola_CAMPOS_I:	
	la     $t0, instrucoes
	lw     $t1, 0($t0)
	la     $s0, RS
	la     $s1, RT
	la     $s2, Const16
				
	sll    $t2, $t1, 6	#rs
	srl    $t2, $t2, 27
	sw     $t2, 0($s0)	
	
	sll    $t2, $t1, 11	#rt
	srl    $t2, $t2, 27
	sw     $t2, 0($s1)
	
	sll    $t2, $t1, 16	#constante de 16 bits
	srl    $t2, $t2, 16
	sw     $t2, 0($s2)
	jr     $ra
	
isola_CAMPOS_J:
	la     $t0, instrucoes
	lw     $t1, 0($t0)
	la     $s0, Const26
	
	sll    $t2, $t1, 6	#constante de 26 bits
	srl    $t2, $t2, 6
	sw     $t2, 0($s0)	
	jr     $ra	

TIPO_R: 
	jal    isola_CAMPOS_R
	la     $t0, FUNCT 
	lw     $t3, 0($t0) 
	
	beq    $t3, 0x20, inst_ADD 
	beq    $t3, 0x21, inst_ADDU
	beq    $t3, 0x24, inst_AND
	beq    $t3, 0x22, inst_SUB
	beq    $t3, 0x23, inst_SUBU
	beq    $t3, 0x27, inst_NOR
	beq    $t3, 0x26, inst_XOR
	beq    $t3, 0x2A, inst_SLT
	beq    $t3, 0x2B, inst_SLTU
	beq    $t3, 0x23, inst_SUBU
	beq    $t3, 0x00, inst_SLL
	beq    $t3, 0x02, inst_SRL
	beq    $t3, 0x0C, inst_SYSCALL
	beq    $t3, 0x08, inst_JR
	j      Fim_Arquivo

imprime_reg_s: # verifica qual reg_istrador deve imprimir
	sw     $ra, 4($sp)
	beq    $a0, 0x00, reg_zero # $zero
	beq    $a0, 0x01, reg_at   # $at
	beq    $a0, 0x02, reg_v0   # $v0
	beq    $a0, 0x03, reg_v1   # $v1
	beq    $a0, 0x04, reg_a0   # $a0
	beq    $a0, 0x05, reg_a1   # $a1
	beq    $a0, 0x06, reg_a2   # $a2
	beq    $a0, 0x07, reg_a3   # $a3
	beq    $a0, 0x08, reg_t0   # $t0
	beq    $a0, 0x09, reg_t1   # $t1
	beq    $a0, 0x0a, reg_t2   # $t2
	beq    $a0, 0x0b, reg_t3   # $t3
	beq    $a0, 0x0c, reg_t4   # $t4
	beq    $a0, 0x0d, reg_t5   # $t5
	beq    $a0, 0x0e, reg_t6   # $t6
	beq    $a0, 0x0f, reg_t7   # $t7
	beq    $a0, 0x10, reg_s0   # $s0
	beq    $a0, 0x11, reg_s1   # $s1
	beq    $a0, 0x12, reg_s2   # $s2
	beq    $a0, 0x13, reg_s3   # $s3                	 	    	                	            
	beq    $a0, 0x14, reg_s4   # $s4
	beq    $a0, 0x15, reg_s5   # $s5
	beq    $a0, 0x16, reg_s6   # $s6
	beq    $a0, 0x17, reg_s7   # $s7
	beq    $a0, 0x18, reg_t8   # $t8
	beq    $a0, 0x19, reg_t9   # $t9
	beq    $a0, 0x1a, reg_k0   # $k0
	beq    $a0, 0x1b, reg_k1   # $k1
	beq    $a0, 0x1c, reg_gp   # $gp
	beq    $a0, 0x1d, reg_sp   # $sp
	beq    $a0, 0x1e, reg_fp   # $fp
	beq    $a0, 0x1f, reg_ra   # $ra
	lw     $ra, 4($sp)
	jr     $ra
	    
inst_ADD:
	imprime_str("add ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     
	
inst_ADDU:
	imprime_str("addu ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     
	
inst_ADDI:
	imprime_str("addi ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     
	
inst_SUB:
	imprime_str("sub ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     

inst_SUBU:
	imprime_str("subu ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     

inst_LI:

	imprime_str("li ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     
	
inst_LW:
	imprime_str("lw ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	imprime_str("(")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_str(")")
	nova_linha()
	j      Fim_Arquivo      

inst_SW:
	imprime_str("sw ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	imprime_str("(")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_str(")")
	nova_linha()
	j      Fim_Arquivo     
	
inst_SLL:
	imprime_str("sll ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s	
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_SRL:
	imprime_str("srl ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s	
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_AND:
	imprime_str("and ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     

inst_NOR:
	imprime_str("nor ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     
	
inst_XOR:
	imprime_str("xor ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     
	
inst_BEQ:
	imprime_str("beq ")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_BNE:
	imprime_str("bne ")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_SLT:
	imprime_str("slt ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     

inst_SLTI:
	imprime_str("slti ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_SLTIU:
	imprime_str("sltiu ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $a0, Const16
	lw     $a0, 0($t0)
	li     $v0, 36
	syscall
	nova_linha()
	j      Fim_Arquivo     
	
inst_SLTU:
	imprime_str("sltu ")
	la     $t0, RD
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo     

inst_J:
	imprime_str("j ")
	la     $t0, Const26
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_JAL:
	imprime_str("jal ")
	la     $t0, Const26
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	nova_linha()
	j      Fim_Arquivo     
	
inst_JR:
	imprime_str("jr ")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	nova_linha()
	j      Fim_Arquivo 
		
inst_LB:
	imprime_str("lb ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	imprime_str("(")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_str("(")
	nova_linha()
	j      Fim_Arquivo     

inst_ADDIU:
	imprime_str("addiu ")
	la     $t0, RT
	lw     $s0, 0($t0)
	move   $a0, $s0
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 36
	syscall
	nova_linha()
	j      Fim_Arquivo     

inst_SB:
	imprime_str("sb ")
	la     $t0, RT
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_virgula()
	la     $t0, Const16
	lw     $a0, 0($t0)
	li     $v0, 1
	syscall
	imprime_str("(")
	la     $t0, RS
	lw     $a0, 0($t0)
	jal    imprime_reg_s
	imprime_str("(")
	nova_linha()
	j      Fim_Arquivo     

inst_SYSCALL:
	imprime_str("syscall ")
	nova_linha()
	j Fim_Arquivo     

# Registradores: 
reg_zero:
	imprime_str("$zero")
        jr  $ra  
reg_at:
	imprime_str("$at")
	jr $ra		    
reg_v0:
	imprime_str("$v0")
	jr $ra
reg_v1:
	imprime_str("$v1")
	jr $ra
reg_a0:
	imprime_str("$a0")
	jr $ra
reg_a1:
	imprime_str("$a1")
	jr $ra
reg_a2:
	imprime_str("$a2")
	jr $ra
reg_a3:
	imprime_str("$a3")
	jr $ra
reg_t0:
	imprime_str("$t0")
	jr $ra
reg_t1:
	imprime_str("$t1")
	jr $ra
reg_t2:
	imprime_str("$t2")
	jr $ra
reg_t3:
	imprime_str("$t3")
	jr $ra
reg_t4:
	imprime_str("$t4")
	jr $ra
reg_t5:
	imprime_str("$t5")
	jr $ra
reg_t6:
	imprime_str("$t6")
	jr $ra
reg_t7:
	imprime_str("$t7")
	jr $ra
reg_s0:
	imprime_str("$s0")
	jr $ra
reg_s1:
	imprime_str("$s1")
	jr $ra
reg_s2:
	imprime_str("$s2")
	jr $ra
reg_s3:
	imprime_str("$s3")
	jr $ra
reg_s4:
	imprime_str("$s4")
	jr $ra
reg_s5:
	imprime_str("$s5")
	jr $ra
reg_s6:
	imprime_str("$s6")
	jr $ra
reg_s7:
	imprime_str("$s7")
	jr $ra
reg_t8:
	imprime_str("$t8")
	jr $ra
reg_t9:
	imprime_str("$t9")
	jr $ra
reg_k0:
	imprime_str("$k0")
	jr $ra
reg_k1:
	imprime_str("$k1")
	jr $ra
reg_gp:
	imprime_str("$gp")
	jr $ra
reg_sp:
	imprime_str("$sp")
	jr $ra
reg_fp:
	imprime_str("$sp")
	jr $ra
reg_ra:
	imprime_str("$ra")
	jr $ra
	
.data
Endereco:  	.word 0x00400000 # endereco inicial
instrucoes: 	.space 4	 # vetor que guarda os 4 bytes da instruï¿½ao atual
buffer_entrada: .space 4  	 # vetor que guarda a entrada da leitura

RS:	.space 1
	.align 2
RT:  	.space 1
	.align 2
RD:  	.space 1   
	.align 2
SHAMT:  .space 1
	.align 2
FUNCT:  .space 1
	.align 2
Const16:.space 2
	.align 2
Const26:.space 4

banco_registradores: .space 128

# Ficheiro de entrada:
Entrada:     .asciiz "exercicio12.dump"
#nome_arquivo_text: .asciiz "text.bin"
#nome_arquivo_data: .asciiz "data.bin"

msg_erro:    .asciiz "erro de abertura"

reg_$0:      .asciiz "$zero"
reg_$at:     .asciiz "$at"
reg_$v0:     .asciiz "$v0"
reg_$v1:     .asciiz "$v1"
reg_$a0:     .asciiz "$a0"
reg_$a1:     .asciiz "$a1"
reg_$a2:     .asciiz "$a2"
reg_$a3:     .asciiz "$a3"
reg_$t0:     .asciiz "$t0"
reg_$t1:     .asciiz "$t1"
reg_$t2:     .asciiz "$t2"
reg_$t3:     .asciiz "$t3"
reg_$t4:     .asciiz "$t4"
reg_$t5:     .asciiz "$t5"
reg_$t6:     .asciiz "$t6"
reg_$t7:     .asciiz "$t7"
reg_$t8:     .asciiz "$t8"
reg_$t9:     .asciiz "$t9"
reg_$s0:     .asciiz "$s0"
reg_$s1:     .asciiz "$s1"
reg_$s2:     .asciiz "$s2"
reg_$s3:     .asciiz "$s3"
reg_$s4:     .asciiz "$s4"
reg_$s5:     .asciiz "$s5"
reg_$s6:     .asciiz "$s6"
reg_$s7:     .asciiz "$s7"
reg_$sp:     .asciiz "$sp"
reg_$gp:     .asciiz "$gp"
reg_$fp:     .asciiz "$fp"
reg_$ra:     .asciiz "$ra"
reg_$k0:     .asciiz "$k0"
reg_$k1:     .asciiz "$k1"



#Variï¿½veis SIMULADOR
memoria_text:			.space 4096
memoria_data:			.space 4096

#Arquivo
nome_arquivo_text: 		.asciiz "text.bin"
nome_arquivo_data: 		.asciiz "data.bin"
msg_erro_leitura_arquivo:	.asciiz "\nErro na leitura do arquivo\n"

#Contador de programa
pc:				.space 4	
#Registrador de instruï¿½ï¿½o
ir:				.space 4

#Campos instruï¿½ï¿½o em IR
instrucao_op:				.space 4
instrucao_rs:				.space 4
instrucao_rt:				.space 4	
instrucao_rd:				.space 4
instrucao_imm16:			.space 4
instrucao_imm26:			.space 4
instrucao_shamt:			.space 4	


