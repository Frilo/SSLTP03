%code top{
#include <stdio.h>
#include "scanner_flex.h"
#include "symbol.h"
#include "semantic.h"
#include "errores.h"
}
%code provides{
void yyerror(const char *);
extern int yylexerrs;
int yynerrs;
}
%defines "parser_bison.h"
%output "parser.c"
%token PROG FIN VAR COD DEF LEER ESC ID CTE ASIG
%left '+' '-'
%left '/' '*'
%precedence NEG 
%define api.value.type {char *}
%define parse.error verbose

%%
todo	: mini { if (yynerrs || yylexerrs || errSeman) {YYABORT;} else {YYACCEPT;}}
mini 	: PROG {empezar();} programa FIN {terminar();}
		;
programa: VAR definiciones COD sentencias 
		| VAR COD sentencias
		;
definiciones: definiciones DEF ID '.' {if(!validarID($ID))YYERROR;declararID($ID);}
		| DEF ID '.' {declararID($ID);/*No hace falta validar la 1era declaracion*/}
		| error '.'
		;
sentencias: sentencias sentencia '.'
		| sentencia '.'
		;
sentencia: LEER'(' identificadores ')'
		| ESC '(' expresiones ')'
		| id ASIG expresion  {asignar($expresion, $id); $id= $expresion;}
		| error
		; 
identificadores: identificadores ',' id {leerID($id);}
		| id {leerID($id);}
		;
expresiones: expresiones ',' expresion {escribirExp($1);}
		| expresion  {escribirExp($1);}
		;
expresion: expresion '+' expresion {$$ = aplOperacion("ADD", $1, $3, declararTmp()->lexema);}	
		| expresion '-' expresion {$$ = aplOperacion("SUBS", $1, $3, declararTmp()->lexema);}	
		| expresion '*' expresion {$$ = aplOperacion("MULT", $1, $3, declararTmp()->lexema);}
		| expresion '/' expresion {$$ = aplOperacion("DIV", $1, $3, declararTmp()->lexema);}
		| CTE
		| '(' expresion ')' {$$ = $2;}
		| id
		| '-' expresion %prec NEG  {$$ = aplOperacion("INV", $2, "", declararTmp()->lexema);}	
		;
		
id		: ID {if(!verificarID($1)) YYERROR;}

		
%%

