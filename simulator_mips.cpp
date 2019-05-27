#include<stdio.h>
int reg[32],pc=0;
int main(){
	//apresenta o menu com as op��es
	printf("l <nome do arquivo> - Leitura de um arquivo .bin\n");
	printf("r <numero de instru��es> - Realiza a simula��o das instru��es em linguagem de m�quina\n");
	printf("d - Apresenta no terminal o conte�do atual dos registradores\n");
	printf("m <endere�o inicial> <n�mero de endere�os> - Este comando apresenta no terminal o conte�do da mem�ria.");
	char op;
	do{
		printf("\n-> ");
		scanf("%s", &op); //l� a op��o 
		switch(op){
			case 'l':
			break;
			case 'r':
				printf("r");
			break;
			case 'd':
				for(int i=0; i<32; i++){ //apresenta o conte�do atual dos registradores
					printf("Reg %d: %x\n",i,reg[i]); //%x converte o inteiro para hexadecimal
				}
				printf("pc: %x",pc);
			break;
			case 'm':
				printf("m");
			break;
		}
	}while(op!='s');
}
