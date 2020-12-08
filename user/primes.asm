
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <redirect>:
#include "kernel/types.h"
#include "user/user.h"

void redirect(int k, int p[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
    close(k);
  10:	00000097          	auipc	ra,0x0
  14:	466080e7          	jalr	1126(ra) # 476 <close>
    dup(p[k]);
  18:	048a                	slli	s1,s1,0x2
  1a:	94ca                	add	s1,s1,s2
  1c:	4088                	lw	a0,0(s1)
  1e:	00000097          	auipc	ra,0x0
  22:	4a8080e7          	jalr	1192(ra) # 4c6 <dup>
    close(p[0]);
  26:	00092503          	lw	a0,0(s2)
  2a:	00000097          	auipc	ra,0x0
  2e:	44c080e7          	jalr	1100(ra) # 476 <close>
    close(p[1]);
  32:	00492503          	lw	a0,4(s2)
  36:	00000097          	auipc	ra,0x0
  3a:	440080e7          	jalr	1088(ra) # 476 <close>
}
  3e:	60e2                	ld	ra,24(sp)
  40:	6442                	ld	s0,16(sp)
  42:	64a2                	ld	s1,8(sp)
  44:	6902                	ld	s2,0(sp)
  46:	6105                	addi	sp,sp,32
  48:	8082                	ret

000000000000004a <primes>:

void primes() {
  4a:	7179                	addi	sp,sp,-48
  4c:	f406                	sd	ra,40(sp)
  4e:	f022                	sd	s0,32(sp)
  50:	1800                	addi	s0,sp,48
    int p[2];
    int num;

    if(read(0, (void*)&num, sizeof(num)) <= 0)
  52:	4611                	li	a2,4
  54:	fe440593          	addi	a1,s0,-28
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	40c080e7          	jalr	1036(ra) # 466 <read>
  62:	0ca05163          	blez	a0,124 <primes+0xda>
        return;
    
    printf("prime %d\n", num);
  66:	fe442583          	lw	a1,-28(s0)
  6a:	00001517          	auipc	a0,0x1
  6e:	90650513          	addi	a0,a0,-1786 # 970 <malloc+0xec>
  72:	00000097          	auipc	ra,0x0
  76:	754080e7          	jalr	1876(ra) # 7c6 <printf>
    if(pipe(p) < 0) {
  7a:	fe840513          	addi	a0,s0,-24
  7e:	00000097          	auipc	ra,0x0
  82:	3e0080e7          	jalr	992(ra) # 45e <pipe>
  86:	02054463          	bltz	a0,ae <primes+0x64>
        fprintf(2, "Error: cannot create pipe");
        exit(1);
    }
    int pid = fork();
  8a:	00000097          	auipc	ra,0x0
  8e:	3bc080e7          	jalr	956(ra) # 446 <fork>
  92:	fea42023          	sw	a0,-32(s0)
    if(pid == 0) {
  96:	e915                	bnez	a0,ca <primes+0x80>
        redirect(0, p);
  98:	fe840593          	addi	a1,s0,-24
  9c:	00000097          	auipc	ra,0x0
  a0:	f64080e7          	jalr	-156(ra) # 0 <redirect>
        primes();
  a4:	00000097          	auipc	ra,0x0
  a8:	fa6080e7          	jalr	-90(ra) # 4a <primes>
  ac:	a8a5                	j	124 <primes+0xda>
        fprintf(2, "Error: cannot create pipe");
  ae:	00001597          	auipc	a1,0x1
  b2:	8d258593          	addi	a1,a1,-1838 # 980 <malloc+0xfc>
  b6:	4509                	li	a0,2
  b8:	00000097          	auipc	ra,0x0
  bc:	6e0080e7          	jalr	1760(ra) # 798 <fprintf>
        exit(1);
  c0:	4505                	li	a0,1
  c2:	00000097          	auipc	ra,0x0
  c6:	38c080e7          	jalr	908(ra) # 44e <exit>
    } else {
        redirect(1, p);
  ca:	fe840593          	addi	a1,s0,-24
  ce:	4505                	li	a0,1
  d0:	00000097          	auipc	ra,0x0
  d4:	f30080e7          	jalr	-208(ra) # 0 <redirect>
        int tmpnum = 0;
  d8:	fc042e23          	sw	zero,-36(s0)
        while(read(0, (void*)&tmpnum, sizeof(tmpnum))) {
  dc:	4611                	li	a2,4
  de:	fdc40593          	addi	a1,s0,-36
  e2:	4501                	li	a0,0
  e4:	00000097          	auipc	ra,0x0
  e8:	382080e7          	jalr	898(ra) # 466 <read>
  ec:	c10d                	beqz	a0,10e <primes+0xc4>
            if(tmpnum % num != 0) {
  ee:	fdc42783          	lw	a5,-36(s0)
  f2:	fe442703          	lw	a4,-28(s0)
  f6:	02e7e7bb          	remw	a5,a5,a4
  fa:	d3ed                	beqz	a5,dc <primes+0x92>
                write(1, (void*)&tmpnum, sizeof(tmpnum));
  fc:	4611                	li	a2,4
  fe:	fdc40593          	addi	a1,s0,-36
 102:	4505                	li	a0,1
 104:	00000097          	auipc	ra,0x0
 108:	36a080e7          	jalr	874(ra) # 46e <write>
 10c:	bfc1                	j	dc <primes+0x92>
            }
        }
        close(1);
 10e:	4505                	li	a0,1
 110:	00000097          	auipc	ra,0x0
 114:	366080e7          	jalr	870(ra) # 476 <close>
        wait(&pid);
 118:	fe040513          	addi	a0,s0,-32
 11c:	00000097          	auipc	ra,0x0
 120:	33a080e7          	jalr	826(ra) # 456 <wait>
    }

    
}
 124:	70a2                	ld	ra,40(sp)
 126:	7402                	ld	s0,32(sp)
 128:	6145                	addi	sp,sp,48
 12a:	8082                	ret

000000000000012c <main>:

int main(int argc, char* argv[]) {
 12c:	7179                	addi	sp,sp,-48
 12e:	f406                	sd	ra,40(sp)
 130:	f022                	sd	s0,32(sp)
 132:	ec26                	sd	s1,24(sp)
 134:	1800                	addi	s0,sp,48
    int p[2];
    if(pipe(p) < 0) {
 136:	fd840513          	addi	a0,s0,-40
 13a:	00000097          	auipc	ra,0x0
 13e:	324080e7          	jalr	804(ra) # 45e <pipe>
 142:	02054863          	bltz	a0,172 <main+0x46>
        fprintf(2, "Error: cannot create pipe");
        exit(1);
    }

    int pid = fork();
 146:	00000097          	auipc	ra,0x0
 14a:	300080e7          	jalr	768(ra) # 446 <fork>
 14e:	fca42a23          	sw	a0,-44(s0)
    if(pid == 0) {
 152:	ed15                	bnez	a0,18e <main+0x62>
        redirect(0, p);
 154:	fd840593          	addi	a1,s0,-40
 158:	00000097          	auipc	ra,0x0
 15c:	ea8080e7          	jalr	-344(ra) # 0 <redirect>
        primes();
 160:	00000097          	auipc	ra,0x0
 164:	eea080e7          	jalr	-278(ra) # 4a <primes>
            write(1, (void*)&i, sizeof(i));
        }
        close(1);
        wait(&pid);
    }
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	2e4080e7          	jalr	740(ra) # 44e <exit>
        fprintf(2, "Error: cannot create pipe");
 172:	00001597          	auipc	a1,0x1
 176:	80e58593          	addi	a1,a1,-2034 # 980 <malloc+0xfc>
 17a:	4509                	li	a0,2
 17c:	00000097          	auipc	ra,0x0
 180:	61c080e7          	jalr	1564(ra) # 798 <fprintf>
        exit(1);
 184:	4505                	li	a0,1
 186:	00000097          	auipc	ra,0x0
 18a:	2c8080e7          	jalr	712(ra) # 44e <exit>
        redirect(1, p);
 18e:	fd840593          	addi	a1,s0,-40
 192:	4505                	li	a0,1
 194:	00000097          	auipc	ra,0x0
 198:	e6c080e7          	jalr	-404(ra) # 0 <redirect>
        for(int i = 2; i <= 35; i++) {
 19c:	4789                	li	a5,2
 19e:	fcf42823          	sw	a5,-48(s0)
 1a2:	02300493          	li	s1,35
            write(1, (void*)&i, sizeof(i));
 1a6:	4611                	li	a2,4
 1a8:	fd040593          	addi	a1,s0,-48
 1ac:	4505                	li	a0,1
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2c0080e7          	jalr	704(ra) # 46e <write>
        for(int i = 2; i <= 35; i++) {
 1b6:	fd042783          	lw	a5,-48(s0)
 1ba:	2785                	addiw	a5,a5,1
 1bc:	0007871b          	sext.w	a4,a5
 1c0:	fcf42823          	sw	a5,-48(s0)
 1c4:	fee4d1e3          	bge	s1,a4,1a6 <main+0x7a>
        close(1);
 1c8:	4505                	li	a0,1
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2ac080e7          	jalr	684(ra) # 476 <close>
        wait(&pid);
 1d2:	fd440513          	addi	a0,s0,-44
 1d6:	00000097          	auipc	ra,0x0
 1da:	280080e7          	jalr	640(ra) # 456 <wait>
 1de:	b769                	j	168 <main+0x3c>

00000000000001e0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1e6:	87aa                	mv	a5,a0
 1e8:	0585                	addi	a1,a1,1
 1ea:	0785                	addi	a5,a5,1
 1ec:	fff5c703          	lbu	a4,-1(a1)
 1f0:	fee78fa3          	sb	a4,-1(a5)
 1f4:	fb75                	bnez	a4,1e8 <strcpy+0x8>
    ;
  return os;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret

00000000000001fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 202:	00054783          	lbu	a5,0(a0)
 206:	cb91                	beqz	a5,21a <strcmp+0x1e>
 208:	0005c703          	lbu	a4,0(a1)
 20c:	00f71763          	bne	a4,a5,21a <strcmp+0x1e>
    p++, q++;
 210:	0505                	addi	a0,a0,1
 212:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 214:	00054783          	lbu	a5,0(a0)
 218:	fbe5                	bnez	a5,208 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 21a:	0005c503          	lbu	a0,0(a1)
}
 21e:	40a7853b          	subw	a0,a5,a0
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strlen>:

uint
strlen(const char *s)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cf91                	beqz	a5,24e <strlen+0x26>
 234:	0505                	addi	a0,a0,1
 236:	87aa                	mv	a5,a0
 238:	4685                	li	a3,1
 23a:	9e89                	subw	a3,a3,a0
 23c:	00f6853b          	addw	a0,a3,a5
 240:	0785                	addi	a5,a5,1
 242:	fff7c703          	lbu	a4,-1(a5)
 246:	fb7d                	bnez	a4,23c <strlen+0x14>
    ;
  return n;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
  for(n = 0; s[n]; n++)
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strlen+0x20>

0000000000000252 <memset>:

void*
memset(void *dst, int c, uint n)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 258:	ca19                	beqz	a2,26e <memset+0x1c>
 25a:	87aa                	mv	a5,a0
 25c:	1602                	slli	a2,a2,0x20
 25e:	9201                	srli	a2,a2,0x20
 260:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 264:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 268:	0785                	addi	a5,a5,1
 26a:	fee79de3          	bne	a5,a4,264 <memset+0x12>
  }
  return dst;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strchr>:

char*
strchr(const char *s, char c)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  for(; *s; s++)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cb99                	beqz	a5,294 <strchr+0x20>
    if(*s == c)
 280:	00f58763          	beq	a1,a5,28e <strchr+0x1a>
  for(; *s; s++)
 284:	0505                	addi	a0,a0,1
 286:	00054783          	lbu	a5,0(a0)
 28a:	fbfd                	bnez	a5,280 <strchr+0xc>
      return (char*)s;
  return 0;
 28c:	4501                	li	a0,0
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
  return 0;
 294:	4501                	li	a0,0
 296:	bfe5                	j	28e <strchr+0x1a>

0000000000000298 <gets>:

char*
gets(char *buf, int max)
{
 298:	711d                	addi	sp,sp,-96
 29a:	ec86                	sd	ra,88(sp)
 29c:	e8a2                	sd	s0,80(sp)
 29e:	e4a6                	sd	s1,72(sp)
 2a0:	e0ca                	sd	s2,64(sp)
 2a2:	fc4e                	sd	s3,56(sp)
 2a4:	f852                	sd	s4,48(sp)
 2a6:	f456                	sd	s5,40(sp)
 2a8:	f05a                	sd	s6,32(sp)
 2aa:	ec5e                	sd	s7,24(sp)
 2ac:	1080                	addi	s0,sp,96
 2ae:	8baa                	mv	s7,a0
 2b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b2:	892a                	mv	s2,a0
 2b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2b6:	4aa9                	li	s5,10
 2b8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ba:	89a6                	mv	s3,s1
 2bc:	2485                	addiw	s1,s1,1
 2be:	0344d863          	bge	s1,s4,2ee <gets+0x56>
    cc = read(0, &c, 1);
 2c2:	4605                	li	a2,1
 2c4:	faf40593          	addi	a1,s0,-81
 2c8:	4501                	li	a0,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	19c080e7          	jalr	412(ra) # 466 <read>
    if(cc < 1)
 2d2:	00a05e63          	blez	a0,2ee <gets+0x56>
    buf[i++] = c;
 2d6:	faf44783          	lbu	a5,-81(s0)
 2da:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2de:	01578763          	beq	a5,s5,2ec <gets+0x54>
 2e2:	0905                	addi	s2,s2,1
 2e4:	fd679be3          	bne	a5,s6,2ba <gets+0x22>
  for(i=0; i+1 < max; ){
 2e8:	89a6                	mv	s3,s1
 2ea:	a011                	j	2ee <gets+0x56>
 2ec:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2ee:	99de                	add	s3,s3,s7
 2f0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2f4:	855e                	mv	a0,s7
 2f6:	60e6                	ld	ra,88(sp)
 2f8:	6446                	ld	s0,80(sp)
 2fa:	64a6                	ld	s1,72(sp)
 2fc:	6906                	ld	s2,64(sp)
 2fe:	79e2                	ld	s3,56(sp)
 300:	7a42                	ld	s4,48(sp)
 302:	7aa2                	ld	s5,40(sp)
 304:	7b02                	ld	s6,32(sp)
 306:	6be2                	ld	s7,24(sp)
 308:	6125                	addi	sp,sp,96
 30a:	8082                	ret

000000000000030c <stat>:

int
stat(const char *n, struct stat *st)
{
 30c:	1101                	addi	sp,sp,-32
 30e:	ec06                	sd	ra,24(sp)
 310:	e822                	sd	s0,16(sp)
 312:	e426                	sd	s1,8(sp)
 314:	e04a                	sd	s2,0(sp)
 316:	1000                	addi	s0,sp,32
 318:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 31a:	4581                	li	a1,0
 31c:	00000097          	auipc	ra,0x0
 320:	172080e7          	jalr	370(ra) # 48e <open>
  if(fd < 0)
 324:	02054563          	bltz	a0,34e <stat+0x42>
 328:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 32a:	85ca                	mv	a1,s2
 32c:	00000097          	auipc	ra,0x0
 330:	17a080e7          	jalr	378(ra) # 4a6 <fstat>
 334:	892a                	mv	s2,a0
  close(fd);
 336:	8526                	mv	a0,s1
 338:	00000097          	auipc	ra,0x0
 33c:	13e080e7          	jalr	318(ra) # 476 <close>
  return r;
}
 340:	854a                	mv	a0,s2
 342:	60e2                	ld	ra,24(sp)
 344:	6442                	ld	s0,16(sp)
 346:	64a2                	ld	s1,8(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	597d                	li	s2,-1
 350:	bfc5                	j	340 <stat+0x34>

0000000000000352 <atoi>:

int
atoi(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 358:	00054603          	lbu	a2,0(a0)
 35c:	fd06079b          	addiw	a5,a2,-48
 360:	0ff7f793          	andi	a5,a5,255
 364:	4725                	li	a4,9
 366:	02f76963          	bltu	a4,a5,398 <atoi+0x46>
 36a:	86aa                	mv	a3,a0
  n = 0;
 36c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 36e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 370:	0685                	addi	a3,a3,1
 372:	0025179b          	slliw	a5,a0,0x2
 376:	9fa9                	addw	a5,a5,a0
 378:	0017979b          	slliw	a5,a5,0x1
 37c:	9fb1                	addw	a5,a5,a2
 37e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 382:	0006c603          	lbu	a2,0(a3)
 386:	fd06071b          	addiw	a4,a2,-48
 38a:	0ff77713          	andi	a4,a4,255
 38e:	fee5f1e3          	bgeu	a1,a4,370 <atoi+0x1e>
  return n;
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  n = 0;
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <atoi+0x40>

000000000000039c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a2:	02b57463          	bgeu	a0,a1,3ca <memmove+0x2e>
    while(n-- > 0)
 3a6:	00c05f63          	blez	a2,3c4 <memmove+0x28>
 3aa:	1602                	slli	a2,a2,0x20
 3ac:	9201                	srli	a2,a2,0x20
 3ae:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b4:	0585                	addi	a1,a1,1
 3b6:	0705                	addi	a4,a4,1
 3b8:	fff5c683          	lbu	a3,-1(a1)
 3bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3c0:	fee79ae3          	bne	a5,a4,3b4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
    dst += n;
 3ca:	00c50733          	add	a4,a0,a2
    src += n;
 3ce:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3d0:	fec05ae3          	blez	a2,3c4 <memmove+0x28>
 3d4:	fff6079b          	addiw	a5,a2,-1
 3d8:	1782                	slli	a5,a5,0x20
 3da:	9381                	srli	a5,a5,0x20
 3dc:	fff7c793          	not	a5,a5
 3e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e2:	15fd                	addi	a1,a1,-1
 3e4:	177d                	addi	a4,a4,-1
 3e6:	0005c683          	lbu	a3,0(a1)
 3ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ee:	fee79ae3          	bne	a5,a4,3e2 <memmove+0x46>
 3f2:	bfc9                	j	3c4 <memmove+0x28>

00000000000003f4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f4:	1141                	addi	sp,sp,-16
 3f6:	e422                	sd	s0,8(sp)
 3f8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3fa:	ca05                	beqz	a2,42a <memcmp+0x36>
 3fc:	fff6069b          	addiw	a3,a2,-1
 400:	1682                	slli	a3,a3,0x20
 402:	9281                	srli	a3,a3,0x20
 404:	0685                	addi	a3,a3,1
 406:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 408:	00054783          	lbu	a5,0(a0)
 40c:	0005c703          	lbu	a4,0(a1)
 410:	00e79863          	bne	a5,a4,420 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 414:	0505                	addi	a0,a0,1
    p2++;
 416:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 418:	fed518e3          	bne	a0,a3,408 <memcmp+0x14>
  }
  return 0;
 41c:	4501                	li	a0,0
 41e:	a019                	j	424 <memcmp+0x30>
      return *p1 - *p2;
 420:	40e7853b          	subw	a0,a5,a4
}
 424:	6422                	ld	s0,8(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret
  return 0;
 42a:	4501                	li	a0,0
 42c:	bfe5                	j	424 <memcmp+0x30>

000000000000042e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e406                	sd	ra,8(sp)
 432:	e022                	sd	s0,0(sp)
 434:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 436:	00000097          	auipc	ra,0x0
 43a:	f66080e7          	jalr	-154(ra) # 39c <memmove>
}
 43e:	60a2                	ld	ra,8(sp)
 440:	6402                	ld	s0,0(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret

0000000000000446 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 446:	4885                	li	a7,1
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <exit>:
.global exit
exit:
 li a7, SYS_exit
 44e:	4889                	li	a7,2
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <wait>:
.global wait
wait:
 li a7, SYS_wait
 456:	488d                	li	a7,3
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 45e:	4891                	li	a7,4
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <read>:
.global read
read:
 li a7, SYS_read
 466:	4895                	li	a7,5
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <write>:
.global write
write:
 li a7, SYS_write
 46e:	48c1                	li	a7,16
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <close>:
.global close
close:
 li a7, SYS_close
 476:	48d5                	li	a7,21
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <kill>:
.global kill
kill:
 li a7, SYS_kill
 47e:	4899                	li	a7,6
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <exec>:
.global exec
exec:
 li a7, SYS_exec
 486:	489d                	li	a7,7
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <open>:
.global open
open:
 li a7, SYS_open
 48e:	48bd                	li	a7,15
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 496:	48c5                	li	a7,17
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 49e:	48c9                	li	a7,18
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a6:	48a1                	li	a7,8
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <link>:
.global link
link:
 li a7, SYS_link
 4ae:	48cd                	li	a7,19
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b6:	48d1                	li	a7,20
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4be:	48a5                	li	a7,9
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c6:	48a9                	li	a7,10
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ce:	48ad                	li	a7,11
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d6:	48b1                	li	a7,12
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4de:	48b5                	li	a7,13
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e6:	48b9                	li	a7,14
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ee:	1101                	addi	sp,sp,-32
 4f0:	ec06                	sd	ra,24(sp)
 4f2:	e822                	sd	s0,16(sp)
 4f4:	1000                	addi	s0,sp,32
 4f6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4fa:	4605                	li	a2,1
 4fc:	fef40593          	addi	a1,s0,-17
 500:	00000097          	auipc	ra,0x0
 504:	f6e080e7          	jalr	-146(ra) # 46e <write>
}
 508:	60e2                	ld	ra,24(sp)
 50a:	6442                	ld	s0,16(sp)
 50c:	6105                	addi	sp,sp,32
 50e:	8082                	ret

0000000000000510 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 510:	7139                	addi	sp,sp,-64
 512:	fc06                	sd	ra,56(sp)
 514:	f822                	sd	s0,48(sp)
 516:	f426                	sd	s1,40(sp)
 518:	f04a                	sd	s2,32(sp)
 51a:	ec4e                	sd	s3,24(sp)
 51c:	0080                	addi	s0,sp,64
 51e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 520:	c299                	beqz	a3,526 <printint+0x16>
 522:	0805c863          	bltz	a1,5b2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 526:	2581                	sext.w	a1,a1
  neg = 0;
 528:	4881                	li	a7,0
 52a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 52e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 530:	2601                	sext.w	a2,a2
 532:	00000517          	auipc	a0,0x0
 536:	47650513          	addi	a0,a0,1142 # 9a8 <digits>
 53a:	883a                	mv	a6,a4
 53c:	2705                	addiw	a4,a4,1
 53e:	02c5f7bb          	remuw	a5,a1,a2
 542:	1782                	slli	a5,a5,0x20
 544:	9381                	srli	a5,a5,0x20
 546:	97aa                	add	a5,a5,a0
 548:	0007c783          	lbu	a5,0(a5)
 54c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 550:	0005879b          	sext.w	a5,a1
 554:	02c5d5bb          	divuw	a1,a1,a2
 558:	0685                	addi	a3,a3,1
 55a:	fec7f0e3          	bgeu	a5,a2,53a <printint+0x2a>
  if(neg)
 55e:	00088b63          	beqz	a7,574 <printint+0x64>
    buf[i++] = '-';
 562:	fd040793          	addi	a5,s0,-48
 566:	973e                	add	a4,a4,a5
 568:	02d00793          	li	a5,45
 56c:	fef70823          	sb	a5,-16(a4)
 570:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 574:	02e05863          	blez	a4,5a4 <printint+0x94>
 578:	fc040793          	addi	a5,s0,-64
 57c:	00e78933          	add	s2,a5,a4
 580:	fff78993          	addi	s3,a5,-1
 584:	99ba                	add	s3,s3,a4
 586:	377d                	addiw	a4,a4,-1
 588:	1702                	slli	a4,a4,0x20
 58a:	9301                	srli	a4,a4,0x20
 58c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 590:	fff94583          	lbu	a1,-1(s2)
 594:	8526                	mv	a0,s1
 596:	00000097          	auipc	ra,0x0
 59a:	f58080e7          	jalr	-168(ra) # 4ee <putc>
  while(--i >= 0)
 59e:	197d                	addi	s2,s2,-1
 5a0:	ff3918e3          	bne	s2,s3,590 <printint+0x80>
}
 5a4:	70e2                	ld	ra,56(sp)
 5a6:	7442                	ld	s0,48(sp)
 5a8:	74a2                	ld	s1,40(sp)
 5aa:	7902                	ld	s2,32(sp)
 5ac:	69e2                	ld	s3,24(sp)
 5ae:	6121                	addi	sp,sp,64
 5b0:	8082                	ret
    x = -xx;
 5b2:	40b005bb          	negw	a1,a1
    neg = 1;
 5b6:	4885                	li	a7,1
    x = -xx;
 5b8:	bf8d                	j	52a <printint+0x1a>

00000000000005ba <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ba:	7119                	addi	sp,sp,-128
 5bc:	fc86                	sd	ra,120(sp)
 5be:	f8a2                	sd	s0,112(sp)
 5c0:	f4a6                	sd	s1,104(sp)
 5c2:	f0ca                	sd	s2,96(sp)
 5c4:	ecce                	sd	s3,88(sp)
 5c6:	e8d2                	sd	s4,80(sp)
 5c8:	e4d6                	sd	s5,72(sp)
 5ca:	e0da                	sd	s6,64(sp)
 5cc:	fc5e                	sd	s7,56(sp)
 5ce:	f862                	sd	s8,48(sp)
 5d0:	f466                	sd	s9,40(sp)
 5d2:	f06a                	sd	s10,32(sp)
 5d4:	ec6e                	sd	s11,24(sp)
 5d6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d8:	0005c903          	lbu	s2,0(a1)
 5dc:	18090f63          	beqz	s2,77a <vprintf+0x1c0>
 5e0:	8aaa                	mv	s5,a0
 5e2:	8b32                	mv	s6,a2
 5e4:	00158493          	addi	s1,a1,1
  state = 0;
 5e8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5ea:	02500a13          	li	s4,37
      if(c == 'd'){
 5ee:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5f2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5f6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5fa:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5fe:	00000b97          	auipc	s7,0x0
 602:	3aab8b93          	addi	s7,s7,938 # 9a8 <digits>
 606:	a839                	j	624 <vprintf+0x6a>
        putc(fd, c);
 608:	85ca                	mv	a1,s2
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	ee2080e7          	jalr	-286(ra) # 4ee <putc>
 614:	a019                	j	61a <vprintf+0x60>
    } else if(state == '%'){
 616:	01498f63          	beq	s3,s4,634 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 61a:	0485                	addi	s1,s1,1
 61c:	fff4c903          	lbu	s2,-1(s1)
 620:	14090d63          	beqz	s2,77a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 624:	0009079b          	sext.w	a5,s2
    if(state == 0){
 628:	fe0997e3          	bnez	s3,616 <vprintf+0x5c>
      if(c == '%'){
 62c:	fd479ee3          	bne	a5,s4,608 <vprintf+0x4e>
        state = '%';
 630:	89be                	mv	s3,a5
 632:	b7e5                	j	61a <vprintf+0x60>
      if(c == 'd'){
 634:	05878063          	beq	a5,s8,674 <vprintf+0xba>
      } else if(c == 'l') {
 638:	05978c63          	beq	a5,s9,690 <vprintf+0xd6>
      } else if(c == 'x') {
 63c:	07a78863          	beq	a5,s10,6ac <vprintf+0xf2>
      } else if(c == 'p') {
 640:	09b78463          	beq	a5,s11,6c8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 644:	07300713          	li	a4,115
 648:	0ce78663          	beq	a5,a4,714 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 64c:	06300713          	li	a4,99
 650:	0ee78e63          	beq	a5,a4,74c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 654:	11478863          	beq	a5,s4,764 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 658:	85d2                	mv	a1,s4
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e92080e7          	jalr	-366(ra) # 4ee <putc>
        putc(fd, c);
 664:	85ca                	mv	a1,s2
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e86080e7          	jalr	-378(ra) # 4ee <putc>
      }
      state = 0;
 670:	4981                	li	s3,0
 672:	b765                	j	61a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 674:	008b0913          	addi	s2,s6,8
 678:	4685                	li	a3,1
 67a:	4629                	li	a2,10
 67c:	000b2583          	lw	a1,0(s6)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e8e080e7          	jalr	-370(ra) # 510 <printint>
 68a:	8b4a                	mv	s6,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b771                	j	61a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 690:	008b0913          	addi	s2,s6,8
 694:	4681                	li	a3,0
 696:	4629                	li	a2,10
 698:	000b2583          	lw	a1,0(s6)
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	e72080e7          	jalr	-398(ra) # 510 <printint>
 6a6:	8b4a                	mv	s6,s2
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bf85                	j	61a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ac:	008b0913          	addi	s2,s6,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000b2583          	lw	a1,0(s6)
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e56080e7          	jalr	-426(ra) # 510 <printint>
 6c2:	8b4a                	mv	s6,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bf91                	j	61a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6c8:	008b0793          	addi	a5,s6,8
 6cc:	f8f43423          	sd	a5,-120(s0)
 6d0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6d4:	03000593          	li	a1,48
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	e14080e7          	jalr	-492(ra) # 4ee <putc>
  putc(fd, 'x');
 6e2:	85ea                	mv	a1,s10
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e08080e7          	jalr	-504(ra) # 4ee <putc>
 6ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f0:	03c9d793          	srli	a5,s3,0x3c
 6f4:	97de                	add	a5,a5,s7
 6f6:	0007c583          	lbu	a1,0(a5)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	df2080e7          	jalr	-526(ra) # 4ee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 704:	0992                	slli	s3,s3,0x4
 706:	397d                	addiw	s2,s2,-1
 708:	fe0914e3          	bnez	s2,6f0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 70c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 710:	4981                	li	s3,0
 712:	b721                	j	61a <vprintf+0x60>
        s = va_arg(ap, char*);
 714:	008b0993          	addi	s3,s6,8
 718:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 71c:	02090163          	beqz	s2,73e <vprintf+0x184>
        while(*s != 0){
 720:	00094583          	lbu	a1,0(s2)
 724:	c9a1                	beqz	a1,774 <vprintf+0x1ba>
          putc(fd, *s);
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	dc6080e7          	jalr	-570(ra) # 4ee <putc>
          s++;
 730:	0905                	addi	s2,s2,1
        while(*s != 0){
 732:	00094583          	lbu	a1,0(s2)
 736:	f9e5                	bnez	a1,726 <vprintf+0x16c>
        s = va_arg(ap, char*);
 738:	8b4e                	mv	s6,s3
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bdf9                	j	61a <vprintf+0x60>
          s = "(null)";
 73e:	00000917          	auipc	s2,0x0
 742:	26290913          	addi	s2,s2,610 # 9a0 <malloc+0x11c>
        while(*s != 0){
 746:	02800593          	li	a1,40
 74a:	bff1                	j	726 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 74c:	008b0913          	addi	s2,s6,8
 750:	000b4583          	lbu	a1,0(s6)
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	d98080e7          	jalr	-616(ra) # 4ee <putc>
 75e:	8b4a                	mv	s6,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bd65                	j	61a <vprintf+0x60>
        putc(fd, c);
 764:	85d2                	mv	a1,s4
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	d86080e7          	jalr	-634(ra) # 4ee <putc>
      state = 0;
 770:	4981                	li	s3,0
 772:	b565                	j	61a <vprintf+0x60>
        s = va_arg(ap, char*);
 774:	8b4e                	mv	s6,s3
      state = 0;
 776:	4981                	li	s3,0
 778:	b54d                	j	61a <vprintf+0x60>
    }
  }
}
 77a:	70e6                	ld	ra,120(sp)
 77c:	7446                	ld	s0,112(sp)
 77e:	74a6                	ld	s1,104(sp)
 780:	7906                	ld	s2,96(sp)
 782:	69e6                	ld	s3,88(sp)
 784:	6a46                	ld	s4,80(sp)
 786:	6aa6                	ld	s5,72(sp)
 788:	6b06                	ld	s6,64(sp)
 78a:	7be2                	ld	s7,56(sp)
 78c:	7c42                	ld	s8,48(sp)
 78e:	7ca2                	ld	s9,40(sp)
 790:	7d02                	ld	s10,32(sp)
 792:	6de2                	ld	s11,24(sp)
 794:	6109                	addi	sp,sp,128
 796:	8082                	ret

0000000000000798 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 798:	715d                	addi	sp,sp,-80
 79a:	ec06                	sd	ra,24(sp)
 79c:	e822                	sd	s0,16(sp)
 79e:	1000                	addi	s0,sp,32
 7a0:	e010                	sd	a2,0(s0)
 7a2:	e414                	sd	a3,8(s0)
 7a4:	e818                	sd	a4,16(s0)
 7a6:	ec1c                	sd	a5,24(s0)
 7a8:	03043023          	sd	a6,32(s0)
 7ac:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7b0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b4:	8622                	mv	a2,s0
 7b6:	00000097          	auipc	ra,0x0
 7ba:	e04080e7          	jalr	-508(ra) # 5ba <vprintf>
}
 7be:	60e2                	ld	ra,24(sp)
 7c0:	6442                	ld	s0,16(sp)
 7c2:	6161                	addi	sp,sp,80
 7c4:	8082                	ret

00000000000007c6 <printf>:

void
printf(const char *fmt, ...)
{
 7c6:	711d                	addi	sp,sp,-96
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	e40c                	sd	a1,8(s0)
 7d0:	e810                	sd	a2,16(s0)
 7d2:	ec14                	sd	a3,24(s0)
 7d4:	f018                	sd	a4,32(s0)
 7d6:	f41c                	sd	a5,40(s0)
 7d8:	03043823          	sd	a6,48(s0)
 7dc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e0:	00840613          	addi	a2,s0,8
 7e4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e8:	85aa                	mv	a1,a0
 7ea:	4505                	li	a0,1
 7ec:	00000097          	auipc	ra,0x0
 7f0:	dce080e7          	jalr	-562(ra) # 5ba <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6125                	addi	sp,sp,96
 7fa:	8082                	ret

00000000000007fc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fc:	1141                	addi	sp,sp,-16
 7fe:	e422                	sd	s0,8(sp)
 800:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 802:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	00000797          	auipc	a5,0x0
 80a:	1ba7b783          	ld	a5,442(a5) # 9c0 <freep>
 80e:	a805                	j	83e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 810:	4618                	lw	a4,8(a2)
 812:	9db9                	addw	a1,a1,a4
 814:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 818:	6398                	ld	a4,0(a5)
 81a:	6318                	ld	a4,0(a4)
 81c:	fee53823          	sd	a4,-16(a0)
 820:	a091                	j	864 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 822:	ff852703          	lw	a4,-8(a0)
 826:	9e39                	addw	a2,a2,a4
 828:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 82a:	ff053703          	ld	a4,-16(a0)
 82e:	e398                	sd	a4,0(a5)
 830:	a099                	j	876 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 832:	6398                	ld	a4,0(a5)
 834:	00e7e463          	bltu	a5,a4,83c <free+0x40>
 838:	00e6ea63          	bltu	a3,a4,84c <free+0x50>
{
 83c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	fed7fae3          	bgeu	a5,a3,832 <free+0x36>
 842:	6398                	ld	a4,0(a5)
 844:	00e6e463          	bltu	a3,a4,84c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 848:	fee7eae3          	bltu	a5,a4,83c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 84c:	ff852583          	lw	a1,-8(a0)
 850:	6390                	ld	a2,0(a5)
 852:	02059813          	slli	a6,a1,0x20
 856:	01c85713          	srli	a4,a6,0x1c
 85a:	9736                	add	a4,a4,a3
 85c:	fae60ae3          	beq	a2,a4,810 <free+0x14>
    bp->s.ptr = p->s.ptr;
 860:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 864:	4790                	lw	a2,8(a5)
 866:	02061593          	slli	a1,a2,0x20
 86a:	01c5d713          	srli	a4,a1,0x1c
 86e:	973e                	add	a4,a4,a5
 870:	fae689e3          	beq	a3,a4,822 <free+0x26>
  } else
    p->s.ptr = bp;
 874:	e394                	sd	a3,0(a5)
  freep = p;
 876:	00000717          	auipc	a4,0x0
 87a:	14f73523          	sd	a5,330(a4) # 9c0 <freep>
}
 87e:	6422                	ld	s0,8(sp)
 880:	0141                	addi	sp,sp,16
 882:	8082                	ret

0000000000000884 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 884:	7139                	addi	sp,sp,-64
 886:	fc06                	sd	ra,56(sp)
 888:	f822                	sd	s0,48(sp)
 88a:	f426                	sd	s1,40(sp)
 88c:	f04a                	sd	s2,32(sp)
 88e:	ec4e                	sd	s3,24(sp)
 890:	e852                	sd	s4,16(sp)
 892:	e456                	sd	s5,8(sp)
 894:	e05a                	sd	s6,0(sp)
 896:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 898:	02051493          	slli	s1,a0,0x20
 89c:	9081                	srli	s1,s1,0x20
 89e:	04bd                	addi	s1,s1,15
 8a0:	8091                	srli	s1,s1,0x4
 8a2:	0014899b          	addiw	s3,s1,1
 8a6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a8:	00000517          	auipc	a0,0x0
 8ac:	11853503          	ld	a0,280(a0) # 9c0 <freep>
 8b0:	c515                	beqz	a0,8dc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b4:	4798                	lw	a4,8(a5)
 8b6:	02977f63          	bgeu	a4,s1,8f4 <malloc+0x70>
 8ba:	8a4e                	mv	s4,s3
 8bc:	0009871b          	sext.w	a4,s3
 8c0:	6685                	lui	a3,0x1
 8c2:	00d77363          	bgeu	a4,a3,8c8 <malloc+0x44>
 8c6:	6a05                	lui	s4,0x1
 8c8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8cc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8d0:	00000917          	auipc	s2,0x0
 8d4:	0f090913          	addi	s2,s2,240 # 9c0 <freep>
  if(p == (char*)-1)
 8d8:	5afd                	li	s5,-1
 8da:	a895                	j	94e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8dc:	00000797          	auipc	a5,0x0
 8e0:	0ec78793          	addi	a5,a5,236 # 9c8 <base>
 8e4:	00000717          	auipc	a4,0x0
 8e8:	0cf73e23          	sd	a5,220(a4) # 9c0 <freep>
 8ec:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ee:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f2:	b7e1                	j	8ba <malloc+0x36>
      if(p->s.size == nunits)
 8f4:	02e48c63          	beq	s1,a4,92c <malloc+0xa8>
        p->s.size -= nunits;
 8f8:	4137073b          	subw	a4,a4,s3
 8fc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fe:	02071693          	slli	a3,a4,0x20
 902:	01c6d713          	srli	a4,a3,0x1c
 906:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 908:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 90c:	00000717          	auipc	a4,0x0
 910:	0aa73a23          	sd	a0,180(a4) # 9c0 <freep>
      return (void*)(p + 1);
 914:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 918:	70e2                	ld	ra,56(sp)
 91a:	7442                	ld	s0,48(sp)
 91c:	74a2                	ld	s1,40(sp)
 91e:	7902                	ld	s2,32(sp)
 920:	69e2                	ld	s3,24(sp)
 922:	6a42                	ld	s4,16(sp)
 924:	6aa2                	ld	s5,8(sp)
 926:	6b02                	ld	s6,0(sp)
 928:	6121                	addi	sp,sp,64
 92a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 92c:	6398                	ld	a4,0(a5)
 92e:	e118                	sd	a4,0(a0)
 930:	bff1                	j	90c <malloc+0x88>
  hp->s.size = nu;
 932:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 936:	0541                	addi	a0,a0,16
 938:	00000097          	auipc	ra,0x0
 93c:	ec4080e7          	jalr	-316(ra) # 7fc <free>
  return freep;
 940:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 944:	d971                	beqz	a0,918 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	fa9775e3          	bgeu	a4,s1,8f4 <malloc+0x70>
    if(p == freep)
 94e:	00093703          	ld	a4,0(s2)
 952:	853e                	mv	a0,a5
 954:	fef719e3          	bne	a4,a5,946 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 958:	8552                	mv	a0,s4
 95a:	00000097          	auipc	ra,0x0
 95e:	b7c080e7          	jalr	-1156(ra) # 4d6 <sbrk>
  if(p == (char*)-1)
 962:	fd5518e3          	bne	a0,s5,932 <malloc+0xae>
        return 0;
 966:	4501                	li	a0,0
 968:	bf45                	j	918 <malloc+0x94>
