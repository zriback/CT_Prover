#include <stdint.h>
#include <stdio.h>
#include "../../ct-verif.h"

extern void vfct_taintseed(int secret_value);
const int32_t getint32(void);

static int bad_function(int a, int b) {
    int sum = a + b;
    int c = 50;
    if (sum > 100) {
	    printf("sum is greater than 100\n");
    }

    int quotient1 = a / b;
    int quotient2 = c / a;
    int quotient3 = b / c;

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
