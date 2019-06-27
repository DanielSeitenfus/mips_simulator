#*******************************************************************************
# exercicio041.s               Copyright (C) 2015 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Traduzindo a sentenças a = b. As variáveis são números inteiros de
#            32 bits.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    24/08/16   GBTO   versão inicial 
# 0.1.1  28/03/17   GBTO   formatação do código e inclusão de comentários
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #
.text
.globl      main
main:
            # ...
            # traduzindo a = b;
            # carregamos em um registrador uma cópia do valor de b
            la    $t0, variavelB    # $t0 <- endereço da variável B
            lw    $t1, 0($t0)       # $t1 <- valor da variável B
            # salvamos o valor de b (no registrador $t1) em a
            la    $t0, variavelA    # $t0 <- endereço da variável A
            sw    $t1, 0($t0)       # A <- $t0 = B
            # ...
.data
variavelA:  .space 4
variavelB:  .word 1234
