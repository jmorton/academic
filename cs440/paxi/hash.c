/* Author: Jon Morton */

#include "hash.h"

#define SYMBOL_TABLE_SIZE 16

extern struct symbol** setupSymbolTable() {
	return calloc(SYMBOL_TABLE_SIZE, sizeof(struct symbol));
}

// Calculate an index in the hashtable for the string.
unsigned int key(char * name) {
	unsigned int hash = 0;
	unsigned int c;
	while ( (c = *name++) ) hash = (hash * 7) ^ c;
	return (hash % SYMBOL_TABLE_SIZE);
}


// Insert a symbol into the table
extern int insert(struct symbol* table[], char * name, int type, int size, int location) {

	unsigned int index = key(name);
	struct symbol *entry = *(&table[index]);
	char *symbolName;

	// Find an existing entry to avoid duplicate symbols.
	for ( ; entry ; entry = entry->next ) {
		symbolName = entry->name;
		if (symbolName && strcmp(name, symbolName) == 0) {
	    return 0;
		}
	}

	// Allocate a new symbol (on the heap) ...
	struct symbol* s = (struct symbol*) malloc(sizeof(struct symbol));
	s->name = name;
	s->type = type;
  s->location = location;
	s->next = *(&table[index]);

	// ...and make it the head of this slot.
	table[index] = s;

	return 1;
}

// Get the entry in the hash table matching the given name.  Returns
// a symbol if it is found, otherwise null.
extern struct symbol* lookup(struct symbol* table[], char * name) {

	unsigned int index = key(name);
	struct symbol * entry = *(&table[index]);
	char * symbolName;
    
	// Find an existing entry to avoid duplicate symbols.
    for ( ; entry ; entry = entry->next ) {
		symbolName = entry->name;
		if (symbolName && strcmp(name, symbolName) == 0) {
	    return entry;
		}
	}
    
	return 0;
}
