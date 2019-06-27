#*******************************************************************************
# exercicio040.s               Copyright (C) 2015 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Traduzindo as sentenças A = 10; e B = 1000000. A e B são inteiros,
#            com sinal, de 32 bits.
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
            .globl main
main:
            # ...
            # Nesta primeira parte do exemplo, atribuímos um valor constante
            # que pode ser escrito com 16 bits
            # A = 10;               # este valor é igual a 0x0000_000A
            addiu $t0, $zero, 10    # $t0 <- 10
            # poderíamos ter usado a seguinte pseudoinstrução
            # li $t0, 10            # $t0 <- 10
            la    $t1, variavelA    # $t1 <- endereço da variável A
            sw    $t0, 0($t1)       # A <- $t0 = 10
            # Nesta segunda parte do exemplo, atribuímos à uma variável
            # um valor constante que pode ser escrito com 32 bits
            # B = 1000000;          # este valor é igual a 0x000F_4240. 
            lui   $t0, 0x000F       # $t0 <- 0x000F_0000
            ori   $t0, $t0, 0x4240  # $t0 <- 0x000F_4240
            # poderíamos ter usado a seguinte pseudoinstrução
            # li $t1, 1000000
            la    $t1, variavelB    # $t1 <- endereço da variável B
            sw    $t0, 0($t1)       # B <- $t0 = 1000000
            # ...
.data
variavelA:  .space 4                # variável A
variavelB:  .space 4                # variável B
