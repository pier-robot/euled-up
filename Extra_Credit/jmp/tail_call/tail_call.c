#include <stdio.h>

int foo(int c, int v, int total) { 
    if ( c >= total) return v;
    v += 2;
    c += 1;
    return foo(c, v, total);
}


int main(int argc, char *argv[]) {
    int out = foo(0,1, 100000000);
	printf("out: %i\n", out);
	return 0;
}
