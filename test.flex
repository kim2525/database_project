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
int MAX_INT = 2147483647;
int MIN_INT =  -2147483648;
int tok;
int tkval;
char tstr[100]; //if it is a name, store the name
char tkval_s[100];
struct Table tables[30]; 
FILE *paser_generator, *output;
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
-?[0-9]+ { strcpy(tkval_s, yytext); tkval = atoi(yytext);return INT;}
[A-Za-z_][A-Za-z0-9_]* {strcpy(tstr,yytext);return NAME;}
. {}

%%

void error_eater() // when error occur eat the surplus words until ';'
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
	int i, j;
	int len0;
	if(tok == TABLE)
	{ //TABLE 
	fprintf( paser_generator , "TABLE	", tok);
	tok = yylex();
	if(tok == NAME)
	{ //NAME
	len0 = strlen(tstr);// MAX_LENGTH = 100
	for(i=0; i<len0; i++) tstr[i] = (char)tolower(tstr[i]);
	fprintf( paser_generator , "%s ", tstr);
	strcpy(TBname, tstr);
	for(i=0; i<(*TBN); i++)//check repeat table name
	{
		int len0 = strlen(tstr);
		if(strcmp(tables[i].TBname, tstr) == 0)
		{	printf("There has a same Table name\n"); error_eater(); return; }
	}
	tok = yylex();
	if(tok == LEFTPA) // (
	{ // LEFTPA
		fprintf( paser_generator , "(\n\n");
		while(1)
		{
			tok = yylex();
			if(tok == NAME)//ATTRITUBE
			{
				if(num >= 10) {printf("Each table up to 10 attribute\n"); error_eater(); return;} // Each table up to 10 attribute
				len0 = strlen(tstr);
				for(i=0; i<len0; i++) tstr[i] = (char)tolower(tstr[i]);
				fprintf( paser_generator , "	%s ", tstr);
				for(i=0;i<num;i++)// check repeat attribute name
				{
					if(strcmp(str[i],tstr) == 0)
					{	printf("There has a same attribute\n"); error_eater(); return; }
				}
				strcpy(str[num],tstr);
			}
			else {printf("u r wrong NAME\n"); error_eater(); return;} // the things may not be a attribute name
			tok = yylex();
			
			if(tok == integer) { fprintf( paser_generator , "int "); type[num] = 0; } //int case
			else if(tok == VARCHAR) //varchar case
			{
				fprintf( paser_generator , "varchar");
				type[num] = 1;
				tok = yylex();
				int flag = 0;    // to see if the error is last() or wrong type
				if(tok == LEFTPA) // (
				{
					fprintf( paser_generator , "( ");
					tok = yylex();
					if(tok == INT) // tkval 
					{
						int tkval_length = strlen(tkval_s);
						if(tkval_length > 2 || tkval > 40 ) { printf("The num in varchar() is wrong \n"); error_eater(); return; } // check tkval > 40
						fprintf( paser_generator , "%d ", tkval);
						tok = yylex();
						if(tok == RIGHTPA) 
						{ fprintf( paser_generator , ") "); length[num] = tkval; } //  )
						else flag = 1;
					}
					else flag = 2;
				}
				else flag = 1;	//if is in wrong format
				if(flag == 1) {printf("Unknown type\n"); error_eater(); return;}
				else if(flag == 2) {printf("Wrong SQL syntax\n"); error_eater(); return;}
			}
			else {printf("Unknown keywords\n"); error_eater(); return;}
			num++;
			tok = yylex();
			if(tok == RIGHTPA) // )
			{
				fprintf( paser_generator , "\n\n)");
				tok = yylex();
				if(tok == SEMICOLON || tok == 0) 
				{
					fprintf( paser_generator , ";\n");
					break;
				}
				else    // not sure what to do when there is not a semicolon in the end
				{
					printf("expected a semicolon\n"); 
					error_eater();
					return;
				}
			}
			else if(tok == PRIMARY)
			{
				fprintf( paser_generator , "PRIMARY ");
				tok = yylex();
				if(tok == KEY)
				{
					fprintf( paser_generator , "KEY ");
					tok = yylex();
					if(tok == COMMA) { fprintf( paser_generator , ",\n"); PK = num - 1;}
					else if(tok == RIGHTPA) {
						tok = yylex();
						if(tok == SEMICOLON || tok == 1) 
						{
							
							fprintf( paser_generator , ";\n");
							PK = num - 1;
							break;
						}
						else    // not sure what to do when there is not a semicolon in the end
						{
							printf("expected a semicolon\n");
							error_eater();
							return;
						}
					}
					else {printf("Wrong SQL syntax\n"); error_eater(); return;}
				}
				else {printf("Unknown keywords\n"); error_eater(); return;}
			}
			else if(tok != COMMA) {printf("Wrong SQL syntax\n"); error_eater(); return;}
			fprintf( paser_generator , ",\n");
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
	int i, table_number = -1, index[10], now, j, flag, count, loopFlag = 0;
	struct tuple *input, *temp, *PkCheck;
	input = (struct tuple*)malloc(sizeof(struct tuple));
	
	for(i=0; i<10; i++) index[i] = -1;
	for(i=0; i<20; i++) input->is_null[i] = 1;
	for(i=0; i<20; i++) input->grid[i].string[0] = '\0';
	input->PK = -1;
	input->next = NULL;
	
	tok = yylex();
	if(tok == INTO)
	{
		fprintf( paser_generator , "INTO	");
		tok = yylex();
		if(tok == NAME)
		{ 
			for(i=0; i<(*TBN); i++)
			{
				int len0 = strlen(tstr);
				for(j=0; j<len0; j++)  tstr[j] = (char)tolower(tstr[j]);
				fprintf( paser_generator , "%s ",tstr);
				
				if(strcmp(tables[i].TBname, tstr) == 0)
				{
					table_number = i;
					input->attribute_num = tables[i].attribute_num;
					input->PK = tables[i].PK;
					for(j=0; j<input->attribute_num; j++)
					{
						input->grid[j].type = tables[i].attribute_type[j];
						index[j] = j; // reset order according to table attribute
					}
					break;
				}
			}
			if(table_number != -1)
			{
				tok = yylex();
				if(tok == LEFTPA)
				{
					loopFlag = 1;
					fprintf( paser_generator , "( ");
					now = 0;
					while(1)
					{
						tok = yylex();
						if(tok == NAME)
						{
							if(now >= tables[table_number].attribute_num){printf("Too many attribute during INSERT\n"); error_eater(); return;}// now >= attribute_num
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
							fprintf( paser_generator , "%s ",tstr);
							if(flag == 0) {printf("NO such Attribute name\n"); error_eater(); return;}
						}
						else {printf("Wrong Attribute name\n"); error_eater(); return;}
						tok = yylex();
						count = ++now;
						if(tok == RIGHTPA)
						{
							for(i=0;i<count;i++)
							{
								for(j=i+1;j<count;j++)
								{
									if(index[i] == index[j])
									{
										{printf("Repeat attribute name during INSERT\n"); error_eater(); return;}
									}
								}
							}
							fprintf( paser_generator , ")\n");
							tok = yylex();
							break;
						}
						else if(tok != COMMA)
						{
							printf("Wrong syntax\n");
							error_eater();
							return;
						}
						if(tok == COMMA) fprintf( paser_generator , ", ");
					}
				}
				if(tok == VALUES)
				{
					fprintf( paser_generator , "VALUES ");
					tok = yylex();
					if(tok == LEFTPA)
					{
						fprintf( paser_generator , "( ");
						int nowp;
						now = 0;
						while(1)
						{
							if(now >= count &&loopFlag == 1) {printf("Too many value\n"); error_eater();return;}
							tok = yylex();
							nowp = index[now];
							if(tok == INT)
							{
								int tkval_length = strlen(tkval_s);
								fprintf( paser_generator , "%d ", tkval);
								if((tkval_s[0] != '-'&& tkval_length > 10) || (tkval_s[0] == '-'&& tkval_length > 11) || (tkval_s[0] != '-' && tkval_length == 10 && tkval <= 0) || (tkval_s[0] == '-' && tkval_length == 11 && tkval >= 0) ) 
								{ printf("iNTERGER is out of bound \n"); error_eater(); return; } // check the integer boundary
								if(input->grid[nowp].type == 0) //type match
								{
									if(input->PK != -1 && input->PK == nowp)
									{
										PkCheck = tables[table_number].tuple_address;
										while(PkCheck != NULL)
										{
											if(PkCheck ->grid[input->PK].integer == tkval)
											{	printf("PRIMARY KEY repeat \n"); error_eater(); return;}
											PkCheck = PkCheck ->next;
										}
									}
									input->grid[nowp].integer = tkval;
									input->is_null[nowp] = 0;
								}
								else {printf("Attribute type should be varchar\n"); error_eater(); return;}
							}
							else if(tok == STRING)
							{
								if(input->grid[nowp].type == 1) //type match
								{
									fprintf( paser_generator , "%s ", tstr);
									int length = strlen(tstr)-2;
									if(length > tables[table_number].attribute_length[nowp]) {printf("String length too long\n"); error_eater(); return;}
									input->is_null[nowp] = 0;
									for(i=0; i<length; i++)
									{
										input->grid[nowp].string[i] = tstr[i+1];
									}
									if(input->PK != -1 && input->PK == nowp)
									{
										PkCheck = tables[table_number].tuple_address;
										while(PkCheck != NULL)
										{
											if(strcmp(PkCheck ->grid[input->PK].string, input->grid[nowp].string) == 0)
											{	printf("PRIMARY KEY repeat \n"); error_eater(); return;}
											PkCheck = PkCheck ->next;
										}
									}
								}
								else {printf("Attribute type should be int\n"); error_eater(); return;}
							}
							else if(tok == COMMA)
							{
								fprintf( paser_generator , ", ");
								if(input->PK != -1 && input->PK == nowp) { printf("PRIMARY KEY attribute can't be NULL\n"); error_eater(); return;}	
								now++;
								continue; // insert value is null
							}
							else if(tok == RIGHTPA)
							{
								fprintf( paser_generator , ") ");
								tok = yylex();
								now++;
								if(tok == SEMICOLON || tok == 0) 
								{
									fprintf( paser_generator , ";\n\n");
									if(input->PK != -1 &&input->is_null[input->PK] == 1) { printf("PRIMARY KEY attribute can't be NULL\n"); return;}
									break;
								}
								else
								{
									printf("expected a semicolon\n"); 
									error_eater();
									return;
								}
							}
							else {printf("Attribute value should be int or varchar or null\n"); error_eater(); return;}
							now++;
							tok = yylex();
							if(tok == RIGHTPA)
							{
								fprintf( paser_generator , ") ");
								tok = yylex();
								if(tok == SEMICOLON || tok == 0) 
								{
									
									if(now!=count && loopFlag == 1){ printf("now != count\n"); return;}
									if(now > tables[table_number].attribute_num && loopFlag == 0){ printf("now > attribute_num\n"); return;}
									fprintf( paser_generator , ";\n\n");
									if(input->PK != -1 && input->is_null[input->PK] == 1) { printf("PRIMARY KEY attribute can't be NULL\n"); return;}
									break;
								}
								else
								{
									printf("expected a semicolon\n"); 
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
							else if(tok == COMMA) {fprintf( paser_generator , ", ");}
						}
						
						if(input->PK == -1)
						{
							temp = tables[table_number].tuple_address;
							flag = 0;
							
							while(temp != NULL)
							{
								for(i=0; i<temp->attribute_num; i++)
								{
									if(temp->is_null[i] != input->is_null[i]) break;
									else
									{
										if(temp->grid[i].type == 0) //int
										{
											if(temp->grid[i].integer != input->grid[i].integer) break;
										}
										else //varchar
										{
											if(strcmp(temp->grid[i].string, input->grid[i].string) != 0) break;
										}
									}
								}
								
								if(i == temp->attribute_num)
								{
									flag = 1;
									break;
								}
								temp = temp->next;
							}
							
							if(flag == 1) {printf("Repeat tuple (No primary key)\n"); return;}
						}
						input->next = tables[table_number].tuple_address;
						tables[table_number].tuple_address = input;
						
						printf("%10d\n",input->attribute_num);
						for(int i = 0; i < input->attribute_num; i++)
						{
							if(input->is_null[i] == 1) printf("NULL\n");
							else if(input->grid[i].type == 0) printf("%10d\n",input->grid[i].integer);
							else printf("%10s\n",input->grid[i].string);
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
	int size,cycle = 0;
	int TBN = 0; //table numbers
	int flag;
	paser_generator = fopen("paser_generator.txt","w"); //Print out paser reselt to check the paser is correst or no fprintf( paser_generator , "%s", tok);
	output = fopen("output.txt","w");
	while(1)
	{
		printf("cycle: %d\n",cycle++);
		tok = yylex();
		if(tok == CREATE)
		{ 
			fprintf( paser_generator , "\nCREATE	");
			tok = yylex();
			create(&TBN);
			/*printf("table: name%s\n",tables[0].TBname);
			printf("PRIMARY KEY PLACE: %d\n",tables[0].PK);
			for(int i = 0; i < tables[0].attribute_num; i++) printf("%10s",tables[0].attribute_name[i]);
			printf("\n");
			for(int i = 0; i < tables[0].attribute_num; i++) printf("%10d",tables[0].attribute_type[i]);
			printf("\n");
			printf("attribute num: %d\n",tables[0].attribute_num);*/
		}
		else if(tok == INSERT)
		{
			fprintf( paser_generator , "\nINSERT	");
			insert(&TBN);		
			printf("\n");
		}
		else if(tok == 0) break;
		else
		{
			printf("unknown keyword\n");
			error_eater();
		}
	}
	for(int i = 0; i < TBN; i++)
	{
		fprintf(output,"table name: %s\n",tables[i].TBname);
		fprintf(output,"PRIMARY KEY PLACE: %d\n",tables[i].PK);
		for(int j = 0; j < tables[i].attribute_num; j++) fprintf(output,"%10s",tables[i].attribute_name[j]);
		fprintf(output,"\n");
		for(int i = 0; i < 100; i++) fprintf(output,"-");
		fprintf(output,"\n");
		for(struct tuple *j = tables[i].tuple_address; j != NULL; j = j -> next)
		{
			for(int k = 0;k < j->attribute_num; k++)
			{
				if(j->is_null[k] == 1) fprintf(output,"      NULL");
				else
				{
					if(j->grid[k].type == 0) fprintf(output,"%10d",j->grid[k].integer);
					else fprintf(output,"%10s",j->grid[k].string);
				}
				
			}fprintf(output,"\n\n");
		}
	}
	fclose(output);
	fclose(paser_generator);
	return ;
}