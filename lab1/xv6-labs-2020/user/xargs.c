#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

#define ARGLEN 32
int main(int argc, char* argv[]) {
    if(argc < 2) {
        fprintf(2, "Usage: xargs [params] \n");
        exit(1);
    }
    char args[MAXARG][ARGLEN];

    while(1) {
        memset(args, 0, MAXARG * ARGLEN);
        //copy args
        for(int i = 0, j = 1; j < argc && i < MAXARG - 1; j++) {
            strcpy(args[i++], argv[j]);
        }

        
    }
}

