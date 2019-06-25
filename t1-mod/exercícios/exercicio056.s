#*******************************************************************************
# exercicio051.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução while, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
#int a;
#int i;   
#
#int main(void)
#{
#    a = 0;              // inicializamos a variável a com o valor zero
#    for(i=0; i<9; i++){ // para i de 0 a 8 (repetimos 9 vezes o laço for)
#        a = a + 1;      // incremente a 
#    }
#    return 0;           // termina o programa retornando 0
#}
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    12.04.2017     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
            #a = 0; // inicializamos a variável a com o valor zero
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0, a = 0
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
inicio_for:            
            # for(i=0; i<10; i++){// para i de 0 a 9 (repetimos 10 vezes o laço for)
            # laço for - inicialização
            # i = 0;
inicializacao_laco_for:            
            la    $t1, VarI     # $t1 armazena o endereço da variável i
            addi  $t2, $zero, 0 # fazemos $t2 (cópia de i) igual a 0
            sw    $t2, 0($t1)   # atualizamos o valor da variável i na memória
            # laço for - verificamos a condição
            j     verifica_condicao_for # salto incondicional para a verificação do laço for
            # laço for - código se condição for verdadeira
codigo_for_condicao_verdadeira:
            # a = a + 1;      // incremente a
            addi  $s0, $s0, 1   # incrementa o valor de a
            sw    $s0, 0($t0)   # atualiza o valor de a na memória
            # laço for - inccremento
            # i++
            addi  $t2, $t2, 1   # incrementamos o valor de i
            sw    $t2, 0($t1)   # atualiza o valor de i na memória
            # verifica se a condição do laço for é verdadeira
verifica_condicao_for:
            # i<9
            slti   $t3, $t2, 9 # $t3 <- 1 se i < 9
            bne    $t3, $zero, codigo_for_condicao_verdadeira
            # }
codigo_for_condicao_falsa:            
fim_for:            
            # return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # escolhemos o serviço 17 - exit2 - termina o programa
            addi  $a0, $zero, 0 # o valor de retorno do programa é zero
            syscall             # executamos o serviço 17 com uma chamada ao sistema
.data 
# int a;
varA:       .word 0             # variável varA = a, global
# int i;
VarI:       .word 0             # variável VarI = i, global
