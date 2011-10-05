#include <stdio.h>
#include <stdlib.h>
#include "list.h"

/*
 * Jon Morton's doubly linked list library.
 *
 */

/*
 * Find item at the given position.  Position is zero based!
 *
 * Time Complexity:
 *   worst : o(n/2)
 *   head, tail : o(1)
 *
 */
struct item * 
get(struct list *listp, int index)
{
	/* Don't traverse somewhere unreachable. */
	if ((index < 0) || (index >= listp->length)) return NULL;

	struct item *p = listp->head;

	/* Adjust for the zero-index nature of lists. */
	int distance_from_end = (listp->length-1) - index;

	/* Optimization: Start at the head if it is closer
	 * to the index than the tail, otherwise start at
	 * the tail.
	 */
	if ( index < distance_from_end )
		for (p=listp->head; index-- ; p=p->next );
	else
		for (p=listp->tail; distance_from_end-- ; p=p->prev );

	return p;
}

/*
 * Remove item at given position from list.
 *
 * The next item points to the previous item
 * The previous item points to the next item
 * Size decreases by one
 * Head and/or tails is updated if taken.
 *
 */
struct item*
take(struct list* listp, int position)
{
	struct item *p = get(listp, position);

	/* If nothing was found, there is nothing to do. */
	if (p == NULL)
		return NULL;

	/* The list head and tail may need to be updated. */
	if (p == listp->tail)
		listp->tail = p->prev;
	if (p == listp->head)
		listp->head = p->next;

	/* Rewire the previous and next nodes. */
	if (p->next)
		p->next->prev = p->prev;
	if (p->prev)
		p->prev->next = p->next;

	/* Remove references to other items in the list. */
	p->next = p->prev = NULL;

	/* Reduce the length, otherwise the length is a lie. */
	listp->length -= 1;

	return p;
}

/*
 * Insert item before the item at the given position.
 *
 * Case 1: Empty list
 * Case 2: Insert into non-empty list
 * Case 3: Insert at end of list
 *
 * TBD:
 * - Won't inserting the same item will fracture the linked list?
 *
 */
struct item*
insert(struct list *listp, struct item *itemp, int position)
{
	// Keep track of the item at position, and the previous/next items too


	// Whatever the item referenced before is irrelevant so it is cleared.
	itemp->next = itemp->prev = NULL; 

  // Case 1: Insert itemp at head of list.
	if (position <= 0)
		{

			itemp->next = listp->head;
			listp->head = itemp;
			if (itemp->next)
				itemp->next->prev = itemp;
		}
	// Case 2: Insert at tail of list.
	else if (position >= listp->length)
		{
			itemp->prev = listp->tail;
			listp->tail = itemp;
			if (itemp->prev)
				itemp->prev->next = itemp;
		}
	// Case 3: Insert between two items in the list.
	else
		{
			struct item *b = get(listp, position);
			b->prev->next = itemp;
			b->prev = itemp;
			itemp->next = b;
			itemp->prev = b->prev;
		}

	// Ensure the tail is set... this only happens when adding
	// an item to an empty list.
	if (listp->tail == NULL)
		listp->tail = listp->head;

	// always increase the count since all cases are covered
	++(listp->length);
}

/* Take an item off the end of the list.  */
extern struct item*
pop(struct list *listp)
{
	return take(listp, (listp->length)-1);
}

/* Append an item to the end of the list. */
extern struct item*
push(struct list *listp, struct item *itemp)
{
	return insert(listp, itemp, listp->length);
}

/* Apply function to each item in the given list.  The function
 * can take any number of arguments.
 *
 */
extern void
each(struct list *listp, void* (*function)(void *))
{
	struct item *p;

	for ( p = listp->head ; p ; p = p->next )
		{
			(*function)(p);
		}
}

/* Create a new list by applying the given function to each item in the
 * given list.
 *
 * WARNING: This duplicates the item, not the data in the item!!!
 *
 */
extern struct list*
map(struct list *listp, void* (*function)(void *))
{
	struct list *results = (struct list*) (malloc(sizeof(struct list)));

	if (results == NULL)
		return 0; // out of memory

	struct item *original, *copy;

	for ( original = listp->head ; original ; original = original->next )
		{
			copy = (struct item*) (malloc(sizeof(struct item)));

			if (copy == NULL)
				{
					return 0; // out of memory
				}
			else
				{
					copy->data = original->data;
					copy->data = (*function)(copy);
					push(results, copy);
				}
		}

	return results;
}
