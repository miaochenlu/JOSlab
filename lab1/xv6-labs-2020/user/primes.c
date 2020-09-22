#include "kernel/types.h"
#include "user/user.h"


void redirect(int k, int pd[]) {
  close(k);
  dup(pd[k]);
  close(pd[0]);
  close(pd[1]);
}

void cull(int p) {
  int n;

  while(read(0, &n, sizeof(n))) {
    if(n % p != 0) {
      write(1, &n, sizeof(n));
    }
  }
}

void right() {
  int pd[2], p;

  if(read(0, &p, sizeof(p))) {
    printf("prime %d\n", p);
    pipe(pd);
    
    int pid = fork();
    if(pid != 0) {
      redirect(0, pd);
      right();
      wait(&pid);
    } else {
      redirect(1, pd);
      cull(p);
    }
  }
}


int
main(int argc, char* argv[]) {
  int pd[2];
  if(pipe(pd) < 0) {
    fprintf(2, "Error: Cannot create pipe!\n");
    exit(1);
  }

  int pid = fork();

  if(pid != 0) {
    redirect(0, pd);
    right();
    wait(&pid);
  } else {
    redirect(1, pd);
    for(int i = 2; i <= 35; i++) {
      write(1, &i, sizeof(i));
    }
  } 
  exit(0);
}
