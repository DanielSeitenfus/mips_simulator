#*******************************************************************************
# exercicio005.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: traduzindo o seguinte trecho de código em C
#            i = 1;
#            j = 2;
#            k = 0;
#            a[k] = a[i] + a[j]
#            ----------
#            i, j e k são variáveis inteiras
#            a é um vetor de inteiros com 10 elementos. Inicialmente fazemos os
#            elementos iguais a 1,2, ... 10. O índice do vetor vai de 0 a 9. O
#            tamanho dos elementos do vetor a é de 4 bytes.
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
            # ...
            # traduzindo o seguinte trecho de código em C
            # i = 1;
            # j = 2;
            # k = 0;
            # a[k] = a[i] + a[j]
            # ...  
            # vamos carregar i,j e k nos seguintes registradores
            # $s0 <- i
            # $s1 <- j
            # $s2 <- k
            # i = 1;
            addi  $s0, $zero, 1
            # j = 2;
            addi  $s1, $zero, 2
            # k = 0;
            addi  $s2, $zero, 0
            # ou add $s2, $zero, $zero
            # ou xor $s2, $s2, $s2
            # atualizamos o valor das variáveis i, j e k
            
            # carregamos $s0 em i
            la    $t0, variavel_I   # carregamos o endereço da variável i: $t0 <- end(i)
            sw    $s0, 0($t0)       # atualizamos o valor da variável i
            # carregamos j em $s1
            la    $t0, variavel_J   # carregamos o endereço da variável j
            sw    $s1, 0($t0)       # atualizamos o valor da variável j
            # carregamos k em $s2
            la    $t0, variavel_K   # carregamos o endereço da variável k
            sw    $s2, 0($t0)       # atualizamos o valor da variável k
    

            # traduzindo a[k] = a[i] + a[j];  
            # carregamos par registradores  a[i] e a[j]
            # serão apresentadas 3 formas para o cálculo do endereço efetivo dos elementos
            # do vetor a. Usamos a seguinte fórmula:
            # endereço_efetivo_elemento_i = endereço_base + deslocamento
            # deslocamento = i * tamanho_elemento_vetor_em_bytes
            # Neste exemplo, o tamanho do elemento é 4 bytes porque estamos trabalhando
            # com inteiros.
            # i é o índice do vetor, começando em 0
            
            # carregamos o endereço base do vetor a
            la    $t0, vetorA       # $t0 <- endereço base do vetor a 
            
            # carregamos a[i]  
            # calculamos o endereço efetivo do elemento a[i]. No cálculo do deslocamento
            # usamos duas somas.
            add   $t1, $s0, $s0     # $t1 <- i*2
            add   $t1, $t1, $t1     # $t1 <- i * 4
            add   $t1, $t0, $t1     # $t1 <- endereço efetivo de a[i]
            # carregamos o elemento a[i]
            lw    $t2, 0($t1)       # $t2 <- a[i]

            
            # carregamos a[j]
            # calculamos o endereço efetivo do elemento a[j]. No cálculo do deslocamento
            # usamos um deslocamento lógico. Esta é a forma preferida quando 
            # trabalhamos com elementos inteiros.            
            sll   $t1, $s1, 2       # $t1 <- j * 4
            add   $t1, $t0, $t1     # $t1 <- endereço de a[j]
            lw    $t3, 0($t1)       # $t3 <- a[j]
            
            # fazemos a soma de a[i] com a[j]
            add   $t4, $t2, $t3     # $t4 <- a[i]+a[j]
            
            # armazenado o resultado em a[k]
            # calculamos o endereço efetivo do elemento a[k]. No cálculo do deslocamento
            # usamos a instrução de multiplicação.
            addi  $t1, $zero, 4       # criamos a constante 4 no registrador $t1
            mul   $t1, $s2, $t1     # $t1 <- k * 4
            # podemos usar a pseudo-instrução
            # mul   $t1, $s2, 4     # $t1 <- k * 4
            add   $t1, $t0, $t1     # $t1 <- endereço de a[k]
            sw    $t4, 0($t1)       # a[k] <- a[i] + a[j]
            # ... 
.data 
variavel_I: .space 4                # variável i
variavel_J: .space 4                # variável j
variavel_K: .space 4                # variável k
# vetor de inteiros, com os valores iniciais 1, 2, ..., 10
vetorA:     .word  1, 2, 3, 4, 5, 6, 7, 8, 9, 10 
