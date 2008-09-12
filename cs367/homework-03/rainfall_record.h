#include <stdio.h>
#include <stdlib.h>

struct rainfall_record {
  char city[80];
  float amount;
};

void readRecords(struct rainfall_record *record, FILE *file, int length);

float computeAverage(struct rainfall_record *record, int length);
