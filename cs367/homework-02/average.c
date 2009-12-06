/*   author: Jon Morton -- jon.morton@gmail.com
 * 
 *    about: Homework 2 for CS367 at GMU
 *           http://www.cs.gmu.edu/~rcarver/cs367/hm2.txt
 *
 *  created: 7-September 2008
 *
 *  This program solves the problem and meets all special requirements.
 */

#include <stdio.h>
#include <stdlib.h>

#define MAXINPUT 20

// Prompt for and return number of integers to collect
int promptNumber() {
  int input = 0;
  
  printf("How many numbers?: ");
  scanf("%d", &input);
  
  return input;
}

// Prompt for [length] of numbers and put them in [numbers]
void readNumbers(int numbers[], int length) {
  int ix = 0;
  
  printf("Enter the numbers. (Press <Enter> after each number.)\n");
  
  // Gather user input (without error handling)
  for(ix = 0; ix < length; ix++) {
    scanf("%d", (numbers + ix));
  }
}

// Calculate average of values in [numbers] and updates [result]
// with the calculation.
void computeAverage(int numbers[], int length, float *result) {
  int ix = 0;
  int sum = 0;
  
  for(ix = 0; ix < length; ix++) {
    sum += *(numbers + ix);
  }
  
  *result = sum / length;
}

int main(void) {
  // Create placeholder for user inputs
  int inputs[MAXINPUT];
  int limit = 0;
  float average = 0;

  // Determine numebr of numbers to prompt for
  limit = promptNumber();
  readNumbers(inputs, limit);

  // Calculate and display average of person's inputs
  computeAverage(inputs, limit, &average);
  printf("The average is %.1f\n", average);
  
  return EXIT_SUCCESS;
}
