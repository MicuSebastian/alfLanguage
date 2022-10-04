%left 'if'
%left '=' '!='
%left '>' '>=' '<' '<='
%left 'and' 'or' 'xor'
%left 'not'
%left '+' '-'
%left '*' '/' 'mod'

%%

start
: statements    {
                    $1 = $1.reverse();
                    return {
                        id: "script",
                        statements: $1,
                        line: yylineno + 1
                    };
                }
;

statements
: statement ';' NEWLINE statements      {
                                            $4.push($1);
                                            $$ = $4;
                                        }
| statement ';'                         {
                                            $$ = [];
                                            $$.push($1);
                                        }
| COMMENT NEWLINE statements            {
                                            $$ = $3;
                                        }
| COMMENT NEWLINE NEWLINE statements    {
                                            $$ = $4;
                                        }
| empty
;

empty
: ';'               {
                        $$= [];
                        $$.push({
                            type: "empty"
                        });
                    }
;
statement
: expression
| variable
| attribution
| value
| function
| function_definition
| function_call
| branch
| return
;

value
: ERRORS            {
                        return {
                            error: "syntax",
                            line: yylineno + 1,
                            text: ",",
                            "token": "\",\"",
                            expected: [
                                "\";\"",
                                "\"+\"",
                                "\"-\"",
                                "\"*\"",
                                "\"/\"",
                                "\"%\"",
                                "\">\"",
                                "\"<\"",
                                "\".\"",
                                "\"==\"",
                                "\"!=\"",
                                "\"<=\"",
                                "\">=\"",
                                "\"OR\"",
                                "\"XOR\"",
                                "\"AND\""]
                        };
                    }
| ERRORL            {
                        return {
                            error: "lexical",
                            line: yylineno + 1,
                            text: "Lexical error on line " + (yylineno+1) + ": Unrecognized text.\n\n Erroneous area:\n1: #Lexical error#\n2: " + $1 + ";\n^..^"
                        };
                    }
| FLOAT             {
                        $$ = {
                            id: "value",
                            type: "real",
                            value: parseFloat($1),
                            line: yylineno + 1
                        };
                    }
| INT               {
                        $$ = {
                            id: "value",
                            type: "int",
                            value: parseInt($1),
                            line: yylineno + 1
                        };
                    }
| CHARACTER         {
                        $$ = {
                            id: "value",
                            type: "character",
                            value: JSON.parse($1),
                            line: yylineno + 1
                        };
                    }
| COMMENT           {}
| LOGIC             {
                        $$ = {
                            id: "value",
                            type: "logic",
                            value: JSON.parse($1),
                            line: yylineno + 1
                        };
                    }
| SC                {
                        $$ = {
                            id: "value",
                            type: "character",
                            value: JSON.parse($1),
                            line: yylineno + 1
                        };
                    }
| STRING            {
                        $$ = {
                            id: "value",
                            type: "string",
                            value: JSON.parse($1),
                            line: yylineno + 1
                        };
                    }
| NONE              {
                        $$ = {
                            id: "value",
                            type: $1,
                            line: yylineno + 1
                        };
                    }
;

variable
: VAR IDENTIFIER ':' tip ',' variable               {
                                                        $6.push({
                                                            type: $4,
                                                            title: $2,
                                                            line: yylineno + 1
                                                        });
                                                        $$ = {
                                                            id: "var",
                                                            elements: $6.reverse(),
                                                            line: yylineno + 1
                                                        };
                                                    }
| IDENTIFIER ':' tip ',' variable                   {
                                                        $5.push({
                                                            type: $3,
                                                            title: $1,
                                                            line: yylineno + 1
                                                        });
                                                        $$ = $5;
                                                    }
| IDENTIFIER ':' tip                                {
                                                        $$ = [];
                                                        $$.push({
                                                            type: $3,
                                                            title: $1,
                                                            line: yylineno + 1
                                                        });
                                                    }
| VAR IDENTIFIER ':' tip                            {
                                                        $$ = {
                                                            id: "var",
                                                            elements: [{
                                                                type: $4,
                                                                title: $2,
                                                                line: yylineno + 1
                                                            }],
                                                            line: yylineno + 1
                                                        };
                                                    }
| VAR IDENTIFIER '<-' value                         {
                                                        $$ = {
                                                            id: "var",
                                                            elements: [{
                                                                type: "auto",
                                                                title: $2,
                                                                value: {
                                                                    id: "value",
                                                                    type: $4.type,
                                                                    value: $4.value,
                                                                    line: yylineno + 1
                                                                },
                                                                line: yylineno + 1
                                                            }],
                                                            line: yylineno + 1
                                                        };
                                                    }
