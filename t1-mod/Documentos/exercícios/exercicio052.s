#*******************************************************************************
# exercicio051.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo da tradução de uma instrução if - else, de um trecho de 
#            código, do C para assembly. Neste código a variável a é incrementada 
#            de 0 a 9. Segue o código em C.
#static int a;
#
#int main(void)
#{
#    a = 0;              // inicializa a variável a com zero
#l0:                     
#    a = a + 1;          // incremente a variável a
#    if(a = 9){          // se a = 9
#        goto l1;        // desvie incondicionalmente para l1
#    }else{              // senão
#        goto l0;        // desvie incondicionalmente para l0
#    }
#l1:
#    return 0;           // termina o programa retornando 0
#}
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
            #a = 0;
            la    $t0, varA     # $t0 é carregado com o endereço da variável a
            xor   $s0, $s0, $s0 # $s0 contém uma cópia de a. Fazemos a = 0
            sw    $s0, 0($t0)   # atualizamos o valor da variável a na memória
l0:                             #
            # a = a + 1;          // incremente a variável a
            addi  $s0, $s0, 1   # incrementamos o registrador com a cópia da variável a
            sw    $s0, 0($t0)   # armazenamos na variável a o novo valor
            # if(a = 9){          // se a = 9 desvie para código para condição verdadeira
            addi  $t1, $zero, 9 # carregamos 9 no registrador $t1
            beq   $s0, $t1, if_cond_verdadeira # se a == 9 desvie para if_cond_verdadeira
if_cond_falsa:            
            # senão execute o código para condição falsa
            # }else{              // senão
            # goto l0;            // desvie incondicionalmente para l0
            j     l0           # desvie incondicionalmente para l0
            # }
            j desvia_da_cond_verdadeira # desvie para não executar condição verdadeira
if_cond_verdadeira:             # código executado quando a condição em if é verdadeira
            #goto l1;             // desvie incondicionalmente para l1
            j l1                # desvie incodicionalmente para l1
desvia_da_cond_verdadeira:
l1:
            # return 0;           // termina o programa retornando 0
            addi  $v0, $zero, 17 # selecionamos o serviço 17 do sistema - exit2
            addi  $a0, $zero, 0 # o valor de retorno do programa é 0 - sucesso
            syscall             # realizamos uma chamada ao serviço 17 do sistema com o valor 0
.data 
# static int a;
varA:       .word 0             # variável varA = a, global. 

