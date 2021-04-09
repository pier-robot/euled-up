# Overview

This is a wandering exploration of ideas. What originally started off 
as an attempt to investigate how [data oriented design](https://www.dataorienteddesign.com/dodmain)
affects performance, (by making sure to utilize L1 cache etc), quickly devolved into a
wrestling match with the compiler optimizer.

# Some Tests

The basis of the tests was to allocate a chunk of memory and the iterate over the values. The goal
to see how changing the algorithm in very subtle ways affects performance. The basic algorithm is

1. allocated an array of values of -1
1. allocated an array of values of 1
1. for each value in the array add them together twice
1. repeat adding the arrays together in this manner 1000 times.
The end sum should be 0

All the steps will be the same with minor changes to step 3.

## Test A

We loop through the length of the array twice adding each element together.

```c
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
```

## Test B

Similar to A, but we'll add the a's up first then the b's.

```c
int A(const int const *a, const int const *b) {
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
```

## Test C

Doing this as one loop, instead of two seperate ones.

```c
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
```

## Test D

Same as Test C, but change the order slightly.

```c
int C(const int const *a, const int const *b) {
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
```

## The Main Block

Here is the main block of code which invokes each test.
```c
char mode = argv[1][0];

if (mode == 'A') for (int i=0; i<1000; ++i) sum += A(minus_ones, ones);
else if (mode == 'B') for (int i=0; i<1000; ++i) sum += B(minus_ones, ones);
else if (mode == 'C') for (int i=0; i<1000; ++i) sum += C(minus_ones, ones);
else if (mode == 'D') for (int i=0; i<1000; ++i) sum += D(minus_ones, ones);
```

# Expectations

So given that we are running the same calculation but in slightly different ways
are there any guesses as to the performance of each? 

* Are they all run at roughly the same speed?
* Will they be radically different?
* What impact does the compiler optimization level have?

# Results

All times are in seconds


## C

|Optimization Level| A | B | C | D |
|------------------|---|---|---|---|
|-O0  |   17.090 | 17.689|  15.211 | 15.709|
|-O1  |   0.023  | 0.025 |  0.024  | 0.022 |
|-O2  |   0.024  | 4.260 |  3.908  | 2.110 |
|-O3  |   2.189  | 1.324 |  0.516  | 0.509 |

### What?

Godbolt time!

## Zig

|Optimization Level | A      | B     |  C     |  D      | E       |
|------------------|---|---|---|---|---|
| Debug               | 52.666 | 53.624|  48.372|  50.752 | 41.498  |
|-Drelease-safe | 5.832  | 4.465 |  3.962 |  4.062  | 4.036   |
|-Drelease-small| 4.138  | 4.202 |  1.981 |  1.990  | 1.408   |
|-Drelease-fast | 2.134  | 1.267 |  1.104 |  1.085  | 1.151   |

### What?

# Epilogue
To measure what was happening I was simplying timing real execution time and also verifying
cache hits with [Cachegrind](https://valgrind.org/docs/manual/cg-manual.html). However this
approach is far from robust and would definitely recommend looking at articles like 
[Getting 4 bytes or a full cache line: same speed or not?](https://lemire.me/blog/2018/07/31/getting-4-bytes-or-a-full-cache-line-same-speed-or-not)


