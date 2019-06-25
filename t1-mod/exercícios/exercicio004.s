#*******************************************************************************
# exercicio004.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: a[2] = a[4] + a[1]. 
#            a é um vetor de inteiros com 10 elementos. Inicialmente fazemos os
#            elementos iguais a 1,2, ... 10. O índice do vetor vai de 0 a 9.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    26/03/18   GBTO   versão inicial
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #
.text
            # ...
            # a[2] = a[4] + a[1];
            # carregamos o endereço base do vetor e os elementos a[4] e a[1]
            la    $t0, vetorA        # $t0 <- endereço base do vetor a
            lw    $t1, 16($t0)        # $t1 <- a[4]
            lw    $t2, 4($t0)        # $t2 <- a[1]
            # realizamos a soma a[4] + a[1]
            add   $t3, $t1, $t2    # $t3 <- a[4] + a[1]
            # armazenamos o resultado da soma no elemento a[2]. No cálculo do
            # endereço do elemento, usamos a seguinte fórmula:
            # endereço_elemento_i = endereço_base + deslocamento
            # deslocamento = i * tamanho_em_bytes_do_elemento
            # $t0 possui o endereço base e 8 é o deslocamento para a[2]
            sw    $t3, 8($t0)        # a[2] <- a[4] + a[1]
            # ...
.data
# a é um vetor de inteiros (com 4 bytes) com os valores 0, 1, 2,..., 9
vetorA: .word 1, 2, 3, 4, 5, 6, 7, 8, 9

