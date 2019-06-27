#*******************************************************************************
# exercicio002.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: a = b + c + d + e;
#            b, c, d e e são constantes inteiras iguais a 1, 2, 3 e 4, respectivamente.
#            a é uma variável inteira.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    26/03/18   GBTO   versão inicial
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

.text       #segmento de texto
.globl      main
main: 
            # a = b + c + d + e;
            # Usamos os seguintes registradores
            # $s1 <- a
            # $s2 <- b
            # $s3 <- c
            # $s4 <- d
            # $s5 <- e
            
            # carregamos uma copia dos valores da variáveis nos registradores
            la    $t0, variavelB    # carregamos b em $s2
            lw    $s2, 0($t0)       #
            la    $t0, variavelC    # carregamos c em $s3
            lw    $s3, 0($t0)       #
            la    $t0, variavelD    # carregamos d em $s4
            lw    $s4, 0($t0)       #
            la    $t0, variavelE    # carregamos e em $s5
            lw    $s5, 0($t0)       #
            # fazemos a soma de b+c+d+e
            add   $t0, $s2, $s3     # $t0 = b + c
            add   $t1, $s4, $s5     # $t1 <- d + e
            add   $s1, $t0, $t1     # $s1 <-(b + c) + (d + e)
            # guardamos o resultado da soma na variável a, na memória
            la    $t0, variavelA
            sw    $s1, 0($t0)
            # ...

.data       # segmento da dados
variavelA:  .space 4                # variável inteira a
variavelB:  .word  1                # constante inteira b, igual a 1
variavelC:  .word  2                # constante inteira c, igual a 2
variavelD:  .word  3                # constante inteira d, igual a 3
variavelE:  .word  4                # constante inteira e, igual a 4
