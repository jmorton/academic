/*   author: Jon Morton -- jon.morton@gmail.com
 *    about: Homework 1 for CS367 at GMU
 *  created: 28-August 2008
 *
 *  This program solves the problem and meets all special requirements.
 */

#include <stdio.h>
#include <stdlib.h>

#define MAXINPUT 20

// Calculate average of a set of numbers
int average(int *numbers, int size) {
  int ix = 0;
  int sum = 0;
  
  for(ix = 0; ix < size; ix++) {
    sum += numbers[ix];
  }
  
  return sum / size;
}

int main(void) {
  int inputLimit = 0;
  
  // Figure out how many numbers the user will enter
  printf("How many numbers?: ");
  scanf("%d", &inputLimit);
  printf("Enter the numbers. (Press <Enter> after each number.)\n");
  
  // Create placeholder for user inputs
  int inputs[inputLimit];
  
  // Gather user input (without error handling)
  int ix = 0;
  for(ix = 0; ix < inputLimit; ix++) {
    scanf("%d", &inputs[ix]);
  }
  
  // Calculate and display average of person's inputs
  printf("The average is %d\n", average(inputs, inputLimit));
  
  return EXIT_SUCCESS;
}