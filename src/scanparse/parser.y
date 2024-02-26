%{


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "palm/memory.h"
#include "palm/ctinfo.h"
#include "palm/dbug.h"
#include "palm/str.h"
#include "ccngen/ast.h"
#include "ccngen/enum.h"
#include "global/globals.h"

static node_st *parseresult = NULL;
extern int yylex();
int yyerror(char *errname);
extern FILE *yyin;
void AddLocToNode(node_st *node, void *begin_loc, void *end_loc);


%}

%union {
 char               *id;
 int                 cint;
 enum BinOpType     cbinop;
 enum BasicType     ctype;
 node_st             *node;
}

%locations

%token BRACKET_L BRACKET_R CURLY_BRACKET_L CURLY_BRACKET_R
       SEMICOLON QUOTE
%token MINUS PLUS STAR SLASH PERCENT
%token LET RETURN
%token TRUEVAL FALSEVAL
%token INT BOOL STRING

%token <cint> NUM
%token <id> ID

%type <node> intval stringval boolval constant expr
%type <node> stmts stmt fundef assign return varlet program
%type <cbinop> binop
%type <ctype> type_

%start program

%%

program: stmts
         {
           parseresult = ASTprogram($1);
         }
         ;

stmts: stmt stmts
        {
          $$ = ASTstmts($1, $2);
        }
      | stmt
        {
          $$ = ASTstmts($1, NULL);
        }
        ;

stmt: assign
       {
         $$ = $1;
       }
     | fundef
       {
         $$ = $1;
       }
     | return
       {
         $$ = $1;
       }
       ;

fundef: type_ ID[name] BRACKET_L BRACKET_R CURLY_BRACKET_L stmts[body] CURLY_BRACKET_R
        {
          $$ = ASTfundef($body, $name, $1);
        }
        ;

return: RETURN expr SEMICOLON
        {
          $$ = ASTreturn($2);
        }
        ;

assign: type_ varlet LET expr SEMICOLON
        {
          $$ = ASTassign($2, $4, $1);
        }
        ;

type_: INT
        {
          $$ = BT_int;
        }
      | BOOL
        {
          $$ = BT_bool;
        }
      | STRING
        {
          $$ = BT_string;
        }
        ;

varlet: ID
        {
          $$ = ASTvarlet($1);
          AddLocToNode($$, &@1, &@1);
        }
        ;


expr: constant
      {
        $$ = $1;
      }
    | ID BRACKET_L BRACKET_R
      {
        $$ = ASTfuncall($1);
      }
    | ID
      {
        $$ = ASTvar($1);
      }
    | BRACKET_L expr[left] binop[type] expr[right] BRACKET_R
      {
        $$ = ASTbinop( $left, $right, $type);
        AddLocToNode($$, &@left, &@right);
      }
    ;

constant: stringval
          {
            $$ = $1;
          }
        | intval
          {
            $$ = $1;
          }
        | boolval
          {
            $$ = $1;
          }
        ;

stringval: QUOTE ID QUOTE
           {
             $$ = ASTstring($2);
           }
         ;

intval: NUM
        {
          $$ = ASTnum($1);
        }
      ;

boolval: TRUEVAL
         {
           $$ = ASTbool(true);
         }
       | FALSEVAL
         {
           $$ = ASTbool(false);
         }
       ;

binop: PLUS      { $$ = BO_add; }
     | MINUS     { $$ = BO_sub; }
     | STAR      { $$ = BO_mul; }
     | SLASH     { $$ = BO_div; }
     | PERCENT   { $$ = BO_mod; }
     ;

%%

void AddLocToNode(node_st *node, void *begin_loc, void *end_loc)
{
    // Needed because YYLTYPE unpacks later than top-level decl.
    YYLTYPE *loc_b = (YYLTYPE*)begin_loc;
    YYLTYPE *loc_e = (YYLTYPE*)end_loc;
    NODE_BLINE(node) = loc_b->first_line;
    NODE_BCOL(node) = loc_b->first_column;
    NODE_ELINE(node) = loc_e->last_line;
    NODE_ECOL(node) = loc_e->last_column;
}

int yyerror(char *error)
{
  CTI(CTI_ERROR, true, "line %d, col %d\nError parsing source code: %s\n",
            global.line, global.col, error);
  CTIabortOnError();
  return 0;
}

node_st *SPdoScanParse(node_st *root)
{
    DBUG_ASSERT(root == NULL, "Started parsing with existing syntax tree.");
    yyin = fopen(global.input_file, "r");
    if (yyin == NULL) {
        CTI(CTI_ERROR, true, "Cannot open file '%s'.", global.input_file);
        CTIabortOnError();
    }
    yyparse();
    return parseresult;
}
