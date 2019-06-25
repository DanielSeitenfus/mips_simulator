#*******************************************************************************
# exercicio051.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução if, de um trecho de código,
#            do C para assembly (exercicio051.c). Neste código a variável 
#            a é incrementada de 0 a 9. Segue o código em C.
#    a = 0;
#l0:
#    a = a + 1;
#    if(a == 9) goto l1;
#    goto l0;
#l1:
#    return 0;*/
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    12.04.2017     GBTO   versão inicial 
# 0.2    06.05.2019     GBTO   corrigida instrução addi  $0, $s0, 1 para addi  $s0, $s0, 1
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
            #a = 0; // inicializamos a variável a
            la    $t0, varA     # $t0 <- endereço da variável a
            xor   $s0, $s0, $s0 # $s0 <- 0. $s0 guarda uma cópia da variável a
            sw    $s0, 0($t0)   # atualizamos a variável a na memória
l0:                             #
            #a = a + 1; // incrementamos a variável a         
            addi  $s0, $s0, 1   # incrementamos a variável a
            sw    $s0, 0($t0)   # atualizamos o valor da variável a, na memória
# Se a condição de if é verdadeira, executamos o código associado ao if. Se a 
# condição de if é falsa, o código associado ao if não será executado.
            #if(a == 9) goto l1; // se a == 9 desvie para l1
            addi  $t1, $zero, 9 # carregamos 9 no registrador $t1
            beq   $s0, $t1, l1  # se a == 9 então desvie para l1
# As instruções após o if são executadas            
            #goto l0;  // senão, desvie incondicionalmente para l0
            j l0                # Esta instrução é executada se a != 9. Desvie para l0
l1:                             #
            #return 0; // termine o programa
            addi  $v0, $zero, 17 # serviço 17 - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0 - sucesso
            syscall             # fazemos uma chamada ao serviço 17 do sistema - exit2
.data 
# int a;
varA:       .word 0             # variável varA =  a, global

