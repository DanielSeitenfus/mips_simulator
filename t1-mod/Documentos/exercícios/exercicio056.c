//*******************************************************************************
// exercicio056.c                 Copyright (C) 2019 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// versão: 0.1
// Descrição: Exemplo de um código usando uma sentença com for. Neste exemplo,
//            a variável a é incrementada de 0 a 9.
// Documentação:
// Assembler: MARS
// Revisões:
// Rev #  Data           Nome   Comentários
// 0.1    12.04.2017     GBTO   versão inicial 
//*******************************************************************************
//       1         2         3         4         5         6         7         8
//345678901234567890123456789012345678901234567890123456789012345678901234567890 
 
int a;
int i;   

int main(void)
{
    a = 0;                // inicializamos a variável a com o valor zero
    for(i=0; i<9; i++){   // para i de 0 a 8 (repetimos 9 vezes o laço for)
        a = a + 1;        // incremente a 
    }                     //
    return 0;             // termina o programa retornando 0
}
 
