%{
#include "main.h"
#include <vector>
#include <queue>
#include <string.h>
union symbolData{
    int intData;
    float floatData;
};
struct table{
    string name;
    int type; //0:int 1:float 2:fun 3:int vector 4:float vector
    symbolData data;
    vector<float> Head; //vector data
    int dim_index;
};

table symbolTable[50];
int tablelength = 0;
int currentVector = 0;
vector<float> temp_vector;
queue<string> c_code;

float* Operation(float* x, float* y, int x_length, int y_length, int type);
void updateSymbolTable(char *name, float data);
int findtablenum(char *name);
int symbolValue(char *name, float **data);

void yyerror(const char *s);
extern int yylex();
extern int yyparse();
%}

%union {
    float floatNum;
    int intNum;
    char charNum[20];
    int dim_index;
    struct exprdata expr;
}

%token <intNum> INTRGER
%token <floatNum> REAL
%token <charNum>  IDENTIFIER STRING
%token <dim_index> INT_VECTOR REAL_VECTOR 
%token FUN VAR INT_TOKEN REAL_TOKEN 
%token PRINT PRINTLN

%type  <expr> num expr
%type  <floatNum> statements statement  
%type  <expr>  assign
%type  <expr> arrayvalue

%left '+' '-' ','
%left '*' '/'
%right MINUS

%%
func:
    FUN IDENTIFIER '(' ')' '{' statements '}' {printf("int %s", $2); printf("(){\n");  
                                                while(!c_code.empty()){
                                                    cout<<c_code.front();
                                                    c_code.pop();
                                                } printf("}\n"); }
    ;

statements:
    statements statement {;} |
    ;

