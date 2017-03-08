%{
#include <string.h>
enum troken
{
	CREATE = 1,
	TABLE = 2,
	NAME = 3,
	LEFTPA = 4, 	//(
	VARCHAR = 5, 
	RIGHTPA = 6,	//)
	INT = 7, 		//ex 100,123
	integer = 8, 	//int
	COMMA = 9, 		//,
	SEMICOLON = 10, //;
	PRIMARY = 11,
	KEY = 12,
	INSERT = 13
	
};
int tkval;
char tstr[100];
%}
%%
[Cc][Rr][Ee][Aa][Tt][Ee] {return CREATE;}
[Tt][Aa][Bb][Ll][Ee] {return TABLE;}
[Ii][Nn][Tt] {return integer;}
[Pp][Rr][Ii][Mm][Aa][Rr][Yy] {return PRIMARY;}
[Kk][Ee][Yy] {return KEY;}
[Vv][Aa][Rr][Cc][Hh][Aa][Rr] {tkval = atoi(yytext);return VARCHAR;}
[Ii][Nn][Ss][Ee][Rr][Tt] {return INSERT;}
\( {return LEFTPA;}
\) {return RIGHTPA;}
\, {return COMMA;}
\; {return SEMICOLON;}
[\r\t\n\f]+ {}
-?[0-9]+ {return INT;}
[A-Za-z][A-Za-zs0-9_]* {strcpy(tstr,yytext);return NAME;}
. {}

%%
char str[100][100];   //store the name of attributes
char type[100][100];	//store the type of attributes
int length[20]; // 
int PKplace = -1;
int num = 0;
int tok;
void create()
{
	if(tok == TABLE)
	{ //TABLE
	tok = yylex();
	if(tok == NAME)
	{ //NAME
	tok = yylex();
	if(tok == LEFTPA)
	{ // LEFTPA
		while(1)
		{
			tok = yylex();
			if(tok == NAME) strcpy(str[num],tstr);
			else {printf("u r wrong NAME\n"); break;} // the things may not be a attribute name
			tok = yylex();
			if(tok == integer) strcpy(type[num], "int"); //int case
			else if(tok == VARCHAR) //varchar case
			{
				strcpy(type[num], "varchar");
				tok = yylex();
				int flag = 0;
				if(tok == LEFTPA)
				{
					tok = yylex();
					if(tok == INT)
					{
						tok = yylex();
						if(tok == RIGHTPA) length[num] = tkval;
						else flag = 1;
					}
					else flag = 2;
				}
				else flag = 1;
				if(flag == 1) //if is in wrong format
				{
					printf("Unknown keywords\n");
					break;
				}
				else if(flag == 2)
				{
					printf("Wrong SQL syntax\n");
					break;
				}
			}
			else
			{
				printf("Unknown keywords");
				break;
			}
			num++;
			tok = yylex();
			if(tok == RIGHTPA)
			{
				tok = yylex();
				if(tok == SEMICOLON) 
				{
					for(int i = 0; i < num; i++) printf("%10s",str[i]);
					printf("\n");
					for(int i = 0; i < num; i++) printf("%10s",type[i]);
					break;
				}
				else    // not sure what to do when there is not a semicolon in the end
				{
					printf("u r wrong semicolon");
					break;
				}
			}
			else if(tok == PRIMARY)
			{
				tok = yylex();
				if(tok == KEY)
				{
					tok = yylex();
					if(tok == COMMA) PKplace = num - 1;
					else {printf("Wrong SQL syntax\n"); break;}
				}
				else
				{
					printf("Unknown keywords\n"); break;
				}
			}
			else if(tok != COMMA)
			{
			
				printf("Wrong SQL syntax\n");
				break;
			}
			
		}
	}//LEFTPA
	else printf("Wrong SQL syntax\n");
	}//NAME
	else printf("Unknown keywords\n");
	}//TABLE
	else printf("Unknown keywords\n");
}
void insert()
{
	
}
void main(int argc, char **argv)
{
	int size;
	int k = 2;
	tok = yylex();
	if(tok == CREATE)
	{ 
		tok = yylex();
		create();
	}
	else if(tok == INSERT)
	{
		tok = yylex();
		insert();
	}

}