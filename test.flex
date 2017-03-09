%{
#include <string.h>
#include <ctype.h>
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
	STRING = 15,
	VALUES = 16
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
[Vv][Aa][Ll][Uu][Ee][Ss] {return VALUES;}
\'[ \r\t\f!-~]*\' {strcpy(tstr, yytext); return STRING;}
\( {return LEFTPA;}
\) {return RIGHTPA;}
\, {return COMMA;}
\; {return SEMICOLON;}
[\r\t\n\f]+ {}
-?[0-9]+ {tkval = atoi(yytext);return INT;}
[A-Za-z_][A-Za-z0-9_]* {strcpy(tstr,yytext);return NAME;}
. {}

%%

void error_eater()
{
	tok = 1;
	while(tok != SEMICOLON && tok != 0)
	{
		tok = yylex();
	}
}

void create(int *TBN)
{
	char str[100][100];   //store the name of attributes
	int type[100];	//store the type of attributes
	int length[100];
	char TBname[30];
	int PK = -1;
	int num = 0;
	int i;
	int len0;
	if(tok == TABLE)
	{ //TABLE
	tok = yylex();
	if(tok == NAME)
	{ //NAME
	len0 = strlen(tstr);
	for(i=0; i<len0; i++) tstr[i] = (char)tolower(tstr[i]);
	strcpy(TBname, tstr); 
	tok = yylex();
	if(tok == LEFTPA)
	{ // LEFTPA
		while(1)
		{
			tok = yylex();
			if(tok == NAME)
			{
				len0 = strlen(tstr);
				for(i=0; i<len0; i++) tstr[i] = (char)tolower(tstr[i]);
				strcpy(str[num],tstr);
			}
			else {printf("u r wrong NAME\n"); error_eater(); return;} // the things may not be a attribute name
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
				if(flag == 1) {printf("Unknown keywords\n"); error_eater(); return;}
				else if(flag == 2) {printf("Wrong SQL syntax\n"); error_eater(); return;}
			}
			else {printf("Unknown keywords"); error_eater(); return;}
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
					error_eater();
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
					else {printf("Wrong SQL syntax\n"); error_eater(); return;}
				}
				else {printf("Unknown keywords\n"); error_eater(); return;}
			}
			else if(tok != COMMA) {printf("Wrong SQL syntax\n"); error_eater(); return;}
		}
	}//LEFTPA
	else {printf("Wrong SQL syntax\n"); error_eater(); return;}
	}//NAME
	else {printf("Unknown keywords\n"); error_eater(); return;}
	}//TABLE
	else {printf("Unknown keywords\n"); error_eater(); return;}
	strcpy(tables[*TBN].TBname, TBname);
	tables[*TBN].PK = PK;
	for(i = 0; i < num; i++)
	{
		strcpy(tables[*TBN].attribute_name[i] ,str[i]);
		tables[*TBN].attribute_type[i] = type[i];
		tables[*TBN].attribute_length[i] = length[i];
	}
	tables[*TBN].attribute_num = num;
	tables[*TBN].tuple_address = NULL;
	(*TBN)++;
	num++;
}
void insert(int *TBN)
{
	int i, table_number = -1, index[10], now, j, flag;
	struct tuple *input, *temp, *temp2;
	input = (struct tuple*)malloc(sizeof(struct tuple));
	
	for(i=0; i<10; i++) index[i] = -1;
	for(i=0; i<20; i++) input->is_null[i] = 1;
	for(i=0; i<20; i++) input->grid[i].string[0] = '\0';
	input->PK = -1;
	input->next = NULL;
	
	tok = yylex();
	if(tok == INTO)
	{
		tok = yylex();
		if(tok == NAME)
		{
			for(i=0; i<(*TBN); i++)
			{
				int len0 = strlen(tstr);
				for(j=0; j<len0; j++)  tstr[j] = (char)tolower(tstr[j]);
				printf("%s\n",tstr);
				if(strcmp(tables[i].TBname, tstr) == 0)
				{
					table_number = i;
					input->attribute_num = tables[i].attribute_num;
					input->PK = tables[i].PK;
					for(j=0; j<input->attribute_num; j++)
					{
						input->grid[j].type = tables[i].attribute_type[j];
						index[j] = j;
					}
					break;
				}
			}
			if(table_number != -1)
			{
				tok = yylex();
				if(tok == LEFTPA)
				{
					now = 0;
					while(1)
					{
						tok = yylex();
						if(tok == NAME)
						{
							flag = 0;
							for(i=0; i<tables[table_number].attribute_num; i++)
							{
								int len0 = strlen(tstr);
								for(j=0; j<len0; j++) tstr[j] = (char)tolower(tstr[j]);
								if(strcmp(tables[table_number].attribute_name[i], tstr) == 0)
								{
									index[now] = i;
									flag = 1;
									break;
								}
							}
							if(flag == 0) {printf("NO such Attribute name\n"); error_eater(); return;}
						}
						else {printf("Wrong Attribute name\n"); error_eater(); return;}
						tok = yylex();
						if(tok == RIGHTPA)
						{
							break;
						}
						else if(tok != COMMA)
						{
							printf("Wrong syntax\n");
							error_eater();
							return;
						}
						now++;
					}
				}
				tok = yylex();
				if(tok == VALUES)
				{
					tok = yylex();
					if(tok == LEFTPA)
					{
						int nowp;
						now = 0;
						while(1)
						{
							tok = yylex();
							nowp = index[now];
							if(tok == INT)
							{
								if(input->grid[nowp].type == 0) //type match
								{
									input->grid[nowp].integer = tkval;
									input->is_null[nowp] = 0;
								}
								else {printf("Attribute type should be int\n"); error_eater(); return;}
							}
							else if(tok == STRING)
							{
								if(input->grid[nowp].type == 1) //type match
								{
									int length = strlen(tstr);
									if(length > tables[table_number].attribute_length[nowp]) {printf("String length too long\n"); error_eater(); return;}
									for(i=0; i<length-2; i++)
									{
										input->grid[nowp].string[i] = tstr[i+1];
										input->is_null[nowp] = 0;
									}
								}
								else {printf("Attribute type should be int\n"); error_eater(); return;}
							}
							else {printf("Attribute should be int or varchar\n"); error_eater(); return;}
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
									error_eater();
									return;
								}
							}
							else if(tok != COMMA)
							{
								printf("Wrong syntax\n");
								error_eater();
								return;
							}
							now++;
						}
						if(tables[table_number].tuple_address == NULL)
						{
							tables[table_number].tuple_address = input;
						}
						else
						{
							temp = tables[table_number].tuple_address;
							temp2 = temp->next;
							temp->next = input;
							input->next = temp2;
						}
					}
					else {printf("Syntax error\n"); error_eater(); return;}
				}
				else {printf("Syntax error\n"); error_eater(); return;}
			}
			else {printf("There is no this Table name\n"); error_eater(); return;}
		}
		else {printf("Wrong Table name\n"); error_eater(); return;}
	}
	else {printf("Syntax error, it should be INSERT INTO\n"); error_eater(); return;}
}

void main(int argc, char **argv)
{
	int size;
	
	int TBN = 0; //table numbers
	int flag;
	while(1)
	{
		tok = yylex();
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
			
			insert(&TBN);
			for(int i=0; i<tables[0].attribute_num; i++)
			{
				if(tables[0].attribute_type[i] == 0) printf("%10d", tables[0].tuple_address->grid[i].integer);
				else printf("%10s", tables[0].tuple_address->grid[i].string);
			}			
		}
	}
}