statement:
    assign ';'  {string temp = ""; temp += $1.string; temp += ";\n"; c_code.push(temp); } |
    PRINT '(' STRING ')' ';' { string temp = ""; temp += "printf\(\"\%s\", \""; temp += $3; temp += "\");\n"; c_code.push(temp); } |
    PRINT '(' expr ')' ';'      { string temp = ""; 
                                for(int i = 0; i < $3.length; ++i){
                                    if( $3.type == 0 || $3.type == 3){
                                        if( $3.length == 1){
                                            temp += "printf\(\"\%d\", ";
                                            temp += $3.string;
                                            temp += "\);\n";
                                        }
                                        else{
                                            temp += "printf\(\"\%d\", ";
                                            temp += to_string((int)$3.head[i]);
                                            temp += "\);\n";
                                        }
                                    }
                                    else{
                                        if( $3.length == 1){
                                            temp += "printf\(\"\%f\", ";
                                            temp += $3.string; 
                                            temp += "\);\n";
                                        }
                                        else{
                                            temp += "printf\(\"\%f\", ";
                                            temp += to_string((int)$3.head[i]);
                                            temp += "\);\n";
                                        }
                                    }
                                } c_code.push(temp); } |
    PRINTLN '(' STRING ')' ';' { string temp = ""; temp += "printf\(\"\%s\", \""; temp += $3; temp += "\\n\");\n"; c_code.push(temp); } |
    PRINTLN '(' expr ')' ';'           { string temp = ""; 
                                for(int i = 0; i < $3.length; ++i){
                                    if( $3.type == 0 || $3.type == 3){
                                        if( $3.length == 1){
                                            temp += "printf\(\"\%d\", ";
                                            temp += $3.string;
                                            temp += "\);\n";
                                        }
                                        else{
                                            temp += "printf\(\"\%d\", ";
                                            temp += to_string((int)$3.head[i]);
                                            temp += "\);\n";
                                        }
                                    }
                                    else{
                                        if( $3.length == 1){
                                            temp += "printf\(\"\%f\", ";
                                            temp += $3.string; 
                                            temp += "\);\n";
                                        }
                                        else{
                                            temp += "printf\(\"\%f\", ";
                                            temp += to_string((int)$3.head[i]);
                                            temp += "\);\n";
                                        }
                                    }
                                } temp += "printf(\"\\n\");"; c_code.push(temp); } |
    VAR IDENTIFIER ':' INT_TOKEN ';'  { string temp = ""; temp += "int "; temp += $2; temp += ";\n"; c_code.push(temp);
                                        if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 0; tablelength++; } |
    VAR IDENTIFIER ':' REAL_TOKEN ';'  { string temp = ""; temp += "float "; temp += $2; temp += ";\n"; c_code.push(temp);
                                        if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 1; tablelength++; } |
    VAR IDENTIFIER ':' INT_TOKEN '=' expr ';'  { string temp = ""; temp += "int "; temp += $2; temp += " = "; temp += $6.string; temp += ";\n"; c_code.push(temp);
                                                if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 0; tablelength++; updateSymbolTable($2, $6.head[0]); } |
    VAR IDENTIFIER ':' REAL_TOKEN '=' expr ';' { string temp = ""; temp += "float "; temp += $2; temp += " = "; temp += $6.string; temp += ";\n"; c_code.push(temp);
                                                if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 1; tablelength++; updateSymbolTable($2, $6.head[0]); } |
    VAR IDENTIFIER ':' INT_VECTOR ';'  { string temp = ""; temp += "int "; temp += $2; 
                                            temp += "["; temp += to_string($4); temp += "]";
                                            temp += ";\n"; c_code.push(temp);
                                        if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 3; symbolTable[tablelength].dim_index = $4; tablelength++; } |
    VAR IDENTIFIER ':' REAL_VECTOR ';' { string temp = ""; temp += "float "; temp += $2; 
                                            temp += "["; temp += to_string($4); temp += "]";
                                            temp += ";\n"; c_code.push(temp);
                                        if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 4; symbolTable[tablelength].dim_index = $4; tablelength++; } |
    VAR IDENTIFIER ':' INT_VECTOR '=' '{' arrayvalue '}' ';' { string temp = ""; temp += "int "; temp += $2; 
                                                                temp += "["; temp += to_string($4); temp += "]";
                                                                temp += "="; temp += "{"; temp += $7.string; temp += "}"; 
                                                                temp += ";\n"; c_code.push(temp);
                                                                if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); if( temp_vector.size() > $4) yyerror("ERROR: too many dimensions");
                                                                for(int i = 0; i < temp_vector.size(); ++i){
                                                                    symbolTable[tablelength].Head.push_back(temp_vector[i]);
                                                                } temp_vector.clear(); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 3; symbolTable[tablelength].dim_index = $4; tablelength++; } |
    VAR IDENTIFIER ':' REAL_VECTOR '=' '{' arrayvalue '}' ';' { string temp = ""; temp += "float "; temp += $2; 
                                                                temp += "["; temp += to_string($4); temp += "]";
                                                                temp += "="; temp += "{"; temp += $7.string; temp += "}"; 
                                                                temp += ";\n"; c_code.push(temp);
                                                                if(findtablenum($2) != -1) yyerror("ERROR: duplicate declaration"); if( temp_vector.size() > $4) yyerror("ERROR: too many dimensions");
                                                                for(int i = 0; i < temp_vector.size(); ++i){
                                                                    symbolTable[tablelength].Head.push_back(temp_vector[i]);
                                                                } temp_vector.clear(); symbolTable[tablelength].name = $2; symbolTable[tablelength].type = 4; symbolTable[tablelength].dim_index = $4; tablelength++; }
    ;

arrayvalue:
    arrayvalue ',' expr { strcpy($$.string, $1.string); strcat($$.string, ","); strcat($$.string, $3.string); temp_vector.push_back($3.head[0]); } |
    expr                { strcpy($$.string, $1.string); temp_vector.push_back($1.head[0]); }
    ;

assign: 
    IDENTIFIER '=' expr { strcpy($$.string, $1); strcat($$.string, "="); strcat($$.string, $3.string); updateSymbolTable($1, $3.head[0]); }
    ;

