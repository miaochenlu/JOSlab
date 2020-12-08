
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"


void find(char* path, char* filename) {
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	24913c23          	sd	s1,600(sp)
  10:	25213823          	sd	s2,592(sp)
  14:	25313423          	sd	s3,584(sp)
  18:	25413023          	sd	s4,576(sp)
  1c:	23513c23          	sd	s5,568(sp)
  20:	23613823          	sd	s6,560(sp)
  24:	1c80                	addi	s0,sp,624
  26:	892a                	mv	s2,a0
  28:	89ae                	mv	s3,a1
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;

    if((fd = open(path, 0)) < 0) {
  2a:	4581                	li	a1,0
  2c:	00000097          	auipc	ra,0x0
  30:	4d8080e7          	jalr	1240(ra) # 504 <open>
  34:	06054263          	bltz	a0,98 <find+0x98>
  38:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        return;
    }

    if(fstat(fd, &st) < 0) {
  3a:	d9840593          	addi	a1,s0,-616
  3e:	00000097          	auipc	ra,0x0
  42:	4de080e7          	jalr	1246(ra) # 51c <fstat>
  46:	06054463          	bltz	a0,ae <find+0xae>
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        return;
    }

    if(st.type != T_DIR) {
  4a:	da041703          	lh	a4,-608(s0)
  4e:	4785                	li	a5,1
  50:	06f70f63          	beq	a4,a5,ce <find+0xce>
        fprintf(2, "find: %s is not a directory\n", path);
  54:	864a                	mv	a2,s2
  56:	00001597          	auipc	a1,0x1
  5a:	9ba58593          	addi	a1,a1,-1606 # a10 <malloc+0x116>
  5e:	4509                	li	a0,2
  60:	00000097          	auipc	ra,0x0
  64:	7ae080e7          	jalr	1966(ra) # 80e <fprintf>
        close(fd);
  68:	8526                	mv	a0,s1
  6a:	00000097          	auipc	ra,0x0
  6e:	482080e7          	jalr	1154(ra) # 4ec <close>
        case T_DIR:
            find(buf, filename);
        }
    }
    close(fd);
}
  72:	26813083          	ld	ra,616(sp)
  76:	26013403          	ld	s0,608(sp)
  7a:	25813483          	ld	s1,600(sp)
  7e:	25013903          	ld	s2,592(sp)
  82:	24813983          	ld	s3,584(sp)
  86:	24013a03          	ld	s4,576(sp)
  8a:	23813a83          	ld	s5,568(sp)
  8e:	23013b03          	ld	s6,560(sp)
  92:	27010113          	addi	sp,sp,624
  96:	8082                	ret
        fprintf(2, "find: cannot open %s\n", path);
  98:	864a                	mv	a2,s2
  9a:	00001597          	auipc	a1,0x1
  9e:	94658593          	addi	a1,a1,-1722 # 9e0 <malloc+0xe6>
  a2:	4509                	li	a0,2
  a4:	00000097          	auipc	ra,0x0
  a8:	76a080e7          	jalr	1898(ra) # 80e <fprintf>
        return;
  ac:	b7d9                	j	72 <find+0x72>
        fprintf(2, "find: cannot stat %s\n", path);
  ae:	864a                	mv	a2,s2
  b0:	00001597          	auipc	a1,0x1
  b4:	94858593          	addi	a1,a1,-1720 # 9f8 <malloc+0xfe>
  b8:	4509                	li	a0,2
  ba:	00000097          	auipc	ra,0x0
  be:	754080e7          	jalr	1876(ra) # 80e <fprintf>
        close(fd);
  c2:	8526                	mv	a0,s1
  c4:	00000097          	auipc	ra,0x0
  c8:	428080e7          	jalr	1064(ra) # 4ec <close>
        return;
  cc:	b75d                	j	72 <find+0x72>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
  ce:	854a                	mv	a0,s2
  d0:	00000097          	auipc	ra,0x0
  d4:	1ce080e7          	jalr	462(ra) # 29e <strlen>
  d8:	2541                	addiw	a0,a0,16
  da:	20000793          	li	a5,512
  de:	0ea7e363          	bltu	a5,a0,1c4 <find+0x1c4>
    strcpy(buf, path);
  e2:	85ca                	mv	a1,s2
  e4:	dc040513          	addi	a0,s0,-576
  e8:	00000097          	auipc	ra,0x0
  ec:	16e080e7          	jalr	366(ra) # 256 <strcpy>
    p = buf+strlen(buf);
  f0:	dc040513          	addi	a0,s0,-576
  f4:	00000097          	auipc	ra,0x0
  f8:	1aa080e7          	jalr	426(ra) # 29e <strlen>
  fc:	02051913          	slli	s2,a0,0x20
 100:	02095913          	srli	s2,s2,0x20
 104:	dc040793          	addi	a5,s0,-576
 108:	993e                	add	s2,s2,a5
    *p++ = '/';
 10a:	00190a93          	addi	s5,s2,1
 10e:	02f00793          	li	a5,47
 112:	00f90023          	sb	a5,0(s2)
        if(strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 116:	00001a17          	auipc	s4,0x1
 11a:	932a0a13          	addi	s4,s4,-1742 # a48 <malloc+0x14e>
 11e:	00001b17          	auipc	s6,0x1
 122:	932b0b13          	addi	s6,s6,-1742 # a50 <malloc+0x156>
    while(read(fd, &de, sizeof(de)) == sizeof(de)) {
 126:	4641                	li	a2,16
 128:	db040593          	addi	a1,s0,-592
 12c:	8526                	mv	a0,s1
 12e:	00000097          	auipc	ra,0x0
 132:	3ae080e7          	jalr	942(ra) # 4dc <read>
 136:	47c1                	li	a5,16
 138:	0cf51863          	bne	a0,a5,208 <find+0x208>
        if(de.inum == 0) 
 13c:	db045783          	lhu	a5,-592(s0)
 140:	d3fd                	beqz	a5,126 <find+0x126>
        if(strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 142:	85d2                	mv	a1,s4
 144:	db240513          	addi	a0,s0,-590
 148:	00000097          	auipc	ra,0x0
 14c:	12a080e7          	jalr	298(ra) # 272 <strcmp>
 150:	d979                	beqz	a0,126 <find+0x126>
 152:	85da                	mv	a1,s6
 154:	db240513          	addi	a0,s0,-590
 158:	00000097          	auipc	ra,0x0
 15c:	11a080e7          	jalr	282(ra) # 272 <strcmp>
 160:	d179                	beqz	a0,126 <find+0x126>
        memmove(p, de.name, DIRSIZ);
 162:	4639                	li	a2,14
 164:	db240593          	addi	a1,s0,-590
 168:	8556                	mv	a0,s5
 16a:	00000097          	auipc	ra,0x0
 16e:	2a8080e7          	jalr	680(ra) # 412 <memmove>
        p[DIRSIZ] = 0;
 172:	000907a3          	sb	zero,15(s2)
        if(stat(buf, &st) < 0) {
 176:	d9840593          	addi	a1,s0,-616
 17a:	dc040513          	addi	a0,s0,-576
 17e:	00000097          	auipc	ra,0x0
 182:	204080e7          	jalr	516(ra) # 382 <stat>
 186:	04054d63          	bltz	a0,1e0 <find+0x1e0>
        switch (st.type)
 18a:	da041783          	lh	a5,-608(s0)
 18e:	0007869b          	sext.w	a3,a5
 192:	4705                	li	a4,1
 194:	06e68263          	beq	a3,a4,1f8 <find+0x1f8>
 198:	4709                	li	a4,2
 19a:	f8e696e3          	bne	a3,a4,126 <find+0x126>
            if(strcmp(de.name, filename) == 0) {
 19e:	85ce                	mv	a1,s3
 1a0:	db240513          	addi	a0,s0,-590
 1a4:	00000097          	auipc	ra,0x0
 1a8:	0ce080e7          	jalr	206(ra) # 272 <strcmp>
 1ac:	fd2d                	bnez	a0,126 <find+0x126>
                printf("%s\n", buf);
 1ae:	dc040593          	addi	a1,s0,-576
 1b2:	00001517          	auipc	a0,0x1
 1b6:	8a650513          	addi	a0,a0,-1882 # a58 <malloc+0x15e>
 1ba:	00000097          	auipc	ra,0x0
 1be:	682080e7          	jalr	1666(ra) # 83c <printf>
 1c2:	b795                	j	126 <find+0x126>
        printf("find: path too long\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	86c50513          	addi	a0,a0,-1940 # a30 <malloc+0x136>
 1cc:	00000097          	auipc	ra,0x0
 1d0:	670080e7          	jalr	1648(ra) # 83c <printf>
        close(fd);
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	316080e7          	jalr	790(ra) # 4ec <close>
        return;
 1de:	bd51                	j	72 <find+0x72>
            fprintf(2, "find: cannot stat %s\n", buf);;
 1e0:	dc040613          	addi	a2,s0,-576
 1e4:	00001597          	auipc	a1,0x1
 1e8:	81458593          	addi	a1,a1,-2028 # 9f8 <malloc+0xfe>
 1ec:	4509                	li	a0,2
 1ee:	00000097          	auipc	ra,0x0
 1f2:	620080e7          	jalr	1568(ra) # 80e <fprintf>
            continue;
 1f6:	bf05                	j	126 <find+0x126>
            find(buf, filename);
 1f8:	85ce                	mv	a1,s3
 1fa:	dc040513          	addi	a0,s0,-576
 1fe:	00000097          	auipc	ra,0x0
 202:	e02080e7          	jalr	-510(ra) # 0 <find>
 206:	b705                	j	126 <find+0x126>
    close(fd);
 208:	8526                	mv	a0,s1
 20a:	00000097          	auipc	ra,0x0
 20e:	2e2080e7          	jalr	738(ra) # 4ec <close>
 212:	b585                	j	72 <find+0x72>

0000000000000214 <main>:

int
main(int argc, char *argv[])
{
 214:	1141                	addi	sp,sp,-16
 216:	e406                	sd	ra,8(sp)
 218:	e022                	sd	s0,0(sp)
 21a:	0800                	addi	s0,sp,16
  if(argc < 3){
 21c:	4709                	li	a4,2
 21e:	02a74063          	blt	a4,a0,23e <main+0x2a>
    fprintf(2, "Usage: find path filename\n");
 222:	00001597          	auipc	a1,0x1
 226:	83e58593          	addi	a1,a1,-1986 # a60 <malloc+0x166>
 22a:	4509                	li	a0,2
 22c:	00000097          	auipc	ra,0x0
 230:	5e2080e7          	jalr	1506(ra) # 80e <fprintf>
    exit(1);
 234:	4505                	li	a0,1
 236:	00000097          	auipc	ra,0x0
 23a:	28e080e7          	jalr	654(ra) # 4c4 <exit>
 23e:	87ae                	mv	a5,a1
  }
  find(argv[1], argv[2]);
 240:	698c                	ld	a1,16(a1)
 242:	6788                	ld	a0,8(a5)
 244:	00000097          	auipc	ra,0x0
 248:	dbc080e7          	jalr	-580(ra) # 0 <find>
  exit(0);
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	276080e7          	jalr	630(ra) # 4c4 <exit>

0000000000000256 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 25c:	87aa                	mv	a5,a0
 25e:	0585                	addi	a1,a1,1
 260:	0785                	addi	a5,a5,1
 262:	fff5c703          	lbu	a4,-1(a1)
 266:	fee78fa3          	sb	a4,-1(a5)
 26a:	fb75                	bnez	a4,25e <strcpy+0x8>
    ;
  return os;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret

0000000000000272 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 278:	00054783          	lbu	a5,0(a0)
 27c:	cb91                	beqz	a5,290 <strcmp+0x1e>
 27e:	0005c703          	lbu	a4,0(a1)
 282:	00f71763          	bne	a4,a5,290 <strcmp+0x1e>
    p++, q++;
 286:	0505                	addi	a0,a0,1
 288:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 28a:	00054783          	lbu	a5,0(a0)
 28e:	fbe5                	bnez	a5,27e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 290:	0005c503          	lbu	a0,0(a1)
}
 294:	40a7853b          	subw	a0,a5,a0
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <strlen>:

uint
strlen(const char *s)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	cf91                	beqz	a5,2c4 <strlen+0x26>
 2aa:	0505                	addi	a0,a0,1
 2ac:	87aa                	mv	a5,a0
 2ae:	4685                	li	a3,1
 2b0:	9e89                	subw	a3,a3,a0
 2b2:	00f6853b          	addw	a0,a3,a5
 2b6:	0785                	addi	a5,a5,1
 2b8:	fff7c703          	lbu	a4,-1(a5)
 2bc:	fb7d                	bnez	a4,2b2 <strlen+0x14>
    ;
  return n;
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
  for(n = 0; s[n]; n++)
 2c4:	4501                	li	a0,0
 2c6:	bfe5                	j	2be <strlen+0x20>

00000000000002c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ce:	ca19                	beqz	a2,2e4 <memset+0x1c>
 2d0:	87aa                	mv	a5,a0
 2d2:	1602                	slli	a2,a2,0x20
 2d4:	9201                	srli	a2,a2,0x20
 2d6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2de:	0785                	addi	a5,a5,1
 2e0:	fee79de3          	bne	a5,a4,2da <memset+0x12>
  }
  return dst;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <strchr>:

char*
strchr(const char *s, char c)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cb99                	beqz	a5,30a <strchr+0x20>
    if(*s == c)
 2f6:	00f58763          	beq	a1,a5,304 <strchr+0x1a>
  for(; *s; s++)
 2fa:	0505                	addi	a0,a0,1
 2fc:	00054783          	lbu	a5,0(a0)
 300:	fbfd                	bnez	a5,2f6 <strchr+0xc>
      return (char*)s;
  return 0;
 302:	4501                	li	a0,0
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <strchr+0x1a>

000000000000030e <gets>:

char*
gets(char *buf, int max)
{
 30e:	711d                	addi	sp,sp,-96
 310:	ec86                	sd	ra,88(sp)
 312:	e8a2                	sd	s0,80(sp)
 314:	e4a6                	sd	s1,72(sp)
 316:	e0ca                	sd	s2,64(sp)
 318:	fc4e                	sd	s3,56(sp)
 31a:	f852                	sd	s4,48(sp)
 31c:	f456                	sd	s5,40(sp)
 31e:	f05a                	sd	s6,32(sp)
 320:	ec5e                	sd	s7,24(sp)
 322:	1080                	addi	s0,sp,96
 324:	8baa                	mv	s7,a0
 326:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 328:	892a                	mv	s2,a0
 32a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 32c:	4aa9                	li	s5,10
 32e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 330:	89a6                	mv	s3,s1
 332:	2485                	addiw	s1,s1,1
 334:	0344d863          	bge	s1,s4,364 <gets+0x56>
    cc = read(0, &c, 1);
 338:	4605                	li	a2,1
 33a:	faf40593          	addi	a1,s0,-81
 33e:	4501                	li	a0,0
 340:	00000097          	auipc	ra,0x0
 344:	19c080e7          	jalr	412(ra) # 4dc <read>
    if(cc < 1)
 348:	00a05e63          	blez	a0,364 <gets+0x56>
    buf[i++] = c;
 34c:	faf44783          	lbu	a5,-81(s0)
 350:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 354:	01578763          	beq	a5,s5,362 <gets+0x54>
 358:	0905                	addi	s2,s2,1
 35a:	fd679be3          	bne	a5,s6,330 <gets+0x22>
  for(i=0; i+1 < max; ){
 35e:	89a6                	mv	s3,s1
 360:	a011                	j	364 <gets+0x56>
 362:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 364:	99de                	add	s3,s3,s7
 366:	00098023          	sb	zero,0(s3)
  return buf;
}
 36a:	855e                	mv	a0,s7
 36c:	60e6                	ld	ra,88(sp)
 36e:	6446                	ld	s0,80(sp)
 370:	64a6                	ld	s1,72(sp)
 372:	6906                	ld	s2,64(sp)
 374:	79e2                	ld	s3,56(sp)
 376:	7a42                	ld	s4,48(sp)
 378:	7aa2                	ld	s5,40(sp)
 37a:	7b02                	ld	s6,32(sp)
 37c:	6be2                	ld	s7,24(sp)
 37e:	6125                	addi	sp,sp,96
 380:	8082                	ret

0000000000000382 <stat>:

int
stat(const char *n, struct stat *st)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	e426                	sd	s1,8(sp)
 38a:	e04a                	sd	s2,0(sp)
 38c:	1000                	addi	s0,sp,32
 38e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 390:	4581                	li	a1,0
 392:	00000097          	auipc	ra,0x0
 396:	172080e7          	jalr	370(ra) # 504 <open>
  if(fd < 0)
 39a:	02054563          	bltz	a0,3c4 <stat+0x42>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	00000097          	auipc	ra,0x0
 3a6:	17a080e7          	jalr	378(ra) # 51c <fstat>
 3aa:	892a                	mv	s2,a0
  close(fd);
 3ac:	8526                	mv	a0,s1
 3ae:	00000097          	auipc	ra,0x0
 3b2:	13e080e7          	jalr	318(ra) # 4ec <close>
  return r;
}
 3b6:	854a                	mv	a0,s2
 3b8:	60e2                	ld	ra,24(sp)
 3ba:	6442                	ld	s0,16(sp)
 3bc:	64a2                	ld	s1,8(sp)
 3be:	6902                	ld	s2,0(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret
    return -1;
 3c4:	597d                	li	s2,-1
 3c6:	bfc5                	j	3b6 <stat+0x34>

00000000000003c8 <atoi>:

int
atoi(const char *s)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e422                	sd	s0,8(sp)
 3cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ce:	00054603          	lbu	a2,0(a0)
 3d2:	fd06079b          	addiw	a5,a2,-48
 3d6:	0ff7f793          	andi	a5,a5,255
 3da:	4725                	li	a4,9
 3dc:	02f76963          	bltu	a4,a5,40e <atoi+0x46>
 3e0:	86aa                	mv	a3,a0
  n = 0;
 3e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3e6:	0685                	addi	a3,a3,1
 3e8:	0025179b          	slliw	a5,a0,0x2
 3ec:	9fa9                	addw	a5,a5,a0
 3ee:	0017979b          	slliw	a5,a5,0x1
 3f2:	9fb1                	addw	a5,a5,a2
 3f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f8:	0006c603          	lbu	a2,0(a3)
 3fc:	fd06071b          	addiw	a4,a2,-48
 400:	0ff77713          	andi	a4,a4,255
 404:	fee5f1e3          	bgeu	a1,a4,3e6 <atoi+0x1e>
  return n;
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  n = 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <atoi+0x40>

0000000000000412 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 418:	02b57463          	bgeu	a0,a1,440 <memmove+0x2e>
    while(n-- > 0)
 41c:	00c05f63          	blez	a2,43a <memmove+0x28>
 420:	1602                	slli	a2,a2,0x20
 422:	9201                	srli	a2,a2,0x20
 424:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 428:	872a                	mv	a4,a0
      *dst++ = *src++;
 42a:	0585                	addi	a1,a1,1
 42c:	0705                	addi	a4,a4,1
 42e:	fff5c683          	lbu	a3,-1(a1)
 432:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 436:	fee79ae3          	bne	a5,a4,42a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
    dst += n;
 440:	00c50733          	add	a4,a0,a2
    src += n;
 444:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 446:	fec05ae3          	blez	a2,43a <memmove+0x28>
 44a:	fff6079b          	addiw	a5,a2,-1
 44e:	1782                	slli	a5,a5,0x20
 450:	9381                	srli	a5,a5,0x20
 452:	fff7c793          	not	a5,a5
 456:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 458:	15fd                	addi	a1,a1,-1
 45a:	177d                	addi	a4,a4,-1
 45c:	0005c683          	lbu	a3,0(a1)
 460:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 464:	fee79ae3          	bne	a5,a4,458 <memmove+0x46>
 468:	bfc9                	j	43a <memmove+0x28>

000000000000046a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e422                	sd	s0,8(sp)
 46e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 470:	ca05                	beqz	a2,4a0 <memcmp+0x36>
 472:	fff6069b          	addiw	a3,a2,-1
 476:	1682                	slli	a3,a3,0x20
 478:	9281                	srli	a3,a3,0x20
 47a:	0685                	addi	a3,a3,1
 47c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 47e:	00054783          	lbu	a5,0(a0)
 482:	0005c703          	lbu	a4,0(a1)
 486:	00e79863          	bne	a5,a4,496 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48a:	0505                	addi	a0,a0,1
    p2++;
 48c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 48e:	fed518e3          	bne	a0,a3,47e <memcmp+0x14>
  }
  return 0;
 492:	4501                	li	a0,0
 494:	a019                	j	49a <memcmp+0x30>
      return *p1 - *p2;
 496:	40e7853b          	subw	a0,a5,a4
}
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret
  return 0;
 4a0:	4501                	li	a0,0
 4a2:	bfe5                	j	49a <memcmp+0x30>

00000000000004a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e406                	sd	ra,8(sp)
 4a8:	e022                	sd	s0,0(sp)
 4aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ac:	00000097          	auipc	ra,0x0
 4b0:	f66080e7          	jalr	-154(ra) # 412 <memmove>
}
 4b4:	60a2                	ld	ra,8(sp)
 4b6:	6402                	ld	s0,0(sp)
 4b8:	0141                	addi	sp,sp,16
 4ba:	8082                	ret

00000000000004bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4bc:	4885                	li	a7,1
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c4:	4889                	li	a7,2
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 4cc:	488d                	li	a7,3
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d4:	4891                	li	a7,4
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <read>:
.global read
read:
 li a7, SYS_read
 4dc:	4895                	li	a7,5
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <write>:
.global write
write:
 li a7, SYS_write
 4e4:	48c1                	li	a7,16
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <close>:
.global close
close:
 li a7, SYS_close
 4ec:	48d5                	li	a7,21
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f4:	4899                	li	a7,6
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fc:	489d                	li	a7,7
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <open>:
.global open
open:
 li a7, SYS_open
 504:	48bd                	li	a7,15
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50c:	48c5                	li	a7,17
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 514:	48c9                	li	a7,18
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51c:	48a1                	li	a7,8
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <link>:
.global link
link:
 li a7, SYS_link
 524:	48cd                	li	a7,19
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52c:	48d1                	li	a7,20
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 534:	48a5                	li	a7,9
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <dup>:
.global dup
dup:
 li a7, SYS_dup
 53c:	48a9                	li	a7,10
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 544:	48ad                	li	a7,11
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 54c:	48b1                	li	a7,12
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 554:	48b5                	li	a7,13
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55c:	48b9                	li	a7,14
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 564:	1101                	addi	sp,sp,-32
 566:	ec06                	sd	ra,24(sp)
 568:	e822                	sd	s0,16(sp)
 56a:	1000                	addi	s0,sp,32
 56c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 570:	4605                	li	a2,1
 572:	fef40593          	addi	a1,s0,-17
 576:	00000097          	auipc	ra,0x0
 57a:	f6e080e7          	jalr	-146(ra) # 4e4 <write>
}
 57e:	60e2                	ld	ra,24(sp)
 580:	6442                	ld	s0,16(sp)
 582:	6105                	addi	sp,sp,32
 584:	8082                	ret

0000000000000586 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 586:	7139                	addi	sp,sp,-64
 588:	fc06                	sd	ra,56(sp)
 58a:	f822                	sd	s0,48(sp)
 58c:	f426                	sd	s1,40(sp)
 58e:	f04a                	sd	s2,32(sp)
 590:	ec4e                	sd	s3,24(sp)
 592:	0080                	addi	s0,sp,64
 594:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 596:	c299                	beqz	a3,59c <printint+0x16>
 598:	0805c863          	bltz	a1,628 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 59c:	2581                	sext.w	a1,a1
  neg = 0;
 59e:	4881                	li	a7,0
 5a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a6:	2601                	sext.w	a2,a2
 5a8:	00000517          	auipc	a0,0x0
 5ac:	4e050513          	addi	a0,a0,1248 # a88 <digits>
 5b0:	883a                	mv	a6,a4
 5b2:	2705                	addiw	a4,a4,1
 5b4:	02c5f7bb          	remuw	a5,a1,a2
 5b8:	1782                	slli	a5,a5,0x20
 5ba:	9381                	srli	a5,a5,0x20
 5bc:	97aa                	add	a5,a5,a0
 5be:	0007c783          	lbu	a5,0(a5)
 5c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c6:	0005879b          	sext.w	a5,a1
 5ca:	02c5d5bb          	divuw	a1,a1,a2
 5ce:	0685                	addi	a3,a3,1
 5d0:	fec7f0e3          	bgeu	a5,a2,5b0 <printint+0x2a>
  if(neg)
 5d4:	00088b63          	beqz	a7,5ea <printint+0x64>
    buf[i++] = '-';
 5d8:	fd040793          	addi	a5,s0,-48
 5dc:	973e                	add	a4,a4,a5
 5de:	02d00793          	li	a5,45
 5e2:	fef70823          	sb	a5,-16(a4)
 5e6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ea:	02e05863          	blez	a4,61a <printint+0x94>
 5ee:	fc040793          	addi	a5,s0,-64
 5f2:	00e78933          	add	s2,a5,a4
 5f6:	fff78993          	addi	s3,a5,-1
 5fa:	99ba                	add	s3,s3,a4
 5fc:	377d                	addiw	a4,a4,-1
 5fe:	1702                	slli	a4,a4,0x20
 600:	9301                	srli	a4,a4,0x20
 602:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 606:	fff94583          	lbu	a1,-1(s2)
 60a:	8526                	mv	a0,s1
 60c:	00000097          	auipc	ra,0x0
 610:	f58080e7          	jalr	-168(ra) # 564 <putc>
  while(--i >= 0)
 614:	197d                	addi	s2,s2,-1
 616:	ff3918e3          	bne	s2,s3,606 <printint+0x80>
}
 61a:	70e2                	ld	ra,56(sp)
 61c:	7442                	ld	s0,48(sp)
 61e:	74a2                	ld	s1,40(sp)
 620:	7902                	ld	s2,32(sp)
 622:	69e2                	ld	s3,24(sp)
 624:	6121                	addi	sp,sp,64
 626:	8082                	ret
    x = -xx;
 628:	40b005bb          	negw	a1,a1
    neg = 1;
 62c:	4885                	li	a7,1
    x = -xx;
 62e:	bf8d                	j	5a0 <printint+0x1a>

0000000000000630 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 630:	7119                	addi	sp,sp,-128
 632:	fc86                	sd	ra,120(sp)
 634:	f8a2                	sd	s0,112(sp)
 636:	f4a6                	sd	s1,104(sp)
 638:	f0ca                	sd	s2,96(sp)
 63a:	ecce                	sd	s3,88(sp)
 63c:	e8d2                	sd	s4,80(sp)
 63e:	e4d6                	sd	s5,72(sp)
 640:	e0da                	sd	s6,64(sp)
 642:	fc5e                	sd	s7,56(sp)
 644:	f862                	sd	s8,48(sp)
 646:	f466                	sd	s9,40(sp)
 648:	f06a                	sd	s10,32(sp)
 64a:	ec6e                	sd	s11,24(sp)
 64c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 64e:	0005c903          	lbu	s2,0(a1)
 652:	18090f63          	beqz	s2,7f0 <vprintf+0x1c0>
 656:	8aaa                	mv	s5,a0
 658:	8b32                	mv	s6,a2
 65a:	00158493          	addi	s1,a1,1
  state = 0;
 65e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 660:	02500a13          	li	s4,37
      if(c == 'd'){
 664:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 668:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 66c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 670:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 674:	00000b97          	auipc	s7,0x0
 678:	414b8b93          	addi	s7,s7,1044 # a88 <digits>
 67c:	a839                	j	69a <vprintf+0x6a>
        putc(fd, c);
 67e:	85ca                	mv	a1,s2
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	ee2080e7          	jalr	-286(ra) # 564 <putc>
 68a:	a019                	j	690 <vprintf+0x60>
    } else if(state == '%'){
 68c:	01498f63          	beq	s3,s4,6aa <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 690:	0485                	addi	s1,s1,1
 692:	fff4c903          	lbu	s2,-1(s1)
 696:	14090d63          	beqz	s2,7f0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 69a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 69e:	fe0997e3          	bnez	s3,68c <vprintf+0x5c>
      if(c == '%'){
 6a2:	fd479ee3          	bne	a5,s4,67e <vprintf+0x4e>
        state = '%';
 6a6:	89be                	mv	s3,a5
 6a8:	b7e5                	j	690 <vprintf+0x60>
      if(c == 'd'){
 6aa:	05878063          	beq	a5,s8,6ea <vprintf+0xba>
      } else if(c == 'l') {
 6ae:	05978c63          	beq	a5,s9,706 <vprintf+0xd6>
      } else if(c == 'x') {
 6b2:	07a78863          	beq	a5,s10,722 <vprintf+0xf2>
      } else if(c == 'p') {
 6b6:	09b78463          	beq	a5,s11,73e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6ba:	07300713          	li	a4,115
 6be:	0ce78663          	beq	a5,a4,78a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6c2:	06300713          	li	a4,99
 6c6:	0ee78e63          	beq	a5,a4,7c2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6ca:	11478863          	beq	a5,s4,7da <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ce:	85d2                	mv	a1,s4
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e92080e7          	jalr	-366(ra) # 564 <putc>
        putc(fd, c);
 6da:	85ca                	mv	a1,s2
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	e86080e7          	jalr	-378(ra) # 564 <putc>
      }
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b765                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ea:	008b0913          	addi	s2,s6,8
 6ee:	4685                	li	a3,1
 6f0:	4629                	li	a2,10
 6f2:	000b2583          	lw	a1,0(s6)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e8e080e7          	jalr	-370(ra) # 586 <printint>
 700:	8b4a                	mv	s6,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	b771                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 706:	008b0913          	addi	s2,s6,8
 70a:	4681                	li	a3,0
 70c:	4629                	li	a2,10
 70e:	000b2583          	lw	a1,0(s6)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e72080e7          	jalr	-398(ra) # 586 <printint>
 71c:	8b4a                	mv	s6,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bf85                	j	690 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 722:	008b0913          	addi	s2,s6,8
 726:	4681                	li	a3,0
 728:	4641                	li	a2,16
 72a:	000b2583          	lw	a1,0(s6)
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	e56080e7          	jalr	-426(ra) # 586 <printint>
 738:	8b4a                	mv	s6,s2
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bf91                	j	690 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 73e:	008b0793          	addi	a5,s6,8
 742:	f8f43423          	sd	a5,-120(s0)
 746:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 74a:	03000593          	li	a1,48
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	e14080e7          	jalr	-492(ra) # 564 <putc>
  putc(fd, 'x');
 758:	85ea                	mv	a1,s10
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	e08080e7          	jalr	-504(ra) # 564 <putc>
 764:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 766:	03c9d793          	srli	a5,s3,0x3c
 76a:	97de                	add	a5,a5,s7
 76c:	0007c583          	lbu	a1,0(a5)
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	df2080e7          	jalr	-526(ra) # 564 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77a:	0992                	slli	s3,s3,0x4
 77c:	397d                	addiw	s2,s2,-1
 77e:	fe0914e3          	bnez	s2,766 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 782:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 786:	4981                	li	s3,0
 788:	b721                	j	690 <vprintf+0x60>
        s = va_arg(ap, char*);
 78a:	008b0993          	addi	s3,s6,8
 78e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 792:	02090163          	beqz	s2,7b4 <vprintf+0x184>
        while(*s != 0){
 796:	00094583          	lbu	a1,0(s2)
 79a:	c9a1                	beqz	a1,7ea <vprintf+0x1ba>
          putc(fd, *s);
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	dc6080e7          	jalr	-570(ra) # 564 <putc>
          s++;
 7a6:	0905                	addi	s2,s2,1
        while(*s != 0){
 7a8:	00094583          	lbu	a1,0(s2)
 7ac:	f9e5                	bnez	a1,79c <vprintf+0x16c>
        s = va_arg(ap, char*);
 7ae:	8b4e                	mv	s6,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bdf9                	j	690 <vprintf+0x60>
          s = "(null)";
 7b4:	00000917          	auipc	s2,0x0
 7b8:	2cc90913          	addi	s2,s2,716 # a80 <malloc+0x186>
        while(*s != 0){
 7bc:	02800593          	li	a1,40
 7c0:	bff1                	j	79c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7c2:	008b0913          	addi	s2,s6,8
 7c6:	000b4583          	lbu	a1,0(s6)
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	d98080e7          	jalr	-616(ra) # 564 <putc>
 7d4:	8b4a                	mv	s6,s2
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	bd65                	j	690 <vprintf+0x60>
        putc(fd, c);
 7da:	85d2                	mv	a1,s4
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	d86080e7          	jalr	-634(ra) # 564 <putc>
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	b565                	j	690 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ea:	8b4e                	mv	s6,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	b54d                	j	690 <vprintf+0x60>
    }
  }
}
 7f0:	70e6                	ld	ra,120(sp)
 7f2:	7446                	ld	s0,112(sp)
 7f4:	74a6                	ld	s1,104(sp)
 7f6:	7906                	ld	s2,96(sp)
 7f8:	69e6                	ld	s3,88(sp)
 7fa:	6a46                	ld	s4,80(sp)
 7fc:	6aa6                	ld	s5,72(sp)
 7fe:	6b06                	ld	s6,64(sp)
 800:	7be2                	ld	s7,56(sp)
 802:	7c42                	ld	s8,48(sp)
 804:	7ca2                	ld	s9,40(sp)
 806:	7d02                	ld	s10,32(sp)
 808:	6de2                	ld	s11,24(sp)
 80a:	6109                	addi	sp,sp,128
 80c:	8082                	ret

000000000000080e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 80e:	715d                	addi	sp,sp,-80
 810:	ec06                	sd	ra,24(sp)
 812:	e822                	sd	s0,16(sp)
 814:	1000                	addi	s0,sp,32
 816:	e010                	sd	a2,0(s0)
 818:	e414                	sd	a3,8(s0)
 81a:	e818                	sd	a4,16(s0)
 81c:	ec1c                	sd	a5,24(s0)
 81e:	03043023          	sd	a6,32(s0)
 822:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82a:	8622                	mv	a2,s0
 82c:	00000097          	auipc	ra,0x0
 830:	e04080e7          	jalr	-508(ra) # 630 <vprintf>
}
 834:	60e2                	ld	ra,24(sp)
 836:	6442                	ld	s0,16(sp)
 838:	6161                	addi	sp,sp,80
 83a:	8082                	ret

000000000000083c <printf>:

void
printf(const char *fmt, ...)
{
 83c:	711d                	addi	sp,sp,-96
 83e:	ec06                	sd	ra,24(sp)
 840:	e822                	sd	s0,16(sp)
 842:	1000                	addi	s0,sp,32
 844:	e40c                	sd	a1,8(s0)
 846:	e810                	sd	a2,16(s0)
 848:	ec14                	sd	a3,24(s0)
 84a:	f018                	sd	a4,32(s0)
 84c:	f41c                	sd	a5,40(s0)
 84e:	03043823          	sd	a6,48(s0)
 852:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 856:	00840613          	addi	a2,s0,8
 85a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 85e:	85aa                	mv	a1,a0
 860:	4505                	li	a0,1
 862:	00000097          	auipc	ra,0x0
 866:	dce080e7          	jalr	-562(ra) # 630 <vprintf>
}
 86a:	60e2                	ld	ra,24(sp)
 86c:	6442                	ld	s0,16(sp)
 86e:	6125                	addi	sp,sp,96
 870:	8082                	ret

0000000000000872 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 872:	1141                	addi	sp,sp,-16
 874:	e422                	sd	s0,8(sp)
 876:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 878:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87c:	00000797          	auipc	a5,0x0
 880:	2247b783          	ld	a5,548(a5) # aa0 <freep>
 884:	a805                	j	8b4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 886:	4618                	lw	a4,8(a2)
 888:	9db9                	addw	a1,a1,a4
 88a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 88e:	6398                	ld	a4,0(a5)
 890:	6318                	ld	a4,0(a4)
 892:	fee53823          	sd	a4,-16(a0)
 896:	a091                	j	8da <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 898:	ff852703          	lw	a4,-8(a0)
 89c:	9e39                	addw	a2,a2,a4
 89e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8a0:	ff053703          	ld	a4,-16(a0)
 8a4:	e398                	sd	a4,0(a5)
 8a6:	a099                	j	8ec <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	6398                	ld	a4,0(a5)
 8aa:	00e7e463          	bltu	a5,a4,8b2 <free+0x40>
 8ae:	00e6ea63          	bltu	a3,a4,8c2 <free+0x50>
{
 8b2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b4:	fed7fae3          	bgeu	a5,a3,8a8 <free+0x36>
 8b8:	6398                	ld	a4,0(a5)
 8ba:	00e6e463          	bltu	a3,a4,8c2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8be:	fee7eae3          	bltu	a5,a4,8b2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8c2:	ff852583          	lw	a1,-8(a0)
 8c6:	6390                	ld	a2,0(a5)
 8c8:	02059813          	slli	a6,a1,0x20
 8cc:	01c85713          	srli	a4,a6,0x1c
 8d0:	9736                	add	a4,a4,a3
 8d2:	fae60ae3          	beq	a2,a4,886 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8d6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8da:	4790                	lw	a2,8(a5)
 8dc:	02061593          	slli	a1,a2,0x20
 8e0:	01c5d713          	srli	a4,a1,0x1c
 8e4:	973e                	add	a4,a4,a5
 8e6:	fae689e3          	beq	a3,a4,898 <free+0x26>
  } else
    p->s.ptr = bp;
 8ea:	e394                	sd	a3,0(a5)
  freep = p;
 8ec:	00000717          	auipc	a4,0x0
 8f0:	1af73a23          	sd	a5,436(a4) # aa0 <freep>
}
 8f4:	6422                	ld	s0,8(sp)
 8f6:	0141                	addi	sp,sp,16
 8f8:	8082                	ret

00000000000008fa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fa:	7139                	addi	sp,sp,-64
 8fc:	fc06                	sd	ra,56(sp)
 8fe:	f822                	sd	s0,48(sp)
 900:	f426                	sd	s1,40(sp)
 902:	f04a                	sd	s2,32(sp)
 904:	ec4e                	sd	s3,24(sp)
 906:	e852                	sd	s4,16(sp)
 908:	e456                	sd	s5,8(sp)
 90a:	e05a                	sd	s6,0(sp)
 90c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90e:	02051493          	slli	s1,a0,0x20
 912:	9081                	srli	s1,s1,0x20
 914:	04bd                	addi	s1,s1,15
 916:	8091                	srli	s1,s1,0x4
 918:	0014899b          	addiw	s3,s1,1
 91c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91e:	00000517          	auipc	a0,0x0
 922:	18253503          	ld	a0,386(a0) # aa0 <freep>
 926:	c515                	beqz	a0,952 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 928:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92a:	4798                	lw	a4,8(a5)
 92c:	02977f63          	bgeu	a4,s1,96a <malloc+0x70>
 930:	8a4e                	mv	s4,s3
 932:	0009871b          	sext.w	a4,s3
 936:	6685                	lui	a3,0x1
 938:	00d77363          	bgeu	a4,a3,93e <malloc+0x44>
 93c:	6a05                	lui	s4,0x1
 93e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 942:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 946:	00000917          	auipc	s2,0x0
 94a:	15a90913          	addi	s2,s2,346 # aa0 <freep>
  if(p == (char*)-1)
 94e:	5afd                	li	s5,-1
 950:	a895                	j	9c4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 952:	00000797          	auipc	a5,0x0
 956:	15678793          	addi	a5,a5,342 # aa8 <base>
 95a:	00000717          	auipc	a4,0x0
 95e:	14f73323          	sd	a5,326(a4) # aa0 <freep>
 962:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 964:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 968:	b7e1                	j	930 <malloc+0x36>
      if(p->s.size == nunits)
 96a:	02e48c63          	beq	s1,a4,9a2 <malloc+0xa8>
        p->s.size -= nunits;
 96e:	4137073b          	subw	a4,a4,s3
 972:	c798                	sw	a4,8(a5)
        p += p->s.size;
 974:	02071693          	slli	a3,a4,0x20
 978:	01c6d713          	srli	a4,a3,0x1c
 97c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 982:	00000717          	auipc	a4,0x0
 986:	10a73f23          	sd	a0,286(a4) # aa0 <freep>
      return (void*)(p + 1);
 98a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 98e:	70e2                	ld	ra,56(sp)
 990:	7442                	ld	s0,48(sp)
 992:	74a2                	ld	s1,40(sp)
 994:	7902                	ld	s2,32(sp)
 996:	69e2                	ld	s3,24(sp)
 998:	6a42                	ld	s4,16(sp)
 99a:	6aa2                	ld	s5,8(sp)
 99c:	6b02                	ld	s6,0(sp)
 99e:	6121                	addi	sp,sp,64
 9a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9a2:	6398                	ld	a4,0(a5)
 9a4:	e118                	sd	a4,0(a0)
 9a6:	bff1                	j	982 <malloc+0x88>
  hp->s.size = nu;
 9a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ac:	0541                	addi	a0,a0,16
 9ae:	00000097          	auipc	ra,0x0
 9b2:	ec4080e7          	jalr	-316(ra) # 872 <free>
  return freep;
 9b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ba:	d971                	beqz	a0,98e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9be:	4798                	lw	a4,8(a5)
 9c0:	fa9775e3          	bgeu	a4,s1,96a <malloc+0x70>
    if(p == freep)
 9c4:	00093703          	ld	a4,0(s2)
 9c8:	853e                	mv	a0,a5
 9ca:	fef719e3          	bne	a4,a5,9bc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9ce:	8552                	mv	a0,s4
 9d0:	00000097          	auipc	ra,0x0
 9d4:	b7c080e7          	jalr	-1156(ra) # 54c <sbrk>
  if(p == (char*)-1)
 9d8:	fd5518e3          	bne	a0,s5,9a8 <malloc+0xae>
        return 0;
 9dc:	4501                	li	a0,0
 9de:	bf45                	j	98e <malloc+0x94>
