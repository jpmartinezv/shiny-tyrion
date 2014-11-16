%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char lexema[64];
void yyerror(char *);

%}

%token ID INT FLOAT
%token DEF PRINT ERROR IF ELSE WHILE FOR IN ITE LAMBDA NIL

%%

program         :   statements  
                | ;

statements      :   statement statements
                |   statement
                ;

statement       :   expression                                                          {printf("Expression\n");}
                |   ID ':''=' expression                                                {printf("Variable Assignment\n");}
                |   DEF ID '=' expression                                               {printf("Var. Declaration\n");}
                |   DEF ID '(' parameters ')' '{' statements '}'                        {printf("Function Definition\n");}
                |   PRINT expression                                                    {printf("Print expression to console\n");}
                |   ERROR expression                                                    {printf("Print expression and exit\n");}
                |   IF '(' expression ')' '{' statements '}' ELSE '{' statements '}'    {printf("If-else statement\n");}
                |   WHILE '(' expression ')' '{' statements '}'                         {printf("While loop\n");}
                |   FOR '(' ID IN expr4')' '{' statements '}'                           {printf("For loop\n");}
                ;

parameters      :   expression ',' parameters
                |   expression
                | ;

expression      :   expr4
                |   NIL
                |   LAMBDA '(' parameters ')' '{' statements '}'
                |   ITE '(' expr4 ',' expr4 ',' expr4 ')'
                ;

expr4           :   expr3
                |   expr4 '+' expr3
                |   expr4 '-' expr3
                ;

expr3           :   expr2
                |   expr3 '*' expr2
                |   expr3 '/' expr2
                ;

expr2           :   expr1
                |   expr2 '=''=' expr1
                |   expr2 '!''=' expr1
                |   expr2 '<''=' expr1
                |   expr2 '>''=' expr1
                |   expr2 '<' expr1
                |   expr2 '>' expr1
                ;

expr1           :   num
                |   ID              {printf("ID\n");}
                |   '(' expr4 ')'
                |   '?' ID '(' parameters ')'
                ;

num             :   INT
                |   FLOAT
                ;

%%

void yyerror(char *mgs)
{
    printf("error: %s",mgs);
}

int reservedWord(char lexema[])
{
   if(strcasecmp(lexema, "def") == 0) return DEF;
   if(strcasecmp(lexema, "print") == 0) return PRINT;
   if(strcasecmp(lexema, "error") == 0) return ERROR;
   if(strcasecmp(lexema, "if") == 0) return IF;
   if(strcasecmp(lexema, "else") == 0) return ELSE;
   if(strcasecmp(lexema, "while") == 0) return WHILE;
   if(strcasecmp(lexema, "for") == 0) return FOR;
   if(strcasecmp(lexema, "in") == 0) return IN;
   if(strcasecmp(lexema, "ite") == 0) return ITE;
   if(strcasecmp(lexema, "lambda") == 0) return LAMBDA;
   if(strcasecmp(lexema, "null") == 0) return NIL;
   return ID;
}

int yylex()
{
    char c ,t;
    
    while(1)
    {
        c=getchar();
    
        if( c == '\n' ) continue;
        if( isspace( c ) ) continue;
        
        if(isalpha(c))
        {
            int i=0;
            do
            {
                lexema[i++]=c;
                c=getchar();
            }while(isalnum(c));
            
            ungetc(c,stdin);
            lexema[i]=0;
            return reservedWord(lexema); 
        }
        else if(isdigit(c))
        {
            int i = 0;
            do
            {
                lexema[i++] = c;
                c = getchar();
            }while(isdigit(c));
            
            if(!isalpha(c))
            {
                if(c == '.')
                {
                    do
                    {
                        lexema[i++] = c;
                        c = getchar();
                    }while(isdigit(c));
                    
                    if( !isalpha(c))
                    {
                        ungetc(c, stdin);
                        lexema[i] == 0;
                        return FLOAT;
                    }
                }
                else
                {
                    ungetc(c, stdin);
                    lexema[i] = 0;
                    return INT;
                    
                }
            }
        }
        return c;			
    }
}
void main()
{
    if(!yyparse())
        printf("Sintaxis de lenguaje valida\n");
    else
        printf("Sintaxis de lenguaje invalida\n");
}
