#include<stdio.h>
int reg[32],pc=0;
int main(){
	//apresenta o menu com as opções
	printf("l <nome do arquivo> - Leitura de um arquivo .bin\n");
	printf("r <numero de instruções> - Realiza a simulação das instruções em linguagem de máquina\n");
	printf("d - Apresenta no terminal o conteúdo atual dos registradores\n");
	printf("m <endereço inicial> <número de endereços> - Este comando apresenta no terminal o conteúdo da memória.");
	char op;
	do{
		printf("\n-> ");
		scanf("%s", &op); //lê a opção 
		switch(op){
			case 'l':
			break;
			case 'r':
				printf("r");
			break;
			case 'd':
				for(int i=0; i<32; i++){ //apresenta o conteúdo atual dos registradores
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