| VAR IDENTIFIER '<' value                          {
                                                        return {
                                                            error: "syntax",
                                                            line: yylineno + 1,
                                                            text: $3,
                                                            token: "\"<\"",
                                                            expected: [
                                                                "\":\"",
                                                                "\"ASSIGN\""
                                                            ]
                                                        };
                                                    }
| VAR IDENTIFIER ':' tip '<-' expression            {
                                                        $$ = {
                                                            id: "var",
                                                            elements: [{
                                                                type: $4,
                                                                title: $2,
                                                                value: $6,
                                                                line: yylineno + 1
                                                            }],
                                                            line: yylineno + 1
                                                        };
                                                    }
| VAR IDENTIFIER ':' tip '<-' value ',' variable    {
                                                        $8.push({
                                                            type: $4,
                                                            title: $2,
                                                            value: {
                                                                id: "value",
                                                                type: $6.type,
                                                                value: $6.value,
                                                                line: yylineno + 1
                                                            },
                                                            line: yylineno + 1
                                                        });
                                                        $$ = {
                                                            id: "var",
                                                            elements: $8.reverse(),
                                                            line: yylineno + 1
                                                        };
                                                    }
| IDENTIFIER ':' tip '<-' value ',' variable        {
                                                        $7.push({
                                                            type: $3,
                                                            title: $1,
                                                            value: {
                                                                id: "value",
                                                                type: $5.type,
                                                                value: $5.value,
                                                                line: yylineno + 1
                                                            },
                                                            line: yylineno + 1
                                                        });
                                                        $$ = $7;
                                                    }
| IDENTIFIER ':' tip '<-' value                     {
                                                        $$ = [];
                                                        $$.push({
                                                            type: $3,
                                                            title: $1,
                                                            value: {
                                                                id: "value",
                                                                type: $5.type,
                                                                value: $5.value,
                                                                line: yylineno + 1
                                                            },
                                                            line: yylineno + 1
                                                        });
                                                    }
| VAR IDENTIFIER ':' tip '<-' value                 {
                                                        $$ = {
                                                            id: "var",
                                                            elements: [{
                                                                type: $4,
                                                                title: $2,
                                                                value: {
                                                                    id: "value",
                                                                    type: $6.type,
                                                                    value: $6.value,
                                                                    line: yylineno + 1
                                                                },
                                                                line: yylineno + 1
                                                            }],
                                                            line: yylineno + 1
                                                        };
                                                    }
;

tip
: INT
| FLOAT
| STRING
| BOOL
;

attribution
: NEWLINE IDENTIFIER '<-' value             {
                                                $$ = {
                                                    id: "attr",
                                                    to: {
                                                        id: "identifier",
                                                        title: $2,
                                                        line: yylineno + 1
                                                    },
                                                    from: {
                                                        id: "value",
                                                        type: $4.type,
                                                        value: $4.value,
                                                        line: yylineno + 1
                                                    },
                                                    line: yylineno + 1
                                                };
                                            }
| IDENTIFIER '<-' IDENTIFIER '+' value      {
                                                $$ = {
                                                    id: "attr",
                                                    to: {
                                                        id: "identifier",
                                                        title: $1,
                                                        line: yylineno + 1
                                                    },
                                                    from: {
                                                        id: "expr",
                                                        op: $4,
                                                        left: {
                                                            id: "identifier",
                                                            title: $3,
                                                            line: yylineno + 1
                                                        },
                                                        right: {
                                                            id: "value",
                                                            type: $5.type,
                                                            value: $5.value,
                                                            line: yylineno + 1
                                                        },
                                                        line: yylineno + 1
                                                    },
                                                    line: yylineno + 1
                                                };
                                            }
| IDENTIFIER '<-' expression                {
                                                $$ = {
                                                    id: "attr",
                                                    to: {
                                                        id: "identifier",
                                                        title: $1,
                                                        line: yylineno + 1
                                                    },
                                                    from: $3,
                                                    line: yylineno + 1
                                                };
                                            }
| NEWLINE IDENTIFIER '<-' function_call     {
                                                $$ = {
                                                    id: "attr",
                                                    to: {
                                                        id: "identifier",
                                                        title: $2,
                                                        line: yylineno + 1
                                                    },
                                                    from: $4,
                                                    line: yylineno + 1
                                                };    
                                            }
;

