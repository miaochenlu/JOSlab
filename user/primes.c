#include "kernel/types.h"
#include "user/user.h"

void redirect(int k, int p[]) {
    close(k);
    dup(p[k]);
    close(p[0]);
    close(p[1]);
}

void primes() {
    int p[2];
    int num;

    if(read(0, (void*)&num, sizeof(num)) <= 0)
        return;
    
    printf("prime %d\n", num);
    if(pipe(p) < 0) {
        fprintf(2, "Error: cannot create pipe");
        exit(1);
    }
    int pid = fork();
    if(pid == 0) {
        redirect(0, p);
        primes();
    } else {
        redirect(1, p);
        int tmpnum = 0;
        while(read(0, (void*)&tmpnum, sizeof(tmpnum))) {
            if(tmpnum % num != 0) {
                write(1, (void*)&tmpnum, sizeof(tmpnum));
            }
        }
        close(1);
        wait(&pid);
    }

    
}

int main(int argc, char* argv[]) {
    int p[2];
    if(pipe(p) < 0) {
        fprintf(2, "Error: cannot create pipe");
        exit(1);
    }

    int pid = fork();
    if(pid == 0) {
        redirect(0, p);
        primes();
    } else {
        redirect(1, p);
        for(int i = 2; i <= 35; i++) {
            write(1, (void*)&i, sizeof(i));
        }
        close(1);
        wait(&pid);
    }
    exit(0);
}