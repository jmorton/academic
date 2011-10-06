#include <stdio.h>
#include <string.h>
#include "hash.h"

int main(int argc, char * argv[]) {

	struct symbol** symtable = setupSymbolTable();

	int choice;
	char *key;
	char *type;
	int insertResult;
	struct symbol* lookupResult;

	while (1) {

		printf("Choose An Action: [1] Insert \t[2] Lookup\t[3] Quit\n");
		printf("~> ");
		scanf("%d", &choice);

		// Insert...
		if (choice == 1) {
	    printf("key: ");
	    scanf("%sa", &key);
	    printf("type: ");
	    scanf("%sa", &type);
	    insertResult = insert(symtable, &key, &type);
	    printf("inserting '%s' -- result: %d\n", &key, insertResult);

			// Lookup...
		} else if (choice == 2) {
	    printf("key: ");
	    scanf("%sa", &key);
	    lookupResult = lookup(symtable, &key);

	    if (lookupResult != NULL) {
				printf("'%s' found, type: %s\n", lookupResult->name, lookupResult->type);
	    } else {
				printf("'%s' not found\n", &key);
	    }

			// Quit
		} else if (choice == 3) {
	    printf("Bye!\n");
	    return 0;

		} else {
	    printf("Invalid choice!\n");
		}

	}

	return 0;
}
