#include <stdio.h>
#include <stdlib.h>

#include "rainfall_record.h"

void readRecords(struct rainfall_record *record, FILE *file, int length) {
  int i = 0;
  
  // Read each line in the file into the allocated array.
  for (i = 0; i < length; i++) {
    fscanf(file, "%s %f", &(record+i)->city, &(record+i)->amount);
    printf("%s %0.1f\n", (record+i)->city, (record+i)->amount);
  }
}

float computeAverage(struct rainfall_record *record, int length) {
  int i = 0;
  float sum = 0.0;
  
  for (i = 0; i < length; i++) {
    sum += (record+i)->amount;
  }
  
  return sum / length;
}