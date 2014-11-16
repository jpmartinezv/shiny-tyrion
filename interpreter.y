%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char lexema[64];
void yyerror(char *);

typedef struct {
   char name[60];
   double value;
   int token;
}typeS;

typeS SymTable[100];
int nSym = 0;

typedef struct {
   int op;
   int a1;
   int a2;
   int a3;
}typeCod;

int cx = -1;
typeCod codeTable[100];

void genCode( int, int, int ,int );
int locateSymbol( char*, int );
void printSymTable();
void printCodeTable();

int nVarTemp = 0;
int genVarTemp();

void interpretedCode();

%}

%token ID INT FLOAT NUM
%token DEF PRINT ERROR IF ELSE WHILE FOR IN ITE LAMBDA NIL
%token ASSIGN DECLARE FUNCTION

%%

program         :   statements  
                | ;

statements      :   statement statements
                |   statement
                ;

statement       :   expression                                                          {printf("Expression\n");}
                |   ID {$$ = locateSymbol( lexema, ID );}':''=' expression {genCode( ASSIGN, $2, $5, '-');}
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
                |   NIL {$$ = locateSymbol(lexema, NIL);}
                |   LAMBDA '(' parameters ')' '{' statements '}'
                |   ITE '(' expr4 ',' expr4 ',' expr4 ')'
                ;

expr4           :   expr3
                |   expr4 '+' expr3 {int i = genVarTemp();}
                |   expr4 '-' expr3 {int i = genVarTemp();}
                ;

expr3           :   expr2
                |   expr3 '*' expr2 {int i = genVarTemp();}
                |   expr3 '/' expr2 {int i = genVarTemp();}
                ;

expr2           :   expr1
                |   expr2 '=''=' expr1 {int i = genVarTemp();}
                |   expr2 '!''=' expr1 {int i = genVarTemp();}
                |   expr2 '<''=' expr1 {int i = genVarTemp();}
                |   expr2 '>''=' expr1 {int i = genVarTemp();}
                |   expr2 '<' expr1 {int i = genVarTemp();}
                |   expr2 '>' expr1 {int i = genVarTemp();}
                ;

expr1           :   num {$$ = locateSymbol(lexema, NUM);}
                |   ID  {$$ = locateSymbol(lexema, ID);}
                |   '(' expr4 ')' {int i = genVarTemp();}
                |   '?' ID '(' parameters ')' {int i = genVarTemp();}
                ;

num             :   INT
                |   FLOAT
                ;

%%

int genVarTemp()
{
   char tmp[60];
   sprintf( tmp, "T%d", nVarTemp++ );
   return locateSymbol( tmp, ID);
}

void genCode( int op, int a1, int a2, int a3 )
{
   cx++;
   codeTable[cx].op = op;
   codeTable[cx].a1 = a1;
   codeTable[cx].a2 = a2;
   codeTable[cx].a3 = a3;
}

int locateSymbol(char *name, int token)
{
   int i;
   for( i = 0; i < nSym; i++ )
      if( !strcasecmp( SymTable[i].name, name ) )
         return i;
   
   strcpy( SymTable[nSym].name, name );
   SymTable[nSym].token = token;
   if( token == ID )
      SymTable[nSym].value = 0.0;
   if( token == NUM )
      sscanf( name, "%lf", &SymTable[nSym].value );
   nSym++;
   
   return nSym - 1;
}

void printSymTable()
{
   int i;
   printf("ID\tName\t Valor\t\t\tToken\n");
   for( i = 0; i< nSym; i++ )
      printf("%d\t%s\t%.6lf\t\t%d\n", i, SymTable[i].name, SymTable[i].value, SymTable[i].token);
}

void printCodeTable()
{
   int i, op, a1, a2, a3;
   printf("ID\tcod\ta1\ta2\ta3\n");
   for( i = 0; i <= cx; i++ ){
      op = codeTable[i].op;
      a1 = codeTable[i].a1;
      a2 = codeTable[i].a2;
      a3 = codeTable[i].a3;
      printf("%d\t%d\t%d\t%d\t%d\n", i, op, a1, a2, a3);
   }
}

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
      
   puts("TABLA DE SIMBOLOS");
   printSymTable();
   puts("");
   puts("TABLA DE CODIGOS");
   printCodeTable();
}
