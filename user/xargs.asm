
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/param.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
   0:	aa010113          	addi	sp,sp,-1376
   4:	54113c23          	sd	ra,1368(sp)
   8:	54813823          	sd	s0,1360(sp)
   c:	54913423          	sd	s1,1352(sp)
  10:	55213023          	sd	s2,1344(sp)
  14:	53313c23          	sd	s3,1336(sp)
  18:	53413823          	sd	s4,1328(sp)
  1c:	53513423          	sd	s5,1320(sp)
  20:	53613023          	sd	s6,1312(sp)
  24:	51713c23          	sd	s7,1304(sp)
  28:	51813823          	sd	s8,1296(sp)
  2c:	56010413          	addi	s0,sp,1376
    char *nargs[MAXARG];
    int argCount = 0;
    for(int i = 1; i < argc; i++) {
  30:	4785                	li	a5,1
  32:	04a7d463          	bge	a5,a0,7a <main+0x7a>
  36:	00858713          	addi	a4,a1,8
  3a:	eb040793          	addi	a5,s0,-336
  3e:	00050b9b          	sext.w	s7,a0
  42:	ffe5069b          	addiw	a3,a0,-2
  46:	02069613          	slli	a2,a3,0x20
  4a:	01d65693          	srli	a3,a2,0x1d
  4e:	eb840613          	addi	a2,s0,-328
  52:	96b2                	add	a3,a3,a2
        nargs[argCount++] = argv[i];
  54:	6310                	ld	a2,0(a4)
  56:	e390                	sd	a2,0(a5)
    for(int i = 1; i < argc; i++) {
  58:	0721                	addi	a4,a4,8
  5a:	07a1                	addi	a5,a5,8
  5c:	fed79ce3          	bne	a5,a3,54 <main+0x54>
        nargs[argCount++] = argv[i];
  60:	3bfd                	addiw	s7,s7,-1
    }

    char tmpchar = 0;
  62:	ea0407a3          	sb	zero,-337(s0)
            if(status == 0) exit(0);
            if(tmpchar != ' ' && tmpchar != '\n') {
                buffer[pos++] = tmpchar;
            } else if(tmpchar == ' ') {
                buffer[pos++] = 0;
                nargs[argCount++] = &buffer[argStartPos];
  66:	4a05                	li	s4,1
        int argStartPos = 0;
  68:	4981                	li	s3,0
            if(tmpchar != ' ' && tmpchar != '\n') {
  6a:	02000a93          	li	s5,32
  6e:	aa840493          	addi	s1,s0,-1368
                nargs[argCount++] = &buffer[argStartPos];
  72:	8952                	mv	s2,s4
        int argStartPos = 0;
  74:	8b4e                	mv	s6,s3
            if(tmpchar != ' ' && tmpchar != '\n') {
  76:	4c29                	li	s8,10
  78:	a03d                	j	a6 <main+0xa6>
    int argCount = 0;
  7a:	4b81                	li	s7,0
  7c:	b7dd                	j	62 <main+0x62>
            if(status == 0) exit(0);
  7e:	00000097          	auipc	ra,0x0
  82:	2fa080e7          	jalr	762(ra) # 378 <exit>
                buffer[pos++] = 0;
  86:	00048023          	sb	zero,0(s1)
                nargs[argCount++] = &buffer[argStartPos];
  8a:	003b9793          	slli	a5,s7,0x3
  8e:	fb040713          	addi	a4,s0,-80
  92:	97ba                	add	a5,a5,a4
  94:	aa840713          	addi	a4,s0,-1368
  98:	9b3a                	add	s6,s6,a4
  9a:	f167b023          	sd	s6,-256(a5)
                argStartPos = pos;
  9e:	8b4a                	mv	s6,s2
                nargs[argCount++] = &buffer[argStartPos];
  a0:	2b85                	addiw	s7,s7,1
  a2:	2905                	addiw	s2,s2,1
  a4:	0485                	addi	s1,s1,1
            status = read(0, &tmpchar, 1);
  a6:	8652                	mv	a2,s4
  a8:	eaf40593          	addi	a1,s0,-337
  ac:	854e                	mv	a0,s3
  ae:	00000097          	auipc	ra,0x0
  b2:	2e2080e7          	jalr	738(ra) # 390 <read>
            if(status == 0) exit(0);
  b6:	d561                	beqz	a0,7e <main+0x7e>
            if(tmpchar != ' ' && tmpchar != '\n') {
  b8:	eaf44783          	lbu	a5,-337(s0)
  bc:	fd5785e3          	beq	a5,s5,86 <main+0x86>
  c0:	01878563          	beq	a5,s8,ca <main+0xca>
                buffer[pos++] = tmpchar;
  c4:	00f48023          	sb	a5,0(s1)
  c8:	bfe9                	j	a2 <main+0xa2>
            } else if(tmpchar == '\n') {
                nargs[argCount++] = &buffer[argStartPos];
  ca:	001b849b          	addiw	s1,s7,1
  ce:	0b8e                	slli	s7,s7,0x3
  d0:	fb040793          	addi	a5,s0,-80
  d4:	9bbe                	add	s7,s7,a5
  d6:	aa840793          	addi	a5,s0,-1368
  da:	9b3e                	add	s6,s6,a5
  dc:	f16bb023          	sd	s6,-256(s7)
                argStartPos = pos;
                break;
            }
        }

        if(fork() == 0) {
  e0:	00000097          	auipc	ra,0x0
  e4:	290080e7          	jalr	656(ra) # 370 <fork>
  e8:	e919                	bnez	a0,fe <main+0xfe>
            exec(nargs[0], nargs);
  ea:	eb040593          	addi	a1,s0,-336
  ee:	eb043503          	ld	a0,-336(s0)
  f2:	00000097          	auipc	ra,0x0
  f6:	2be080e7          	jalr	702(ra) # 3b0 <exec>
        int argStartPos = 0;
  fa:	8ba6                	mv	s7,s1
  fc:	bf8d                	j	6e <main+0x6e>
        } else {
            wait(0);
  fe:	854e                	mv	a0,s3
 100:	00000097          	auipc	ra,0x0
 104:	280080e7          	jalr	640(ra) # 380 <wait>
 108:	bfcd                	j	fa <main+0xfa>

000000000000010a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 110:	87aa                	mv	a5,a0
 112:	0585                	addi	a1,a1,1
 114:	0785                	addi	a5,a5,1
 116:	fff5c703          	lbu	a4,-1(a1)
 11a:	fee78fa3          	sb	a4,-1(a5)
 11e:	fb75                	bnez	a4,112 <strcpy+0x8>
    ;
  return os;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cb91                	beqz	a5,144 <strcmp+0x1e>
 132:	0005c703          	lbu	a4,0(a1)
 136:	00f71763          	bne	a4,a5,144 <strcmp+0x1e>
    p++, q++;
 13a:	0505                	addi	a0,a0,1
 13c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 13e:	00054783          	lbu	a5,0(a0)
 142:	fbe5                	bnez	a5,132 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 144:	0005c503          	lbu	a0,0(a1)
}
 148:	40a7853b          	subw	a0,a5,a0
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	addi	sp,sp,16
 150:	8082                	ret

0000000000000152 <strlen>:

uint
strlen(const char *s)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 158:	00054783          	lbu	a5,0(a0)
 15c:	cf91                	beqz	a5,178 <strlen+0x26>
 15e:	0505                	addi	a0,a0,1
 160:	87aa                	mv	a5,a0
 162:	4685                	li	a3,1
 164:	9e89                	subw	a3,a3,a0
 166:	00f6853b          	addw	a0,a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	fb7d                	bnez	a4,166 <strlen+0x14>
    ;
  return n;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  for(n = 0; s[n]; n++)
 178:	4501                	li	a0,0
 17a:	bfe5                	j	172 <strlen+0x20>

000000000000017c <memset>:

void*
memset(void *dst, int c, uint n)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 182:	ca19                	beqz	a2,198 <memset+0x1c>
 184:	87aa                	mv	a5,a0
 186:	1602                	slli	a2,a2,0x20
 188:	9201                	srli	a2,a2,0x20
 18a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 18e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 192:	0785                	addi	a5,a5,1
 194:	fee79de3          	bne	a5,a4,18e <memset+0x12>
  }
  return dst;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strchr>:

char*
strchr(const char *s, char c)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb99                	beqz	a5,1be <strchr+0x20>
    if(*s == c)
 1aa:	00f58763          	beq	a1,a5,1b8 <strchr+0x1a>
  for(; *s; s++)
 1ae:	0505                	addi	a0,a0,1
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	fbfd                	bnez	a5,1aa <strchr+0xc>
      return (char*)s;
  return 0;
 1b6:	4501                	li	a0,0
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  return 0;
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strchr+0x1a>

00000000000001c2 <gets>:

char*
gets(char *buf, int max)
{
 1c2:	711d                	addi	sp,sp,-96
 1c4:	ec86                	sd	ra,88(sp)
 1c6:	e8a2                	sd	s0,80(sp)
 1c8:	e4a6                	sd	s1,72(sp)
 1ca:	e0ca                	sd	s2,64(sp)
 1cc:	fc4e                	sd	s3,56(sp)
 1ce:	f852                	sd	s4,48(sp)
 1d0:	f456                	sd	s5,40(sp)
 1d2:	f05a                	sd	s6,32(sp)
 1d4:	ec5e                	sd	s7,24(sp)
 1d6:	1080                	addi	s0,sp,96
 1d8:	8baa                	mv	s7,a0
 1da:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1dc:	892a                	mv	s2,a0
 1de:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e0:	4aa9                	li	s5,10
 1e2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e4:	89a6                	mv	s3,s1
 1e6:	2485                	addiw	s1,s1,1
 1e8:	0344d863          	bge	s1,s4,218 <gets+0x56>
    cc = read(0, &c, 1);
 1ec:	4605                	li	a2,1
 1ee:	faf40593          	addi	a1,s0,-81
 1f2:	4501                	li	a0,0
 1f4:	00000097          	auipc	ra,0x0
 1f8:	19c080e7          	jalr	412(ra) # 390 <read>
    if(cc < 1)
 1fc:	00a05e63          	blez	a0,218 <gets+0x56>
    buf[i++] = c;
 200:	faf44783          	lbu	a5,-81(s0)
 204:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 208:	01578763          	beq	a5,s5,216 <gets+0x54>
 20c:	0905                	addi	s2,s2,1
 20e:	fd679be3          	bne	a5,s6,1e4 <gets+0x22>
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	a011                	j	218 <gets+0x56>
 216:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 218:	99de                	add	s3,s3,s7
 21a:	00098023          	sb	zero,0(s3)
  return buf;
}
 21e:	855e                	mv	a0,s7
 220:	60e6                	ld	ra,88(sp)
 222:	6446                	ld	s0,80(sp)
 224:	64a6                	ld	s1,72(sp)
 226:	6906                	ld	s2,64(sp)
 228:	79e2                	ld	s3,56(sp)
 22a:	7a42                	ld	s4,48(sp)
 22c:	7aa2                	ld	s5,40(sp)
 22e:	7b02                	ld	s6,32(sp)
 230:	6be2                	ld	s7,24(sp)
 232:	6125                	addi	sp,sp,96
 234:	8082                	ret

0000000000000236 <stat>:

int
stat(const char *n, struct stat *st)
{
 236:	1101                	addi	sp,sp,-32
 238:	ec06                	sd	ra,24(sp)
 23a:	e822                	sd	s0,16(sp)
 23c:	e426                	sd	s1,8(sp)
 23e:	e04a                	sd	s2,0(sp)
 240:	1000                	addi	s0,sp,32
 242:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 244:	4581                	li	a1,0
 246:	00000097          	auipc	ra,0x0
 24a:	172080e7          	jalr	370(ra) # 3b8 <open>
  if(fd < 0)
 24e:	02054563          	bltz	a0,278 <stat+0x42>
 252:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 254:	85ca                	mv	a1,s2
 256:	00000097          	auipc	ra,0x0
 25a:	17a080e7          	jalr	378(ra) # 3d0 <fstat>
 25e:	892a                	mv	s2,a0
  close(fd);
 260:	8526                	mv	a0,s1
 262:	00000097          	auipc	ra,0x0
 266:	13e080e7          	jalr	318(ra) # 3a0 <close>
  return r;
}
 26a:	854a                	mv	a0,s2
 26c:	60e2                	ld	ra,24(sp)
 26e:	6442                	ld	s0,16(sp)
 270:	64a2                	ld	s1,8(sp)
 272:	6902                	ld	s2,0(sp)
 274:	6105                	addi	sp,sp,32
 276:	8082                	ret
    return -1;
 278:	597d                	li	s2,-1
 27a:	bfc5                	j	26a <stat+0x34>

000000000000027c <atoi>:

int
atoi(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 282:	00054603          	lbu	a2,0(a0)
 286:	fd06079b          	addiw	a5,a2,-48
 28a:	0ff7f793          	andi	a5,a5,255
 28e:	4725                	li	a4,9
 290:	02f76963          	bltu	a4,a5,2c2 <atoi+0x46>
 294:	86aa                	mv	a3,a0
  n = 0;
 296:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 298:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 29a:	0685                	addi	a3,a3,1
 29c:	0025179b          	slliw	a5,a0,0x2
 2a0:	9fa9                	addw	a5,a5,a0
 2a2:	0017979b          	slliw	a5,a5,0x1
 2a6:	9fb1                	addw	a5,a5,a2
 2a8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ac:	0006c603          	lbu	a2,0(a3)
 2b0:	fd06071b          	addiw	a4,a2,-48
 2b4:	0ff77713          	andi	a4,a4,255
 2b8:	fee5f1e3          	bgeu	a1,a4,29a <atoi+0x1e>
  return n;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
  n = 0;
 2c2:	4501                	li	a0,0
 2c4:	bfe5                	j	2bc <atoi+0x40>

00000000000002c6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c6:	1141                	addi	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2cc:	02b57463          	bgeu	a0,a1,2f4 <memmove+0x2e>
    while(n-- > 0)
 2d0:	00c05f63          	blez	a2,2ee <memmove+0x28>
 2d4:	1602                	slli	a2,a2,0x20
 2d6:	9201                	srli	a2,a2,0x20
 2d8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2dc:	872a                	mv	a4,a0
      *dst++ = *src++;
 2de:	0585                	addi	a1,a1,1
 2e0:	0705                	addi	a4,a4,1
 2e2:	fff5c683          	lbu	a3,-1(a1)
 2e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ea:	fee79ae3          	bne	a5,a4,2de <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
    dst += n;
 2f4:	00c50733          	add	a4,a0,a2
    src += n;
 2f8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2fa:	fec05ae3          	blez	a2,2ee <memmove+0x28>
 2fe:	fff6079b          	addiw	a5,a2,-1
 302:	1782                	slli	a5,a5,0x20
 304:	9381                	srli	a5,a5,0x20
 306:	fff7c793          	not	a5,a5
 30a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30c:	15fd                	addi	a1,a1,-1
 30e:	177d                	addi	a4,a4,-1
 310:	0005c683          	lbu	a3,0(a1)
 314:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x46>
 31c:	bfc9                	j	2ee <memmove+0x28>

000000000000031e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31e:	1141                	addi	sp,sp,-16
 320:	e422                	sd	s0,8(sp)
 322:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 324:	ca05                	beqz	a2,354 <memcmp+0x36>
 326:	fff6069b          	addiw	a3,a2,-1
 32a:	1682                	slli	a3,a3,0x20
 32c:	9281                	srli	a3,a3,0x20
 32e:	0685                	addi	a3,a3,1
 330:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 332:	00054783          	lbu	a5,0(a0)
 336:	0005c703          	lbu	a4,0(a1)
 33a:	00e79863          	bne	a5,a4,34a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 33e:	0505                	addi	a0,a0,1
    p2++;
 340:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 342:	fed518e3          	bne	a0,a3,332 <memcmp+0x14>
  }
  return 0;
 346:	4501                	li	a0,0
 348:	a019                	j	34e <memcmp+0x30>
      return *p1 - *p2;
 34a:	40e7853b          	subw	a0,a5,a4
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret
  return 0;
 354:	4501                	li	a0,0
 356:	bfe5                	j	34e <memcmp+0x30>

0000000000000358 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e406                	sd	ra,8(sp)
 35c:	e022                	sd	s0,0(sp)
 35e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 360:	00000097          	auipc	ra,0x0
 364:	f66080e7          	jalr	-154(ra) # 2c6 <memmove>
}
 368:	60a2                	ld	ra,8(sp)
 36a:	6402                	ld	s0,0(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret

0000000000000370 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 370:	4885                	li	a7,1
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exit>:
.global exit
exit:
 li a7, SYS_exit
 378:	4889                	li	a7,2
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <wait>:
.global wait
wait:
 li a7, SYS_wait
 380:	488d                	li	a7,3
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 388:	4891                	li	a7,4
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <read>:
.global read
read:
 li a7, SYS_read
 390:	4895                	li	a7,5
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <write>:
.global write
write:
 li a7, SYS_write
 398:	48c1                	li	a7,16
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <close>:
.global close
close:
 li a7, SYS_close
 3a0:	48d5                	li	a7,21
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a8:	4899                	li	a7,6
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b0:	489d                	li	a7,7
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <open>:
.global open
open:
 li a7, SYS_open
 3b8:	48bd                	li	a7,15
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c0:	48c5                	li	a7,17
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c8:	48c9                	li	a7,18
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d0:	48a1                	li	a7,8
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <link>:
.global link
link:
 li a7, SYS_link
 3d8:	48cd                	li	a7,19
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e0:	48d1                	li	a7,20
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e8:	48a5                	li	a7,9
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f0:	48a9                	li	a7,10
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f8:	48ad                	li	a7,11
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 400:	48b1                	li	a7,12
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 408:	48b5                	li	a7,13
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 410:	48b9                	li	a7,14
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 418:	1101                	addi	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	1000                	addi	s0,sp,32
 420:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 424:	4605                	li	a2,1
 426:	fef40593          	addi	a1,s0,-17
 42a:	00000097          	auipc	ra,0x0
 42e:	f6e080e7          	jalr	-146(ra) # 398 <write>
}
 432:	60e2                	ld	ra,24(sp)
 434:	6442                	ld	s0,16(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret

000000000000043a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43a:	7139                	addi	sp,sp,-64
 43c:	fc06                	sd	ra,56(sp)
 43e:	f822                	sd	s0,48(sp)
 440:	f426                	sd	s1,40(sp)
 442:	f04a                	sd	s2,32(sp)
 444:	ec4e                	sd	s3,24(sp)
 446:	0080                	addi	s0,sp,64
 448:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 44a:	c299                	beqz	a3,450 <printint+0x16>
 44c:	0805c863          	bltz	a1,4dc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 450:	2581                	sext.w	a1,a1
  neg = 0;
 452:	4881                	li	a7,0
 454:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 458:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 45a:	2601                	sext.w	a2,a2
 45c:	00000517          	auipc	a0,0x0
 460:	44450513          	addi	a0,a0,1092 # 8a0 <digits>
 464:	883a                	mv	a6,a4
 466:	2705                	addiw	a4,a4,1
 468:	02c5f7bb          	remuw	a5,a1,a2
 46c:	1782                	slli	a5,a5,0x20
 46e:	9381                	srli	a5,a5,0x20
 470:	97aa                	add	a5,a5,a0
 472:	0007c783          	lbu	a5,0(a5)
 476:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 47a:	0005879b          	sext.w	a5,a1
 47e:	02c5d5bb          	divuw	a1,a1,a2
 482:	0685                	addi	a3,a3,1
 484:	fec7f0e3          	bgeu	a5,a2,464 <printint+0x2a>
  if(neg)
 488:	00088b63          	beqz	a7,49e <printint+0x64>
    buf[i++] = '-';
 48c:	fd040793          	addi	a5,s0,-48
 490:	973e                	add	a4,a4,a5
 492:	02d00793          	li	a5,45
 496:	fef70823          	sb	a5,-16(a4)
 49a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49e:	02e05863          	blez	a4,4ce <printint+0x94>
 4a2:	fc040793          	addi	a5,s0,-64
 4a6:	00e78933          	add	s2,a5,a4
 4aa:	fff78993          	addi	s3,a5,-1
 4ae:	99ba                	add	s3,s3,a4
 4b0:	377d                	addiw	a4,a4,-1
 4b2:	1702                	slli	a4,a4,0x20
 4b4:	9301                	srli	a4,a4,0x20
 4b6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ba:	fff94583          	lbu	a1,-1(s2)
 4be:	8526                	mv	a0,s1
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f58080e7          	jalr	-168(ra) # 418 <putc>
  while(--i >= 0)
 4c8:	197d                	addi	s2,s2,-1
 4ca:	ff3918e3          	bne	s2,s3,4ba <printint+0x80>
}
 4ce:	70e2                	ld	ra,56(sp)
 4d0:	7442                	ld	s0,48(sp)
 4d2:	74a2                	ld	s1,40(sp)
 4d4:	7902                	ld	s2,32(sp)
 4d6:	69e2                	ld	s3,24(sp)
 4d8:	6121                	addi	sp,sp,64
 4da:	8082                	ret
    x = -xx;
 4dc:	40b005bb          	negw	a1,a1
    neg = 1;
 4e0:	4885                	li	a7,1
    x = -xx;
 4e2:	bf8d                	j	454 <printint+0x1a>

00000000000004e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e4:	7119                	addi	sp,sp,-128
 4e6:	fc86                	sd	ra,120(sp)
 4e8:	f8a2                	sd	s0,112(sp)
 4ea:	f4a6                	sd	s1,104(sp)
 4ec:	f0ca                	sd	s2,96(sp)
 4ee:	ecce                	sd	s3,88(sp)
 4f0:	e8d2                	sd	s4,80(sp)
 4f2:	e4d6                	sd	s5,72(sp)
 4f4:	e0da                	sd	s6,64(sp)
 4f6:	fc5e                	sd	s7,56(sp)
 4f8:	f862                	sd	s8,48(sp)
 4fa:	f466                	sd	s9,40(sp)
 4fc:	f06a                	sd	s10,32(sp)
 4fe:	ec6e                	sd	s11,24(sp)
 500:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 502:	0005c903          	lbu	s2,0(a1)
 506:	18090f63          	beqz	s2,6a4 <vprintf+0x1c0>
 50a:	8aaa                	mv	s5,a0
 50c:	8b32                	mv	s6,a2
 50e:	00158493          	addi	s1,a1,1
  state = 0;
 512:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 514:	02500a13          	li	s4,37
      if(c == 'd'){
 518:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 51c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 520:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 524:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 528:	00000b97          	auipc	s7,0x0
 52c:	378b8b93          	addi	s7,s7,888 # 8a0 <digits>
 530:	a839                	j	54e <vprintf+0x6a>
        putc(fd, c);
 532:	85ca                	mv	a1,s2
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	ee2080e7          	jalr	-286(ra) # 418 <putc>
 53e:	a019                	j	544 <vprintf+0x60>
    } else if(state == '%'){
 540:	01498f63          	beq	s3,s4,55e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 544:	0485                	addi	s1,s1,1
 546:	fff4c903          	lbu	s2,-1(s1)
 54a:	14090d63          	beqz	s2,6a4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 54e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 552:	fe0997e3          	bnez	s3,540 <vprintf+0x5c>
      if(c == '%'){
 556:	fd479ee3          	bne	a5,s4,532 <vprintf+0x4e>
        state = '%';
 55a:	89be                	mv	s3,a5
 55c:	b7e5                	j	544 <vprintf+0x60>
      if(c == 'd'){
 55e:	05878063          	beq	a5,s8,59e <vprintf+0xba>
      } else if(c == 'l') {
 562:	05978c63          	beq	a5,s9,5ba <vprintf+0xd6>
      } else if(c == 'x') {
 566:	07a78863          	beq	a5,s10,5d6 <vprintf+0xf2>
      } else if(c == 'p') {
 56a:	09b78463          	beq	a5,s11,5f2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 56e:	07300713          	li	a4,115
 572:	0ce78663          	beq	a5,a4,63e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 576:	06300713          	li	a4,99
 57a:	0ee78e63          	beq	a5,a4,676 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 57e:	11478863          	beq	a5,s4,68e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 582:	85d2                	mv	a1,s4
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e92080e7          	jalr	-366(ra) # 418 <putc>
        putc(fd, c);
 58e:	85ca                	mv	a1,s2
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e86080e7          	jalr	-378(ra) # 418 <putc>
      }
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b765                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b0913          	addi	s2,s6,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000b2583          	lw	a1,0(s6)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e8e080e7          	jalr	-370(ra) # 43a <printint>
 5b4:	8b4a                	mv	s6,s2
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b771                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b0913          	addi	s2,s6,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000b2583          	lw	a1,0(s6)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e72080e7          	jalr	-398(ra) # 43a <printint>
 5d0:	8b4a                	mv	s6,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	bf85                	j	544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b0913          	addi	s2,s6,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000b2583          	lw	a1,0(s6)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e56080e7          	jalr	-426(ra) # 43a <printint>
 5ec:	8b4a                	mv	s6,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bf91                	j	544 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f2:	008b0793          	addi	a5,s6,8
 5f6:	f8f43423          	sd	a5,-120(s0)
 5fa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fe:	03000593          	li	a1,48
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e14080e7          	jalr	-492(ra) # 418 <putc>
  putc(fd, 'x');
 60c:	85ea                	mv	a1,s10
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e08080e7          	jalr	-504(ra) # 418 <putc>
 618:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	03c9d793          	srli	a5,s3,0x3c
 61e:	97de                	add	a5,a5,s7
 620:	0007c583          	lbu	a1,0(a5)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	df2080e7          	jalr	-526(ra) # 418 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62e:	0992                	slli	s3,s3,0x4
 630:	397d                	addiw	s2,s2,-1
 632:	fe0914e3          	bnez	s2,61a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 636:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b721                	j	544 <vprintf+0x60>
        s = va_arg(ap, char*);
 63e:	008b0993          	addi	s3,s6,8
 642:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 646:	02090163          	beqz	s2,668 <vprintf+0x184>
        while(*s != 0){
 64a:	00094583          	lbu	a1,0(s2)
 64e:	c9a1                	beqz	a1,69e <vprintf+0x1ba>
          putc(fd, *s);
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	dc6080e7          	jalr	-570(ra) # 418 <putc>
          s++;
 65a:	0905                	addi	s2,s2,1
        while(*s != 0){
 65c:	00094583          	lbu	a1,0(s2)
 660:	f9e5                	bnez	a1,650 <vprintf+0x16c>
        s = va_arg(ap, char*);
 662:	8b4e                	mv	s6,s3
      state = 0;
 664:	4981                	li	s3,0
 666:	bdf9                	j	544 <vprintf+0x60>
          s = "(null)";
 668:	00000917          	auipc	s2,0x0
 66c:	23090913          	addi	s2,s2,560 # 898 <malloc+0xea>
        while(*s != 0){
 670:	02800593          	li	a1,40
 674:	bff1                	j	650 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 676:	008b0913          	addi	s2,s6,8
 67a:	000b4583          	lbu	a1,0(s6)
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	d98080e7          	jalr	-616(ra) # 418 <putc>
 688:	8b4a                	mv	s6,s2
      state = 0;
 68a:	4981                	li	s3,0
 68c:	bd65                	j	544 <vprintf+0x60>
        putc(fd, c);
 68e:	85d2                	mv	a1,s4
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	d86080e7          	jalr	-634(ra) # 418 <putc>
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b565                	j	544 <vprintf+0x60>
        s = va_arg(ap, char*);
 69e:	8b4e                	mv	s6,s3
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	b54d                	j	544 <vprintf+0x60>
    }
  }
}
 6a4:	70e6                	ld	ra,120(sp)
 6a6:	7446                	ld	s0,112(sp)
 6a8:	74a6                	ld	s1,104(sp)
 6aa:	7906                	ld	s2,96(sp)
 6ac:	69e6                	ld	s3,88(sp)
 6ae:	6a46                	ld	s4,80(sp)
 6b0:	6aa6                	ld	s5,72(sp)
 6b2:	6b06                	ld	s6,64(sp)
 6b4:	7be2                	ld	s7,56(sp)
 6b6:	7c42                	ld	s8,48(sp)
 6b8:	7ca2                	ld	s9,40(sp)
 6ba:	7d02                	ld	s10,32(sp)
 6bc:	6de2                	ld	s11,24(sp)
 6be:	6109                	addi	sp,sp,128
 6c0:	8082                	ret

00000000000006c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c2:	715d                	addi	sp,sp,-80
 6c4:	ec06                	sd	ra,24(sp)
 6c6:	e822                	sd	s0,16(sp)
 6c8:	1000                	addi	s0,sp,32
 6ca:	e010                	sd	a2,0(s0)
 6cc:	e414                	sd	a3,8(s0)
 6ce:	e818                	sd	a4,16(s0)
 6d0:	ec1c                	sd	a5,24(s0)
 6d2:	03043023          	sd	a6,32(s0)
 6d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6de:	8622                	mv	a2,s0
 6e0:	00000097          	auipc	ra,0x0
 6e4:	e04080e7          	jalr	-508(ra) # 4e4 <vprintf>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6161                	addi	sp,sp,80
 6ee:	8082                	ret

00000000000006f0 <printf>:

void
printf(const char *fmt, ...)
{
 6f0:	711d                	addi	sp,sp,-96
 6f2:	ec06                	sd	ra,24(sp)
 6f4:	e822                	sd	s0,16(sp)
 6f6:	1000                	addi	s0,sp,32
 6f8:	e40c                	sd	a1,8(s0)
 6fa:	e810                	sd	a2,16(s0)
 6fc:	ec14                	sd	a3,24(s0)
 6fe:	f018                	sd	a4,32(s0)
 700:	f41c                	sd	a5,40(s0)
 702:	03043823          	sd	a6,48(s0)
 706:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 70a:	00840613          	addi	a2,s0,8
 70e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 712:	85aa                	mv	a1,a0
 714:	4505                	li	a0,1
 716:	00000097          	auipc	ra,0x0
 71a:	dce080e7          	jalr	-562(ra) # 4e4 <vprintf>
}
 71e:	60e2                	ld	ra,24(sp)
 720:	6442                	ld	s0,16(sp)
 722:	6125                	addi	sp,sp,96
 724:	8082                	ret

0000000000000726 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 726:	1141                	addi	sp,sp,-16
 728:	e422                	sd	s0,8(sp)
 72a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 730:	00000797          	auipc	a5,0x0
 734:	1887b783          	ld	a5,392(a5) # 8b8 <freep>
 738:	a805                	j	768 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 73a:	4618                	lw	a4,8(a2)
 73c:	9db9                	addw	a1,a1,a4
 73e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 742:	6398                	ld	a4,0(a5)
 744:	6318                	ld	a4,0(a4)
 746:	fee53823          	sd	a4,-16(a0)
 74a:	a091                	j	78e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74c:	ff852703          	lw	a4,-8(a0)
 750:	9e39                	addw	a2,a2,a4
 752:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 754:	ff053703          	ld	a4,-16(a0)
 758:	e398                	sd	a4,0(a5)
 75a:	a099                	j	7a0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75c:	6398                	ld	a4,0(a5)
 75e:	00e7e463          	bltu	a5,a4,766 <free+0x40>
 762:	00e6ea63          	bltu	a3,a4,776 <free+0x50>
{
 766:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 768:	fed7fae3          	bgeu	a5,a3,75c <free+0x36>
 76c:	6398                	ld	a4,0(a5)
 76e:	00e6e463          	bltu	a3,a4,776 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	fee7eae3          	bltu	a5,a4,766 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 776:	ff852583          	lw	a1,-8(a0)
 77a:	6390                	ld	a2,0(a5)
 77c:	02059813          	slli	a6,a1,0x20
 780:	01c85713          	srli	a4,a6,0x1c
 784:	9736                	add	a4,a4,a3
 786:	fae60ae3          	beq	a2,a4,73a <free+0x14>
    bp->s.ptr = p->s.ptr;
 78a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78e:	4790                	lw	a2,8(a5)
 790:	02061593          	slli	a1,a2,0x20
 794:	01c5d713          	srli	a4,a1,0x1c
 798:	973e                	add	a4,a4,a5
 79a:	fae689e3          	beq	a3,a4,74c <free+0x26>
  } else
    p->s.ptr = bp;
 79e:	e394                	sd	a3,0(a5)
  freep = p;
 7a0:	00000717          	auipc	a4,0x0
 7a4:	10f73c23          	sd	a5,280(a4) # 8b8 <freep>
}
 7a8:	6422                	ld	s0,8(sp)
 7aa:	0141                	addi	sp,sp,16
 7ac:	8082                	ret

00000000000007ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ae:	7139                	addi	sp,sp,-64
 7b0:	fc06                	sd	ra,56(sp)
 7b2:	f822                	sd	s0,48(sp)
 7b4:	f426                	sd	s1,40(sp)
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	ec4e                	sd	s3,24(sp)
 7ba:	e852                	sd	s4,16(sp)
 7bc:	e456                	sd	s5,8(sp)
 7be:	e05a                	sd	s6,0(sp)
 7c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c2:	02051493          	slli	s1,a0,0x20
 7c6:	9081                	srli	s1,s1,0x20
 7c8:	04bd                	addi	s1,s1,15
 7ca:	8091                	srli	s1,s1,0x4
 7cc:	0014899b          	addiw	s3,s1,1
 7d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d2:	00000517          	auipc	a0,0x0
 7d6:	0e653503          	ld	a0,230(a0) # 8b8 <freep>
 7da:	c515                	beqz	a0,806 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7de:	4798                	lw	a4,8(a5)
 7e0:	02977f63          	bgeu	a4,s1,81e <malloc+0x70>
 7e4:	8a4e                	mv	s4,s3
 7e6:	0009871b          	sext.w	a4,s3
 7ea:	6685                	lui	a3,0x1
 7ec:	00d77363          	bgeu	a4,a3,7f2 <malloc+0x44>
 7f0:	6a05                	lui	s4,0x1
 7f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7fa:	00000917          	auipc	s2,0x0
 7fe:	0be90913          	addi	s2,s2,190 # 8b8 <freep>
  if(p == (char*)-1)
 802:	5afd                	li	s5,-1
 804:	a895                	j	878 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 806:	00000797          	auipc	a5,0x0
 80a:	0ba78793          	addi	a5,a5,186 # 8c0 <base>
 80e:	00000717          	auipc	a4,0x0
 812:	0af73523          	sd	a5,170(a4) # 8b8 <freep>
 816:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 818:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81c:	b7e1                	j	7e4 <malloc+0x36>
      if(p->s.size == nunits)
 81e:	02e48c63          	beq	s1,a4,856 <malloc+0xa8>
        p->s.size -= nunits;
 822:	4137073b          	subw	a4,a4,s3
 826:	c798                	sw	a4,8(a5)
        p += p->s.size;
 828:	02071693          	slli	a3,a4,0x20
 82c:	01c6d713          	srli	a4,a3,0x1c
 830:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 832:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 836:	00000717          	auipc	a4,0x0
 83a:	08a73123          	sd	a0,130(a4) # 8b8 <freep>
      return (void*)(p + 1);
 83e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 842:	70e2                	ld	ra,56(sp)
 844:	7442                	ld	s0,48(sp)
 846:	74a2                	ld	s1,40(sp)
 848:	7902                	ld	s2,32(sp)
 84a:	69e2                	ld	s3,24(sp)
 84c:	6a42                	ld	s4,16(sp)
 84e:	6aa2                	ld	s5,8(sp)
 850:	6b02                	ld	s6,0(sp)
 852:	6121                	addi	sp,sp,64
 854:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	e118                	sd	a4,0(a0)
 85a:	bff1                	j	836 <malloc+0x88>
  hp->s.size = nu;
 85c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 860:	0541                	addi	a0,a0,16
 862:	00000097          	auipc	ra,0x0
 866:	ec4080e7          	jalr	-316(ra) # 726 <free>
  return freep;
 86a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86e:	d971                	beqz	a0,842 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	fa9775e3          	bgeu	a4,s1,81e <malloc+0x70>
    if(p == freep)
 878:	00093703          	ld	a4,0(s2)
 87c:	853e                	mv	a0,a5
 87e:	fef719e3          	bne	a4,a5,870 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 882:	8552                	mv	a0,s4
 884:	00000097          	auipc	ra,0x0
 888:	b7c080e7          	jalr	-1156(ra) # 400 <sbrk>
  if(p == (char*)-1)
 88c:	fd5518e3          	bne	a0,s5,85c <malloc+0xae>
        return 0;
 890:	4501                	li	a0,0
 892:	bf45                	j	842 <malloc+0x94>
