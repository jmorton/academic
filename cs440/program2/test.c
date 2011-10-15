/* Author: Jon Morton */

#include <stdio.h>
#include <string.h>
#include "hash.h"

void display_symbols(struct symbol * table[]) {
	struct symbol *entry;
	char *symbolName;
	int ix;
    
	for ( ix = 0 ; ix < 16 ; ix++ ) {
		entry = *(&table[ix]);
		printf("\n%3d: ", ix);
		for ( ; entry ; entry = entry->next ) {
			printf(" %s", entry->name);
		}
	}
    printf("\n");
}

int main(int argc, char * argv[]) {
    
	struct symbol** symtable = setupSymbolTable();
    
	int choice;
	int insertResult;
	char buffer[1024];
	char *key, *type;;
    
	struct symbol* lookupResult;
    
	while (1) {
        
		printf("Choose An Action: [1] Insert \t[2] Lookup\t[3] Quit\t [4] Full Test\n");
		printf("~> ");
		scanf("%d", &choice);
        
		// Insert...
		if (choice == 1) {
            
            printf("key: ");
            scanf("%1023s", buffer);
			key = (char*)malloc(sizeof(char) * strlen(buffer));
			strcpy(key, buffer);
            
            printf("type: ");
            scanf("%1023s", buffer);
			type = (char*)malloc(sizeof(char) * strlen(buffer));
			strcpy(type, buffer);
            
            insertResult = insert(symtable, key, type);
            printf("inserted '%s' -- result: %d\n", key, insertResult);
            
			// Lookup...
		} else if (choice == 2) {
            printf("key: ");
            scanf("%1023s", buffer);
			key = (char*)malloc(sizeof(char) * strlen(buffer));
			strcpy(key, buffer);
            lookupResult = lookup(symtable, key);
            
            if (lookupResult != NULL) {
				printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
            } else {
				printf("'%s' not found\n", key);
            }
            
			// Quit
		} else if (choice == 3) {
            printf("Bye!\n");
			display_symbols(symtable);
            break;
            
		} else if (choice == 4) {
			insertResult = insert(symtable, "foo", "a");
			insertResult = insert(symtable, "bar", "b");
			insertResult = insert(symtable, "baz", "c");
			insertResult = insert(symtable, "gru", "d");
            
            lookupResult = lookup(symtable, "foo");
			printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
            lookupResult = lookup(symtable, "bar");
			printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
            lookupResult = lookup(symtable, "baz");
			printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
            lookupResult = lookup(symtable, "gru");
			printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
            lookupResult = lookup(symtable, "nun");
			printf("'%s' not found, %s\n", "nun", lookupResult);
            
		} else {
            printf("Invalid choice!\n");
		}
        
	}
    
	return 0;
}