function
: NEWLINE FOR IDENTIFIER FROM value TO value GO NEWLINE statement ';' NEWLINE END   {
                                                                                        $$ = {
                                                                                            id: "for",
                                                                                            variable: $3,
                                                                                            from: {
                                                                                                id: "value",
                                                                                                type: $5.type,
                                                                                                value: $5.value,
                                                                                                line: yylineno - 1
                                                                                            },
                                                                                            to: {
                                                                                                id: "value",
                                                                                                type: $7.type,
                                                                                                value: $7.value,
                                                                                                line: yylineno - 1
                                                                                            },
                                                                                            statements: [$10],
                                                                                            line: yylineno + 1
                                                                                        };
                                                                                    }
| NEWLINE FOR IDENTIFIER OF IDENTIFIER GO NEWLINE statement ';' NEWLINE END         {
                                                                                        $$ = {
                                                                                                id: "for",
                                                                                                variable: $3,
                                                                                                exp: {
                                                                                                    id: "identifier",
                                                                                                    title: $5,
                                                                                                    line: yylineno - 1
                                                                                                },
                                                                                                statements: [$8],
                                                                                                line: yylineno + 1
                                                                                            };
                                                                                    }
| NEWLINE LOOP NEWLINE statement ';' NEWLINE WHEN statement                         {
                                                                                        $$ = {
                                                                                            id: "loop_when",
                                                                                            exp: $8,
                                                                                            statements: [$4],
                                                                                            line: yylineno + 1
                                                                                        };
                                                                                    }
| NEWLINE LOOP statement GO NEWLINE statement ';' NEWLINE END                       {
                                                                                        $$ = {
                                                                                            id: "loop_go",
                                                                                            exp: $3,
                                                                                            statements: [$6],
                                                                                            line: yylineno + 1
                                                                                        };
                                                                                    }                           
;

function_definition
: NEWLINE FUNCTION SUM LP parameters RP ':' tip '->'        {
                                                                $$ = {
                                                                    id: "function_def",
                                                                    title: $3,
                                                                    parameters: $5,
                                                                    return_type: $8,
                                                                    statements: [{
                                                                            type: "empty"
                                                                    }],
                                                                    line: yylineno + 1
                                                                };
                                                            }
| FUNCTION IDENTIFIER ':' tip '->' value                    {
                                                                $$ = {
                                                                    id: "function_def",
                                                                    title: $2,
                                                                    return_type: $4,
                                                                    parameters: [],
                                                                    statements: [$6],
                                                                    line: yylineno + 1
                                                                };
                                                            }
| FUNCTION IDENTIFIER ':' tip NEWLINE START NEWLINE statement ';' NEWLINE statement ';' NEWLINE statement ';' NEWLINE END        {
                                                                                                    $$ = {
                                                                                                        id: "function_def",
                                                                                                        title: $2,
                                                                                                        parameters: [],
                                                                                                        return_type: $4,
                                                                                                        statements: [$8, $11, $14],
                                                                                                        line: yylineno + 1
                                                                                                    };
                                                                                                }
| FUNCTION SUM LP parameters RP ':' tip NEWLINE START NEWLINE statement ';' NEWLINE END         {
                                                                                                    $$ = {
                                                                                                        id: "function_def",
                                                                                                        title: $2,
                                                                                                        parameters: $4,
                                                                                                        return_type: $7,
                                                                                                        statements: [$11],
                                                                                                        line: yylineno + 1
                                                                                                    };
                                                                                                }
| NEWLINE FUNCTION SUM LP parameters RP ':' tip NEWLINE START NEWLINE statement ';' NEWLINE statement ';' NEWLINE END   {
                                                                                                                            $$ = {
                                                                                                                                id: "function_def",
                                                                                                                                title: $3,
                                                                                                                                parameters: $5,
                                                                                                                                return_type: $8,
                                                                                                                                statements: [$12, $15],
                                                                                                                                line: yylineno + 1
                                                                                                                            };
                                                                                                                        }
| FUNCTION PRINT LP parameters RP ':' tip NEWLINE START NEWLINE empty NEWLINE END   {
                                                                                        $$ = {
                                                                                            id: "function_def",
                                                                                            title: $2,
                                                                                            parameters: $4,
                                                                                            return_type: $7,
                                                                                            statements: $11,
                                                                                            line: yylineno + 1
                                                                                        };
                                                                                    }         
