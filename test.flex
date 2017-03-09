%{
#include <string.h>
#include "an.h"
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
	INSERT = 13,
	INTO = 14,
	STRING = 15
	
};
int tok;
int tkval;
char tstr[100]; //if it is a name, store the name
struct Table tables[30]; 
%}
%%
[Cc][Rr][Ee][Aa][Tt][Ee] {return CREATE;}
[Tt][Aa][Bb][Ll][Ee] {return TABLE;}
[Ii][Nn][Tt] {return integer;}
[Pp][Rr][Ii][Mm][Aa][Rr][Yy] {return PRIMARY;}
[Kk][Ee][Yy] {return KEY;}
[Vv][Aa][Rr][Cc][Hh][Aa][Rr] {return VARCHAR;}
[Ii][Nn][Ss][Ee][Rr][Tt] {return INSERT;}
[Ii][Nn][Tt][Oo] {return INTO;}
\'[\r\t\f!-~]+\' {return STRING;}
\( {return LEFTPA;}
\) {return RIGHTPA;}
\, {return COMMA;}
\; {return SEMICOLON;}
[\r\t\n\f]+ {}
-?[0-9]+ {tkval = atoi(yytext);return INT;}
[A-Za-z_][A-Za-z0-9_]* {strcpy(tstr,yytext);return NAME;}
. {}

%%
void create(int *TBN)
{
	char str[100][100];   //store the name of attributes
	int type[100];	//store the type of attributes
	int length[100];
	char TBname[30];
	int PK = -1;
	int num = 0;
	if(tok == TABLE)
	{ //TABLE
	tok = yylex();
	if(tok == NAME)
	{ //NAME
	strcpy(TBname,tstr);
	tok = yylex();
	if(tok == LEFTPA)
	{ // LEFTPA
		while(1)
		{
			tok = yylex();
			if(tok == NAME) strcpy(str[num],tstr);
			else {printf("u r wrong NAME\n"); return;} // the things may not be a attribute name
			tok = yylex();
			if(tok == integer) type[num] = 0; //int case
			else if(tok == VARCHAR) //varchar case
			{
				type[num] = 1;
				tok = yylex();
				int flag = 0;    // to see if the error is last() or wrong type
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
				else flag = 1;	//if is in wrong format
				if(flag == 1) {printf("Unknown keywords\n"); return;}
				else if(flag == 2) {printf("Wrong SQL syntax\n"); return;}
			}
			else {printf("Unknown keywords"); return;}
			num++;
			tok = yylex();
			if(tok == RIGHTPA)
			{
				tok = yylex();
				if(tok == SEMICOLON) 
				{
					//for(int i = 0; i < num; i++) printf("%10s",str[i]);
					//printf("\n");
					//for(int i = 0; i < num; i++) printf("%10d",type[i]);
					break;
				}
				else    // not sure what to do when there is not a semicolon in the end
				{
					printf("u r wrong semicolon"); 
					return;
				}
			}
			else if(tok == PRIMARY)
			{
				tok = yylex();
				if(tok == KEY)
				{
					tok = yylex();
					if(tok == COMMA) PK = num - 1;
					else {printf("Wrong SQL syntax\n"); return;}
				}
				else {printf("Unknown keywords\n"); return;}
			}
			else if(tok != COMMA) {printf("Wrong SQL syntax\n");return;}
		}
	}//LEFTPA
	else {printf("Wrong SQL syntax\n"); return;}
	}//NAME
	else {printf("Unknown keywords\n"); return;}
	}//TABLE
	else {printf("Unknown keywords\n"); return;}
	strcpy(tables[*TBN].TBname, TBname);
	tables[*TBN].PK = PK;
	for(int i = 0; i < num; i++)
	{
		strcpy(tables[*TBN].attribute_name[i] ,str[i]);
		tables[*TBN].attribute_type[i] = type[i];
		tables[*TBN].attribute_length[i] = length[i];
	}
	tables[*TBN].attribute_num = num;
	(*TBN)++;
	num++;
}
void insert()
{
	
}
void main(int argc, char **argv)
{
	int size;
	tok = yylex();
	int TBN = 0; //table numbers
	int flag;
	if(tok == CREATE)
	{ 
		tok = yylex();
		create(&TBN);
		printf("table: name%s\n",tables[0].TBname);
		printf("PRIMARY KEY PLACE: %d\n",tables[0].PK);
		for(int i = 0; i < tables[0].attribute_num; i++) printf("%10s",tables[0].attribute_name[i]);
		printf("\n");
		for(int i = 0; i < tables[0].attribute_num; i++) printf("%10d",tables[0].attribute_type[i]);
		printf("\n");
		printf("attribute num: %d\n",tables[0].attribute_num);
	}
	else if(tok == INSERT)
	{
		tok = yylex();
		insert();
	}

}