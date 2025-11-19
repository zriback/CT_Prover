#include <stdint.h>
#include <stdio.h>
#include "../../ct-verif.h"

extern void vfct_taintseed(const void *secret_value);
const int32_t getint32(void);

static int bad_function(int a, int b) {
    int sum = a + b;
    printf("a + b = %d + %d = %d\n", a, b, sum);
    return sum;
}

void bad_wrapper(int a, int b) {
    vfct_taintseed(&a);
    public_in(__SMACK_value(b));

    int sum = bad_function(a, b);
    public_out(__SMACK_value(sum));
}

void bad_wrapper_t(void) {
    int secret = (int)getint32();
    int public_value = (int)getint32();
    bad_wrapper(secret, public_value);
}
