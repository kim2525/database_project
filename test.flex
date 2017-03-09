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
char str[100][100];   //store the name of attributes
int type[100];	//store the type of attributes
int length[100];
char TBname[30];
int atrlength[20]; // 
int PK;
int tok;
int tkval;
int num;
char tstr[100]; //if it is a name, store the name
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
[A-Za-z][A-Za-zs0-9_]* {strcpy(tstr,yytext);return NAME;}
. {}

%%
int create()
{
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
			else {printf("u r wrong NAME\n"); return 0;} // the things may not be a attribute name
			tok = yylex();
			if(tok == integer) type[num] = 0; //int case
			else if(tok == VARCHAR) //varchar case
			{
				type[num] = 1;
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
				else flag = 1;	//if is in wrong format
				if(flag == 1) {printf("Unknown keywords\n"); return 0;}
				else if(flag == 2) {printf("Wrong SQL syntax\n"); return 0;}
			}
			else {printf("Unknown keywords"); return 0;}
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
					return 1;
				}
				else    // not sure what to do when there is not a semicolon in the end
				{
					printf("u r wrong semicolon"); 
					return 0;
				}
			}
			else if(tok == PRIMARY)
			{
				tok = yylex();
				if(tok == KEY)
				{
					tok = yylex();
					if(tok == COMMA) PK = num - 1;
					else {printf("Wrong SQL syntax\n"); return 0;}
				}
				else {printf("Unknown keywords\n"); return 0;}
			}
			else if(tok != COMMA) {printf("Wrong SQL syntax\n");return 0;}
		}
	}//LEFTPA
	else {printf("Wrong SQL syntax\n"); return 0;}
	}//NAME
	else {printf("Unknown keywords\n"); return 0;}
	}//TABLE
	else {printf("Unknown keywords\n"); return 0;}
	return 1;
}
void insert()
{
	
}
void main(int argc, char **argv)
{
	int size;
	int k = 2;
	tok = yylex();
	PK = -1;
	num = 0; // attribute numbers
	int TBN = 0; //table numbers
	struct Table tables[30]; 
	int flag;
	if(tok == CREATE)
	{ 
		tok = yylex();
		flag = create();
		if(flag)
		{
		
			strcpy(tables[TBN].TBname, TBname);
			tables[TBN].PK = PK;
			for(int i = 0; i < num; i++)
			{
				strcpy(tables[TBN].attribute_name[i] ,str[i]);
				tables[TBN].attribute_type[i] = type[i];
				tables[TBN].attribute_length[i] = length[i];
			}
			tables[TBN].attribute_num = num;
			TBN++;
		}
		printf("table: name%s\n",tables[0].TBname);
		printf("PRIMARY KEY PLACE: %d\n",tables[0].PK);
		for(int i = 0; i < num; i++) printf("%10s",tables[0].attribute_name[i]);
		printf("\n");
		for(int i = 0; i < num; i++) printf("%10d",tables[0].attribute_type[i]);
		printf("\n");
		printf("attribute num: %d\n",tables[0].attribute_num);
	}
	else if(tok == INSERT)
	{
		tok = yylex();
		insert();
	}

}