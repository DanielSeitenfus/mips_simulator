#*******************************************************************************
# exercicio051.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução while, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
# int a;
#
#int main(void)
#{
#    a = 0;              // inicializamos a variável a com o valor zero
#    while (a != 9){     // enquanto a variável a é diferente de 9, faça
#        a = a + 1;      // incremente a variável a
#    }                   // 
#    return 0;           // termina o programa retornando 0
#}
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    12.04.2017     GBTO   versão inicial 
# 0.2    06.05.2019     GBTO   adicionada a instrução sw    $s0, 0($t0) no laço while
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
            #a = 0;
            la    $t0, varA     # carregamos em $t0 o endereço da variável a
            xor   $s0, $s0, $s0 # $s0 guarda uma cópia de a. Fazemos a = 0
            sw    $s0, 0($t0)   # atualizamos o valor da variável a
            # while (a != 9){     // enquanto a variável a é diferente de 9, faça
            # parte 1 deste instrução
inicio_while:            
            j    testa_condicao # verificamos se a condição do laço while é verdadeira
instrucoes_laco_while:          # inicio das instruções lo laço while se condição é verdadeira
            # a = a + 1;      // incremente a variável a
            addi  $s0, $s0, 1   # incrementamos a variável a
            sw    $s0, 0($t0)   # atualizamos a variável a
            # }                   // 
testa_condicao:                 # testamos se a condição do laço while é verdadeira
            # while (a != 9){     // enquanto a variável a é diferente de 9, faça
            # parte 2 desta instrução
            addi  $t1, $zero, 9 # carregamos em $t1 o valor 9
            bne   $s0, $t1, instrucoes_laco_while # se a != 9 execute o código do laço while
            # se a condição é falsa, termina a instrução while
fim_while:            
            # return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 - exit 2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0 - sucesso
            syscall             # fazemos uma chamada do serviço 17 do sistema com valor 0
.data 
# int a;
varA:       .word 0             # variável varA = a, global.

