#include <stdio.h>

struct rainfall_record {
};

void readRecords(struct rainfall_record record[], FILE file, int);

float computeAverage(struct rainfall_record record[], int);
