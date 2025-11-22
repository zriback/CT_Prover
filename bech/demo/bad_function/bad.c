#include <stdint.h>
#include <stdio.h>
#include "../../ct-verif.h"

extern void vfct_taintseed(int secret_value);
const int32_t getint32(void);

static int bad_function(int a, int b) {
    int sum = a + b;
    if (sum > 10){
    	printf("sum was greater than 10!\n");
    }
    else {
	printf("Sum was less than 10 :(\n");
    }

    if (b % 2 == 0) {
	    printf("b is even\n");
    }
    if (a % 2 == 0) {
	    printf("a is even\n");
    }

    for (int i = 0; i < 100; i++) {
	    printf("Loop #%d\n", i);
    }

    for (int i = 0; i < a; i++) {
	    printf("Looping with a #%d\n", i);
    }

    if (a > 100) {
	    printf("a is greater than 100\n");
    }

    int c = a + 10;
    if (c > 5) {
	    printf("c is greater than 5\n");
    }



    return sum;
}

void bad_wrapper(int a, int b) {
    vfct_taintseed(a);
    public_in(__SMACK_value(b));

    (void)bad_function(a, b);
}

void bad_wrapper_t(void) {
    int secret = (int)getint32();
    int public_value = (int)getint32();
    bad_wrapper(secret, public_value);
}
