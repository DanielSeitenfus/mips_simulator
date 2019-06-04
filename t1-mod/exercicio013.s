###############################################################################
# programa para calcular o fatorial de um número: versão não recursiva
###############################################################################

###############################################################################
.text
.globl main		# main pode ser referenciado em outros arquivos
###############################################################################

###############################################################################
main:
#------------------------------------------------------------------------------
	# void main(void)
	# { 	
	#     int k; 	
	#     k = 5; 	
	#     k = fact2(k); 	
	#     printf("%d",k); 
	#     return;
	# }	
#------------------------------------------------------------------------------
# prólogo
# k pode ser armazenado em um registrador. Não usaremos a pilha
# corpo do procedimento
	li 		$s0, 5				# k = $s0 <-10;
	add		$a0, $zero, $s0		# a0 <- k, a0 argumento da função
	jal 	fact2				# chama a função fact - fatorial
	move 	$s0, $v0		    # k = fact(k)
# imprime o valor de k
	li 		$v0, 1	 			# serviço 1 - imprime inteiro
	move    $a0, $s0			# $a0 <- k
	syscall						# chamada ao sistema
# epílogo
# termina o programa
	li 		$v0, 10				# serviço 10 - término do programa
	syscall						# chamada ao sistema
	
	
###############################################################################
fact2:
#------------------------------------------------------------------------------
	# procedimento fact2 - retorna o fatorial de um inteiro
	# função não recursiva
	# n deve ser maior ou igual a zero
	# n deve ser menor que 12 para registradores de 32 bits	
#------------------------------------------------------------------------------
	# int fact2(int n)
	# {
	# int tmp;
	# tmp = 1;
	# if(n==0) return 1; 	
	# else {
	# 	tmp = n;
	#	while(n>1){
	#		n = n-1;
	#		tmp = tmp*n;
	#	}
	#	return tmp;
	#	}
	# }
#------------------------------------------------------------------------------
# prólogo
# corpo do procedimento	
	# verifica se n==0
	beq		$a0, $zero, N_EQ_0		# se n==0 desvie para N_EQ_0
N_NEQ_0:
	# $t0 <- n
	# $t1 <- tmp
	add 	$t0, $zero, $a0			# $t0 <- n;
	add 	$t1, $zero, $a0			# $t1 <- n;
		
LOOP:		
	sgt 	$t2, $t0, 1				# $t2 <- 1 se n>1 senão 0
	beq 	$t2, $zero, END_LOOP	# se t2 = 0 (n<=1) saia do laço
	
	subi 	$t0, $t0, 1				# n = n - 1;
	mul 	$t1, $t1,$t0			# tmp <- tmp*n
	j 		LOOP					# continua o laço
END_LOOP:
	move	$v0, $t1				# guarda o valor de retorno
	j 		EXIT					# vai para o encerramento do procedimento	
N_EQ_0:
	addi 	$v0, $zero, 1			# fact <- 1
EXIT:
# epílogo
# retorna ao procedimento chamador
	jr 		$ra						# retorna para a funcao chamadora
# fim do procedimento fact2	
###############################################################################	
