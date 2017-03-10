struct Grid
{
	int type;  // 0 -> int 1 -> varchar
	int integer;
	char string[50];
};
struct tuple
{
	int attribute_num;
	int is_null[20];
	int PK;
	struct Grid grid[20];
	struct tuple *next;
};
struct Table
{
	char TBname[30];
	int attribute_num;
	int PK; // primary key's place default is -1;
	int attribute_type[30]; // 0 -> int 1 -> varchar
	char attribute_name[30][100];
	int attribute_length[30];
	struct tuple *tuple_address;
};
