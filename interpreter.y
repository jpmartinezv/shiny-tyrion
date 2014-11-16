%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char lexema[254];
void yyerror(char *);

%}

%token ID INT FLOAT

%%

instr: ID '=' expr4 | expr4;

expr4: 
     expr3 | 
     expr4 '+' expr3 |
     expr4 '-' expr3;

expr3: 
     expr2 |
     expr3 '*' expr2 |
     expr3 '/' expr2;

expr2:
     expr1 |
     expr2 '^' expr1 |
     expr2 '%' expr1;

expr1:
     num | 
     ID |
     '(' expr4 ')';

num:
   INT| FLOAT;

%%

void yyerror(char *mgs){
    printf("error: %s",mgs);
}

int yylex(){ 
    char c ,t;
    
    while(1){
        c=getchar();
    
        if( c == '\n' ) continue;
        if( isspace( c ) ) continue;
        
        if(isalpha(c)){
            int i=0;
            do{
                lexema[i++]=c;
                c=getchar();
            }while(isalnum(c));
            
            ungetc(c,stdin);
            lexema[i]=0;
            return ID; 
        }
        else if(isdigit(c)) {
            int i = 0;
            do{
                lexema[i++] = c;
                c = getchar();
            }while(isdigit(c));
            
            if(!isalpha(c))
            {
                if(c == '.'){
                    lexema[i++] = c;
                    do{
                        lexema[i++] = c;
                        c = getchar();
                    }while(isdigit(c));
                    
                    if( !isalpha(c)){
                        ungetc(c, stdin);
                        lexema[i] == 0;
                        return FLOAT;
                    }
                }
                else{
                    ungetc(c, stdin);
                    lexema[i] == 0;
                    return INT;
                    
                }
            }
        }
        return c;			
    }
}
void main(){
    if(!yyparse())
        printf("Sintaxis de lenguaje valida\n");
    else
        printf("Sintaxis de lenguaje invalida\n");
}

