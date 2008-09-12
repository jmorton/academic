rainfall: hm3.o rainfall_record.o
	cc -g -o rainfall hm3.o rainfall_record.o

hm3.o: hm3.c rainfall_record.h
	cc -g -c hm3.c

rainfall_record.o: rainfall_record.c rainfall_record.h
	cc -g -c rainfall_record.c