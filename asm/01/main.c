int main(char* argc) {
	
	// int x;
	// x = incrementing();
	// printf("%i\n", x);
	
	int ret_status;
	ret_status = asm_main();
	printf("%d\n",ret_status);
	
	return ret_status;
}