expr:
    num                   { strcpy($$.string, $1.string); $$.head = $1.head; $$.length = $1.length; $$.type = $1.type; } |
    expr '+' expr         { strcpy($$.string, $1.string); strcat($$.string, "+"); strcat($$.string, $3.string); $$.head = Operation($1.head, $3.head, $1.length, $3.length, 0); $$.length = $1.length; $$.type = $1.type; } |
    expr '-' expr         { strcpy($$.string, $1.string); strcat($$.string, "-"); strcat($$.string, $3.string); $$.head = Operation($1.head, $3.head, $1.length, $3.length, 1); $$.length = $1.length; $$.type = $1.type; } |
    expr '*' expr         { $$.head = Operation($1.head, $3.head, $1.length, $3.length, 2);
                            if($1.length == 1){ strcpy($$.string, $1.string); strcat($$.string, "*"); strcat($$.string, $3.string); } 
                            else strcpy($$.string, to_string($$.head[0]).c_str());
                            $$.length = 1; $$.type = $1.type; } |
    expr '/' expr         { strcpy($$.string, $1.string); strcat($$.string, "/"); strcat($$.string, $3.string);$$.head = Operation($1.head, $3.head, $1.length, $3.length, 3); $$.length = $1.length; $$.type = $1.type; } |
    '-' expr %prec MINUS  { strcpy($$.string, "-"); strcat($$.string, $2.string); $$.head = Operation($2.head, $2.head, $2.length, $2.length, 4); $$.length = $2.length; $$.type = $2.type;} |
    '(' expr ')'          { strcpy($$.string, "\("); strcat($$.string, $2.string); strcat($$.string, "\)"); $$.head = $2.head; $$.length = $2.length; $$.type = $2.type; }
    ;

num:
    IDENTIFIER { strcpy($$.string, $1); $$.length = symbolValue($1, &$$.head); $$.type = symbolTable[findtablenum($1)].type; } |
    INTRGER { strcpy($$.string, to_string($1).c_str()); $$.head = new float; $$.head[0] = $1; $$.length = 1; $$.type = 0; } |
    REAL    { strcpy($$.string, to_string($1).c_str()); $$.head = new float; $$.head[0] = (float)$1; $$.length = 1; $$.type = 1; }
    ;
%%
float* Operation(float* x, float* y, int x_length, int y_length, int type){
    if (x_length != y_length)
        yyerror("ERROR: mismatched dimensions");
    float *output = new float[x_length];
    for(int i = 0; i < x_length; ++i){
        switch(type){
            case 0: // +
                output[i] = x[i] + y[i]; 
                break;
            case 1: // -
                output[i] = x[i] - y[i];
                break;
            case 2: // *
                output[i] = x[i] * y[i];
                break;
            case 3: // /
                output[i] = x[i] / y[i];
                break;
            case 4: 
                output[i] = -x[i];    
        }
    }
    if(type == 2){
        float* new_output = new float;
        new_output[0] = 0;
        for(int i = 0; i < x_length; ++i)
            new_output[0] += output[i];
        return new_output;
    }
    return output;
}

void updateSymbolTable(char *name, float data){
    string temp_name = name;
    for(int i = 0; i < tablelength; ++i){
        if(symbolTable[i].name == temp_name){
            switch(symbolTable[i].type){
                case 0:
                    symbolTable[i].data.intData = (int)data;
                    break;
                case 1:
                    symbolTable[i].data.floatData = data;
                    break;
                default:
                    break;
            }
            break;
        }
    }
}

int findtablenum(char *name){
    string temp_name = name;
    for(int i = 0; i < tablelength; ++i){
        if(symbolTable[i].name == temp_name){
            return i;
        }
    }
    return -1;
}

int symbolValue(char *name, float **data){
    string temp_name = name;
    for(int i = 0; i < tablelength; ++i){
        if(symbolTable[i].name == temp_name){
            switch(symbolTable[i].type){
                case 0:
                    *data = new float;
                    (*data)[0] = symbolTable[i].data.intData;
                    return 1;
                case 1:
                    (*data) = &(symbolTable[i].data.floatData);
                    return 1;
                case 3:
                case 4:
                    *data = new float[symbolTable[i].dim_index];
                    for(int j = 0; j < symbolTable[i].dim_index; ++j){
                        if( j < symbolTable[i].Head.size())
                            (*data)[j] = symbolTable[i].Head[j];
                        else
                            (*data)[j] = 0;
                    }
                    return symbolTable[i].dim_index;
                    break;
                default:
                    return -1;
            }
        }
    }
    return -1;
}

void yyerror(const char *s) { cerr << s << endl; }