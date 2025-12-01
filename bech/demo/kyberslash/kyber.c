#include <stdint.h>
#include <stdio.h>
#include "../../ct-verif.h"

#define KYBER_N 256
#define KYBER_Q 3329
#define KYBER_INDCPA_MSG_BYTES (KYBER_N/8)

extern void vfct_taintseed(int secret_value);
const int32_t getint32(void);

typedef struct{
  int16_t coeffs[KYBER_N];
} poly;


/************************************************
* Name:        poly_tomsg
*
* Description: Convert polynomial to 32-byte message
*
* Arguments:   - uint8_t *msg: pointer to output message
*              - const poly *a: pointer to input polynomial
**************************************************/
void poly_tomsg(uint8_t msg[KYBER_INDCPA_MSG_BYTES], const poly *a)
{
    unsigned int i,j;
    uint16_t t;

    for(i=0;i<KYBER_N/8;i++) {
        msg[i] = 0;
        for(j=0;j<8;j++) {
            t  = a->coeffs[8*i+j];
            t += ((int16_t)t >> 15) & KYBER_Q;
            t  = (((t << 1) + KYBER_Q/2)/KYBER_Q) & 1;
            msg[i] |= t << j;
        }
    }
}

void poly_tomsg_wrapper(uint8_t msg[KYBER_INDCPA_MSG_BYTES], const poly *a)
{
    public_in(__SMACK_value(msg));
    public_in(__SMACK_value(a));
    for (unsigned int i = 0; i < KYBER_N; i++) {
        vfct_taintseed((int)a->coeffs[i]);
    }
    (void)poly_tomsg(msg, a);
}


void kyber_wrapper_t(void) {
    uint8_t msg[KYBER_INDCPA_MSG_BYTES];
    poly a;

    for (unsigned int i = 0; i < KYBER_N; i++) {
        a.coeffs[i] = (int16_t)getint32();
    }

    poly_tomsg_wrapper(msg, &a);
}