| FUNCTION PRINT LP parameters RP ':' tip NEWLINE START statement ';' NEWLINE END   {
                                                                                        $$ = {
                                                                                            id: "function_def",
                                                                                            title: $2,
                                                                                            parameters: $4,
                                                                                            return_type: $7,
                                                                                            statements: [$10],
                                                                                            line: yylineno + 1
                                                                                        };
                                                                                    }
;

function_call
: PRINT LP IDENTIFIER ':' value RP                          {
                                                                $$ = {
                                                                    id: "function_call",
                                                                    function: $1,
                                                                    parameters: {
                                                                        [$3]: $5
                                                                    },
                                                                    line: yylineno + 1
                                                                };
                                                            }
| GETPID LP RP                                              {
                                                                $$ = {
                                                                    id: "function_call",
                                                                    function: $1,
                                                                    parameters: [],
                                                                    line: yylineno + 1
                                                                };
                                                            }
| SUM LP IDENTIFIER ':' value ',' IDENTIFIER ':' value RP   {
                                                                $$ = {
                                                                    id: "function_call",
                                                                    function: $1,
                                                                    parameters: {
                                                                        [$3]: $5,
                                                                        [$7]: $9
                                                                    },
                                                                    line: yylineno + 1
                                                                };
                                                            }
;

parameters
: IDENTIFIER ':' tip ',' parameters     {
                                            $5.push({
                                                type: $3,
                                                name: $1
                                            });
                                            $$ = $5.reverse();
                                        }
| IDENTIFIER ':' tip                    {
                                            $$ = [];
                                            $$.push({
                                                type: $3,
                                                name: $1
                                            });
                                        }                                        
;

branch
: NEWLINE IF expression THEN NEWLINE attribution ';' NEWLINE END    {
                                                                        $$ = {
                                                                            id: "if_then",
                                                                            exp: $3,
                                                                            then: [$6],
                                                                            line: yylineno + 1
                                                                        };
                                                                    }
| NEWLINE IF expression THEN NEWLINE attribution ';' NEWLINE ELSE NEWLINE attribution ';' NEWLINE END {
                                                                        $$ = {
                                                                            id: "if_then",
                                                                            exp: $3,
                                                                            then: [$6],
                                                                            else: [$11],
                                                                            line: yylineno + 1
                                                                        };
                                                                    }
;

expression
: value '+' value '*' value     {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "value",
                                            type: $1.type,
                                            value: $1.value,
                                            line: yylineno + 1
                                        },
                                        right: {
                                            id: "expr",
                                            op: $4,
                                            left: {
                                                id: "value",
                                                type: $3.type,
                                                value: $3.value,
                                                line: yylineno + 1
                                            },
                                            right: {
                                                id: "value",
                                                type: $5.type,
                                                value: $5.value,
                                                line: yylineno + 1
                                            },
                                            line: yylineno + 1
                                        },
                                        line: yylineno + 1
                                    };
                                }
| value '*' IDENTIFIER          {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "value",
                                            type: $1.type,
                                            value: $1.value,
                                            line: yylineno + 1
                                        },
                                        right: {
                                            id: "identifier",
                                            title: $3,
                                            line: yylineno + 1
                                        },
                                        line: yylineno + 1
                                    };
                                }
| IDENTIFIER '*' value          {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "identifier",
                                            title: $1,
                                            line: yylineno + 1
                                        },
                                        right: $3,
                                        line: yylineno + 1
                                    };
                                }
| IDENTIFIER '<' value          {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "identifier",
                                            title: $1,
                                            line: yylineno + 1
                                        },
                                        right: {
                                            id: "value",
                                            type: $3.type,
                                            value: $3.value,
                                            line: yylineno + 1
                                        },
                                        line: yylineno + 1
                                    };
                                }
| IDENTIFIER '>' value          {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "identifier",
                                            title: $1,
                                            line: yylineno + 1
                                        },
                                        right: $3,
                                        line: yylineno + 1
                                    };
                                }
| IDENTIFIER '+' IDENTIFIER     {
                                    $$ = {
                                        id: "expr",
                                        op: $2,
                                        left: {
                                            id: "identifier",
                                            title: $1,
                                            line: yylineno + 1
                                        },
                                        right: {
                                            id: "identifier",
                                            title: $3,
                                            line: yylineno + 1
                                        },
                                        line: yylineno + 1
                                    };
                                }                           
;

return
: RETURN IDENTIFIER             {
                                    $$ = {
                                        id: "return",
                                        value: {
                                            id: "identifier",
                                            title: $2,
                                            line: yylineno + 1
                                        },
                                        line: yylineno + 1
                                    };
                                }
;