#include <stdio.h>
#include "list.h"

// Used for example purposes...
void display(struct item *i) {
	printf("  %3d ", (int)(i->data));
}

// Used for example purposes...
int multiply(struct item *item) {
	return 3 * ((int)(item->data));
}


int main() {

	struct list *stack = (struct list*) malloc(sizeof(struct list));
	struct item *tempItem;
	int i;

	for (i = 0; i < 10; i++) {
		tempItem = (struct item*) (malloc(sizeof(struct item))); 
		tempItem->data = i;
		insert(stack, tempItem, 2);
		get(stack, i);
	}

	printf("List Details: \n");
	printf("Tail: %3d \t", (int)(get(stack,9)->data) );
	printf("Head: %3d \t", (int)(get(stack,0)->data) );
	printf("Length: %3d \t", (int)(stack->length) );
	printf("\n");
	each(stack, &display);

	struct list *mapping = map(stack, &multiply);

	printf("\nPrinting tripled stack: \n");
	each(mapping, &display);

	printf("\nPrinting original stack: \n");
	each(stack, &display);

	for (i = 1; i <= 5; i++) {
		tempItem = take(stack, stack->length-1);
	}

	printf("\nPrinting trimmed stack: \n");
	each(stack, &display);

	printf("\nDone.\n");

	return 0;
}

