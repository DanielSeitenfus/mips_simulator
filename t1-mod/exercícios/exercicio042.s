#*******************************************************************************
# exercicio042.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Traduzindo a sentença a =  b + 1 e c = b + 1000000. 
#            a, b e c são inteiros.
#            b -> constante igual a 1234.
#            a e c são variáveis.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    24/08/16   GBTO   versão inicial 
# 0.1.1  28/03/17   GBTO   formatação do código e inclusão de comentários
# 0.2    26/03/18   GBTO   adicionada a tradução da sentença c = b + 1000000
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #
.text       # segmento de dados
.globl main
main:
            # ...
            # carregamos em um registrador uma cópia do valor de b
            la    $t0, variavelB    # $t0 <- endereço da variável b
            lw    $t1, 0($t0)       # $t1 <- valor da variável b
           
            # realizamos a computação de b + 1
            addi  $t2, $t1, 1       # $t2 <- b + 1
            
            # realizamos a computação de b + 1000000
            # Contruímos a constante 1000000 em um registrador ($t3). Seu valor
            # é muito grande para um valor imediato na operação addi
            # este valor é igual a 0x000F_4240. 
            lui   $t3, 0x000F       # $t0 <- 0x000F_0000
            ori   $t3, $t3, 0x4240  # $t0 <- 0x000F_4240
            # poderíamos ter usado a seguinte pseudoinstrução
            # li $t3, 1000000
            # realizamos a soma de b com a constante 1000000
            add   $t4, $t1, $t3
            
            # salvamos o valor de b+1 (no registrador $t2) em a
            la    $t0, variavelA    # $t0 <- endereço da variável a
            sw    $t2, 0($t0)       # a <- $t2 = b + 1 
            
            # salvamos o valor de b+1000000 (no registrador $t4) na variável c
            la    $t0, variavelC    # $t0 <- endereço da variável c
            sw    $t4, 0($t0)       # c <- $t4 = b + 1000000

.data       # segmento de dados       
variavelA:  .space 4                # variável a
variavelB:  .word 1234              # constante b = 1234
variavelC:  .space 4                # variavel c
