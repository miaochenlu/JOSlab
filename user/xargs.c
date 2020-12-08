#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    char *nargs[MAXARG];
    int argCount = 0;
    for(int i = 1; i < argc; i++) {
        nargs[argCount++] = argv[i];
    }

    char tmpchar = 0;
    char buffer[1024];

    int status = 1;
    while(status) {
        int pos = 0;
        int argStartPos = 0;
        
        while(1) {
            status = read(0, &tmpchar, 1);
            if(status == 0) exit(0);
            if(tmpchar != ' ' && tmpchar != '\n') {
                buffer[pos++] = tmpchar;
            } else if(tmpchar == ' ') {
                buffer[pos++] = 0;
                nargs[argCount++] = &buffer[argStartPos];
                argStartPos = pos;
            } else if(tmpchar == '\n') {
                nargs[argCount++] = &buffer[argStartPos];
                argStartPos = pos;
                break;
            }
        }

        if(fork() == 0) {
            exec(nargs[0], nargs);
        } else {
            wait(0);
        }
    }
    exit(0);
}