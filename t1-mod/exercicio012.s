#*******************************************************************************
# exercicio012.s               Copyright (C) 2017 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: programa para calcular o fatorial de um número: versão recursiva
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    ??/??/????     GBTO   versão inicial 
# 0.2    25/04/2018     GBTO   formatação e adição de comentários 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

.text                               # segmento de texto (código)
.globl main                         # main pode ser referenciado em outros arquivos


################################################################################
main:
#
# void main(void)
# {     
#     int k;
#     int fat;     
#     k = 5;     
#     fat = fatorial(k);     
#     printf("O fatorial de %d é %d\n",k, fat); 
#     return;
# }
#------------------------------------------------------------------------------    
# mapa da pilha
#     valor antigo do sp |          |
#                        ------------
#                 sp + 7 |    k     | 
#                 sp + 6 |    k     |    ^ endereços crescem
#                 sp + 5 |    k     |
#                 sp + 4 |    k     |
#                        ------------
#                 sp + 3 |   fat    |
#                 sp + 2 |   fat    |   | endereços decrescem
#                 sp + 1 |   fat    |   |
#                 sp + 0 |   fat    |   V
#                        ------------
#                        |          |
#  vamos atribuir as variáveis aos seguintes registradores
#  $t0 <- k
#  $t1 <- fat
#  O código apresentado a seguir pode ser otimizado
################################################################################
# prologo
            addiu $sp, $sp, -8      # ajusta a pilha para os elementos k e fat
# corpo do procedimento
            # k = 5
            li    $t0, 5            # k = $t0 <-5;
            sw    $t0, 4($sp)       # k = 5;
            # ajusta os parâmetros e chama a função
            add   $a0, $zero, $t0   # a0 <- k, a0 é argumento da função
            jal   fatorial          # chama a função fatorial
            # restaura o valor de $t0 = k
            lw    $t0, 4($sp)       # restaura o valor de k
            # atualiza o valor de fat
            move  $t1, $v0          # $t1 = fat <- fatorial(k)
            sw    $v0, 0($sp)       # fat = fatorial(k)
            # imprime o valor de k e o fatorial de k
            # vamos usar uma função simplificada para printf("O fatorial de %d é %d\n",k, fat);
            # equivalente a printf_simplificada(k, fat);
            move  $a0, $t0          # ajustamos os argumentos
            move  $a1, $t1          #
            jal   printf            # imprimimos o resultado
            # Os valores de $t0 e $t1 são indeterminados aqui, após a chamada
            # ao procedimento. Não restauramos os valores porque não serão usados
            # novamente 
#epílogo
            addiu $sp, $sp, 8       # restaura a pilha
# termina o programa
            li    $v0, 10           # serviço 10 - término do programa
            syscall                 # chamada ao sistema
# fim do procedimento main
################################################################################
    
    
    
################################################################################    
fatorial:
#------------------------------------------------------------------------------
# procedimento fatorial - retorna o fatorial de um inteiro
# n deve ser maior ou igual a zero
# n deve ser menor que 12 para registradores de 32 bits
#
# int fatorial(int n)
# {     
#     if(n==0) return 1;     
#     else return n*fatorial(n-1); 
# }
#------------------------------------------------------------------------------
# mapa da pilha
#     valor antigo do sp |          |
#                        ------------
#                 sp + 7 |   $ra    | 
#                 sp + 6 |   $ra    |    ^ endereços crescem
#                 sp + 5 |   $ra    |    |
#                 sp + 4 |   $ra    |    |
#                        ------------
#                 sp + 3 |   $a0    |
#                 sp + 2 |   $a0    |   | endereços decrescem
#                 sp + 1 |   $a0    |   |
#                 sp + 0 |   $a0    |   V
#                        ------------
#                        |          |
################################################################################
# prólogo
            addiu $sp, $sp, -8      # ajusta a pilha para receber 2 itens
            sw    $ra, 4($sp)       # salva o endereço de retorno
            sw    $a0, 0($sp)       # salva o argumento da função
# corpo do procedimento
            bne   $zero, $a0, n_nao_igual_0 # se n!=0  calcule n*fatorial(n-1)
n_igual_0:
            add   $v0, $zero, 1     # retorna 1 = 0!
            j fatorial_epilogo      # epílogo  do procedimento
n_nao_igual_0:
            # precisamos retornar n* fatorial(n-1)
            # n está na pilha
            # calculamos fatorial(n-1)
            addi  $a0, $a0, -1      # a0 <- n-1
            jal   fatorial          # chamamos fatorial(n-1)
            lw    $a0, 0($sp)       # a0 <- n, restauramos n
            mul   $v0, $a0, $v0     # v0 <- n*fatorial(n-1), v0 valor de retorno
            lw    $ra, 4($sp)       # restaura o endereço de retorno
# epílogo
fatorial_epilogo:
            add   $sp, $sp, 8       # restaura a pilha - eliminamos 2 itens
            jr    $ra               # retorna para o procedimento chamador
# fim do procedimento fatorial
################################################################################    
    
    

################################################################################  
printf:
# mapa da pilha
#     valor antigo do sp |          |
#                        ------------
#                 sp + 3 |   $a0    |
#                 sp + 2 |   $a0    |   | endereços decrescem
#                 sp + 1 |   $a0    |   |
#                 sp + 0 |   $a0    |   V
#                        ------------
#                        |          |
# Comentários:
#             Esta função foi simplificada. No exercicio063 apresentamos um 
#             código melhor
#
################################################################################
# prólogo
            addiu   $sp, $sp, -4
# corpo do procedimento
    # imprimimos a mensagem "O fatorial de"
            sw      $a0, 0($sp)     # guardamos na pilha $a0 = k
            li      $v0, 4          # serviço 4: imprime uma string
            la      $a0, str0_0     # $a0 <- endereço da string 
            syscall                 # chamada ao serviço do sistema
            # imprimimos k
            lw      $a0, 0($sp)     # $a0 <- k, carregamos da pilha
            li      $v0, 1          # serviço 1: imprime um inteiro
            syscall                 # chamada ao serviço do sistema
            # imprimimos " é "
            la      $a0, str0_1     # $a0 <- endereço da string
            li      $v0, 4          # serviço 4: imprime uma string
            syscall                 # chamada ao serviço do sistema
            # imprimimos fat
            move    $a0, $a1        # $a0 <- fat
            li      $v0, 1          # serviço 1: imprime um inteiro
            syscall                 # chamada ao serviço do sistema
            # imprimimos um fim de linha
            li      $a0, '\n'       # $a0 <- fim de linha
            li      $v0, 11         # serviço 11: imprime um caracter
            syscall
#epílogo
            addiu   $sp, $sp, 4
            # retornamos ao procedimento chamador
            jr      $ra
################################################################################ 
   
    
################################################################################            
# Dados estáticos do programa        
#------------------------------------------------------------------------------
.data
    str0_0: .asciiz "O fatorial de "
    str0_1: .asciiz " é "    
################################################################################    
