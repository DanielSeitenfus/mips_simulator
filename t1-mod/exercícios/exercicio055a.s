#*******************************************************************************
# exercicio055.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução switch-case, de um trecho de 
#            código, do C para assembly. Neste código, se o valor da variável a
#            estiver no intervalo 0 a 3, ele é substituído por 10, 20, 30 ou 40 
#            respectivamente. Neste exemplo, comparamos o valor da variável de 
#            controle com os valores em case. Veja o exemplo exercicio055.s para
#            uma tradução mais eficiente, usando uma tabela de desvios.
#            Segue o código em C.
# int a;
#
#int main(void)
#{
#    a = 2;              // colocamos em a um valor para teste
#    switch (a){         // selecionamos um case, usando o valor de a
#        case 0:         // se a = 0
#            a = 10;     // fazemos a = 10
#            break;      // saímos da estrutura switch-case
#        case 1:         // se a = 1 
#            a = 20;     // fazemos a = 20
#            break;      // saímos da estrutura switch-case
#        case 2:         // se a = 2
#            a = 30;     // fazemos a = 30
#            break;      // saímos da estrutura switch-case
#        case 3:         // se a = 3
#            a = 40;     // fazemos a = 40
#            break;      // saímos da estrutura switch-case
#    }                   // fim da construção switch-case
#    return 0;           // termina o programa retornando 0
#}
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    17.09.2018     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
            #a = 2;              // colocamos em a um valor para teste
            la    $t0, varA     # $t0 <- enderço da variável a
            addi  $s0, $zero, 2 # fazemos $s0 igual a 2
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
            
            #switch (a){         // selecionamos um case, usando o valor de a
            # verificamos se a = 0
            addi  $t1, $zero, 0 # $t1  <- 0
            beq   $s0, $t1, l0  # se a=0, desvie para l0 (case 0:)
            # verificamos se a = 1
            addi  $t1, $zero, 1 # $t1 <- 1
            beq   $s0, $t1, l1  # se a=1, desvie para l1 (case 1:)
            # verificamos se a = 2
            addi  $t1, $zero, 2 # $t1 <- 2
            beq   $s0, $t1, l2  # se a=2, desvie para l2 (case 2:)
            # verificamos se a = 3
            addi  $t1, $zero, 3 # $t1 <- 3
            beq   $s0, $t1, l3  # se a=3, desvie para l3 (case 3:)
            # a próxima instrução será executada se a < 0 ou se a > 3
            # saimos da estrutura switch
            j     fim_switch
            # case 0:         // se a = 0
l0:
            # a = 10;           // fazemos a = 10
            addi  $s0, $zero, 10 # fazemos a = 10
            sw    $s0, 0($t0)   # atualizamo o valor de a na memória
            # break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
            # case 1:           // se a = 1 
l1:            
            # a = 20;           // fazemos a = 20
            addi  $s0, $zero, 20 # fazemos a = 20
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
            # break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
            # case 2:           // se a = 2
l2:            
            # a = 30;           // fazemos a = 30
            addi  $s0, $zero, 30 # fazemos a variável a = 30
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
            # break;            // saímos da estrutura switch-case
            j     fim_switch    # salto incondicional para o final da construção switch-case
            # case 3:           // se a = 3
l3:            
            # a = 40;           // fazemos a = 40
            addi  $s0, $zero, 40 # fazemos a variável a = 40
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
            # break;            // saímos da estrutura switch-case
            j     fim_switch
            # }                 // fim da construção switch-case
fim_switch:
            # return 0;         // termina o programa retornando 0
            addi  $v0, $zero, 17 # serviço 17 do sistema - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é zero
            syscall             # chamamos o serviço 17 do sistema com o valor 0
.data 
# int a;
varA:       .word 0             # variável varA = a, global


