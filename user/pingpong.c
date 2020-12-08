#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
    int p2c[2];
    int c2p[2];
    char buf[10];
    pipe(p2c);
    pipe(c2p);
    if(fork() == 0) {
        close(p2c[1]);
        close(c2p[0]);
        read(p2c[0], buf, 1);
        if(buf[0] == 'p') {
            printf("%d: received ping\n", getpid());
        }
        close(p2c[0]);
        write(c2p[1], "c", 1);
        close(c2p[1]);
        exit(0);
    } else {
        close(p2c[0]);
        close(c2p[1]);

        write(p2c[1], "p", 1);
        close(p2c[1]);
        read(c2p[0], buf, 1);
        if(buf[0] == 'c') {
            printf("%d: received pong\n", getpid());
        }
        close(c2p[0]);
        exit(0);
    }
    exit(0);
}