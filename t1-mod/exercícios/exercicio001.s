#*******************************************************************************
# exercicio001.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: traduzindo a = b + c. 
#            b e c são constantes inteiras iguais a 1 e 2, respectivamente.
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

.text           
main: 
            # traduzindo a = b + c.
            #            Usamos os seguintes registradores           
            #            $s1 <- a
            #            $s2 <- b
            #            $s3 <- c
            # carregamos uma copia dos valores da variáveis nos registradores
            la    $t0, variavelB    # carregamos a variável b em $s2
            lw    $s2, 0($t0)       #
            la    $t0, variavelC    # carregamos a variável c em $s3
            lw    $s3, 0($t0)       #
            # fazemos a soma b + c
            add   $s1, $s2, $s3     # $s1 <- b + c = a
            la    $t0, variavelA    # salvamos $s1 = b+c em a
            sw    $s1, 0($t0)       #

.data
variavelA:  .space 4                # variável inteira a
variavelB:  .word  1                # constante inteira b, igual a 1
variavelC:  .word  2                # constante inteira c, igual a 2
