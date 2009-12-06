#include <stdio.h>
#include <stdlib.h>

#include "rainfall_record.h"

int main(void) {
  
  FILE *file = NULL;
  int lines = 0;
  float average = 0.0f;
  struct rainfall_record *records = NULL;
  
  // open input file "rainfall.txt"
  file = fopen("rainfall.txt", "r");
  
  // determine how many lines will be read and setup records
  fscanf(file, "%d", &lines);
  records = (struct rainfall_record*) malloc(lines * sizeof(struct rainfall_record));
  
  // read the rainfall records into the array
  readRecords(records, file, lines);
  
  // calculate the average rainfall
  average = computeAverage(records, lines);
  
  // output all the records and print the average
  printf("\nThe average rainfall was: %.1f\n", average);
  
  return EXIT_SUCCESS;
}