#include <stdio.h>
#include <stdlib.h>

int MAX_LENGTH=16;

typedef struct EmployeeStruct
{
	char Name[MAX_LENGTH];
	int EmployeeNumber;
	struct EmployeeStruct *Next;
} Employee;

Employee* stack = 0;

void push(Employee* e) {
	e->Next = stack;
	stack = e;
}

Employee* pop() {
	Employee* e;
	e = stack->Next;
	stack = stack->Next;
	return e;
}

void traverse() {
	printf("Traversing...\n");
	
	Employee* e = stack;
	for(; e != NULL; e = e->Next) {
		printf("Employee #%d, %s\n", e->EmployeeNumber, e->Name);
	}
}

int main() {
	Employee* new_employee = malloc(sizeof(Employee));
	new_employee->EmployeeNumber = 5;
	
	push(new_employee);
	traverse();
	pop();
	traverse();

	return 0;
}