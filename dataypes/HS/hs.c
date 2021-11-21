#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// #define max(a,b) \
//    ({ __typeof__ (a) _a = (a); \
//        __typeof__ (b) _b = (b); \
//      _a > _b ? _a : _b; })

typedef enum {
    BIT_z = 0x0,
    BIT_0 = 0x1,
    BIT_1 = 0x2,
    BIT_x = 0x3
} tbit;

typedef long tvector; // This will represent a single header in binary i.e. 1x1z0, 1xxx01 etc)

struct hs {
   tvector* hs_list;
   tvector* hs_diff;
};

tvector hs_string_to_byte_array(char* hs_string, int strlen) {
    if (!hs_string || strlen == 0) {
    	printf("ERROR: Empty or null string given\n");
        return (BIT_z); // TODO: Add exception
    }
    tvector br = 0;
    for (int i = 0; i < strlen; i++) {
    	br = br << 2;
        // substr = str[max(0,strlen-4*j-4):strlen-4*j]
        if (hs_string[i] == 'X' || hs_string[i] == 'x')
            br += 0x03;
        else if (hs_string[i] == '1')
            br += 0x02;
        else if (hs_string[i] == '0')
            br += 0x01;
        else if (hs_string[i] == 'Z' || hs_string[i] == 'z')
            br += 0x00;
        else {
	    	printf("ERROR: Unrecognized string given\n");
	        return (BIT_z); // TODO: Add exception
        }
    }
    return br;
}

int main() {
   // printf() displays the string inside quotation
   tbit *value;
   value = malloc(3 * sizeof(tbit));
   value[0] = BIT_1;
   printf("%d\n", hs_string_to_byte_array("1xx01",5));
   return 0;
}