#*******************************************************************************
# exercicio039.s               Copyright (C) 2015 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo que mostra como: 
#            (a) carregar um dado da memória para registradores do processador MIPS e 
#            (b) guardar um dado de um registrador para a memória
#            Como dados usamos uma palavra (4 bytes), uma meia palavra (2 bytes)
#            e um byte.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    24/08/16   GBTO   versão inicial 
# 0.1.1  31/08/16   GBTO   formatação do código e inclusão de comentários
# 0.1.2  26/03/18   GBTO   Revisão dos comentários
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #
.text
.globl      main
main:
# Exemplo de como carregar um dado de um endereço de memória para registradores
            # carregamos o endereço do dado
            la    $s0, memory   # $s0 <- endereço base da variável memory
            # carrega com extensão do sinal
            lw    $t0, 0($s0)   # $t0 <- mem[$s0+0] = memory
            # poderia ter usado a pseudo instrução lw, $t0, memory
            lh    $t1, 0($s0)   # $t1 <- mem[$s0+0] = val(memory). Com extensão do sinal.
            lb    $t2, 0($s0)   # $t2 <- mem[$s0+0] = val(memory). Com extensão do sinal.
            # carrega sem extensão do sinal
            lhu   $t3, 0($s0)   # $t3 <- mem[$s0+0] = val(memory). Sem extensão do sinal.
            lbu   $t4, 0($s0)   # $t4 <- mem[$s0+0] = val(memory). Sem extensão do sinal.
            
# Exemplo de como armazenar um dado de um registrador para um endereço da memória            
            # armazena em dataw a palavra 0xABCDE080
            la    $s0, dataw    # $s0 <- endereço de dataw
            sw    $t0, 0($s0)   # armazena no endereço mem[$s0+0] = $t0 = 0xABCDE080
            # poderiamos ter usado a pseudoinstrução:
            # sw    $t0, dataw  # mem[dataw] <- $t0. Pseudo instrução.
            # armazena os dois bytes menos significativos de $t1 (0xE080) em datah
            la    $s0, datah    # guarda em $s0 o endereço de datah
            sh    $t1, 0($s0)   # guarda no endereço de memmória mem[$s0+0] a meia palavra de $t1
            # poderiamos ter usado a pseudoinstrução:
            # sh    $t1, datah  # mem[datah] <- $t0. Pseudo instrução.
            # armazena o byte menos significativo de $t2 em datab
            la    $s0, datab    # armazena em $s0 o endereço de datab
            sb    $t2, 0($s0)   # guarda no endereço mem[$s0+0] o byte menos significativo de $t2
            # poderiamos ter usado a seguinte pseudoinstrução
            # sb    $t2, datab  # mem[datab] <- $t2. Pseudo instrução.
    
.data 
memory:     .word  0xABCDE080   # Os dados são guardados no formato little enddian

dataw:      .space 4            # Reservamos no endereço dataw 4 bytes: uma palavra
datah:      .space 2            # Reservamos no endereço datah 2 bytes: uma meia palavra
datab:      .space 1            # Reservamos no endereço datab 1 byte.
