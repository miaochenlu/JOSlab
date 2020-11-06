# Find Some References

https://www.cnblogs.com/nlp-in-shell/p/11909472.html

[MIT-6.s081-OS lab util Unix utilities_RedemptionC的博客-CSDN博客](https://blog.csdn.net/RedemptionC/article/details/106484363?utm_medium=distribute.pc_relevant.none-task-blog-OPENSEARCH-2.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-OPENSEARCH-2.channel_param)

[MIT6.828实验1 -- Lab Utilities](https://cloud.tencent.com/developer/article/1639599)

[zhayujie/xv6-riscv-fall19](https://github.com/zhayujie/xv6-riscv-fall19/tree/util/user)

[MIT 6.828 Lab 1: Xv6 and Unix utilities * The Real World](https://abcdlsj.github.io/post/mit-6.828-lab1xv6-and-unix-utilities/)

[6.S081-LAB1 Xv6 and Unix utilities](https://qinstaunch.github.io/2020/07/04/6-S081-LAB1-Xv6-and-Unix-utilities/)

# Lab1: Xv6 and Unix utilities

```bash
echo "deb [<http://mirrors.tuna.tsinghua.edu.cn/debian/>](<http://mirrors.tuna.tsinghua.edu.cn/debian/>) stable main" > /etc/apt/sources.list
```

## Prework: **Installing via APT (Debian/Ubuntu)**

Make sure you are running either "bullseye" or "sid" for your debian version (on ubuntu this can be checked by running cat /etc/debian_version), then run:

```
sudo apt-get install git build-essential gdb-multiarch qemu-system-misc gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu 
```

(The version of QEMU on "buster" is too old, so you'd have to get that separately.)

## Boot xv6 ([easy](https://pdos.csail.mit.edu/6.828/2020/labs/guidance.html))

```bash
$ git clone git://g.csail.mit.edu/xv6-labs-2020
Cloning into 'xv6-labs-2020'...
...
$ cd xv6-labs-2020
$ git checkout util
Branch 'util' set up to track remote branch 'util' from 'origin'.
Switched to a new branch 'util'
```

The xv6-labs-2020 repository differs slightly from the book's xv6-riscv; it mostly adds some files. If you are curious look at the git log:

```bash
$ git log
```

Build and run xv6:

```bash
$ make qemu
riscv64-unknown-elf-gcc    -c -o kernel/entry.o kernel/entry.S
riscv64-unknown-elf-gcc -Wall -Werror -O -fno-omit-frame-pointer -ggdb -DSOL_UTIL -MD -mcmodel=medany -ffreestanding -fno-common -nostdlib -mno-relax -I. -fno-stack-protector -fno-pie -no-pie   -c -o kernel/start.o kernel/start.c
...  
riscv64-unknown-elf-ld -z max-page-size=4096 -N -e main -Ttext 0 -o user/_zombie user/zombie.o user/ulib.o user/usys.o user/printf.o user/umalloc.o
riscv64-unknown-elf-objdump -S user/_zombie > user/zombie.asm
riscv64-unknown-elf-objdump -t user/_zombie | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$/d' > user/zombie.sym
mkfs/mkfs fs.img README  user/xargstest.sh user/_cat user/_echo user/_forktest user/_grep user/_init user/_kill user/_ln user/_ls user/_mkdir user/_rm user/_sh user/_stressfs user/_usertests user/_grind user/_wc user/_zombie 
nmeta 46 (boot, super, log blocks 30 inode blocks 13, bitmap blocks 1) blocks 954 total 1000
balloc: first 591 blocks have been allocated
balloc: write bitmap block at sector 45
qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 128M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

xv6 kernel is booting

hart 2 starting
hart 1 starting
init: starting sh
$ 
```

If you type ls at the prompt, you should see output similar to the following:

```bash
$ ls
.              1 1 1024
..             1 1 1024
README         2 2 2059
xargstest.sh   2 3 93
cat            2 4 24256
echo           2 5 23080
forktest       2 6 13272
grep           2 7 27560
init           2 8 23816
kill           2 9 23024
ln             2 10 22880
ls             2 11 26448
mkdir          2 12 23176
rm             2 13 23160
sh             2 14 41976
stressfs       2 15 24016
usertests      2 16 148456
grind          2 17 38144
wc             2 18 25344
zombie         2 19 22408
console        3 20 0
```

These are the files that mkfs includes in the initial file system; most are programs you can run. You just ran one of them: ls.

xv6 has no ps command, but, if you type Ctrl-p, the kernel will print information about each process. If you try it now, you'll see two lines: one for init, and one for sh.

To quit qemu type: Ctrl-a x.

## sleep ([easy](https://pdos.csail.mit.edu/6.828/2020/labs/guidance.html))

Implement the UNIX program sleep for xv6; your sleep should pause for a user-specified number of ticks. A tick is a notion of time defined by the xv6 kernel, namely the time between two interrupts from the timer chip. Your solution should be in the file user/sleep.c.

Some hints:

- [x] Before you start coding, read Chapter 1 of the [xv6 book](https://pdos.csail.mit.edu/6.828/2020/xv6/book-riscv-rev1.pdf).
- [x] Look at some of the other programs in  (e.g. `user/echo.c`, `user/grep.c`,  `user/rm.c` ) to see how you can obtain the command-line arguments passed to a program.

这里看的是command-line arguments的传递。显然是使用`argc` `argv`

see `rm.c`

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    fprintf(2, "Usage: rm files...\\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(unlink(argv[i]) < 0){
      fprintf(2, "rm: %s failed to delete\\n", argv[i]);
      break;
    }
  }

  exit(0);
}
```

- [x] If the user forgets to pass an argument, sleep should print an error message.

这个就可以是

```c
if(argc != 2) {
	fprintf(2, "...");
	exit(1);
}
```

注意: `2` 是标准错误输出，另外 `0`是标准输入, `1` 是标准输出

- [x] 是The command-line argument is passed as a string; you can convert it to an integer using `atoi` (see `user/ulib.c`).

```
atoi(char* s)
int
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    n = n*10 + *s++ - '0';
  return n;
}
```

- [x] Use the system call `sleep`.
- [x] See `kernel/sysproc.c` for the xv6 kernel code that implements the  `sleep` system call (look for `sys_sleep`),  `user/user.h` for the C definition of  callable from a user program, and `user/usys.S` for the assembler code that jumps from user code into the kernel for `sleep.`

```
sys_sleep
uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
user.h
int sleep(int);
usys.S
.global sleep
sleep:
 li a7, SYS_sleep
 ecall
 ret
```

容易发现一个问题, 在用户模式下调用 `sleep` 是有参数的，但是kernel下的调用没有参数 `uint64 sys_sleep(void)`，那么参数是如何传递的呢？

Passing arguments from user-level functions to kernel-level functions cannot be done in XV6. XV6 has its own built-in functions for passing arguments into a kernel function. For instance, to pass in an integer, the `argint()` function is called.

```c
argint(0, &pid);
```

... to get the first argument which is the Process ID, and:

```c
argint(1, &pty);
```

- [x] Make sure `main` calls  `exit()` in order to exit your program.  

最后加一条`exit(0)`

- [x] Add your  `sleep` program to `UPROGS` in Makefile; once you've done that,  `make qemu` will compile your program and you'll be able to run it from the xv6 shell.

```makefile
UPROGS=\\
	$U/_cat\\
	$U/_echo\\
	$U/_forktest\\
	$U/_grep\\
	$U/_init\\
	$U/_kill\\
	$U/_ln\\
	$U/_ls\\
	$U/_mkdir\\
	$U/_rm\\
	$U/_sh\\
	$U/_stressfs\\
	$U/_usertests\\
	$U/_grind\\
	$U/_wc\\
	$U/_zombie\\
	$U/_sleep\\
```

Run the program from the xv6 shell:

```bash
$ make qemu
...
init: starting sh
$ sleep 10
(nothing happens for a little while)
$
    
```

Your solution is correct if your program pauses when run as shown above. Run make grade to see if you indeed pass the sleep tests.

Note that make grade runs all tests, including the ones for the assignments below. If you want to run the grade tests for one assignment, type:

```bash
$ ./grade-lab-util sleep
```

This will run the grade tests that match "sleep". Or, you can type:

```bash
$ make GRADEFLAGS=sleep grade
```

which does the same.

### Final Code

```c
#include "kernel/types.h"
#include "user/user.h"
int main(int argc, char* argv[]) {
	if(argc != 2) {
		fprintf(2, "Usage: sleep [ticks]\\n");
		exit(1);
	}
	if(sleep(atoi(argv[1]) < 0)) {
		fprintf(2, "Failed to sleep %s ticks.\\n", argv[1]);
		exit(1);
	}
	exit(0);
}
```

## pingpong

Write a program that uses UNIX system calls to ''ping-pong'' a byte between two processes over a pair of pipes, one for each direction. The parent should send a byte to the child; the child should print "<pid>: received ping", where <pid> is its process ID, write the byte on the pipe to the parent, and exit; the parent should read the byte from the child, print "<pid>: received pong", and exit. Your solution should be in the file user/pingpong.c.

Some hints:

- Use `pipe` to create a pipe.

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cf3908b1-12b5-47d9-b0cc-ce4fe04fcad6/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/cf3908b1-12b5-47d9-b0cc-ce4fe04fcad6/Untitled.png)

[linux管道pipe详解_oguro的博客-CSDN博客](https://blog.csdn.net/oguro/article/details/53841949?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param)

- Use `fork` to create a child.
- Use  `read` to read from the pipe, and `write` to write to the pipe.
- Use `getpid` to find the process ID of the calling process.
- Add the program to `UPROGS` in Makefile.
- User programs on xv6 have a limited set of library functions available to them.

Run the program from the xv6 shell and it should produce the following output:

```bash
    $ make qemu
    ...
    init: starting sh
    $ pingpong
    4: received ping
    3: received pong
    $
```

Your solution is correct if your program exchanges a byte between two processes and produces output as shown above.

### Final Code

```c
#include "kernel/types.h"
#include "user/user.h"

int 
main(int argc, char* argv[]) {
    int parent_fd[2], child_fd[2];
    char buf[10];

    if(pipe(parent_fd) < 0 || pipe(child_fd) < 0) {
        fprintf(2, "Error: Can't create pipe!\\n");
        exit(1);
    }
    int pid = fork();

    if(pid == 0) {  //children process
        close(parent_fd[1]); //close write
        close(child_fd[0]);
        read(parent_fd[0], buf, 1);
        if(buf[0] == 'i') {
            printf("%d: received ping\\n", getpid());
        }
        write(child_fd[1], "o", 1);
        close(parent_fd[0]);
        close(child_fd[1]);
    } else {
        close(parent_fd[0]);
        close(child_fd[1]);
        write(parent_fd[1], "i", 1);
        read(child_fd[0], buf, 1);
        if(buf[0] == 'o') {
            printf("%d: received pong\\n", getpid());
        }
        close(parent_fd[1]);
        close(child_fd[0]);
    }
    exit(0);

}
```

### 衍生问题： 为什么linux中的管道不用要关闭

- parent process calls `pipe()` and gets 2 file descriptors: let's call it `rd` and `wr`.

- parent process calls `fork()`. Now both processes have a `rd` and a `wr`.

- Suppose the child process is supposed to be the reader.

  Then

  - the parent should close its reading end (for not wasting FDs and for proper detection of dying reader) and
  - the child must close its writing end (in order to be possible to detect the EOF condition).

# Primes

[【译文】Bell Labs and CSP Threads, Russ Cox.](https://qinstaunch.github.io/2020/07/04/【译文】Bell-Labs-and-CSP-Threads-Russ-Cox/#more)

https://s3-us-west-2.amazonaws.com/secure.notion-static.com/563f5b16-57e2-4e3b-9a17-f0280fb8438e/prime3.mov



sudo code

```c
void primes() {
  p = read from left         // 从左边接收到的第一个数一定是素数
  if (fork() == 0): 
    primes()                 // 子进程，进入递归
  else: 
    loop: 
      n = read from left     // 父进程，循环接收左边的输入  
      if (p % n != 0): 
        write n to right     // 不能被p整除则向右输出   
}
#include "kernel/types.h"
#include "user/user.h"

/* connect stdin (k=0) or stdout (k=1) to pipe pd */
void redirect(int k, int pd[]) {
  close(k);
  dup(pd[k]);
  close(pd[0]);
  close(pd[1]);
}

//挑不能整除的数
void cull(int p) {
  int n;

  while(read(0, &n, sizeof(n))) {
    if(n % p != 0)
      write(1, &n, sizeof(n));
  }
}

void right() {
  int pd[2], p;

  if(read(0, &p, sizeof(p))) {
    printf("prime %d\\n", p);
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
    fprintf(2, "Error: Cannot create pipe!\\n");
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
```

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c05d036a-adfe-48bf-a387-9e56b1596874/Untitled.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c05d036a-adfe-48bf-a387-9e56b1596874/Untitled.png)

## **SYNOPSIS [top](https://man7.org/linux/man-pages/man2/dup.2.html#top_of_page)**

```c
int dup(int oldfd);

int dup2(int oldfd, int newfd);
```

## **DESCRIPTION [top](https://man7.org/linux/man-pages/man2/dup.2.html#top_of_page)**

```
	dup()
	     The dup() system call creates a copy of the file descriptor oldfd,
       using the lowest-numbered unused file descriptor for the new
       descriptor.

       After a successful return, the old and new file descriptors may be
       used interchangeably.  They refer to the same open file description
       (see open(2)) and thus share file offset and file status flags; for
       example, if the file offset is modified by using lseek(2) on one of
       the file descriptors, the offset is also changed for the other.

       The two file descriptors do not share file descriptor flags (the
       close-on-exec flag).  The close-on-exec flag (FD_CLOEXEC; see
       fcntl(2)) for the duplicate descriptor is off.

   dup2()
       The dup2() system call performs the same task as dup(), but instead
       of using the lowest-numbered unused file descriptor, it uses the file
       descriptor number specified in newfd.  If the file descriptor newfd
       was previously open, it is silently closed before being reused.

       The steps of closing and reusing the file descriptor newfd are
       performed atomically.  This is important, because trying to implement
       equivalent functionality using close(2) and dup() would be subject to
       race conditions, whereby newfd might be reused between the two steps.
       Such reuse could happen because the main program is interrupted by a
       signal handler that allocates a file descriptor, or because a
       parallel thread allocates a file descriptor.

       Note the following points:

       *  If oldfd is not a valid file descriptor, then the call fails, and
          newfd is not closed.

       *  If oldfd is a valid file descriptor, and newfd has the same value
          as oldfd, then dup2() does nothing, and returns newfd.
```

所以

```c
close(0); dup(fd[0);
//等价于把fd[0]接到了标准输入
dup2(fd[0], 0);
//dup2系统调用将close操作和文件描述符拷贝操作集成在同一个函数里，而且它保证操作具有原子性。
```

## 传统艺能 BUGSSSSSSS

```bash
$ sudo apt-get install qemu-system-misc
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 perl-base : Breaks: debconf (< 1.5.61) but 1.5.58ubuntu1 is to be installed
             Breaks: debconf:i386 (< 1.5.61)
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

???

什么鬼问题

这样解决了

```bash
$ sudo apt-get install -y --allow-downgrades perl-base --allow-unauthenticated
```