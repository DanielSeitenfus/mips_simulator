//*******************************************************************************
// exercicio0.c                 Copyright (C) 2019 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// versão: 0.1
// Descrição: Exemplo de um programa em C, com um desvio incondicional. Uma variável
//            a é incrementada em um laço infinito. A linha return 0 não deve ser
//            executada.
// Documentação:
// Assembler: MARS
// Revisões:
// Rev #  Data           Nome   Comentários
// 0.1    12.04.2017     GBTO   versão inicial 
//*******************************************************************************
//       1         2         3         4         5         6         7         8
//345678901234567890123456789012345678901234567890123456789012345678901234567890 
 
int a;

int main(void)
{
    a = 0;      // inicializamos a com 0
l0:             // inicio do laço infinito
    a = a + 1;  // incrementamos a
    goto l0;    // desvio incondicional para l0
    return 0;   // fim do programa. Esta instrução não é executada
}
 
