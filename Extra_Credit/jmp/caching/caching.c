#include <stdlib.h>
#include <stdio.h>

// How big is our array of data we are going to allocate.
const int size = 2<<21;

// The following functions A, B, C and D all compute the
// same result but going about it in slight different ways.
int A(const int const *a, const int const *b) {
	int sum = 0;
	int i = 0;
	for (i=0; i<size; ++i) {
		sum += a[i];
		sum += b[i];
	}

	for (i=0; i<size; ++i) {
		sum += a[i];
		sum += b[i];
	}
	return sum;
}

int B(const int const *a, const int const *b) {
	int sum = 0;
	int i = 0;
	for (i=0; i<size; ++i) {
		sum += a[i];
		sum += a[i];
	}

	for (i=0; i<size; ++i) {
		sum += b[i];
		sum += b[i];
	}
	return sum;
}


int C(const int const *a, const int const *b) {
	int sum = 0;
	int i = 0;
	for (i=0; i<size; ++i) {
		sum += a[i];
		sum += a[i];
		sum += b[i];
		sum += b[i];
	}
	return sum;
}

int D(const int const *a, const int const *b) {
	int sum = 0;
	int i = 0;
	for (i=0; i<size; ++i) {
		sum += a[i];
		sum += b[i];
		sum += a[i];
		sum += b[i];
	}
	return sum;
}

int main(int argc, char *argv[]) {

	// Allocate some chunks of memory and set all values to 0
	int *minus_ones = (int *) calloc(size, sizeof(minus_ones));
	int *ones = (int *) calloc(size, sizeof(ones));

	int i = 0;

	// Initialize each array.
	for (i=0; i<size; ++i) {
		minus_ones[i] = -1;
		ones[i] = 1;
	}

	// Our running counter
	int sum = 0;

	// We can pass in a command line argument A, B, C, D to specify which function we
	// want to run. If we don't pass anything it defaults to A.
	if (argc == 2) {
		char mode = argv[1][0];
	
		// we could have used a function pointer ie) (*func_ptr)(int *, int *) or nested
		// in a loop but we'll opt for being very very explicit with the control flow.
		if (mode == 'A') for (int i=0; i<1000; ++i) sum += A(minus_ones, ones);
		else if (mode == 'B') for (int i=0; i<1000; ++i) sum += B(minus_ones, ones);
		else if (mode == 'C') for (int i=0; i<1000; ++i) sum += C(minus_ones, ones);
		else if (mode == 'D') for (int i=0; i<1000; ++i) sum += D(minus_ones, ones);
		else { 
			printf("Invalid mode\n");
			free(minus_ones);
			free(ones);
			exit(1);
		}
	} else {
		for (i=0; i<1000; ++i) { 
			sum += A(minus_ones, ones);
		}
	}

	printf("%d\n", sum);

	free(minus_ones);
	free(ones);
}
