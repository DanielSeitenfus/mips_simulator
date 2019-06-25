#*******************************************************************************
# exercicio050.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução goto, de um trecho de código,
#            do C para assembly. Veja o exercicio050.c. A variável varA é incrementada
#            em um laço infinito. As instruções addi  $v0, $zero, 17 e seguintes
#            não são executadas.
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
            # a = 0;      // inicializamos a com 0
            la    $t0, varA     # $t0 ,- endereço da variável a
            xor   $s0, $s0, $s0 # fazemos a cópia de a no registrador igual a 0
            sw    $s0, 0($t0)   # atualizamos a variável a na memória
            # para zerarmos um registrador poderíamos ter usado outras instruções:
            # add   $s0, $zero, $zero
            # addi  $s0, $zero, 0
            # sub   $s0, $s0, $s0
            # ...
l0:                             # inicio do laço infinito
            # a = a + 1;  // incrementamos a
            addi  $s0, $s0, 1   # incrementamos a variável a
            sw    $s0, 0($t0)   # atualizamos a variável a na memória
            # goto l0;    // desvio incondicional para l0
            j     l0            # desvio incondicional para l0           
            # return 0;   // fim do programa. Esta instrução não é executada
            addi  $v0, $zero, 17 # serviço 17 - exit2
            addi  $a0, $zero, 0 # valor de retorno do programa é 0 - sucesso
            syscall             # chamada ao serviço 17 do sistema - exit2
.data 
#   int a;
varA:       .word 0             # variável a

