#*******************************************************************************
# exercicio067.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Este programa lê um arquivo e imprime os caracteres em um terminal
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    06.05.2019     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

################################################################################
# segmento de texto (programa)
.text
################################################################################



################################################################################
main:
################################################################################    


# abrimos o arquivo para a leitura
            li    $v0, 13       # serviço 13: abre um arquivo
            la    $a0, nome_arquivo # $a0 <- endereço da string com o nome do arquivo
            li    $a1, 0        # $a1 <- 0: arquivo será aberto para leitura
            li    $a2, 0        # modo não é usado. Use o valor 0.
            syscall             # abre o arquivo
            
# Se o arquivo não pode ser aberto, imprime uma mensagem de erro e termina o programa
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 ($v0 negativo)
            bne   $t0, $zero, arquivo_nao_pode_ser_aberto # se $v0 é negativo, o arquivo não pode ser aberto
            
# guardamos o descritor do arquivo aberto em descritor_arquivo
arquivo_aberto_com_sucesso:
            la    $t0, descritor_arquivo # $t0 <- endereço da variável descritor_arquivo
            sw    $v0, 0($t0)   # armazenamos na variável descritor_arquivo seu valor

# lemos o arquivo até preencher o buffer
leia_caracteres_arquivo:
            li    $v0, 14       # serviço 14: leitura do arquivo
            la    $t0, descritor_arquivo # $t0 <- endereço do descritor do arquivo
            lw    $a0, 0($t0)   # $a0 <- o valor do descritor do arquivo
            la    $a1, buffer   # $a1 <- endereço do buffer que guarda os carcateres lidos
            li    $a2, 255      # $a2 <- número máximo de carcateres lidos
            syscall             # fazemos a leitura de caracateres do arquivo para o buffer
            # verificamos se houve um erro de leitura
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 (erro de leitura)
            bne   $t0, $zero, erro_leitura # se $t0=1 desvie para erro de leitura
            # verificamos se chegamos ao final do arquivo
            beq   $v0, $zero, fim_arquivo # se $v0 = 0 chegamos ao final do arquivo
# senão imprime os carcateres do buffer entre parênteses
# Os registradores $v0 e $a1 serão usados no código a seguir.
# Armazenamos o conteúdo destes registradores em outros registradores
            move  $s0, $v0      # armazenamos o número de caracteres lidos em $s0
            move  $s1, $a1      # armazenamos o endereço do buffer em $s1
imprime_buffer:
            # imprime parêntese da esquerda
            li    $v0, 11       # serviço 11: imprime o caracter em $a0
            li    $a0, '('      # $a0 <- caractere parêtese da esquerda
            syscall             # imprime o caractere parêntese da esquerda
            # imprime caractere do buffer
            li    $v0, 11       # serviço 11: imprime o caractere em $a0
            lbu   $a0, 0($s1)   # carregamos o caractere do buffer para $a0
            syscall             # imprimimos o caractere do buffer
            # imprime carcatere da direita
            li    $v0, 11       # serviço 11: imprime o caracter em $a0
            li    $a0, ')'      # $a0 <- caractere parêntese da direita
            syscall             # imprime o caractere parêntese da direita
            # decrementa o número de caracteres do buffer
            addi  $s0, $s0, -1  # decrementa o número de carcateres do buffer
            addi  $s1, $s1, 1   # aponta para o próximo caracter do buffer
            bne   $s0, $zero, imprime_buffer # se restam caracteres no buffer, imprima
fim_impressao_caracteres:
            j     leia_caracteres_arquivo # senão, leia mais caracteres do arquivo

# imprime uma mensagem indicando que houve erro na leitura do arquivo e fecha o arquivo 
erro_leitura:
            li    $v0, 4        # serviço 4: imprime uma string
            la    $a0, str_erro_leitura # $a0 guarda o endereço da string a ser apresentada
            syscall             # apresentamos a string no terminal
            li    $s0, 1        # indica que houve erro na execução do programa
            j     fecha_arquivo # desvia para fecha_arquivo

# imprime uma mensagem dizendo que foi encontrado o fim do arquivo e fecha o arquivo.            
fim_arquivo:
            li    $v0, 4        # serviço 4: imprime uma string
            la    $a0, str_fim_arquivo # $a0 armazena o endereço da string a ser apresentada
            syscall             # apresenta a string 
            li    $s0, 0        # indica que o programa foi executado com sucesso
            j     fecha_arquivo # desvia para fecha_arquivo

# imprime uma mensagem dizendo que o arquivo não pode ser aberto e termina o programa            
arquivo_nao_pode_ser_aberto:
            li    $v0, 4        # serviço 4: imprime uma string
            la    $a0, str_arquivo_nao_pode_ser_aberto # $a0 armazena o endereço da string a ser apresentada
            syscall             # apresenta a string
            li    $s0, 1        # indica que houve erro na execução do programa
            j     fim_do_programa # desvia para fim_do_programa

# fechamos o arquivo
fecha_arquivo:
            li    $v0, 16       # serviço 16: fecha um arquivo
            la    $t0, descritor_arquivo # $t0 <- endereço do descritor do arquivo
            lw    $a0, 0($t0)   # carregamos em $a0 o descritor do arquivo
            syscall             # fechamos o arquivo

# terminamos o programa
fim_do_programa:
            li    $v0,4          # serviço 4: imprime uma string
            la    $a0, str_fim_do_programa # $a0 <- endereço da string a ser apresentada
            syscall             # apresenta a string
            move  $a0, $s0      # carrega em $a0 o código de retorno do programa
            li    $v0, 17       # serviço 17: termina o programa
            syscall             # termina o programa
################################################################################    



################################################################################
# segmento de dados
.data
buffer:           .space 256    # criamos um buffer com 256 bytes
descritor_arquivo: .space 4     # descritor do arquivo
nome_arquivo:     .asciiz "exercicio067.s" # nome do arquivo a ser aberto
# strings usadas no programa
str_erro_leitura: .asciiz "\n=== O arquivo não pode ser lido ===\n"
str_fim_arquivo:  .asciiz "\n=== O final do arquivo foi encontrado ===\n"
str_arquivo_nao_pode_ser_aberto: .asciiz "\n=== O arquivo não pode ser aberto ==\n"
str_fim_do_programa: .asciiz "\n=== Fim do programa ===\n"
################################################################################





