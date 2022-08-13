/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#include <vector>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

static int commentCaller;
static int stringCaller;
static std::vector<char> stringArray;

%}

/*
 * Define names for regular expressions here.
 */

DARROW          =>
CLASS		class
ELSE		else
FI		fi
IF		if
IN		in
INHERITS	inherits
LET		let
LOOP		loop
POOL		pool
THEN		then
WHILE		while
CASE		case
ESAC		esac
OF		of
NEW		new
ISVOID		isvoid
ASSIGN		<-
NOT		not
LE		<=

%x COMMENT
%x STRING
%x STRING_ESCAPE

%%

 /*
  *  Nested comments
  */

"(*" {
    commentCaller = INITIAL;
    BEGIN(COMMENT);
}

<COMMENT><<EOF>> {
    BEGIN(commentCaller);
    cool_yylval.error_msg = "EOF in comments";
    return (ERROR);
}

<COMMENT>[^(\*\))] {
    if (yytext[0] == '\n') ++curr_lineno;
}

<COMMENT>"*)" {
    BEGIN(commentCaller);
}
"*)" {
    cool_yylval.error_msg = "Unmatched *)";
    return (ERROR);
}

 /*
  *  The multiple-character operators.
  */
{DARROW} { return (DARROW); }
[Cc][Ll][Aa][Ss][Ss] { return (CLASS); }
[Ee][Ll][Ss][Ee] { return (ELSE); }
[Ff][Ii] {return (FI); }
[Ii][Ff] {return (IF); }
[Ii][Nn] {return (IN); }
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] {return (INHERITS); }
[Ll][Ee][Tt] {return (LET); }
[Ll[Oo][Oo][Pp] {return (LOOP); }
[Pp][Oo][Oo][Ll] {return (POOL); }
[Tt][Hh][Ee][Nn] {return (THEN); }
[Ww][Hh][Ii][Ll][Ee] {return (WHILE); }
[Cc][Aa][Ss][Ee] {return (CASE); }
[Ee][Ss][Aa][Cc] {return (ESAC); }
[Oo][Ff] {return (OF); }
[Nn][Ee][Ww] {return (NEW); }
[Ii][Ss][Vv][Oo][Ii][Dd] {return (ISVOID); }
[Aa][Ss][Ss][Ii][Gg][Nn] {return (ASSIGN); }
[Nn][Oo][Tt] {return (NOT); }
[Ll][Ee] {return (LE); }

  /* 
   * Invalid Characters
   */

[\[\]\'>] {
    cool_yylval.error_msg = yytext;
    return (ERROR);
}

[ \t\f\r\v] {}

\n { ++curr_lineno; }

--.* {}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
  
  /*
   * Type Identifiers
   */
 
t[Rr][Uu][Ee] {
    cool_yylval.boolean = true;
    return (BOOL_CONST);
}
 
f[Aa][Ll][Ss][Ee] {
    cool_yylval.boolean = false;
    return (BOOL_CONST);
}
 
SELF_TYPE {
    cool_yylval.symbol = idtable.add_string("SELF_TYPE");
    return (TYPEID);
}

[A-Z][A-Za-z0-9_]* {
    cool_yylval.symbol = idtable.add_string(yytext, yyleng);
    return (TYPEID);
}

  /*
   * Object Identifiers
   */
self {
    cool_yylval.symbol = idtable.add_string(yytext, yyleng);
    return (OBJECTID);
}

[a-z][A-Za-z0-9_]* {
    cool_yylval.symbol = idtable.add_string(yytext, yyleng);
    return (OBJECTID);
}

  /*
   * Numbers
   */

[0-9][0-9]* {
    cool_yylval.symbol = inttable.add_string(yytext, yyleng);
    return (INT_CONST);
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

\" {
    stringCaller = INITIAL;
    stringArray.clear();
    BEGIN(STRING);
}

<STRING>[^\"\\]*\\ {
    stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
    BEGIN(STRING_ESCAPE);
}

<STRING>[^\"\\]*\" {
    stringArray.insert(stringArray.end(), yytext, yytext + yyleng - 1);
    cool_yylval.symbol = stringtable.add_string(&stringArray[0], stringArray.size());
    BEGIN(stringCaller);
    return (STR_CONST);
}

<STRING>[^\"\\]*$ {
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN(stringCaller);
    ++curr_lineno;
    return (ERROR);
}



<STRING_ESCAPE>n {
    stringArray.push_back('\n');
    BEGIN(STRING);
}

<STRING_ESCAPE>t {
    stringArray.push_back('\t');
    BEGIN(STRING);
}

<STRING_ESCAPE>b {
    stringArray.push_back('\b');
    BEGIN(STRING);
}

<STRING_ESCAPE>f {
    stringArray.push_back('\f');
    BEGIN(STRING);
}

<STRING_ESCAPE>0 {
    cool_yylval.error_msg = "string contains null character";
    BEGIN(STRING);
    return (ERROR);
}

<STRING_ESCAPE>\n {
    stringArray.push_back('\n');
    ++curr_lineno;
    BEGIN(STRING);
}

<STRING_ESCAPE><<EOF>> {
    cool_yylval.error_msg = "EOF in string-escaped constant";
    BEGIN(STRING);
    return (ERROR);
}

<STRING_ESCAPE>. {
    stringArray.push_back(yytext[0]);
    BEGIN(STRING);
}

 /*
  * Single-character symbol
  */

. {
    return yytext[0];
}

%%
