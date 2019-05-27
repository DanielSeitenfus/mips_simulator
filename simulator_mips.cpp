#include<stdio.h>
int reg[32],pc=0;
char instrucao[50]; //cria um vetor fixo para armazenar 50 instru��es (com 10 bites cada, 8 bites para instru��o e 2 para o '\n')

int identificaOpCode(int pos1, int pos2){
	/*
	00 - 0
	01 - 1
	10 - 2
	11 - 3
	*/
	if(instrucao[pos1]=='0'){
		if(instrucao[pos2]=='0'){
			return 0; 
		}else{
			return 1;
		}
	}else if(instrucao[pos1]=='1'){
		if(instrucao[pos2]=='0'){
			return 2;
		}else{
			return 3;
		}
	}
}
int main(){
	//apresenta o menu com as op��es
	printf("l <nome do arquivo> - Leitura de um arquivo binario\n");
	printf("r <numero de instrucoes> - Realiza a simulacao das instrucoes em linguagem de maquina\n");
	printf("d - Apresenta no terminal o conteudo atual dos registradores\n");
	printf("m <endereco inicial> <numero de enderecos> - Este comando apresenta no terminal o conteudo da memoria.");
	char op;
	do{
		printf("\n-> ");
		scanf("%s", &op); //l� a op��o 
		switch(op){
			case 'l':{
				char nomeArquivo[30];
				scanf("%s", nomeArquivo);
				FILE *arq;
				arq=fopen(nomeArquivo,"rb"); //abre arquivo .bin
				if(arq==NULL){
					printf("Erro na abertura do arquivo");
				}else{
					printf("arquivo aberto. \n");
				}
				int contador=0;
				while(!feof(arq)){ //executa at� que chegue ao final do arquivo
					int result = fread(&instrucao[contador], sizeof(char),10, arq); //l� linha por linha
					contador +=10; //incrementa 10 porque cada instru��o ocupa esse espa�o
				}			
				printf("%s", instrucao);
				break;
			}
			case 'r':{ //decodifica��o e executa��o
				int numInstrucoes;
				scanf("%d", &numInstrucoes); //l� a quantidade de instru��es a serem executadas
				for(int i=0; i<numInstrucoes; i++){
					switch(identificaOpCode(pc,pc+1)){ //identifica a instru��o a ser executada
						/* 
						0 = lb
						1 = sb
						2 = add
						3 = jump
						*/
						case 0:{ //aqui deve ser realizado a execu��o, os printfs s�o o significado de cada instru��o decodificada
							printf("Carrega um byte de um endere�o da memoria (end) para um registrador (reg)\n");
							break;
						}
						case 1:{
							printf("Armazene um byte de um registrador (reg) para um endere�o na memoria (mem)\n");
							break;
						}
						case 2:{
							printf("some os registradores fontes (reg_f1 e reg_f2) e guarde o resultado no registrador destino (reg_d)\n");
							break;
						}
						case 3:{
							printf("desvie o programa para o endereco end\n");
							break;
						}
					}
					pc+=10;
				}
				break;
			}
			case 'd':{
				for(int i=0; i<32; i++){ //apresenta o conte�do atual dos registradores
					printf("Reg %d: %x\n",i,reg[i]); //%x apresente inteiro em hexadecimal
				}
				printf("pc: %x",pc);
				break;
			}		
			case 'm':{
				break;
			}
		}
	}while(op!='s');
}
