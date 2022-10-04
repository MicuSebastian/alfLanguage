Newline             \r?\n
Ws                  [ \t]
ErrorS              [0-9]+\,[0-9]+
ErrorL              \^[0-9]+
Float               [0-9]+\.[0-9]+
Int                 [0-9]+
Character           \"[A-Za-z0-9]\"
Sc                  \"\\\"\"
String              \"(?:[^"\\]|\\.)*\"
Comment             \#[A-Za-z0-9\s\.*]*\#
Identifier          [a-z(0-9)*]+
Var                 \@[var]+

%%

"*"                 { return '*'; }
"/"                 { return '/'; }
"+"                 { return '+'; }
"->"                { return '->'; }
"-"                 { return '-'; }
"int"               { return 'INT'; }
"float"             { return 'FLOAT'; }
"true"              { return 'LOGIC'; }
"false"             { return 'LOGIC'; }
"bool"              { return 'BOOL'; }
"character"         { return 'CHARACTER'; }
"string"            { return 'STRING'; }
"none"              { return 'NONE'; }
";"                 { return ';'; }
":"                 { return ':'; }
"<-"                { return '<-'; }
"<"                 { return '<'; }
">"                 { return '>'; }
","                 { return ','; }
"("                 { return 'LP'; }
")"                 { return 'RP'; }
"for"               { return 'FOR'; }
"end"               { return 'END'; }
"from"              { return 'FROM'; }
"to"                { return 'TO'; }
"go"                { return 'GO'; }
"of"                { return 'OF'; }
"loop"              { return 'LOOP'; }
"when"              { return 'WHEN'; }
"function"          { return 'FUNCTION'; }
"start"             { return 'START'; }
"return"            { return 'RETURN'; }
"print"             { return 'PRINT'; }
"getpid"            { return 'GETPID'; }
"sum"               { return 'SUM'; }
"if"                { return 'IF'; }
"then"              { return 'THEN'; }
"else"              { return 'ELSE'; }

{Newline}           { return 'NEWLINE'; }
{Ws}                { }
{ErrorS}            { return 'ERRORS'; }
{ErrorL}            { return 'ERRORL'; }
{Float}             { return 'FLOAT'; }
{Int}               { return 'INT'; }
{LOGIC}             { return 'LOGIC'; }
{Character}         { return 'CHARACTER'; }
{Sc}                { return 'SC'; }
{String}            { return 'STRING'; }
{Comment}           { return 'COMMENT'; }
{NONE}              { return 'NONE'; }
{Identifier}        { return 'IDENTIFIER'; }
{Var}               { return 'VAR'; }