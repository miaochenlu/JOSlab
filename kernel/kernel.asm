
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	b1478793          	addi	a5,a5,-1260 # 80005b70 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e0278793          	addi	a5,a5,-510 # 80000ea8 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	af2080e7          	jalr	-1294(ra) # 80000bfe <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	364080e7          	jalr	868(ra) # 8000248a <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	796080e7          	jalr	1942(ra) # 800008cc <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	b64080e7          	jalr	-1180(ra) # 80000cb2 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7159                	addi	sp,sp,-112
    80000170:	f486                	sd	ra,104(sp)
    80000172:	f0a2                	sd	s0,96(sp)
    80000174:	eca6                	sd	s1,88(sp)
    80000176:	e8ca                	sd	s2,80(sp)
    80000178:	e4ce                	sd	s3,72(sp)
    8000017a:	e0d2                	sd	s4,64(sp)
    8000017c:	fc56                	sd	s5,56(sp)
    8000017e:	f85a                	sd	s6,48(sp)
    80000180:	f45e                	sd	s7,40(sp)
    80000182:	f062                	sd	s8,32(sp)
    80000184:	ec66                	sd	s9,24(sp)
    80000186:	e86a                	sd	s10,16(sp)
    80000188:	1880                	addi	s0,sp,112
    8000018a:	8aaa                	mv	s5,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000194:	00011517          	auipc	a0,0x11
    80000198:	69c50513          	addi	a0,a0,1692 # 80011830 <cons>
    8000019c:	00001097          	auipc	ra,0x1
    800001a0:	a62080e7          	jalr	-1438(ra) # 80000bfe <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a4:	00011497          	auipc	s1,0x11
    800001a8:	68c48493          	addi	s1,s1,1676 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ac:	00011917          	auipc	s2,0x11
    800001b0:	71c90913          	addi	s2,s2,1820 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b4:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b6:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b8:	4ca9                	li	s9,10
  while(n > 0){
    800001ba:	07305863          	blez	s3,8000022a <consoleread+0xbc>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	02f71463          	bne	a4,a5,800001ee <consoleread+0x80>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	800080e7          	jalr	-2048(ra) # 800019ca <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	000080e7          	jalr	ra # 800021da <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000204:	077d0563          	beq	s10,s7,8000026e <consoleread+0x100>
    cbuf = c;
    80000208:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f9f40613          	addi	a2,s0,-97
    80000212:	85d2                	mv	a1,s4
    80000214:	8556                	mv	a0,s5
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	21e080e7          	jalr	542(ra) # 80002434 <either_copyout>
    8000021e:	01850663          	beq	a0,s8,8000022a <consoleread+0xbc>
    dst++;
    80000222:	0a05                	addi	s4,s4,1
    --n;
    80000224:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000226:	f99d1ae3          	bne	s10,s9,800001ba <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	60650513          	addi	a0,a0,1542 # 80011830 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a80080e7          	jalr	-1408(ra) # 80000cb2 <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a6a080e7          	jalr	-1430(ra) # 80000cb2 <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70a6                	ld	ra,104(sp)
    80000254:	7406                	ld	s0,96(sp)
    80000256:	64e6                	ld	s1,88(sp)
    80000258:	6946                	ld	s2,80(sp)
    8000025a:	69a6                	ld	s3,72(sp)
    8000025c:	6a06                	ld	s4,64(sp)
    8000025e:	7ae2                	ld	s5,56(sp)
    80000260:	7b42                	ld	s6,48(sp)
    80000262:	7ba2                	ld	s7,40(sp)
    80000264:	7c02                	ld	s8,32(sp)
    80000266:	6ce2                	ld	s9,24(sp)
    80000268:	6d42                	ld	s10,16(sp)
    8000026a:	6165                	addi	sp,sp,112
    8000026c:	8082                	ret
      if(n < target){
    8000026e:	0009871b          	sext.w	a4,s3
    80000272:	fb677ce3          	bgeu	a4,s6,8000022a <consoleread+0xbc>
        cons.r--;
    80000276:	00011717          	auipc	a4,0x11
    8000027a:	64f72923          	sw	a5,1618(a4) # 800118c8 <cons+0x98>
    8000027e:	b775                	j	8000022a <consoleread+0xbc>

0000000080000280 <consputc>:
{
    80000280:	1141                	addi	sp,sp,-16
    80000282:	e406                	sd	ra,8(sp)
    80000284:	e022                	sd	s0,0(sp)
    80000286:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000288:	10000793          	li	a5,256
    8000028c:	00f50a63          	beq	a0,a5,800002a0 <consputc+0x20>
    uartputc_sync(c);
    80000290:	00000097          	auipc	ra,0x0
    80000294:	55e080e7          	jalr	1374(ra) # 800007ee <uartputc_sync>
}
    80000298:	60a2                	ld	ra,8(sp)
    8000029a:	6402                	ld	s0,0(sp)
    8000029c:	0141                	addi	sp,sp,16
    8000029e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a0:	4521                	li	a0,8
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	54c080e7          	jalr	1356(ra) # 800007ee <uartputc_sync>
    800002aa:	02000513          	li	a0,32
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	540080e7          	jalr	1344(ra) # 800007ee <uartputc_sync>
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	536080e7          	jalr	1334(ra) # 800007ee <uartputc_sync>
    800002c0:	bfe1                	j	80000298 <consputc+0x18>

00000000800002c2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c2:	1101                	addi	sp,sp,-32
    800002c4:	ec06                	sd	ra,24(sp)
    800002c6:	e822                	sd	s0,16(sp)
    800002c8:	e426                	sd	s1,8(sp)
    800002ca:	e04a                	sd	s2,0(sp)
    800002cc:	1000                	addi	s0,sp,32
    800002ce:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d0:	00011517          	auipc	a0,0x11
    800002d4:	56050513          	addi	a0,a0,1376 # 80011830 <cons>
    800002d8:	00001097          	auipc	ra,0x1
    800002dc:	926080e7          	jalr	-1754(ra) # 80000bfe <acquire>

  switch(c){
    800002e0:	47d5                	li	a5,21
    800002e2:	0af48663          	beq	s1,a5,8000038e <consoleintr+0xcc>
    800002e6:	0297ca63          	blt	a5,s1,8000031a <consoleintr+0x58>
    800002ea:	47a1                	li	a5,8
    800002ec:	0ef48763          	beq	s1,a5,800003da <consoleintr+0x118>
    800002f0:	47c1                	li	a5,16
    800002f2:	10f49a63          	bne	s1,a5,80000406 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f6:	00002097          	auipc	ra,0x2
    800002fa:	1ea080e7          	jalr	490(ra) # 800024e0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	9ac080e7          	jalr	-1620(ra) # 80000cb2 <release>
}
    8000030e:	60e2                	ld	ra,24(sp)
    80000310:	6442                	ld	s0,16(sp)
    80000312:	64a2                	ld	s1,8(sp)
    80000314:	6902                	ld	s2,0(sp)
    80000316:	6105                	addi	sp,sp,32
    80000318:	8082                	ret
  switch(c){
    8000031a:	07f00793          	li	a5,127
    8000031e:	0af48e63          	beq	s1,a5,800003da <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000322:	00011717          	auipc	a4,0x11
    80000326:	50e70713          	addi	a4,a4,1294 # 80011830 <cons>
    8000032a:	0a072783          	lw	a5,160(a4)
    8000032e:	09872703          	lw	a4,152(a4)
    80000332:	9f99                	subw	a5,a5,a4
    80000334:	07f00713          	li	a4,127
    80000338:	fcf763e3          	bltu	a4,a5,800002fe <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033c:	47b5                	li	a5,13
    8000033e:	0cf48763          	beq	s1,a5,8000040c <consoleintr+0x14a>
      consputc(c);
    80000342:	8526                	mv	a0,s1
    80000344:	00000097          	auipc	ra,0x0
    80000348:	f3c080e7          	jalr	-196(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034c:	00011797          	auipc	a5,0x11
    80000350:	4e478793          	addi	a5,a5,1252 # 80011830 <cons>
    80000354:	0a07a703          	lw	a4,160(a5)
    80000358:	0017069b          	addiw	a3,a4,1
    8000035c:	0006861b          	sext.w	a2,a3
    80000360:	0ad7a023          	sw	a3,160(a5)
    80000364:	07f77713          	andi	a4,a4,127
    80000368:	97ba                	add	a5,a5,a4
    8000036a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036e:	47a9                	li	a5,10
    80000370:	0cf48563          	beq	s1,a5,8000043a <consoleintr+0x178>
    80000374:	4791                	li	a5,4
    80000376:	0cf48263          	beq	s1,a5,8000043a <consoleintr+0x178>
    8000037a:	00011797          	auipc	a5,0x11
    8000037e:	54e7a783          	lw	a5,1358(a5) # 800118c8 <cons+0x98>
    80000382:	0807879b          	addiw	a5,a5,128
    80000386:	f6f61ce3          	bne	a2,a5,800002fe <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038a:	863e                	mv	a2,a5
    8000038c:	a07d                	j	8000043a <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038e:	00011717          	auipc	a4,0x11
    80000392:	4a270713          	addi	a4,a4,1186 # 80011830 <cons>
    80000396:	0a072783          	lw	a5,160(a4)
    8000039a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039e:	00011497          	auipc	s1,0x11
    800003a2:	49248493          	addi	s1,s1,1170 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a6:	4929                	li	s2,10
    800003a8:	f4f70be3          	beq	a4,a5,800002fe <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	37fd                	addiw	a5,a5,-1
    800003ae:	07f7f713          	andi	a4,a5,127
    800003b2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b4:	01874703          	lbu	a4,24(a4)
    800003b8:	f52703e3          	beq	a4,s2,800002fe <consoleintr+0x3c>
      cons.e--;
    800003bc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c0:	10000513          	li	a0,256
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	ebc080e7          	jalr	-324(ra) # 80000280 <consputc>
    while(cons.e != cons.w &&
    800003cc:	0a04a783          	lw	a5,160(s1)
    800003d0:	09c4a703          	lw	a4,156(s1)
    800003d4:	fcf71ce3          	bne	a4,a5,800003ac <consoleintr+0xea>
    800003d8:	b71d                	j	800002fe <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003da:	00011717          	auipc	a4,0x11
    800003de:	45670713          	addi	a4,a4,1110 # 80011830 <cons>
    800003e2:	0a072783          	lw	a5,160(a4)
    800003e6:	09c72703          	lw	a4,156(a4)
    800003ea:	f0f70ae3          	beq	a4,a5,800002fe <consoleintr+0x3c>
      cons.e--;
    800003ee:	37fd                	addiw	a5,a5,-1
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	4ef72023          	sw	a5,1248(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f8:	10000513          	li	a0,256
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e84080e7          	jalr	-380(ra) # 80000280 <consputc>
    80000404:	bded                	j	800002fe <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000406:	ee048ce3          	beqz	s1,800002fe <consoleintr+0x3c>
    8000040a:	bf21                	j	80000322 <consoleintr+0x60>
      consputc(c);
    8000040c:	4529                	li	a0,10
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	e72080e7          	jalr	-398(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000416:	00011797          	auipc	a5,0x11
    8000041a:	41a78793          	addi	a5,a5,1050 # 80011830 <cons>
    8000041e:	0a07a703          	lw	a4,160(a5)
    80000422:	0017069b          	addiw	a3,a4,1
    80000426:	0006861b          	sext.w	a2,a3
    8000042a:	0ad7a023          	sw	a3,160(a5)
    8000042e:	07f77713          	andi	a4,a4,127
    80000432:	97ba                	add	a5,a5,a4
    80000434:	4729                	li	a4,10
    80000436:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043a:	00011797          	auipc	a5,0x11
    8000043e:	48c7a923          	sw	a2,1170(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000442:	00011517          	auipc	a0,0x11
    80000446:	48650513          	addi	a0,a0,1158 # 800118c8 <cons+0x98>
    8000044a:	00002097          	auipc	ra,0x2
    8000044e:	f10080e7          	jalr	-240(ra) # 8000235a <wakeup>
    80000452:	b575                	j	800002fe <consoleintr+0x3c>

0000000080000454 <consoleinit>:

void
consoleinit(void)
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045c:	00008597          	auipc	a1,0x8
    80000460:	bb458593          	addi	a1,a1,-1100 # 80008010 <etext+0x10>
    80000464:	00011517          	auipc	a0,0x11
    80000468:	3cc50513          	addi	a0,a0,972 # 80011830 <cons>
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	702080e7          	jalr	1794(ra) # 80000b6e <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00021797          	auipc	a5,0x21
    80000480:	53478793          	addi	a5,a5,1332 # 800219b0 <devsw>
    80000484:	00000717          	auipc	a4,0x0
    80000488:	cea70713          	addi	a4,a4,-790 # 8000016e <consoleread>
    8000048c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048e:	00000717          	auipc	a4,0x0
    80000492:	c5e70713          	addi	a4,a4,-930 # 800000ec <consolewrite>
    80000496:	ef98                	sd	a4,24(a5)
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret

00000000800004a0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a0:	7179                	addi	sp,sp,-48
    800004a2:	f406                	sd	ra,40(sp)
    800004a4:	f022                	sd	s0,32(sp)
    800004a6:	ec26                	sd	s1,24(sp)
    800004a8:	e84a                	sd	s2,16(sp)
    800004aa:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ac:	c219                	beqz	a2,800004b2 <printint+0x12>
    800004ae:	08054663          	bltz	a0,8000053a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b2:	2501                	sext.w	a0,a0
    800004b4:	4881                	li	a7,0
    800004b6:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ba:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004bc:	2581                	sext.w	a1,a1
    800004be:	00008617          	auipc	a2,0x8
    800004c2:	b8260613          	addi	a2,a2,-1150 # 80008040 <digits>
    800004c6:	883a                	mv	a6,a4
    800004c8:	2705                	addiw	a4,a4,1
    800004ca:	02b577bb          	remuw	a5,a0,a1
    800004ce:	1782                	slli	a5,a5,0x20
    800004d0:	9381                	srli	a5,a5,0x20
    800004d2:	97b2                	add	a5,a5,a2
    800004d4:	0007c783          	lbu	a5,0(a5)
    800004d8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004dc:	0005079b          	sext.w	a5,a0
    800004e0:	02b5553b          	divuw	a0,a0,a1
    800004e4:	0685                	addi	a3,a3,1
    800004e6:	feb7f0e3          	bgeu	a5,a1,800004c6 <printint+0x26>

  if(sign)
    800004ea:	00088b63          	beqz	a7,80000500 <printint+0x60>
    buf[i++] = '-';
    800004ee:	fe040793          	addi	a5,s0,-32
    800004f2:	973e                	add	a4,a4,a5
    800004f4:	02d00793          	li	a5,45
    800004f8:	fef70823          	sb	a5,-16(a4)
    800004fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000500:	02e05763          	blez	a4,8000052e <printint+0x8e>
    80000504:	fd040793          	addi	a5,s0,-48
    80000508:	00e784b3          	add	s1,a5,a4
    8000050c:	fff78913          	addi	s2,a5,-1
    80000510:	993a                	add	s2,s2,a4
    80000512:	377d                	addiw	a4,a4,-1
    80000514:	1702                	slli	a4,a4,0x20
    80000516:	9301                	srli	a4,a4,0x20
    80000518:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051c:	fff4c503          	lbu	a0,-1(s1)
    80000520:	00000097          	auipc	ra,0x0
    80000524:	d60080e7          	jalr	-672(ra) # 80000280 <consputc>
  while(--i >= 0)
    80000528:	14fd                	addi	s1,s1,-1
    8000052a:	ff2499e3          	bne	s1,s2,8000051c <printint+0x7c>
}
    8000052e:	70a2                	ld	ra,40(sp)
    80000530:	7402                	ld	s0,32(sp)
    80000532:	64e2                	ld	s1,24(sp)
    80000534:	6942                	ld	s2,16(sp)
    80000536:	6145                	addi	sp,sp,48
    80000538:	8082                	ret
    x = -xx;
    8000053a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053e:	4885                	li	a7,1
    x = -xx;
    80000540:	bf9d                	j	800004b6 <printint+0x16>

0000000080000542 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000542:	1101                	addi	sp,sp,-32
    80000544:	ec06                	sd	ra,24(sp)
    80000546:	e822                	sd	s0,16(sp)
    80000548:	e426                	sd	s1,8(sp)
    8000054a:	1000                	addi	s0,sp,32
    8000054c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054e:	00011797          	auipc	a5,0x11
    80000552:	3a07a123          	sw	zero,930(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000556:	00008517          	auipc	a0,0x8
    8000055a:	ac250513          	addi	a0,a0,-1342 # 80008018 <etext+0x18>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	02e080e7          	jalr	46(ra) # 8000058c <printf>
  printf(s);
    80000566:	8526                	mv	a0,s1
    80000568:	00000097          	auipc	ra,0x0
    8000056c:	024080e7          	jalr	36(ra) # 8000058c <printf>
  printf("\n");
    80000570:	00008517          	auipc	a0,0x8
    80000574:	b5850513          	addi	a0,a0,-1192 # 800080c8 <digits+0x88>
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	014080e7          	jalr	20(ra) # 8000058c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000580:	4785                	li	a5,1
    80000582:	00009717          	auipc	a4,0x9
    80000586:	a6f72f23          	sw	a5,-1410(a4) # 80009000 <panicked>
  for(;;)
    8000058a:	a001                	j	8000058a <panic+0x48>

000000008000058c <printf>:
{
    8000058c:	7131                	addi	sp,sp,-192
    8000058e:	fc86                	sd	ra,120(sp)
    80000590:	f8a2                	sd	s0,112(sp)
    80000592:	f4a6                	sd	s1,104(sp)
    80000594:	f0ca                	sd	s2,96(sp)
    80000596:	ecce                	sd	s3,88(sp)
    80000598:	e8d2                	sd	s4,80(sp)
    8000059a:	e4d6                	sd	s5,72(sp)
    8000059c:	e0da                	sd	s6,64(sp)
    8000059e:	fc5e                	sd	s7,56(sp)
    800005a0:	f862                	sd	s8,48(sp)
    800005a2:	f466                	sd	s9,40(sp)
    800005a4:	f06a                	sd	s10,32(sp)
    800005a6:	ec6e                	sd	s11,24(sp)
    800005a8:	0100                	addi	s0,sp,128
    800005aa:	8a2a                	mv	s4,a0
    800005ac:	e40c                	sd	a1,8(s0)
    800005ae:	e810                	sd	a2,16(s0)
    800005b0:	ec14                	sd	a3,24(s0)
    800005b2:	f018                	sd	a4,32(s0)
    800005b4:	f41c                	sd	a5,40(s0)
    800005b6:	03043823          	sd	a6,48(s0)
    800005ba:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005be:	00011d97          	auipc	s11,0x11
    800005c2:	332dad83          	lw	s11,818(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005c6:	020d9b63          	bnez	s11,800005fc <printf+0x70>
  if (fmt == 0)
    800005ca:	040a0263          	beqz	s4,8000060e <printf+0x82>
  va_start(ap, fmt);
    800005ce:	00840793          	addi	a5,s0,8
    800005d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d6:	000a4503          	lbu	a0,0(s4)
    800005da:	14050f63          	beqz	a0,80000738 <printf+0x1ac>
    800005de:	4981                	li	s3,0
    if(c != '%'){
    800005e0:	02500a93          	li	s5,37
    switch(c){
    800005e4:	07000b93          	li	s7,112
  consputc('x');
    800005e8:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ea:	00008b17          	auipc	s6,0x8
    800005ee:	a56b0b13          	addi	s6,s6,-1450 # 80008040 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	5fa080e7          	jalr	1530(ra) # 80000bfe <acquire>
    8000060c:	bf7d                	j	800005ca <printf+0x3e>
    panic("null fmt");
    8000060e:	00008517          	auipc	a0,0x8
    80000612:	a1a50513          	addi	a0,a0,-1510 # 80008028 <etext+0x28>
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	f2c080e7          	jalr	-212(ra) # 80000542 <panic>
      consputc(c);
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	c62080e7          	jalr	-926(ra) # 80000280 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000626:	2985                	addiw	s3,s3,1
    80000628:	013a07b3          	add	a5,s4,s3
    8000062c:	0007c503          	lbu	a0,0(a5)
    80000630:	10050463          	beqz	a0,80000738 <printf+0x1ac>
    if(c != '%'){
    80000634:	ff5515e3          	bne	a0,s5,8000061e <printf+0x92>
    c = fmt[++i] & 0xff;
    80000638:	2985                	addiw	s3,s3,1
    8000063a:	013a07b3          	add	a5,s4,s3
    8000063e:	0007c783          	lbu	a5,0(a5)
    80000642:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000646:	cbed                	beqz	a5,80000738 <printf+0x1ac>
    switch(c){
    80000648:	05778a63          	beq	a5,s7,8000069c <printf+0x110>
    8000064c:	02fbf663          	bgeu	s7,a5,80000678 <printf+0xec>
    80000650:	09978863          	beq	a5,s9,800006e0 <printf+0x154>
    80000654:	07800713          	li	a4,120
    80000658:	0ce79563          	bne	a5,a4,80000722 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065c:	f8843783          	ld	a5,-120(s0)
    80000660:	00878713          	addi	a4,a5,8
    80000664:	f8e43423          	sd	a4,-120(s0)
    80000668:	4605                	li	a2,1
    8000066a:	85ea                	mv	a1,s10
    8000066c:	4388                	lw	a0,0(a5)
    8000066e:	00000097          	auipc	ra,0x0
    80000672:	e32080e7          	jalr	-462(ra) # 800004a0 <printint>
      break;
    80000676:	bf45                	j	80000626 <printf+0x9a>
    switch(c){
    80000678:	09578f63          	beq	a5,s5,80000716 <printf+0x18a>
    8000067c:	0b879363          	bne	a5,s8,80000722 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000680:	f8843783          	ld	a5,-120(s0)
    80000684:	00878713          	addi	a4,a5,8
    80000688:	f8e43423          	sd	a4,-120(s0)
    8000068c:	4605                	li	a2,1
    8000068e:	45a9                	li	a1,10
    80000690:	4388                	lw	a0,0(a5)
    80000692:	00000097          	auipc	ra,0x0
    80000696:	e0e080e7          	jalr	-498(ra) # 800004a0 <printint>
      break;
    8000069a:	b771                	j	80000626 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069c:	f8843783          	ld	a5,-120(s0)
    800006a0:	00878713          	addi	a4,a5,8
    800006a4:	f8e43423          	sd	a4,-120(s0)
    800006a8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ac:	03000513          	li	a0,48
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	bd0080e7          	jalr	-1072(ra) # 80000280 <consputc>
  consputc('x');
    800006b8:	07800513          	li	a0,120
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bc4080e7          	jalr	-1084(ra) # 80000280 <consputc>
    800006c4:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	03c95793          	srli	a5,s2,0x3c
    800006ca:	97da                	add	a5,a5,s6
    800006cc:	0007c503          	lbu	a0,0(a5)
    800006d0:	00000097          	auipc	ra,0x0
    800006d4:	bb0080e7          	jalr	-1104(ra) # 80000280 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d8:	0912                	slli	s2,s2,0x4
    800006da:	34fd                	addiw	s1,s1,-1
    800006dc:	f4ed                	bnez	s1,800006c6 <printf+0x13a>
    800006de:	b7a1                	j	80000626 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	6384                	ld	s1,0(a5)
    800006ee:	cc89                	beqz	s1,80000708 <printf+0x17c>
      for(; *s; s++)
    800006f0:	0004c503          	lbu	a0,0(s1)
    800006f4:	d90d                	beqz	a0,80000626 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b8a080e7          	jalr	-1142(ra) # 80000280 <consputc>
      for(; *s; s++)
    800006fe:	0485                	addi	s1,s1,1
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x16a>
    80000706:	b705                	j	80000626 <printf+0x9a>
        s = "(null)";
    80000708:	00008497          	auipc	s1,0x8
    8000070c:	91848493          	addi	s1,s1,-1768 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x16a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b68080e7          	jalr	-1176(ra) # 80000280 <consputc>
      break;
    80000720:	b719                	j	80000626 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b5c080e7          	jalr	-1188(ra) # 80000280 <consputc>
      consputc(c);
    8000072c:	8526                	mv	a0,s1
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b52080e7          	jalr	-1198(ra) # 80000280 <consputc>
      break;
    80000736:	bdc5                	j	80000626 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1ce>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00011517          	auipc	a0,0x11
    8000075e:	17e50513          	addi	a0,a0,382 # 800118d8 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	550080e7          	jalr	1360(ra) # 80000cb2 <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b0>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00011497          	auipc	s1,0x11
    8000077a:	16248493          	addi	s1,s1,354 # 800118d8 <pr>
    8000077e:	00008597          	auipc	a1,0x8
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80008038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	3e6080e7          	jalr	998(ra) # 80000b6e <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80008058 <digits+0x18>
    800007d6:	00011517          	auipc	a0,0x11
    800007da:	12250513          	addi	a0,a0,290 # 800118f8 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	390080e7          	jalr	912(ra) # 80000b6e <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	3b8080e7          	jalr	952(ra) # 80000bb2 <push_off>

  if(panicked){
    80000802:	00008797          	auipc	a5,0x8
    80000806:	7fe7a783          	lw	a5,2046(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0207f793          	andi	a5,a5,32
    8000081a:	dfe5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081c:	0ff4f513          	andi	a0,s1,255
    80000820:	100007b7          	lui	a5,0x10000
    80000824:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000828:	00000097          	auipc	ra,0x0
    8000082c:	42a080e7          	jalr	1066(ra) # 80000c52 <pop_off>
}
    80000830:	60e2                	ld	ra,24(sp)
    80000832:	6442                	ld	s0,16(sp)
    80000834:	64a2                	ld	s1,8(sp)
    80000836:	6105                	addi	sp,sp,32
    80000838:	8082                	ret

000000008000083a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7ca7a783          	lw	a5,1994(a5) # 80009004 <uart_tx_r>
    80000842:	00008717          	auipc	a4,0x8
    80000846:	7c672703          	lw	a4,1990(a4) # 80009008 <uart_tx_w>
    8000084a:	08f70063          	beq	a4,a5,800008ca <uartstart+0x90>
{
    8000084e:	7139                	addi	sp,sp,-64
    80000850:	fc06                	sd	ra,56(sp)
    80000852:	f822                	sd	s0,48(sp)
    80000854:	f426                	sd	s1,40(sp)
    80000856:	f04a                	sd	s2,32(sp)
    80000858:	ec4e                	sd	s3,24(sp)
    8000085a:	e852                	sd	s4,16(sp)
    8000085c:	e456                	sd	s5,8(sp)
    8000085e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000860:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000864:	00011a97          	auipc	s5,0x11
    80000868:	094a8a93          	addi	s5,s5,148 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000086c:	00008497          	auipc	s1,0x8
    80000870:	79848493          	addi	s1,s1,1944 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000874:	00008a17          	auipc	s4,0x8
    80000878:	794a0a13          	addi	s4,s4,1940 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000880:	02077713          	andi	a4,a4,32
    80000884:	cb15                	beqz	a4,800008b8 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    80000886:	00fa8733          	add	a4,s5,a5
    8000088a:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000088e:	2785                	addiw	a5,a5,1
    80000890:	41f7d71b          	sraiw	a4,a5,0x1f
    80000894:	01b7571b          	srliw	a4,a4,0x1b
    80000898:	9fb9                	addw	a5,a5,a4
    8000089a:	8bfd                	andi	a5,a5,31
    8000089c:	9f99                	subw	a5,a5,a4
    8000089e:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a0:	8526                	mv	a0,s1
    800008a2:	00002097          	auipc	ra,0x2
    800008a6:	ab8080e7          	jalr	-1352(ra) # 8000235a <wakeup>
    
    WriteReg(THR, c);
    800008aa:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ae:	409c                	lw	a5,0(s1)
    800008b0:	000a2703          	lw	a4,0(s4)
    800008b4:	fcf714e3          	bne	a4,a5,8000087c <uartstart+0x42>
  }
}
    800008b8:	70e2                	ld	ra,56(sp)
    800008ba:	7442                	ld	s0,48(sp)
    800008bc:	74a2                	ld	s1,40(sp)
    800008be:	7902                	ld	s2,32(sp)
    800008c0:	69e2                	ld	s3,24(sp)
    800008c2:	6a42                	ld	s4,16(sp)
    800008c4:	6aa2                	ld	s5,8(sp)
    800008c6:	6121                	addi	sp,sp,64
    800008c8:	8082                	ret
    800008ca:	8082                	ret

00000000800008cc <uartputc>:
{
    800008cc:	7179                	addi	sp,sp,-48
    800008ce:	f406                	sd	ra,40(sp)
    800008d0:	f022                	sd	s0,32(sp)
    800008d2:	ec26                	sd	s1,24(sp)
    800008d4:	e84a                	sd	s2,16(sp)
    800008d6:	e44e                	sd	s3,8(sp)
    800008d8:	e052                	sd	s4,0(sp)
    800008da:	1800                	addi	s0,sp,48
    800008dc:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008de:	00011517          	auipc	a0,0x11
    800008e2:	01a50513          	addi	a0,a0,26 # 800118f8 <uart_tx_lock>
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	318080e7          	jalr	792(ra) # 80000bfe <acquire>
  if(panicked){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	7127a783          	lw	a5,1810(a5) # 80009000 <panicked>
    800008f6:	c391                	beqz	a5,800008fa <uartputc+0x2e>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800008fa:	00008697          	auipc	a3,0x8
    800008fe:	70e6a683          	lw	a3,1806(a3) # 80009008 <uart_tx_w>
    80000902:	0016879b          	addiw	a5,a3,1
    80000906:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090a:	01b7571b          	srliw	a4,a4,0x1b
    8000090e:	9fb9                	addw	a5,a5,a4
    80000910:	8bfd                	andi	a5,a5,31
    80000912:	9f99                	subw	a5,a5,a4
    80000914:	00008717          	auipc	a4,0x8
    80000918:	6f072703          	lw	a4,1776(a4) # 80009004 <uart_tx_r>
    8000091c:	04f71363          	bne	a4,a5,80000962 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000920:	00011a17          	auipc	s4,0x11
    80000924:	fd8a0a13          	addi	s4,s4,-40 # 800118f8 <uart_tx_lock>
    80000928:	00008917          	auipc	s2,0x8
    8000092c:	6dc90913          	addi	s2,s2,1756 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000930:	00008997          	auipc	s3,0x8
    80000934:	6d898993          	addi	s3,s3,1752 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	85d2                	mv	a1,s4
    8000093a:	854a                	mv	a0,s2
    8000093c:	00002097          	auipc	ra,0x2
    80000940:	89e080e7          	jalr	-1890(ra) # 800021da <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	0009a683          	lw	a3,0(s3)
    80000948:	0016879b          	addiw	a5,a3,1
    8000094c:	41f7d71b          	sraiw	a4,a5,0x1f
    80000950:	01b7571b          	srliw	a4,a4,0x1b
    80000954:	9fb9                	addw	a5,a5,a4
    80000956:	8bfd                	andi	a5,a5,31
    80000958:	9f99                	subw	a5,a5,a4
    8000095a:	00092703          	lw	a4,0(s2)
    8000095e:	fcf70de3          	beq	a4,a5,80000938 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000962:	00011917          	auipc	s2,0x11
    80000966:	f9690913          	addi	s2,s2,-106 # 800118f8 <uart_tx_lock>
    8000096a:	96ca                	add	a3,a3,s2
    8000096c:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000970:	00008717          	auipc	a4,0x8
    80000974:	68f72c23          	sw	a5,1688(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000978:	00000097          	auipc	ra,0x0
    8000097c:	ec2080e7          	jalr	-318(ra) # 8000083a <uartstart>
      release(&uart_tx_lock);
    80000980:	854a                	mv	a0,s2
    80000982:	00000097          	auipc	ra,0x0
    80000986:	330080e7          	jalr	816(ra) # 80000cb2 <release>
}
    8000098a:	70a2                	ld	ra,40(sp)
    8000098c:	7402                	ld	s0,32(sp)
    8000098e:	64e2                	ld	s1,24(sp)
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
    80000994:	6a02                	ld	s4,0(sp)
    80000996:	6145                	addi	sp,sp,48
    80000998:	8082                	ret

000000008000099a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000099a:	1141                	addi	sp,sp,-16
    8000099c:	e422                	sd	s0,8(sp)
    8000099e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a0:	100007b7          	lui	a5,0x10000
    800009a4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a8:	8b85                	andi	a5,a5,1
    800009aa:	cb91                	beqz	a5,800009be <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ac:	100007b7          	lui	a5,0x10000
    800009b0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009b4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009b8:	6422                	ld	s0,8(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret
    return -1;
    800009be:	557d                	li	a0,-1
    800009c0:	bfe5                	j	800009b8 <uartgetc+0x1e>

00000000800009c2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c2:	1101                	addi	sp,sp,-32
    800009c4:	ec06                	sd	ra,24(sp)
    800009c6:	e822                	sd	s0,16(sp)
    800009c8:	e426                	sd	s1,8(sp)
    800009ca:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009cc:	54fd                	li	s1,-1
    800009ce:	a029                	j	800009d8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	8f2080e7          	jalr	-1806(ra) # 800002c2 <consoleintr>
    int c = uartgetc();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	fc2080e7          	jalr	-62(ra) # 8000099a <uartgetc>
    if(c == -1)
    800009e0:	fe9518e3          	bne	a0,s1,800009d0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009e4:	00011497          	auipc	s1,0x11
    800009e8:	f1448493          	addi	s1,s1,-236 # 800118f8 <uart_tx_lock>
    800009ec:	8526                	mv	a0,s1
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	210080e7          	jalr	528(ra) # 80000bfe <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e44080e7          	jalr	-444(ra) # 8000083a <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	2b2080e7          	jalr	690(ra) # 80000cb2 <release>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret

0000000080000a12 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a12:	1101                	addi	sp,sp,-32
    80000a14:	ec06                	sd	ra,24(sp)
    80000a16:	e822                	sd	s0,16(sp)
    80000a18:	e426                	sd	s1,8(sp)
    80000a1a:	e04a                	sd	s2,0(sp)
    80000a1c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03451793          	slli	a5,a0,0x34
    80000a22:	ebb9                	bnez	a5,80000a78 <kfree+0x66>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00025797          	auipc	a5,0x25
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80026000 <end>
    80000a2e:	04f56563          	bltu	a0,a5,80000a78 <kfree+0x66>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	04f57163          	bgeu	a0,a5,80000a78 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	4585                	li	a1,1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	2bc080e7          	jalr	700(ra) # 80000cfa <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a46:	00011917          	auipc	s2,0x11
    80000a4a:	eea90913          	addi	s2,s2,-278 # 80011930 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	1ae080e7          	jalr	430(ra) # 80000bfe <acquire>
  r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	24e080e7          	jalr	590(ra) # 80000cb2 <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6902                	ld	s2,0(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kfree");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5e850513          	addi	a0,a0,1512 # 80008060 <digits+0x20>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ac2080e7          	jalr	-1342(ra) # 80000542 <panic>

0000000080000a88 <freerange>:
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	e052                	sd	s4,0(sp)
    80000a96:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a98:	6785                	lui	a5,0x1
    80000a9a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a9e:	94aa                	add	s1,s1,a0
    80000aa0:	757d                	lui	a0,0xfffff
    80000aa2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa4:	94be                	add	s1,s1,a5
    80000aa6:	0095ee63          	bltu	a1,s1,80000ac2 <freerange+0x3a>
    80000aaa:	892e                	mv	s2,a1
    kfree(p);
    80000aac:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aae:	6985                	lui	s3,0x1
    kfree(p);
    80000ab0:	01448533          	add	a0,s1,s4
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	f5e080e7          	jalr	-162(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abc:	94ce                	add	s1,s1,s3
    80000abe:	fe9979e3          	bgeu	s2,s1,80000ab0 <freerange+0x28>
}
    80000ac2:	70a2                	ld	ra,40(sp)
    80000ac4:	7402                	ld	s0,32(sp)
    80000ac6:	64e2                	ld	s1,24(sp)
    80000ac8:	6942                	ld	s2,16(sp)
    80000aca:	69a2                	ld	s3,8(sp)
    80000acc:	6a02                	ld	s4,0(sp)
    80000ace:	6145                	addi	sp,sp,48
    80000ad0:	8082                	ret

0000000080000ad2 <kinit>:
{
    80000ad2:	1141                	addi	sp,sp,-16
    80000ad4:	e406                	sd	ra,8(sp)
    80000ad6:	e022                	sd	s0,0(sp)
    80000ad8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ada:	00007597          	auipc	a1,0x7
    80000ade:	58e58593          	addi	a1,a1,1422 # 80008068 <digits+0x28>
    80000ae2:	00011517          	auipc	a0,0x11
    80000ae6:	e4e50513          	addi	a0,a0,-434 # 80011930 <kmem>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	084080e7          	jalr	132(ra) # 80000b6e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af2:	45c5                	li	a1,17
    80000af4:	05ee                	slli	a1,a1,0x1b
    80000af6:	00025517          	auipc	a0,0x25
    80000afa:	50a50513          	addi	a0,a0,1290 # 80026000 <end>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f8a080e7          	jalr	-118(ra) # 80000a88 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00011497          	auipc	s1,0x11
    80000b1c:	e1848493          	addi	s1,s1,-488 # 80011930 <kmem>
    80000b20:	8526                	mv	a0,s1
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	0dc080e7          	jalr	220(ra) # 80000bfe <acquire>
  r = kmem.freelist;
    80000b2a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b2c:	c885                	beqz	s1,80000b5c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00011517          	auipc	a0,0x11
    80000b34:	e0050513          	addi	a0,a0,-512 # 80011930 <kmem>
    80000b38:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	178080e7          	jalr	376(ra) # 80000cb2 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b42:	6605                	lui	a2,0x1
    80000b44:	4595                	li	a1,5
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	1b2080e7          	jalr	434(ra) # 80000cfa <memset>
  return (void*)r;
}
    80000b50:	8526                	mv	a0,s1
    80000b52:	60e2                	ld	ra,24(sp)
    80000b54:	6442                	ld	s0,16(sp)
    80000b56:	64a2                	ld	s1,8(sp)
    80000b58:	6105                	addi	sp,sp,32
    80000b5a:	8082                	ret
  release(&kmem.lock);
    80000b5c:	00011517          	auipc	a0,0x11
    80000b60:	dd450513          	addi	a0,a0,-556 # 80011930 <kmem>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	14e080e7          	jalr	334(ra) # 80000cb2 <release>
  if(r)
    80000b6c:	b7d5                	j	80000b50 <kalloc+0x42>

0000000080000b6e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b6e:	1141                	addi	sp,sp,-16
    80000b70:	e422                	sd	s0,8(sp)
    80000b72:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b74:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b76:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b7a:	00053823          	sd	zero,16(a0)
}
    80000b7e:	6422                	ld	s0,8(sp)
    80000b80:	0141                	addi	sp,sp,16
    80000b82:	8082                	ret

0000000080000b84 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b84:	411c                	lw	a5,0(a0)
    80000b86:	e399                	bnez	a5,80000b8c <holding+0x8>
    80000b88:	4501                	li	a0,0
  return r;
}
    80000b8a:	8082                	ret
{
    80000b8c:	1101                	addi	sp,sp,-32
    80000b8e:	ec06                	sd	ra,24(sp)
    80000b90:	e822                	sd	s0,16(sp)
    80000b92:	e426                	sd	s1,8(sp)
    80000b94:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	6904                	ld	s1,16(a0)
    80000b98:	00001097          	auipc	ra,0x1
    80000b9c:	e16080e7          	jalr	-490(ra) # 800019ae <mycpu>
    80000ba0:	40a48533          	sub	a0,s1,a0
    80000ba4:	00153513          	seqz	a0,a0
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret

0000000080000bb2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb2:	1101                	addi	sp,sp,-32
    80000bb4:	ec06                	sd	ra,24(sp)
    80000bb6:	e822                	sd	s0,16(sp)
    80000bb8:	e426                	sd	s1,8(sp)
    80000bba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbc:	100024f3          	csrr	s1,sstatus
    80000bc0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc6:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bca:	00001097          	auipc	ra,0x1
    80000bce:	de4080e7          	jalr	-540(ra) # 800019ae <mycpu>
    80000bd2:	5d3c                	lw	a5,120(a0)
    80000bd4:	cf89                	beqz	a5,80000bee <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd6:	00001097          	auipc	ra,0x1
    80000bda:	dd8080e7          	jalr	-552(ra) # 800019ae <mycpu>
    80000bde:	5d3c                	lw	a5,120(a0)
    80000be0:	2785                	addiw	a5,a5,1
    80000be2:	dd3c                	sw	a5,120(a0)
}
    80000be4:	60e2                	ld	ra,24(sp)
    80000be6:	6442                	ld	s0,16(sp)
    80000be8:	64a2                	ld	s1,8(sp)
    80000bea:	6105                	addi	sp,sp,32
    80000bec:	8082                	ret
    mycpu()->intena = old;
    80000bee:	00001097          	auipc	ra,0x1
    80000bf2:	dc0080e7          	jalr	-576(ra) # 800019ae <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bf6:	8085                	srli	s1,s1,0x1
    80000bf8:	8885                	andi	s1,s1,1
    80000bfa:	dd64                	sw	s1,124(a0)
    80000bfc:	bfe9                	j	80000bd6 <push_off+0x24>

0000000080000bfe <acquire>:
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c0a:	00000097          	auipc	ra,0x0
    80000c0e:	fa8080e7          	jalr	-88(ra) # 80000bb2 <push_off>
  if(holding(lk))
    80000c12:	8526                	mv	a0,s1
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	f70080e7          	jalr	-144(ra) # 80000b84 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c1c:	4705                	li	a4,1
  if(holding(lk))
    80000c1e:	e115                	bnez	a0,80000c42 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c20:	87ba                	mv	a5,a4
    80000c22:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c26:	2781                	sext.w	a5,a5
    80000c28:	ffe5                	bnez	a5,80000c20 <acquire+0x22>
  __sync_synchronize();
    80000c2a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d80080e7          	jalr	-640(ra) # 800019ae <mycpu>
    80000c36:	e888                	sd	a0,16(s1)
}
    80000c38:	60e2                	ld	ra,24(sp)
    80000c3a:	6442                	ld	s0,16(sp)
    80000c3c:	64a2                	ld	s1,8(sp)
    80000c3e:	6105                	addi	sp,sp,32
    80000c40:	8082                	ret
    panic("acquire");
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	42e50513          	addi	a0,a0,1070 # 80008070 <digits+0x30>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	8f8080e7          	jalr	-1800(ra) # 80000542 <panic>

0000000080000c52 <pop_off>:

void
pop_off(void)
{
    80000c52:	1141                	addi	sp,sp,-16
    80000c54:	e406                	sd	ra,8(sp)
    80000c56:	e022                	sd	s0,0(sp)
    80000c58:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c5a:	00001097          	auipc	ra,0x1
    80000c5e:	d54080e7          	jalr	-684(ra) # 800019ae <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c62:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c66:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c68:	e78d                	bnez	a5,80000c92 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c6a:	5d3c                	lw	a5,120(a0)
    80000c6c:	02f05b63          	blez	a5,80000ca2 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c70:	37fd                	addiw	a5,a5,-1
    80000c72:	0007871b          	sext.w	a4,a5
    80000c76:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c78:	eb09                	bnez	a4,80000c8a <pop_off+0x38>
    80000c7a:	5d7c                	lw	a5,124(a0)
    80000c7c:	c799                	beqz	a5,80000c8a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c86:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c8a:	60a2                	ld	ra,8(sp)
    80000c8c:	6402                	ld	s0,0(sp)
    80000c8e:	0141                	addi	sp,sp,16
    80000c90:	8082                	ret
    panic("pop_off - interruptible");
    80000c92:	00007517          	auipc	a0,0x7
    80000c96:	3e650513          	addi	a0,a0,998 # 80008078 <digits+0x38>
    80000c9a:	00000097          	auipc	ra,0x0
    80000c9e:	8a8080e7          	jalr	-1880(ra) # 80000542 <panic>
    panic("pop_off");
    80000ca2:	00007517          	auipc	a0,0x7
    80000ca6:	3ee50513          	addi	a0,a0,1006 # 80008090 <digits+0x50>
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	898080e7          	jalr	-1896(ra) # 80000542 <panic>

0000000080000cb2 <release>:
{
    80000cb2:	1101                	addi	sp,sp,-32
    80000cb4:	ec06                	sd	ra,24(sp)
    80000cb6:	e822                	sd	s0,16(sp)
    80000cb8:	e426                	sd	s1,8(sp)
    80000cba:	1000                	addi	s0,sp,32
    80000cbc:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	ec6080e7          	jalr	-314(ra) # 80000b84 <holding>
    80000cc6:	c115                	beqz	a0,80000cea <release+0x38>
  lk->cpu = 0;
    80000cc8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ccc:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cd0:	0f50000f          	fence	iorw,ow
    80000cd4:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	f7a080e7          	jalr	-134(ra) # 80000c52 <pop_off>
}
    80000ce0:	60e2                	ld	ra,24(sp)
    80000ce2:	6442                	ld	s0,16(sp)
    80000ce4:	64a2                	ld	s1,8(sp)
    80000ce6:	6105                	addi	sp,sp,32
    80000ce8:	8082                	ret
    panic("release");
    80000cea:	00007517          	auipc	a0,0x7
    80000cee:	3ae50513          	addi	a0,a0,942 # 80008098 <digits+0x58>
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	850080e7          	jalr	-1968(ra) # 80000542 <panic>

0000000080000cfa <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cfa:	1141                	addi	sp,sp,-16
    80000cfc:	e422                	sd	s0,8(sp)
    80000cfe:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d00:	ca19                	beqz	a2,80000d16 <memset+0x1c>
    80000d02:	87aa                	mv	a5,a0
    80000d04:	1602                	slli	a2,a2,0x20
    80000d06:	9201                	srli	a2,a2,0x20
    80000d08:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d0c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d10:	0785                	addi	a5,a5,1
    80000d12:	fee79de3          	bne	a5,a4,80000d0c <memset+0x12>
  }
  return dst;
}
    80000d16:	6422                	ld	s0,8(sp)
    80000d18:	0141                	addi	sp,sp,16
    80000d1a:	8082                	ret

0000000080000d1c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d1c:	1141                	addi	sp,sp,-16
    80000d1e:	e422                	sd	s0,8(sp)
    80000d20:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d22:	ca05                	beqz	a2,80000d52 <memcmp+0x36>
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	1682                	slli	a3,a3,0x20
    80000d2a:	9281                	srli	a3,a3,0x20
    80000d2c:	0685                	addi	a3,a3,1
    80000d2e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d30:	00054783          	lbu	a5,0(a0)
    80000d34:	0005c703          	lbu	a4,0(a1)
    80000d38:	00e79863          	bne	a5,a4,80000d48 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d3c:	0505                	addi	a0,a0,1
    80000d3e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d40:	fed518e3          	bne	a0,a3,80000d30 <memcmp+0x14>
  }

  return 0;
    80000d44:	4501                	li	a0,0
    80000d46:	a019                	j	80000d4c <memcmp+0x30>
      return *s1 - *s2;
    80000d48:	40e7853b          	subw	a0,a5,a4
}
    80000d4c:	6422                	ld	s0,8(sp)
    80000d4e:	0141                	addi	sp,sp,16
    80000d50:	8082                	ret
  return 0;
    80000d52:	4501                	li	a0,0
    80000d54:	bfe5                	j	80000d4c <memcmp+0x30>

0000000080000d56 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d5c:	02a5e563          	bltu	a1,a0,80000d86 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6069b          	addiw	a3,a2,-1
    80000d64:	ce11                	beqz	a2,80000d80 <memmove+0x2a>
    80000d66:	1682                	slli	a3,a3,0x20
    80000d68:	9281                	srli	a3,a3,0x20
    80000d6a:	0685                	addi	a3,a3,1
    80000d6c:	96ae                	add	a3,a3,a1
    80000d6e:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	0785                	addi	a5,a5,1
    80000d74:	fff5c703          	lbu	a4,-1(a1)
    80000d78:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d7c:	fed59ae3          	bne	a1,a3,80000d70 <memmove+0x1a>

  return dst;
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret
  if(s < d && s + n > d){
    80000d86:	02061713          	slli	a4,a2,0x20
    80000d8a:	9301                	srli	a4,a4,0x20
    80000d8c:	00e587b3          	add	a5,a1,a4
    80000d90:	fcf578e3          	bgeu	a0,a5,80000d60 <memmove+0xa>
    d += n;
    80000d94:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d96:	fff6069b          	addiw	a3,a2,-1
    80000d9a:	d27d                	beqz	a2,80000d80 <memmove+0x2a>
    80000d9c:	02069613          	slli	a2,a3,0x20
    80000da0:	9201                	srli	a2,a2,0x20
    80000da2:	fff64613          	not	a2,a2
    80000da6:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000da8:	17fd                	addi	a5,a5,-1
    80000daa:	177d                	addi	a4,a4,-1
    80000dac:	0007c683          	lbu	a3,0(a5)
    80000db0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000db4:	fef61ae3          	bne	a2,a5,80000da8 <memmove+0x52>
    80000db8:	b7e1                	j	80000d80 <memmove+0x2a>

0000000080000dba <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dba:	1141                	addi	sp,sp,-16
    80000dbc:	e406                	sd	ra,8(sp)
    80000dbe:	e022                	sd	s0,0(sp)
    80000dc0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc2:	00000097          	auipc	ra,0x0
    80000dc6:	f94080e7          	jalr	-108(ra) # 80000d56 <memmove>
}
    80000dca:	60a2                	ld	ra,8(sp)
    80000dcc:	6402                	ld	s0,0(sp)
    80000dce:	0141                	addi	sp,sp,16
    80000dd0:	8082                	ret

0000000080000dd2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dd8:	ce11                	beqz	a2,80000df4 <strncmp+0x22>
    80000dda:	00054783          	lbu	a5,0(a0)
    80000dde:	cf89                	beqz	a5,80000df8 <strncmp+0x26>
    80000de0:	0005c703          	lbu	a4,0(a1)
    80000de4:	00f71a63          	bne	a4,a5,80000df8 <strncmp+0x26>
    n--, p++, q++;
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	0505                	addi	a0,a0,1
    80000dec:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dee:	f675                	bnez	a2,80000dda <strncmp+0x8>
  if(n == 0)
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	a809                	j	80000e04 <strncmp+0x32>
    80000df4:	4501                	li	a0,0
    80000df6:	a039                	j	80000e04 <strncmp+0x32>
  if(n == 0)
    80000df8:	ca09                	beqz	a2,80000e0a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dfa:	00054503          	lbu	a0,0(a0)
    80000dfe:	0005c783          	lbu	a5,0(a1)
    80000e02:	9d1d                	subw	a0,a0,a5
}
    80000e04:	6422                	ld	s0,8(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret
    return 0;
    80000e0a:	4501                	li	a0,0
    80000e0c:	bfe5                	j	80000e04 <strncmp+0x32>

0000000080000e0e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e0e:	1141                	addi	sp,sp,-16
    80000e10:	e422                	sd	s0,8(sp)
    80000e12:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e14:	872a                	mv	a4,a0
    80000e16:	8832                	mv	a6,a2
    80000e18:	367d                	addiw	a2,a2,-1
    80000e1a:	01005963          	blez	a6,80000e2c <strncpy+0x1e>
    80000e1e:	0705                	addi	a4,a4,1
    80000e20:	0005c783          	lbu	a5,0(a1)
    80000e24:	fef70fa3          	sb	a5,-1(a4)
    80000e28:	0585                	addi	a1,a1,1
    80000e2a:	f7f5                	bnez	a5,80000e16 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e2c:	86ba                	mv	a3,a4
    80000e2e:	00c05c63          	blez	a2,80000e46 <strncpy+0x38>
    *s++ = 0;
    80000e32:	0685                	addi	a3,a3,1
    80000e34:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e38:	fff6c793          	not	a5,a3
    80000e3c:	9fb9                	addw	a5,a5,a4
    80000e3e:	010787bb          	addw	a5,a5,a6
    80000e42:	fef048e3          	bgtz	a5,80000e32 <strncpy+0x24>
  return os;
}
    80000e46:	6422                	ld	s0,8(sp)
    80000e48:	0141                	addi	sp,sp,16
    80000e4a:	8082                	ret

0000000080000e4c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e422                	sd	s0,8(sp)
    80000e50:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e52:	02c05363          	blez	a2,80000e78 <safestrcpy+0x2c>
    80000e56:	fff6069b          	addiw	a3,a2,-1
    80000e5a:	1682                	slli	a3,a3,0x20
    80000e5c:	9281                	srli	a3,a3,0x20
    80000e5e:	96ae                	add	a3,a3,a1
    80000e60:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e62:	00d58963          	beq	a1,a3,80000e74 <safestrcpy+0x28>
    80000e66:	0585                	addi	a1,a1,1
    80000e68:	0785                	addi	a5,a5,1
    80000e6a:	fff5c703          	lbu	a4,-1(a1)
    80000e6e:	fee78fa3          	sb	a4,-1(a5)
    80000e72:	fb65                	bnez	a4,80000e62 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e74:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e78:	6422                	ld	s0,8(sp)
    80000e7a:	0141                	addi	sp,sp,16
    80000e7c:	8082                	ret

0000000080000e7e <strlen>:

int
strlen(const char *s)
{
    80000e7e:	1141                	addi	sp,sp,-16
    80000e80:	e422                	sd	s0,8(sp)
    80000e82:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e84:	00054783          	lbu	a5,0(a0)
    80000e88:	cf91                	beqz	a5,80000ea4 <strlen+0x26>
    80000e8a:	0505                	addi	a0,a0,1
    80000e8c:	87aa                	mv	a5,a0
    80000e8e:	4685                	li	a3,1
    80000e90:	9e89                	subw	a3,a3,a0
    80000e92:	00f6853b          	addw	a0,a3,a5
    80000e96:	0785                	addi	a5,a5,1
    80000e98:	fff7c703          	lbu	a4,-1(a5)
    80000e9c:	fb7d                	bnez	a4,80000e92 <strlen+0x14>
    ;
  return n;
}
    80000e9e:	6422                	ld	s0,8(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ea4:	4501                	li	a0,0
    80000ea6:	bfe5                	j	80000e9e <strlen+0x20>

0000000080000ea8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e406                	sd	ra,8(sp)
    80000eac:	e022                	sd	s0,0(sp)
    80000eae:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb0:	00001097          	auipc	ra,0x1
    80000eb4:	aee080e7          	jalr	-1298(ra) # 8000199e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eb8:	00008717          	auipc	a4,0x8
    80000ebc:	15470713          	addi	a4,a4,340 # 8000900c <started>
  if(cpuid() == 0){
    80000ec0:	c139                	beqz	a0,80000f06 <main+0x5e>
    while(started == 0)
    80000ec2:	431c                	lw	a5,0(a4)
    80000ec4:	2781                	sext.w	a5,a5
    80000ec6:	dff5                	beqz	a5,80000ec2 <main+0x1a>
      ;
    __sync_synchronize();
    80000ec8:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ecc:	00001097          	auipc	ra,0x1
    80000ed0:	ad2080e7          	jalr	-1326(ra) # 8000199e <cpuid>
    80000ed4:	85aa                	mv	a1,a0
    80000ed6:	00007517          	auipc	a0,0x7
    80000eda:	1e250513          	addi	a0,a0,482 # 800080b8 <digits+0x78>
    80000ede:	fffff097          	auipc	ra,0xfffff
    80000ee2:	6ae080e7          	jalr	1710(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000ee6:	00000097          	auipc	ra,0x0
    80000eea:	0d8080e7          	jalr	216(ra) # 80000fbe <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eee:	00001097          	auipc	ra,0x1
    80000ef2:	734080e7          	jalr	1844(ra) # 80002622 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ef6:	00005097          	auipc	ra,0x5
    80000efa:	cba080e7          	jalr	-838(ra) # 80005bb0 <plicinithart>
  }

  scheduler();        
    80000efe:	00001097          	auipc	ra,0x1
    80000f02:	000080e7          	jalr	ra # 80001efe <scheduler>
    consoleinit();
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	54e080e7          	jalr	1358(ra) # 80000454 <consoleinit>
    printfinit();
    80000f0e:	00000097          	auipc	ra,0x0
    80000f12:	85e080e7          	jalr	-1954(ra) # 8000076c <printfinit>
    printf("\n");
    80000f16:	00007517          	auipc	a0,0x7
    80000f1a:	1b250513          	addi	a0,a0,434 # 800080c8 <digits+0x88>
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	66e080e7          	jalr	1646(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f26:	00007517          	auipc	a0,0x7
    80000f2a:	17a50513          	addi	a0,a0,378 # 800080a0 <digits+0x60>
    80000f2e:	fffff097          	auipc	ra,0xfffff
    80000f32:	65e080e7          	jalr	1630(ra) # 8000058c <printf>
    printf("\n");
    80000f36:	00007517          	auipc	a0,0x7
    80000f3a:	19250513          	addi	a0,a0,402 # 800080c8 <digits+0x88>
    80000f3e:	fffff097          	auipc	ra,0xfffff
    80000f42:	64e080e7          	jalr	1614(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000f46:	00000097          	auipc	ra,0x0
    80000f4a:	b8c080e7          	jalr	-1140(ra) # 80000ad2 <kinit>
    kvminit();       // create kernel page table
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	2a0080e7          	jalr	672(ra) # 800011ee <kvminit>
    kvminithart();   // turn on paging
    80000f56:	00000097          	auipc	ra,0x0
    80000f5a:	068080e7          	jalr	104(ra) # 80000fbe <kvminithart>
    procinit();      // process table
    80000f5e:	00001097          	auipc	ra,0x1
    80000f62:	970080e7          	jalr	-1680(ra) # 800018ce <procinit>
    trapinit();      // trap vectors
    80000f66:	00001097          	auipc	ra,0x1
    80000f6a:	694080e7          	jalr	1684(ra) # 800025fa <trapinit>
    trapinithart();  // install kernel trap vector
    80000f6e:	00001097          	auipc	ra,0x1
    80000f72:	6b4080e7          	jalr	1716(ra) # 80002622 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f76:	00005097          	auipc	ra,0x5
    80000f7a:	c24080e7          	jalr	-988(ra) # 80005b9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f7e:	00005097          	auipc	ra,0x5
    80000f82:	c32080e7          	jalr	-974(ra) # 80005bb0 <plicinithart>
    binit();         // buffer cache
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	ddc080e7          	jalr	-548(ra) # 80002d62 <binit>
    iinit();         // inode cache
    80000f8e:	00002097          	auipc	ra,0x2
    80000f92:	46e080e7          	jalr	1134(ra) # 800033fc <iinit>
    fileinit();      // file table
    80000f96:	00003097          	auipc	ra,0x3
    80000f9a:	40c080e7          	jalr	1036(ra) # 800043a2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f9e:	00005097          	auipc	ra,0x5
    80000fa2:	d1a080e7          	jalr	-742(ra) # 80005cb8 <virtio_disk_init>
    userinit();      // first user process
    80000fa6:	00001097          	auipc	ra,0x1
    80000faa:	cee080e7          	jalr	-786(ra) # 80001c94 <userinit>
    __sync_synchronize();
    80000fae:	0ff0000f          	fence
    started = 1;
    80000fb2:	4785                	li	a5,1
    80000fb4:	00008717          	auipc	a4,0x8
    80000fb8:	04f72c23          	sw	a5,88(a4) # 8000900c <started>
    80000fbc:	b789                	j	80000efe <main+0x56>

0000000080000fbe <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fbe:	1141                	addi	sp,sp,-16
    80000fc0:	e422                	sd	s0,8(sp)
    80000fc2:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fc4:	00008797          	auipc	a5,0x8
    80000fc8:	04c7b783          	ld	a5,76(a5) # 80009010 <kernel_pagetable>
    80000fcc:	83b1                	srli	a5,a5,0xc
    80000fce:	577d                	li	a4,-1
    80000fd0:	177e                	slli	a4,a4,0x3f
    80000fd2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fd4:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fd8:	12000073          	sfence.vma
  sfence_vma();
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret

0000000080000fe2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fe2:	7139                	addi	sp,sp,-64
    80000fe4:	fc06                	sd	ra,56(sp)
    80000fe6:	f822                	sd	s0,48(sp)
    80000fe8:	f426                	sd	s1,40(sp)
    80000fea:	f04a                	sd	s2,32(sp)
    80000fec:	ec4e                	sd	s3,24(sp)
    80000fee:	e852                	sd	s4,16(sp)
    80000ff0:	e456                	sd	s5,8(sp)
    80000ff2:	e05a                	sd	s6,0(sp)
    80000ff4:	0080                	addi	s0,sp,64
    80000ff6:	84aa                	mv	s1,a0
    80000ff8:	89ae                	mv	s3,a1
    80000ffa:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ffc:	57fd                	li	a5,-1
    80000ffe:	83e9                	srli	a5,a5,0x1a
    80001000:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001002:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001004:	04b7f263          	bgeu	a5,a1,80001048 <walk+0x66>
    panic("walk");
    80001008:	00007517          	auipc	a0,0x7
    8000100c:	0c850513          	addi	a0,a0,200 # 800080d0 <digits+0x90>
    80001010:	fffff097          	auipc	ra,0xfffff
    80001014:	532080e7          	jalr	1330(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001018:	060a8663          	beqz	s5,80001084 <walk+0xa2>
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	af2080e7          	jalr	-1294(ra) # 80000b0e <kalloc>
    80001024:	84aa                	mv	s1,a0
    80001026:	c529                	beqz	a0,80001070 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001028:	6605                	lui	a2,0x1
    8000102a:	4581                	li	a1,0
    8000102c:	00000097          	auipc	ra,0x0
    80001030:	cce080e7          	jalr	-818(ra) # 80000cfa <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001034:	00c4d793          	srli	a5,s1,0xc
    80001038:	07aa                	slli	a5,a5,0xa
    8000103a:	0017e793          	ori	a5,a5,1
    8000103e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001042:	3a5d                	addiw	s4,s4,-9
    80001044:	036a0063          	beq	s4,s6,80001064 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001048:	0149d933          	srl	s2,s3,s4
    8000104c:	1ff97913          	andi	s2,s2,511
    80001050:	090e                	slli	s2,s2,0x3
    80001052:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001054:	00093483          	ld	s1,0(s2)
    80001058:	0014f793          	andi	a5,s1,1
    8000105c:	dfd5                	beqz	a5,80001018 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000105e:	80a9                	srli	s1,s1,0xa
    80001060:	04b2                	slli	s1,s1,0xc
    80001062:	b7c5                	j	80001042 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001064:	00c9d513          	srli	a0,s3,0xc
    80001068:	1ff57513          	andi	a0,a0,511
    8000106c:	050e                	slli	a0,a0,0x3
    8000106e:	9526                	add	a0,a0,s1
}
    80001070:	70e2                	ld	ra,56(sp)
    80001072:	7442                	ld	s0,48(sp)
    80001074:	74a2                	ld	s1,40(sp)
    80001076:	7902                	ld	s2,32(sp)
    80001078:	69e2                	ld	s3,24(sp)
    8000107a:	6a42                	ld	s4,16(sp)
    8000107c:	6aa2                	ld	s5,8(sp)
    8000107e:	6b02                	ld	s6,0(sp)
    80001080:	6121                	addi	sp,sp,64
    80001082:	8082                	ret
        return 0;
    80001084:	4501                	li	a0,0
    80001086:	b7ed                	j	80001070 <walk+0x8e>

0000000080001088 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001088:	57fd                	li	a5,-1
    8000108a:	83e9                	srli	a5,a5,0x1a
    8000108c:	00b7f463          	bgeu	a5,a1,80001094 <walkaddr+0xc>
    return 0;
    80001090:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001092:	8082                	ret
{
    80001094:	1141                	addi	sp,sp,-16
    80001096:	e406                	sd	ra,8(sp)
    80001098:	e022                	sd	s0,0(sp)
    8000109a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000109c:	4601                	li	a2,0
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	f44080e7          	jalr	-188(ra) # 80000fe2 <walk>
  if(pte == 0)
    800010a6:	c105                	beqz	a0,800010c6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010a8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010aa:	0117f693          	andi	a3,a5,17
    800010ae:	4745                	li	a4,17
    return 0;
    800010b0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010b2:	00e68663          	beq	a3,a4,800010be <walkaddr+0x36>
}
    800010b6:	60a2                	ld	ra,8(sp)
    800010b8:	6402                	ld	s0,0(sp)
    800010ba:	0141                	addi	sp,sp,16
    800010bc:	8082                	ret
  pa = PTE2PA(*pte);
    800010be:	00a7d513          	srli	a0,a5,0xa
    800010c2:	0532                	slli	a0,a0,0xc
  return pa;
    800010c4:	bfcd                	j	800010b6 <walkaddr+0x2e>
    return 0;
    800010c6:	4501                	li	a0,0
    800010c8:	b7fd                	j	800010b6 <walkaddr+0x2e>

00000000800010ca <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010ca:	1101                	addi	sp,sp,-32
    800010cc:	ec06                	sd	ra,24(sp)
    800010ce:	e822                	sd	s0,16(sp)
    800010d0:	e426                	sd	s1,8(sp)
    800010d2:	1000                	addi	s0,sp,32
    800010d4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010d6:	1552                	slli	a0,a0,0x34
    800010d8:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010dc:	4601                	li	a2,0
    800010de:	00008517          	auipc	a0,0x8
    800010e2:	f3253503          	ld	a0,-206(a0) # 80009010 <kernel_pagetable>
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	efc080e7          	jalr	-260(ra) # 80000fe2 <walk>
  if(pte == 0)
    800010ee:	cd09                	beqz	a0,80001108 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    800010f0:	6108                	ld	a0,0(a0)
    800010f2:	00157793          	andi	a5,a0,1
    800010f6:	c38d                	beqz	a5,80001118 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    800010f8:	8129                	srli	a0,a0,0xa
    800010fa:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    800010fc:	9526                	add	a0,a0,s1
    800010fe:	60e2                	ld	ra,24(sp)
    80001100:	6442                	ld	s0,16(sp)
    80001102:	64a2                	ld	s1,8(sp)
    80001104:	6105                	addi	sp,sp,32
    80001106:	8082                	ret
    panic("kvmpa");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fd050513          	addi	a0,a0,-48 # 800080d8 <digits+0x98>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	432080e7          	jalr	1074(ra) # 80000542 <panic>
    panic("kvmpa");
    80001118:	00007517          	auipc	a0,0x7
    8000111c:	fc050513          	addi	a0,a0,-64 # 800080d8 <digits+0x98>
    80001120:	fffff097          	auipc	ra,0xfffff
    80001124:	422080e7          	jalr	1058(ra) # 80000542 <panic>

0000000080001128 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001128:	715d                	addi	sp,sp,-80
    8000112a:	e486                	sd	ra,72(sp)
    8000112c:	e0a2                	sd	s0,64(sp)
    8000112e:	fc26                	sd	s1,56(sp)
    80001130:	f84a                	sd	s2,48(sp)
    80001132:	f44e                	sd	s3,40(sp)
    80001134:	f052                	sd	s4,32(sp)
    80001136:	ec56                	sd	s5,24(sp)
    80001138:	e85a                	sd	s6,16(sp)
    8000113a:	e45e                	sd	s7,8(sp)
    8000113c:	0880                	addi	s0,sp,80
    8000113e:	8aaa                	mv	s5,a0
    80001140:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001142:	777d                	lui	a4,0xfffff
    80001144:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001148:	167d                	addi	a2,a2,-1
    8000114a:	00b609b3          	add	s3,a2,a1
    8000114e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001152:	893e                	mv	s2,a5
    80001154:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001158:	6b85                	lui	s7,0x1
    8000115a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115e:	4605                	li	a2,1
    80001160:	85ca                	mv	a1,s2
    80001162:	8556                	mv	a0,s5
    80001164:	00000097          	auipc	ra,0x0
    80001168:	e7e080e7          	jalr	-386(ra) # 80000fe2 <walk>
    8000116c:	c51d                	beqz	a0,8000119a <mappages+0x72>
    if(*pte & PTE_V)
    8000116e:	611c                	ld	a5,0(a0)
    80001170:	8b85                	andi	a5,a5,1
    80001172:	ef81                	bnez	a5,8000118a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001174:	80b1                	srli	s1,s1,0xc
    80001176:	04aa                	slli	s1,s1,0xa
    80001178:	0164e4b3          	or	s1,s1,s6
    8000117c:	0014e493          	ori	s1,s1,1
    80001180:	e104                	sd	s1,0(a0)
    if(a == last)
    80001182:	03390863          	beq	s2,s3,800011b2 <mappages+0x8a>
    a += PGSIZE;
    80001186:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001188:	bfc9                	j	8000115a <mappages+0x32>
      panic("remap");
    8000118a:	00007517          	auipc	a0,0x7
    8000118e:	f5650513          	addi	a0,a0,-170 # 800080e0 <digits+0xa0>
    80001192:	fffff097          	auipc	ra,0xfffff
    80001196:	3b0080e7          	jalr	944(ra) # 80000542 <panic>
      return -1;
    8000119a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000119c:	60a6                	ld	ra,72(sp)
    8000119e:	6406                	ld	s0,64(sp)
    800011a0:	74e2                	ld	s1,56(sp)
    800011a2:	7942                	ld	s2,48(sp)
    800011a4:	79a2                	ld	s3,40(sp)
    800011a6:	7a02                	ld	s4,32(sp)
    800011a8:	6ae2                	ld	s5,24(sp)
    800011aa:	6b42                	ld	s6,16(sp)
    800011ac:	6ba2                	ld	s7,8(sp)
    800011ae:	6161                	addi	sp,sp,80
    800011b0:	8082                	ret
  return 0;
    800011b2:	4501                	li	a0,0
    800011b4:	b7e5                	j	8000119c <mappages+0x74>

00000000800011b6 <kvmmap>:
{
    800011b6:	1141                	addi	sp,sp,-16
    800011b8:	e406                	sd	ra,8(sp)
    800011ba:	e022                	sd	s0,0(sp)
    800011bc:	0800                	addi	s0,sp,16
    800011be:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011c0:	86ae                	mv	a3,a1
    800011c2:	85aa                	mv	a1,a0
    800011c4:	00008517          	auipc	a0,0x8
    800011c8:	e4c53503          	ld	a0,-436(a0) # 80009010 <kernel_pagetable>
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f5c080e7          	jalr	-164(ra) # 80001128 <mappages>
    800011d4:	e509                	bnez	a0,800011de <kvmmap+0x28>
}
    800011d6:	60a2                	ld	ra,8(sp)
    800011d8:	6402                	ld	s0,0(sp)
    800011da:	0141                	addi	sp,sp,16
    800011dc:	8082                	ret
    panic("kvmmap");
    800011de:	00007517          	auipc	a0,0x7
    800011e2:	f0a50513          	addi	a0,a0,-246 # 800080e8 <digits+0xa8>
    800011e6:	fffff097          	auipc	ra,0xfffff
    800011ea:	35c080e7          	jalr	860(ra) # 80000542 <panic>

00000000800011ee <kvminit>:
{
    800011ee:	1101                	addi	sp,sp,-32
    800011f0:	ec06                	sd	ra,24(sp)
    800011f2:	e822                	sd	s0,16(sp)
    800011f4:	e426                	sd	s1,8(sp)
    800011f6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	916080e7          	jalr	-1770(ra) # 80000b0e <kalloc>
    80001200:	00008797          	auipc	a5,0x8
    80001204:	e0a7b823          	sd	a0,-496(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001208:	6605                	lui	a2,0x1
    8000120a:	4581                	li	a1,0
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	aee080e7          	jalr	-1298(ra) # 80000cfa <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001214:	4699                	li	a3,6
    80001216:	6605                	lui	a2,0x1
    80001218:	100005b7          	lui	a1,0x10000
    8000121c:	10000537          	lui	a0,0x10000
    80001220:	00000097          	auipc	ra,0x0
    80001224:	f96080e7          	jalr	-106(ra) # 800011b6 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001228:	4699                	li	a3,6
    8000122a:	6605                	lui	a2,0x1
    8000122c:	100015b7          	lui	a1,0x10001
    80001230:	10001537          	lui	a0,0x10001
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f82080e7          	jalr	-126(ra) # 800011b6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000123c:	4699                	li	a3,6
    8000123e:	6641                	lui	a2,0x10
    80001240:	020005b7          	lui	a1,0x2000
    80001244:	02000537          	lui	a0,0x2000
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f6e080e7          	jalr	-146(ra) # 800011b6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001250:	4699                	li	a3,6
    80001252:	00400637          	lui	a2,0x400
    80001256:	0c0005b7          	lui	a1,0xc000
    8000125a:	0c000537          	lui	a0,0xc000
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f58080e7          	jalr	-168(ra) # 800011b6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001266:	00007497          	auipc	s1,0x7
    8000126a:	d9a48493          	addi	s1,s1,-614 # 80008000 <etext>
    8000126e:	46a9                	li	a3,10
    80001270:	80007617          	auipc	a2,0x80007
    80001274:	d9060613          	addi	a2,a2,-624 # 8000 <_entry-0x7fff8000>
    80001278:	4585                	li	a1,1
    8000127a:	05fe                	slli	a1,a1,0x1f
    8000127c:	852e                	mv	a0,a1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f38080e7          	jalr	-200(ra) # 800011b6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001286:	4699                	li	a3,6
    80001288:	4645                	li	a2,17
    8000128a:	066e                	slli	a2,a2,0x1b
    8000128c:	8e05                	sub	a2,a2,s1
    8000128e:	85a6                	mv	a1,s1
    80001290:	8526                	mv	a0,s1
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f24080e7          	jalr	-220(ra) # 800011b6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000129a:	46a9                	li	a3,10
    8000129c:	6605                	lui	a2,0x1
    8000129e:	00006597          	auipc	a1,0x6
    800012a2:	d6258593          	addi	a1,a1,-670 # 80007000 <_trampoline>
    800012a6:	04000537          	lui	a0,0x4000
    800012aa:	157d                	addi	a0,a0,-1
    800012ac:	0532                	slli	a0,a0,0xc
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f08080e7          	jalr	-248(ra) # 800011b6 <kvmmap>
}
    800012b6:	60e2                	ld	ra,24(sp)
    800012b8:	6442                	ld	s0,16(sp)
    800012ba:	64a2                	ld	s1,8(sp)
    800012bc:	6105                	addi	sp,sp,32
    800012be:	8082                	ret

00000000800012c0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012c0:	715d                	addi	sp,sp,-80
    800012c2:	e486                	sd	ra,72(sp)
    800012c4:	e0a2                	sd	s0,64(sp)
    800012c6:	fc26                	sd	s1,56(sp)
    800012c8:	f84a                	sd	s2,48(sp)
    800012ca:	f44e                	sd	s3,40(sp)
    800012cc:	f052                	sd	s4,32(sp)
    800012ce:	ec56                	sd	s5,24(sp)
    800012d0:	e85a                	sd	s6,16(sp)
    800012d2:	e45e                	sd	s7,8(sp)
    800012d4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012d6:	03459793          	slli	a5,a1,0x34
    800012da:	e795                	bnez	a5,80001306 <uvmunmap+0x46>
    800012dc:	8a2a                	mv	s4,a0
    800012de:	892e                	mv	s2,a1
    800012e0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e2:	0632                	slli	a2,a2,0xc
    800012e4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ea:	6b05                	lui	s6,0x1
    800012ec:	0735e263          	bltu	a1,s3,80001350 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012f0:	60a6                	ld	ra,72(sp)
    800012f2:	6406                	ld	s0,64(sp)
    800012f4:	74e2                	ld	s1,56(sp)
    800012f6:	7942                	ld	s2,48(sp)
    800012f8:	79a2                	ld	s3,40(sp)
    800012fa:	7a02                	ld	s4,32(sp)
    800012fc:	6ae2                	ld	s5,24(sp)
    800012fe:	6b42                	ld	s6,16(sp)
    80001300:	6ba2                	ld	s7,8(sp)
    80001302:	6161                	addi	sp,sp,80
    80001304:	8082                	ret
    panic("uvmunmap: not aligned");
    80001306:	00007517          	auipc	a0,0x7
    8000130a:	dea50513          	addi	a0,a0,-534 # 800080f0 <digits+0xb0>
    8000130e:	fffff097          	auipc	ra,0xfffff
    80001312:	234080e7          	jalr	564(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001316:	00007517          	auipc	a0,0x7
    8000131a:	df250513          	addi	a0,a0,-526 # 80008108 <digits+0xc8>
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	224080e7          	jalr	548(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001326:	00007517          	auipc	a0,0x7
    8000132a:	df250513          	addi	a0,a0,-526 # 80008118 <digits+0xd8>
    8000132e:	fffff097          	auipc	ra,0xfffff
    80001332:	214080e7          	jalr	532(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001336:	00007517          	auipc	a0,0x7
    8000133a:	dfa50513          	addi	a0,a0,-518 # 80008130 <digits+0xf0>
    8000133e:	fffff097          	auipc	ra,0xfffff
    80001342:	204080e7          	jalr	516(ra) # 80000542 <panic>
    *pte = 0;
    80001346:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134a:	995a                	add	s2,s2,s6
    8000134c:	fb3972e3          	bgeu	s2,s3,800012f0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001350:	4601                	li	a2,0
    80001352:	85ca                	mv	a1,s2
    80001354:	8552                	mv	a0,s4
    80001356:	00000097          	auipc	ra,0x0
    8000135a:	c8c080e7          	jalr	-884(ra) # 80000fe2 <walk>
    8000135e:	84aa                	mv	s1,a0
    80001360:	d95d                	beqz	a0,80001316 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001362:	6108                	ld	a0,0(a0)
    80001364:	00157793          	andi	a5,a0,1
    80001368:	dfdd                	beqz	a5,80001326 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000136a:	3ff57793          	andi	a5,a0,1023
    8000136e:	fd7784e3          	beq	a5,s7,80001336 <uvmunmap+0x76>
    if(do_free){
    80001372:	fc0a8ae3          	beqz	s5,80001346 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001376:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001378:	0532                	slli	a0,a0,0xc
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	698080e7          	jalr	1688(ra) # 80000a12 <kfree>
    80001382:	b7d1                	j	80001346 <uvmunmap+0x86>

0000000080001384 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001384:	1101                	addi	sp,sp,-32
    80001386:	ec06                	sd	ra,24(sp)
    80001388:	e822                	sd	s0,16(sp)
    8000138a:	e426                	sd	s1,8(sp)
    8000138c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	780080e7          	jalr	1920(ra) # 80000b0e <kalloc>
    80001396:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001398:	c519                	beqz	a0,800013a6 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000139a:	6605                	lui	a2,0x1
    8000139c:	4581                	li	a1,0
    8000139e:	00000097          	auipc	ra,0x0
    800013a2:	95c080e7          	jalr	-1700(ra) # 80000cfa <memset>
  return pagetable;
}
    800013a6:	8526                	mv	a0,s1
    800013a8:	60e2                	ld	ra,24(sp)
    800013aa:	6442                	ld	s0,16(sp)
    800013ac:	64a2                	ld	s1,8(sp)
    800013ae:	6105                	addi	sp,sp,32
    800013b0:	8082                	ret

00000000800013b2 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013b2:	7179                	addi	sp,sp,-48
    800013b4:	f406                	sd	ra,40(sp)
    800013b6:	f022                	sd	s0,32(sp)
    800013b8:	ec26                	sd	s1,24(sp)
    800013ba:	e84a                	sd	s2,16(sp)
    800013bc:	e44e                	sd	s3,8(sp)
    800013be:	e052                	sd	s4,0(sp)
    800013c0:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013c2:	6785                	lui	a5,0x1
    800013c4:	04f67863          	bgeu	a2,a5,80001414 <uvminit+0x62>
    800013c8:	8a2a                	mv	s4,a0
    800013ca:	89ae                	mv	s3,a1
    800013cc:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013ce:	fffff097          	auipc	ra,0xfffff
    800013d2:	740080e7          	jalr	1856(ra) # 80000b0e <kalloc>
    800013d6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013d8:	6605                	lui	a2,0x1
    800013da:	4581                	li	a1,0
    800013dc:	00000097          	auipc	ra,0x0
    800013e0:	91e080e7          	jalr	-1762(ra) # 80000cfa <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013e4:	4779                	li	a4,30
    800013e6:	86ca                	mv	a3,s2
    800013e8:	6605                	lui	a2,0x1
    800013ea:	4581                	li	a1,0
    800013ec:	8552                	mv	a0,s4
    800013ee:	00000097          	auipc	ra,0x0
    800013f2:	d3a080e7          	jalr	-710(ra) # 80001128 <mappages>
  memmove(mem, src, sz);
    800013f6:	8626                	mv	a2,s1
    800013f8:	85ce                	mv	a1,s3
    800013fa:	854a                	mv	a0,s2
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	95a080e7          	jalr	-1702(ra) # 80000d56 <memmove>
}
    80001404:	70a2                	ld	ra,40(sp)
    80001406:	7402                	ld	s0,32(sp)
    80001408:	64e2                	ld	s1,24(sp)
    8000140a:	6942                	ld	s2,16(sp)
    8000140c:	69a2                	ld	s3,8(sp)
    8000140e:	6a02                	ld	s4,0(sp)
    80001410:	6145                	addi	sp,sp,48
    80001412:	8082                	ret
    panic("inituvm: more than a page");
    80001414:	00007517          	auipc	a0,0x7
    80001418:	d3450513          	addi	a0,a0,-716 # 80008148 <digits+0x108>
    8000141c:	fffff097          	auipc	ra,0xfffff
    80001420:	126080e7          	jalr	294(ra) # 80000542 <panic>

0000000080001424 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001424:	1101                	addi	sp,sp,-32
    80001426:	ec06                	sd	ra,24(sp)
    80001428:	e822                	sd	s0,16(sp)
    8000142a:	e426                	sd	s1,8(sp)
    8000142c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000142e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001430:	00b67d63          	bgeu	a2,a1,8000144a <uvmdealloc+0x26>
    80001434:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001436:	6785                	lui	a5,0x1
    80001438:	17fd                	addi	a5,a5,-1
    8000143a:	00f60733          	add	a4,a2,a5
    8000143e:	767d                	lui	a2,0xfffff
    80001440:	8f71                	and	a4,a4,a2
    80001442:	97ae                	add	a5,a5,a1
    80001444:	8ff1                	and	a5,a5,a2
    80001446:	00f76863          	bltu	a4,a5,80001456 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000144a:	8526                	mv	a0,s1
    8000144c:	60e2                	ld	ra,24(sp)
    8000144e:	6442                	ld	s0,16(sp)
    80001450:	64a2                	ld	s1,8(sp)
    80001452:	6105                	addi	sp,sp,32
    80001454:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001456:	8f99                	sub	a5,a5,a4
    80001458:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000145a:	4685                	li	a3,1
    8000145c:	0007861b          	sext.w	a2,a5
    80001460:	85ba                	mv	a1,a4
    80001462:	00000097          	auipc	ra,0x0
    80001466:	e5e080e7          	jalr	-418(ra) # 800012c0 <uvmunmap>
    8000146a:	b7c5                	j	8000144a <uvmdealloc+0x26>

000000008000146c <uvmalloc>:
  if(newsz < oldsz)
    8000146c:	0ab66163          	bltu	a2,a1,8000150e <uvmalloc+0xa2>
{
    80001470:	7139                	addi	sp,sp,-64
    80001472:	fc06                	sd	ra,56(sp)
    80001474:	f822                	sd	s0,48(sp)
    80001476:	f426                	sd	s1,40(sp)
    80001478:	f04a                	sd	s2,32(sp)
    8000147a:	ec4e                	sd	s3,24(sp)
    8000147c:	e852                	sd	s4,16(sp)
    8000147e:	e456                	sd	s5,8(sp)
    80001480:	0080                	addi	s0,sp,64
    80001482:	8aaa                	mv	s5,a0
    80001484:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001486:	6985                	lui	s3,0x1
    80001488:	19fd                	addi	s3,s3,-1
    8000148a:	95ce                	add	a1,a1,s3
    8000148c:	79fd                	lui	s3,0xfffff
    8000148e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001492:	08c9f063          	bgeu	s3,a2,80001512 <uvmalloc+0xa6>
    80001496:	894e                	mv	s2,s3
    mem = kalloc();
    80001498:	fffff097          	auipc	ra,0xfffff
    8000149c:	676080e7          	jalr	1654(ra) # 80000b0e <kalloc>
    800014a0:	84aa                	mv	s1,a0
    if(mem == 0){
    800014a2:	c51d                	beqz	a0,800014d0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014a4:	6605                	lui	a2,0x1
    800014a6:	4581                	li	a1,0
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	852080e7          	jalr	-1966(ra) # 80000cfa <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014b0:	4779                	li	a4,30
    800014b2:	86a6                	mv	a3,s1
    800014b4:	6605                	lui	a2,0x1
    800014b6:	85ca                	mv	a1,s2
    800014b8:	8556                	mv	a0,s5
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	c6e080e7          	jalr	-914(ra) # 80001128 <mappages>
    800014c2:	e905                	bnez	a0,800014f2 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014c4:	6785                	lui	a5,0x1
    800014c6:	993e                	add	s2,s2,a5
    800014c8:	fd4968e3          	bltu	s2,s4,80001498 <uvmalloc+0x2c>
  return newsz;
    800014cc:	8552                	mv	a0,s4
    800014ce:	a809                	j	800014e0 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014d0:	864e                	mv	a2,s3
    800014d2:	85ca                	mv	a1,s2
    800014d4:	8556                	mv	a0,s5
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	f4e080e7          	jalr	-178(ra) # 80001424 <uvmdealloc>
      return 0;
    800014de:	4501                	li	a0,0
}
    800014e0:	70e2                	ld	ra,56(sp)
    800014e2:	7442                	ld	s0,48(sp)
    800014e4:	74a2                	ld	s1,40(sp)
    800014e6:	7902                	ld	s2,32(sp)
    800014e8:	69e2                	ld	s3,24(sp)
    800014ea:	6a42                	ld	s4,16(sp)
    800014ec:	6aa2                	ld	s5,8(sp)
    800014ee:	6121                	addi	sp,sp,64
    800014f0:	8082                	ret
      kfree(mem);
    800014f2:	8526                	mv	a0,s1
    800014f4:	fffff097          	auipc	ra,0xfffff
    800014f8:	51e080e7          	jalr	1310(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014fc:	864e                	mv	a2,s3
    800014fe:	85ca                	mv	a1,s2
    80001500:	8556                	mv	a0,s5
    80001502:	00000097          	auipc	ra,0x0
    80001506:	f22080e7          	jalr	-222(ra) # 80001424 <uvmdealloc>
      return 0;
    8000150a:	4501                	li	a0,0
    8000150c:	bfd1                	j	800014e0 <uvmalloc+0x74>
    return oldsz;
    8000150e:	852e                	mv	a0,a1
}
    80001510:	8082                	ret
  return newsz;
    80001512:	8532                	mv	a0,a2
    80001514:	b7f1                	j	800014e0 <uvmalloc+0x74>

0000000080001516 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001516:	7179                	addi	sp,sp,-48
    80001518:	f406                	sd	ra,40(sp)
    8000151a:	f022                	sd	s0,32(sp)
    8000151c:	ec26                	sd	s1,24(sp)
    8000151e:	e84a                	sd	s2,16(sp)
    80001520:	e44e                	sd	s3,8(sp)
    80001522:	e052                	sd	s4,0(sp)
    80001524:	1800                	addi	s0,sp,48
    80001526:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001528:	84aa                	mv	s1,a0
    8000152a:	6905                	lui	s2,0x1
    8000152c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000152e:	4985                	li	s3,1
    80001530:	a821                	j	80001548 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001532:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001534:	0532                	slli	a0,a0,0xc
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	fe0080e7          	jalr	-32(ra) # 80001516 <freewalk>
      pagetable[i] = 0;
    8000153e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001542:	04a1                	addi	s1,s1,8
    80001544:	03248163          	beq	s1,s2,80001566 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001548:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000154a:	00f57793          	andi	a5,a0,15
    8000154e:	ff3782e3          	beq	a5,s3,80001532 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001552:	8905                	andi	a0,a0,1
    80001554:	d57d                	beqz	a0,80001542 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001556:	00007517          	auipc	a0,0x7
    8000155a:	c1250513          	addi	a0,a0,-1006 # 80008168 <digits+0x128>
    8000155e:	fffff097          	auipc	ra,0xfffff
    80001562:	fe4080e7          	jalr	-28(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    80001566:	8552                	mv	a0,s4
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	4aa080e7          	jalr	1194(ra) # 80000a12 <kfree>
}
    80001570:	70a2                	ld	ra,40(sp)
    80001572:	7402                	ld	s0,32(sp)
    80001574:	64e2                	ld	s1,24(sp)
    80001576:	6942                	ld	s2,16(sp)
    80001578:	69a2                	ld	s3,8(sp)
    8000157a:	6a02                	ld	s4,0(sp)
    8000157c:	6145                	addi	sp,sp,48
    8000157e:	8082                	ret

0000000080001580 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001580:	1101                	addi	sp,sp,-32
    80001582:	ec06                	sd	ra,24(sp)
    80001584:	e822                	sd	s0,16(sp)
    80001586:	e426                	sd	s1,8(sp)
    80001588:	1000                	addi	s0,sp,32
    8000158a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000158c:	e999                	bnez	a1,800015a2 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000158e:	8526                	mv	a0,s1
    80001590:	00000097          	auipc	ra,0x0
    80001594:	f86080e7          	jalr	-122(ra) # 80001516 <freewalk>
}
    80001598:	60e2                	ld	ra,24(sp)
    8000159a:	6442                	ld	s0,16(sp)
    8000159c:	64a2                	ld	s1,8(sp)
    8000159e:	6105                	addi	sp,sp,32
    800015a0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015a2:	6605                	lui	a2,0x1
    800015a4:	167d                	addi	a2,a2,-1
    800015a6:	962e                	add	a2,a2,a1
    800015a8:	4685                	li	a3,1
    800015aa:	8231                	srli	a2,a2,0xc
    800015ac:	4581                	li	a1,0
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	d12080e7          	jalr	-750(ra) # 800012c0 <uvmunmap>
    800015b6:	bfe1                	j	8000158e <uvmfree+0xe>

00000000800015b8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015b8:	c679                	beqz	a2,80001686 <uvmcopy+0xce>
{
    800015ba:	715d                	addi	sp,sp,-80
    800015bc:	e486                	sd	ra,72(sp)
    800015be:	e0a2                	sd	s0,64(sp)
    800015c0:	fc26                	sd	s1,56(sp)
    800015c2:	f84a                	sd	s2,48(sp)
    800015c4:	f44e                	sd	s3,40(sp)
    800015c6:	f052                	sd	s4,32(sp)
    800015c8:	ec56                	sd	s5,24(sp)
    800015ca:	e85a                	sd	s6,16(sp)
    800015cc:	e45e                	sd	s7,8(sp)
    800015ce:	0880                	addi	s0,sp,80
    800015d0:	8b2a                	mv	s6,a0
    800015d2:	8aae                	mv	s5,a1
    800015d4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015d6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015d8:	4601                	li	a2,0
    800015da:	85ce                	mv	a1,s3
    800015dc:	855a                	mv	a0,s6
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	a04080e7          	jalr	-1532(ra) # 80000fe2 <walk>
    800015e6:	c531                	beqz	a0,80001632 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015e8:	6118                	ld	a4,0(a0)
    800015ea:	00177793          	andi	a5,a4,1
    800015ee:	cbb1                	beqz	a5,80001642 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015f0:	00a75593          	srli	a1,a4,0xa
    800015f4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015f8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	512080e7          	jalr	1298(ra) # 80000b0e <kalloc>
    80001604:	892a                	mv	s2,a0
    80001606:	c939                	beqz	a0,8000165c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001608:	6605                	lui	a2,0x1
    8000160a:	85de                	mv	a1,s7
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	74a080e7          	jalr	1866(ra) # 80000d56 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001614:	8726                	mv	a4,s1
    80001616:	86ca                	mv	a3,s2
    80001618:	6605                	lui	a2,0x1
    8000161a:	85ce                	mv	a1,s3
    8000161c:	8556                	mv	a0,s5
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	b0a080e7          	jalr	-1270(ra) # 80001128 <mappages>
    80001626:	e515                	bnez	a0,80001652 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	6785                	lui	a5,0x1
    8000162a:	99be                	add	s3,s3,a5
    8000162c:	fb49e6e3          	bltu	s3,s4,800015d8 <uvmcopy+0x20>
    80001630:	a081                	j	80001670 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001632:	00007517          	auipc	a0,0x7
    80001636:	b4650513          	addi	a0,a0,-1210 # 80008178 <digits+0x138>
    8000163a:	fffff097          	auipc	ra,0xfffff
    8000163e:	f08080e7          	jalr	-248(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b5650513          	addi	a0,a0,-1194 # 80008198 <digits+0x158>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	ef8080e7          	jalr	-264(ra) # 80000542 <panic>
      kfree(mem);
    80001652:	854a                	mv	a0,s2
    80001654:	fffff097          	auipc	ra,0xfffff
    80001658:	3be080e7          	jalr	958(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000165c:	4685                	li	a3,1
    8000165e:	00c9d613          	srli	a2,s3,0xc
    80001662:	4581                	li	a1,0
    80001664:	8556                	mv	a0,s5
    80001666:	00000097          	auipc	ra,0x0
    8000166a:	c5a080e7          	jalr	-934(ra) # 800012c0 <uvmunmap>
  return -1;
    8000166e:	557d                	li	a0,-1
}
    80001670:	60a6                	ld	ra,72(sp)
    80001672:	6406                	ld	s0,64(sp)
    80001674:	74e2                	ld	s1,56(sp)
    80001676:	7942                	ld	s2,48(sp)
    80001678:	79a2                	ld	s3,40(sp)
    8000167a:	7a02                	ld	s4,32(sp)
    8000167c:	6ae2                	ld	s5,24(sp)
    8000167e:	6b42                	ld	s6,16(sp)
    80001680:	6ba2                	ld	s7,8(sp)
    80001682:	6161                	addi	sp,sp,80
    80001684:	8082                	ret
  return 0;
    80001686:	4501                	li	a0,0
}
    80001688:	8082                	ret

000000008000168a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000168a:	1141                	addi	sp,sp,-16
    8000168c:	e406                	sd	ra,8(sp)
    8000168e:	e022                	sd	s0,0(sp)
    80001690:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001692:	4601                	li	a2,0
    80001694:	00000097          	auipc	ra,0x0
    80001698:	94e080e7          	jalr	-1714(ra) # 80000fe2 <walk>
  if(pte == 0)
    8000169c:	c901                	beqz	a0,800016ac <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000169e:	611c                	ld	a5,0(a0)
    800016a0:	9bbd                	andi	a5,a5,-17
    800016a2:	e11c                	sd	a5,0(a0)
}
    800016a4:	60a2                	ld	ra,8(sp)
    800016a6:	6402                	ld	s0,0(sp)
    800016a8:	0141                	addi	sp,sp,16
    800016aa:	8082                	ret
    panic("uvmclear");
    800016ac:	00007517          	auipc	a0,0x7
    800016b0:	b0c50513          	addi	a0,a0,-1268 # 800081b8 <digits+0x178>
    800016b4:	fffff097          	auipc	ra,0xfffff
    800016b8:	e8e080e7          	jalr	-370(ra) # 80000542 <panic>

00000000800016bc <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016bc:	c6bd                	beqz	a3,8000172a <copyout+0x6e>
{
    800016be:	715d                	addi	sp,sp,-80
    800016c0:	e486                	sd	ra,72(sp)
    800016c2:	e0a2                	sd	s0,64(sp)
    800016c4:	fc26                	sd	s1,56(sp)
    800016c6:	f84a                	sd	s2,48(sp)
    800016c8:	f44e                	sd	s3,40(sp)
    800016ca:	f052                	sd	s4,32(sp)
    800016cc:	ec56                	sd	s5,24(sp)
    800016ce:	e85a                	sd	s6,16(sp)
    800016d0:	e45e                	sd	s7,8(sp)
    800016d2:	e062                	sd	s8,0(sp)
    800016d4:	0880                	addi	s0,sp,80
    800016d6:	8b2a                	mv	s6,a0
    800016d8:	8c2e                	mv	s8,a1
    800016da:	8a32                	mv	s4,a2
    800016dc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016de:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016e0:	6a85                	lui	s5,0x1
    800016e2:	a015                	j	80001706 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016e4:	9562                	add	a0,a0,s8
    800016e6:	0004861b          	sext.w	a2,s1
    800016ea:	85d2                	mv	a1,s4
    800016ec:	41250533          	sub	a0,a0,s2
    800016f0:	fffff097          	auipc	ra,0xfffff
    800016f4:	666080e7          	jalr	1638(ra) # 80000d56 <memmove>

    len -= n;
    800016f8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016fc:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016fe:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001702:	02098263          	beqz	s3,80001726 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001706:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000170a:	85ca                	mv	a1,s2
    8000170c:	855a                	mv	a0,s6
    8000170e:	00000097          	auipc	ra,0x0
    80001712:	97a080e7          	jalr	-1670(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    80001716:	cd01                	beqz	a0,8000172e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001718:	418904b3          	sub	s1,s2,s8
    8000171c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000171e:	fc99f3e3          	bgeu	s3,s1,800016e4 <copyout+0x28>
    80001722:	84ce                	mv	s1,s3
    80001724:	b7c1                	j	800016e4 <copyout+0x28>
  }
  return 0;
    80001726:	4501                	li	a0,0
    80001728:	a021                	j	80001730 <copyout+0x74>
    8000172a:	4501                	li	a0,0
}
    8000172c:	8082                	ret
      return -1;
    8000172e:	557d                	li	a0,-1
}
    80001730:	60a6                	ld	ra,72(sp)
    80001732:	6406                	ld	s0,64(sp)
    80001734:	74e2                	ld	s1,56(sp)
    80001736:	7942                	ld	s2,48(sp)
    80001738:	79a2                	ld	s3,40(sp)
    8000173a:	7a02                	ld	s4,32(sp)
    8000173c:	6ae2                	ld	s5,24(sp)
    8000173e:	6b42                	ld	s6,16(sp)
    80001740:	6ba2                	ld	s7,8(sp)
    80001742:	6c02                	ld	s8,0(sp)
    80001744:	6161                	addi	sp,sp,80
    80001746:	8082                	ret

0000000080001748 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001748:	caa5                	beqz	a3,800017b8 <copyin+0x70>
{
    8000174a:	715d                	addi	sp,sp,-80
    8000174c:	e486                	sd	ra,72(sp)
    8000174e:	e0a2                	sd	s0,64(sp)
    80001750:	fc26                	sd	s1,56(sp)
    80001752:	f84a                	sd	s2,48(sp)
    80001754:	f44e                	sd	s3,40(sp)
    80001756:	f052                	sd	s4,32(sp)
    80001758:	ec56                	sd	s5,24(sp)
    8000175a:	e85a                	sd	s6,16(sp)
    8000175c:	e45e                	sd	s7,8(sp)
    8000175e:	e062                	sd	s8,0(sp)
    80001760:	0880                	addi	s0,sp,80
    80001762:	8b2a                	mv	s6,a0
    80001764:	8a2e                	mv	s4,a1
    80001766:	8c32                	mv	s8,a2
    80001768:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000176a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000176c:	6a85                	lui	s5,0x1
    8000176e:	a01d                	j	80001794 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001770:	018505b3          	add	a1,a0,s8
    80001774:	0004861b          	sext.w	a2,s1
    80001778:	412585b3          	sub	a1,a1,s2
    8000177c:	8552                	mv	a0,s4
    8000177e:	fffff097          	auipc	ra,0xfffff
    80001782:	5d8080e7          	jalr	1496(ra) # 80000d56 <memmove>

    len -= n;
    80001786:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000178a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000178c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001790:	02098263          	beqz	s3,800017b4 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001794:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001798:	85ca                	mv	a1,s2
    8000179a:	855a                	mv	a0,s6
    8000179c:	00000097          	auipc	ra,0x0
    800017a0:	8ec080e7          	jalr	-1812(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    800017a4:	cd01                	beqz	a0,800017bc <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017a6:	418904b3          	sub	s1,s2,s8
    800017aa:	94d6                	add	s1,s1,s5
    if(n > len)
    800017ac:	fc99f2e3          	bgeu	s3,s1,80001770 <copyin+0x28>
    800017b0:	84ce                	mv	s1,s3
    800017b2:	bf7d                	j	80001770 <copyin+0x28>
  }
  return 0;
    800017b4:	4501                	li	a0,0
    800017b6:	a021                	j	800017be <copyin+0x76>
    800017b8:	4501                	li	a0,0
}
    800017ba:	8082                	ret
      return -1;
    800017bc:	557d                	li	a0,-1
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6c02                	ld	s8,0(sp)
    800017d2:	6161                	addi	sp,sp,80
    800017d4:	8082                	ret

00000000800017d6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017d6:	c6c5                	beqz	a3,8000187e <copyinstr+0xa8>
{
    800017d8:	715d                	addi	sp,sp,-80
    800017da:	e486                	sd	ra,72(sp)
    800017dc:	e0a2                	sd	s0,64(sp)
    800017de:	fc26                	sd	s1,56(sp)
    800017e0:	f84a                	sd	s2,48(sp)
    800017e2:	f44e                	sd	s3,40(sp)
    800017e4:	f052                	sd	s4,32(sp)
    800017e6:	ec56                	sd	s5,24(sp)
    800017e8:	e85a                	sd	s6,16(sp)
    800017ea:	e45e                	sd	s7,8(sp)
    800017ec:	0880                	addi	s0,sp,80
    800017ee:	8a2a                	mv	s4,a0
    800017f0:	8b2e                	mv	s6,a1
    800017f2:	8bb2                	mv	s7,a2
    800017f4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017f6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017f8:	6985                	lui	s3,0x1
    800017fa:	a035                	j	80001826 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017fc:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001800:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000180a:	60a6                	ld	ra,72(sp)
    8000180c:	6406                	ld	s0,64(sp)
    8000180e:	74e2                	ld	s1,56(sp)
    80001810:	7942                	ld	s2,48(sp)
    80001812:	79a2                	ld	s3,40(sp)
    80001814:	7a02                	ld	s4,32(sp)
    80001816:	6ae2                	ld	s5,24(sp)
    80001818:	6b42                	ld	s6,16(sp)
    8000181a:	6ba2                	ld	s7,8(sp)
    8000181c:	6161                	addi	sp,sp,80
    8000181e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001820:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001824:	c8a9                	beqz	s1,80001876 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001826:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000182a:	85ca                	mv	a1,s2
    8000182c:	8552                	mv	a0,s4
    8000182e:	00000097          	auipc	ra,0x0
    80001832:	85a080e7          	jalr	-1958(ra) # 80001088 <walkaddr>
    if(pa0 == 0)
    80001836:	c131                	beqz	a0,8000187a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001838:	41790833          	sub	a6,s2,s7
    8000183c:	984e                	add	a6,a6,s3
    if(n > max)
    8000183e:	0104f363          	bgeu	s1,a6,80001844 <copyinstr+0x6e>
    80001842:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001844:	955e                	add	a0,a0,s7
    80001846:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000184a:	fc080be3          	beqz	a6,80001820 <copyinstr+0x4a>
    8000184e:	985a                	add	a6,a6,s6
    80001850:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001852:	41650633          	sub	a2,a0,s6
    80001856:	14fd                	addi	s1,s1,-1
    80001858:	9b26                	add	s6,s6,s1
    8000185a:	00f60733          	add	a4,a2,a5
    8000185e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001862:	df49                	beqz	a4,800017fc <copyinstr+0x26>
        *dst = *p;
    80001864:	00e78023          	sb	a4,0(a5)
      --max;
    80001868:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000186c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000186e:	ff0796e3          	bne	a5,a6,8000185a <copyinstr+0x84>
      dst++;
    80001872:	8b42                	mv	s6,a6
    80001874:	b775                	j	80001820 <copyinstr+0x4a>
    80001876:	4781                	li	a5,0
    80001878:	b769                	j	80001802 <copyinstr+0x2c>
      return -1;
    8000187a:	557d                	li	a0,-1
    8000187c:	b779                	j	8000180a <copyinstr+0x34>
  int got_null = 0;
    8000187e:	4781                	li	a5,0
  if(got_null){
    80001880:	0017b793          	seqz	a5,a5
    80001884:	40f00533          	neg	a0,a5
}
    80001888:	8082                	ret

000000008000188a <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000188a:	1101                	addi	sp,sp,-32
    8000188c:	ec06                	sd	ra,24(sp)
    8000188e:	e822                	sd	s0,16(sp)
    80001890:	e426                	sd	s1,8(sp)
    80001892:	1000                	addi	s0,sp,32
    80001894:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001896:	fffff097          	auipc	ra,0xfffff
    8000189a:	2ee080e7          	jalr	750(ra) # 80000b84 <holding>
    8000189e:	c909                	beqz	a0,800018b0 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018a0:	749c                	ld	a5,40(s1)
    800018a2:	00978f63          	beq	a5,s1,800018c0 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018a6:	60e2                	ld	ra,24(sp)
    800018a8:	6442                	ld	s0,16(sp)
    800018aa:	64a2                	ld	s1,8(sp)
    800018ac:	6105                	addi	sp,sp,32
    800018ae:	8082                	ret
    panic("wakeup1");
    800018b0:	00007517          	auipc	a0,0x7
    800018b4:	91850513          	addi	a0,a0,-1768 # 800081c8 <digits+0x188>
    800018b8:	fffff097          	auipc	ra,0xfffff
    800018bc:	c8a080e7          	jalr	-886(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018c0:	4c98                	lw	a4,24(s1)
    800018c2:	4785                	li	a5,1
    800018c4:	fef711e3          	bne	a4,a5,800018a6 <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018c8:	4789                	li	a5,2
    800018ca:	cc9c                	sw	a5,24(s1)
}
    800018cc:	bfe9                	j	800018a6 <wakeup1+0x1c>

00000000800018ce <procinit>:
{
    800018ce:	715d                	addi	sp,sp,-80
    800018d0:	e486                	sd	ra,72(sp)
    800018d2:	e0a2                	sd	s0,64(sp)
    800018d4:	fc26                	sd	s1,56(sp)
    800018d6:	f84a                	sd	s2,48(sp)
    800018d8:	f44e                	sd	s3,40(sp)
    800018da:	f052                	sd	s4,32(sp)
    800018dc:	ec56                	sd	s5,24(sp)
    800018de:	e85a                	sd	s6,16(sp)
    800018e0:	e45e                	sd	s7,8(sp)
    800018e2:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800018e4:	00007597          	auipc	a1,0x7
    800018e8:	8ec58593          	addi	a1,a1,-1812 # 800081d0 <digits+0x190>
    800018ec:	00010517          	auipc	a0,0x10
    800018f0:	06450513          	addi	a0,a0,100 # 80011950 <pid_lock>
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	27a080e7          	jalr	634(ra) # 80000b6e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fc:	00010917          	auipc	s2,0x10
    80001900:	46c90913          	addi	s2,s2,1132 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001904:	00007b97          	auipc	s7,0x7
    80001908:	8d4b8b93          	addi	s7,s7,-1836 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    8000190c:	8b4a                	mv	s6,s2
    8000190e:	00006a97          	auipc	s5,0x6
    80001912:	6f2a8a93          	addi	s5,s5,1778 # 80008000 <etext>
    80001916:	040009b7          	lui	s3,0x4000
    8000191a:	19fd                	addi	s3,s3,-1
    8000191c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191e:	00016a17          	auipc	s4,0x16
    80001922:	e4aa0a13          	addi	s4,s4,-438 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001926:	85de                	mv	a1,s7
    80001928:	854a                	mv	a0,s2
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	244080e7          	jalr	580(ra) # 80000b6e <initlock>
      char *pa = kalloc();
    80001932:	fffff097          	auipc	ra,0xfffff
    80001936:	1dc080e7          	jalr	476(ra) # 80000b0e <kalloc>
    8000193a:	85aa                	mv	a1,a0
      if(pa == 0)
    8000193c:	c929                	beqz	a0,8000198e <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000193e:	416904b3          	sub	s1,s2,s6
    80001942:	848d                	srai	s1,s1,0x3
    80001944:	000ab783          	ld	a5,0(s5)
    80001948:	02f484b3          	mul	s1,s1,a5
    8000194c:	2485                	addiw	s1,s1,1
    8000194e:	00d4949b          	slliw	s1,s1,0xd
    80001952:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001956:	4699                	li	a3,6
    80001958:	6605                	lui	a2,0x1
    8000195a:	8526                	mv	a0,s1
    8000195c:	00000097          	auipc	ra,0x0
    80001960:	85a080e7          	jalr	-1958(ra) # 800011b6 <kvmmap>
      p->kstack = va;
    80001964:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	16890913          	addi	s2,s2,360
    8000196c:	fb491de3          	bne	s2,s4,80001926 <procinit+0x58>
  kvminithart();
    80001970:	fffff097          	auipc	ra,0xfffff
    80001974:	64e080e7          	jalr	1614(ra) # 80000fbe <kvminithart>
}
    80001978:	60a6                	ld	ra,72(sp)
    8000197a:	6406                	ld	s0,64(sp)
    8000197c:	74e2                	ld	s1,56(sp)
    8000197e:	7942                	ld	s2,48(sp)
    80001980:	79a2                	ld	s3,40(sp)
    80001982:	7a02                	ld	s4,32(sp)
    80001984:	6ae2                	ld	s5,24(sp)
    80001986:	6b42                	ld	s6,16(sp)
    80001988:	6ba2                	ld	s7,8(sp)
    8000198a:	6161                	addi	sp,sp,80
    8000198c:	8082                	ret
        panic("kalloc");
    8000198e:	00007517          	auipc	a0,0x7
    80001992:	85250513          	addi	a0,a0,-1966 # 800081e0 <digits+0x1a0>
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	bac080e7          	jalr	-1108(ra) # 80000542 <panic>

000000008000199e <cpuid>:
{
    8000199e:	1141                	addi	sp,sp,-16
    800019a0:	e422                	sd	s0,8(sp)
    800019a2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a4:	8512                	mv	a0,tp
}
    800019a6:	2501                	sext.w	a0,a0
    800019a8:	6422                	ld	s0,8(sp)
    800019aa:	0141                	addi	sp,sp,16
    800019ac:	8082                	ret

00000000800019ae <mycpu>:
mycpu(void) {
    800019ae:	1141                	addi	sp,sp,-16
    800019b0:	e422                	sd	s0,8(sp)
    800019b2:	0800                	addi	s0,sp,16
    800019b4:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019b6:	2781                	sext.w	a5,a5
    800019b8:	079e                	slli	a5,a5,0x7
}
    800019ba:	00010517          	auipc	a0,0x10
    800019be:	fae50513          	addi	a0,a0,-82 # 80011968 <cpus>
    800019c2:	953e                	add	a0,a0,a5
    800019c4:	6422                	ld	s0,8(sp)
    800019c6:	0141                	addi	sp,sp,16
    800019c8:	8082                	ret

00000000800019ca <myproc>:
myproc(void) {
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	e426                	sd	s1,8(sp)
    800019d2:	1000                	addi	s0,sp,32
  push_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	1de080e7          	jalr	478(ra) # 80000bb2 <push_off>
    800019dc:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    800019de:	2781                	sext.w	a5,a5
    800019e0:	079e                	slli	a5,a5,0x7
    800019e2:	00010717          	auipc	a4,0x10
    800019e6:	f6e70713          	addi	a4,a4,-146 # 80011950 <pid_lock>
    800019ea:	97ba                	add	a5,a5,a4
    800019ec:	6f84                	ld	s1,24(a5)
  pop_off();
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	264080e7          	jalr	612(ra) # 80000c52 <pop_off>
}
    800019f6:	8526                	mv	a0,s1
    800019f8:	60e2                	ld	ra,24(sp)
    800019fa:	6442                	ld	s0,16(sp)
    800019fc:	64a2                	ld	s1,8(sp)
    800019fe:	6105                	addi	sp,sp,32
    80001a00:	8082                	ret

0000000080001a02 <forkret>:
{
    80001a02:	1141                	addi	sp,sp,-16
    80001a04:	e406                	sd	ra,8(sp)
    80001a06:	e022                	sd	s0,0(sp)
    80001a08:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a0a:	00000097          	auipc	ra,0x0
    80001a0e:	fc0080e7          	jalr	-64(ra) # 800019ca <myproc>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	2a0080e7          	jalr	672(ra) # 80000cb2 <release>
  if (first) {
    80001a1a:	00007797          	auipc	a5,0x7
    80001a1e:	df67a783          	lw	a5,-522(a5) # 80008810 <first.1>
    80001a22:	eb89                	bnez	a5,80001a34 <forkret+0x32>
  usertrapret();
    80001a24:	00001097          	auipc	ra,0x1
    80001a28:	c16080e7          	jalr	-1002(ra) # 8000263a <usertrapret>
}
    80001a2c:	60a2                	ld	ra,8(sp)
    80001a2e:	6402                	ld	s0,0(sp)
    80001a30:	0141                	addi	sp,sp,16
    80001a32:	8082                	ret
    first = 0;
    80001a34:	00007797          	auipc	a5,0x7
    80001a38:	dc07ae23          	sw	zero,-548(a5) # 80008810 <first.1>
    fsinit(ROOTDEV);
    80001a3c:	4505                	li	a0,1
    80001a3e:	00002097          	auipc	ra,0x2
    80001a42:	93e080e7          	jalr	-1730(ra) # 8000337c <fsinit>
    80001a46:	bff9                	j	80001a24 <forkret+0x22>

0000000080001a48 <allocpid>:
allocpid() {
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a54:	00010917          	auipc	s2,0x10
    80001a58:	efc90913          	addi	s2,s2,-260 # 80011950 <pid_lock>
    80001a5c:	854a                	mv	a0,s2
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	1a0080e7          	jalr	416(ra) # 80000bfe <acquire>
  pid = nextpid;
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	dae78793          	addi	a5,a5,-594 # 80008814 <nextpid>
    80001a6e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a70:	0014871b          	addiw	a4,s1,1
    80001a74:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a76:	854a                	mv	a0,s2
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	23a080e7          	jalr	570(ra) # 80000cb2 <release>
}
    80001a80:	8526                	mv	a0,s1
    80001a82:	60e2                	ld	ra,24(sp)
    80001a84:	6442                	ld	s0,16(sp)
    80001a86:	64a2                	ld	s1,8(sp)
    80001a88:	6902                	ld	s2,0(sp)
    80001a8a:	6105                	addi	sp,sp,32
    80001a8c:	8082                	ret

0000000080001a8e <proc_pagetable>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	e04a                	sd	s2,0(sp)
    80001a98:	1000                	addi	s0,sp,32
    80001a9a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	8e8080e7          	jalr	-1816(ra) # 80001384 <uvmcreate>
    80001aa4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa6:	c121                	beqz	a0,80001ae6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa8:	4729                	li	a4,10
    80001aaa:	00005697          	auipc	a3,0x5
    80001aae:	55668693          	addi	a3,a3,1366 # 80007000 <_trampoline>
    80001ab2:	6605                	lui	a2,0x1
    80001ab4:	040005b7          	lui	a1,0x4000
    80001ab8:	15fd                	addi	a1,a1,-1
    80001aba:	05b2                	slli	a1,a1,0xc
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	66c080e7          	jalr	1644(ra) # 80001128 <mappages>
    80001ac4:	02054863          	bltz	a0,80001af4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac8:	4719                	li	a4,6
    80001aca:	05893683          	ld	a3,88(s2)
    80001ace:	6605                	lui	a2,0x1
    80001ad0:	020005b7          	lui	a1,0x2000
    80001ad4:	15fd                	addi	a1,a1,-1
    80001ad6:	05b6                	slli	a1,a1,0xd
    80001ad8:	8526                	mv	a0,s1
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	64e080e7          	jalr	1614(ra) # 80001128 <mappages>
    80001ae2:	02054163          	bltz	a0,80001b04 <proc_pagetable+0x76>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	addi	sp,sp,32
    80001af2:	8082                	ret
    uvmfree(pagetable, 0);
    80001af4:	4581                	li	a1,0
    80001af6:	8526                	mv	a0,s1
    80001af8:	00000097          	auipc	ra,0x0
    80001afc:	a88080e7          	jalr	-1400(ra) # 80001580 <uvmfree>
    return 0;
    80001b00:	4481                	li	s1,0
    80001b02:	b7d5                	j	80001ae6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b04:	4681                	li	a3,0
    80001b06:	4605                	li	a2,1
    80001b08:	040005b7          	lui	a1,0x4000
    80001b0c:	15fd                	addi	a1,a1,-1
    80001b0e:	05b2                	slli	a1,a1,0xc
    80001b10:	8526                	mv	a0,s1
    80001b12:	fffff097          	auipc	ra,0xfffff
    80001b16:	7ae080e7          	jalr	1966(ra) # 800012c0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b1a:	4581                	li	a1,0
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	00000097          	auipc	ra,0x0
    80001b22:	a62080e7          	jalr	-1438(ra) # 80001580 <uvmfree>
    return 0;
    80001b26:	4481                	li	s1,0
    80001b28:	bf7d                	j	80001ae6 <proc_pagetable+0x58>

0000000080001b2a <proc_freepagetable>:
{
    80001b2a:	1101                	addi	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	e04a                	sd	s2,0(sp)
    80001b34:	1000                	addi	s0,sp,32
    80001b36:	84aa                	mv	s1,a0
    80001b38:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	040005b7          	lui	a1,0x4000
    80001b42:	15fd                	addi	a1,a1,-1
    80001b44:	05b2                	slli	a1,a1,0xc
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	77a080e7          	jalr	1914(ra) # 800012c0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	020005b7          	lui	a1,0x2000
    80001b56:	15fd                	addi	a1,a1,-1
    80001b58:	05b6                	slli	a1,a1,0xd
    80001b5a:	8526                	mv	a0,s1
    80001b5c:	fffff097          	auipc	ra,0xfffff
    80001b60:	764080e7          	jalr	1892(ra) # 800012c0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b64:	85ca                	mv	a1,s2
    80001b66:	8526                	mv	a0,s1
    80001b68:	00000097          	auipc	ra,0x0
    80001b6c:	a18080e7          	jalr	-1512(ra) # 80001580 <uvmfree>
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6902                	ld	s2,0(sp)
    80001b78:	6105                	addi	sp,sp,32
    80001b7a:	8082                	ret

0000000080001b7c <freeproc>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	1000                	addi	s0,sp,32
    80001b86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b88:	6d28                	ld	a0,88(a0)
    80001b8a:	c509                	beqz	a0,80001b94 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	e86080e7          	jalr	-378(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001b94:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b98:	68a8                	ld	a0,80(s1)
    80001b9a:	c511                	beqz	a0,80001ba6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9c:	64ac                	ld	a1,72(s1)
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	f8c080e7          	jalr	-116(ra) # 80001b2a <proc_freepagetable>
  p->pagetable = 0;
    80001ba6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001baa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bae:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001bb2:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001bb6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bba:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001bbe:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001bc2:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bc6:	0004ac23          	sw	zero,24(s1)
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6105                	addi	sp,sp,32
    80001bd2:	8082                	ret

0000000080001bd4 <allocproc>:
{
    80001bd4:	1101                	addi	sp,sp,-32
    80001bd6:	ec06                	sd	ra,24(sp)
    80001bd8:	e822                	sd	s0,16(sp)
    80001bda:	e426                	sd	s1,8(sp)
    80001bdc:	e04a                	sd	s2,0(sp)
    80001bde:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be0:	00010497          	auipc	s1,0x10
    80001be4:	18848493          	addi	s1,s1,392 # 80011d68 <proc>
    80001be8:	00016917          	auipc	s2,0x16
    80001bec:	b8090913          	addi	s2,s2,-1152 # 80017768 <tickslock>
    acquire(&p->lock);
    80001bf0:	8526                	mv	a0,s1
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	00c080e7          	jalr	12(ra) # 80000bfe <acquire>
    if(p->state == UNUSED) {
    80001bfa:	4c9c                	lw	a5,24(s1)
    80001bfc:	cf81                	beqz	a5,80001c14 <allocproc+0x40>
      release(&p->lock);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	0b2080e7          	jalr	178(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	16848493          	addi	s1,s1,360
    80001c0c:	ff2492e3          	bne	s1,s2,80001bf0 <allocproc+0x1c>
  return 0;
    80001c10:	4481                	li	s1,0
    80001c12:	a0b9                	j	80001c60 <allocproc+0x8c>
  p->pid = allocpid();
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e34080e7          	jalr	-460(ra) # 80001a48 <allocpid>
    80001c1c:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	ef0080e7          	jalr	-272(ra) # 80000b0e <kalloc>
    80001c26:	892a                	mv	s2,a0
    80001c28:	eca8                	sd	a0,88(s1)
    80001c2a:	c131                	beqz	a0,80001c6e <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	00000097          	auipc	ra,0x0
    80001c32:	e60080e7          	jalr	-416(ra) # 80001a8e <proc_pagetable>
    80001c36:	892a                	mv	s2,a0
    80001c38:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c3a:	c129                	beqz	a0,80001c7c <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c3c:	07000613          	li	a2,112
    80001c40:	4581                	li	a1,0
    80001c42:	06048513          	addi	a0,s1,96
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	0b4080e7          	jalr	180(ra) # 80000cfa <memset>
  p->context.ra = (uint64)forkret;
    80001c4e:	00000797          	auipc	a5,0x0
    80001c52:	db478793          	addi	a5,a5,-588 # 80001a02 <forkret>
    80001c56:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c58:	60bc                	ld	a5,64(s1)
    80001c5a:	6705                	lui	a4,0x1
    80001c5c:	97ba                	add	a5,a5,a4
    80001c5e:	f4bc                	sd	a5,104(s1)
}
    80001c60:	8526                	mv	a0,s1
    80001c62:	60e2                	ld	ra,24(sp)
    80001c64:	6442                	ld	s0,16(sp)
    80001c66:	64a2                	ld	s1,8(sp)
    80001c68:	6902                	ld	s2,0(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret
    release(&p->lock);
    80001c6e:	8526                	mv	a0,s1
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	042080e7          	jalr	66(ra) # 80000cb2 <release>
    return 0;
    80001c78:	84ca                	mv	s1,s2
    80001c7a:	b7dd                	j	80001c60 <allocproc+0x8c>
    freeproc(p);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	efe080e7          	jalr	-258(ra) # 80001b7c <freeproc>
    release(&p->lock);
    80001c86:	8526                	mv	a0,s1
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	02a080e7          	jalr	42(ra) # 80000cb2 <release>
    return 0;
    80001c90:	84ca                	mv	s1,s2
    80001c92:	b7f9                	j	80001c60 <allocproc+0x8c>

0000000080001c94 <userinit>:
{
    80001c94:	1101                	addi	sp,sp,-32
    80001c96:	ec06                	sd	ra,24(sp)
    80001c98:	e822                	sd	s0,16(sp)
    80001c9a:	e426                	sd	s1,8(sp)
    80001c9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	f36080e7          	jalr	-202(ra) # 80001bd4 <allocproc>
    80001ca6:	84aa                	mv	s1,a0
  initproc = p;
    80001ca8:	00007797          	auipc	a5,0x7
    80001cac:	36a7b823          	sd	a0,880(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cb0:	03400613          	li	a2,52
    80001cb4:	00007597          	auipc	a1,0x7
    80001cb8:	b6c58593          	addi	a1,a1,-1172 # 80008820 <initcode>
    80001cbc:	6928                	ld	a0,80(a0)
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	6f4080e7          	jalr	1780(ra) # 800013b2 <uvminit>
  p->sz = PGSIZE;
    80001cc6:	6785                	lui	a5,0x1
    80001cc8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cca:	6cb8                	ld	a4,88(s1)
    80001ccc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd0:	6cb8                	ld	a4,88(s1)
    80001cd2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cd4:	4641                	li	a2,16
    80001cd6:	00006597          	auipc	a1,0x6
    80001cda:	51258593          	addi	a1,a1,1298 # 800081e8 <digits+0x1a8>
    80001cde:	15848513          	addi	a0,s1,344
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	16a080e7          	jalr	362(ra) # 80000e4c <safestrcpy>
  p->cwd = namei("/");
    80001cea:	00006517          	auipc	a0,0x6
    80001cee:	50e50513          	addi	a0,a0,1294 # 800081f8 <digits+0x1b8>
    80001cf2:	00002097          	auipc	ra,0x2
    80001cf6:	0b2080e7          	jalr	178(ra) # 80003da4 <namei>
    80001cfa:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cfe:	4789                	li	a5,2
    80001d00:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	fae080e7          	jalr	-82(ra) # 80000cb2 <release>
}
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <growproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	e04a                	sd	s2,0(sp)
    80001d20:	1000                	addi	s0,sp,32
    80001d22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	ca6080e7          	jalr	-858(ra) # 800019ca <myproc>
    80001d2c:	892a                	mv	s2,a0
  sz = p->sz;
    80001d2e:	652c                	ld	a1,72(a0)
    80001d30:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d34:	00904f63          	bgtz	s1,80001d52 <growproc+0x3c>
  } else if(n < 0){
    80001d38:	0204cc63          	bltz	s1,80001d70 <growproc+0x5a>
  p->sz = sz;
    80001d3c:	1602                	slli	a2,a2,0x20
    80001d3e:	9201                	srli	a2,a2,0x20
    80001d40:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d44:	4501                	li	a0,0
}
    80001d46:	60e2                	ld	ra,24(sp)
    80001d48:	6442                	ld	s0,16(sp)
    80001d4a:	64a2                	ld	s1,8(sp)
    80001d4c:	6902                	ld	s2,0(sp)
    80001d4e:	6105                	addi	sp,sp,32
    80001d50:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d52:	9e25                	addw	a2,a2,s1
    80001d54:	1602                	slli	a2,a2,0x20
    80001d56:	9201                	srli	a2,a2,0x20
    80001d58:	1582                	slli	a1,a1,0x20
    80001d5a:	9181                	srli	a1,a1,0x20
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	70e080e7          	jalr	1806(ra) # 8000146c <uvmalloc>
    80001d66:	0005061b          	sext.w	a2,a0
    80001d6a:	fa69                	bnez	a2,80001d3c <growproc+0x26>
      return -1;
    80001d6c:	557d                	li	a0,-1
    80001d6e:	bfe1                	j	80001d46 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d70:	9e25                	addw	a2,a2,s1
    80001d72:	1602                	slli	a2,a2,0x20
    80001d74:	9201                	srli	a2,a2,0x20
    80001d76:	1582                	slli	a1,a1,0x20
    80001d78:	9181                	srli	a1,a1,0x20
    80001d7a:	6928                	ld	a0,80(a0)
    80001d7c:	fffff097          	auipc	ra,0xfffff
    80001d80:	6a8080e7          	jalr	1704(ra) # 80001424 <uvmdealloc>
    80001d84:	0005061b          	sext.w	a2,a0
    80001d88:	bf55                	j	80001d3c <growproc+0x26>

0000000080001d8a <fork>:
{
    80001d8a:	7139                	addi	sp,sp,-64
    80001d8c:	fc06                	sd	ra,56(sp)
    80001d8e:	f822                	sd	s0,48(sp)
    80001d90:	f426                	sd	s1,40(sp)
    80001d92:	f04a                	sd	s2,32(sp)
    80001d94:	ec4e                	sd	s3,24(sp)
    80001d96:	e852                	sd	s4,16(sp)
    80001d98:	e456                	sd	s5,8(sp)
    80001d9a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d9c:	00000097          	auipc	ra,0x0
    80001da0:	c2e080e7          	jalr	-978(ra) # 800019ca <myproc>
    80001da4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	e2e080e7          	jalr	-466(ra) # 80001bd4 <allocproc>
    80001dae:	c17d                	beqz	a0,80001e94 <fork+0x10a>
    80001db0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001db2:	048ab603          	ld	a2,72(s5)
    80001db6:	692c                	ld	a1,80(a0)
    80001db8:	050ab503          	ld	a0,80(s5)
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	7fc080e7          	jalr	2044(ra) # 800015b8 <uvmcopy>
    80001dc4:	04054a63          	bltz	a0,80001e18 <fork+0x8e>
  np->sz = p->sz;
    80001dc8:	048ab783          	ld	a5,72(s5)
    80001dcc:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001dd0:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dd4:	058ab683          	ld	a3,88(s5)
    80001dd8:	87b6                	mv	a5,a3
    80001dda:	058a3703          	ld	a4,88(s4)
    80001dde:	12068693          	addi	a3,a3,288
    80001de2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001de6:	6788                	ld	a0,8(a5)
    80001de8:	6b8c                	ld	a1,16(a5)
    80001dea:	6f90                	ld	a2,24(a5)
    80001dec:	01073023          	sd	a6,0(a4)
    80001df0:	e708                	sd	a0,8(a4)
    80001df2:	eb0c                	sd	a1,16(a4)
    80001df4:	ef10                	sd	a2,24(a4)
    80001df6:	02078793          	addi	a5,a5,32
    80001dfa:	02070713          	addi	a4,a4,32
    80001dfe:	fed792e3          	bne	a5,a3,80001de2 <fork+0x58>
  np->trapframe->a0 = 0;
    80001e02:	058a3783          	ld	a5,88(s4)
    80001e06:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e0a:	0d0a8493          	addi	s1,s5,208
    80001e0e:	0d0a0913          	addi	s2,s4,208
    80001e12:	150a8993          	addi	s3,s5,336
    80001e16:	a00d                	j	80001e38 <fork+0xae>
    freeproc(np);
    80001e18:	8552                	mv	a0,s4
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	d62080e7          	jalr	-670(ra) # 80001b7c <freeproc>
    release(&np->lock);
    80001e22:	8552                	mv	a0,s4
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	e8e080e7          	jalr	-370(ra) # 80000cb2 <release>
    return -1;
    80001e2c:	54fd                	li	s1,-1
    80001e2e:	a889                	j	80001e80 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001e30:	04a1                	addi	s1,s1,8
    80001e32:	0921                	addi	s2,s2,8
    80001e34:	01348b63          	beq	s1,s3,80001e4a <fork+0xc0>
    if(p->ofile[i])
    80001e38:	6088                	ld	a0,0(s1)
    80001e3a:	d97d                	beqz	a0,80001e30 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e3c:	00002097          	auipc	ra,0x2
    80001e40:	5f8080e7          	jalr	1528(ra) # 80004434 <filedup>
    80001e44:	00a93023          	sd	a0,0(s2)
    80001e48:	b7e5                	j	80001e30 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e4a:	150ab503          	ld	a0,336(s5)
    80001e4e:	00001097          	auipc	ra,0x1
    80001e52:	768080e7          	jalr	1896(ra) # 800035b6 <idup>
    80001e56:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e5a:	4641                	li	a2,16
    80001e5c:	158a8593          	addi	a1,s5,344
    80001e60:	158a0513          	addi	a0,s4,344
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	fe8080e7          	jalr	-24(ra) # 80000e4c <safestrcpy>
  pid = np->pid;
    80001e6c:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001e70:	4789                	li	a5,2
    80001e72:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e76:	8552                	mv	a0,s4
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e3a080e7          	jalr	-454(ra) # 80000cb2 <release>
}
    80001e80:	8526                	mv	a0,s1
    80001e82:	70e2                	ld	ra,56(sp)
    80001e84:	7442                	ld	s0,48(sp)
    80001e86:	74a2                	ld	s1,40(sp)
    80001e88:	7902                	ld	s2,32(sp)
    80001e8a:	69e2                	ld	s3,24(sp)
    80001e8c:	6a42                	ld	s4,16(sp)
    80001e8e:	6aa2                	ld	s5,8(sp)
    80001e90:	6121                	addi	sp,sp,64
    80001e92:	8082                	ret
    return -1;
    80001e94:	54fd                	li	s1,-1
    80001e96:	b7ed                	j	80001e80 <fork+0xf6>

0000000080001e98 <reparent>:
{
    80001e98:	7179                	addi	sp,sp,-48
    80001e9a:	f406                	sd	ra,40(sp)
    80001e9c:	f022                	sd	s0,32(sp)
    80001e9e:	ec26                	sd	s1,24(sp)
    80001ea0:	e84a                	sd	s2,16(sp)
    80001ea2:	e44e                	sd	s3,8(sp)
    80001ea4:	e052                	sd	s4,0(sp)
    80001ea6:	1800                	addi	s0,sp,48
    80001ea8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eaa:	00010497          	auipc	s1,0x10
    80001eae:	ebe48493          	addi	s1,s1,-322 # 80011d68 <proc>
      pp->parent = initproc;
    80001eb2:	00007a17          	auipc	s4,0x7
    80001eb6:	166a0a13          	addi	s4,s4,358 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eba:	00016997          	auipc	s3,0x16
    80001ebe:	8ae98993          	addi	s3,s3,-1874 # 80017768 <tickslock>
    80001ec2:	a029                	j	80001ecc <reparent+0x34>
    80001ec4:	16848493          	addi	s1,s1,360
    80001ec8:	03348363          	beq	s1,s3,80001eee <reparent+0x56>
    if(pp->parent == p){
    80001ecc:	709c                	ld	a5,32(s1)
    80001ece:	ff279be3          	bne	a5,s2,80001ec4 <reparent+0x2c>
      acquire(&pp->lock);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	d2a080e7          	jalr	-726(ra) # 80000bfe <acquire>
      pp->parent = initproc;
    80001edc:	000a3783          	ld	a5,0(s4)
    80001ee0:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	dce080e7          	jalr	-562(ra) # 80000cb2 <release>
    80001eec:	bfe1                	j	80001ec4 <reparent+0x2c>
}
    80001eee:	70a2                	ld	ra,40(sp)
    80001ef0:	7402                	ld	s0,32(sp)
    80001ef2:	64e2                	ld	s1,24(sp)
    80001ef4:	6942                	ld	s2,16(sp)
    80001ef6:	69a2                	ld	s3,8(sp)
    80001ef8:	6a02                	ld	s4,0(sp)
    80001efa:	6145                	addi	sp,sp,48
    80001efc:	8082                	ret

0000000080001efe <scheduler>:
{
    80001efe:	715d                	addi	sp,sp,-80
    80001f00:	e486                	sd	ra,72(sp)
    80001f02:	e0a2                	sd	s0,64(sp)
    80001f04:	fc26                	sd	s1,56(sp)
    80001f06:	f84a                	sd	s2,48(sp)
    80001f08:	f44e                	sd	s3,40(sp)
    80001f0a:	f052                	sd	s4,32(sp)
    80001f0c:	ec56                	sd	s5,24(sp)
    80001f0e:	e85a                	sd	s6,16(sp)
    80001f10:	e45e                	sd	s7,8(sp)
    80001f12:	e062                	sd	s8,0(sp)
    80001f14:	0880                	addi	s0,sp,80
    80001f16:	8792                	mv	a5,tp
  int id = r_tp();
    80001f18:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f1a:	00779b13          	slli	s6,a5,0x7
    80001f1e:	00010717          	auipc	a4,0x10
    80001f22:	a3270713          	addi	a4,a4,-1486 # 80011950 <pid_lock>
    80001f26:	975a                	add	a4,a4,s6
    80001f28:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f2c:	00010717          	auipc	a4,0x10
    80001f30:	a4470713          	addi	a4,a4,-1468 # 80011970 <cpus+0x8>
    80001f34:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f36:	4c0d                	li	s8,3
        c->proc = p;
    80001f38:	079e                	slli	a5,a5,0x7
    80001f3a:	00010a17          	auipc	s4,0x10
    80001f3e:	a16a0a13          	addi	s4,s4,-1514 # 80011950 <pid_lock>
    80001f42:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f44:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f46:	00016997          	auipc	s3,0x16
    80001f4a:	82298993          	addi	s3,s3,-2014 # 80017768 <tickslock>
    80001f4e:	a899                	j	80001fa4 <scheduler+0xa6>
      release(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	d60080e7          	jalr	-672(ra) # 80000cb2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f5a:	16848493          	addi	s1,s1,360
    80001f5e:	03348963          	beq	s1,s3,80001f90 <scheduler+0x92>
      acquire(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	c9a080e7          	jalr	-870(ra) # 80000bfe <acquire>
      if(p->state == RUNNABLE) {
    80001f6c:	4c9c                	lw	a5,24(s1)
    80001f6e:	ff2791e3          	bne	a5,s2,80001f50 <scheduler+0x52>
        p->state = RUNNING;
    80001f72:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f76:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001f7a:	06048593          	addi	a1,s1,96
    80001f7e:	855a                	mv	a0,s6
    80001f80:	00000097          	auipc	ra,0x0
    80001f84:	610080e7          	jalr	1552(ra) # 80002590 <swtch>
        c->proc = 0;
    80001f88:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001f8c:	8ade                	mv	s5,s7
    80001f8e:	b7c9                	j	80001f50 <scheduler+0x52>
    if(found == 0) {
    80001f90:	000a9a63          	bnez	s5,80001fa4 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f98:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fa0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fb0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb2:	00010497          	auipc	s1,0x10
    80001fb6:	db648493          	addi	s1,s1,-586 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80001fba:	4909                	li	s2,2
    80001fbc:	b75d                	j	80001f62 <scheduler+0x64>

0000000080001fbe <sched>:
{
    80001fbe:	7179                	addi	sp,sp,-48
    80001fc0:	f406                	sd	ra,40(sp)
    80001fc2:	f022                	sd	s0,32(sp)
    80001fc4:	ec26                	sd	s1,24(sp)
    80001fc6:	e84a                	sd	s2,16(sp)
    80001fc8:	e44e                	sd	s3,8(sp)
    80001fca:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fcc:	00000097          	auipc	ra,0x0
    80001fd0:	9fe080e7          	jalr	-1538(ra) # 800019ca <myproc>
    80001fd4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	bae080e7          	jalr	-1106(ra) # 80000b84 <holding>
    80001fde:	c93d                	beqz	a0,80002054 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe2:	2781                	sext.w	a5,a5
    80001fe4:	079e                	slli	a5,a5,0x7
    80001fe6:	00010717          	auipc	a4,0x10
    80001fea:	96a70713          	addi	a4,a4,-1686 # 80011950 <pid_lock>
    80001fee:	97ba                	add	a5,a5,a4
    80001ff0:	0907a703          	lw	a4,144(a5)
    80001ff4:	4785                	li	a5,1
    80001ff6:	06f71763          	bne	a4,a5,80002064 <sched+0xa6>
  if(p->state == RUNNING)
    80001ffa:	4c98                	lw	a4,24(s1)
    80001ffc:	478d                	li	a5,3
    80001ffe:	06f70b63          	beq	a4,a5,80002074 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002002:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002006:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002008:	efb5                	bnez	a5,80002084 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000200c:	00010917          	auipc	s2,0x10
    80002010:	94490913          	addi	s2,s2,-1724 # 80011950 <pid_lock>
    80002014:	2781                	sext.w	a5,a5
    80002016:	079e                	slli	a5,a5,0x7
    80002018:	97ca                	add	a5,a5,s2
    8000201a:	0947a983          	lw	s3,148(a5)
    8000201e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002020:	2781                	sext.w	a5,a5
    80002022:	079e                	slli	a5,a5,0x7
    80002024:	00010597          	auipc	a1,0x10
    80002028:	94c58593          	addi	a1,a1,-1716 # 80011970 <cpus+0x8>
    8000202c:	95be                	add	a1,a1,a5
    8000202e:	06048513          	addi	a0,s1,96
    80002032:	00000097          	auipc	ra,0x0
    80002036:	55e080e7          	jalr	1374(ra) # 80002590 <swtch>
    8000203a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000203c:	2781                	sext.w	a5,a5
    8000203e:	079e                	slli	a5,a5,0x7
    80002040:	97ca                	add	a5,a5,s2
    80002042:	0937aa23          	sw	s3,148(a5)
}
    80002046:	70a2                	ld	ra,40(sp)
    80002048:	7402                	ld	s0,32(sp)
    8000204a:	64e2                	ld	s1,24(sp)
    8000204c:	6942                	ld	s2,16(sp)
    8000204e:	69a2                	ld	s3,8(sp)
    80002050:	6145                	addi	sp,sp,48
    80002052:	8082                	ret
    panic("sched p->lock");
    80002054:	00006517          	auipc	a0,0x6
    80002058:	1ac50513          	addi	a0,a0,428 # 80008200 <digits+0x1c0>
    8000205c:	ffffe097          	auipc	ra,0xffffe
    80002060:	4e6080e7          	jalr	1254(ra) # 80000542 <panic>
    panic("sched locks");
    80002064:	00006517          	auipc	a0,0x6
    80002068:	1ac50513          	addi	a0,a0,428 # 80008210 <digits+0x1d0>
    8000206c:	ffffe097          	auipc	ra,0xffffe
    80002070:	4d6080e7          	jalr	1238(ra) # 80000542 <panic>
    panic("sched running");
    80002074:	00006517          	auipc	a0,0x6
    80002078:	1ac50513          	addi	a0,a0,428 # 80008220 <digits+0x1e0>
    8000207c:	ffffe097          	auipc	ra,0xffffe
    80002080:	4c6080e7          	jalr	1222(ra) # 80000542 <panic>
    panic("sched interruptible");
    80002084:	00006517          	auipc	a0,0x6
    80002088:	1ac50513          	addi	a0,a0,428 # 80008230 <digits+0x1f0>
    8000208c:	ffffe097          	auipc	ra,0xffffe
    80002090:	4b6080e7          	jalr	1206(ra) # 80000542 <panic>

0000000080002094 <exit>:
{
    80002094:	7179                	addi	sp,sp,-48
    80002096:	f406                	sd	ra,40(sp)
    80002098:	f022                	sd	s0,32(sp)
    8000209a:	ec26                	sd	s1,24(sp)
    8000209c:	e84a                	sd	s2,16(sp)
    8000209e:	e44e                	sd	s3,8(sp)
    800020a0:	e052                	sd	s4,0(sp)
    800020a2:	1800                	addi	s0,sp,48
    800020a4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020a6:	00000097          	auipc	ra,0x0
    800020aa:	924080e7          	jalr	-1756(ra) # 800019ca <myproc>
    800020ae:	89aa                	mv	s3,a0
  if(p == initproc)
    800020b0:	00007797          	auipc	a5,0x7
    800020b4:	f687b783          	ld	a5,-152(a5) # 80009018 <initproc>
    800020b8:	0d050493          	addi	s1,a0,208
    800020bc:	15050913          	addi	s2,a0,336
    800020c0:	02a79363          	bne	a5,a0,800020e6 <exit+0x52>
    panic("init exiting");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	18450513          	addi	a0,a0,388 # 80008248 <digits+0x208>
    800020cc:	ffffe097          	auipc	ra,0xffffe
    800020d0:	476080e7          	jalr	1142(ra) # 80000542 <panic>
      fileclose(f);
    800020d4:	00002097          	auipc	ra,0x2
    800020d8:	3b2080e7          	jalr	946(ra) # 80004486 <fileclose>
      p->ofile[fd] = 0;
    800020dc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020e0:	04a1                	addi	s1,s1,8
    800020e2:	01248563          	beq	s1,s2,800020ec <exit+0x58>
    if(p->ofile[fd]){
    800020e6:	6088                	ld	a0,0(s1)
    800020e8:	f575                	bnez	a0,800020d4 <exit+0x40>
    800020ea:	bfdd                	j	800020e0 <exit+0x4c>
  begin_op();
    800020ec:	00002097          	auipc	ra,0x2
    800020f0:	ec8080e7          	jalr	-312(ra) # 80003fb4 <begin_op>
  iput(p->cwd);
    800020f4:	1509b503          	ld	a0,336(s3)
    800020f8:	00001097          	auipc	ra,0x1
    800020fc:	6b6080e7          	jalr	1718(ra) # 800037ae <iput>
  end_op();
    80002100:	00002097          	auipc	ra,0x2
    80002104:	f34080e7          	jalr	-204(ra) # 80004034 <end_op>
  p->cwd = 0;
    80002108:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000210c:	00007497          	auipc	s1,0x7
    80002110:	f0c48493          	addi	s1,s1,-244 # 80009018 <initproc>
    80002114:	6088                	ld	a0,0(s1)
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	ae8080e7          	jalr	-1304(ra) # 80000bfe <acquire>
  wakeup1(initproc);
    8000211e:	6088                	ld	a0,0(s1)
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	76a080e7          	jalr	1898(ra) # 8000188a <wakeup1>
  release(&initproc->lock);
    80002128:	6088                	ld	a0,0(s1)
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b88080e7          	jalr	-1144(ra) # 80000cb2 <release>
  acquire(&p->lock);
    80002132:	854e                	mv	a0,s3
    80002134:	fffff097          	auipc	ra,0xfffff
    80002138:	aca080e7          	jalr	-1334(ra) # 80000bfe <acquire>
  struct proc *original_parent = p->parent;
    8000213c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002140:	854e                	mv	a0,s3
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	b70080e7          	jalr	-1168(ra) # 80000cb2 <release>
  acquire(&original_parent->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	ab2080e7          	jalr	-1358(ra) # 80000bfe <acquire>
  acquire(&p->lock);
    80002154:	854e                	mv	a0,s3
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	aa8080e7          	jalr	-1368(ra) # 80000bfe <acquire>
  reparent(p);
    8000215e:	854e                	mv	a0,s3
    80002160:	00000097          	auipc	ra,0x0
    80002164:	d38080e7          	jalr	-712(ra) # 80001e98 <reparent>
  wakeup1(original_parent);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	720080e7          	jalr	1824(ra) # 8000188a <wakeup1>
  p->xstate = status;
    80002172:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002176:	4791                	li	a5,4
    80002178:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000217c:	8526                	mv	a0,s1
    8000217e:	fffff097          	auipc	ra,0xfffff
    80002182:	b34080e7          	jalr	-1228(ra) # 80000cb2 <release>
  sched();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	e38080e7          	jalr	-456(ra) # 80001fbe <sched>
  panic("zombie exit");
    8000218e:	00006517          	auipc	a0,0x6
    80002192:	0ca50513          	addi	a0,a0,202 # 80008258 <digits+0x218>
    80002196:	ffffe097          	auipc	ra,0xffffe
    8000219a:	3ac080e7          	jalr	940(ra) # 80000542 <panic>

000000008000219e <yield>:
{
    8000219e:	1101                	addi	sp,sp,-32
    800021a0:	ec06                	sd	ra,24(sp)
    800021a2:	e822                	sd	s0,16(sp)
    800021a4:	e426                	sd	s1,8(sp)
    800021a6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	822080e7          	jalr	-2014(ra) # 800019ca <myproc>
    800021b0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	a4c080e7          	jalr	-1460(ra) # 80000bfe <acquire>
  p->state = RUNNABLE;
    800021ba:	4789                	li	a5,2
    800021bc:	cc9c                	sw	a5,24(s1)
  sched();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	e00080e7          	jalr	-512(ra) # 80001fbe <sched>
  release(&p->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	aea080e7          	jalr	-1302(ra) # 80000cb2 <release>
}
    800021d0:	60e2                	ld	ra,24(sp)
    800021d2:	6442                	ld	s0,16(sp)
    800021d4:	64a2                	ld	s1,8(sp)
    800021d6:	6105                	addi	sp,sp,32
    800021d8:	8082                	ret

00000000800021da <sleep>:
{
    800021da:	7179                	addi	sp,sp,-48
    800021dc:	f406                	sd	ra,40(sp)
    800021de:	f022                	sd	s0,32(sp)
    800021e0:	ec26                	sd	s1,24(sp)
    800021e2:	e84a                	sd	s2,16(sp)
    800021e4:	e44e                	sd	s3,8(sp)
    800021e6:	1800                	addi	s0,sp,48
    800021e8:	89aa                	mv	s3,a0
    800021ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	7de080e7          	jalr	2014(ra) # 800019ca <myproc>
    800021f4:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800021f6:	05250663          	beq	a0,s2,80002242 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	a04080e7          	jalr	-1532(ra) # 80000bfe <acquire>
    release(lk);
    80002202:	854a                	mv	a0,s2
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	aae080e7          	jalr	-1362(ra) # 80000cb2 <release>
  p->chan = chan;
    8000220c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002210:	4785                	li	a5,1
    80002212:	cc9c                	sw	a5,24(s1)
  sched();
    80002214:	00000097          	auipc	ra,0x0
    80002218:	daa080e7          	jalr	-598(ra) # 80001fbe <sched>
  p->chan = 0;
    8000221c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	a90080e7          	jalr	-1392(ra) # 80000cb2 <release>
    acquire(lk);
    8000222a:	854a                	mv	a0,s2
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	9d2080e7          	jalr	-1582(ra) # 80000bfe <acquire>
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6145                	addi	sp,sp,48
    80002240:	8082                	ret
  p->chan = chan;
    80002242:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002246:	4785                	li	a5,1
    80002248:	cd1c                	sw	a5,24(a0)
  sched();
    8000224a:	00000097          	auipc	ra,0x0
    8000224e:	d74080e7          	jalr	-652(ra) # 80001fbe <sched>
  p->chan = 0;
    80002252:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002256:	bff9                	j	80002234 <sleep+0x5a>

0000000080002258 <wait>:
{
    80002258:	715d                	addi	sp,sp,-80
    8000225a:	e486                	sd	ra,72(sp)
    8000225c:	e0a2                	sd	s0,64(sp)
    8000225e:	fc26                	sd	s1,56(sp)
    80002260:	f84a                	sd	s2,48(sp)
    80002262:	f44e                	sd	s3,40(sp)
    80002264:	f052                	sd	s4,32(sp)
    80002266:	ec56                	sd	s5,24(sp)
    80002268:	e85a                	sd	s6,16(sp)
    8000226a:	e45e                	sd	s7,8(sp)
    8000226c:	0880                	addi	s0,sp,80
    8000226e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	75a080e7          	jalr	1882(ra) # 800019ca <myproc>
    80002278:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	984080e7          	jalr	-1660(ra) # 80000bfe <acquire>
    havekids = 0;
    80002282:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002284:	4a11                	li	s4,4
        havekids = 1;
    80002286:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002288:	00015997          	auipc	s3,0x15
    8000228c:	4e098993          	addi	s3,s3,1248 # 80017768 <tickslock>
    havekids = 0;
    80002290:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002292:	00010497          	auipc	s1,0x10
    80002296:	ad648493          	addi	s1,s1,-1322 # 80011d68 <proc>
    8000229a:	a08d                	j	800022fc <wait+0xa4>
          pid = np->pid;
    8000229c:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022a0:	000b0e63          	beqz	s6,800022bc <wait+0x64>
    800022a4:	4691                	li	a3,4
    800022a6:	03448613          	addi	a2,s1,52
    800022aa:	85da                	mv	a1,s6
    800022ac:	05093503          	ld	a0,80(s2)
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	40c080e7          	jalr	1036(ra) # 800016bc <copyout>
    800022b8:	02054263          	bltz	a0,800022dc <wait+0x84>
          freeproc(np);
    800022bc:	8526                	mv	a0,s1
    800022be:	00000097          	auipc	ra,0x0
    800022c2:	8be080e7          	jalr	-1858(ra) # 80001b7c <freeproc>
          release(&np->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	9ea080e7          	jalr	-1558(ra) # 80000cb2 <release>
          release(&p->lock);
    800022d0:	854a                	mv	a0,s2
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	9e0080e7          	jalr	-1568(ra) # 80000cb2 <release>
          return pid;
    800022da:	a8a9                	j	80002334 <wait+0xdc>
            release(&np->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9d4080e7          	jalr	-1580(ra) # 80000cb2 <release>
            release(&p->lock);
    800022e6:	854a                	mv	a0,s2
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	9ca080e7          	jalr	-1590(ra) # 80000cb2 <release>
            return -1;
    800022f0:	59fd                	li	s3,-1
    800022f2:	a089                	j	80002334 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800022f4:	16848493          	addi	s1,s1,360
    800022f8:	03348463          	beq	s1,s3,80002320 <wait+0xc8>
      if(np->parent == p){
    800022fc:	709c                	ld	a5,32(s1)
    800022fe:	ff279be3          	bne	a5,s2,800022f4 <wait+0x9c>
        acquire(&np->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	8fa080e7          	jalr	-1798(ra) # 80000bfe <acquire>
        if(np->state == ZOMBIE){
    8000230c:	4c9c                	lw	a5,24(s1)
    8000230e:	f94787e3          	beq	a5,s4,8000229c <wait+0x44>
        release(&np->lock);
    80002312:	8526                	mv	a0,s1
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	99e080e7          	jalr	-1634(ra) # 80000cb2 <release>
        havekids = 1;
    8000231c:	8756                	mv	a4,s5
    8000231e:	bfd9                	j	800022f4 <wait+0x9c>
    if(!havekids || p->killed){
    80002320:	c701                	beqz	a4,80002328 <wait+0xd0>
    80002322:	03092783          	lw	a5,48(s2)
    80002326:	c39d                	beqz	a5,8000234c <wait+0xf4>
      release(&p->lock);
    80002328:	854a                	mv	a0,s2
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	988080e7          	jalr	-1656(ra) # 80000cb2 <release>
      return -1;
    80002332:	59fd                	li	s3,-1
}
    80002334:	854e                	mv	a0,s3
    80002336:	60a6                	ld	ra,72(sp)
    80002338:	6406                	ld	s0,64(sp)
    8000233a:	74e2                	ld	s1,56(sp)
    8000233c:	7942                	ld	s2,48(sp)
    8000233e:	79a2                	ld	s3,40(sp)
    80002340:	7a02                	ld	s4,32(sp)
    80002342:	6ae2                	ld	s5,24(sp)
    80002344:	6b42                	ld	s6,16(sp)
    80002346:	6ba2                	ld	s7,8(sp)
    80002348:	6161                	addi	sp,sp,80
    8000234a:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000234c:	85ca                	mv	a1,s2
    8000234e:	854a                	mv	a0,s2
    80002350:	00000097          	auipc	ra,0x0
    80002354:	e8a080e7          	jalr	-374(ra) # 800021da <sleep>
    havekids = 0;
    80002358:	bf25                	j	80002290 <wait+0x38>

000000008000235a <wakeup>:
{
    8000235a:	7139                	addi	sp,sp,-64
    8000235c:	fc06                	sd	ra,56(sp)
    8000235e:	f822                	sd	s0,48(sp)
    80002360:	f426                	sd	s1,40(sp)
    80002362:	f04a                	sd	s2,32(sp)
    80002364:	ec4e                	sd	s3,24(sp)
    80002366:	e852                	sd	s4,16(sp)
    80002368:	e456                	sd	s5,8(sp)
    8000236a:	0080                	addi	s0,sp,64
    8000236c:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000236e:	00010497          	auipc	s1,0x10
    80002372:	9fa48493          	addi	s1,s1,-1542 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002376:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002378:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000237a:	00015917          	auipc	s2,0x15
    8000237e:	3ee90913          	addi	s2,s2,1006 # 80017768 <tickslock>
    80002382:	a811                	j	80002396 <wakeup+0x3c>
    release(&p->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	92c080e7          	jalr	-1748(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000238e:	16848493          	addi	s1,s1,360
    80002392:	03248063          	beq	s1,s2,800023b2 <wakeup+0x58>
    acquire(&p->lock);
    80002396:	8526                	mv	a0,s1
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	866080e7          	jalr	-1946(ra) # 80000bfe <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023a0:	4c9c                	lw	a5,24(s1)
    800023a2:	ff3791e3          	bne	a5,s3,80002384 <wakeup+0x2a>
    800023a6:	749c                	ld	a5,40(s1)
    800023a8:	fd479ee3          	bne	a5,s4,80002384 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023ac:	0154ac23          	sw	s5,24(s1)
    800023b0:	bfd1                	j	80002384 <wakeup+0x2a>
}
    800023b2:	70e2                	ld	ra,56(sp)
    800023b4:	7442                	ld	s0,48(sp)
    800023b6:	74a2                	ld	s1,40(sp)
    800023b8:	7902                	ld	s2,32(sp)
    800023ba:	69e2                	ld	s3,24(sp)
    800023bc:	6a42                	ld	s4,16(sp)
    800023be:	6aa2                	ld	s5,8(sp)
    800023c0:	6121                	addi	sp,sp,64
    800023c2:	8082                	ret

00000000800023c4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023c4:	7179                	addi	sp,sp,-48
    800023c6:	f406                	sd	ra,40(sp)
    800023c8:	f022                	sd	s0,32(sp)
    800023ca:	ec26                	sd	s1,24(sp)
    800023cc:	e84a                	sd	s2,16(sp)
    800023ce:	e44e                	sd	s3,8(sp)
    800023d0:	1800                	addi	s0,sp,48
    800023d2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023d4:	00010497          	auipc	s1,0x10
    800023d8:	99448493          	addi	s1,s1,-1644 # 80011d68 <proc>
    800023dc:	00015997          	auipc	s3,0x15
    800023e0:	38c98993          	addi	s3,s3,908 # 80017768 <tickslock>
    acquire(&p->lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	818080e7          	jalr	-2024(ra) # 80000bfe <acquire>
    if(p->pid == pid){
    800023ee:	5c9c                	lw	a5,56(s1)
    800023f0:	01278d63          	beq	a5,s2,8000240a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023f4:	8526                	mv	a0,s1
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	8bc080e7          	jalr	-1860(ra) # 80000cb2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023fe:	16848493          	addi	s1,s1,360
    80002402:	ff3491e3          	bne	s1,s3,800023e4 <kill+0x20>
  }
  return -1;
    80002406:	557d                	li	a0,-1
    80002408:	a821                	j	80002420 <kill+0x5c>
      p->killed = 1;
    8000240a:	4785                	li	a5,1
    8000240c:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000240e:	4c98                	lw	a4,24(s1)
    80002410:	00f70f63          	beq	a4,a5,8000242e <kill+0x6a>
      release(&p->lock);
    80002414:	8526                	mv	a0,s1
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	89c080e7          	jalr	-1892(ra) # 80000cb2 <release>
      return 0;
    8000241e:	4501                	li	a0,0
}
    80002420:	70a2                	ld	ra,40(sp)
    80002422:	7402                	ld	s0,32(sp)
    80002424:	64e2                	ld	s1,24(sp)
    80002426:	6942                	ld	s2,16(sp)
    80002428:	69a2                	ld	s3,8(sp)
    8000242a:	6145                	addi	sp,sp,48
    8000242c:	8082                	ret
        p->state = RUNNABLE;
    8000242e:	4789                	li	a5,2
    80002430:	cc9c                	sw	a5,24(s1)
    80002432:	b7cd                	j	80002414 <kill+0x50>

0000000080002434 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002434:	7179                	addi	sp,sp,-48
    80002436:	f406                	sd	ra,40(sp)
    80002438:	f022                	sd	s0,32(sp)
    8000243a:	ec26                	sd	s1,24(sp)
    8000243c:	e84a                	sd	s2,16(sp)
    8000243e:	e44e                	sd	s3,8(sp)
    80002440:	e052                	sd	s4,0(sp)
    80002442:	1800                	addi	s0,sp,48
    80002444:	84aa                	mv	s1,a0
    80002446:	892e                	mv	s2,a1
    80002448:	89b2                	mv	s3,a2
    8000244a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	57e080e7          	jalr	1406(ra) # 800019ca <myproc>
  if(user_dst){
    80002454:	c08d                	beqz	s1,80002476 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002456:	86d2                	mv	a3,s4
    80002458:	864e                	mv	a2,s3
    8000245a:	85ca                	mv	a1,s2
    8000245c:	6928                	ld	a0,80(a0)
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	25e080e7          	jalr	606(ra) # 800016bc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002466:	70a2                	ld	ra,40(sp)
    80002468:	7402                	ld	s0,32(sp)
    8000246a:	64e2                	ld	s1,24(sp)
    8000246c:	6942                	ld	s2,16(sp)
    8000246e:	69a2                	ld	s3,8(sp)
    80002470:	6a02                	ld	s4,0(sp)
    80002472:	6145                	addi	sp,sp,48
    80002474:	8082                	ret
    memmove((char *)dst, src, len);
    80002476:	000a061b          	sext.w	a2,s4
    8000247a:	85ce                	mv	a1,s3
    8000247c:	854a                	mv	a0,s2
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	8d8080e7          	jalr	-1832(ra) # 80000d56 <memmove>
    return 0;
    80002486:	8526                	mv	a0,s1
    80002488:	bff9                	j	80002466 <either_copyout+0x32>

000000008000248a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000248a:	7179                	addi	sp,sp,-48
    8000248c:	f406                	sd	ra,40(sp)
    8000248e:	f022                	sd	s0,32(sp)
    80002490:	ec26                	sd	s1,24(sp)
    80002492:	e84a                	sd	s2,16(sp)
    80002494:	e44e                	sd	s3,8(sp)
    80002496:	e052                	sd	s4,0(sp)
    80002498:	1800                	addi	s0,sp,48
    8000249a:	892a                	mv	s2,a0
    8000249c:	84ae                	mv	s1,a1
    8000249e:	89b2                	mv	s3,a2
    800024a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	528080e7          	jalr	1320(ra) # 800019ca <myproc>
  if(user_src){
    800024aa:	c08d                	beqz	s1,800024cc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ac:	86d2                	mv	a3,s4
    800024ae:	864e                	mv	a2,s3
    800024b0:	85ca                	mv	a1,s2
    800024b2:	6928                	ld	a0,80(a0)
    800024b4:	fffff097          	auipc	ra,0xfffff
    800024b8:	294080e7          	jalr	660(ra) # 80001748 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024bc:	70a2                	ld	ra,40(sp)
    800024be:	7402                	ld	s0,32(sp)
    800024c0:	64e2                	ld	s1,24(sp)
    800024c2:	6942                	ld	s2,16(sp)
    800024c4:	69a2                	ld	s3,8(sp)
    800024c6:	6a02                	ld	s4,0(sp)
    800024c8:	6145                	addi	sp,sp,48
    800024ca:	8082                	ret
    memmove(dst, (char*)src, len);
    800024cc:	000a061b          	sext.w	a2,s4
    800024d0:	85ce                	mv	a1,s3
    800024d2:	854a                	mv	a0,s2
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	882080e7          	jalr	-1918(ra) # 80000d56 <memmove>
    return 0;
    800024dc:	8526                	mv	a0,s1
    800024de:	bff9                	j	800024bc <either_copyin+0x32>

00000000800024e0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024e0:	715d                	addi	sp,sp,-80
    800024e2:	e486                	sd	ra,72(sp)
    800024e4:	e0a2                	sd	s0,64(sp)
    800024e6:	fc26                	sd	s1,56(sp)
    800024e8:	f84a                	sd	s2,48(sp)
    800024ea:	f44e                	sd	s3,40(sp)
    800024ec:	f052                	sd	s4,32(sp)
    800024ee:	ec56                	sd	s5,24(sp)
    800024f0:	e85a                	sd	s6,16(sp)
    800024f2:	e45e                	sd	s7,8(sp)
    800024f4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800024f6:	00006517          	auipc	a0,0x6
    800024fa:	bd250513          	addi	a0,a0,-1070 # 800080c8 <digits+0x88>
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	08e080e7          	jalr	142(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002506:	00010497          	auipc	s1,0x10
    8000250a:	9ba48493          	addi	s1,s1,-1606 # 80011ec0 <proc+0x158>
    8000250e:	00015917          	auipc	s2,0x15
    80002512:	3b290913          	addi	s2,s2,946 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002516:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002518:	00006997          	auipc	s3,0x6
    8000251c:	d5098993          	addi	s3,s3,-688 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002520:	00006a97          	auipc	s5,0x6
    80002524:	d50a8a93          	addi	s5,s5,-688 # 80008270 <digits+0x230>
    printf("\n");
    80002528:	00006a17          	auipc	s4,0x6
    8000252c:	ba0a0a13          	addi	s4,s4,-1120 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002530:	00006b97          	auipc	s7,0x6
    80002534:	d78b8b93          	addi	s7,s7,-648 # 800082a8 <states.0>
    80002538:	a00d                	j	8000255a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000253a:	ee06a583          	lw	a1,-288(a3)
    8000253e:	8556                	mv	a0,s5
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	04c080e7          	jalr	76(ra) # 8000058c <printf>
    printf("\n");
    80002548:	8552                	mv	a0,s4
    8000254a:	ffffe097          	auipc	ra,0xffffe
    8000254e:	042080e7          	jalr	66(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002552:	16848493          	addi	s1,s1,360
    80002556:	03248263          	beq	s1,s2,8000257a <procdump+0x9a>
    if(p->state == UNUSED)
    8000255a:	86a6                	mv	a3,s1
    8000255c:	ec04a783          	lw	a5,-320(s1)
    80002560:	dbed                	beqz	a5,80002552 <procdump+0x72>
      state = "???";
    80002562:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002564:	fcfb6be3          	bltu	s6,a5,8000253a <procdump+0x5a>
    80002568:	02079713          	slli	a4,a5,0x20
    8000256c:	01d75793          	srli	a5,a4,0x1d
    80002570:	97de                	add	a5,a5,s7
    80002572:	6390                	ld	a2,0(a5)
    80002574:	f279                	bnez	a2,8000253a <procdump+0x5a>
      state = "???";
    80002576:	864e                	mv	a2,s3
    80002578:	b7c9                	j	8000253a <procdump+0x5a>
  }
}
    8000257a:	60a6                	ld	ra,72(sp)
    8000257c:	6406                	ld	s0,64(sp)
    8000257e:	74e2                	ld	s1,56(sp)
    80002580:	7942                	ld	s2,48(sp)
    80002582:	79a2                	ld	s3,40(sp)
    80002584:	7a02                	ld	s4,32(sp)
    80002586:	6ae2                	ld	s5,24(sp)
    80002588:	6b42                	ld	s6,16(sp)
    8000258a:	6ba2                	ld	s7,8(sp)
    8000258c:	6161                	addi	sp,sp,80
    8000258e:	8082                	ret

0000000080002590 <swtch>:
    80002590:	00153023          	sd	ra,0(a0)
    80002594:	00253423          	sd	sp,8(a0)
    80002598:	e900                	sd	s0,16(a0)
    8000259a:	ed04                	sd	s1,24(a0)
    8000259c:	03253023          	sd	s2,32(a0)
    800025a0:	03353423          	sd	s3,40(a0)
    800025a4:	03453823          	sd	s4,48(a0)
    800025a8:	03553c23          	sd	s5,56(a0)
    800025ac:	05653023          	sd	s6,64(a0)
    800025b0:	05753423          	sd	s7,72(a0)
    800025b4:	05853823          	sd	s8,80(a0)
    800025b8:	05953c23          	sd	s9,88(a0)
    800025bc:	07a53023          	sd	s10,96(a0)
    800025c0:	07b53423          	sd	s11,104(a0)
    800025c4:	0005b083          	ld	ra,0(a1)
    800025c8:	0085b103          	ld	sp,8(a1)
    800025cc:	6980                	ld	s0,16(a1)
    800025ce:	6d84                	ld	s1,24(a1)
    800025d0:	0205b903          	ld	s2,32(a1)
    800025d4:	0285b983          	ld	s3,40(a1)
    800025d8:	0305ba03          	ld	s4,48(a1)
    800025dc:	0385ba83          	ld	s5,56(a1)
    800025e0:	0405bb03          	ld	s6,64(a1)
    800025e4:	0485bb83          	ld	s7,72(a1)
    800025e8:	0505bc03          	ld	s8,80(a1)
    800025ec:	0585bc83          	ld	s9,88(a1)
    800025f0:	0605bd03          	ld	s10,96(a1)
    800025f4:	0685bd83          	ld	s11,104(a1)
    800025f8:	8082                	ret

00000000800025fa <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800025fa:	1141                	addi	sp,sp,-16
    800025fc:	e406                	sd	ra,8(sp)
    800025fe:	e022                	sd	s0,0(sp)
    80002600:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002602:	00006597          	auipc	a1,0x6
    80002606:	cce58593          	addi	a1,a1,-818 # 800082d0 <states.0+0x28>
    8000260a:	00015517          	auipc	a0,0x15
    8000260e:	15e50513          	addi	a0,a0,350 # 80017768 <tickslock>
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	55c080e7          	jalr	1372(ra) # 80000b6e <initlock>
}
    8000261a:	60a2                	ld	ra,8(sp)
    8000261c:	6402                	ld	s0,0(sp)
    8000261e:	0141                	addi	sp,sp,16
    80002620:	8082                	ret

0000000080002622 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002622:	1141                	addi	sp,sp,-16
    80002624:	e422                	sd	s0,8(sp)
    80002626:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002628:	00003797          	auipc	a5,0x3
    8000262c:	4b878793          	addi	a5,a5,1208 # 80005ae0 <kernelvec>
    80002630:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002634:	6422                	ld	s0,8(sp)
    80002636:	0141                	addi	sp,sp,16
    80002638:	8082                	ret

000000008000263a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000263a:	1141                	addi	sp,sp,-16
    8000263c:	e406                	sd	ra,8(sp)
    8000263e:	e022                	sd	s0,0(sp)
    80002640:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002642:	fffff097          	auipc	ra,0xfffff
    80002646:	388080e7          	jalr	904(ra) # 800019ca <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000264a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000264e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002650:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002654:	00005617          	auipc	a2,0x5
    80002658:	9ac60613          	addi	a2,a2,-1620 # 80007000 <_trampoline>
    8000265c:	00005697          	auipc	a3,0x5
    80002660:	9a468693          	addi	a3,a3,-1628 # 80007000 <_trampoline>
    80002664:	8e91                	sub	a3,a3,a2
    80002666:	040007b7          	lui	a5,0x4000
    8000266a:	17fd                	addi	a5,a5,-1
    8000266c:	07b2                	slli	a5,a5,0xc
    8000266e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002670:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002674:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002676:	180026f3          	csrr	a3,satp
    8000267a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000267c:	6d38                	ld	a4,88(a0)
    8000267e:	6134                	ld	a3,64(a0)
    80002680:	6585                	lui	a1,0x1
    80002682:	96ae                	add	a3,a3,a1
    80002684:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002686:	6d38                	ld	a4,88(a0)
    80002688:	00000697          	auipc	a3,0x0
    8000268c:	13868693          	addi	a3,a3,312 # 800027c0 <usertrap>
    80002690:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002692:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002694:	8692                	mv	a3,tp
    80002696:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002698:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000269c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026a0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026a8:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026aa:	6f18                	ld	a4,24(a4)
    800026ac:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026b0:	692c                	ld	a1,80(a0)
    800026b2:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026b4:	00005717          	auipc	a4,0x5
    800026b8:	9dc70713          	addi	a4,a4,-1572 # 80007090 <userret>
    800026bc:	8f11                	sub	a4,a4,a2
    800026be:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026c0:	577d                	li	a4,-1
    800026c2:	177e                	slli	a4,a4,0x3f
    800026c4:	8dd9                	or	a1,a1,a4
    800026c6:	02000537          	lui	a0,0x2000
    800026ca:	157d                	addi	a0,a0,-1
    800026cc:	0536                	slli	a0,a0,0xd
    800026ce:	9782                	jalr	a5
}
    800026d0:	60a2                	ld	ra,8(sp)
    800026d2:	6402                	ld	s0,0(sp)
    800026d4:	0141                	addi	sp,sp,16
    800026d6:	8082                	ret

00000000800026d8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026d8:	1101                	addi	sp,sp,-32
    800026da:	ec06                	sd	ra,24(sp)
    800026dc:	e822                	sd	s0,16(sp)
    800026de:	e426                	sd	s1,8(sp)
    800026e0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026e2:	00015497          	auipc	s1,0x15
    800026e6:	08648493          	addi	s1,s1,134 # 80017768 <tickslock>
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	512080e7          	jalr	1298(ra) # 80000bfe <acquire>
  ticks++;
    800026f4:	00007517          	auipc	a0,0x7
    800026f8:	92c50513          	addi	a0,a0,-1748 # 80009020 <ticks>
    800026fc:	411c                	lw	a5,0(a0)
    800026fe:	2785                	addiw	a5,a5,1
    80002700:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002702:	00000097          	auipc	ra,0x0
    80002706:	c58080e7          	jalr	-936(ra) # 8000235a <wakeup>
  release(&tickslock);
    8000270a:	8526                	mv	a0,s1
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	5a6080e7          	jalr	1446(ra) # 80000cb2 <release>
}
    80002714:	60e2                	ld	ra,24(sp)
    80002716:	6442                	ld	s0,16(sp)
    80002718:	64a2                	ld	s1,8(sp)
    8000271a:	6105                	addi	sp,sp,32
    8000271c:	8082                	ret

000000008000271e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000271e:	1101                	addi	sp,sp,-32
    80002720:	ec06                	sd	ra,24(sp)
    80002722:	e822                	sd	s0,16(sp)
    80002724:	e426                	sd	s1,8(sp)
    80002726:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002728:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000272c:	00074d63          	bltz	a4,80002746 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002730:	57fd                	li	a5,-1
    80002732:	17fe                	slli	a5,a5,0x3f
    80002734:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002736:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002738:	06f70363          	beq	a4,a5,8000279e <devintr+0x80>
  }
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	64a2                	ld	s1,8(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
     (scause & 0xff) == 9){
    80002746:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000274a:	46a5                	li	a3,9
    8000274c:	fed792e3          	bne	a5,a3,80002730 <devintr+0x12>
    int irq = plic_claim();
    80002750:	00003097          	auipc	ra,0x3
    80002754:	498080e7          	jalr	1176(ra) # 80005be8 <plic_claim>
    80002758:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000275a:	47a9                	li	a5,10
    8000275c:	02f50763          	beq	a0,a5,8000278a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002760:	4785                	li	a5,1
    80002762:	02f50963          	beq	a0,a5,80002794 <devintr+0x76>
    return 1;
    80002766:	4505                	li	a0,1
    } else if(irq){
    80002768:	d8f1                	beqz	s1,8000273c <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000276a:	85a6                	mv	a1,s1
    8000276c:	00006517          	auipc	a0,0x6
    80002770:	b6c50513          	addi	a0,a0,-1172 # 800082d8 <states.0+0x30>
    80002774:	ffffe097          	auipc	ra,0xffffe
    80002778:	e18080e7          	jalr	-488(ra) # 8000058c <printf>
      plic_complete(irq);
    8000277c:	8526                	mv	a0,s1
    8000277e:	00003097          	auipc	ra,0x3
    80002782:	48e080e7          	jalr	1166(ra) # 80005c0c <plic_complete>
    return 1;
    80002786:	4505                	li	a0,1
    80002788:	bf55                	j	8000273c <devintr+0x1e>
      uartintr();
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	238080e7          	jalr	568(ra) # 800009c2 <uartintr>
    80002792:	b7ed                	j	8000277c <devintr+0x5e>
      virtio_disk_intr();
    80002794:	00004097          	auipc	ra,0x4
    80002798:	8f2080e7          	jalr	-1806(ra) # 80006086 <virtio_disk_intr>
    8000279c:	b7c5                	j	8000277c <devintr+0x5e>
    if(cpuid() == 0){
    8000279e:	fffff097          	auipc	ra,0xfffff
    800027a2:	200080e7          	jalr	512(ra) # 8000199e <cpuid>
    800027a6:	c901                	beqz	a0,800027b6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027a8:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027ac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ae:	14479073          	csrw	sip,a5
    return 2;
    800027b2:	4509                	li	a0,2
    800027b4:	b761                	j	8000273c <devintr+0x1e>
      clockintr();
    800027b6:	00000097          	auipc	ra,0x0
    800027ba:	f22080e7          	jalr	-222(ra) # 800026d8 <clockintr>
    800027be:	b7ed                	j	800027a8 <devintr+0x8a>

00000000800027c0 <usertrap>:
{
    800027c0:	1101                	addi	sp,sp,-32
    800027c2:	ec06                	sd	ra,24(sp)
    800027c4:	e822                	sd	s0,16(sp)
    800027c6:	e426                	sd	s1,8(sp)
    800027c8:	e04a                	sd	s2,0(sp)
    800027ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027cc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027d0:	1007f793          	andi	a5,a5,256
    800027d4:	e3ad                	bnez	a5,80002836 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d6:	00003797          	auipc	a5,0x3
    800027da:	30a78793          	addi	a5,a5,778 # 80005ae0 <kernelvec>
    800027de:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027e2:	fffff097          	auipc	ra,0xfffff
    800027e6:	1e8080e7          	jalr	488(ra) # 800019ca <myproc>
    800027ea:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027ec:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027ee:	14102773          	csrr	a4,sepc
    800027f2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027f8:	47a1                	li	a5,8
    800027fa:	04f71c63          	bne	a4,a5,80002852 <usertrap+0x92>
    if(p->killed)
    800027fe:	591c                	lw	a5,48(a0)
    80002800:	e3b9                	bnez	a5,80002846 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002802:	6cb8                	ld	a4,88(s1)
    80002804:	6f1c                	ld	a5,24(a4)
    80002806:	0791                	addi	a5,a5,4
    80002808:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000280a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000280e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002812:	10079073          	csrw	sstatus,a5
    syscall();
    80002816:	00000097          	auipc	ra,0x0
    8000281a:	2e0080e7          	jalr	736(ra) # 80002af6 <syscall>
  if(p->killed)
    8000281e:	589c                	lw	a5,48(s1)
    80002820:	ebc1                	bnez	a5,800028b0 <usertrap+0xf0>
  usertrapret();
    80002822:	00000097          	auipc	ra,0x0
    80002826:	e18080e7          	jalr	-488(ra) # 8000263a <usertrapret>
}
    8000282a:	60e2                	ld	ra,24(sp)
    8000282c:	6442                	ld	s0,16(sp)
    8000282e:	64a2                	ld	s1,8(sp)
    80002830:	6902                	ld	s2,0(sp)
    80002832:	6105                	addi	sp,sp,32
    80002834:	8082                	ret
    panic("usertrap: not from user mode");
    80002836:	00006517          	auipc	a0,0x6
    8000283a:	ac250513          	addi	a0,a0,-1342 # 800082f8 <states.0+0x50>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	d04080e7          	jalr	-764(ra) # 80000542 <panic>
      exit(-1);
    80002846:	557d                	li	a0,-1
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	84c080e7          	jalr	-1972(ra) # 80002094 <exit>
    80002850:	bf4d                	j	80002802 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002852:	00000097          	auipc	ra,0x0
    80002856:	ecc080e7          	jalr	-308(ra) # 8000271e <devintr>
    8000285a:	892a                	mv	s2,a0
    8000285c:	c501                	beqz	a0,80002864 <usertrap+0xa4>
  if(p->killed)
    8000285e:	589c                	lw	a5,48(s1)
    80002860:	c3a1                	beqz	a5,800028a0 <usertrap+0xe0>
    80002862:	a815                	j	80002896 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002864:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002868:	5c90                	lw	a2,56(s1)
    8000286a:	00006517          	auipc	a0,0x6
    8000286e:	aae50513          	addi	a0,a0,-1362 # 80008318 <states.0+0x70>
    80002872:	ffffe097          	auipc	ra,0xffffe
    80002876:	d1a080e7          	jalr	-742(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000287a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000287e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002882:	00006517          	auipc	a0,0x6
    80002886:	ac650513          	addi	a0,a0,-1338 # 80008348 <states.0+0xa0>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	d02080e7          	jalr	-766(ra) # 8000058c <printf>
    p->killed = 1;
    80002892:	4785                	li	a5,1
    80002894:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002896:	557d                	li	a0,-1
    80002898:	fffff097          	auipc	ra,0xfffff
    8000289c:	7fc080e7          	jalr	2044(ra) # 80002094 <exit>
  if(which_dev == 2)
    800028a0:	4789                	li	a5,2
    800028a2:	f8f910e3          	bne	s2,a5,80002822 <usertrap+0x62>
    yield();
    800028a6:	00000097          	auipc	ra,0x0
    800028aa:	8f8080e7          	jalr	-1800(ra) # 8000219e <yield>
    800028ae:	bf95                	j	80002822 <usertrap+0x62>
  int which_dev = 0;
    800028b0:	4901                	li	s2,0
    800028b2:	b7d5                	j	80002896 <usertrap+0xd6>

00000000800028b4 <kerneltrap>:
{
    800028b4:	7179                	addi	sp,sp,-48
    800028b6:	f406                	sd	ra,40(sp)
    800028b8:	f022                	sd	s0,32(sp)
    800028ba:	ec26                	sd	s1,24(sp)
    800028bc:	e84a                	sd	s2,16(sp)
    800028be:	e44e                	sd	s3,8(sp)
    800028c0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ca:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028ce:	1004f793          	andi	a5,s1,256
    800028d2:	cb85                	beqz	a5,80002902 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028d8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028da:	ef85                	bnez	a5,80002912 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028dc:	00000097          	auipc	ra,0x0
    800028e0:	e42080e7          	jalr	-446(ra) # 8000271e <devintr>
    800028e4:	cd1d                	beqz	a0,80002922 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028e6:	4789                	li	a5,2
    800028e8:	06f50a63          	beq	a0,a5,8000295c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028ec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f0:	10049073          	csrw	sstatus,s1
}
    800028f4:	70a2                	ld	ra,40(sp)
    800028f6:	7402                	ld	s0,32(sp)
    800028f8:	64e2                	ld	s1,24(sp)
    800028fa:	6942                	ld	s2,16(sp)
    800028fc:	69a2                	ld	s3,8(sp)
    800028fe:	6145                	addi	sp,sp,48
    80002900:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002902:	00006517          	auipc	a0,0x6
    80002906:	a6650513          	addi	a0,a0,-1434 # 80008368 <states.0+0xc0>
    8000290a:	ffffe097          	auipc	ra,0xffffe
    8000290e:	c38080e7          	jalr	-968(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002912:	00006517          	auipc	a0,0x6
    80002916:	a7e50513          	addi	a0,a0,-1410 # 80008390 <states.0+0xe8>
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	c28080e7          	jalr	-984(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    80002922:	85ce                	mv	a1,s3
    80002924:	00006517          	auipc	a0,0x6
    80002928:	a8c50513          	addi	a0,a0,-1396 # 800083b0 <states.0+0x108>
    8000292c:	ffffe097          	auipc	ra,0xffffe
    80002930:	c60080e7          	jalr	-928(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002934:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002938:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000293c:	00006517          	auipc	a0,0x6
    80002940:	a8450513          	addi	a0,a0,-1404 # 800083c0 <states.0+0x118>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	c48080e7          	jalr	-952(ra) # 8000058c <printf>
    panic("kerneltrap");
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	a8c50513          	addi	a0,a0,-1396 # 800083d8 <states.0+0x130>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	bee080e7          	jalr	-1042(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000295c:	fffff097          	auipc	ra,0xfffff
    80002960:	06e080e7          	jalr	110(ra) # 800019ca <myproc>
    80002964:	d541                	beqz	a0,800028ec <kerneltrap+0x38>
    80002966:	fffff097          	auipc	ra,0xfffff
    8000296a:	064080e7          	jalr	100(ra) # 800019ca <myproc>
    8000296e:	4d18                	lw	a4,24(a0)
    80002970:	478d                	li	a5,3
    80002972:	f6f71de3          	bne	a4,a5,800028ec <kerneltrap+0x38>
    yield();
    80002976:	00000097          	auipc	ra,0x0
    8000297a:	828080e7          	jalr	-2008(ra) # 8000219e <yield>
    8000297e:	b7bd                	j	800028ec <kerneltrap+0x38>

0000000080002980 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002980:	1101                	addi	sp,sp,-32
    80002982:	ec06                	sd	ra,24(sp)
    80002984:	e822                	sd	s0,16(sp)
    80002986:	e426                	sd	s1,8(sp)
    80002988:	1000                	addi	s0,sp,32
    8000298a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000298c:	fffff097          	auipc	ra,0xfffff
    80002990:	03e080e7          	jalr	62(ra) # 800019ca <myproc>
  switch (n) {
    80002994:	4795                	li	a5,5
    80002996:	0497e163          	bltu	a5,s1,800029d8 <argraw+0x58>
    8000299a:	048a                	slli	s1,s1,0x2
    8000299c:	00006717          	auipc	a4,0x6
    800029a0:	a7470713          	addi	a4,a4,-1420 # 80008410 <states.0+0x168>
    800029a4:	94ba                	add	s1,s1,a4
    800029a6:	409c                	lw	a5,0(s1)
    800029a8:	97ba                	add	a5,a5,a4
    800029aa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029ac:	6d3c                	ld	a5,88(a0)
    800029ae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029b0:	60e2                	ld	ra,24(sp)
    800029b2:	6442                	ld	s0,16(sp)
    800029b4:	64a2                	ld	s1,8(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret
    return p->trapframe->a1;
    800029ba:	6d3c                	ld	a5,88(a0)
    800029bc:	7fa8                	ld	a0,120(a5)
    800029be:	bfcd                	j	800029b0 <argraw+0x30>
    return p->trapframe->a2;
    800029c0:	6d3c                	ld	a5,88(a0)
    800029c2:	63c8                	ld	a0,128(a5)
    800029c4:	b7f5                	j	800029b0 <argraw+0x30>
    return p->trapframe->a3;
    800029c6:	6d3c                	ld	a5,88(a0)
    800029c8:	67c8                	ld	a0,136(a5)
    800029ca:	b7dd                	j	800029b0 <argraw+0x30>
    return p->trapframe->a4;
    800029cc:	6d3c                	ld	a5,88(a0)
    800029ce:	6bc8                	ld	a0,144(a5)
    800029d0:	b7c5                	j	800029b0 <argraw+0x30>
    return p->trapframe->a5;
    800029d2:	6d3c                	ld	a5,88(a0)
    800029d4:	6fc8                	ld	a0,152(a5)
    800029d6:	bfe9                	j	800029b0 <argraw+0x30>
  panic("argraw");
    800029d8:	00006517          	auipc	a0,0x6
    800029dc:	a1050513          	addi	a0,a0,-1520 # 800083e8 <states.0+0x140>
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	b62080e7          	jalr	-1182(ra) # 80000542 <panic>

00000000800029e8 <fetchaddr>:
{
    800029e8:	1101                	addi	sp,sp,-32
    800029ea:	ec06                	sd	ra,24(sp)
    800029ec:	e822                	sd	s0,16(sp)
    800029ee:	e426                	sd	s1,8(sp)
    800029f0:	e04a                	sd	s2,0(sp)
    800029f2:	1000                	addi	s0,sp,32
    800029f4:	84aa                	mv	s1,a0
    800029f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	fd2080e7          	jalr	-46(ra) # 800019ca <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a00:	653c                	ld	a5,72(a0)
    80002a02:	02f4f863          	bgeu	s1,a5,80002a32 <fetchaddr+0x4a>
    80002a06:	00848713          	addi	a4,s1,8
    80002a0a:	02e7e663          	bltu	a5,a4,80002a36 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a0e:	46a1                	li	a3,8
    80002a10:	8626                	mv	a2,s1
    80002a12:	85ca                	mv	a1,s2
    80002a14:	6928                	ld	a0,80(a0)
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	d32080e7          	jalr	-718(ra) # 80001748 <copyin>
    80002a1e:	00a03533          	snez	a0,a0
    80002a22:	40a00533          	neg	a0,a0
}
    80002a26:	60e2                	ld	ra,24(sp)
    80002a28:	6442                	ld	s0,16(sp)
    80002a2a:	64a2                	ld	s1,8(sp)
    80002a2c:	6902                	ld	s2,0(sp)
    80002a2e:	6105                	addi	sp,sp,32
    80002a30:	8082                	ret
    return -1;
    80002a32:	557d                	li	a0,-1
    80002a34:	bfcd                	j	80002a26 <fetchaddr+0x3e>
    80002a36:	557d                	li	a0,-1
    80002a38:	b7fd                	j	80002a26 <fetchaddr+0x3e>

0000000080002a3a <fetchstr>:
{
    80002a3a:	7179                	addi	sp,sp,-48
    80002a3c:	f406                	sd	ra,40(sp)
    80002a3e:	f022                	sd	s0,32(sp)
    80002a40:	ec26                	sd	s1,24(sp)
    80002a42:	e84a                	sd	s2,16(sp)
    80002a44:	e44e                	sd	s3,8(sp)
    80002a46:	1800                	addi	s0,sp,48
    80002a48:	892a                	mv	s2,a0
    80002a4a:	84ae                	mv	s1,a1
    80002a4c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	f7c080e7          	jalr	-132(ra) # 800019ca <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a56:	86ce                	mv	a3,s3
    80002a58:	864a                	mv	a2,s2
    80002a5a:	85a6                	mv	a1,s1
    80002a5c:	6928                	ld	a0,80(a0)
    80002a5e:	fffff097          	auipc	ra,0xfffff
    80002a62:	d78080e7          	jalr	-648(ra) # 800017d6 <copyinstr>
  if(err < 0)
    80002a66:	00054763          	bltz	a0,80002a74 <fetchstr+0x3a>
  return strlen(buf);
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	412080e7          	jalr	1042(ra) # 80000e7e <strlen>
}
    80002a74:	70a2                	ld	ra,40(sp)
    80002a76:	7402                	ld	s0,32(sp)
    80002a78:	64e2                	ld	s1,24(sp)
    80002a7a:	6942                	ld	s2,16(sp)
    80002a7c:	69a2                	ld	s3,8(sp)
    80002a7e:	6145                	addi	sp,sp,48
    80002a80:	8082                	ret

0000000080002a82 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a82:	1101                	addi	sp,sp,-32
    80002a84:	ec06                	sd	ra,24(sp)
    80002a86:	e822                	sd	s0,16(sp)
    80002a88:	e426                	sd	s1,8(sp)
    80002a8a:	1000                	addi	s0,sp,32
    80002a8c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a8e:	00000097          	auipc	ra,0x0
    80002a92:	ef2080e7          	jalr	-270(ra) # 80002980 <argraw>
    80002a96:	c088                	sw	a0,0(s1)
  return 0;
}
    80002a98:	4501                	li	a0,0
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	64a2                	ld	s1,8(sp)
    80002aa0:	6105                	addi	sp,sp,32
    80002aa2:	8082                	ret

0000000080002aa4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002aa4:	1101                	addi	sp,sp,-32
    80002aa6:	ec06                	sd	ra,24(sp)
    80002aa8:	e822                	sd	s0,16(sp)
    80002aaa:	e426                	sd	s1,8(sp)
    80002aac:	1000                	addi	s0,sp,32
    80002aae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ab0:	00000097          	auipc	ra,0x0
    80002ab4:	ed0080e7          	jalr	-304(ra) # 80002980 <argraw>
    80002ab8:	e088                	sd	a0,0(s1)
  return 0;
}
    80002aba:	4501                	li	a0,0
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ac6:	1101                	addi	sp,sp,-32
    80002ac8:	ec06                	sd	ra,24(sp)
    80002aca:	e822                	sd	s0,16(sp)
    80002acc:	e426                	sd	s1,8(sp)
    80002ace:	e04a                	sd	s2,0(sp)
    80002ad0:	1000                	addi	s0,sp,32
    80002ad2:	84ae                	mv	s1,a1
    80002ad4:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	eaa080e7          	jalr	-342(ra) # 80002980 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ade:	864a                	mv	a2,s2
    80002ae0:	85a6                	mv	a1,s1
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	f58080e7          	jalr	-168(ra) # 80002a3a <fetchstr>
}
    80002aea:	60e2                	ld	ra,24(sp)
    80002aec:	6442                	ld	s0,16(sp)
    80002aee:	64a2                	ld	s1,8(sp)
    80002af0:	6902                	ld	s2,0(sp)
    80002af2:	6105                	addi	sp,sp,32
    80002af4:	8082                	ret

0000000080002af6 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	e426                	sd	s1,8(sp)
    80002afe:	e04a                	sd	s2,0(sp)
    80002b00:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	ec8080e7          	jalr	-312(ra) # 800019ca <myproc>
    80002b0a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b0c:	05853903          	ld	s2,88(a0)
    80002b10:	0a893783          	ld	a5,168(s2)
    80002b14:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b18:	37fd                	addiw	a5,a5,-1
    80002b1a:	4751                	li	a4,20
    80002b1c:	00f76f63          	bltu	a4,a5,80002b3a <syscall+0x44>
    80002b20:	00369713          	slli	a4,a3,0x3
    80002b24:	00006797          	auipc	a5,0x6
    80002b28:	90478793          	addi	a5,a5,-1788 # 80008428 <syscalls>
    80002b2c:	97ba                	add	a5,a5,a4
    80002b2e:	639c                	ld	a5,0(a5)
    80002b30:	c789                	beqz	a5,80002b3a <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b32:	9782                	jalr	a5
    80002b34:	06a93823          	sd	a0,112(s2)
    80002b38:	a839                	j	80002b56 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b3a:	15848613          	addi	a2,s1,344
    80002b3e:	5c8c                	lw	a1,56(s1)
    80002b40:	00006517          	auipc	a0,0x6
    80002b44:	8b050513          	addi	a0,a0,-1872 # 800083f0 <states.0+0x148>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a44080e7          	jalr	-1468(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b50:	6cbc                	ld	a5,88(s1)
    80002b52:	577d                	li	a4,-1
    80002b54:	fbb8                	sd	a4,112(a5)
  }
}
    80002b56:	60e2                	ld	ra,24(sp)
    80002b58:	6442                	ld	s0,16(sp)
    80002b5a:	64a2                	ld	s1,8(sp)
    80002b5c:	6902                	ld	s2,0(sp)
    80002b5e:	6105                	addi	sp,sp,32
    80002b60:	8082                	ret

0000000080002b62 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b62:	1101                	addi	sp,sp,-32
    80002b64:	ec06                	sd	ra,24(sp)
    80002b66:	e822                	sd	s0,16(sp)
    80002b68:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b6a:	fec40593          	addi	a1,s0,-20
    80002b6e:	4501                	li	a0,0
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	f12080e7          	jalr	-238(ra) # 80002a82 <argint>
    return -1;
    80002b78:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b7a:	00054963          	bltz	a0,80002b8c <sys_exit+0x2a>
  exit(n);
    80002b7e:	fec42503          	lw	a0,-20(s0)
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	512080e7          	jalr	1298(ra) # 80002094 <exit>
  return 0;  // not reached
    80002b8a:	4781                	li	a5,0
}
    80002b8c:	853e                	mv	a0,a5
    80002b8e:	60e2                	ld	ra,24(sp)
    80002b90:	6442                	ld	s0,16(sp)
    80002b92:	6105                	addi	sp,sp,32
    80002b94:	8082                	ret

0000000080002b96 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b96:	1141                	addi	sp,sp,-16
    80002b98:	e406                	sd	ra,8(sp)
    80002b9a:	e022                	sd	s0,0(sp)
    80002b9c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	e2c080e7          	jalr	-468(ra) # 800019ca <myproc>
}
    80002ba6:	5d08                	lw	a0,56(a0)
    80002ba8:	60a2                	ld	ra,8(sp)
    80002baa:	6402                	ld	s0,0(sp)
    80002bac:	0141                	addi	sp,sp,16
    80002bae:	8082                	ret

0000000080002bb0 <sys_fork>:

uint64
sys_fork(void)
{
    80002bb0:	1141                	addi	sp,sp,-16
    80002bb2:	e406                	sd	ra,8(sp)
    80002bb4:	e022                	sd	s0,0(sp)
    80002bb6:	0800                	addi	s0,sp,16
  return fork();
    80002bb8:	fffff097          	auipc	ra,0xfffff
    80002bbc:	1d2080e7          	jalr	466(ra) # 80001d8a <fork>
}
    80002bc0:	60a2                	ld	ra,8(sp)
    80002bc2:	6402                	ld	s0,0(sp)
    80002bc4:	0141                	addi	sp,sp,16
    80002bc6:	8082                	ret

0000000080002bc8 <sys_wait>:

uint64
sys_wait(void)
{
    80002bc8:	1101                	addi	sp,sp,-32
    80002bca:	ec06                	sd	ra,24(sp)
    80002bcc:	e822                	sd	s0,16(sp)
    80002bce:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002bd0:	fe840593          	addi	a1,s0,-24
    80002bd4:	4501                	li	a0,0
    80002bd6:	00000097          	auipc	ra,0x0
    80002bda:	ece080e7          	jalr	-306(ra) # 80002aa4 <argaddr>
    80002bde:	87aa                	mv	a5,a0
    return -1;
    80002be0:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002be2:	0007c863          	bltz	a5,80002bf2 <sys_wait+0x2a>
  return wait(p);
    80002be6:	fe843503          	ld	a0,-24(s0)
    80002bea:	fffff097          	auipc	ra,0xfffff
    80002bee:	66e080e7          	jalr	1646(ra) # 80002258 <wait>
}
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	6105                	addi	sp,sp,32
    80002bf8:	8082                	ret

0000000080002bfa <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002bfa:	7179                	addi	sp,sp,-48
    80002bfc:	f406                	sd	ra,40(sp)
    80002bfe:	f022                	sd	s0,32(sp)
    80002c00:	ec26                	sd	s1,24(sp)
    80002c02:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c04:	fdc40593          	addi	a1,s0,-36
    80002c08:	4501                	li	a0,0
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	e78080e7          	jalr	-392(ra) # 80002a82 <argint>
    return -1;
    80002c12:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002c14:	00054f63          	bltz	a0,80002c32 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002c18:	fffff097          	auipc	ra,0xfffff
    80002c1c:	db2080e7          	jalr	-590(ra) # 800019ca <myproc>
    80002c20:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c22:	fdc42503          	lw	a0,-36(s0)
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	0f0080e7          	jalr	240(ra) # 80001d16 <growproc>
    80002c2e:	00054863          	bltz	a0,80002c3e <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002c32:	8526                	mv	a0,s1
    80002c34:	70a2                	ld	ra,40(sp)
    80002c36:	7402                	ld	s0,32(sp)
    80002c38:	64e2                	ld	s1,24(sp)
    80002c3a:	6145                	addi	sp,sp,48
    80002c3c:	8082                	ret
    return -1;
    80002c3e:	54fd                	li	s1,-1
    80002c40:	bfcd                	j	80002c32 <sys_sbrk+0x38>

0000000080002c42 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c42:	7139                	addi	sp,sp,-64
    80002c44:	fc06                	sd	ra,56(sp)
    80002c46:	f822                	sd	s0,48(sp)
    80002c48:	f426                	sd	s1,40(sp)
    80002c4a:	f04a                	sd	s2,32(sp)
    80002c4c:	ec4e                	sd	s3,24(sp)
    80002c4e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c50:	fcc40593          	addi	a1,s0,-52
    80002c54:	4501                	li	a0,0
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	e2c080e7          	jalr	-468(ra) # 80002a82 <argint>
    return -1;
    80002c5e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c60:	06054563          	bltz	a0,80002cca <sys_sleep+0x88>
  acquire(&tickslock);
    80002c64:	00015517          	auipc	a0,0x15
    80002c68:	b0450513          	addi	a0,a0,-1276 # 80017768 <tickslock>
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	f92080e7          	jalr	-110(ra) # 80000bfe <acquire>
  ticks0 = ticks;
    80002c74:	00006917          	auipc	s2,0x6
    80002c78:	3ac92903          	lw	s2,940(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002c7c:	fcc42783          	lw	a5,-52(s0)
    80002c80:	cf85                	beqz	a5,80002cb8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c82:	00015997          	auipc	s3,0x15
    80002c86:	ae698993          	addi	s3,s3,-1306 # 80017768 <tickslock>
    80002c8a:	00006497          	auipc	s1,0x6
    80002c8e:	39648493          	addi	s1,s1,918 # 80009020 <ticks>
    if(myproc()->killed){
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	d38080e7          	jalr	-712(ra) # 800019ca <myproc>
    80002c9a:	591c                	lw	a5,48(a0)
    80002c9c:	ef9d                	bnez	a5,80002cda <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002c9e:	85ce                	mv	a1,s3
    80002ca0:	8526                	mv	a0,s1
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	538080e7          	jalr	1336(ra) # 800021da <sleep>
  while(ticks - ticks0 < n){
    80002caa:	409c                	lw	a5,0(s1)
    80002cac:	412787bb          	subw	a5,a5,s2
    80002cb0:	fcc42703          	lw	a4,-52(s0)
    80002cb4:	fce7efe3          	bltu	a5,a4,80002c92 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002cb8:	00015517          	auipc	a0,0x15
    80002cbc:	ab050513          	addi	a0,a0,-1360 # 80017768 <tickslock>
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	ff2080e7          	jalr	-14(ra) # 80000cb2 <release>
  return 0;
    80002cc8:	4781                	li	a5,0
}
    80002cca:	853e                	mv	a0,a5
    80002ccc:	70e2                	ld	ra,56(sp)
    80002cce:	7442                	ld	s0,48(sp)
    80002cd0:	74a2                	ld	s1,40(sp)
    80002cd2:	7902                	ld	s2,32(sp)
    80002cd4:	69e2                	ld	s3,24(sp)
    80002cd6:	6121                	addi	sp,sp,64
    80002cd8:	8082                	ret
      release(&tickslock);
    80002cda:	00015517          	auipc	a0,0x15
    80002cde:	a8e50513          	addi	a0,a0,-1394 # 80017768 <tickslock>
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	fd0080e7          	jalr	-48(ra) # 80000cb2 <release>
      return -1;
    80002cea:	57fd                	li	a5,-1
    80002cec:	bff9                	j	80002cca <sys_sleep+0x88>

0000000080002cee <sys_kill>:

uint64
sys_kill(void)
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002cf6:	fec40593          	addi	a1,s0,-20
    80002cfa:	4501                	li	a0,0
    80002cfc:	00000097          	auipc	ra,0x0
    80002d00:	d86080e7          	jalr	-634(ra) # 80002a82 <argint>
    80002d04:	87aa                	mv	a5,a0
    return -1;
    80002d06:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d08:	0007c863          	bltz	a5,80002d18 <sys_kill+0x2a>
  return kill(pid);
    80002d0c:	fec42503          	lw	a0,-20(s0)
    80002d10:	fffff097          	auipc	ra,0xfffff
    80002d14:	6b4080e7          	jalr	1716(ra) # 800023c4 <kill>
}
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d2a:	00015517          	auipc	a0,0x15
    80002d2e:	a3e50513          	addi	a0,a0,-1474 # 80017768 <tickslock>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	ecc080e7          	jalr	-308(ra) # 80000bfe <acquire>
  xticks = ticks;
    80002d3a:	00006497          	auipc	s1,0x6
    80002d3e:	2e64a483          	lw	s1,742(s1) # 80009020 <ticks>
  release(&tickslock);
    80002d42:	00015517          	auipc	a0,0x15
    80002d46:	a2650513          	addi	a0,a0,-1498 # 80017768 <tickslock>
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	f68080e7          	jalr	-152(ra) # 80000cb2 <release>
  return xticks;
}
    80002d52:	02049513          	slli	a0,s1,0x20
    80002d56:	9101                	srli	a0,a0,0x20
    80002d58:	60e2                	ld	ra,24(sp)
    80002d5a:	6442                	ld	s0,16(sp)
    80002d5c:	64a2                	ld	s1,8(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d62:	7179                	addi	sp,sp,-48
    80002d64:	f406                	sd	ra,40(sp)
    80002d66:	f022                	sd	s0,32(sp)
    80002d68:	ec26                	sd	s1,24(sp)
    80002d6a:	e84a                	sd	s2,16(sp)
    80002d6c:	e44e                	sd	s3,8(sp)
    80002d6e:	e052                	sd	s4,0(sp)
    80002d70:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d72:	00005597          	auipc	a1,0x5
    80002d76:	76658593          	addi	a1,a1,1894 # 800084d8 <syscalls+0xb0>
    80002d7a:	00015517          	auipc	a0,0x15
    80002d7e:	a0650513          	addi	a0,a0,-1530 # 80017780 <bcache>
    80002d82:	ffffe097          	auipc	ra,0xffffe
    80002d86:	dec080e7          	jalr	-532(ra) # 80000b6e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d8a:	0001d797          	auipc	a5,0x1d
    80002d8e:	9f678793          	addi	a5,a5,-1546 # 8001f780 <bcache+0x8000>
    80002d92:	0001d717          	auipc	a4,0x1d
    80002d96:	c5670713          	addi	a4,a4,-938 # 8001f9e8 <bcache+0x8268>
    80002d9a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d9e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002da2:	00015497          	auipc	s1,0x15
    80002da6:	9f648493          	addi	s1,s1,-1546 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002daa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dae:	00005a17          	auipc	s4,0x5
    80002db2:	732a0a13          	addi	s4,s4,1842 # 800084e0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002db6:	2b893783          	ld	a5,696(s2)
    80002dba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dbc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dc0:	85d2                	mv	a1,s4
    80002dc2:	01048513          	addi	a0,s1,16
    80002dc6:	00001097          	auipc	ra,0x1
    80002dca:	4b2080e7          	jalr	1202(ra) # 80004278 <initsleeplock>
    bcache.head.next->prev = b;
    80002dce:	2b893783          	ld	a5,696(s2)
    80002dd2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dd4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dd8:	45848493          	addi	s1,s1,1112
    80002ddc:	fd349de3          	bne	s1,s3,80002db6 <binit+0x54>
  }
}
    80002de0:	70a2                	ld	ra,40(sp)
    80002de2:	7402                	ld	s0,32(sp)
    80002de4:	64e2                	ld	s1,24(sp)
    80002de6:	6942                	ld	s2,16(sp)
    80002de8:	69a2                	ld	s3,8(sp)
    80002dea:	6a02                	ld	s4,0(sp)
    80002dec:	6145                	addi	sp,sp,48
    80002dee:	8082                	ret

0000000080002df0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002df0:	7179                	addi	sp,sp,-48
    80002df2:	f406                	sd	ra,40(sp)
    80002df4:	f022                	sd	s0,32(sp)
    80002df6:	ec26                	sd	s1,24(sp)
    80002df8:	e84a                	sd	s2,16(sp)
    80002dfa:	e44e                	sd	s3,8(sp)
    80002dfc:	1800                	addi	s0,sp,48
    80002dfe:	892a                	mv	s2,a0
    80002e00:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e02:	00015517          	auipc	a0,0x15
    80002e06:	97e50513          	addi	a0,a0,-1666 # 80017780 <bcache>
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	df4080e7          	jalr	-524(ra) # 80000bfe <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e12:	0001d497          	auipc	s1,0x1d
    80002e16:	c264b483          	ld	s1,-986(s1) # 8001fa38 <bcache+0x82b8>
    80002e1a:	0001d797          	auipc	a5,0x1d
    80002e1e:	bce78793          	addi	a5,a5,-1074 # 8001f9e8 <bcache+0x8268>
    80002e22:	02f48f63          	beq	s1,a5,80002e60 <bread+0x70>
    80002e26:	873e                	mv	a4,a5
    80002e28:	a021                	j	80002e30 <bread+0x40>
    80002e2a:	68a4                	ld	s1,80(s1)
    80002e2c:	02e48a63          	beq	s1,a4,80002e60 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e30:	449c                	lw	a5,8(s1)
    80002e32:	ff279ce3          	bne	a5,s2,80002e2a <bread+0x3a>
    80002e36:	44dc                	lw	a5,12(s1)
    80002e38:	ff3799e3          	bne	a5,s3,80002e2a <bread+0x3a>
      b->refcnt++;
    80002e3c:	40bc                	lw	a5,64(s1)
    80002e3e:	2785                	addiw	a5,a5,1
    80002e40:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e42:	00015517          	auipc	a0,0x15
    80002e46:	93e50513          	addi	a0,a0,-1730 # 80017780 <bcache>
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	e68080e7          	jalr	-408(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    80002e52:	01048513          	addi	a0,s1,16
    80002e56:	00001097          	auipc	ra,0x1
    80002e5a:	45c080e7          	jalr	1116(ra) # 800042b2 <acquiresleep>
      return b;
    80002e5e:	a8b9                	j	80002ebc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e60:	0001d497          	auipc	s1,0x1d
    80002e64:	bd04b483          	ld	s1,-1072(s1) # 8001fa30 <bcache+0x82b0>
    80002e68:	0001d797          	auipc	a5,0x1d
    80002e6c:	b8078793          	addi	a5,a5,-1152 # 8001f9e8 <bcache+0x8268>
    80002e70:	00f48863          	beq	s1,a5,80002e80 <bread+0x90>
    80002e74:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e76:	40bc                	lw	a5,64(s1)
    80002e78:	cf81                	beqz	a5,80002e90 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e7a:	64a4                	ld	s1,72(s1)
    80002e7c:	fee49de3          	bne	s1,a4,80002e76 <bread+0x86>
  panic("bget: no buffers");
    80002e80:	00005517          	auipc	a0,0x5
    80002e84:	66850513          	addi	a0,a0,1640 # 800084e8 <syscalls+0xc0>
    80002e88:	ffffd097          	auipc	ra,0xffffd
    80002e8c:	6ba080e7          	jalr	1722(ra) # 80000542 <panic>
      b->dev = dev;
    80002e90:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002e94:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002e98:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002e9c:	4785                	li	a5,1
    80002e9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ea0:	00015517          	auipc	a0,0x15
    80002ea4:	8e050513          	addi	a0,a0,-1824 # 80017780 <bcache>
    80002ea8:	ffffe097          	auipc	ra,0xffffe
    80002eac:	e0a080e7          	jalr	-502(ra) # 80000cb2 <release>
      acquiresleep(&b->lock);
    80002eb0:	01048513          	addi	a0,s1,16
    80002eb4:	00001097          	auipc	ra,0x1
    80002eb8:	3fe080e7          	jalr	1022(ra) # 800042b2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ebc:	409c                	lw	a5,0(s1)
    80002ebe:	cb89                	beqz	a5,80002ed0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	70a2                	ld	ra,40(sp)
    80002ec4:	7402                	ld	s0,32(sp)
    80002ec6:	64e2                	ld	s1,24(sp)
    80002ec8:	6942                	ld	s2,16(sp)
    80002eca:	69a2                	ld	s3,8(sp)
    80002ecc:	6145                	addi	sp,sp,48
    80002ece:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ed0:	4581                	li	a1,0
    80002ed2:	8526                	mv	a0,s1
    80002ed4:	00003097          	auipc	ra,0x3
    80002ed8:	f28080e7          	jalr	-216(ra) # 80005dfc <virtio_disk_rw>
    b->valid = 1;
    80002edc:	4785                	li	a5,1
    80002ede:	c09c                	sw	a5,0(s1)
  return b;
    80002ee0:	b7c5                	j	80002ec0 <bread+0xd0>

0000000080002ee2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ee2:	1101                	addi	sp,sp,-32
    80002ee4:	ec06                	sd	ra,24(sp)
    80002ee6:	e822                	sd	s0,16(sp)
    80002ee8:	e426                	sd	s1,8(sp)
    80002eea:	1000                	addi	s0,sp,32
    80002eec:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002eee:	0541                	addi	a0,a0,16
    80002ef0:	00001097          	auipc	ra,0x1
    80002ef4:	45c080e7          	jalr	1116(ra) # 8000434c <holdingsleep>
    80002ef8:	cd01                	beqz	a0,80002f10 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002efa:	4585                	li	a1,1
    80002efc:	8526                	mv	a0,s1
    80002efe:	00003097          	auipc	ra,0x3
    80002f02:	efe080e7          	jalr	-258(ra) # 80005dfc <virtio_disk_rw>
}
    80002f06:	60e2                	ld	ra,24(sp)
    80002f08:	6442                	ld	s0,16(sp)
    80002f0a:	64a2                	ld	s1,8(sp)
    80002f0c:	6105                	addi	sp,sp,32
    80002f0e:	8082                	ret
    panic("bwrite");
    80002f10:	00005517          	auipc	a0,0x5
    80002f14:	5f050513          	addi	a0,a0,1520 # 80008500 <syscalls+0xd8>
    80002f18:	ffffd097          	auipc	ra,0xffffd
    80002f1c:	62a080e7          	jalr	1578(ra) # 80000542 <panic>

0000000080002f20 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f20:	1101                	addi	sp,sp,-32
    80002f22:	ec06                	sd	ra,24(sp)
    80002f24:	e822                	sd	s0,16(sp)
    80002f26:	e426                	sd	s1,8(sp)
    80002f28:	e04a                	sd	s2,0(sp)
    80002f2a:	1000                	addi	s0,sp,32
    80002f2c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f2e:	01050913          	addi	s2,a0,16
    80002f32:	854a                	mv	a0,s2
    80002f34:	00001097          	auipc	ra,0x1
    80002f38:	418080e7          	jalr	1048(ra) # 8000434c <holdingsleep>
    80002f3c:	c92d                	beqz	a0,80002fae <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f3e:	854a                	mv	a0,s2
    80002f40:	00001097          	auipc	ra,0x1
    80002f44:	3c8080e7          	jalr	968(ra) # 80004308 <releasesleep>

  acquire(&bcache.lock);
    80002f48:	00015517          	auipc	a0,0x15
    80002f4c:	83850513          	addi	a0,a0,-1992 # 80017780 <bcache>
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	cae080e7          	jalr	-850(ra) # 80000bfe <acquire>
  b->refcnt--;
    80002f58:	40bc                	lw	a5,64(s1)
    80002f5a:	37fd                	addiw	a5,a5,-1
    80002f5c:	0007871b          	sext.w	a4,a5
    80002f60:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f62:	eb05                	bnez	a4,80002f92 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f64:	68bc                	ld	a5,80(s1)
    80002f66:	64b8                	ld	a4,72(s1)
    80002f68:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f6a:	64bc                	ld	a5,72(s1)
    80002f6c:	68b8                	ld	a4,80(s1)
    80002f6e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f70:	0001d797          	auipc	a5,0x1d
    80002f74:	81078793          	addi	a5,a5,-2032 # 8001f780 <bcache+0x8000>
    80002f78:	2b87b703          	ld	a4,696(a5)
    80002f7c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f7e:	0001d717          	auipc	a4,0x1d
    80002f82:	a6a70713          	addi	a4,a4,-1430 # 8001f9e8 <bcache+0x8268>
    80002f86:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f88:	2b87b703          	ld	a4,696(a5)
    80002f8c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f8e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002f92:	00014517          	auipc	a0,0x14
    80002f96:	7ee50513          	addi	a0,a0,2030 # 80017780 <bcache>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	d18080e7          	jalr	-744(ra) # 80000cb2 <release>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	64a2                	ld	s1,8(sp)
    80002fa8:	6902                	ld	s2,0(sp)
    80002faa:	6105                	addi	sp,sp,32
    80002fac:	8082                	ret
    panic("brelse");
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	55a50513          	addi	a0,a0,1370 # 80008508 <syscalls+0xe0>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	58c080e7          	jalr	1420(ra) # 80000542 <panic>

0000000080002fbe <bpin>:

void
bpin(struct buf *b) {
    80002fbe:	1101                	addi	sp,sp,-32
    80002fc0:	ec06                	sd	ra,24(sp)
    80002fc2:	e822                	sd	s0,16(sp)
    80002fc4:	e426                	sd	s1,8(sp)
    80002fc6:	1000                	addi	s0,sp,32
    80002fc8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fca:	00014517          	auipc	a0,0x14
    80002fce:	7b650513          	addi	a0,a0,1974 # 80017780 <bcache>
    80002fd2:	ffffe097          	auipc	ra,0xffffe
    80002fd6:	c2c080e7          	jalr	-980(ra) # 80000bfe <acquire>
  b->refcnt++;
    80002fda:	40bc                	lw	a5,64(s1)
    80002fdc:	2785                	addiw	a5,a5,1
    80002fde:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fe0:	00014517          	auipc	a0,0x14
    80002fe4:	7a050513          	addi	a0,a0,1952 # 80017780 <bcache>
    80002fe8:	ffffe097          	auipc	ra,0xffffe
    80002fec:	cca080e7          	jalr	-822(ra) # 80000cb2 <release>
}
    80002ff0:	60e2                	ld	ra,24(sp)
    80002ff2:	6442                	ld	s0,16(sp)
    80002ff4:	64a2                	ld	s1,8(sp)
    80002ff6:	6105                	addi	sp,sp,32
    80002ff8:	8082                	ret

0000000080002ffa <bunpin>:

void
bunpin(struct buf *b) {
    80002ffa:	1101                	addi	sp,sp,-32
    80002ffc:	ec06                	sd	ra,24(sp)
    80002ffe:	e822                	sd	s0,16(sp)
    80003000:	e426                	sd	s1,8(sp)
    80003002:	1000                	addi	s0,sp,32
    80003004:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003006:	00014517          	auipc	a0,0x14
    8000300a:	77a50513          	addi	a0,a0,1914 # 80017780 <bcache>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	bf0080e7          	jalr	-1040(ra) # 80000bfe <acquire>
  b->refcnt--;
    80003016:	40bc                	lw	a5,64(s1)
    80003018:	37fd                	addiw	a5,a5,-1
    8000301a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000301c:	00014517          	auipc	a0,0x14
    80003020:	76450513          	addi	a0,a0,1892 # 80017780 <bcache>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	c8e080e7          	jalr	-882(ra) # 80000cb2 <release>
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6105                	addi	sp,sp,32
    80003034:	8082                	ret

0000000080003036 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	e426                	sd	s1,8(sp)
    8000303e:	e04a                	sd	s2,0(sp)
    80003040:	1000                	addi	s0,sp,32
    80003042:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003044:	00d5d59b          	srliw	a1,a1,0xd
    80003048:	0001d797          	auipc	a5,0x1d
    8000304c:	e147a783          	lw	a5,-492(a5) # 8001fe5c <sb+0x1c>
    80003050:	9dbd                	addw	a1,a1,a5
    80003052:	00000097          	auipc	ra,0x0
    80003056:	d9e080e7          	jalr	-610(ra) # 80002df0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000305a:	0074f713          	andi	a4,s1,7
    8000305e:	4785                	li	a5,1
    80003060:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003064:	14ce                	slli	s1,s1,0x33
    80003066:	90d9                	srli	s1,s1,0x36
    80003068:	00950733          	add	a4,a0,s1
    8000306c:	05874703          	lbu	a4,88(a4)
    80003070:	00e7f6b3          	and	a3,a5,a4
    80003074:	c69d                	beqz	a3,800030a2 <bfree+0x6c>
    80003076:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003078:	94aa                	add	s1,s1,a0
    8000307a:	fff7c793          	not	a5,a5
    8000307e:	8ff9                	and	a5,a5,a4
    80003080:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003084:	00001097          	auipc	ra,0x1
    80003088:	106080e7          	jalr	262(ra) # 8000418a <log_write>
  brelse(bp);
    8000308c:	854a                	mv	a0,s2
    8000308e:	00000097          	auipc	ra,0x0
    80003092:	e92080e7          	jalr	-366(ra) # 80002f20 <brelse>
}
    80003096:	60e2                	ld	ra,24(sp)
    80003098:	6442                	ld	s0,16(sp)
    8000309a:	64a2                	ld	s1,8(sp)
    8000309c:	6902                	ld	s2,0(sp)
    8000309e:	6105                	addi	sp,sp,32
    800030a0:	8082                	ret
    panic("freeing free block");
    800030a2:	00005517          	auipc	a0,0x5
    800030a6:	46e50513          	addi	a0,a0,1134 # 80008510 <syscalls+0xe8>
    800030aa:	ffffd097          	auipc	ra,0xffffd
    800030ae:	498080e7          	jalr	1176(ra) # 80000542 <panic>

00000000800030b2 <balloc>:
{
    800030b2:	711d                	addi	sp,sp,-96
    800030b4:	ec86                	sd	ra,88(sp)
    800030b6:	e8a2                	sd	s0,80(sp)
    800030b8:	e4a6                	sd	s1,72(sp)
    800030ba:	e0ca                	sd	s2,64(sp)
    800030bc:	fc4e                	sd	s3,56(sp)
    800030be:	f852                	sd	s4,48(sp)
    800030c0:	f456                	sd	s5,40(sp)
    800030c2:	f05a                	sd	s6,32(sp)
    800030c4:	ec5e                	sd	s7,24(sp)
    800030c6:	e862                	sd	s8,16(sp)
    800030c8:	e466                	sd	s9,8(sp)
    800030ca:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030cc:	0001d797          	auipc	a5,0x1d
    800030d0:	d787a783          	lw	a5,-648(a5) # 8001fe44 <sb+0x4>
    800030d4:	cbd1                	beqz	a5,80003168 <balloc+0xb6>
    800030d6:	8baa                	mv	s7,a0
    800030d8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030da:	0001db17          	auipc	s6,0x1d
    800030de:	d66b0b13          	addi	s6,s6,-666 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030e2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030e4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030e6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030e8:	6c89                	lui	s9,0x2
    800030ea:	a831                	j	80003106 <balloc+0x54>
    brelse(bp);
    800030ec:	854a                	mv	a0,s2
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	e32080e7          	jalr	-462(ra) # 80002f20 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800030f6:	015c87bb          	addw	a5,s9,s5
    800030fa:	00078a9b          	sext.w	s5,a5
    800030fe:	004b2703          	lw	a4,4(s6)
    80003102:	06eaf363          	bgeu	s5,a4,80003168 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003106:	41fad79b          	sraiw	a5,s5,0x1f
    8000310a:	0137d79b          	srliw	a5,a5,0x13
    8000310e:	015787bb          	addw	a5,a5,s5
    80003112:	40d7d79b          	sraiw	a5,a5,0xd
    80003116:	01cb2583          	lw	a1,28(s6)
    8000311a:	9dbd                	addw	a1,a1,a5
    8000311c:	855e                	mv	a0,s7
    8000311e:	00000097          	auipc	ra,0x0
    80003122:	cd2080e7          	jalr	-814(ra) # 80002df0 <bread>
    80003126:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003128:	004b2503          	lw	a0,4(s6)
    8000312c:	000a849b          	sext.w	s1,s5
    80003130:	8662                	mv	a2,s8
    80003132:	faa4fde3          	bgeu	s1,a0,800030ec <balloc+0x3a>
      m = 1 << (bi % 8);
    80003136:	41f6579b          	sraiw	a5,a2,0x1f
    8000313a:	01d7d69b          	srliw	a3,a5,0x1d
    8000313e:	00c6873b          	addw	a4,a3,a2
    80003142:	00777793          	andi	a5,a4,7
    80003146:	9f95                	subw	a5,a5,a3
    80003148:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000314c:	4037571b          	sraiw	a4,a4,0x3
    80003150:	00e906b3          	add	a3,s2,a4
    80003154:	0586c683          	lbu	a3,88(a3)
    80003158:	00d7f5b3          	and	a1,a5,a3
    8000315c:	cd91                	beqz	a1,80003178 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000315e:	2605                	addiw	a2,a2,1
    80003160:	2485                	addiw	s1,s1,1
    80003162:	fd4618e3          	bne	a2,s4,80003132 <balloc+0x80>
    80003166:	b759                	j	800030ec <balloc+0x3a>
  panic("balloc: out of blocks");
    80003168:	00005517          	auipc	a0,0x5
    8000316c:	3c050513          	addi	a0,a0,960 # 80008528 <syscalls+0x100>
    80003170:	ffffd097          	auipc	ra,0xffffd
    80003174:	3d2080e7          	jalr	978(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003178:	974a                	add	a4,a4,s2
    8000317a:	8fd5                	or	a5,a5,a3
    8000317c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003180:	854a                	mv	a0,s2
    80003182:	00001097          	auipc	ra,0x1
    80003186:	008080e7          	jalr	8(ra) # 8000418a <log_write>
        brelse(bp);
    8000318a:	854a                	mv	a0,s2
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	d94080e7          	jalr	-620(ra) # 80002f20 <brelse>
  bp = bread(dev, bno);
    80003194:	85a6                	mv	a1,s1
    80003196:	855e                	mv	a0,s7
    80003198:	00000097          	auipc	ra,0x0
    8000319c:	c58080e7          	jalr	-936(ra) # 80002df0 <bread>
    800031a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031a2:	40000613          	li	a2,1024
    800031a6:	4581                	li	a1,0
    800031a8:	05850513          	addi	a0,a0,88
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	b4e080e7          	jalr	-1202(ra) # 80000cfa <memset>
  log_write(bp);
    800031b4:	854a                	mv	a0,s2
    800031b6:	00001097          	auipc	ra,0x1
    800031ba:	fd4080e7          	jalr	-44(ra) # 8000418a <log_write>
  brelse(bp);
    800031be:	854a                	mv	a0,s2
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	d60080e7          	jalr	-672(ra) # 80002f20 <brelse>
}
    800031c8:	8526                	mv	a0,s1
    800031ca:	60e6                	ld	ra,88(sp)
    800031cc:	6446                	ld	s0,80(sp)
    800031ce:	64a6                	ld	s1,72(sp)
    800031d0:	6906                	ld	s2,64(sp)
    800031d2:	79e2                	ld	s3,56(sp)
    800031d4:	7a42                	ld	s4,48(sp)
    800031d6:	7aa2                	ld	s5,40(sp)
    800031d8:	7b02                	ld	s6,32(sp)
    800031da:	6be2                	ld	s7,24(sp)
    800031dc:	6c42                	ld	s8,16(sp)
    800031de:	6ca2                	ld	s9,8(sp)
    800031e0:	6125                	addi	sp,sp,96
    800031e2:	8082                	ret

00000000800031e4 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800031e4:	7179                	addi	sp,sp,-48
    800031e6:	f406                	sd	ra,40(sp)
    800031e8:	f022                	sd	s0,32(sp)
    800031ea:	ec26                	sd	s1,24(sp)
    800031ec:	e84a                	sd	s2,16(sp)
    800031ee:	e44e                	sd	s3,8(sp)
    800031f0:	e052                	sd	s4,0(sp)
    800031f2:	1800                	addi	s0,sp,48
    800031f4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031f6:	47ad                	li	a5,11
    800031f8:	04b7fe63          	bgeu	a5,a1,80003254 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800031fc:	ff45849b          	addiw	s1,a1,-12
    80003200:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003204:	0ff00793          	li	a5,255
    80003208:	0ae7e463          	bltu	a5,a4,800032b0 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000320c:	08052583          	lw	a1,128(a0)
    80003210:	c5b5                	beqz	a1,8000327c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003212:	00092503          	lw	a0,0(s2)
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	bda080e7          	jalr	-1062(ra) # 80002df0 <bread>
    8000321e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003220:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003224:	02049713          	slli	a4,s1,0x20
    80003228:	01e75593          	srli	a1,a4,0x1e
    8000322c:	00b784b3          	add	s1,a5,a1
    80003230:	0004a983          	lw	s3,0(s1)
    80003234:	04098e63          	beqz	s3,80003290 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003238:	8552                	mv	a0,s4
    8000323a:	00000097          	auipc	ra,0x0
    8000323e:	ce6080e7          	jalr	-794(ra) # 80002f20 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003242:	854e                	mv	a0,s3
    80003244:	70a2                	ld	ra,40(sp)
    80003246:	7402                	ld	s0,32(sp)
    80003248:	64e2                	ld	s1,24(sp)
    8000324a:	6942                	ld	s2,16(sp)
    8000324c:	69a2                	ld	s3,8(sp)
    8000324e:	6a02                	ld	s4,0(sp)
    80003250:	6145                	addi	sp,sp,48
    80003252:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003254:	02059793          	slli	a5,a1,0x20
    80003258:	01e7d593          	srli	a1,a5,0x1e
    8000325c:	00b504b3          	add	s1,a0,a1
    80003260:	0504a983          	lw	s3,80(s1)
    80003264:	fc099fe3          	bnez	s3,80003242 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003268:	4108                	lw	a0,0(a0)
    8000326a:	00000097          	auipc	ra,0x0
    8000326e:	e48080e7          	jalr	-440(ra) # 800030b2 <balloc>
    80003272:	0005099b          	sext.w	s3,a0
    80003276:	0534a823          	sw	s3,80(s1)
    8000327a:	b7e1                	j	80003242 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000327c:	4108                	lw	a0,0(a0)
    8000327e:	00000097          	auipc	ra,0x0
    80003282:	e34080e7          	jalr	-460(ra) # 800030b2 <balloc>
    80003286:	0005059b          	sext.w	a1,a0
    8000328a:	08b92023          	sw	a1,128(s2)
    8000328e:	b751                	j	80003212 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003290:	00092503          	lw	a0,0(s2)
    80003294:	00000097          	auipc	ra,0x0
    80003298:	e1e080e7          	jalr	-482(ra) # 800030b2 <balloc>
    8000329c:	0005099b          	sext.w	s3,a0
    800032a0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800032a4:	8552                	mv	a0,s4
    800032a6:	00001097          	auipc	ra,0x1
    800032aa:	ee4080e7          	jalr	-284(ra) # 8000418a <log_write>
    800032ae:	b769                	j	80003238 <bmap+0x54>
  panic("bmap: out of range");
    800032b0:	00005517          	auipc	a0,0x5
    800032b4:	29050513          	addi	a0,a0,656 # 80008540 <syscalls+0x118>
    800032b8:	ffffd097          	auipc	ra,0xffffd
    800032bc:	28a080e7          	jalr	650(ra) # 80000542 <panic>

00000000800032c0 <iget>:
{
    800032c0:	7179                	addi	sp,sp,-48
    800032c2:	f406                	sd	ra,40(sp)
    800032c4:	f022                	sd	s0,32(sp)
    800032c6:	ec26                	sd	s1,24(sp)
    800032c8:	e84a                	sd	s2,16(sp)
    800032ca:	e44e                	sd	s3,8(sp)
    800032cc:	e052                	sd	s4,0(sp)
    800032ce:	1800                	addi	s0,sp,48
    800032d0:	89aa                	mv	s3,a0
    800032d2:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800032d4:	0001d517          	auipc	a0,0x1d
    800032d8:	b8c50513          	addi	a0,a0,-1140 # 8001fe60 <icache>
    800032dc:	ffffe097          	auipc	ra,0xffffe
    800032e0:	922080e7          	jalr	-1758(ra) # 80000bfe <acquire>
  empty = 0;
    800032e4:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032e6:	0001d497          	auipc	s1,0x1d
    800032ea:	b9248493          	addi	s1,s1,-1134 # 8001fe78 <icache+0x18>
    800032ee:	0001e697          	auipc	a3,0x1e
    800032f2:	61a68693          	addi	a3,a3,1562 # 80021908 <log>
    800032f6:	a039                	j	80003304 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032f8:	02090b63          	beqz	s2,8000332e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032fc:	08848493          	addi	s1,s1,136
    80003300:	02d48a63          	beq	s1,a3,80003334 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003304:	449c                	lw	a5,8(s1)
    80003306:	fef059e3          	blez	a5,800032f8 <iget+0x38>
    8000330a:	4098                	lw	a4,0(s1)
    8000330c:	ff3716e3          	bne	a4,s3,800032f8 <iget+0x38>
    80003310:	40d8                	lw	a4,4(s1)
    80003312:	ff4713e3          	bne	a4,s4,800032f8 <iget+0x38>
      ip->ref++;
    80003316:	2785                	addiw	a5,a5,1
    80003318:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000331a:	0001d517          	auipc	a0,0x1d
    8000331e:	b4650513          	addi	a0,a0,-1210 # 8001fe60 <icache>
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	990080e7          	jalr	-1648(ra) # 80000cb2 <release>
      return ip;
    8000332a:	8926                	mv	s2,s1
    8000332c:	a03d                	j	8000335a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000332e:	f7f9                	bnez	a5,800032fc <iget+0x3c>
    80003330:	8926                	mv	s2,s1
    80003332:	b7e9                	j	800032fc <iget+0x3c>
  if(empty == 0)
    80003334:	02090c63          	beqz	s2,8000336c <iget+0xac>
  ip->dev = dev;
    80003338:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000333c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003340:	4785                	li	a5,1
    80003342:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003346:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000334a:	0001d517          	auipc	a0,0x1d
    8000334e:	b1650513          	addi	a0,a0,-1258 # 8001fe60 <icache>
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	960080e7          	jalr	-1696(ra) # 80000cb2 <release>
}
    8000335a:	854a                	mv	a0,s2
    8000335c:	70a2                	ld	ra,40(sp)
    8000335e:	7402                	ld	s0,32(sp)
    80003360:	64e2                	ld	s1,24(sp)
    80003362:	6942                	ld	s2,16(sp)
    80003364:	69a2                	ld	s3,8(sp)
    80003366:	6a02                	ld	s4,0(sp)
    80003368:	6145                	addi	sp,sp,48
    8000336a:	8082                	ret
    panic("iget: no inodes");
    8000336c:	00005517          	auipc	a0,0x5
    80003370:	1ec50513          	addi	a0,a0,492 # 80008558 <syscalls+0x130>
    80003374:	ffffd097          	auipc	ra,0xffffd
    80003378:	1ce080e7          	jalr	462(ra) # 80000542 <panic>

000000008000337c <fsinit>:
fsinit(int dev) {
    8000337c:	7179                	addi	sp,sp,-48
    8000337e:	f406                	sd	ra,40(sp)
    80003380:	f022                	sd	s0,32(sp)
    80003382:	ec26                	sd	s1,24(sp)
    80003384:	e84a                	sd	s2,16(sp)
    80003386:	e44e                	sd	s3,8(sp)
    80003388:	1800                	addi	s0,sp,48
    8000338a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000338c:	4585                	li	a1,1
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	a62080e7          	jalr	-1438(ra) # 80002df0 <bread>
    80003396:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003398:	0001d997          	auipc	s3,0x1d
    8000339c:	aa898993          	addi	s3,s3,-1368 # 8001fe40 <sb>
    800033a0:	02000613          	li	a2,32
    800033a4:	05850593          	addi	a1,a0,88
    800033a8:	854e                	mv	a0,s3
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	9ac080e7          	jalr	-1620(ra) # 80000d56 <memmove>
  brelse(bp);
    800033b2:	8526                	mv	a0,s1
    800033b4:	00000097          	auipc	ra,0x0
    800033b8:	b6c080e7          	jalr	-1172(ra) # 80002f20 <brelse>
  if(sb.magic != FSMAGIC)
    800033bc:	0009a703          	lw	a4,0(s3)
    800033c0:	102037b7          	lui	a5,0x10203
    800033c4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033c8:	02f71263          	bne	a4,a5,800033ec <fsinit+0x70>
  initlog(dev, &sb);
    800033cc:	0001d597          	auipc	a1,0x1d
    800033d0:	a7458593          	addi	a1,a1,-1420 # 8001fe40 <sb>
    800033d4:	854a                	mv	a0,s2
    800033d6:	00001097          	auipc	ra,0x1
    800033da:	b3a080e7          	jalr	-1222(ra) # 80003f10 <initlog>
}
    800033de:	70a2                	ld	ra,40(sp)
    800033e0:	7402                	ld	s0,32(sp)
    800033e2:	64e2                	ld	s1,24(sp)
    800033e4:	6942                	ld	s2,16(sp)
    800033e6:	69a2                	ld	s3,8(sp)
    800033e8:	6145                	addi	sp,sp,48
    800033ea:	8082                	ret
    panic("invalid file system");
    800033ec:	00005517          	auipc	a0,0x5
    800033f0:	17c50513          	addi	a0,a0,380 # 80008568 <syscalls+0x140>
    800033f4:	ffffd097          	auipc	ra,0xffffd
    800033f8:	14e080e7          	jalr	334(ra) # 80000542 <panic>

00000000800033fc <iinit>:
{
    800033fc:	7179                	addi	sp,sp,-48
    800033fe:	f406                	sd	ra,40(sp)
    80003400:	f022                	sd	s0,32(sp)
    80003402:	ec26                	sd	s1,24(sp)
    80003404:	e84a                	sd	s2,16(sp)
    80003406:	e44e                	sd	s3,8(sp)
    80003408:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000340a:	00005597          	auipc	a1,0x5
    8000340e:	17658593          	addi	a1,a1,374 # 80008580 <syscalls+0x158>
    80003412:	0001d517          	auipc	a0,0x1d
    80003416:	a4e50513          	addi	a0,a0,-1458 # 8001fe60 <icache>
    8000341a:	ffffd097          	auipc	ra,0xffffd
    8000341e:	754080e7          	jalr	1876(ra) # 80000b6e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003422:	0001d497          	auipc	s1,0x1d
    80003426:	a6648493          	addi	s1,s1,-1434 # 8001fe88 <icache+0x28>
    8000342a:	0001e997          	auipc	s3,0x1e
    8000342e:	4ee98993          	addi	s3,s3,1262 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003432:	00005917          	auipc	s2,0x5
    80003436:	15690913          	addi	s2,s2,342 # 80008588 <syscalls+0x160>
    8000343a:	85ca                	mv	a1,s2
    8000343c:	8526                	mv	a0,s1
    8000343e:	00001097          	auipc	ra,0x1
    80003442:	e3a080e7          	jalr	-454(ra) # 80004278 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003446:	08848493          	addi	s1,s1,136
    8000344a:	ff3498e3          	bne	s1,s3,8000343a <iinit+0x3e>
}
    8000344e:	70a2                	ld	ra,40(sp)
    80003450:	7402                	ld	s0,32(sp)
    80003452:	64e2                	ld	s1,24(sp)
    80003454:	6942                	ld	s2,16(sp)
    80003456:	69a2                	ld	s3,8(sp)
    80003458:	6145                	addi	sp,sp,48
    8000345a:	8082                	ret

000000008000345c <ialloc>:
{
    8000345c:	715d                	addi	sp,sp,-80
    8000345e:	e486                	sd	ra,72(sp)
    80003460:	e0a2                	sd	s0,64(sp)
    80003462:	fc26                	sd	s1,56(sp)
    80003464:	f84a                	sd	s2,48(sp)
    80003466:	f44e                	sd	s3,40(sp)
    80003468:	f052                	sd	s4,32(sp)
    8000346a:	ec56                	sd	s5,24(sp)
    8000346c:	e85a                	sd	s6,16(sp)
    8000346e:	e45e                	sd	s7,8(sp)
    80003470:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003472:	0001d717          	auipc	a4,0x1d
    80003476:	9da72703          	lw	a4,-1574(a4) # 8001fe4c <sb+0xc>
    8000347a:	4785                	li	a5,1
    8000347c:	04e7fa63          	bgeu	a5,a4,800034d0 <ialloc+0x74>
    80003480:	8aaa                	mv	s5,a0
    80003482:	8bae                	mv	s7,a1
    80003484:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003486:	0001da17          	auipc	s4,0x1d
    8000348a:	9baa0a13          	addi	s4,s4,-1606 # 8001fe40 <sb>
    8000348e:	00048b1b          	sext.w	s6,s1
    80003492:	0044d793          	srli	a5,s1,0x4
    80003496:	018a2583          	lw	a1,24(s4)
    8000349a:	9dbd                	addw	a1,a1,a5
    8000349c:	8556                	mv	a0,s5
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	952080e7          	jalr	-1710(ra) # 80002df0 <bread>
    800034a6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034a8:	05850993          	addi	s3,a0,88
    800034ac:	00f4f793          	andi	a5,s1,15
    800034b0:	079a                	slli	a5,a5,0x6
    800034b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034b4:	00099783          	lh	a5,0(s3)
    800034b8:	c785                	beqz	a5,800034e0 <ialloc+0x84>
    brelse(bp);
    800034ba:	00000097          	auipc	ra,0x0
    800034be:	a66080e7          	jalr	-1434(ra) # 80002f20 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034c2:	0485                	addi	s1,s1,1
    800034c4:	00ca2703          	lw	a4,12(s4)
    800034c8:	0004879b          	sext.w	a5,s1
    800034cc:	fce7e1e3          	bltu	a5,a4,8000348e <ialloc+0x32>
  panic("ialloc: no inodes");
    800034d0:	00005517          	auipc	a0,0x5
    800034d4:	0c050513          	addi	a0,a0,192 # 80008590 <syscalls+0x168>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	06a080e7          	jalr	106(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    800034e0:	04000613          	li	a2,64
    800034e4:	4581                	li	a1,0
    800034e6:	854e                	mv	a0,s3
    800034e8:	ffffe097          	auipc	ra,0xffffe
    800034ec:	812080e7          	jalr	-2030(ra) # 80000cfa <memset>
      dip->type = type;
    800034f0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800034f4:	854a                	mv	a0,s2
    800034f6:	00001097          	auipc	ra,0x1
    800034fa:	c94080e7          	jalr	-876(ra) # 8000418a <log_write>
      brelse(bp);
    800034fe:	854a                	mv	a0,s2
    80003500:	00000097          	auipc	ra,0x0
    80003504:	a20080e7          	jalr	-1504(ra) # 80002f20 <brelse>
      return iget(dev, inum);
    80003508:	85da                	mv	a1,s6
    8000350a:	8556                	mv	a0,s5
    8000350c:	00000097          	auipc	ra,0x0
    80003510:	db4080e7          	jalr	-588(ra) # 800032c0 <iget>
}
    80003514:	60a6                	ld	ra,72(sp)
    80003516:	6406                	ld	s0,64(sp)
    80003518:	74e2                	ld	s1,56(sp)
    8000351a:	7942                	ld	s2,48(sp)
    8000351c:	79a2                	ld	s3,40(sp)
    8000351e:	7a02                	ld	s4,32(sp)
    80003520:	6ae2                	ld	s5,24(sp)
    80003522:	6b42                	ld	s6,16(sp)
    80003524:	6ba2                	ld	s7,8(sp)
    80003526:	6161                	addi	sp,sp,80
    80003528:	8082                	ret

000000008000352a <iupdate>:
{
    8000352a:	1101                	addi	sp,sp,-32
    8000352c:	ec06                	sd	ra,24(sp)
    8000352e:	e822                	sd	s0,16(sp)
    80003530:	e426                	sd	s1,8(sp)
    80003532:	e04a                	sd	s2,0(sp)
    80003534:	1000                	addi	s0,sp,32
    80003536:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003538:	415c                	lw	a5,4(a0)
    8000353a:	0047d79b          	srliw	a5,a5,0x4
    8000353e:	0001d597          	auipc	a1,0x1d
    80003542:	91a5a583          	lw	a1,-1766(a1) # 8001fe58 <sb+0x18>
    80003546:	9dbd                	addw	a1,a1,a5
    80003548:	4108                	lw	a0,0(a0)
    8000354a:	00000097          	auipc	ra,0x0
    8000354e:	8a6080e7          	jalr	-1882(ra) # 80002df0 <bread>
    80003552:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003554:	05850793          	addi	a5,a0,88
    80003558:	40c8                	lw	a0,4(s1)
    8000355a:	893d                	andi	a0,a0,15
    8000355c:	051a                	slli	a0,a0,0x6
    8000355e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003560:	04449703          	lh	a4,68(s1)
    80003564:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003568:	04649703          	lh	a4,70(s1)
    8000356c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003570:	04849703          	lh	a4,72(s1)
    80003574:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003578:	04a49703          	lh	a4,74(s1)
    8000357c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003580:	44f8                	lw	a4,76(s1)
    80003582:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003584:	03400613          	li	a2,52
    80003588:	05048593          	addi	a1,s1,80
    8000358c:	0531                	addi	a0,a0,12
    8000358e:	ffffd097          	auipc	ra,0xffffd
    80003592:	7c8080e7          	jalr	1992(ra) # 80000d56 <memmove>
  log_write(bp);
    80003596:	854a                	mv	a0,s2
    80003598:	00001097          	auipc	ra,0x1
    8000359c:	bf2080e7          	jalr	-1038(ra) # 8000418a <log_write>
  brelse(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	97e080e7          	jalr	-1666(ra) # 80002f20 <brelse>
}
    800035aa:	60e2                	ld	ra,24(sp)
    800035ac:	6442                	ld	s0,16(sp)
    800035ae:	64a2                	ld	s1,8(sp)
    800035b0:	6902                	ld	s2,0(sp)
    800035b2:	6105                	addi	sp,sp,32
    800035b4:	8082                	ret

00000000800035b6 <idup>:
{
    800035b6:	1101                	addi	sp,sp,-32
    800035b8:	ec06                	sd	ra,24(sp)
    800035ba:	e822                	sd	s0,16(sp)
    800035bc:	e426                	sd	s1,8(sp)
    800035be:	1000                	addi	s0,sp,32
    800035c0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800035c2:	0001d517          	auipc	a0,0x1d
    800035c6:	89e50513          	addi	a0,a0,-1890 # 8001fe60 <icache>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	634080e7          	jalr	1588(ra) # 80000bfe <acquire>
  ip->ref++;
    800035d2:	449c                	lw	a5,8(s1)
    800035d4:	2785                	addiw	a5,a5,1
    800035d6:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800035d8:	0001d517          	auipc	a0,0x1d
    800035dc:	88850513          	addi	a0,a0,-1912 # 8001fe60 <icache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	6d2080e7          	jalr	1746(ra) # 80000cb2 <release>
}
    800035e8:	8526                	mv	a0,s1
    800035ea:	60e2                	ld	ra,24(sp)
    800035ec:	6442                	ld	s0,16(sp)
    800035ee:	64a2                	ld	s1,8(sp)
    800035f0:	6105                	addi	sp,sp,32
    800035f2:	8082                	ret

00000000800035f4 <ilock>:
{
    800035f4:	1101                	addi	sp,sp,-32
    800035f6:	ec06                	sd	ra,24(sp)
    800035f8:	e822                	sd	s0,16(sp)
    800035fa:	e426                	sd	s1,8(sp)
    800035fc:	e04a                	sd	s2,0(sp)
    800035fe:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003600:	c115                	beqz	a0,80003624 <ilock+0x30>
    80003602:	84aa                	mv	s1,a0
    80003604:	451c                	lw	a5,8(a0)
    80003606:	00f05f63          	blez	a5,80003624 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000360a:	0541                	addi	a0,a0,16
    8000360c:	00001097          	auipc	ra,0x1
    80003610:	ca6080e7          	jalr	-858(ra) # 800042b2 <acquiresleep>
  if(ip->valid == 0){
    80003614:	40bc                	lw	a5,64(s1)
    80003616:	cf99                	beqz	a5,80003634 <ilock+0x40>
}
    80003618:	60e2                	ld	ra,24(sp)
    8000361a:	6442                	ld	s0,16(sp)
    8000361c:	64a2                	ld	s1,8(sp)
    8000361e:	6902                	ld	s2,0(sp)
    80003620:	6105                	addi	sp,sp,32
    80003622:	8082                	ret
    panic("ilock");
    80003624:	00005517          	auipc	a0,0x5
    80003628:	f8450513          	addi	a0,a0,-124 # 800085a8 <syscalls+0x180>
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	f16080e7          	jalr	-234(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003634:	40dc                	lw	a5,4(s1)
    80003636:	0047d79b          	srliw	a5,a5,0x4
    8000363a:	0001d597          	auipc	a1,0x1d
    8000363e:	81e5a583          	lw	a1,-2018(a1) # 8001fe58 <sb+0x18>
    80003642:	9dbd                	addw	a1,a1,a5
    80003644:	4088                	lw	a0,0(s1)
    80003646:	fffff097          	auipc	ra,0xfffff
    8000364a:	7aa080e7          	jalr	1962(ra) # 80002df0 <bread>
    8000364e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003650:	05850593          	addi	a1,a0,88
    80003654:	40dc                	lw	a5,4(s1)
    80003656:	8bbd                	andi	a5,a5,15
    80003658:	079a                	slli	a5,a5,0x6
    8000365a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000365c:	00059783          	lh	a5,0(a1)
    80003660:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003664:	00259783          	lh	a5,2(a1)
    80003668:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000366c:	00459783          	lh	a5,4(a1)
    80003670:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003674:	00659783          	lh	a5,6(a1)
    80003678:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000367c:	459c                	lw	a5,8(a1)
    8000367e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003680:	03400613          	li	a2,52
    80003684:	05b1                	addi	a1,a1,12
    80003686:	05048513          	addi	a0,s1,80
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	6cc080e7          	jalr	1740(ra) # 80000d56 <memmove>
    brelse(bp);
    80003692:	854a                	mv	a0,s2
    80003694:	00000097          	auipc	ra,0x0
    80003698:	88c080e7          	jalr	-1908(ra) # 80002f20 <brelse>
    ip->valid = 1;
    8000369c:	4785                	li	a5,1
    8000369e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036a0:	04449783          	lh	a5,68(s1)
    800036a4:	fbb5                	bnez	a5,80003618 <ilock+0x24>
      panic("ilock: no type");
    800036a6:	00005517          	auipc	a0,0x5
    800036aa:	f0a50513          	addi	a0,a0,-246 # 800085b0 <syscalls+0x188>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	e94080e7          	jalr	-364(ra) # 80000542 <panic>

00000000800036b6 <iunlock>:
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	e04a                	sd	s2,0(sp)
    800036c0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036c2:	c905                	beqz	a0,800036f2 <iunlock+0x3c>
    800036c4:	84aa                	mv	s1,a0
    800036c6:	01050913          	addi	s2,a0,16
    800036ca:	854a                	mv	a0,s2
    800036cc:	00001097          	auipc	ra,0x1
    800036d0:	c80080e7          	jalr	-896(ra) # 8000434c <holdingsleep>
    800036d4:	cd19                	beqz	a0,800036f2 <iunlock+0x3c>
    800036d6:	449c                	lw	a5,8(s1)
    800036d8:	00f05d63          	blez	a5,800036f2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800036dc:	854a                	mv	a0,s2
    800036de:	00001097          	auipc	ra,0x1
    800036e2:	c2a080e7          	jalr	-982(ra) # 80004308 <releasesleep>
}
    800036e6:	60e2                	ld	ra,24(sp)
    800036e8:	6442                	ld	s0,16(sp)
    800036ea:	64a2                	ld	s1,8(sp)
    800036ec:	6902                	ld	s2,0(sp)
    800036ee:	6105                	addi	sp,sp,32
    800036f0:	8082                	ret
    panic("iunlock");
    800036f2:	00005517          	auipc	a0,0x5
    800036f6:	ece50513          	addi	a0,a0,-306 # 800085c0 <syscalls+0x198>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	e48080e7          	jalr	-440(ra) # 80000542 <panic>

0000000080003702 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003702:	7179                	addi	sp,sp,-48
    80003704:	f406                	sd	ra,40(sp)
    80003706:	f022                	sd	s0,32(sp)
    80003708:	ec26                	sd	s1,24(sp)
    8000370a:	e84a                	sd	s2,16(sp)
    8000370c:	e44e                	sd	s3,8(sp)
    8000370e:	e052                	sd	s4,0(sp)
    80003710:	1800                	addi	s0,sp,48
    80003712:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003714:	05050493          	addi	s1,a0,80
    80003718:	08050913          	addi	s2,a0,128
    8000371c:	a021                	j	80003724 <itrunc+0x22>
    8000371e:	0491                	addi	s1,s1,4
    80003720:	01248d63          	beq	s1,s2,8000373a <itrunc+0x38>
    if(ip->addrs[i]){
    80003724:	408c                	lw	a1,0(s1)
    80003726:	dde5                	beqz	a1,8000371e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003728:	0009a503          	lw	a0,0(s3)
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	90a080e7          	jalr	-1782(ra) # 80003036 <bfree>
      ip->addrs[i] = 0;
    80003734:	0004a023          	sw	zero,0(s1)
    80003738:	b7dd                	j	8000371e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000373a:	0809a583          	lw	a1,128(s3)
    8000373e:	e185                	bnez	a1,8000375e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003740:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003744:	854e                	mv	a0,s3
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	de4080e7          	jalr	-540(ra) # 8000352a <iupdate>
}
    8000374e:	70a2                	ld	ra,40(sp)
    80003750:	7402                	ld	s0,32(sp)
    80003752:	64e2                	ld	s1,24(sp)
    80003754:	6942                	ld	s2,16(sp)
    80003756:	69a2                	ld	s3,8(sp)
    80003758:	6a02                	ld	s4,0(sp)
    8000375a:	6145                	addi	sp,sp,48
    8000375c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000375e:	0009a503          	lw	a0,0(s3)
    80003762:	fffff097          	auipc	ra,0xfffff
    80003766:	68e080e7          	jalr	1678(ra) # 80002df0 <bread>
    8000376a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000376c:	05850493          	addi	s1,a0,88
    80003770:	45850913          	addi	s2,a0,1112
    80003774:	a021                	j	8000377c <itrunc+0x7a>
    80003776:	0491                	addi	s1,s1,4
    80003778:	01248b63          	beq	s1,s2,8000378e <itrunc+0x8c>
      if(a[j])
    8000377c:	408c                	lw	a1,0(s1)
    8000377e:	dde5                	beqz	a1,80003776 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003780:	0009a503          	lw	a0,0(s3)
    80003784:	00000097          	auipc	ra,0x0
    80003788:	8b2080e7          	jalr	-1870(ra) # 80003036 <bfree>
    8000378c:	b7ed                	j	80003776 <itrunc+0x74>
    brelse(bp);
    8000378e:	8552                	mv	a0,s4
    80003790:	fffff097          	auipc	ra,0xfffff
    80003794:	790080e7          	jalr	1936(ra) # 80002f20 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003798:	0809a583          	lw	a1,128(s3)
    8000379c:	0009a503          	lw	a0,0(s3)
    800037a0:	00000097          	auipc	ra,0x0
    800037a4:	896080e7          	jalr	-1898(ra) # 80003036 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037a8:	0809a023          	sw	zero,128(s3)
    800037ac:	bf51                	j	80003740 <itrunc+0x3e>

00000000800037ae <iput>:
{
    800037ae:	1101                	addi	sp,sp,-32
    800037b0:	ec06                	sd	ra,24(sp)
    800037b2:	e822                	sd	s0,16(sp)
    800037b4:	e426                	sd	s1,8(sp)
    800037b6:	e04a                	sd	s2,0(sp)
    800037b8:	1000                	addi	s0,sp,32
    800037ba:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037bc:	0001c517          	auipc	a0,0x1c
    800037c0:	6a450513          	addi	a0,a0,1700 # 8001fe60 <icache>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	43a080e7          	jalr	1082(ra) # 80000bfe <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037cc:	4498                	lw	a4,8(s1)
    800037ce:	4785                	li	a5,1
    800037d0:	02f70363          	beq	a4,a5,800037f6 <iput+0x48>
  ip->ref--;
    800037d4:	449c                	lw	a5,8(s1)
    800037d6:	37fd                	addiw	a5,a5,-1
    800037d8:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037da:	0001c517          	auipc	a0,0x1c
    800037de:	68650513          	addi	a0,a0,1670 # 8001fe60 <icache>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	4d0080e7          	jalr	1232(ra) # 80000cb2 <release>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6902                	ld	s2,0(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037f6:	40bc                	lw	a5,64(s1)
    800037f8:	dff1                	beqz	a5,800037d4 <iput+0x26>
    800037fa:	04a49783          	lh	a5,74(s1)
    800037fe:	fbf9                	bnez	a5,800037d4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003800:	01048913          	addi	s2,s1,16
    80003804:	854a                	mv	a0,s2
    80003806:	00001097          	auipc	ra,0x1
    8000380a:	aac080e7          	jalr	-1364(ra) # 800042b2 <acquiresleep>
    release(&icache.lock);
    8000380e:	0001c517          	auipc	a0,0x1c
    80003812:	65250513          	addi	a0,a0,1618 # 8001fe60 <icache>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	49c080e7          	jalr	1180(ra) # 80000cb2 <release>
    itrunc(ip);
    8000381e:	8526                	mv	a0,s1
    80003820:	00000097          	auipc	ra,0x0
    80003824:	ee2080e7          	jalr	-286(ra) # 80003702 <itrunc>
    ip->type = 0;
    80003828:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000382c:	8526                	mv	a0,s1
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	cfc080e7          	jalr	-772(ra) # 8000352a <iupdate>
    ip->valid = 0;
    80003836:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	acc080e7          	jalr	-1332(ra) # 80004308 <releasesleep>
    acquire(&icache.lock);
    80003844:	0001c517          	auipc	a0,0x1c
    80003848:	61c50513          	addi	a0,a0,1564 # 8001fe60 <icache>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	3b2080e7          	jalr	946(ra) # 80000bfe <acquire>
    80003854:	b741                	j	800037d4 <iput+0x26>

0000000080003856 <iunlockput>:
{
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	e426                	sd	s1,8(sp)
    8000385e:	1000                	addi	s0,sp,32
    80003860:	84aa                	mv	s1,a0
  iunlock(ip);
    80003862:	00000097          	auipc	ra,0x0
    80003866:	e54080e7          	jalr	-428(ra) # 800036b6 <iunlock>
  iput(ip);
    8000386a:	8526                	mv	a0,s1
    8000386c:	00000097          	auipc	ra,0x0
    80003870:	f42080e7          	jalr	-190(ra) # 800037ae <iput>
}
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6105                	addi	sp,sp,32
    8000387c:	8082                	ret

000000008000387e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000387e:	1141                	addi	sp,sp,-16
    80003880:	e422                	sd	s0,8(sp)
    80003882:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003884:	411c                	lw	a5,0(a0)
    80003886:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003888:	415c                	lw	a5,4(a0)
    8000388a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000388c:	04451783          	lh	a5,68(a0)
    80003890:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003894:	04a51783          	lh	a5,74(a0)
    80003898:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000389c:	04c56783          	lwu	a5,76(a0)
    800038a0:	e99c                	sd	a5,16(a1)
}
    800038a2:	6422                	ld	s0,8(sp)
    800038a4:	0141                	addi	sp,sp,16
    800038a6:	8082                	ret

00000000800038a8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038a8:	457c                	lw	a5,76(a0)
    800038aa:	0ed7e863          	bltu	a5,a3,8000399a <readi+0xf2>
{
    800038ae:	7159                	addi	sp,sp,-112
    800038b0:	f486                	sd	ra,104(sp)
    800038b2:	f0a2                	sd	s0,96(sp)
    800038b4:	eca6                	sd	s1,88(sp)
    800038b6:	e8ca                	sd	s2,80(sp)
    800038b8:	e4ce                	sd	s3,72(sp)
    800038ba:	e0d2                	sd	s4,64(sp)
    800038bc:	fc56                	sd	s5,56(sp)
    800038be:	f85a                	sd	s6,48(sp)
    800038c0:	f45e                	sd	s7,40(sp)
    800038c2:	f062                	sd	s8,32(sp)
    800038c4:	ec66                	sd	s9,24(sp)
    800038c6:	e86a                	sd	s10,16(sp)
    800038c8:	e46e                	sd	s11,8(sp)
    800038ca:	1880                	addi	s0,sp,112
    800038cc:	8baa                	mv	s7,a0
    800038ce:	8c2e                	mv	s8,a1
    800038d0:	8ab2                	mv	s5,a2
    800038d2:	84b6                	mv	s1,a3
    800038d4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038d6:	9f35                	addw	a4,a4,a3
    return 0;
    800038d8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038da:	08d76f63          	bltu	a4,a3,80003978 <readi+0xd0>
  if(off + n > ip->size)
    800038de:	00e7f463          	bgeu	a5,a4,800038e6 <readi+0x3e>
    n = ip->size - off;
    800038e2:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038e6:	0a0b0863          	beqz	s6,80003996 <readi+0xee>
    800038ea:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800038ec:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038f0:	5cfd                	li	s9,-1
    800038f2:	a82d                	j	8000392c <readi+0x84>
    800038f4:	020a1d93          	slli	s11,s4,0x20
    800038f8:	020ddd93          	srli	s11,s11,0x20
    800038fc:	05890793          	addi	a5,s2,88
    80003900:	86ee                	mv	a3,s11
    80003902:	963e                	add	a2,a2,a5
    80003904:	85d6                	mv	a1,s5
    80003906:	8562                	mv	a0,s8
    80003908:	fffff097          	auipc	ra,0xfffff
    8000390c:	b2c080e7          	jalr	-1236(ra) # 80002434 <either_copyout>
    80003910:	05950d63          	beq	a0,s9,8000396a <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003914:	854a                	mv	a0,s2
    80003916:	fffff097          	auipc	ra,0xfffff
    8000391a:	60a080e7          	jalr	1546(ra) # 80002f20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000391e:	013a09bb          	addw	s3,s4,s3
    80003922:	009a04bb          	addw	s1,s4,s1
    80003926:	9aee                	add	s5,s5,s11
    80003928:	0569f663          	bgeu	s3,s6,80003974 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000392c:	000ba903          	lw	s2,0(s7)
    80003930:	00a4d59b          	srliw	a1,s1,0xa
    80003934:	855e                	mv	a0,s7
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	8ae080e7          	jalr	-1874(ra) # 800031e4 <bmap>
    8000393e:	0005059b          	sext.w	a1,a0
    80003942:	854a                	mv	a0,s2
    80003944:	fffff097          	auipc	ra,0xfffff
    80003948:	4ac080e7          	jalr	1196(ra) # 80002df0 <bread>
    8000394c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000394e:	3ff4f613          	andi	a2,s1,1023
    80003952:	40cd07bb          	subw	a5,s10,a2
    80003956:	413b073b          	subw	a4,s6,s3
    8000395a:	8a3e                	mv	s4,a5
    8000395c:	2781                	sext.w	a5,a5
    8000395e:	0007069b          	sext.w	a3,a4
    80003962:	f8f6f9e3          	bgeu	a3,a5,800038f4 <readi+0x4c>
    80003966:	8a3a                	mv	s4,a4
    80003968:	b771                	j	800038f4 <readi+0x4c>
      brelse(bp);
    8000396a:	854a                	mv	a0,s2
    8000396c:	fffff097          	auipc	ra,0xfffff
    80003970:	5b4080e7          	jalr	1460(ra) # 80002f20 <brelse>
  }
  return tot;
    80003974:	0009851b          	sext.w	a0,s3
}
    80003978:	70a6                	ld	ra,104(sp)
    8000397a:	7406                	ld	s0,96(sp)
    8000397c:	64e6                	ld	s1,88(sp)
    8000397e:	6946                	ld	s2,80(sp)
    80003980:	69a6                	ld	s3,72(sp)
    80003982:	6a06                	ld	s4,64(sp)
    80003984:	7ae2                	ld	s5,56(sp)
    80003986:	7b42                	ld	s6,48(sp)
    80003988:	7ba2                	ld	s7,40(sp)
    8000398a:	7c02                	ld	s8,32(sp)
    8000398c:	6ce2                	ld	s9,24(sp)
    8000398e:	6d42                	ld	s10,16(sp)
    80003990:	6da2                	ld	s11,8(sp)
    80003992:	6165                	addi	sp,sp,112
    80003994:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003996:	89da                	mv	s3,s6
    80003998:	bff1                	j	80003974 <readi+0xcc>
    return 0;
    8000399a:	4501                	li	a0,0
}
    8000399c:	8082                	ret

000000008000399e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000399e:	457c                	lw	a5,76(a0)
    800039a0:	10d7e663          	bltu	a5,a3,80003aac <writei+0x10e>
{
    800039a4:	7159                	addi	sp,sp,-112
    800039a6:	f486                	sd	ra,104(sp)
    800039a8:	f0a2                	sd	s0,96(sp)
    800039aa:	eca6                	sd	s1,88(sp)
    800039ac:	e8ca                	sd	s2,80(sp)
    800039ae:	e4ce                	sd	s3,72(sp)
    800039b0:	e0d2                	sd	s4,64(sp)
    800039b2:	fc56                	sd	s5,56(sp)
    800039b4:	f85a                	sd	s6,48(sp)
    800039b6:	f45e                	sd	s7,40(sp)
    800039b8:	f062                	sd	s8,32(sp)
    800039ba:	ec66                	sd	s9,24(sp)
    800039bc:	e86a                	sd	s10,16(sp)
    800039be:	e46e                	sd	s11,8(sp)
    800039c0:	1880                	addi	s0,sp,112
    800039c2:	8baa                	mv	s7,a0
    800039c4:	8c2e                	mv	s8,a1
    800039c6:	8ab2                	mv	s5,a2
    800039c8:	8936                	mv	s2,a3
    800039ca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039cc:	00e687bb          	addw	a5,a3,a4
    800039d0:	0ed7e063          	bltu	a5,a3,80003ab0 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039d4:	00043737          	lui	a4,0x43
    800039d8:	0cf76e63          	bltu	a4,a5,80003ab4 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039dc:	0a0b0763          	beqz	s6,80003a8a <writei+0xec>
    800039e0:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e2:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039e6:	5cfd                	li	s9,-1
    800039e8:	a091                	j	80003a2c <writei+0x8e>
    800039ea:	02099d93          	slli	s11,s3,0x20
    800039ee:	020ddd93          	srli	s11,s11,0x20
    800039f2:	05848793          	addi	a5,s1,88
    800039f6:	86ee                	mv	a3,s11
    800039f8:	8656                	mv	a2,s5
    800039fa:	85e2                	mv	a1,s8
    800039fc:	953e                	add	a0,a0,a5
    800039fe:	fffff097          	auipc	ra,0xfffff
    80003a02:	a8c080e7          	jalr	-1396(ra) # 8000248a <either_copyin>
    80003a06:	07950263          	beq	a0,s9,80003a6a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a0a:	8526                	mv	a0,s1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	77e080e7          	jalr	1918(ra) # 8000418a <log_write>
    brelse(bp);
    80003a14:	8526                	mv	a0,s1
    80003a16:	fffff097          	auipc	ra,0xfffff
    80003a1a:	50a080e7          	jalr	1290(ra) # 80002f20 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a1e:	01498a3b          	addw	s4,s3,s4
    80003a22:	0129893b          	addw	s2,s3,s2
    80003a26:	9aee                	add	s5,s5,s11
    80003a28:	056a7663          	bgeu	s4,s6,80003a74 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a2c:	000ba483          	lw	s1,0(s7)
    80003a30:	00a9559b          	srliw	a1,s2,0xa
    80003a34:	855e                	mv	a0,s7
    80003a36:	fffff097          	auipc	ra,0xfffff
    80003a3a:	7ae080e7          	jalr	1966(ra) # 800031e4 <bmap>
    80003a3e:	0005059b          	sext.w	a1,a0
    80003a42:	8526                	mv	a0,s1
    80003a44:	fffff097          	auipc	ra,0xfffff
    80003a48:	3ac080e7          	jalr	940(ra) # 80002df0 <bread>
    80003a4c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a4e:	3ff97513          	andi	a0,s2,1023
    80003a52:	40ad07bb          	subw	a5,s10,a0
    80003a56:	414b073b          	subw	a4,s6,s4
    80003a5a:	89be                	mv	s3,a5
    80003a5c:	2781                	sext.w	a5,a5
    80003a5e:	0007069b          	sext.w	a3,a4
    80003a62:	f8f6f4e3          	bgeu	a3,a5,800039ea <writei+0x4c>
    80003a66:	89ba                	mv	s3,a4
    80003a68:	b749                	j	800039ea <writei+0x4c>
      brelse(bp);
    80003a6a:	8526                	mv	a0,s1
    80003a6c:	fffff097          	auipc	ra,0xfffff
    80003a70:	4b4080e7          	jalr	1204(ra) # 80002f20 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003a74:	04cba783          	lw	a5,76(s7)
    80003a78:	0127f463          	bgeu	a5,s2,80003a80 <writei+0xe2>
      ip->size = off;
    80003a7c:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003a80:	855e                	mv	a0,s7
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	aa8080e7          	jalr	-1368(ra) # 8000352a <iupdate>
  }

  return n;
    80003a8a:	000b051b          	sext.w	a0,s6
}
    80003a8e:	70a6                	ld	ra,104(sp)
    80003a90:	7406                	ld	s0,96(sp)
    80003a92:	64e6                	ld	s1,88(sp)
    80003a94:	6946                	ld	s2,80(sp)
    80003a96:	69a6                	ld	s3,72(sp)
    80003a98:	6a06                	ld	s4,64(sp)
    80003a9a:	7ae2                	ld	s5,56(sp)
    80003a9c:	7b42                	ld	s6,48(sp)
    80003a9e:	7ba2                	ld	s7,40(sp)
    80003aa0:	7c02                	ld	s8,32(sp)
    80003aa2:	6ce2                	ld	s9,24(sp)
    80003aa4:	6d42                	ld	s10,16(sp)
    80003aa6:	6da2                	ld	s11,8(sp)
    80003aa8:	6165                	addi	sp,sp,112
    80003aaa:	8082                	ret
    return -1;
    80003aac:	557d                	li	a0,-1
}
    80003aae:	8082                	ret
    return -1;
    80003ab0:	557d                	li	a0,-1
    80003ab2:	bff1                	j	80003a8e <writei+0xf0>
    return -1;
    80003ab4:	557d                	li	a0,-1
    80003ab6:	bfe1                	j	80003a8e <writei+0xf0>

0000000080003ab8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ab8:	1141                	addi	sp,sp,-16
    80003aba:	e406                	sd	ra,8(sp)
    80003abc:	e022                	sd	s0,0(sp)
    80003abe:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ac0:	4639                	li	a2,14
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	310080e7          	jalr	784(ra) # 80000dd2 <strncmp>
}
    80003aca:	60a2                	ld	ra,8(sp)
    80003acc:	6402                	ld	s0,0(sp)
    80003ace:	0141                	addi	sp,sp,16
    80003ad0:	8082                	ret

0000000080003ad2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ad2:	7139                	addi	sp,sp,-64
    80003ad4:	fc06                	sd	ra,56(sp)
    80003ad6:	f822                	sd	s0,48(sp)
    80003ad8:	f426                	sd	s1,40(sp)
    80003ada:	f04a                	sd	s2,32(sp)
    80003adc:	ec4e                	sd	s3,24(sp)
    80003ade:	e852                	sd	s4,16(sp)
    80003ae0:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ae2:	04451703          	lh	a4,68(a0)
    80003ae6:	4785                	li	a5,1
    80003ae8:	00f71a63          	bne	a4,a5,80003afc <dirlookup+0x2a>
    80003aec:	892a                	mv	s2,a0
    80003aee:	89ae                	mv	s3,a1
    80003af0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003af2:	457c                	lw	a5,76(a0)
    80003af4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003af6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003af8:	e79d                	bnez	a5,80003b26 <dirlookup+0x54>
    80003afa:	a8a5                	j	80003b72 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003afc:	00005517          	auipc	a0,0x5
    80003b00:	acc50513          	addi	a0,a0,-1332 # 800085c8 <syscalls+0x1a0>
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	a3e080e7          	jalr	-1474(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003b0c:	00005517          	auipc	a0,0x5
    80003b10:	ad450513          	addi	a0,a0,-1324 # 800085e0 <syscalls+0x1b8>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	a2e080e7          	jalr	-1490(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b1c:	24c1                	addiw	s1,s1,16
    80003b1e:	04c92783          	lw	a5,76(s2)
    80003b22:	04f4f763          	bgeu	s1,a5,80003b70 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b26:	4741                	li	a4,16
    80003b28:	86a6                	mv	a3,s1
    80003b2a:	fc040613          	addi	a2,s0,-64
    80003b2e:	4581                	li	a1,0
    80003b30:	854a                	mv	a0,s2
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	d76080e7          	jalr	-650(ra) # 800038a8 <readi>
    80003b3a:	47c1                	li	a5,16
    80003b3c:	fcf518e3          	bne	a0,a5,80003b0c <dirlookup+0x3a>
    if(de.inum == 0)
    80003b40:	fc045783          	lhu	a5,-64(s0)
    80003b44:	dfe1                	beqz	a5,80003b1c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b46:	fc240593          	addi	a1,s0,-62
    80003b4a:	854e                	mv	a0,s3
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	f6c080e7          	jalr	-148(ra) # 80003ab8 <namecmp>
    80003b54:	f561                	bnez	a0,80003b1c <dirlookup+0x4a>
      if(poff)
    80003b56:	000a0463          	beqz	s4,80003b5e <dirlookup+0x8c>
        *poff = off;
    80003b5a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b5e:	fc045583          	lhu	a1,-64(s0)
    80003b62:	00092503          	lw	a0,0(s2)
    80003b66:	fffff097          	auipc	ra,0xfffff
    80003b6a:	75a080e7          	jalr	1882(ra) # 800032c0 <iget>
    80003b6e:	a011                	j	80003b72 <dirlookup+0xa0>
  return 0;
    80003b70:	4501                	li	a0,0
}
    80003b72:	70e2                	ld	ra,56(sp)
    80003b74:	7442                	ld	s0,48(sp)
    80003b76:	74a2                	ld	s1,40(sp)
    80003b78:	7902                	ld	s2,32(sp)
    80003b7a:	69e2                	ld	s3,24(sp)
    80003b7c:	6a42                	ld	s4,16(sp)
    80003b7e:	6121                	addi	sp,sp,64
    80003b80:	8082                	ret

0000000080003b82 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b82:	711d                	addi	sp,sp,-96
    80003b84:	ec86                	sd	ra,88(sp)
    80003b86:	e8a2                	sd	s0,80(sp)
    80003b88:	e4a6                	sd	s1,72(sp)
    80003b8a:	e0ca                	sd	s2,64(sp)
    80003b8c:	fc4e                	sd	s3,56(sp)
    80003b8e:	f852                	sd	s4,48(sp)
    80003b90:	f456                	sd	s5,40(sp)
    80003b92:	f05a                	sd	s6,32(sp)
    80003b94:	ec5e                	sd	s7,24(sp)
    80003b96:	e862                	sd	s8,16(sp)
    80003b98:	e466                	sd	s9,8(sp)
    80003b9a:	1080                	addi	s0,sp,96
    80003b9c:	84aa                	mv	s1,a0
    80003b9e:	8aae                	mv	s5,a1
    80003ba0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ba2:	00054703          	lbu	a4,0(a0)
    80003ba6:	02f00793          	li	a5,47
    80003baa:	02f70363          	beq	a4,a5,80003bd0 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bae:	ffffe097          	auipc	ra,0xffffe
    80003bb2:	e1c080e7          	jalr	-484(ra) # 800019ca <myproc>
    80003bb6:	15053503          	ld	a0,336(a0)
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	9fc080e7          	jalr	-1540(ra) # 800035b6 <idup>
    80003bc2:	89aa                	mv	s3,a0
  while(*path == '/')
    80003bc4:	02f00913          	li	s2,47
  len = path - s;
    80003bc8:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003bca:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bcc:	4b85                	li	s7,1
    80003bce:	a865                	j	80003c86 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003bd0:	4585                	li	a1,1
    80003bd2:	4505                	li	a0,1
    80003bd4:	fffff097          	auipc	ra,0xfffff
    80003bd8:	6ec080e7          	jalr	1772(ra) # 800032c0 <iget>
    80003bdc:	89aa                	mv	s3,a0
    80003bde:	b7dd                	j	80003bc4 <namex+0x42>
      iunlockput(ip);
    80003be0:	854e                	mv	a0,s3
    80003be2:	00000097          	auipc	ra,0x0
    80003be6:	c74080e7          	jalr	-908(ra) # 80003856 <iunlockput>
      return 0;
    80003bea:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bec:	854e                	mv	a0,s3
    80003bee:	60e6                	ld	ra,88(sp)
    80003bf0:	6446                	ld	s0,80(sp)
    80003bf2:	64a6                	ld	s1,72(sp)
    80003bf4:	6906                	ld	s2,64(sp)
    80003bf6:	79e2                	ld	s3,56(sp)
    80003bf8:	7a42                	ld	s4,48(sp)
    80003bfa:	7aa2                	ld	s5,40(sp)
    80003bfc:	7b02                	ld	s6,32(sp)
    80003bfe:	6be2                	ld	s7,24(sp)
    80003c00:	6c42                	ld	s8,16(sp)
    80003c02:	6ca2                	ld	s9,8(sp)
    80003c04:	6125                	addi	sp,sp,96
    80003c06:	8082                	ret
      iunlock(ip);
    80003c08:	854e                	mv	a0,s3
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	aac080e7          	jalr	-1364(ra) # 800036b6 <iunlock>
      return ip;
    80003c12:	bfe9                	j	80003bec <namex+0x6a>
      iunlockput(ip);
    80003c14:	854e                	mv	a0,s3
    80003c16:	00000097          	auipc	ra,0x0
    80003c1a:	c40080e7          	jalr	-960(ra) # 80003856 <iunlockput>
      return 0;
    80003c1e:	89e6                	mv	s3,s9
    80003c20:	b7f1                	j	80003bec <namex+0x6a>
  len = path - s;
    80003c22:	40b48633          	sub	a2,s1,a1
    80003c26:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c2a:	099c5463          	bge	s8,s9,80003cb2 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c2e:	4639                	li	a2,14
    80003c30:	8552                	mv	a0,s4
    80003c32:	ffffd097          	auipc	ra,0xffffd
    80003c36:	124080e7          	jalr	292(ra) # 80000d56 <memmove>
  while(*path == '/')
    80003c3a:	0004c783          	lbu	a5,0(s1)
    80003c3e:	01279763          	bne	a5,s2,80003c4c <namex+0xca>
    path++;
    80003c42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c44:	0004c783          	lbu	a5,0(s1)
    80003c48:	ff278de3          	beq	a5,s2,80003c42 <namex+0xc0>
    ilock(ip);
    80003c4c:	854e                	mv	a0,s3
    80003c4e:	00000097          	auipc	ra,0x0
    80003c52:	9a6080e7          	jalr	-1626(ra) # 800035f4 <ilock>
    if(ip->type != T_DIR){
    80003c56:	04499783          	lh	a5,68(s3)
    80003c5a:	f97793e3          	bne	a5,s7,80003be0 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c5e:	000a8563          	beqz	s5,80003c68 <namex+0xe6>
    80003c62:	0004c783          	lbu	a5,0(s1)
    80003c66:	d3cd                	beqz	a5,80003c08 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c68:	865a                	mv	a2,s6
    80003c6a:	85d2                	mv	a1,s4
    80003c6c:	854e                	mv	a0,s3
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	e64080e7          	jalr	-412(ra) # 80003ad2 <dirlookup>
    80003c76:	8caa                	mv	s9,a0
    80003c78:	dd51                	beqz	a0,80003c14 <namex+0x92>
    iunlockput(ip);
    80003c7a:	854e                	mv	a0,s3
    80003c7c:	00000097          	auipc	ra,0x0
    80003c80:	bda080e7          	jalr	-1062(ra) # 80003856 <iunlockput>
    ip = next;
    80003c84:	89e6                	mv	s3,s9
  while(*path == '/')
    80003c86:	0004c783          	lbu	a5,0(s1)
    80003c8a:	05279763          	bne	a5,s2,80003cd8 <namex+0x156>
    path++;
    80003c8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c90:	0004c783          	lbu	a5,0(s1)
    80003c94:	ff278de3          	beq	a5,s2,80003c8e <namex+0x10c>
  if(*path == 0)
    80003c98:	c79d                	beqz	a5,80003cc6 <namex+0x144>
    path++;
    80003c9a:	85a6                	mv	a1,s1
  len = path - s;
    80003c9c:	8cda                	mv	s9,s6
    80003c9e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003ca0:	01278963          	beq	a5,s2,80003cb2 <namex+0x130>
    80003ca4:	dfbd                	beqz	a5,80003c22 <namex+0xa0>
    path++;
    80003ca6:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003ca8:	0004c783          	lbu	a5,0(s1)
    80003cac:	ff279ce3          	bne	a5,s2,80003ca4 <namex+0x122>
    80003cb0:	bf8d                	j	80003c22 <namex+0xa0>
    memmove(name, s, len);
    80003cb2:	2601                	sext.w	a2,a2
    80003cb4:	8552                	mv	a0,s4
    80003cb6:	ffffd097          	auipc	ra,0xffffd
    80003cba:	0a0080e7          	jalr	160(ra) # 80000d56 <memmove>
    name[len] = 0;
    80003cbe:	9cd2                	add	s9,s9,s4
    80003cc0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003cc4:	bf9d                	j	80003c3a <namex+0xb8>
  if(nameiparent){
    80003cc6:	f20a83e3          	beqz	s5,80003bec <namex+0x6a>
    iput(ip);
    80003cca:	854e                	mv	a0,s3
    80003ccc:	00000097          	auipc	ra,0x0
    80003cd0:	ae2080e7          	jalr	-1310(ra) # 800037ae <iput>
    return 0;
    80003cd4:	4981                	li	s3,0
    80003cd6:	bf19                	j	80003bec <namex+0x6a>
  if(*path == 0)
    80003cd8:	d7fd                	beqz	a5,80003cc6 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003cda:	0004c783          	lbu	a5,0(s1)
    80003cde:	85a6                	mv	a1,s1
    80003ce0:	b7d1                	j	80003ca4 <namex+0x122>

0000000080003ce2 <dirlink>:
{
    80003ce2:	7139                	addi	sp,sp,-64
    80003ce4:	fc06                	sd	ra,56(sp)
    80003ce6:	f822                	sd	s0,48(sp)
    80003ce8:	f426                	sd	s1,40(sp)
    80003cea:	f04a                	sd	s2,32(sp)
    80003cec:	ec4e                	sd	s3,24(sp)
    80003cee:	e852                	sd	s4,16(sp)
    80003cf0:	0080                	addi	s0,sp,64
    80003cf2:	892a                	mv	s2,a0
    80003cf4:	8a2e                	mv	s4,a1
    80003cf6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cf8:	4601                	li	a2,0
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	dd8080e7          	jalr	-552(ra) # 80003ad2 <dirlookup>
    80003d02:	e93d                	bnez	a0,80003d78 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d04:	04c92483          	lw	s1,76(s2)
    80003d08:	c49d                	beqz	s1,80003d36 <dirlink+0x54>
    80003d0a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d0c:	4741                	li	a4,16
    80003d0e:	86a6                	mv	a3,s1
    80003d10:	fc040613          	addi	a2,s0,-64
    80003d14:	4581                	li	a1,0
    80003d16:	854a                	mv	a0,s2
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	b90080e7          	jalr	-1136(ra) # 800038a8 <readi>
    80003d20:	47c1                	li	a5,16
    80003d22:	06f51163          	bne	a0,a5,80003d84 <dirlink+0xa2>
    if(de.inum == 0)
    80003d26:	fc045783          	lhu	a5,-64(s0)
    80003d2a:	c791                	beqz	a5,80003d36 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d2c:	24c1                	addiw	s1,s1,16
    80003d2e:	04c92783          	lw	a5,76(s2)
    80003d32:	fcf4ede3          	bltu	s1,a5,80003d0c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d36:	4639                	li	a2,14
    80003d38:	85d2                	mv	a1,s4
    80003d3a:	fc240513          	addi	a0,s0,-62
    80003d3e:	ffffd097          	auipc	ra,0xffffd
    80003d42:	0d0080e7          	jalr	208(ra) # 80000e0e <strncpy>
  de.inum = inum;
    80003d46:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d4a:	4741                	li	a4,16
    80003d4c:	86a6                	mv	a3,s1
    80003d4e:	fc040613          	addi	a2,s0,-64
    80003d52:	4581                	li	a1,0
    80003d54:	854a                	mv	a0,s2
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	c48080e7          	jalr	-952(ra) # 8000399e <writei>
    80003d5e:	872a                	mv	a4,a0
    80003d60:	47c1                	li	a5,16
  return 0;
    80003d62:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d64:	02f71863          	bne	a4,a5,80003d94 <dirlink+0xb2>
}
    80003d68:	70e2                	ld	ra,56(sp)
    80003d6a:	7442                	ld	s0,48(sp)
    80003d6c:	74a2                	ld	s1,40(sp)
    80003d6e:	7902                	ld	s2,32(sp)
    80003d70:	69e2                	ld	s3,24(sp)
    80003d72:	6a42                	ld	s4,16(sp)
    80003d74:	6121                	addi	sp,sp,64
    80003d76:	8082                	ret
    iput(ip);
    80003d78:	00000097          	auipc	ra,0x0
    80003d7c:	a36080e7          	jalr	-1482(ra) # 800037ae <iput>
    return -1;
    80003d80:	557d                	li	a0,-1
    80003d82:	b7dd                	j	80003d68 <dirlink+0x86>
      panic("dirlink read");
    80003d84:	00005517          	auipc	a0,0x5
    80003d88:	86c50513          	addi	a0,a0,-1940 # 800085f0 <syscalls+0x1c8>
    80003d8c:	ffffc097          	auipc	ra,0xffffc
    80003d90:	7b6080e7          	jalr	1974(ra) # 80000542 <panic>
    panic("dirlink");
    80003d94:	00005517          	auipc	a0,0x5
    80003d98:	97c50513          	addi	a0,a0,-1668 # 80008710 <syscalls+0x2e8>
    80003d9c:	ffffc097          	auipc	ra,0xffffc
    80003da0:	7a6080e7          	jalr	1958(ra) # 80000542 <panic>

0000000080003da4 <namei>:

struct inode*
namei(char *path)
{
    80003da4:	1101                	addi	sp,sp,-32
    80003da6:	ec06                	sd	ra,24(sp)
    80003da8:	e822                	sd	s0,16(sp)
    80003daa:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003dac:	fe040613          	addi	a2,s0,-32
    80003db0:	4581                	li	a1,0
    80003db2:	00000097          	auipc	ra,0x0
    80003db6:	dd0080e7          	jalr	-560(ra) # 80003b82 <namex>
}
    80003dba:	60e2                	ld	ra,24(sp)
    80003dbc:	6442                	ld	s0,16(sp)
    80003dbe:	6105                	addi	sp,sp,32
    80003dc0:	8082                	ret

0000000080003dc2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003dc2:	1141                	addi	sp,sp,-16
    80003dc4:	e406                	sd	ra,8(sp)
    80003dc6:	e022                	sd	s0,0(sp)
    80003dc8:	0800                	addi	s0,sp,16
    80003dca:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dcc:	4585                	li	a1,1
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	db4080e7          	jalr	-588(ra) # 80003b82 <namex>
}
    80003dd6:	60a2                	ld	ra,8(sp)
    80003dd8:	6402                	ld	s0,0(sp)
    80003dda:	0141                	addi	sp,sp,16
    80003ddc:	8082                	ret

0000000080003dde <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003dde:	1101                	addi	sp,sp,-32
    80003de0:	ec06                	sd	ra,24(sp)
    80003de2:	e822                	sd	s0,16(sp)
    80003de4:	e426                	sd	s1,8(sp)
    80003de6:	e04a                	sd	s2,0(sp)
    80003de8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dea:	0001e917          	auipc	s2,0x1e
    80003dee:	b1e90913          	addi	s2,s2,-1250 # 80021908 <log>
    80003df2:	01892583          	lw	a1,24(s2)
    80003df6:	02892503          	lw	a0,40(s2)
    80003dfa:	fffff097          	auipc	ra,0xfffff
    80003dfe:	ff6080e7          	jalr	-10(ra) # 80002df0 <bread>
    80003e02:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e04:	02c92683          	lw	a3,44(s2)
    80003e08:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e0a:	02d05863          	blez	a3,80003e3a <write_head+0x5c>
    80003e0e:	0001e797          	auipc	a5,0x1e
    80003e12:	b2a78793          	addi	a5,a5,-1238 # 80021938 <log+0x30>
    80003e16:	05c50713          	addi	a4,a0,92
    80003e1a:	36fd                	addiw	a3,a3,-1
    80003e1c:	02069613          	slli	a2,a3,0x20
    80003e20:	01e65693          	srli	a3,a2,0x1e
    80003e24:	0001e617          	auipc	a2,0x1e
    80003e28:	b1860613          	addi	a2,a2,-1256 # 8002193c <log+0x34>
    80003e2c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e2e:	4390                	lw	a2,0(a5)
    80003e30:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e32:	0791                	addi	a5,a5,4
    80003e34:	0711                	addi	a4,a4,4
    80003e36:	fed79ce3          	bne	a5,a3,80003e2e <write_head+0x50>
  }
  bwrite(buf);
    80003e3a:	8526                	mv	a0,s1
    80003e3c:	fffff097          	auipc	ra,0xfffff
    80003e40:	0a6080e7          	jalr	166(ra) # 80002ee2 <bwrite>
  brelse(buf);
    80003e44:	8526                	mv	a0,s1
    80003e46:	fffff097          	auipc	ra,0xfffff
    80003e4a:	0da080e7          	jalr	218(ra) # 80002f20 <brelse>
}
    80003e4e:	60e2                	ld	ra,24(sp)
    80003e50:	6442                	ld	s0,16(sp)
    80003e52:	64a2                	ld	s1,8(sp)
    80003e54:	6902                	ld	s2,0(sp)
    80003e56:	6105                	addi	sp,sp,32
    80003e58:	8082                	ret

0000000080003e5a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e5a:	0001e797          	auipc	a5,0x1e
    80003e5e:	ada7a783          	lw	a5,-1318(a5) # 80021934 <log+0x2c>
    80003e62:	0af05663          	blez	a5,80003f0e <install_trans+0xb4>
{
    80003e66:	7139                	addi	sp,sp,-64
    80003e68:	fc06                	sd	ra,56(sp)
    80003e6a:	f822                	sd	s0,48(sp)
    80003e6c:	f426                	sd	s1,40(sp)
    80003e6e:	f04a                	sd	s2,32(sp)
    80003e70:	ec4e                	sd	s3,24(sp)
    80003e72:	e852                	sd	s4,16(sp)
    80003e74:	e456                	sd	s5,8(sp)
    80003e76:	0080                	addi	s0,sp,64
    80003e78:	0001ea97          	auipc	s5,0x1e
    80003e7c:	ac0a8a93          	addi	s5,s5,-1344 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e80:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e82:	0001e997          	auipc	s3,0x1e
    80003e86:	a8698993          	addi	s3,s3,-1402 # 80021908 <log>
    80003e8a:	0189a583          	lw	a1,24(s3)
    80003e8e:	014585bb          	addw	a1,a1,s4
    80003e92:	2585                	addiw	a1,a1,1
    80003e94:	0289a503          	lw	a0,40(s3)
    80003e98:	fffff097          	auipc	ra,0xfffff
    80003e9c:	f58080e7          	jalr	-168(ra) # 80002df0 <bread>
    80003ea0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ea2:	000aa583          	lw	a1,0(s5)
    80003ea6:	0289a503          	lw	a0,40(s3)
    80003eaa:	fffff097          	auipc	ra,0xfffff
    80003eae:	f46080e7          	jalr	-186(ra) # 80002df0 <bread>
    80003eb2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003eb4:	40000613          	li	a2,1024
    80003eb8:	05890593          	addi	a1,s2,88
    80003ebc:	05850513          	addi	a0,a0,88
    80003ec0:	ffffd097          	auipc	ra,0xffffd
    80003ec4:	e96080e7          	jalr	-362(ra) # 80000d56 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ec8:	8526                	mv	a0,s1
    80003eca:	fffff097          	auipc	ra,0xfffff
    80003ece:	018080e7          	jalr	24(ra) # 80002ee2 <bwrite>
    bunpin(dbuf);
    80003ed2:	8526                	mv	a0,s1
    80003ed4:	fffff097          	auipc	ra,0xfffff
    80003ed8:	126080e7          	jalr	294(ra) # 80002ffa <bunpin>
    brelse(lbuf);
    80003edc:	854a                	mv	a0,s2
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	042080e7          	jalr	66(ra) # 80002f20 <brelse>
    brelse(dbuf);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	fffff097          	auipc	ra,0xfffff
    80003eec:	038080e7          	jalr	56(ra) # 80002f20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ef0:	2a05                	addiw	s4,s4,1
    80003ef2:	0a91                	addi	s5,s5,4
    80003ef4:	02c9a783          	lw	a5,44(s3)
    80003ef8:	f8fa49e3          	blt	s4,a5,80003e8a <install_trans+0x30>
}
    80003efc:	70e2                	ld	ra,56(sp)
    80003efe:	7442                	ld	s0,48(sp)
    80003f00:	74a2                	ld	s1,40(sp)
    80003f02:	7902                	ld	s2,32(sp)
    80003f04:	69e2                	ld	s3,24(sp)
    80003f06:	6a42                	ld	s4,16(sp)
    80003f08:	6aa2                	ld	s5,8(sp)
    80003f0a:	6121                	addi	sp,sp,64
    80003f0c:	8082                	ret
    80003f0e:	8082                	ret

0000000080003f10 <initlog>:
{
    80003f10:	7179                	addi	sp,sp,-48
    80003f12:	f406                	sd	ra,40(sp)
    80003f14:	f022                	sd	s0,32(sp)
    80003f16:	ec26                	sd	s1,24(sp)
    80003f18:	e84a                	sd	s2,16(sp)
    80003f1a:	e44e                	sd	s3,8(sp)
    80003f1c:	1800                	addi	s0,sp,48
    80003f1e:	892a                	mv	s2,a0
    80003f20:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f22:	0001e497          	auipc	s1,0x1e
    80003f26:	9e648493          	addi	s1,s1,-1562 # 80021908 <log>
    80003f2a:	00004597          	auipc	a1,0x4
    80003f2e:	6d658593          	addi	a1,a1,1750 # 80008600 <syscalls+0x1d8>
    80003f32:	8526                	mv	a0,s1
    80003f34:	ffffd097          	auipc	ra,0xffffd
    80003f38:	c3a080e7          	jalr	-966(ra) # 80000b6e <initlock>
  log.start = sb->logstart;
    80003f3c:	0149a583          	lw	a1,20(s3)
    80003f40:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f42:	0109a783          	lw	a5,16(s3)
    80003f46:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f48:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f4c:	854a                	mv	a0,s2
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	ea2080e7          	jalr	-350(ra) # 80002df0 <bread>
  log.lh.n = lh->n;
    80003f56:	4d34                	lw	a3,88(a0)
    80003f58:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f5a:	02d05663          	blez	a3,80003f86 <initlog+0x76>
    80003f5e:	05c50793          	addi	a5,a0,92
    80003f62:	0001e717          	auipc	a4,0x1e
    80003f66:	9d670713          	addi	a4,a4,-1578 # 80021938 <log+0x30>
    80003f6a:	36fd                	addiw	a3,a3,-1
    80003f6c:	02069613          	slli	a2,a3,0x20
    80003f70:	01e65693          	srli	a3,a2,0x1e
    80003f74:	06050613          	addi	a2,a0,96
    80003f78:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003f7a:	4390                	lw	a2,0(a5)
    80003f7c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f7e:	0791                	addi	a5,a5,4
    80003f80:	0711                	addi	a4,a4,4
    80003f82:	fed79ce3          	bne	a5,a3,80003f7a <initlog+0x6a>
  brelse(buf);
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	f9a080e7          	jalr	-102(ra) # 80002f20 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80003f8e:	00000097          	auipc	ra,0x0
    80003f92:	ecc080e7          	jalr	-308(ra) # 80003e5a <install_trans>
  log.lh.n = 0;
    80003f96:	0001e797          	auipc	a5,0x1e
    80003f9a:	9807af23          	sw	zero,-1634(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	e40080e7          	jalr	-448(ra) # 80003dde <write_head>
}
    80003fa6:	70a2                	ld	ra,40(sp)
    80003fa8:	7402                	ld	s0,32(sp)
    80003faa:	64e2                	ld	s1,24(sp)
    80003fac:	6942                	ld	s2,16(sp)
    80003fae:	69a2                	ld	s3,8(sp)
    80003fb0:	6145                	addi	sp,sp,48
    80003fb2:	8082                	ret

0000000080003fb4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fb4:	1101                	addi	sp,sp,-32
    80003fb6:	ec06                	sd	ra,24(sp)
    80003fb8:	e822                	sd	s0,16(sp)
    80003fba:	e426                	sd	s1,8(sp)
    80003fbc:	e04a                	sd	s2,0(sp)
    80003fbe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fc0:	0001e517          	auipc	a0,0x1e
    80003fc4:	94850513          	addi	a0,a0,-1720 # 80021908 <log>
    80003fc8:	ffffd097          	auipc	ra,0xffffd
    80003fcc:	c36080e7          	jalr	-970(ra) # 80000bfe <acquire>
  while(1){
    if(log.committing){
    80003fd0:	0001e497          	auipc	s1,0x1e
    80003fd4:	93848493          	addi	s1,s1,-1736 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fd8:	4979                	li	s2,30
    80003fda:	a039                	j	80003fe8 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003fdc:	85a6                	mv	a1,s1
    80003fde:	8526                	mv	a0,s1
    80003fe0:	ffffe097          	auipc	ra,0xffffe
    80003fe4:	1fa080e7          	jalr	506(ra) # 800021da <sleep>
    if(log.committing){
    80003fe8:	50dc                	lw	a5,36(s1)
    80003fea:	fbed                	bnez	a5,80003fdc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fec:	509c                	lw	a5,32(s1)
    80003fee:	0017871b          	addiw	a4,a5,1
    80003ff2:	0007069b          	sext.w	a3,a4
    80003ff6:	0027179b          	slliw	a5,a4,0x2
    80003ffa:	9fb9                	addw	a5,a5,a4
    80003ffc:	0017979b          	slliw	a5,a5,0x1
    80004000:	54d8                	lw	a4,44(s1)
    80004002:	9fb9                	addw	a5,a5,a4
    80004004:	00f95963          	bge	s2,a5,80004016 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004008:	85a6                	mv	a1,s1
    8000400a:	8526                	mv	a0,s1
    8000400c:	ffffe097          	auipc	ra,0xffffe
    80004010:	1ce080e7          	jalr	462(ra) # 800021da <sleep>
    80004014:	bfd1                	j	80003fe8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004016:	0001e517          	auipc	a0,0x1e
    8000401a:	8f250513          	addi	a0,a0,-1806 # 80021908 <log>
    8000401e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004020:	ffffd097          	auipc	ra,0xffffd
    80004024:	c92080e7          	jalr	-878(ra) # 80000cb2 <release>
      break;
    }
  }
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret

0000000080004034 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004034:	7139                	addi	sp,sp,-64
    80004036:	fc06                	sd	ra,56(sp)
    80004038:	f822                	sd	s0,48(sp)
    8000403a:	f426                	sd	s1,40(sp)
    8000403c:	f04a                	sd	s2,32(sp)
    8000403e:	ec4e                	sd	s3,24(sp)
    80004040:	e852                	sd	s4,16(sp)
    80004042:	e456                	sd	s5,8(sp)
    80004044:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004046:	0001e497          	auipc	s1,0x1e
    8000404a:	8c248493          	addi	s1,s1,-1854 # 80021908 <log>
    8000404e:	8526                	mv	a0,s1
    80004050:	ffffd097          	auipc	ra,0xffffd
    80004054:	bae080e7          	jalr	-1106(ra) # 80000bfe <acquire>
  log.outstanding -= 1;
    80004058:	509c                	lw	a5,32(s1)
    8000405a:	37fd                	addiw	a5,a5,-1
    8000405c:	0007891b          	sext.w	s2,a5
    80004060:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004062:	50dc                	lw	a5,36(s1)
    80004064:	e7b9                	bnez	a5,800040b2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004066:	04091e63          	bnez	s2,800040c2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000406a:	0001e497          	auipc	s1,0x1e
    8000406e:	89e48493          	addi	s1,s1,-1890 # 80021908 <log>
    80004072:	4785                	li	a5,1
    80004074:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004076:	8526                	mv	a0,s1
    80004078:	ffffd097          	auipc	ra,0xffffd
    8000407c:	c3a080e7          	jalr	-966(ra) # 80000cb2 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004080:	54dc                	lw	a5,44(s1)
    80004082:	06f04763          	bgtz	a5,800040f0 <end_op+0xbc>
    acquire(&log.lock);
    80004086:	0001e497          	auipc	s1,0x1e
    8000408a:	88248493          	addi	s1,s1,-1918 # 80021908 <log>
    8000408e:	8526                	mv	a0,s1
    80004090:	ffffd097          	auipc	ra,0xffffd
    80004094:	b6e080e7          	jalr	-1170(ra) # 80000bfe <acquire>
    log.committing = 0;
    80004098:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000409c:	8526                	mv	a0,s1
    8000409e:	ffffe097          	auipc	ra,0xffffe
    800040a2:	2bc080e7          	jalr	700(ra) # 8000235a <wakeup>
    release(&log.lock);
    800040a6:	8526                	mv	a0,s1
    800040a8:	ffffd097          	auipc	ra,0xffffd
    800040ac:	c0a080e7          	jalr	-1014(ra) # 80000cb2 <release>
}
    800040b0:	a03d                	j	800040de <end_op+0xaa>
    panic("log.committing");
    800040b2:	00004517          	auipc	a0,0x4
    800040b6:	55650513          	addi	a0,a0,1366 # 80008608 <syscalls+0x1e0>
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	488080e7          	jalr	1160(ra) # 80000542 <panic>
    wakeup(&log);
    800040c2:	0001e497          	auipc	s1,0x1e
    800040c6:	84648493          	addi	s1,s1,-1978 # 80021908 <log>
    800040ca:	8526                	mv	a0,s1
    800040cc:	ffffe097          	auipc	ra,0xffffe
    800040d0:	28e080e7          	jalr	654(ra) # 8000235a <wakeup>
  release(&log.lock);
    800040d4:	8526                	mv	a0,s1
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	bdc080e7          	jalr	-1060(ra) # 80000cb2 <release>
}
    800040de:	70e2                	ld	ra,56(sp)
    800040e0:	7442                	ld	s0,48(sp)
    800040e2:	74a2                	ld	s1,40(sp)
    800040e4:	7902                	ld	s2,32(sp)
    800040e6:	69e2                	ld	s3,24(sp)
    800040e8:	6a42                	ld	s4,16(sp)
    800040ea:	6aa2                	ld	s5,8(sp)
    800040ec:	6121                	addi	sp,sp,64
    800040ee:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f0:	0001ea97          	auipc	s5,0x1e
    800040f4:	848a8a93          	addi	s5,s5,-1976 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800040f8:	0001ea17          	auipc	s4,0x1e
    800040fc:	810a0a13          	addi	s4,s4,-2032 # 80021908 <log>
    80004100:	018a2583          	lw	a1,24(s4)
    80004104:	012585bb          	addw	a1,a1,s2
    80004108:	2585                	addiw	a1,a1,1
    8000410a:	028a2503          	lw	a0,40(s4)
    8000410e:	fffff097          	auipc	ra,0xfffff
    80004112:	ce2080e7          	jalr	-798(ra) # 80002df0 <bread>
    80004116:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004118:	000aa583          	lw	a1,0(s5)
    8000411c:	028a2503          	lw	a0,40(s4)
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	cd0080e7          	jalr	-816(ra) # 80002df0 <bread>
    80004128:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000412a:	40000613          	li	a2,1024
    8000412e:	05850593          	addi	a1,a0,88
    80004132:	05848513          	addi	a0,s1,88
    80004136:	ffffd097          	auipc	ra,0xffffd
    8000413a:	c20080e7          	jalr	-992(ra) # 80000d56 <memmove>
    bwrite(to);  // write the log
    8000413e:	8526                	mv	a0,s1
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	da2080e7          	jalr	-606(ra) # 80002ee2 <bwrite>
    brelse(from);
    80004148:	854e                	mv	a0,s3
    8000414a:	fffff097          	auipc	ra,0xfffff
    8000414e:	dd6080e7          	jalr	-554(ra) # 80002f20 <brelse>
    brelse(to);
    80004152:	8526                	mv	a0,s1
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	dcc080e7          	jalr	-564(ra) # 80002f20 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000415c:	2905                	addiw	s2,s2,1
    8000415e:	0a91                	addi	s5,s5,4
    80004160:	02ca2783          	lw	a5,44(s4)
    80004164:	f8f94ee3          	blt	s2,a5,80004100 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004168:	00000097          	auipc	ra,0x0
    8000416c:	c76080e7          	jalr	-906(ra) # 80003dde <write_head>
    install_trans(); // Now install writes to home locations
    80004170:	00000097          	auipc	ra,0x0
    80004174:	cea080e7          	jalr	-790(ra) # 80003e5a <install_trans>
    log.lh.n = 0;
    80004178:	0001d797          	auipc	a5,0x1d
    8000417c:	7a07ae23          	sw	zero,1980(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004180:	00000097          	auipc	ra,0x0
    80004184:	c5e080e7          	jalr	-930(ra) # 80003dde <write_head>
    80004188:	bdfd                	j	80004086 <end_op+0x52>

000000008000418a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000418a:	1101                	addi	sp,sp,-32
    8000418c:	ec06                	sd	ra,24(sp)
    8000418e:	e822                	sd	s0,16(sp)
    80004190:	e426                	sd	s1,8(sp)
    80004192:	e04a                	sd	s2,0(sp)
    80004194:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004196:	0001d717          	auipc	a4,0x1d
    8000419a:	79e72703          	lw	a4,1950(a4) # 80021934 <log+0x2c>
    8000419e:	47f5                	li	a5,29
    800041a0:	08e7c063          	blt	a5,a4,80004220 <log_write+0x96>
    800041a4:	84aa                	mv	s1,a0
    800041a6:	0001d797          	auipc	a5,0x1d
    800041aa:	77e7a783          	lw	a5,1918(a5) # 80021924 <log+0x1c>
    800041ae:	37fd                	addiw	a5,a5,-1
    800041b0:	06f75863          	bge	a4,a5,80004220 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041b4:	0001d797          	auipc	a5,0x1d
    800041b8:	7747a783          	lw	a5,1908(a5) # 80021928 <log+0x20>
    800041bc:	06f05a63          	blez	a5,80004230 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800041c0:	0001d917          	auipc	s2,0x1d
    800041c4:	74890913          	addi	s2,s2,1864 # 80021908 <log>
    800041c8:	854a                	mv	a0,s2
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	a34080e7          	jalr	-1484(ra) # 80000bfe <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800041d2:	02c92603          	lw	a2,44(s2)
    800041d6:	06c05563          	blez	a2,80004240 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041da:	44cc                	lw	a1,12(s1)
    800041dc:	0001d717          	auipc	a4,0x1d
    800041e0:	75c70713          	addi	a4,a4,1884 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041e6:	4314                	lw	a3,0(a4)
    800041e8:	04b68d63          	beq	a3,a1,80004242 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800041ec:	2785                	addiw	a5,a5,1
    800041ee:	0711                	addi	a4,a4,4
    800041f0:	fec79be3          	bne	a5,a2,800041e6 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041f4:	0621                	addi	a2,a2,8
    800041f6:	060a                	slli	a2,a2,0x2
    800041f8:	0001d797          	auipc	a5,0x1d
    800041fc:	71078793          	addi	a5,a5,1808 # 80021908 <log>
    80004200:	963e                	add	a2,a2,a5
    80004202:	44dc                	lw	a5,12(s1)
    80004204:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004206:	8526                	mv	a0,s1
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	db6080e7          	jalr	-586(ra) # 80002fbe <bpin>
    log.lh.n++;
    80004210:	0001d717          	auipc	a4,0x1d
    80004214:	6f870713          	addi	a4,a4,1784 # 80021908 <log>
    80004218:	575c                	lw	a5,44(a4)
    8000421a:	2785                	addiw	a5,a5,1
    8000421c:	d75c                	sw	a5,44(a4)
    8000421e:	a83d                	j	8000425c <log_write+0xd2>
    panic("too big a transaction");
    80004220:	00004517          	auipc	a0,0x4
    80004224:	3f850513          	addi	a0,a0,1016 # 80008618 <syscalls+0x1f0>
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	31a080e7          	jalr	794(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    80004230:	00004517          	auipc	a0,0x4
    80004234:	40050513          	addi	a0,a0,1024 # 80008630 <syscalls+0x208>
    80004238:	ffffc097          	auipc	ra,0xffffc
    8000423c:	30a080e7          	jalr	778(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004240:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004242:	00878713          	addi	a4,a5,8
    80004246:	00271693          	slli	a3,a4,0x2
    8000424a:	0001d717          	auipc	a4,0x1d
    8000424e:	6be70713          	addi	a4,a4,1726 # 80021908 <log>
    80004252:	9736                	add	a4,a4,a3
    80004254:	44d4                	lw	a3,12(s1)
    80004256:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004258:	faf607e3          	beq	a2,a5,80004206 <log_write+0x7c>
  }
  release(&log.lock);
    8000425c:	0001d517          	auipc	a0,0x1d
    80004260:	6ac50513          	addi	a0,a0,1708 # 80021908 <log>
    80004264:	ffffd097          	auipc	ra,0xffffd
    80004268:	a4e080e7          	jalr	-1458(ra) # 80000cb2 <release>
}
    8000426c:	60e2                	ld	ra,24(sp)
    8000426e:	6442                	ld	s0,16(sp)
    80004270:	64a2                	ld	s1,8(sp)
    80004272:	6902                	ld	s2,0(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret

0000000080004278 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004278:	1101                	addi	sp,sp,-32
    8000427a:	ec06                	sd	ra,24(sp)
    8000427c:	e822                	sd	s0,16(sp)
    8000427e:	e426                	sd	s1,8(sp)
    80004280:	e04a                	sd	s2,0(sp)
    80004282:	1000                	addi	s0,sp,32
    80004284:	84aa                	mv	s1,a0
    80004286:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004288:	00004597          	auipc	a1,0x4
    8000428c:	3c858593          	addi	a1,a1,968 # 80008650 <syscalls+0x228>
    80004290:	0521                	addi	a0,a0,8
    80004292:	ffffd097          	auipc	ra,0xffffd
    80004296:	8dc080e7          	jalr	-1828(ra) # 80000b6e <initlock>
  lk->name = name;
    8000429a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000429e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042a2:	0204a423          	sw	zero,40(s1)
}
    800042a6:	60e2                	ld	ra,24(sp)
    800042a8:	6442                	ld	s0,16(sp)
    800042aa:	64a2                	ld	s1,8(sp)
    800042ac:	6902                	ld	s2,0(sp)
    800042ae:	6105                	addi	sp,sp,32
    800042b0:	8082                	ret

00000000800042b2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042b2:	1101                	addi	sp,sp,-32
    800042b4:	ec06                	sd	ra,24(sp)
    800042b6:	e822                	sd	s0,16(sp)
    800042b8:	e426                	sd	s1,8(sp)
    800042ba:	e04a                	sd	s2,0(sp)
    800042bc:	1000                	addi	s0,sp,32
    800042be:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042c0:	00850913          	addi	s2,a0,8
    800042c4:	854a                	mv	a0,s2
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	938080e7          	jalr	-1736(ra) # 80000bfe <acquire>
  while (lk->locked) {
    800042ce:	409c                	lw	a5,0(s1)
    800042d0:	cb89                	beqz	a5,800042e2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800042d2:	85ca                	mv	a1,s2
    800042d4:	8526                	mv	a0,s1
    800042d6:	ffffe097          	auipc	ra,0xffffe
    800042da:	f04080e7          	jalr	-252(ra) # 800021da <sleep>
  while (lk->locked) {
    800042de:	409c                	lw	a5,0(s1)
    800042e0:	fbed                	bnez	a5,800042d2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042e2:	4785                	li	a5,1
    800042e4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042e6:	ffffd097          	auipc	ra,0xffffd
    800042ea:	6e4080e7          	jalr	1764(ra) # 800019ca <myproc>
    800042ee:	5d1c                	lw	a5,56(a0)
    800042f0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042f2:	854a                	mv	a0,s2
    800042f4:	ffffd097          	auipc	ra,0xffffd
    800042f8:	9be080e7          	jalr	-1602(ra) # 80000cb2 <release>
}
    800042fc:	60e2                	ld	ra,24(sp)
    800042fe:	6442                	ld	s0,16(sp)
    80004300:	64a2                	ld	s1,8(sp)
    80004302:	6902                	ld	s2,0(sp)
    80004304:	6105                	addi	sp,sp,32
    80004306:	8082                	ret

0000000080004308 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004308:	1101                	addi	sp,sp,-32
    8000430a:	ec06                	sd	ra,24(sp)
    8000430c:	e822                	sd	s0,16(sp)
    8000430e:	e426                	sd	s1,8(sp)
    80004310:	e04a                	sd	s2,0(sp)
    80004312:	1000                	addi	s0,sp,32
    80004314:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004316:	00850913          	addi	s2,a0,8
    8000431a:	854a                	mv	a0,s2
    8000431c:	ffffd097          	auipc	ra,0xffffd
    80004320:	8e2080e7          	jalr	-1822(ra) # 80000bfe <acquire>
  lk->locked = 0;
    80004324:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004328:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000432c:	8526                	mv	a0,s1
    8000432e:	ffffe097          	auipc	ra,0xffffe
    80004332:	02c080e7          	jalr	44(ra) # 8000235a <wakeup>
  release(&lk->lk);
    80004336:	854a                	mv	a0,s2
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	97a080e7          	jalr	-1670(ra) # 80000cb2 <release>
}
    80004340:	60e2                	ld	ra,24(sp)
    80004342:	6442                	ld	s0,16(sp)
    80004344:	64a2                	ld	s1,8(sp)
    80004346:	6902                	ld	s2,0(sp)
    80004348:	6105                	addi	sp,sp,32
    8000434a:	8082                	ret

000000008000434c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000434c:	7179                	addi	sp,sp,-48
    8000434e:	f406                	sd	ra,40(sp)
    80004350:	f022                	sd	s0,32(sp)
    80004352:	ec26                	sd	s1,24(sp)
    80004354:	e84a                	sd	s2,16(sp)
    80004356:	e44e                	sd	s3,8(sp)
    80004358:	1800                	addi	s0,sp,48
    8000435a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000435c:	00850913          	addi	s2,a0,8
    80004360:	854a                	mv	a0,s2
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	89c080e7          	jalr	-1892(ra) # 80000bfe <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000436a:	409c                	lw	a5,0(s1)
    8000436c:	ef99                	bnez	a5,8000438a <holdingsleep+0x3e>
    8000436e:	4481                	li	s1,0
  release(&lk->lk);
    80004370:	854a                	mv	a0,s2
    80004372:	ffffd097          	auipc	ra,0xffffd
    80004376:	940080e7          	jalr	-1728(ra) # 80000cb2 <release>
  return r;
}
    8000437a:	8526                	mv	a0,s1
    8000437c:	70a2                	ld	ra,40(sp)
    8000437e:	7402                	ld	s0,32(sp)
    80004380:	64e2                	ld	s1,24(sp)
    80004382:	6942                	ld	s2,16(sp)
    80004384:	69a2                	ld	s3,8(sp)
    80004386:	6145                	addi	sp,sp,48
    80004388:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000438a:	0284a983          	lw	s3,40(s1)
    8000438e:	ffffd097          	auipc	ra,0xffffd
    80004392:	63c080e7          	jalr	1596(ra) # 800019ca <myproc>
    80004396:	5d04                	lw	s1,56(a0)
    80004398:	413484b3          	sub	s1,s1,s3
    8000439c:	0014b493          	seqz	s1,s1
    800043a0:	bfc1                	j	80004370 <holdingsleep+0x24>

00000000800043a2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043a2:	1141                	addi	sp,sp,-16
    800043a4:	e406                	sd	ra,8(sp)
    800043a6:	e022                	sd	s0,0(sp)
    800043a8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043aa:	00004597          	auipc	a1,0x4
    800043ae:	2b658593          	addi	a1,a1,694 # 80008660 <syscalls+0x238>
    800043b2:	0001d517          	auipc	a0,0x1d
    800043b6:	69e50513          	addi	a0,a0,1694 # 80021a50 <ftable>
    800043ba:	ffffc097          	auipc	ra,0xffffc
    800043be:	7b4080e7          	jalr	1972(ra) # 80000b6e <initlock>
}
    800043c2:	60a2                	ld	ra,8(sp)
    800043c4:	6402                	ld	s0,0(sp)
    800043c6:	0141                	addi	sp,sp,16
    800043c8:	8082                	ret

00000000800043ca <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043ca:	1101                	addi	sp,sp,-32
    800043cc:	ec06                	sd	ra,24(sp)
    800043ce:	e822                	sd	s0,16(sp)
    800043d0:	e426                	sd	s1,8(sp)
    800043d2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043d4:	0001d517          	auipc	a0,0x1d
    800043d8:	67c50513          	addi	a0,a0,1660 # 80021a50 <ftable>
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	822080e7          	jalr	-2014(ra) # 80000bfe <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043e4:	0001d497          	auipc	s1,0x1d
    800043e8:	68448493          	addi	s1,s1,1668 # 80021a68 <ftable+0x18>
    800043ec:	0001e717          	auipc	a4,0x1e
    800043f0:	61c70713          	addi	a4,a4,1564 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    800043f4:	40dc                	lw	a5,4(s1)
    800043f6:	cf99                	beqz	a5,80004414 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043f8:	02848493          	addi	s1,s1,40
    800043fc:	fee49ce3          	bne	s1,a4,800043f4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004400:	0001d517          	auipc	a0,0x1d
    80004404:	65050513          	addi	a0,a0,1616 # 80021a50 <ftable>
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	8aa080e7          	jalr	-1878(ra) # 80000cb2 <release>
  return 0;
    80004410:	4481                	li	s1,0
    80004412:	a819                	j	80004428 <filealloc+0x5e>
      f->ref = 1;
    80004414:	4785                	li	a5,1
    80004416:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004418:	0001d517          	auipc	a0,0x1d
    8000441c:	63850513          	addi	a0,a0,1592 # 80021a50 <ftable>
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	892080e7          	jalr	-1902(ra) # 80000cb2 <release>
}
    80004428:	8526                	mv	a0,s1
    8000442a:	60e2                	ld	ra,24(sp)
    8000442c:	6442                	ld	s0,16(sp)
    8000442e:	64a2                	ld	s1,8(sp)
    80004430:	6105                	addi	sp,sp,32
    80004432:	8082                	ret

0000000080004434 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004434:	1101                	addi	sp,sp,-32
    80004436:	ec06                	sd	ra,24(sp)
    80004438:	e822                	sd	s0,16(sp)
    8000443a:	e426                	sd	s1,8(sp)
    8000443c:	1000                	addi	s0,sp,32
    8000443e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004440:	0001d517          	auipc	a0,0x1d
    80004444:	61050513          	addi	a0,a0,1552 # 80021a50 <ftable>
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	7b6080e7          	jalr	1974(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    80004450:	40dc                	lw	a5,4(s1)
    80004452:	02f05263          	blez	a5,80004476 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004456:	2785                	addiw	a5,a5,1
    80004458:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000445a:	0001d517          	auipc	a0,0x1d
    8000445e:	5f650513          	addi	a0,a0,1526 # 80021a50 <ftable>
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	850080e7          	jalr	-1968(ra) # 80000cb2 <release>
  return f;
}
    8000446a:	8526                	mv	a0,s1
    8000446c:	60e2                	ld	ra,24(sp)
    8000446e:	6442                	ld	s0,16(sp)
    80004470:	64a2                	ld	s1,8(sp)
    80004472:	6105                	addi	sp,sp,32
    80004474:	8082                	ret
    panic("filedup");
    80004476:	00004517          	auipc	a0,0x4
    8000447a:	1f250513          	addi	a0,a0,498 # 80008668 <syscalls+0x240>
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	0c4080e7          	jalr	196(ra) # 80000542 <panic>

0000000080004486 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004486:	7139                	addi	sp,sp,-64
    80004488:	fc06                	sd	ra,56(sp)
    8000448a:	f822                	sd	s0,48(sp)
    8000448c:	f426                	sd	s1,40(sp)
    8000448e:	f04a                	sd	s2,32(sp)
    80004490:	ec4e                	sd	s3,24(sp)
    80004492:	e852                	sd	s4,16(sp)
    80004494:	e456                	sd	s5,8(sp)
    80004496:	0080                	addi	s0,sp,64
    80004498:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000449a:	0001d517          	auipc	a0,0x1d
    8000449e:	5b650513          	addi	a0,a0,1462 # 80021a50 <ftable>
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	75c080e7          	jalr	1884(ra) # 80000bfe <acquire>
  if(f->ref < 1)
    800044aa:	40dc                	lw	a5,4(s1)
    800044ac:	06f05163          	blez	a5,8000450e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044b0:	37fd                	addiw	a5,a5,-1
    800044b2:	0007871b          	sext.w	a4,a5
    800044b6:	c0dc                	sw	a5,4(s1)
    800044b8:	06e04363          	bgtz	a4,8000451e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044bc:	0004a903          	lw	s2,0(s1)
    800044c0:	0094ca83          	lbu	s5,9(s1)
    800044c4:	0104ba03          	ld	s4,16(s1)
    800044c8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044cc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044d0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044d4:	0001d517          	auipc	a0,0x1d
    800044d8:	57c50513          	addi	a0,a0,1404 # 80021a50 <ftable>
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	7d6080e7          	jalr	2006(ra) # 80000cb2 <release>

  if(ff.type == FD_PIPE){
    800044e4:	4785                	li	a5,1
    800044e6:	04f90d63          	beq	s2,a5,80004540 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044ea:	3979                	addiw	s2,s2,-2
    800044ec:	4785                	li	a5,1
    800044ee:	0527e063          	bltu	a5,s2,8000452e <fileclose+0xa8>
    begin_op();
    800044f2:	00000097          	auipc	ra,0x0
    800044f6:	ac2080e7          	jalr	-1342(ra) # 80003fb4 <begin_op>
    iput(ff.ip);
    800044fa:	854e                	mv	a0,s3
    800044fc:	fffff097          	auipc	ra,0xfffff
    80004500:	2b2080e7          	jalr	690(ra) # 800037ae <iput>
    end_op();
    80004504:	00000097          	auipc	ra,0x0
    80004508:	b30080e7          	jalr	-1232(ra) # 80004034 <end_op>
    8000450c:	a00d                	j	8000452e <fileclose+0xa8>
    panic("fileclose");
    8000450e:	00004517          	auipc	a0,0x4
    80004512:	16250513          	addi	a0,a0,354 # 80008670 <syscalls+0x248>
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	02c080e7          	jalr	44(ra) # 80000542 <panic>
    release(&ftable.lock);
    8000451e:	0001d517          	auipc	a0,0x1d
    80004522:	53250513          	addi	a0,a0,1330 # 80021a50 <ftable>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	78c080e7          	jalr	1932(ra) # 80000cb2 <release>
  }
}
    8000452e:	70e2                	ld	ra,56(sp)
    80004530:	7442                	ld	s0,48(sp)
    80004532:	74a2                	ld	s1,40(sp)
    80004534:	7902                	ld	s2,32(sp)
    80004536:	69e2                	ld	s3,24(sp)
    80004538:	6a42                	ld	s4,16(sp)
    8000453a:	6aa2                	ld	s5,8(sp)
    8000453c:	6121                	addi	sp,sp,64
    8000453e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004540:	85d6                	mv	a1,s5
    80004542:	8552                	mv	a0,s4
    80004544:	00000097          	auipc	ra,0x0
    80004548:	372080e7          	jalr	882(ra) # 800048b6 <pipeclose>
    8000454c:	b7cd                	j	8000452e <fileclose+0xa8>

000000008000454e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000454e:	715d                	addi	sp,sp,-80
    80004550:	e486                	sd	ra,72(sp)
    80004552:	e0a2                	sd	s0,64(sp)
    80004554:	fc26                	sd	s1,56(sp)
    80004556:	f84a                	sd	s2,48(sp)
    80004558:	f44e                	sd	s3,40(sp)
    8000455a:	0880                	addi	s0,sp,80
    8000455c:	84aa                	mv	s1,a0
    8000455e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004560:	ffffd097          	auipc	ra,0xffffd
    80004564:	46a080e7          	jalr	1130(ra) # 800019ca <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004568:	409c                	lw	a5,0(s1)
    8000456a:	37f9                	addiw	a5,a5,-2
    8000456c:	4705                	li	a4,1
    8000456e:	04f76763          	bltu	a4,a5,800045bc <filestat+0x6e>
    80004572:	892a                	mv	s2,a0
    ilock(f->ip);
    80004574:	6c88                	ld	a0,24(s1)
    80004576:	fffff097          	auipc	ra,0xfffff
    8000457a:	07e080e7          	jalr	126(ra) # 800035f4 <ilock>
    stati(f->ip, &st);
    8000457e:	fb840593          	addi	a1,s0,-72
    80004582:	6c88                	ld	a0,24(s1)
    80004584:	fffff097          	auipc	ra,0xfffff
    80004588:	2fa080e7          	jalr	762(ra) # 8000387e <stati>
    iunlock(f->ip);
    8000458c:	6c88                	ld	a0,24(s1)
    8000458e:	fffff097          	auipc	ra,0xfffff
    80004592:	128080e7          	jalr	296(ra) # 800036b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004596:	46e1                	li	a3,24
    80004598:	fb840613          	addi	a2,s0,-72
    8000459c:	85ce                	mv	a1,s3
    8000459e:	05093503          	ld	a0,80(s2)
    800045a2:	ffffd097          	auipc	ra,0xffffd
    800045a6:	11a080e7          	jalr	282(ra) # 800016bc <copyout>
    800045aa:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045ae:	60a6                	ld	ra,72(sp)
    800045b0:	6406                	ld	s0,64(sp)
    800045b2:	74e2                	ld	s1,56(sp)
    800045b4:	7942                	ld	s2,48(sp)
    800045b6:	79a2                	ld	s3,40(sp)
    800045b8:	6161                	addi	sp,sp,80
    800045ba:	8082                	ret
  return -1;
    800045bc:	557d                	li	a0,-1
    800045be:	bfc5                	j	800045ae <filestat+0x60>

00000000800045c0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045c0:	7179                	addi	sp,sp,-48
    800045c2:	f406                	sd	ra,40(sp)
    800045c4:	f022                	sd	s0,32(sp)
    800045c6:	ec26                	sd	s1,24(sp)
    800045c8:	e84a                	sd	s2,16(sp)
    800045ca:	e44e                	sd	s3,8(sp)
    800045cc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045ce:	00854783          	lbu	a5,8(a0)
    800045d2:	c3d5                	beqz	a5,80004676 <fileread+0xb6>
    800045d4:	84aa                	mv	s1,a0
    800045d6:	89ae                	mv	s3,a1
    800045d8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045da:	411c                	lw	a5,0(a0)
    800045dc:	4705                	li	a4,1
    800045de:	04e78963          	beq	a5,a4,80004630 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045e2:	470d                	li	a4,3
    800045e4:	04e78d63          	beq	a5,a4,8000463e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045e8:	4709                	li	a4,2
    800045ea:	06e79e63          	bne	a5,a4,80004666 <fileread+0xa6>
    ilock(f->ip);
    800045ee:	6d08                	ld	a0,24(a0)
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	004080e7          	jalr	4(ra) # 800035f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045f8:	874a                	mv	a4,s2
    800045fa:	5094                	lw	a3,32(s1)
    800045fc:	864e                	mv	a2,s3
    800045fe:	4585                	li	a1,1
    80004600:	6c88                	ld	a0,24(s1)
    80004602:	fffff097          	auipc	ra,0xfffff
    80004606:	2a6080e7          	jalr	678(ra) # 800038a8 <readi>
    8000460a:	892a                	mv	s2,a0
    8000460c:	00a05563          	blez	a0,80004616 <fileread+0x56>
      f->off += r;
    80004610:	509c                	lw	a5,32(s1)
    80004612:	9fa9                	addw	a5,a5,a0
    80004614:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004616:	6c88                	ld	a0,24(s1)
    80004618:	fffff097          	auipc	ra,0xfffff
    8000461c:	09e080e7          	jalr	158(ra) # 800036b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004620:	854a                	mv	a0,s2
    80004622:	70a2                	ld	ra,40(sp)
    80004624:	7402                	ld	s0,32(sp)
    80004626:	64e2                	ld	s1,24(sp)
    80004628:	6942                	ld	s2,16(sp)
    8000462a:	69a2                	ld	s3,8(sp)
    8000462c:	6145                	addi	sp,sp,48
    8000462e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004630:	6908                	ld	a0,16(a0)
    80004632:	00000097          	auipc	ra,0x0
    80004636:	3f4080e7          	jalr	1012(ra) # 80004a26 <piperead>
    8000463a:	892a                	mv	s2,a0
    8000463c:	b7d5                	j	80004620 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000463e:	02451783          	lh	a5,36(a0)
    80004642:	03079693          	slli	a3,a5,0x30
    80004646:	92c1                	srli	a3,a3,0x30
    80004648:	4725                	li	a4,9
    8000464a:	02d76863          	bltu	a4,a3,8000467a <fileread+0xba>
    8000464e:	0792                	slli	a5,a5,0x4
    80004650:	0001d717          	auipc	a4,0x1d
    80004654:	36070713          	addi	a4,a4,864 # 800219b0 <devsw>
    80004658:	97ba                	add	a5,a5,a4
    8000465a:	639c                	ld	a5,0(a5)
    8000465c:	c38d                	beqz	a5,8000467e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000465e:	4505                	li	a0,1
    80004660:	9782                	jalr	a5
    80004662:	892a                	mv	s2,a0
    80004664:	bf75                	j	80004620 <fileread+0x60>
    panic("fileread");
    80004666:	00004517          	auipc	a0,0x4
    8000466a:	01a50513          	addi	a0,a0,26 # 80008680 <syscalls+0x258>
    8000466e:	ffffc097          	auipc	ra,0xffffc
    80004672:	ed4080e7          	jalr	-300(ra) # 80000542 <panic>
    return -1;
    80004676:	597d                	li	s2,-1
    80004678:	b765                	j	80004620 <fileread+0x60>
      return -1;
    8000467a:	597d                	li	s2,-1
    8000467c:	b755                	j	80004620 <fileread+0x60>
    8000467e:	597d                	li	s2,-1
    80004680:	b745                	j	80004620 <fileread+0x60>

0000000080004682 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004682:	00954783          	lbu	a5,9(a0)
    80004686:	14078563          	beqz	a5,800047d0 <filewrite+0x14e>
{
    8000468a:	715d                	addi	sp,sp,-80
    8000468c:	e486                	sd	ra,72(sp)
    8000468e:	e0a2                	sd	s0,64(sp)
    80004690:	fc26                	sd	s1,56(sp)
    80004692:	f84a                	sd	s2,48(sp)
    80004694:	f44e                	sd	s3,40(sp)
    80004696:	f052                	sd	s4,32(sp)
    80004698:	ec56                	sd	s5,24(sp)
    8000469a:	e85a                	sd	s6,16(sp)
    8000469c:	e45e                	sd	s7,8(sp)
    8000469e:	e062                	sd	s8,0(sp)
    800046a0:	0880                	addi	s0,sp,80
    800046a2:	892a                	mv	s2,a0
    800046a4:	8aae                	mv	s5,a1
    800046a6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a8:	411c                	lw	a5,0(a0)
    800046aa:	4705                	li	a4,1
    800046ac:	02e78263          	beq	a5,a4,800046d0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046b0:	470d                	li	a4,3
    800046b2:	02e78563          	beq	a5,a4,800046dc <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b6:	4709                	li	a4,2
    800046b8:	10e79463          	bne	a5,a4,800047c0 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046bc:	0ec05e63          	blez	a2,800047b8 <filewrite+0x136>
    int i = 0;
    800046c0:	4981                	li	s3,0
    800046c2:	6b05                	lui	s6,0x1
    800046c4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046c8:	6b85                	lui	s7,0x1
    800046ca:	c00b8b9b          	addiw	s7,s7,-1024
    800046ce:	a851                	j	80004762 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800046d0:	6908                	ld	a0,16(a0)
    800046d2:	00000097          	auipc	ra,0x0
    800046d6:	254080e7          	jalr	596(ra) # 80004926 <pipewrite>
    800046da:	a85d                	j	80004790 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046dc:	02451783          	lh	a5,36(a0)
    800046e0:	03079693          	slli	a3,a5,0x30
    800046e4:	92c1                	srli	a3,a3,0x30
    800046e6:	4725                	li	a4,9
    800046e8:	0ed76663          	bltu	a4,a3,800047d4 <filewrite+0x152>
    800046ec:	0792                	slli	a5,a5,0x4
    800046ee:	0001d717          	auipc	a4,0x1d
    800046f2:	2c270713          	addi	a4,a4,706 # 800219b0 <devsw>
    800046f6:	97ba                	add	a5,a5,a4
    800046f8:	679c                	ld	a5,8(a5)
    800046fa:	cff9                	beqz	a5,800047d8 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800046fc:	4505                	li	a0,1
    800046fe:	9782                	jalr	a5
    80004700:	a841                	j	80004790 <filewrite+0x10e>
    80004702:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004706:	00000097          	auipc	ra,0x0
    8000470a:	8ae080e7          	jalr	-1874(ra) # 80003fb4 <begin_op>
      ilock(f->ip);
    8000470e:	01893503          	ld	a0,24(s2)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	ee2080e7          	jalr	-286(ra) # 800035f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000471a:	8762                	mv	a4,s8
    8000471c:	02092683          	lw	a3,32(s2)
    80004720:	01598633          	add	a2,s3,s5
    80004724:	4585                	li	a1,1
    80004726:	01893503          	ld	a0,24(s2)
    8000472a:	fffff097          	auipc	ra,0xfffff
    8000472e:	274080e7          	jalr	628(ra) # 8000399e <writei>
    80004732:	84aa                	mv	s1,a0
    80004734:	02a05f63          	blez	a0,80004772 <filewrite+0xf0>
        f->off += r;
    80004738:	02092783          	lw	a5,32(s2)
    8000473c:	9fa9                	addw	a5,a5,a0
    8000473e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004742:	01893503          	ld	a0,24(s2)
    80004746:	fffff097          	auipc	ra,0xfffff
    8000474a:	f70080e7          	jalr	-144(ra) # 800036b6 <iunlock>
      end_op();
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	8e6080e7          	jalr	-1818(ra) # 80004034 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004756:	049c1963          	bne	s8,s1,800047a8 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    8000475a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000475e:	0349d663          	bge	s3,s4,8000478a <filewrite+0x108>
      int n1 = n - i;
    80004762:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004766:	84be                	mv	s1,a5
    80004768:	2781                	sext.w	a5,a5
    8000476a:	f8fb5ce3          	bge	s6,a5,80004702 <filewrite+0x80>
    8000476e:	84de                	mv	s1,s7
    80004770:	bf49                	j	80004702 <filewrite+0x80>
      iunlock(f->ip);
    80004772:	01893503          	ld	a0,24(s2)
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	f40080e7          	jalr	-192(ra) # 800036b6 <iunlock>
      end_op();
    8000477e:	00000097          	auipc	ra,0x0
    80004782:	8b6080e7          	jalr	-1866(ra) # 80004034 <end_op>
      if(r < 0)
    80004786:	fc04d8e3          	bgez	s1,80004756 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000478a:	8552                	mv	a0,s4
    8000478c:	033a1863          	bne	s4,s3,800047bc <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004790:	60a6                	ld	ra,72(sp)
    80004792:	6406                	ld	s0,64(sp)
    80004794:	74e2                	ld	s1,56(sp)
    80004796:	7942                	ld	s2,48(sp)
    80004798:	79a2                	ld	s3,40(sp)
    8000479a:	7a02                	ld	s4,32(sp)
    8000479c:	6ae2                	ld	s5,24(sp)
    8000479e:	6b42                	ld	s6,16(sp)
    800047a0:	6ba2                	ld	s7,8(sp)
    800047a2:	6c02                	ld	s8,0(sp)
    800047a4:	6161                	addi	sp,sp,80
    800047a6:	8082                	ret
        panic("short filewrite");
    800047a8:	00004517          	auipc	a0,0x4
    800047ac:	ee850513          	addi	a0,a0,-280 # 80008690 <syscalls+0x268>
    800047b0:	ffffc097          	auipc	ra,0xffffc
    800047b4:	d92080e7          	jalr	-622(ra) # 80000542 <panic>
    int i = 0;
    800047b8:	4981                	li	s3,0
    800047ba:	bfc1                	j	8000478a <filewrite+0x108>
    ret = (i == n ? n : -1);
    800047bc:	557d                	li	a0,-1
    800047be:	bfc9                	j	80004790 <filewrite+0x10e>
    panic("filewrite");
    800047c0:	00004517          	auipc	a0,0x4
    800047c4:	ee050513          	addi	a0,a0,-288 # 800086a0 <syscalls+0x278>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	d7a080e7          	jalr	-646(ra) # 80000542 <panic>
    return -1;
    800047d0:	557d                	li	a0,-1
}
    800047d2:	8082                	ret
      return -1;
    800047d4:	557d                	li	a0,-1
    800047d6:	bf6d                	j	80004790 <filewrite+0x10e>
    800047d8:	557d                	li	a0,-1
    800047da:	bf5d                	j	80004790 <filewrite+0x10e>

00000000800047dc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047dc:	7179                	addi	sp,sp,-48
    800047de:	f406                	sd	ra,40(sp)
    800047e0:	f022                	sd	s0,32(sp)
    800047e2:	ec26                	sd	s1,24(sp)
    800047e4:	e84a                	sd	s2,16(sp)
    800047e6:	e44e                	sd	s3,8(sp)
    800047e8:	e052                	sd	s4,0(sp)
    800047ea:	1800                	addi	s0,sp,48
    800047ec:	84aa                	mv	s1,a0
    800047ee:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047f0:	0005b023          	sd	zero,0(a1)
    800047f4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	bd2080e7          	jalr	-1070(ra) # 800043ca <filealloc>
    80004800:	e088                	sd	a0,0(s1)
    80004802:	c551                	beqz	a0,8000488e <pipealloc+0xb2>
    80004804:	00000097          	auipc	ra,0x0
    80004808:	bc6080e7          	jalr	-1082(ra) # 800043ca <filealloc>
    8000480c:	00aa3023          	sd	a0,0(s4)
    80004810:	c92d                	beqz	a0,80004882 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	2fc080e7          	jalr	764(ra) # 80000b0e <kalloc>
    8000481a:	892a                	mv	s2,a0
    8000481c:	c125                	beqz	a0,8000487c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000481e:	4985                	li	s3,1
    80004820:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004824:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004828:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000482c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004830:	00004597          	auipc	a1,0x4
    80004834:	e8058593          	addi	a1,a1,-384 # 800086b0 <syscalls+0x288>
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	336080e7          	jalr	822(ra) # 80000b6e <initlock>
  (*f0)->type = FD_PIPE;
    80004840:	609c                	ld	a5,0(s1)
    80004842:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004846:	609c                	ld	a5,0(s1)
    80004848:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000484c:	609c                	ld	a5,0(s1)
    8000484e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004852:	609c                	ld	a5,0(s1)
    80004854:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004858:	000a3783          	ld	a5,0(s4)
    8000485c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004860:	000a3783          	ld	a5,0(s4)
    80004864:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004868:	000a3783          	ld	a5,0(s4)
    8000486c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004870:	000a3783          	ld	a5,0(s4)
    80004874:	0127b823          	sd	s2,16(a5)
  return 0;
    80004878:	4501                	li	a0,0
    8000487a:	a025                	j	800048a2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000487c:	6088                	ld	a0,0(s1)
    8000487e:	e501                	bnez	a0,80004886 <pipealloc+0xaa>
    80004880:	a039                	j	8000488e <pipealloc+0xb2>
    80004882:	6088                	ld	a0,0(s1)
    80004884:	c51d                	beqz	a0,800048b2 <pipealloc+0xd6>
    fileclose(*f0);
    80004886:	00000097          	auipc	ra,0x0
    8000488a:	c00080e7          	jalr	-1024(ra) # 80004486 <fileclose>
  if(*f1)
    8000488e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004892:	557d                	li	a0,-1
  if(*f1)
    80004894:	c799                	beqz	a5,800048a2 <pipealloc+0xc6>
    fileclose(*f1);
    80004896:	853e                	mv	a0,a5
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	bee080e7          	jalr	-1042(ra) # 80004486 <fileclose>
  return -1;
    800048a0:	557d                	li	a0,-1
}
    800048a2:	70a2                	ld	ra,40(sp)
    800048a4:	7402                	ld	s0,32(sp)
    800048a6:	64e2                	ld	s1,24(sp)
    800048a8:	6942                	ld	s2,16(sp)
    800048aa:	69a2                	ld	s3,8(sp)
    800048ac:	6a02                	ld	s4,0(sp)
    800048ae:	6145                	addi	sp,sp,48
    800048b0:	8082                	ret
  return -1;
    800048b2:	557d                	li	a0,-1
    800048b4:	b7fd                	j	800048a2 <pipealloc+0xc6>

00000000800048b6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	e426                	sd	s1,8(sp)
    800048be:	e04a                	sd	s2,0(sp)
    800048c0:	1000                	addi	s0,sp,32
    800048c2:	84aa                	mv	s1,a0
    800048c4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	338080e7          	jalr	824(ra) # 80000bfe <acquire>
  if(writable){
    800048ce:	02090d63          	beqz	s2,80004908 <pipeclose+0x52>
    pi->writeopen = 0;
    800048d2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048d6:	21848513          	addi	a0,s1,536
    800048da:	ffffe097          	auipc	ra,0xffffe
    800048de:	a80080e7          	jalr	-1408(ra) # 8000235a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048e2:	2204b783          	ld	a5,544(s1)
    800048e6:	eb95                	bnez	a5,8000491a <pipeclose+0x64>
    release(&pi->lock);
    800048e8:	8526                	mv	a0,s1
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	3c8080e7          	jalr	968(ra) # 80000cb2 <release>
    kfree((char*)pi);
    800048f2:	8526                	mv	a0,s1
    800048f4:	ffffc097          	auipc	ra,0xffffc
    800048f8:	11e080e7          	jalr	286(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    800048fc:	60e2                	ld	ra,24(sp)
    800048fe:	6442                	ld	s0,16(sp)
    80004900:	64a2                	ld	s1,8(sp)
    80004902:	6902                	ld	s2,0(sp)
    80004904:	6105                	addi	sp,sp,32
    80004906:	8082                	ret
    pi->readopen = 0;
    80004908:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000490c:	21c48513          	addi	a0,s1,540
    80004910:	ffffe097          	auipc	ra,0xffffe
    80004914:	a4a080e7          	jalr	-1462(ra) # 8000235a <wakeup>
    80004918:	b7e9                	j	800048e2 <pipeclose+0x2c>
    release(&pi->lock);
    8000491a:	8526                	mv	a0,s1
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	396080e7          	jalr	918(ra) # 80000cb2 <release>
}
    80004924:	bfe1                	j	800048fc <pipeclose+0x46>

0000000080004926 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004926:	711d                	addi	sp,sp,-96
    80004928:	ec86                	sd	ra,88(sp)
    8000492a:	e8a2                	sd	s0,80(sp)
    8000492c:	e4a6                	sd	s1,72(sp)
    8000492e:	e0ca                	sd	s2,64(sp)
    80004930:	fc4e                	sd	s3,56(sp)
    80004932:	f852                	sd	s4,48(sp)
    80004934:	f456                	sd	s5,40(sp)
    80004936:	f05a                	sd	s6,32(sp)
    80004938:	ec5e                	sd	s7,24(sp)
    8000493a:	e862                	sd	s8,16(sp)
    8000493c:	1080                	addi	s0,sp,96
    8000493e:	84aa                	mv	s1,a0
    80004940:	8b2e                	mv	s6,a1
    80004942:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004944:	ffffd097          	auipc	ra,0xffffd
    80004948:	086080e7          	jalr	134(ra) # 800019ca <myproc>
    8000494c:	892a                	mv	s2,a0

  acquire(&pi->lock);
    8000494e:	8526                	mv	a0,s1
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	2ae080e7          	jalr	686(ra) # 80000bfe <acquire>
  for(i = 0; i < n; i++){
    80004958:	09505763          	blez	s5,800049e6 <pipewrite+0xc0>
    8000495c:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    8000495e:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004962:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004966:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004968:	2184a783          	lw	a5,536(s1)
    8000496c:	21c4a703          	lw	a4,540(s1)
    80004970:	2007879b          	addiw	a5,a5,512
    80004974:	02f71b63          	bne	a4,a5,800049aa <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004978:	2204a783          	lw	a5,544(s1)
    8000497c:	c3d1                	beqz	a5,80004a00 <pipewrite+0xda>
    8000497e:	03092783          	lw	a5,48(s2)
    80004982:	efbd                	bnez	a5,80004a00 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004984:	8552                	mv	a0,s4
    80004986:	ffffe097          	auipc	ra,0xffffe
    8000498a:	9d4080e7          	jalr	-1580(ra) # 8000235a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000498e:	85a6                	mv	a1,s1
    80004990:	854e                	mv	a0,s3
    80004992:	ffffe097          	auipc	ra,0xffffe
    80004996:	848080e7          	jalr	-1976(ra) # 800021da <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    8000499a:	2184a783          	lw	a5,536(s1)
    8000499e:	21c4a703          	lw	a4,540(s1)
    800049a2:	2007879b          	addiw	a5,a5,512
    800049a6:	fcf709e3          	beq	a4,a5,80004978 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049aa:	4685                	li	a3,1
    800049ac:	865a                	mv	a2,s6
    800049ae:	faf40593          	addi	a1,s0,-81
    800049b2:	05093503          	ld	a0,80(s2)
    800049b6:	ffffd097          	auipc	ra,0xffffd
    800049ba:	d92080e7          	jalr	-622(ra) # 80001748 <copyin>
    800049be:	03850563          	beq	a0,s8,800049e8 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049c2:	21c4a783          	lw	a5,540(s1)
    800049c6:	0017871b          	addiw	a4,a5,1
    800049ca:	20e4ae23          	sw	a4,540(s1)
    800049ce:	1ff7f793          	andi	a5,a5,511
    800049d2:	97a6                	add	a5,a5,s1
    800049d4:	faf44703          	lbu	a4,-81(s0)
    800049d8:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    800049dc:	2b85                	addiw	s7,s7,1
    800049de:	0b05                	addi	s6,s6,1
    800049e0:	f97a94e3          	bne	s5,s7,80004968 <pipewrite+0x42>
    800049e4:	a011                	j	800049e8 <pipewrite+0xc2>
    800049e6:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    800049e8:	21848513          	addi	a0,s1,536
    800049ec:	ffffe097          	auipc	ra,0xffffe
    800049f0:	96e080e7          	jalr	-1682(ra) # 8000235a <wakeup>
  release(&pi->lock);
    800049f4:	8526                	mv	a0,s1
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	2bc080e7          	jalr	700(ra) # 80000cb2 <release>
  return i;
    800049fe:	a039                	j	80004a0c <pipewrite+0xe6>
        release(&pi->lock);
    80004a00:	8526                	mv	a0,s1
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	2b0080e7          	jalr	688(ra) # 80000cb2 <release>
        return -1;
    80004a0a:	5bfd                	li	s7,-1
}
    80004a0c:	855e                	mv	a0,s7
    80004a0e:	60e6                	ld	ra,88(sp)
    80004a10:	6446                	ld	s0,80(sp)
    80004a12:	64a6                	ld	s1,72(sp)
    80004a14:	6906                	ld	s2,64(sp)
    80004a16:	79e2                	ld	s3,56(sp)
    80004a18:	7a42                	ld	s4,48(sp)
    80004a1a:	7aa2                	ld	s5,40(sp)
    80004a1c:	7b02                	ld	s6,32(sp)
    80004a1e:	6be2                	ld	s7,24(sp)
    80004a20:	6c42                	ld	s8,16(sp)
    80004a22:	6125                	addi	sp,sp,96
    80004a24:	8082                	ret

0000000080004a26 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a26:	715d                	addi	sp,sp,-80
    80004a28:	e486                	sd	ra,72(sp)
    80004a2a:	e0a2                	sd	s0,64(sp)
    80004a2c:	fc26                	sd	s1,56(sp)
    80004a2e:	f84a                	sd	s2,48(sp)
    80004a30:	f44e                	sd	s3,40(sp)
    80004a32:	f052                	sd	s4,32(sp)
    80004a34:	ec56                	sd	s5,24(sp)
    80004a36:	e85a                	sd	s6,16(sp)
    80004a38:	0880                	addi	s0,sp,80
    80004a3a:	84aa                	mv	s1,a0
    80004a3c:	892e                	mv	s2,a1
    80004a3e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a40:	ffffd097          	auipc	ra,0xffffd
    80004a44:	f8a080e7          	jalr	-118(ra) # 800019ca <myproc>
    80004a48:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	ffffc097          	auipc	ra,0xffffc
    80004a50:	1b2080e7          	jalr	434(ra) # 80000bfe <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a54:	2184a703          	lw	a4,536(s1)
    80004a58:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a5c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a60:	02f71463          	bne	a4,a5,80004a88 <piperead+0x62>
    80004a64:	2244a783          	lw	a5,548(s1)
    80004a68:	c385                	beqz	a5,80004a88 <piperead+0x62>
    if(pr->killed){
    80004a6a:	030a2783          	lw	a5,48(s4)
    80004a6e:	ebc1                	bnez	a5,80004afe <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a70:	85a6                	mv	a1,s1
    80004a72:	854e                	mv	a0,s3
    80004a74:	ffffd097          	auipc	ra,0xffffd
    80004a78:	766080e7          	jalr	1894(ra) # 800021da <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a7c:	2184a703          	lw	a4,536(s1)
    80004a80:	21c4a783          	lw	a5,540(s1)
    80004a84:	fef700e3          	beq	a4,a5,80004a64 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a88:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a8a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a8c:	05505363          	blez	s5,80004ad2 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004a90:	2184a783          	lw	a5,536(s1)
    80004a94:	21c4a703          	lw	a4,540(s1)
    80004a98:	02f70d63          	beq	a4,a5,80004ad2 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004a9c:	0017871b          	addiw	a4,a5,1
    80004aa0:	20e4ac23          	sw	a4,536(s1)
    80004aa4:	1ff7f793          	andi	a5,a5,511
    80004aa8:	97a6                	add	a5,a5,s1
    80004aaa:	0187c783          	lbu	a5,24(a5)
    80004aae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ab2:	4685                	li	a3,1
    80004ab4:	fbf40613          	addi	a2,s0,-65
    80004ab8:	85ca                	mv	a1,s2
    80004aba:	050a3503          	ld	a0,80(s4)
    80004abe:	ffffd097          	auipc	ra,0xffffd
    80004ac2:	bfe080e7          	jalr	-1026(ra) # 800016bc <copyout>
    80004ac6:	01650663          	beq	a0,s6,80004ad2 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aca:	2985                	addiw	s3,s3,1
    80004acc:	0905                	addi	s2,s2,1
    80004ace:	fd3a91e3          	bne	s5,s3,80004a90 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ad2:	21c48513          	addi	a0,s1,540
    80004ad6:	ffffe097          	auipc	ra,0xffffe
    80004ada:	884080e7          	jalr	-1916(ra) # 8000235a <wakeup>
  release(&pi->lock);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	1d2080e7          	jalr	466(ra) # 80000cb2 <release>
  return i;
}
    80004ae8:	854e                	mv	a0,s3
    80004aea:	60a6                	ld	ra,72(sp)
    80004aec:	6406                	ld	s0,64(sp)
    80004aee:	74e2                	ld	s1,56(sp)
    80004af0:	7942                	ld	s2,48(sp)
    80004af2:	79a2                	ld	s3,40(sp)
    80004af4:	7a02                	ld	s4,32(sp)
    80004af6:	6ae2                	ld	s5,24(sp)
    80004af8:	6b42                	ld	s6,16(sp)
    80004afa:	6161                	addi	sp,sp,80
    80004afc:	8082                	ret
      release(&pi->lock);
    80004afe:	8526                	mv	a0,s1
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	1b2080e7          	jalr	434(ra) # 80000cb2 <release>
      return -1;
    80004b08:	59fd                	li	s3,-1
    80004b0a:	bff9                	j	80004ae8 <piperead+0xc2>

0000000080004b0c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b0c:	de010113          	addi	sp,sp,-544
    80004b10:	20113c23          	sd	ra,536(sp)
    80004b14:	20813823          	sd	s0,528(sp)
    80004b18:	20913423          	sd	s1,520(sp)
    80004b1c:	21213023          	sd	s2,512(sp)
    80004b20:	ffce                	sd	s3,504(sp)
    80004b22:	fbd2                	sd	s4,496(sp)
    80004b24:	f7d6                	sd	s5,488(sp)
    80004b26:	f3da                	sd	s6,480(sp)
    80004b28:	efde                	sd	s7,472(sp)
    80004b2a:	ebe2                	sd	s8,464(sp)
    80004b2c:	e7e6                	sd	s9,456(sp)
    80004b2e:	e3ea                	sd	s10,448(sp)
    80004b30:	ff6e                	sd	s11,440(sp)
    80004b32:	1400                	addi	s0,sp,544
    80004b34:	892a                	mv	s2,a0
    80004b36:	dea43423          	sd	a0,-536(s0)
    80004b3a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b3e:	ffffd097          	auipc	ra,0xffffd
    80004b42:	e8c080e7          	jalr	-372(ra) # 800019ca <myproc>
    80004b46:	84aa                	mv	s1,a0

  begin_op();
    80004b48:	fffff097          	auipc	ra,0xfffff
    80004b4c:	46c080e7          	jalr	1132(ra) # 80003fb4 <begin_op>

  if((ip = namei(path)) == 0){
    80004b50:	854a                	mv	a0,s2
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	252080e7          	jalr	594(ra) # 80003da4 <namei>
    80004b5a:	c93d                	beqz	a0,80004bd0 <exec+0xc4>
    80004b5c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b5e:	fffff097          	auipc	ra,0xfffff
    80004b62:	a96080e7          	jalr	-1386(ra) # 800035f4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b66:	04000713          	li	a4,64
    80004b6a:	4681                	li	a3,0
    80004b6c:	e4840613          	addi	a2,s0,-440
    80004b70:	4581                	li	a1,0
    80004b72:	8556                	mv	a0,s5
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	d34080e7          	jalr	-716(ra) # 800038a8 <readi>
    80004b7c:	04000793          	li	a5,64
    80004b80:	00f51a63          	bne	a0,a5,80004b94 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004b84:	e4842703          	lw	a4,-440(s0)
    80004b88:	464c47b7          	lui	a5,0x464c4
    80004b8c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b90:	04f70663          	beq	a4,a5,80004bdc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b94:	8556                	mv	a0,s5
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	cc0080e7          	jalr	-832(ra) # 80003856 <iunlockput>
    end_op();
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	496080e7          	jalr	1174(ra) # 80004034 <end_op>
  }
  return -1;
    80004ba6:	557d                	li	a0,-1
}
    80004ba8:	21813083          	ld	ra,536(sp)
    80004bac:	21013403          	ld	s0,528(sp)
    80004bb0:	20813483          	ld	s1,520(sp)
    80004bb4:	20013903          	ld	s2,512(sp)
    80004bb8:	79fe                	ld	s3,504(sp)
    80004bba:	7a5e                	ld	s4,496(sp)
    80004bbc:	7abe                	ld	s5,488(sp)
    80004bbe:	7b1e                	ld	s6,480(sp)
    80004bc0:	6bfe                	ld	s7,472(sp)
    80004bc2:	6c5e                	ld	s8,464(sp)
    80004bc4:	6cbe                	ld	s9,456(sp)
    80004bc6:	6d1e                	ld	s10,448(sp)
    80004bc8:	7dfa                	ld	s11,440(sp)
    80004bca:	22010113          	addi	sp,sp,544
    80004bce:	8082                	ret
    end_op();
    80004bd0:	fffff097          	auipc	ra,0xfffff
    80004bd4:	464080e7          	jalr	1124(ra) # 80004034 <end_op>
    return -1;
    80004bd8:	557d                	li	a0,-1
    80004bda:	b7f9                	j	80004ba8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004bdc:	8526                	mv	a0,s1
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	eb0080e7          	jalr	-336(ra) # 80001a8e <proc_pagetable>
    80004be6:	8b2a                	mv	s6,a0
    80004be8:	d555                	beqz	a0,80004b94 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bea:	e6842783          	lw	a5,-408(s0)
    80004bee:	e8045703          	lhu	a4,-384(s0)
    80004bf2:	c735                	beqz	a4,80004c5e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004bf4:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bf6:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004bfa:	6a05                	lui	s4,0x1
    80004bfc:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c00:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004c04:	6d85                	lui	s11,0x1
    80004c06:	7d7d                	lui	s10,0xfffff
    80004c08:	ac1d                	j	80004e3e <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c0a:	00004517          	auipc	a0,0x4
    80004c0e:	aae50513          	addi	a0,a0,-1362 # 800086b8 <syscalls+0x290>
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	930080e7          	jalr	-1744(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c1a:	874a                	mv	a4,s2
    80004c1c:	009c86bb          	addw	a3,s9,s1
    80004c20:	4581                	li	a1,0
    80004c22:	8556                	mv	a0,s5
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	c84080e7          	jalr	-892(ra) # 800038a8 <readi>
    80004c2c:	2501                	sext.w	a0,a0
    80004c2e:	1aa91863          	bne	s2,a0,80004dde <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004c32:	009d84bb          	addw	s1,s11,s1
    80004c36:	013d09bb          	addw	s3,s10,s3
    80004c3a:	1f74f263          	bgeu	s1,s7,80004e1e <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004c3e:	02049593          	slli	a1,s1,0x20
    80004c42:	9181                	srli	a1,a1,0x20
    80004c44:	95e2                	add	a1,a1,s8
    80004c46:	855a                	mv	a0,s6
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	440080e7          	jalr	1088(ra) # 80001088 <walkaddr>
    80004c50:	862a                	mv	a2,a0
    if(pa == 0)
    80004c52:	dd45                	beqz	a0,80004c0a <exec+0xfe>
      n = PGSIZE;
    80004c54:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004c56:	fd49f2e3          	bgeu	s3,s4,80004c1a <exec+0x10e>
      n = sz - i;
    80004c5a:	894e                	mv	s2,s3
    80004c5c:	bf7d                	j	80004c1a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c5e:	4481                	li	s1,0
  iunlockput(ip);
    80004c60:	8556                	mv	a0,s5
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	bf4080e7          	jalr	-1036(ra) # 80003856 <iunlockput>
  end_op();
    80004c6a:	fffff097          	auipc	ra,0xfffff
    80004c6e:	3ca080e7          	jalr	970(ra) # 80004034 <end_op>
  p = myproc();
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	d58080e7          	jalr	-680(ra) # 800019ca <myproc>
    80004c7a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004c7c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004c80:	6785                	lui	a5,0x1
    80004c82:	17fd                	addi	a5,a5,-1
    80004c84:	94be                	add	s1,s1,a5
    80004c86:	77fd                	lui	a5,0xfffff
    80004c88:	8fe5                	and	a5,a5,s1
    80004c8a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004c8e:	6609                	lui	a2,0x2
    80004c90:	963e                	add	a2,a2,a5
    80004c92:	85be                	mv	a1,a5
    80004c94:	855a                	mv	a0,s6
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	7d6080e7          	jalr	2006(ra) # 8000146c <uvmalloc>
    80004c9e:	8c2a                	mv	s8,a0
  ip = 0;
    80004ca0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ca2:	12050e63          	beqz	a0,80004dde <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ca6:	75f9                	lui	a1,0xffffe
    80004ca8:	95aa                	add	a1,a1,a0
    80004caa:	855a                	mv	a0,s6
    80004cac:	ffffd097          	auipc	ra,0xffffd
    80004cb0:	9de080e7          	jalr	-1570(ra) # 8000168a <uvmclear>
  stackbase = sp - PGSIZE;
    80004cb4:	7afd                	lui	s5,0xfffff
    80004cb6:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cb8:	df043783          	ld	a5,-528(s0)
    80004cbc:	6388                	ld	a0,0(a5)
    80004cbe:	c925                	beqz	a0,80004d2e <exec+0x222>
    80004cc0:	e8840993          	addi	s3,s0,-376
    80004cc4:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004cc8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cca:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	1b2080e7          	jalr	434(ra) # 80000e7e <strlen>
    80004cd4:	0015079b          	addiw	a5,a0,1
    80004cd8:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004cdc:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004ce0:	13596363          	bltu	s2,s5,80004e06 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ce4:	df043d83          	ld	s11,-528(s0)
    80004ce8:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004cec:	8552                	mv	a0,s4
    80004cee:	ffffc097          	auipc	ra,0xffffc
    80004cf2:	190080e7          	jalr	400(ra) # 80000e7e <strlen>
    80004cf6:	0015069b          	addiw	a3,a0,1
    80004cfa:	8652                	mv	a2,s4
    80004cfc:	85ca                	mv	a1,s2
    80004cfe:	855a                	mv	a0,s6
    80004d00:	ffffd097          	auipc	ra,0xffffd
    80004d04:	9bc080e7          	jalr	-1604(ra) # 800016bc <copyout>
    80004d08:	10054363          	bltz	a0,80004e0e <exec+0x302>
    ustack[argc] = sp;
    80004d0c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d10:	0485                	addi	s1,s1,1
    80004d12:	008d8793          	addi	a5,s11,8
    80004d16:	def43823          	sd	a5,-528(s0)
    80004d1a:	008db503          	ld	a0,8(s11)
    80004d1e:	c911                	beqz	a0,80004d32 <exec+0x226>
    if(argc >= MAXARG)
    80004d20:	09a1                	addi	s3,s3,8
    80004d22:	fb3c95e3          	bne	s9,s3,80004ccc <exec+0x1c0>
  sz = sz1;
    80004d26:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d2a:	4a81                	li	s5,0
    80004d2c:	a84d                	j	80004dde <exec+0x2d2>
  sp = sz;
    80004d2e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d30:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d32:	00349793          	slli	a5,s1,0x3
    80004d36:	f9040713          	addi	a4,s0,-112
    80004d3a:	97ba                	add	a5,a5,a4
    80004d3c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004d40:	00148693          	addi	a3,s1,1
    80004d44:	068e                	slli	a3,a3,0x3
    80004d46:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d4a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d4e:	01597663          	bgeu	s2,s5,80004d5a <exec+0x24e>
  sz = sz1;
    80004d52:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d56:	4a81                	li	s5,0
    80004d58:	a059                	j	80004dde <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d5a:	e8840613          	addi	a2,s0,-376
    80004d5e:	85ca                	mv	a1,s2
    80004d60:	855a                	mv	a0,s6
    80004d62:	ffffd097          	auipc	ra,0xffffd
    80004d66:	95a080e7          	jalr	-1702(ra) # 800016bc <copyout>
    80004d6a:	0a054663          	bltz	a0,80004e16 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004d6e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004d72:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004d76:	de843783          	ld	a5,-536(s0)
    80004d7a:	0007c703          	lbu	a4,0(a5)
    80004d7e:	cf11                	beqz	a4,80004d9a <exec+0x28e>
    80004d80:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004d82:	02f00693          	li	a3,47
    80004d86:	a039                	j	80004d94 <exec+0x288>
      last = s+1;
    80004d88:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004d8c:	0785                	addi	a5,a5,1
    80004d8e:	fff7c703          	lbu	a4,-1(a5)
    80004d92:	c701                	beqz	a4,80004d9a <exec+0x28e>
    if(*s == '/')
    80004d94:	fed71ce3          	bne	a4,a3,80004d8c <exec+0x280>
    80004d98:	bfc5                	j	80004d88 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004d9a:	4641                	li	a2,16
    80004d9c:	de843583          	ld	a1,-536(s0)
    80004da0:	158b8513          	addi	a0,s7,344
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	0a8080e7          	jalr	168(ra) # 80000e4c <safestrcpy>
  oldpagetable = p->pagetable;
    80004dac:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004db0:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004db4:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004db8:	058bb783          	ld	a5,88(s7)
    80004dbc:	e6043703          	ld	a4,-416(s0)
    80004dc0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004dc2:	058bb783          	ld	a5,88(s7)
    80004dc6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004dca:	85ea                	mv	a1,s10
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	d5e080e7          	jalr	-674(ra) # 80001b2a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004dd4:	0004851b          	sext.w	a0,s1
    80004dd8:	bbc1                	j	80004ba8 <exec+0x9c>
    80004dda:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004dde:	df843583          	ld	a1,-520(s0)
    80004de2:	855a                	mv	a0,s6
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	d46080e7          	jalr	-698(ra) # 80001b2a <proc_freepagetable>
  if(ip){
    80004dec:	da0a94e3          	bnez	s5,80004b94 <exec+0x88>
  return -1;
    80004df0:	557d                	li	a0,-1
    80004df2:	bb5d                	j	80004ba8 <exec+0x9c>
    80004df4:	de943c23          	sd	s1,-520(s0)
    80004df8:	b7dd                	j	80004dde <exec+0x2d2>
    80004dfa:	de943c23          	sd	s1,-520(s0)
    80004dfe:	b7c5                	j	80004dde <exec+0x2d2>
    80004e00:	de943c23          	sd	s1,-520(s0)
    80004e04:	bfe9                	j	80004dde <exec+0x2d2>
  sz = sz1;
    80004e06:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e0a:	4a81                	li	s5,0
    80004e0c:	bfc9                	j	80004dde <exec+0x2d2>
  sz = sz1;
    80004e0e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e12:	4a81                	li	s5,0
    80004e14:	b7e9                	j	80004dde <exec+0x2d2>
  sz = sz1;
    80004e16:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e1a:	4a81                	li	s5,0
    80004e1c:	b7c9                	j	80004dde <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e1e:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e22:	e0843783          	ld	a5,-504(s0)
    80004e26:	0017869b          	addiw	a3,a5,1
    80004e2a:	e0d43423          	sd	a3,-504(s0)
    80004e2e:	e0043783          	ld	a5,-512(s0)
    80004e32:	0387879b          	addiw	a5,a5,56
    80004e36:	e8045703          	lhu	a4,-384(s0)
    80004e3a:	e2e6d3e3          	bge	a3,a4,80004c60 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e3e:	2781                	sext.w	a5,a5
    80004e40:	e0f43023          	sd	a5,-512(s0)
    80004e44:	03800713          	li	a4,56
    80004e48:	86be                	mv	a3,a5
    80004e4a:	e1040613          	addi	a2,s0,-496
    80004e4e:	4581                	li	a1,0
    80004e50:	8556                	mv	a0,s5
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	a56080e7          	jalr	-1450(ra) # 800038a8 <readi>
    80004e5a:	03800793          	li	a5,56
    80004e5e:	f6f51ee3          	bne	a0,a5,80004dda <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004e62:	e1042783          	lw	a5,-496(s0)
    80004e66:	4705                	li	a4,1
    80004e68:	fae79de3          	bne	a5,a4,80004e22 <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004e6c:	e3843603          	ld	a2,-456(s0)
    80004e70:	e3043783          	ld	a5,-464(s0)
    80004e74:	f8f660e3          	bltu	a2,a5,80004df4 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e78:	e2043783          	ld	a5,-480(s0)
    80004e7c:	963e                	add	a2,a2,a5
    80004e7e:	f6f66ee3          	bltu	a2,a5,80004dfa <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e82:	85a6                	mv	a1,s1
    80004e84:	855a                	mv	a0,s6
    80004e86:	ffffc097          	auipc	ra,0xffffc
    80004e8a:	5e6080e7          	jalr	1510(ra) # 8000146c <uvmalloc>
    80004e8e:	dea43c23          	sd	a0,-520(s0)
    80004e92:	d53d                	beqz	a0,80004e00 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004e94:	e2043c03          	ld	s8,-480(s0)
    80004e98:	de043783          	ld	a5,-544(s0)
    80004e9c:	00fc77b3          	and	a5,s8,a5
    80004ea0:	ff9d                	bnez	a5,80004dde <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ea2:	e1842c83          	lw	s9,-488(s0)
    80004ea6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004eaa:	f60b8ae3          	beqz	s7,80004e1e <exec+0x312>
    80004eae:	89de                	mv	s3,s7
    80004eb0:	4481                	li	s1,0
    80004eb2:	b371                	j	80004c3e <exec+0x132>

0000000080004eb4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004eb4:	7179                	addi	sp,sp,-48
    80004eb6:	f406                	sd	ra,40(sp)
    80004eb8:	f022                	sd	s0,32(sp)
    80004eba:	ec26                	sd	s1,24(sp)
    80004ebc:	e84a                	sd	s2,16(sp)
    80004ebe:	1800                	addi	s0,sp,48
    80004ec0:	892e                	mv	s2,a1
    80004ec2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004ec4:	fdc40593          	addi	a1,s0,-36
    80004ec8:	ffffe097          	auipc	ra,0xffffe
    80004ecc:	bba080e7          	jalr	-1094(ra) # 80002a82 <argint>
    80004ed0:	04054063          	bltz	a0,80004f10 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ed4:	fdc42703          	lw	a4,-36(s0)
    80004ed8:	47bd                	li	a5,15
    80004eda:	02e7ed63          	bltu	a5,a4,80004f14 <argfd+0x60>
    80004ede:	ffffd097          	auipc	ra,0xffffd
    80004ee2:	aec080e7          	jalr	-1300(ra) # 800019ca <myproc>
    80004ee6:	fdc42703          	lw	a4,-36(s0)
    80004eea:	01a70793          	addi	a5,a4,26
    80004eee:	078e                	slli	a5,a5,0x3
    80004ef0:	953e                	add	a0,a0,a5
    80004ef2:	611c                	ld	a5,0(a0)
    80004ef4:	c395                	beqz	a5,80004f18 <argfd+0x64>
    return -1;
  if(pfd)
    80004ef6:	00090463          	beqz	s2,80004efe <argfd+0x4a>
    *pfd = fd;
    80004efa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004efe:	4501                	li	a0,0
  if(pf)
    80004f00:	c091                	beqz	s1,80004f04 <argfd+0x50>
    *pf = f;
    80004f02:	e09c                	sd	a5,0(s1)
}
    80004f04:	70a2                	ld	ra,40(sp)
    80004f06:	7402                	ld	s0,32(sp)
    80004f08:	64e2                	ld	s1,24(sp)
    80004f0a:	6942                	ld	s2,16(sp)
    80004f0c:	6145                	addi	sp,sp,48
    80004f0e:	8082                	ret
    return -1;
    80004f10:	557d                	li	a0,-1
    80004f12:	bfcd                	j	80004f04 <argfd+0x50>
    return -1;
    80004f14:	557d                	li	a0,-1
    80004f16:	b7fd                	j	80004f04 <argfd+0x50>
    80004f18:	557d                	li	a0,-1
    80004f1a:	b7ed                	j	80004f04 <argfd+0x50>

0000000080004f1c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f1c:	1101                	addi	sp,sp,-32
    80004f1e:	ec06                	sd	ra,24(sp)
    80004f20:	e822                	sd	s0,16(sp)
    80004f22:	e426                	sd	s1,8(sp)
    80004f24:	1000                	addi	s0,sp,32
    80004f26:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f28:	ffffd097          	auipc	ra,0xffffd
    80004f2c:	aa2080e7          	jalr	-1374(ra) # 800019ca <myproc>
    80004f30:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f32:	0d050793          	addi	a5,a0,208
    80004f36:	4501                	li	a0,0
    80004f38:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f3a:	6398                	ld	a4,0(a5)
    80004f3c:	cb19                	beqz	a4,80004f52 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f3e:	2505                	addiw	a0,a0,1
    80004f40:	07a1                	addi	a5,a5,8
    80004f42:	fed51ce3          	bne	a0,a3,80004f3a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f46:	557d                	li	a0,-1
}
    80004f48:	60e2                	ld	ra,24(sp)
    80004f4a:	6442                	ld	s0,16(sp)
    80004f4c:	64a2                	ld	s1,8(sp)
    80004f4e:	6105                	addi	sp,sp,32
    80004f50:	8082                	ret
      p->ofile[fd] = f;
    80004f52:	01a50793          	addi	a5,a0,26
    80004f56:	078e                	slli	a5,a5,0x3
    80004f58:	963e                	add	a2,a2,a5
    80004f5a:	e204                	sd	s1,0(a2)
      return fd;
    80004f5c:	b7f5                	j	80004f48 <fdalloc+0x2c>

0000000080004f5e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f5e:	715d                	addi	sp,sp,-80
    80004f60:	e486                	sd	ra,72(sp)
    80004f62:	e0a2                	sd	s0,64(sp)
    80004f64:	fc26                	sd	s1,56(sp)
    80004f66:	f84a                	sd	s2,48(sp)
    80004f68:	f44e                	sd	s3,40(sp)
    80004f6a:	f052                	sd	s4,32(sp)
    80004f6c:	ec56                	sd	s5,24(sp)
    80004f6e:	0880                	addi	s0,sp,80
    80004f70:	89ae                	mv	s3,a1
    80004f72:	8ab2                	mv	s5,a2
    80004f74:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f76:	fb040593          	addi	a1,s0,-80
    80004f7a:	fffff097          	auipc	ra,0xfffff
    80004f7e:	e48080e7          	jalr	-440(ra) # 80003dc2 <nameiparent>
    80004f82:	892a                	mv	s2,a0
    80004f84:	12050e63          	beqz	a0,800050c0 <create+0x162>
    return 0;

  ilock(dp);
    80004f88:	ffffe097          	auipc	ra,0xffffe
    80004f8c:	66c080e7          	jalr	1644(ra) # 800035f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f90:	4601                	li	a2,0
    80004f92:	fb040593          	addi	a1,s0,-80
    80004f96:	854a                	mv	a0,s2
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	b3a080e7          	jalr	-1222(ra) # 80003ad2 <dirlookup>
    80004fa0:	84aa                	mv	s1,a0
    80004fa2:	c921                	beqz	a0,80004ff2 <create+0x94>
    iunlockput(dp);
    80004fa4:	854a                	mv	a0,s2
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	8b0080e7          	jalr	-1872(ra) # 80003856 <iunlockput>
    ilock(ip);
    80004fae:	8526                	mv	a0,s1
    80004fb0:	ffffe097          	auipc	ra,0xffffe
    80004fb4:	644080e7          	jalr	1604(ra) # 800035f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fb8:	2981                	sext.w	s3,s3
    80004fba:	4789                	li	a5,2
    80004fbc:	02f99463          	bne	s3,a5,80004fe4 <create+0x86>
    80004fc0:	0444d783          	lhu	a5,68(s1)
    80004fc4:	37f9                	addiw	a5,a5,-2
    80004fc6:	17c2                	slli	a5,a5,0x30
    80004fc8:	93c1                	srli	a5,a5,0x30
    80004fca:	4705                	li	a4,1
    80004fcc:	00f76c63          	bltu	a4,a5,80004fe4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	60a6                	ld	ra,72(sp)
    80004fd4:	6406                	ld	s0,64(sp)
    80004fd6:	74e2                	ld	s1,56(sp)
    80004fd8:	7942                	ld	s2,48(sp)
    80004fda:	79a2                	ld	s3,40(sp)
    80004fdc:	7a02                	ld	s4,32(sp)
    80004fde:	6ae2                	ld	s5,24(sp)
    80004fe0:	6161                	addi	sp,sp,80
    80004fe2:	8082                	ret
    iunlockput(ip);
    80004fe4:	8526                	mv	a0,s1
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	870080e7          	jalr	-1936(ra) # 80003856 <iunlockput>
    return 0;
    80004fee:	4481                	li	s1,0
    80004ff0:	b7c5                	j	80004fd0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004ff2:	85ce                	mv	a1,s3
    80004ff4:	00092503          	lw	a0,0(s2)
    80004ff8:	ffffe097          	auipc	ra,0xffffe
    80004ffc:	464080e7          	jalr	1124(ra) # 8000345c <ialloc>
    80005000:	84aa                	mv	s1,a0
    80005002:	c521                	beqz	a0,8000504a <create+0xec>
  ilock(ip);
    80005004:	ffffe097          	auipc	ra,0xffffe
    80005008:	5f0080e7          	jalr	1520(ra) # 800035f4 <ilock>
  ip->major = major;
    8000500c:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005010:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005014:	4a05                	li	s4,1
    80005016:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000501a:	8526                	mv	a0,s1
    8000501c:	ffffe097          	auipc	ra,0xffffe
    80005020:	50e080e7          	jalr	1294(ra) # 8000352a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005024:	2981                	sext.w	s3,s3
    80005026:	03498a63          	beq	s3,s4,8000505a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000502a:	40d0                	lw	a2,4(s1)
    8000502c:	fb040593          	addi	a1,s0,-80
    80005030:	854a                	mv	a0,s2
    80005032:	fffff097          	auipc	ra,0xfffff
    80005036:	cb0080e7          	jalr	-848(ra) # 80003ce2 <dirlink>
    8000503a:	06054b63          	bltz	a0,800050b0 <create+0x152>
  iunlockput(dp);
    8000503e:	854a                	mv	a0,s2
    80005040:	fffff097          	auipc	ra,0xfffff
    80005044:	816080e7          	jalr	-2026(ra) # 80003856 <iunlockput>
  return ip;
    80005048:	b761                	j	80004fd0 <create+0x72>
    panic("create: ialloc");
    8000504a:	00003517          	auipc	a0,0x3
    8000504e:	68e50513          	addi	a0,a0,1678 # 800086d8 <syscalls+0x2b0>
    80005052:	ffffb097          	auipc	ra,0xffffb
    80005056:	4f0080e7          	jalr	1264(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    8000505a:	04a95783          	lhu	a5,74(s2)
    8000505e:	2785                	addiw	a5,a5,1
    80005060:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005064:	854a                	mv	a0,s2
    80005066:	ffffe097          	auipc	ra,0xffffe
    8000506a:	4c4080e7          	jalr	1220(ra) # 8000352a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000506e:	40d0                	lw	a2,4(s1)
    80005070:	00003597          	auipc	a1,0x3
    80005074:	67858593          	addi	a1,a1,1656 # 800086e8 <syscalls+0x2c0>
    80005078:	8526                	mv	a0,s1
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	c68080e7          	jalr	-920(ra) # 80003ce2 <dirlink>
    80005082:	00054f63          	bltz	a0,800050a0 <create+0x142>
    80005086:	00492603          	lw	a2,4(s2)
    8000508a:	00003597          	auipc	a1,0x3
    8000508e:	66658593          	addi	a1,a1,1638 # 800086f0 <syscalls+0x2c8>
    80005092:	8526                	mv	a0,s1
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	c4e080e7          	jalr	-946(ra) # 80003ce2 <dirlink>
    8000509c:	f80557e3          	bgez	a0,8000502a <create+0xcc>
      panic("create dots");
    800050a0:	00003517          	auipc	a0,0x3
    800050a4:	65850513          	addi	a0,a0,1624 # 800086f8 <syscalls+0x2d0>
    800050a8:	ffffb097          	auipc	ra,0xffffb
    800050ac:	49a080e7          	jalr	1178(ra) # 80000542 <panic>
    panic("create: dirlink");
    800050b0:	00003517          	auipc	a0,0x3
    800050b4:	65850513          	addi	a0,a0,1624 # 80008708 <syscalls+0x2e0>
    800050b8:	ffffb097          	auipc	ra,0xffffb
    800050bc:	48a080e7          	jalr	1162(ra) # 80000542 <panic>
    return 0;
    800050c0:	84aa                	mv	s1,a0
    800050c2:	b739                	j	80004fd0 <create+0x72>

00000000800050c4 <sys_dup>:
{
    800050c4:	7179                	addi	sp,sp,-48
    800050c6:	f406                	sd	ra,40(sp)
    800050c8:	f022                	sd	s0,32(sp)
    800050ca:	ec26                	sd	s1,24(sp)
    800050cc:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050ce:	fd840613          	addi	a2,s0,-40
    800050d2:	4581                	li	a1,0
    800050d4:	4501                	li	a0,0
    800050d6:	00000097          	auipc	ra,0x0
    800050da:	dde080e7          	jalr	-546(ra) # 80004eb4 <argfd>
    return -1;
    800050de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050e0:	02054363          	bltz	a0,80005106 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800050e4:	fd843503          	ld	a0,-40(s0)
    800050e8:	00000097          	auipc	ra,0x0
    800050ec:	e34080e7          	jalr	-460(ra) # 80004f1c <fdalloc>
    800050f0:	84aa                	mv	s1,a0
    return -1;
    800050f2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050f4:	00054963          	bltz	a0,80005106 <sys_dup+0x42>
  filedup(f);
    800050f8:	fd843503          	ld	a0,-40(s0)
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	338080e7          	jalr	824(ra) # 80004434 <filedup>
  return fd;
    80005104:	87a6                	mv	a5,s1
}
    80005106:	853e                	mv	a0,a5
    80005108:	70a2                	ld	ra,40(sp)
    8000510a:	7402                	ld	s0,32(sp)
    8000510c:	64e2                	ld	s1,24(sp)
    8000510e:	6145                	addi	sp,sp,48
    80005110:	8082                	ret

0000000080005112 <sys_read>:
{
    80005112:	7179                	addi	sp,sp,-48
    80005114:	f406                	sd	ra,40(sp)
    80005116:	f022                	sd	s0,32(sp)
    80005118:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000511a:	fe840613          	addi	a2,s0,-24
    8000511e:	4581                	li	a1,0
    80005120:	4501                	li	a0,0
    80005122:	00000097          	auipc	ra,0x0
    80005126:	d92080e7          	jalr	-622(ra) # 80004eb4 <argfd>
    return -1;
    8000512a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000512c:	04054163          	bltz	a0,8000516e <sys_read+0x5c>
    80005130:	fe440593          	addi	a1,s0,-28
    80005134:	4509                	li	a0,2
    80005136:	ffffe097          	auipc	ra,0xffffe
    8000513a:	94c080e7          	jalr	-1716(ra) # 80002a82 <argint>
    return -1;
    8000513e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005140:	02054763          	bltz	a0,8000516e <sys_read+0x5c>
    80005144:	fd840593          	addi	a1,s0,-40
    80005148:	4505                	li	a0,1
    8000514a:	ffffe097          	auipc	ra,0xffffe
    8000514e:	95a080e7          	jalr	-1702(ra) # 80002aa4 <argaddr>
    return -1;
    80005152:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005154:	00054d63          	bltz	a0,8000516e <sys_read+0x5c>
  return fileread(f, p, n);
    80005158:	fe442603          	lw	a2,-28(s0)
    8000515c:	fd843583          	ld	a1,-40(s0)
    80005160:	fe843503          	ld	a0,-24(s0)
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	45c080e7          	jalr	1116(ra) # 800045c0 <fileread>
    8000516c:	87aa                	mv	a5,a0
}
    8000516e:	853e                	mv	a0,a5
    80005170:	70a2                	ld	ra,40(sp)
    80005172:	7402                	ld	s0,32(sp)
    80005174:	6145                	addi	sp,sp,48
    80005176:	8082                	ret

0000000080005178 <sys_write>:
{
    80005178:	7179                	addi	sp,sp,-48
    8000517a:	f406                	sd	ra,40(sp)
    8000517c:	f022                	sd	s0,32(sp)
    8000517e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005180:	fe840613          	addi	a2,s0,-24
    80005184:	4581                	li	a1,0
    80005186:	4501                	li	a0,0
    80005188:	00000097          	auipc	ra,0x0
    8000518c:	d2c080e7          	jalr	-724(ra) # 80004eb4 <argfd>
    return -1;
    80005190:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005192:	04054163          	bltz	a0,800051d4 <sys_write+0x5c>
    80005196:	fe440593          	addi	a1,s0,-28
    8000519a:	4509                	li	a0,2
    8000519c:	ffffe097          	auipc	ra,0xffffe
    800051a0:	8e6080e7          	jalr	-1818(ra) # 80002a82 <argint>
    return -1;
    800051a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051a6:	02054763          	bltz	a0,800051d4 <sys_write+0x5c>
    800051aa:	fd840593          	addi	a1,s0,-40
    800051ae:	4505                	li	a0,1
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	8f4080e7          	jalr	-1804(ra) # 80002aa4 <argaddr>
    return -1;
    800051b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051ba:	00054d63          	bltz	a0,800051d4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800051be:	fe442603          	lw	a2,-28(s0)
    800051c2:	fd843583          	ld	a1,-40(s0)
    800051c6:	fe843503          	ld	a0,-24(s0)
    800051ca:	fffff097          	auipc	ra,0xfffff
    800051ce:	4b8080e7          	jalr	1208(ra) # 80004682 <filewrite>
    800051d2:	87aa                	mv	a5,a0
}
    800051d4:	853e                	mv	a0,a5
    800051d6:	70a2                	ld	ra,40(sp)
    800051d8:	7402                	ld	s0,32(sp)
    800051da:	6145                	addi	sp,sp,48
    800051dc:	8082                	ret

00000000800051de <sys_close>:
{
    800051de:	1101                	addi	sp,sp,-32
    800051e0:	ec06                	sd	ra,24(sp)
    800051e2:	e822                	sd	s0,16(sp)
    800051e4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051e6:	fe040613          	addi	a2,s0,-32
    800051ea:	fec40593          	addi	a1,s0,-20
    800051ee:	4501                	li	a0,0
    800051f0:	00000097          	auipc	ra,0x0
    800051f4:	cc4080e7          	jalr	-828(ra) # 80004eb4 <argfd>
    return -1;
    800051f8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051fa:	02054463          	bltz	a0,80005222 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	7cc080e7          	jalr	1996(ra) # 800019ca <myproc>
    80005206:	fec42783          	lw	a5,-20(s0)
    8000520a:	07e9                	addi	a5,a5,26
    8000520c:	078e                	slli	a5,a5,0x3
    8000520e:	97aa                	add	a5,a5,a0
    80005210:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005214:	fe043503          	ld	a0,-32(s0)
    80005218:	fffff097          	auipc	ra,0xfffff
    8000521c:	26e080e7          	jalr	622(ra) # 80004486 <fileclose>
  return 0;
    80005220:	4781                	li	a5,0
}
    80005222:	853e                	mv	a0,a5
    80005224:	60e2                	ld	ra,24(sp)
    80005226:	6442                	ld	s0,16(sp)
    80005228:	6105                	addi	sp,sp,32
    8000522a:	8082                	ret

000000008000522c <sys_fstat>:
{
    8000522c:	1101                	addi	sp,sp,-32
    8000522e:	ec06                	sd	ra,24(sp)
    80005230:	e822                	sd	s0,16(sp)
    80005232:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005234:	fe840613          	addi	a2,s0,-24
    80005238:	4581                	li	a1,0
    8000523a:	4501                	li	a0,0
    8000523c:	00000097          	auipc	ra,0x0
    80005240:	c78080e7          	jalr	-904(ra) # 80004eb4 <argfd>
    return -1;
    80005244:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005246:	02054563          	bltz	a0,80005270 <sys_fstat+0x44>
    8000524a:	fe040593          	addi	a1,s0,-32
    8000524e:	4505                	li	a0,1
    80005250:	ffffe097          	auipc	ra,0xffffe
    80005254:	854080e7          	jalr	-1964(ra) # 80002aa4 <argaddr>
    return -1;
    80005258:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000525a:	00054b63          	bltz	a0,80005270 <sys_fstat+0x44>
  return filestat(f, st);
    8000525e:	fe043583          	ld	a1,-32(s0)
    80005262:	fe843503          	ld	a0,-24(s0)
    80005266:	fffff097          	auipc	ra,0xfffff
    8000526a:	2e8080e7          	jalr	744(ra) # 8000454e <filestat>
    8000526e:	87aa                	mv	a5,a0
}
    80005270:	853e                	mv	a0,a5
    80005272:	60e2                	ld	ra,24(sp)
    80005274:	6442                	ld	s0,16(sp)
    80005276:	6105                	addi	sp,sp,32
    80005278:	8082                	ret

000000008000527a <sys_link>:
{
    8000527a:	7169                	addi	sp,sp,-304
    8000527c:	f606                	sd	ra,296(sp)
    8000527e:	f222                	sd	s0,288(sp)
    80005280:	ee26                	sd	s1,280(sp)
    80005282:	ea4a                	sd	s2,272(sp)
    80005284:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005286:	08000613          	li	a2,128
    8000528a:	ed040593          	addi	a1,s0,-304
    8000528e:	4501                	li	a0,0
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	836080e7          	jalr	-1994(ra) # 80002ac6 <argstr>
    return -1;
    80005298:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000529a:	10054e63          	bltz	a0,800053b6 <sys_link+0x13c>
    8000529e:	08000613          	li	a2,128
    800052a2:	f5040593          	addi	a1,s0,-176
    800052a6:	4505                	li	a0,1
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	81e080e7          	jalr	-2018(ra) # 80002ac6 <argstr>
    return -1;
    800052b0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052b2:	10054263          	bltz	a0,800053b6 <sys_link+0x13c>
  begin_op();
    800052b6:	fffff097          	auipc	ra,0xfffff
    800052ba:	cfe080e7          	jalr	-770(ra) # 80003fb4 <begin_op>
  if((ip = namei(old)) == 0){
    800052be:	ed040513          	addi	a0,s0,-304
    800052c2:	fffff097          	auipc	ra,0xfffff
    800052c6:	ae2080e7          	jalr	-1310(ra) # 80003da4 <namei>
    800052ca:	84aa                	mv	s1,a0
    800052cc:	c551                	beqz	a0,80005358 <sys_link+0xde>
  ilock(ip);
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	326080e7          	jalr	806(ra) # 800035f4 <ilock>
  if(ip->type == T_DIR){
    800052d6:	04449703          	lh	a4,68(s1)
    800052da:	4785                	li	a5,1
    800052dc:	08f70463          	beq	a4,a5,80005364 <sys_link+0xea>
  ip->nlink++;
    800052e0:	04a4d783          	lhu	a5,74(s1)
    800052e4:	2785                	addiw	a5,a5,1
    800052e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052ea:	8526                	mv	a0,s1
    800052ec:	ffffe097          	auipc	ra,0xffffe
    800052f0:	23e080e7          	jalr	574(ra) # 8000352a <iupdate>
  iunlock(ip);
    800052f4:	8526                	mv	a0,s1
    800052f6:	ffffe097          	auipc	ra,0xffffe
    800052fa:	3c0080e7          	jalr	960(ra) # 800036b6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052fe:	fd040593          	addi	a1,s0,-48
    80005302:	f5040513          	addi	a0,s0,-176
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	abc080e7          	jalr	-1348(ra) # 80003dc2 <nameiparent>
    8000530e:	892a                	mv	s2,a0
    80005310:	c935                	beqz	a0,80005384 <sys_link+0x10a>
  ilock(dp);
    80005312:	ffffe097          	auipc	ra,0xffffe
    80005316:	2e2080e7          	jalr	738(ra) # 800035f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000531a:	00092703          	lw	a4,0(s2)
    8000531e:	409c                	lw	a5,0(s1)
    80005320:	04f71d63          	bne	a4,a5,8000537a <sys_link+0x100>
    80005324:	40d0                	lw	a2,4(s1)
    80005326:	fd040593          	addi	a1,s0,-48
    8000532a:	854a                	mv	a0,s2
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	9b6080e7          	jalr	-1610(ra) # 80003ce2 <dirlink>
    80005334:	04054363          	bltz	a0,8000537a <sys_link+0x100>
  iunlockput(dp);
    80005338:	854a                	mv	a0,s2
    8000533a:	ffffe097          	auipc	ra,0xffffe
    8000533e:	51c080e7          	jalr	1308(ra) # 80003856 <iunlockput>
  iput(ip);
    80005342:	8526                	mv	a0,s1
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	46a080e7          	jalr	1130(ra) # 800037ae <iput>
  end_op();
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	ce8080e7          	jalr	-792(ra) # 80004034 <end_op>
  return 0;
    80005354:	4781                	li	a5,0
    80005356:	a085                	j	800053b6 <sys_link+0x13c>
    end_op();
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	cdc080e7          	jalr	-804(ra) # 80004034 <end_op>
    return -1;
    80005360:	57fd                	li	a5,-1
    80005362:	a891                	j	800053b6 <sys_link+0x13c>
    iunlockput(ip);
    80005364:	8526                	mv	a0,s1
    80005366:	ffffe097          	auipc	ra,0xffffe
    8000536a:	4f0080e7          	jalr	1264(ra) # 80003856 <iunlockput>
    end_op();
    8000536e:	fffff097          	auipc	ra,0xfffff
    80005372:	cc6080e7          	jalr	-826(ra) # 80004034 <end_op>
    return -1;
    80005376:	57fd                	li	a5,-1
    80005378:	a83d                	j	800053b6 <sys_link+0x13c>
    iunlockput(dp);
    8000537a:	854a                	mv	a0,s2
    8000537c:	ffffe097          	auipc	ra,0xffffe
    80005380:	4da080e7          	jalr	1242(ra) # 80003856 <iunlockput>
  ilock(ip);
    80005384:	8526                	mv	a0,s1
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	26e080e7          	jalr	622(ra) # 800035f4 <ilock>
  ip->nlink--;
    8000538e:	04a4d783          	lhu	a5,74(s1)
    80005392:	37fd                	addiw	a5,a5,-1
    80005394:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005398:	8526                	mv	a0,s1
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	190080e7          	jalr	400(ra) # 8000352a <iupdate>
  iunlockput(ip);
    800053a2:	8526                	mv	a0,s1
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	4b2080e7          	jalr	1202(ra) # 80003856 <iunlockput>
  end_op();
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	c88080e7          	jalr	-888(ra) # 80004034 <end_op>
  return -1;
    800053b4:	57fd                	li	a5,-1
}
    800053b6:	853e                	mv	a0,a5
    800053b8:	70b2                	ld	ra,296(sp)
    800053ba:	7412                	ld	s0,288(sp)
    800053bc:	64f2                	ld	s1,280(sp)
    800053be:	6952                	ld	s2,272(sp)
    800053c0:	6155                	addi	sp,sp,304
    800053c2:	8082                	ret

00000000800053c4 <sys_unlink>:
{
    800053c4:	7151                	addi	sp,sp,-240
    800053c6:	f586                	sd	ra,232(sp)
    800053c8:	f1a2                	sd	s0,224(sp)
    800053ca:	eda6                	sd	s1,216(sp)
    800053cc:	e9ca                	sd	s2,208(sp)
    800053ce:	e5ce                	sd	s3,200(sp)
    800053d0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053d2:	08000613          	li	a2,128
    800053d6:	f3040593          	addi	a1,s0,-208
    800053da:	4501                	li	a0,0
    800053dc:	ffffd097          	auipc	ra,0xffffd
    800053e0:	6ea080e7          	jalr	1770(ra) # 80002ac6 <argstr>
    800053e4:	18054163          	bltz	a0,80005566 <sys_unlink+0x1a2>
  begin_op();
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	bcc080e7          	jalr	-1076(ra) # 80003fb4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053f0:	fb040593          	addi	a1,s0,-80
    800053f4:	f3040513          	addi	a0,s0,-208
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	9ca080e7          	jalr	-1590(ra) # 80003dc2 <nameiparent>
    80005400:	84aa                	mv	s1,a0
    80005402:	c979                	beqz	a0,800054d8 <sys_unlink+0x114>
  ilock(dp);
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	1f0080e7          	jalr	496(ra) # 800035f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	2dc58593          	addi	a1,a1,732 # 800086e8 <syscalls+0x2c0>
    80005414:	fb040513          	addi	a0,s0,-80
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	6a0080e7          	jalr	1696(ra) # 80003ab8 <namecmp>
    80005420:	14050a63          	beqz	a0,80005574 <sys_unlink+0x1b0>
    80005424:	00003597          	auipc	a1,0x3
    80005428:	2cc58593          	addi	a1,a1,716 # 800086f0 <syscalls+0x2c8>
    8000542c:	fb040513          	addi	a0,s0,-80
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	688080e7          	jalr	1672(ra) # 80003ab8 <namecmp>
    80005438:	12050e63          	beqz	a0,80005574 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000543c:	f2c40613          	addi	a2,s0,-212
    80005440:	fb040593          	addi	a1,s0,-80
    80005444:	8526                	mv	a0,s1
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	68c080e7          	jalr	1676(ra) # 80003ad2 <dirlookup>
    8000544e:	892a                	mv	s2,a0
    80005450:	12050263          	beqz	a0,80005574 <sys_unlink+0x1b0>
  ilock(ip);
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	1a0080e7          	jalr	416(ra) # 800035f4 <ilock>
  if(ip->nlink < 1)
    8000545c:	04a91783          	lh	a5,74(s2)
    80005460:	08f05263          	blez	a5,800054e4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005464:	04491703          	lh	a4,68(s2)
    80005468:	4785                	li	a5,1
    8000546a:	08f70563          	beq	a4,a5,800054f4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000546e:	4641                	li	a2,16
    80005470:	4581                	li	a1,0
    80005472:	fc040513          	addi	a0,s0,-64
    80005476:	ffffc097          	auipc	ra,0xffffc
    8000547a:	884080e7          	jalr	-1916(ra) # 80000cfa <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000547e:	4741                	li	a4,16
    80005480:	f2c42683          	lw	a3,-212(s0)
    80005484:	fc040613          	addi	a2,s0,-64
    80005488:	4581                	li	a1,0
    8000548a:	8526                	mv	a0,s1
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	512080e7          	jalr	1298(ra) # 8000399e <writei>
    80005494:	47c1                	li	a5,16
    80005496:	0af51563          	bne	a0,a5,80005540 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000549a:	04491703          	lh	a4,68(s2)
    8000549e:	4785                	li	a5,1
    800054a0:	0af70863          	beq	a4,a5,80005550 <sys_unlink+0x18c>
  iunlockput(dp);
    800054a4:	8526                	mv	a0,s1
    800054a6:	ffffe097          	auipc	ra,0xffffe
    800054aa:	3b0080e7          	jalr	944(ra) # 80003856 <iunlockput>
  ip->nlink--;
    800054ae:	04a95783          	lhu	a5,74(s2)
    800054b2:	37fd                	addiw	a5,a5,-1
    800054b4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054b8:	854a                	mv	a0,s2
    800054ba:	ffffe097          	auipc	ra,0xffffe
    800054be:	070080e7          	jalr	112(ra) # 8000352a <iupdate>
  iunlockput(ip);
    800054c2:	854a                	mv	a0,s2
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	392080e7          	jalr	914(ra) # 80003856 <iunlockput>
  end_op();
    800054cc:	fffff097          	auipc	ra,0xfffff
    800054d0:	b68080e7          	jalr	-1176(ra) # 80004034 <end_op>
  return 0;
    800054d4:	4501                	li	a0,0
    800054d6:	a84d                	j	80005588 <sys_unlink+0x1c4>
    end_op();
    800054d8:	fffff097          	auipc	ra,0xfffff
    800054dc:	b5c080e7          	jalr	-1188(ra) # 80004034 <end_op>
    return -1;
    800054e0:	557d                	li	a0,-1
    800054e2:	a05d                	j	80005588 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054e4:	00003517          	auipc	a0,0x3
    800054e8:	23450513          	addi	a0,a0,564 # 80008718 <syscalls+0x2f0>
    800054ec:	ffffb097          	auipc	ra,0xffffb
    800054f0:	056080e7          	jalr	86(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054f4:	04c92703          	lw	a4,76(s2)
    800054f8:	02000793          	li	a5,32
    800054fc:	f6e7f9e3          	bgeu	a5,a4,8000546e <sys_unlink+0xaa>
    80005500:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005504:	4741                	li	a4,16
    80005506:	86ce                	mv	a3,s3
    80005508:	f1840613          	addi	a2,s0,-232
    8000550c:	4581                	li	a1,0
    8000550e:	854a                	mv	a0,s2
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	398080e7          	jalr	920(ra) # 800038a8 <readi>
    80005518:	47c1                	li	a5,16
    8000551a:	00f51b63          	bne	a0,a5,80005530 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000551e:	f1845783          	lhu	a5,-232(s0)
    80005522:	e7a1                	bnez	a5,8000556a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005524:	29c1                	addiw	s3,s3,16
    80005526:	04c92783          	lw	a5,76(s2)
    8000552a:	fcf9ede3          	bltu	s3,a5,80005504 <sys_unlink+0x140>
    8000552e:	b781                	j	8000546e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005530:	00003517          	auipc	a0,0x3
    80005534:	20050513          	addi	a0,a0,512 # 80008730 <syscalls+0x308>
    80005538:	ffffb097          	auipc	ra,0xffffb
    8000553c:	00a080e7          	jalr	10(ra) # 80000542 <panic>
    panic("unlink: writei");
    80005540:	00003517          	auipc	a0,0x3
    80005544:	20850513          	addi	a0,a0,520 # 80008748 <syscalls+0x320>
    80005548:	ffffb097          	auipc	ra,0xffffb
    8000554c:	ffa080e7          	jalr	-6(ra) # 80000542 <panic>
    dp->nlink--;
    80005550:	04a4d783          	lhu	a5,74(s1)
    80005554:	37fd                	addiw	a5,a5,-1
    80005556:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000555a:	8526                	mv	a0,s1
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	fce080e7          	jalr	-50(ra) # 8000352a <iupdate>
    80005564:	b781                	j	800054a4 <sys_unlink+0xe0>
    return -1;
    80005566:	557d                	li	a0,-1
    80005568:	a005                	j	80005588 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000556a:	854a                	mv	a0,s2
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	2ea080e7          	jalr	746(ra) # 80003856 <iunlockput>
  iunlockput(dp);
    80005574:	8526                	mv	a0,s1
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	2e0080e7          	jalr	736(ra) # 80003856 <iunlockput>
  end_op();
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	ab6080e7          	jalr	-1354(ra) # 80004034 <end_op>
  return -1;
    80005586:	557d                	li	a0,-1
}
    80005588:	70ae                	ld	ra,232(sp)
    8000558a:	740e                	ld	s0,224(sp)
    8000558c:	64ee                	ld	s1,216(sp)
    8000558e:	694e                	ld	s2,208(sp)
    80005590:	69ae                	ld	s3,200(sp)
    80005592:	616d                	addi	sp,sp,240
    80005594:	8082                	ret

0000000080005596 <sys_open>:

uint64
sys_open(void)
{
    80005596:	7131                	addi	sp,sp,-192
    80005598:	fd06                	sd	ra,184(sp)
    8000559a:	f922                	sd	s0,176(sp)
    8000559c:	f526                	sd	s1,168(sp)
    8000559e:	f14a                	sd	s2,160(sp)
    800055a0:	ed4e                	sd	s3,152(sp)
    800055a2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055a4:	08000613          	li	a2,128
    800055a8:	f5040593          	addi	a1,s0,-176
    800055ac:	4501                	li	a0,0
    800055ae:	ffffd097          	auipc	ra,0xffffd
    800055b2:	518080e7          	jalr	1304(ra) # 80002ac6 <argstr>
    return -1;
    800055b6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055b8:	0c054163          	bltz	a0,8000567a <sys_open+0xe4>
    800055bc:	f4c40593          	addi	a1,s0,-180
    800055c0:	4505                	li	a0,1
    800055c2:	ffffd097          	auipc	ra,0xffffd
    800055c6:	4c0080e7          	jalr	1216(ra) # 80002a82 <argint>
    800055ca:	0a054863          	bltz	a0,8000567a <sys_open+0xe4>

  begin_op();
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	9e6080e7          	jalr	-1562(ra) # 80003fb4 <begin_op>

  if(omode & O_CREATE){
    800055d6:	f4c42783          	lw	a5,-180(s0)
    800055da:	2007f793          	andi	a5,a5,512
    800055de:	cbdd                	beqz	a5,80005694 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800055e0:	4681                	li	a3,0
    800055e2:	4601                	li	a2,0
    800055e4:	4589                	li	a1,2
    800055e6:	f5040513          	addi	a0,s0,-176
    800055ea:	00000097          	auipc	ra,0x0
    800055ee:	974080e7          	jalr	-1676(ra) # 80004f5e <create>
    800055f2:	892a                	mv	s2,a0
    if(ip == 0){
    800055f4:	c959                	beqz	a0,8000568a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055f6:	04491703          	lh	a4,68(s2)
    800055fa:	478d                	li	a5,3
    800055fc:	00f71763          	bne	a4,a5,8000560a <sys_open+0x74>
    80005600:	04695703          	lhu	a4,70(s2)
    80005604:	47a5                	li	a5,9
    80005606:	0ce7ec63          	bltu	a5,a4,800056de <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	dc0080e7          	jalr	-576(ra) # 800043ca <filealloc>
    80005612:	89aa                	mv	s3,a0
    80005614:	10050263          	beqz	a0,80005718 <sys_open+0x182>
    80005618:	00000097          	auipc	ra,0x0
    8000561c:	904080e7          	jalr	-1788(ra) # 80004f1c <fdalloc>
    80005620:	84aa                	mv	s1,a0
    80005622:	0e054663          	bltz	a0,8000570e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005626:	04491703          	lh	a4,68(s2)
    8000562a:	478d                	li	a5,3
    8000562c:	0cf70463          	beq	a4,a5,800056f4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005630:	4789                	li	a5,2
    80005632:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005636:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000563a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000563e:	f4c42783          	lw	a5,-180(s0)
    80005642:	0017c713          	xori	a4,a5,1
    80005646:	8b05                	andi	a4,a4,1
    80005648:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000564c:	0037f713          	andi	a4,a5,3
    80005650:	00e03733          	snez	a4,a4
    80005654:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005658:	4007f793          	andi	a5,a5,1024
    8000565c:	c791                	beqz	a5,80005668 <sys_open+0xd2>
    8000565e:	04491703          	lh	a4,68(s2)
    80005662:	4789                	li	a5,2
    80005664:	08f70f63          	beq	a4,a5,80005702 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005668:	854a                	mv	a0,s2
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	04c080e7          	jalr	76(ra) # 800036b6 <iunlock>
  end_op();
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	9c2080e7          	jalr	-1598(ra) # 80004034 <end_op>

  return fd;
}
    8000567a:	8526                	mv	a0,s1
    8000567c:	70ea                	ld	ra,184(sp)
    8000567e:	744a                	ld	s0,176(sp)
    80005680:	74aa                	ld	s1,168(sp)
    80005682:	790a                	ld	s2,160(sp)
    80005684:	69ea                	ld	s3,152(sp)
    80005686:	6129                	addi	sp,sp,192
    80005688:	8082                	ret
      end_op();
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	9aa080e7          	jalr	-1622(ra) # 80004034 <end_op>
      return -1;
    80005692:	b7e5                	j	8000567a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005694:	f5040513          	addi	a0,s0,-176
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	70c080e7          	jalr	1804(ra) # 80003da4 <namei>
    800056a0:	892a                	mv	s2,a0
    800056a2:	c905                	beqz	a0,800056d2 <sys_open+0x13c>
    ilock(ip);
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	f50080e7          	jalr	-176(ra) # 800035f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056ac:	04491703          	lh	a4,68(s2)
    800056b0:	4785                	li	a5,1
    800056b2:	f4f712e3          	bne	a4,a5,800055f6 <sys_open+0x60>
    800056b6:	f4c42783          	lw	a5,-180(s0)
    800056ba:	dba1                	beqz	a5,8000560a <sys_open+0x74>
      iunlockput(ip);
    800056bc:	854a                	mv	a0,s2
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	198080e7          	jalr	408(ra) # 80003856 <iunlockput>
      end_op();
    800056c6:	fffff097          	auipc	ra,0xfffff
    800056ca:	96e080e7          	jalr	-1682(ra) # 80004034 <end_op>
      return -1;
    800056ce:	54fd                	li	s1,-1
    800056d0:	b76d                	j	8000567a <sys_open+0xe4>
      end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	962080e7          	jalr	-1694(ra) # 80004034 <end_op>
      return -1;
    800056da:	54fd                	li	s1,-1
    800056dc:	bf79                	j	8000567a <sys_open+0xe4>
    iunlockput(ip);
    800056de:	854a                	mv	a0,s2
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	176080e7          	jalr	374(ra) # 80003856 <iunlockput>
    end_op();
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	94c080e7          	jalr	-1716(ra) # 80004034 <end_op>
    return -1;
    800056f0:	54fd                	li	s1,-1
    800056f2:	b761                	j	8000567a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800056f4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800056f8:	04691783          	lh	a5,70(s2)
    800056fc:	02f99223          	sh	a5,36(s3)
    80005700:	bf2d                	j	8000563a <sys_open+0xa4>
    itrunc(ip);
    80005702:	854a                	mv	a0,s2
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	ffe080e7          	jalr	-2(ra) # 80003702 <itrunc>
    8000570c:	bfb1                	j	80005668 <sys_open+0xd2>
      fileclose(f);
    8000570e:	854e                	mv	a0,s3
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	d76080e7          	jalr	-650(ra) # 80004486 <fileclose>
    iunlockput(ip);
    80005718:	854a                	mv	a0,s2
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	13c080e7          	jalr	316(ra) # 80003856 <iunlockput>
    end_op();
    80005722:	fffff097          	auipc	ra,0xfffff
    80005726:	912080e7          	jalr	-1774(ra) # 80004034 <end_op>
    return -1;
    8000572a:	54fd                	li	s1,-1
    8000572c:	b7b9                	j	8000567a <sys_open+0xe4>

000000008000572e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000572e:	7175                	addi	sp,sp,-144
    80005730:	e506                	sd	ra,136(sp)
    80005732:	e122                	sd	s0,128(sp)
    80005734:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005736:	fffff097          	auipc	ra,0xfffff
    8000573a:	87e080e7          	jalr	-1922(ra) # 80003fb4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000573e:	08000613          	li	a2,128
    80005742:	f7040593          	addi	a1,s0,-144
    80005746:	4501                	li	a0,0
    80005748:	ffffd097          	auipc	ra,0xffffd
    8000574c:	37e080e7          	jalr	894(ra) # 80002ac6 <argstr>
    80005750:	02054963          	bltz	a0,80005782 <sys_mkdir+0x54>
    80005754:	4681                	li	a3,0
    80005756:	4601                	li	a2,0
    80005758:	4585                	li	a1,1
    8000575a:	f7040513          	addi	a0,s0,-144
    8000575e:	00000097          	auipc	ra,0x0
    80005762:	800080e7          	jalr	-2048(ra) # 80004f5e <create>
    80005766:	cd11                	beqz	a0,80005782 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	0ee080e7          	jalr	238(ra) # 80003856 <iunlockput>
  end_op();
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	8c4080e7          	jalr	-1852(ra) # 80004034 <end_op>
  return 0;
    80005778:	4501                	li	a0,0
}
    8000577a:	60aa                	ld	ra,136(sp)
    8000577c:	640a                	ld	s0,128(sp)
    8000577e:	6149                	addi	sp,sp,144
    80005780:	8082                	ret
    end_op();
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	8b2080e7          	jalr	-1870(ra) # 80004034 <end_op>
    return -1;
    8000578a:	557d                	li	a0,-1
    8000578c:	b7fd                	j	8000577a <sys_mkdir+0x4c>

000000008000578e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000578e:	7135                	addi	sp,sp,-160
    80005790:	ed06                	sd	ra,152(sp)
    80005792:	e922                	sd	s0,144(sp)
    80005794:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005796:	fffff097          	auipc	ra,0xfffff
    8000579a:	81e080e7          	jalr	-2018(ra) # 80003fb4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000579e:	08000613          	li	a2,128
    800057a2:	f7040593          	addi	a1,s0,-144
    800057a6:	4501                	li	a0,0
    800057a8:	ffffd097          	auipc	ra,0xffffd
    800057ac:	31e080e7          	jalr	798(ra) # 80002ac6 <argstr>
    800057b0:	04054a63          	bltz	a0,80005804 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800057b4:	f6c40593          	addi	a1,s0,-148
    800057b8:	4505                	li	a0,1
    800057ba:	ffffd097          	auipc	ra,0xffffd
    800057be:	2c8080e7          	jalr	712(ra) # 80002a82 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057c2:	04054163          	bltz	a0,80005804 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800057c6:	f6840593          	addi	a1,s0,-152
    800057ca:	4509                	li	a0,2
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	2b6080e7          	jalr	694(ra) # 80002a82 <argint>
     argint(1, &major) < 0 ||
    800057d4:	02054863          	bltz	a0,80005804 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057d8:	f6841683          	lh	a3,-152(s0)
    800057dc:	f6c41603          	lh	a2,-148(s0)
    800057e0:	458d                	li	a1,3
    800057e2:	f7040513          	addi	a0,s0,-144
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	778080e7          	jalr	1912(ra) # 80004f5e <create>
     argint(2, &minor) < 0 ||
    800057ee:	c919                	beqz	a0,80005804 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057f0:	ffffe097          	auipc	ra,0xffffe
    800057f4:	066080e7          	jalr	102(ra) # 80003856 <iunlockput>
  end_op();
    800057f8:	fffff097          	auipc	ra,0xfffff
    800057fc:	83c080e7          	jalr	-1988(ra) # 80004034 <end_op>
  return 0;
    80005800:	4501                	li	a0,0
    80005802:	a031                	j	8000580e <sys_mknod+0x80>
    end_op();
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	830080e7          	jalr	-2000(ra) # 80004034 <end_op>
    return -1;
    8000580c:	557d                	li	a0,-1
}
    8000580e:	60ea                	ld	ra,152(sp)
    80005810:	644a                	ld	s0,144(sp)
    80005812:	610d                	addi	sp,sp,160
    80005814:	8082                	ret

0000000080005816 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005816:	7135                	addi	sp,sp,-160
    80005818:	ed06                	sd	ra,152(sp)
    8000581a:	e922                	sd	s0,144(sp)
    8000581c:	e526                	sd	s1,136(sp)
    8000581e:	e14a                	sd	s2,128(sp)
    80005820:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005822:	ffffc097          	auipc	ra,0xffffc
    80005826:	1a8080e7          	jalr	424(ra) # 800019ca <myproc>
    8000582a:	892a                	mv	s2,a0
  
  begin_op();
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	788080e7          	jalr	1928(ra) # 80003fb4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005834:	08000613          	li	a2,128
    80005838:	f6040593          	addi	a1,s0,-160
    8000583c:	4501                	li	a0,0
    8000583e:	ffffd097          	auipc	ra,0xffffd
    80005842:	288080e7          	jalr	648(ra) # 80002ac6 <argstr>
    80005846:	04054b63          	bltz	a0,8000589c <sys_chdir+0x86>
    8000584a:	f6040513          	addi	a0,s0,-160
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	556080e7          	jalr	1366(ra) # 80003da4 <namei>
    80005856:	84aa                	mv	s1,a0
    80005858:	c131                	beqz	a0,8000589c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000585a:	ffffe097          	auipc	ra,0xffffe
    8000585e:	d9a080e7          	jalr	-614(ra) # 800035f4 <ilock>
  if(ip->type != T_DIR){
    80005862:	04449703          	lh	a4,68(s1)
    80005866:	4785                	li	a5,1
    80005868:	04f71063          	bne	a4,a5,800058a8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000586c:	8526                	mv	a0,s1
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	e48080e7          	jalr	-440(ra) # 800036b6 <iunlock>
  iput(p->cwd);
    80005876:	15093503          	ld	a0,336(s2)
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	f34080e7          	jalr	-204(ra) # 800037ae <iput>
  end_op();
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	7b2080e7          	jalr	1970(ra) # 80004034 <end_op>
  p->cwd = ip;
    8000588a:	14993823          	sd	s1,336(s2)
  return 0;
    8000588e:	4501                	li	a0,0
}
    80005890:	60ea                	ld	ra,152(sp)
    80005892:	644a                	ld	s0,144(sp)
    80005894:	64aa                	ld	s1,136(sp)
    80005896:	690a                	ld	s2,128(sp)
    80005898:	610d                	addi	sp,sp,160
    8000589a:	8082                	ret
    end_op();
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	798080e7          	jalr	1944(ra) # 80004034 <end_op>
    return -1;
    800058a4:	557d                	li	a0,-1
    800058a6:	b7ed                	j	80005890 <sys_chdir+0x7a>
    iunlockput(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	fac080e7          	jalr	-84(ra) # 80003856 <iunlockput>
    end_op();
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	782080e7          	jalr	1922(ra) # 80004034 <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	bfd1                	j	80005890 <sys_chdir+0x7a>

00000000800058be <sys_exec>:

uint64
sys_exec(void)
{
    800058be:	7145                	addi	sp,sp,-464
    800058c0:	e786                	sd	ra,456(sp)
    800058c2:	e3a2                	sd	s0,448(sp)
    800058c4:	ff26                	sd	s1,440(sp)
    800058c6:	fb4a                	sd	s2,432(sp)
    800058c8:	f74e                	sd	s3,424(sp)
    800058ca:	f352                	sd	s4,416(sp)
    800058cc:	ef56                	sd	s5,408(sp)
    800058ce:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058d0:	08000613          	li	a2,128
    800058d4:	f4040593          	addi	a1,s0,-192
    800058d8:	4501                	li	a0,0
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	1ec080e7          	jalr	492(ra) # 80002ac6 <argstr>
    return -1;
    800058e2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058e4:	0c054a63          	bltz	a0,800059b8 <sys_exec+0xfa>
    800058e8:	e3840593          	addi	a1,s0,-456
    800058ec:	4505                	li	a0,1
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	1b6080e7          	jalr	438(ra) # 80002aa4 <argaddr>
    800058f6:	0c054163          	bltz	a0,800059b8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800058fa:	10000613          	li	a2,256
    800058fe:	4581                	li	a1,0
    80005900:	e4040513          	addi	a0,s0,-448
    80005904:	ffffb097          	auipc	ra,0xffffb
    80005908:	3f6080e7          	jalr	1014(ra) # 80000cfa <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000590c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005910:	89a6                	mv	s3,s1
    80005912:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005914:	02000a13          	li	s4,32
    80005918:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000591c:	00391793          	slli	a5,s2,0x3
    80005920:	e3040593          	addi	a1,s0,-464
    80005924:	e3843503          	ld	a0,-456(s0)
    80005928:	953e                	add	a0,a0,a5
    8000592a:	ffffd097          	auipc	ra,0xffffd
    8000592e:	0be080e7          	jalr	190(ra) # 800029e8 <fetchaddr>
    80005932:	02054a63          	bltz	a0,80005966 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005936:	e3043783          	ld	a5,-464(s0)
    8000593a:	c3b9                	beqz	a5,80005980 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000593c:	ffffb097          	auipc	ra,0xffffb
    80005940:	1d2080e7          	jalr	466(ra) # 80000b0e <kalloc>
    80005944:	85aa                	mv	a1,a0
    80005946:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000594a:	cd11                	beqz	a0,80005966 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000594c:	6605                	lui	a2,0x1
    8000594e:	e3043503          	ld	a0,-464(s0)
    80005952:	ffffd097          	auipc	ra,0xffffd
    80005956:	0e8080e7          	jalr	232(ra) # 80002a3a <fetchstr>
    8000595a:	00054663          	bltz	a0,80005966 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000595e:	0905                	addi	s2,s2,1
    80005960:	09a1                	addi	s3,s3,8
    80005962:	fb491be3          	bne	s2,s4,80005918 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005966:	10048913          	addi	s2,s1,256
    8000596a:	6088                	ld	a0,0(s1)
    8000596c:	c529                	beqz	a0,800059b6 <sys_exec+0xf8>
    kfree(argv[i]);
    8000596e:	ffffb097          	auipc	ra,0xffffb
    80005972:	0a4080e7          	jalr	164(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005976:	04a1                	addi	s1,s1,8
    80005978:	ff2499e3          	bne	s1,s2,8000596a <sys_exec+0xac>
  return -1;
    8000597c:	597d                	li	s2,-1
    8000597e:	a82d                	j	800059b8 <sys_exec+0xfa>
      argv[i] = 0;
    80005980:	0a8e                	slli	s5,s5,0x3
    80005982:	fc040793          	addi	a5,s0,-64
    80005986:	9abe                	add	s5,s5,a5
    80005988:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    8000598c:	e4040593          	addi	a1,s0,-448
    80005990:	f4040513          	addi	a0,s0,-192
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	178080e7          	jalr	376(ra) # 80004b0c <exec>
    8000599c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000599e:	10048993          	addi	s3,s1,256
    800059a2:	6088                	ld	a0,0(s1)
    800059a4:	c911                	beqz	a0,800059b8 <sys_exec+0xfa>
    kfree(argv[i]);
    800059a6:	ffffb097          	auipc	ra,0xffffb
    800059aa:	06c080e7          	jalr	108(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ae:	04a1                	addi	s1,s1,8
    800059b0:	ff3499e3          	bne	s1,s3,800059a2 <sys_exec+0xe4>
    800059b4:	a011                	j	800059b8 <sys_exec+0xfa>
  return -1;
    800059b6:	597d                	li	s2,-1
}
    800059b8:	854a                	mv	a0,s2
    800059ba:	60be                	ld	ra,456(sp)
    800059bc:	641e                	ld	s0,448(sp)
    800059be:	74fa                	ld	s1,440(sp)
    800059c0:	795a                	ld	s2,432(sp)
    800059c2:	79ba                	ld	s3,424(sp)
    800059c4:	7a1a                	ld	s4,416(sp)
    800059c6:	6afa                	ld	s5,408(sp)
    800059c8:	6179                	addi	sp,sp,464
    800059ca:	8082                	ret

00000000800059cc <sys_pipe>:

uint64
sys_pipe(void)
{
    800059cc:	7139                	addi	sp,sp,-64
    800059ce:	fc06                	sd	ra,56(sp)
    800059d0:	f822                	sd	s0,48(sp)
    800059d2:	f426                	sd	s1,40(sp)
    800059d4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059d6:	ffffc097          	auipc	ra,0xffffc
    800059da:	ff4080e7          	jalr	-12(ra) # 800019ca <myproc>
    800059de:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800059e0:	fd840593          	addi	a1,s0,-40
    800059e4:	4501                	li	a0,0
    800059e6:	ffffd097          	auipc	ra,0xffffd
    800059ea:	0be080e7          	jalr	190(ra) # 80002aa4 <argaddr>
    return -1;
    800059ee:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800059f0:	0e054063          	bltz	a0,80005ad0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800059f4:	fc840593          	addi	a1,s0,-56
    800059f8:	fd040513          	addi	a0,s0,-48
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	de0080e7          	jalr	-544(ra) # 800047dc <pipealloc>
    return -1;
    80005a04:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a06:	0c054563          	bltz	a0,80005ad0 <sys_pipe+0x104>
  fd0 = -1;
    80005a0a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a0e:	fd043503          	ld	a0,-48(s0)
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	50a080e7          	jalr	1290(ra) # 80004f1c <fdalloc>
    80005a1a:	fca42223          	sw	a0,-60(s0)
    80005a1e:	08054c63          	bltz	a0,80005ab6 <sys_pipe+0xea>
    80005a22:	fc843503          	ld	a0,-56(s0)
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	4f6080e7          	jalr	1270(ra) # 80004f1c <fdalloc>
    80005a2e:	fca42023          	sw	a0,-64(s0)
    80005a32:	06054863          	bltz	a0,80005aa2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a36:	4691                	li	a3,4
    80005a38:	fc440613          	addi	a2,s0,-60
    80005a3c:	fd843583          	ld	a1,-40(s0)
    80005a40:	68a8                	ld	a0,80(s1)
    80005a42:	ffffc097          	auipc	ra,0xffffc
    80005a46:	c7a080e7          	jalr	-902(ra) # 800016bc <copyout>
    80005a4a:	02054063          	bltz	a0,80005a6a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a4e:	4691                	li	a3,4
    80005a50:	fc040613          	addi	a2,s0,-64
    80005a54:	fd843583          	ld	a1,-40(s0)
    80005a58:	0591                	addi	a1,a1,4
    80005a5a:	68a8                	ld	a0,80(s1)
    80005a5c:	ffffc097          	auipc	ra,0xffffc
    80005a60:	c60080e7          	jalr	-928(ra) # 800016bc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a64:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a66:	06055563          	bgez	a0,80005ad0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a6a:	fc442783          	lw	a5,-60(s0)
    80005a6e:	07e9                	addi	a5,a5,26
    80005a70:	078e                	slli	a5,a5,0x3
    80005a72:	97a6                	add	a5,a5,s1
    80005a74:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a78:	fc042503          	lw	a0,-64(s0)
    80005a7c:	0569                	addi	a0,a0,26
    80005a7e:	050e                	slli	a0,a0,0x3
    80005a80:	9526                	add	a0,a0,s1
    80005a82:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005a86:	fd043503          	ld	a0,-48(s0)
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	9fc080e7          	jalr	-1540(ra) # 80004486 <fileclose>
    fileclose(wf);
    80005a92:	fc843503          	ld	a0,-56(s0)
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	9f0080e7          	jalr	-1552(ra) # 80004486 <fileclose>
    return -1;
    80005a9e:	57fd                	li	a5,-1
    80005aa0:	a805                	j	80005ad0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005aa2:	fc442783          	lw	a5,-60(s0)
    80005aa6:	0007c863          	bltz	a5,80005ab6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005aaa:	01a78513          	addi	a0,a5,26
    80005aae:	050e                	slli	a0,a0,0x3
    80005ab0:	9526                	add	a0,a0,s1
    80005ab2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ab6:	fd043503          	ld	a0,-48(s0)
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	9cc080e7          	jalr	-1588(ra) # 80004486 <fileclose>
    fileclose(wf);
    80005ac2:	fc843503          	ld	a0,-56(s0)
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	9c0080e7          	jalr	-1600(ra) # 80004486 <fileclose>
    return -1;
    80005ace:	57fd                	li	a5,-1
}
    80005ad0:	853e                	mv	a0,a5
    80005ad2:	70e2                	ld	ra,56(sp)
    80005ad4:	7442                	ld	s0,48(sp)
    80005ad6:	74a2                	ld	s1,40(sp)
    80005ad8:	6121                	addi	sp,sp,64
    80005ada:	8082                	ret
    80005adc:	0000                	unimp
	...

0000000080005ae0 <kernelvec>:
    80005ae0:	7111                	addi	sp,sp,-256
    80005ae2:	e006                	sd	ra,0(sp)
    80005ae4:	e40a                	sd	sp,8(sp)
    80005ae6:	e80e                	sd	gp,16(sp)
    80005ae8:	ec12                	sd	tp,24(sp)
    80005aea:	f016                	sd	t0,32(sp)
    80005aec:	f41a                	sd	t1,40(sp)
    80005aee:	f81e                	sd	t2,48(sp)
    80005af0:	fc22                	sd	s0,56(sp)
    80005af2:	e0a6                	sd	s1,64(sp)
    80005af4:	e4aa                	sd	a0,72(sp)
    80005af6:	e8ae                	sd	a1,80(sp)
    80005af8:	ecb2                	sd	a2,88(sp)
    80005afa:	f0b6                	sd	a3,96(sp)
    80005afc:	f4ba                	sd	a4,104(sp)
    80005afe:	f8be                	sd	a5,112(sp)
    80005b00:	fcc2                	sd	a6,120(sp)
    80005b02:	e146                	sd	a7,128(sp)
    80005b04:	e54a                	sd	s2,136(sp)
    80005b06:	e94e                	sd	s3,144(sp)
    80005b08:	ed52                	sd	s4,152(sp)
    80005b0a:	f156                	sd	s5,160(sp)
    80005b0c:	f55a                	sd	s6,168(sp)
    80005b0e:	f95e                	sd	s7,176(sp)
    80005b10:	fd62                	sd	s8,184(sp)
    80005b12:	e1e6                	sd	s9,192(sp)
    80005b14:	e5ea                	sd	s10,200(sp)
    80005b16:	e9ee                	sd	s11,208(sp)
    80005b18:	edf2                	sd	t3,216(sp)
    80005b1a:	f1f6                	sd	t4,224(sp)
    80005b1c:	f5fa                	sd	t5,232(sp)
    80005b1e:	f9fe                	sd	t6,240(sp)
    80005b20:	d95fc0ef          	jal	ra,800028b4 <kerneltrap>
    80005b24:	6082                	ld	ra,0(sp)
    80005b26:	6122                	ld	sp,8(sp)
    80005b28:	61c2                	ld	gp,16(sp)
    80005b2a:	7282                	ld	t0,32(sp)
    80005b2c:	7322                	ld	t1,40(sp)
    80005b2e:	73c2                	ld	t2,48(sp)
    80005b30:	7462                	ld	s0,56(sp)
    80005b32:	6486                	ld	s1,64(sp)
    80005b34:	6526                	ld	a0,72(sp)
    80005b36:	65c6                	ld	a1,80(sp)
    80005b38:	6666                	ld	a2,88(sp)
    80005b3a:	7686                	ld	a3,96(sp)
    80005b3c:	7726                	ld	a4,104(sp)
    80005b3e:	77c6                	ld	a5,112(sp)
    80005b40:	7866                	ld	a6,120(sp)
    80005b42:	688a                	ld	a7,128(sp)
    80005b44:	692a                	ld	s2,136(sp)
    80005b46:	69ca                	ld	s3,144(sp)
    80005b48:	6a6a                	ld	s4,152(sp)
    80005b4a:	7a8a                	ld	s5,160(sp)
    80005b4c:	7b2a                	ld	s6,168(sp)
    80005b4e:	7bca                	ld	s7,176(sp)
    80005b50:	7c6a                	ld	s8,184(sp)
    80005b52:	6c8e                	ld	s9,192(sp)
    80005b54:	6d2e                	ld	s10,200(sp)
    80005b56:	6dce                	ld	s11,208(sp)
    80005b58:	6e6e                	ld	t3,216(sp)
    80005b5a:	7e8e                	ld	t4,224(sp)
    80005b5c:	7f2e                	ld	t5,232(sp)
    80005b5e:	7fce                	ld	t6,240(sp)
    80005b60:	6111                	addi	sp,sp,256
    80005b62:	10200073          	sret
    80005b66:	00000013          	nop
    80005b6a:	00000013          	nop
    80005b6e:	0001                	nop

0000000080005b70 <timervec>:
    80005b70:	34051573          	csrrw	a0,mscratch,a0
    80005b74:	e10c                	sd	a1,0(a0)
    80005b76:	e510                	sd	a2,8(a0)
    80005b78:	e914                	sd	a3,16(a0)
    80005b7a:	710c                	ld	a1,32(a0)
    80005b7c:	7510                	ld	a2,40(a0)
    80005b7e:	6194                	ld	a3,0(a1)
    80005b80:	96b2                	add	a3,a3,a2
    80005b82:	e194                	sd	a3,0(a1)
    80005b84:	4589                	li	a1,2
    80005b86:	14459073          	csrw	sip,a1
    80005b8a:	6914                	ld	a3,16(a0)
    80005b8c:	6510                	ld	a2,8(a0)
    80005b8e:	610c                	ld	a1,0(a0)
    80005b90:	34051573          	csrrw	a0,mscratch,a0
    80005b94:	30200073          	mret
	...

0000000080005b9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b9a:	1141                	addi	sp,sp,-16
    80005b9c:	e422                	sd	s0,8(sp)
    80005b9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ba0:	0c0007b7          	lui	a5,0xc000
    80005ba4:	4705                	li	a4,1
    80005ba6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ba8:	c3d8                	sw	a4,4(a5)
}
    80005baa:	6422                	ld	s0,8(sp)
    80005bac:	0141                	addi	sp,sp,16
    80005bae:	8082                	ret

0000000080005bb0 <plicinithart>:

void
plicinithart(void)
{
    80005bb0:	1141                	addi	sp,sp,-16
    80005bb2:	e406                	sd	ra,8(sp)
    80005bb4:	e022                	sd	s0,0(sp)
    80005bb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bb8:	ffffc097          	auipc	ra,0xffffc
    80005bbc:	de6080e7          	jalr	-538(ra) # 8000199e <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bc0:	0085171b          	slliw	a4,a0,0x8
    80005bc4:	0c0027b7          	lui	a5,0xc002
    80005bc8:	97ba                	add	a5,a5,a4
    80005bca:	40200713          	li	a4,1026
    80005bce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005bd2:	00d5151b          	slliw	a0,a0,0xd
    80005bd6:	0c2017b7          	lui	a5,0xc201
    80005bda:	953e                	add	a0,a0,a5
    80005bdc:	00052023          	sw	zero,0(a0)
}
    80005be0:	60a2                	ld	ra,8(sp)
    80005be2:	6402                	ld	s0,0(sp)
    80005be4:	0141                	addi	sp,sp,16
    80005be6:	8082                	ret

0000000080005be8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005be8:	1141                	addi	sp,sp,-16
    80005bea:	e406                	sd	ra,8(sp)
    80005bec:	e022                	sd	s0,0(sp)
    80005bee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bf0:	ffffc097          	auipc	ra,0xffffc
    80005bf4:	dae080e7          	jalr	-594(ra) # 8000199e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005bf8:	00d5179b          	slliw	a5,a0,0xd
    80005bfc:	0c201537          	lui	a0,0xc201
    80005c00:	953e                	add	a0,a0,a5
  return irq;
}
    80005c02:	4148                	lw	a0,4(a0)
    80005c04:	60a2                	ld	ra,8(sp)
    80005c06:	6402                	ld	s0,0(sp)
    80005c08:	0141                	addi	sp,sp,16
    80005c0a:	8082                	ret

0000000080005c0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c0c:	1101                	addi	sp,sp,-32
    80005c0e:	ec06                	sd	ra,24(sp)
    80005c10:	e822                	sd	s0,16(sp)
    80005c12:	e426                	sd	s1,8(sp)
    80005c14:	1000                	addi	s0,sp,32
    80005c16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	d86080e7          	jalr	-634(ra) # 8000199e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c20:	00d5151b          	slliw	a0,a0,0xd
    80005c24:	0c2017b7          	lui	a5,0xc201
    80005c28:	97aa                	add	a5,a5,a0
    80005c2a:	c3c4                	sw	s1,4(a5)
}
    80005c2c:	60e2                	ld	ra,24(sp)
    80005c2e:	6442                	ld	s0,16(sp)
    80005c30:	64a2                	ld	s1,8(sp)
    80005c32:	6105                	addi	sp,sp,32
    80005c34:	8082                	ret

0000000080005c36 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c36:	1141                	addi	sp,sp,-16
    80005c38:	e406                	sd	ra,8(sp)
    80005c3a:	e022                	sd	s0,0(sp)
    80005c3c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c3e:	479d                	li	a5,7
    80005c40:	04a7cc63          	blt	a5,a0,80005c98 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005c44:	0001d797          	auipc	a5,0x1d
    80005c48:	3bc78793          	addi	a5,a5,956 # 80023000 <disk>
    80005c4c:	00a78733          	add	a4,a5,a0
    80005c50:	6789                	lui	a5,0x2
    80005c52:	97ba                	add	a5,a5,a4
    80005c54:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c58:	eba1                	bnez	a5,80005ca8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005c5a:	00451713          	slli	a4,a0,0x4
    80005c5e:	0001f797          	auipc	a5,0x1f
    80005c62:	3a27b783          	ld	a5,930(a5) # 80025000 <disk+0x2000>
    80005c66:	97ba                	add	a5,a5,a4
    80005c68:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005c6c:	0001d797          	auipc	a5,0x1d
    80005c70:	39478793          	addi	a5,a5,916 # 80023000 <disk>
    80005c74:	97aa                	add	a5,a5,a0
    80005c76:	6509                	lui	a0,0x2
    80005c78:	953e                	add	a0,a0,a5
    80005c7a:	4785                	li	a5,1
    80005c7c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005c80:	0001f517          	auipc	a0,0x1f
    80005c84:	39850513          	addi	a0,a0,920 # 80025018 <disk+0x2018>
    80005c88:	ffffc097          	auipc	ra,0xffffc
    80005c8c:	6d2080e7          	jalr	1746(ra) # 8000235a <wakeup>
}
    80005c90:	60a2                	ld	ra,8(sp)
    80005c92:	6402                	ld	s0,0(sp)
    80005c94:	0141                	addi	sp,sp,16
    80005c96:	8082                	ret
    panic("virtio_disk_intr 1");
    80005c98:	00003517          	auipc	a0,0x3
    80005c9c:	ac050513          	addi	a0,a0,-1344 # 80008758 <syscalls+0x330>
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	8a2080e7          	jalr	-1886(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005ca8:	00003517          	auipc	a0,0x3
    80005cac:	ac850513          	addi	a0,a0,-1336 # 80008770 <syscalls+0x348>
    80005cb0:	ffffb097          	auipc	ra,0xffffb
    80005cb4:	892080e7          	jalr	-1902(ra) # 80000542 <panic>

0000000080005cb8 <virtio_disk_init>:
{
    80005cb8:	1101                	addi	sp,sp,-32
    80005cba:	ec06                	sd	ra,24(sp)
    80005cbc:	e822                	sd	s0,16(sp)
    80005cbe:	e426                	sd	s1,8(sp)
    80005cc0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cc2:	00003597          	auipc	a1,0x3
    80005cc6:	ac658593          	addi	a1,a1,-1338 # 80008788 <syscalls+0x360>
    80005cca:	0001f517          	auipc	a0,0x1f
    80005cce:	3de50513          	addi	a0,a0,990 # 800250a8 <disk+0x20a8>
    80005cd2:	ffffb097          	auipc	ra,0xffffb
    80005cd6:	e9c080e7          	jalr	-356(ra) # 80000b6e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cda:	100017b7          	lui	a5,0x10001
    80005cde:	4398                	lw	a4,0(a5)
    80005ce0:	2701                	sext.w	a4,a4
    80005ce2:	747277b7          	lui	a5,0x74727
    80005ce6:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005cea:	0ef71163          	bne	a4,a5,80005dcc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005cee:	100017b7          	lui	a5,0x10001
    80005cf2:	43dc                	lw	a5,4(a5)
    80005cf4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cf6:	4705                	li	a4,1
    80005cf8:	0ce79a63          	bne	a5,a4,80005dcc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cfc:	100017b7          	lui	a5,0x10001
    80005d00:	479c                	lw	a5,8(a5)
    80005d02:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d04:	4709                	li	a4,2
    80005d06:	0ce79363          	bne	a5,a4,80005dcc <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d0a:	100017b7          	lui	a5,0x10001
    80005d0e:	47d8                	lw	a4,12(a5)
    80005d10:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d12:	554d47b7          	lui	a5,0x554d4
    80005d16:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d1a:	0af71963          	bne	a4,a5,80005dcc <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d1e:	100017b7          	lui	a5,0x10001
    80005d22:	4705                	li	a4,1
    80005d24:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d26:	470d                	li	a4,3
    80005d28:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d2a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d2c:	c7ffe737          	lui	a4,0xc7ffe
    80005d30:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005d34:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d36:	2701                	sext.w	a4,a4
    80005d38:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d3a:	472d                	li	a4,11
    80005d3c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d3e:	473d                	li	a4,15
    80005d40:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d42:	6705                	lui	a4,0x1
    80005d44:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d46:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d4a:	5bdc                	lw	a5,52(a5)
    80005d4c:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d4e:	c7d9                	beqz	a5,80005ddc <virtio_disk_init+0x124>
  if(max < NUM)
    80005d50:	471d                	li	a4,7
    80005d52:	08f77d63          	bgeu	a4,a5,80005dec <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d56:	100014b7          	lui	s1,0x10001
    80005d5a:	47a1                	li	a5,8
    80005d5c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d5e:	6609                	lui	a2,0x2
    80005d60:	4581                	li	a1,0
    80005d62:	0001d517          	auipc	a0,0x1d
    80005d66:	29e50513          	addi	a0,a0,670 # 80023000 <disk>
    80005d6a:	ffffb097          	auipc	ra,0xffffb
    80005d6e:	f90080e7          	jalr	-112(ra) # 80000cfa <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d72:	0001d717          	auipc	a4,0x1d
    80005d76:	28e70713          	addi	a4,a4,654 # 80023000 <disk>
    80005d7a:	00c75793          	srli	a5,a4,0xc
    80005d7e:	2781                	sext.w	a5,a5
    80005d80:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005d82:	0001f797          	auipc	a5,0x1f
    80005d86:	27e78793          	addi	a5,a5,638 # 80025000 <disk+0x2000>
    80005d8a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005d8c:	0001d717          	auipc	a4,0x1d
    80005d90:	2f470713          	addi	a4,a4,756 # 80023080 <disk+0x80>
    80005d94:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005d96:	0001e717          	auipc	a4,0x1e
    80005d9a:	26a70713          	addi	a4,a4,618 # 80024000 <disk+0x1000>
    80005d9e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005da0:	4705                	li	a4,1
    80005da2:	00e78c23          	sb	a4,24(a5)
    80005da6:	00e78ca3          	sb	a4,25(a5)
    80005daa:	00e78d23          	sb	a4,26(a5)
    80005dae:	00e78da3          	sb	a4,27(a5)
    80005db2:	00e78e23          	sb	a4,28(a5)
    80005db6:	00e78ea3          	sb	a4,29(a5)
    80005dba:	00e78f23          	sb	a4,30(a5)
    80005dbe:	00e78fa3          	sb	a4,31(a5)
}
    80005dc2:	60e2                	ld	ra,24(sp)
    80005dc4:	6442                	ld	s0,16(sp)
    80005dc6:	64a2                	ld	s1,8(sp)
    80005dc8:	6105                	addi	sp,sp,32
    80005dca:	8082                	ret
    panic("could not find virtio disk");
    80005dcc:	00003517          	auipc	a0,0x3
    80005dd0:	9cc50513          	addi	a0,a0,-1588 # 80008798 <syscalls+0x370>
    80005dd4:	ffffa097          	auipc	ra,0xffffa
    80005dd8:	76e080e7          	jalr	1902(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    80005ddc:	00003517          	auipc	a0,0x3
    80005de0:	9dc50513          	addi	a0,a0,-1572 # 800087b8 <syscalls+0x390>
    80005de4:	ffffa097          	auipc	ra,0xffffa
    80005de8:	75e080e7          	jalr	1886(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    80005dec:	00003517          	auipc	a0,0x3
    80005df0:	9ec50513          	addi	a0,a0,-1556 # 800087d8 <syscalls+0x3b0>
    80005df4:	ffffa097          	auipc	ra,0xffffa
    80005df8:	74e080e7          	jalr	1870(ra) # 80000542 <panic>

0000000080005dfc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005dfc:	7175                	addi	sp,sp,-144
    80005dfe:	e506                	sd	ra,136(sp)
    80005e00:	e122                	sd	s0,128(sp)
    80005e02:	fca6                	sd	s1,120(sp)
    80005e04:	f8ca                	sd	s2,112(sp)
    80005e06:	f4ce                	sd	s3,104(sp)
    80005e08:	f0d2                	sd	s4,96(sp)
    80005e0a:	ecd6                	sd	s5,88(sp)
    80005e0c:	e8da                	sd	s6,80(sp)
    80005e0e:	e4de                	sd	s7,72(sp)
    80005e10:	e0e2                	sd	s8,64(sp)
    80005e12:	fc66                	sd	s9,56(sp)
    80005e14:	f86a                	sd	s10,48(sp)
    80005e16:	f46e                	sd	s11,40(sp)
    80005e18:	0900                	addi	s0,sp,144
    80005e1a:	8aaa                	mv	s5,a0
    80005e1c:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e1e:	00c52c83          	lw	s9,12(a0)
    80005e22:	001c9c9b          	slliw	s9,s9,0x1
    80005e26:	1c82                	slli	s9,s9,0x20
    80005e28:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005e2c:	0001f517          	auipc	a0,0x1f
    80005e30:	27c50513          	addi	a0,a0,636 # 800250a8 <disk+0x20a8>
    80005e34:	ffffb097          	auipc	ra,0xffffb
    80005e38:	dca080e7          	jalr	-566(ra) # 80000bfe <acquire>
  for(int i = 0; i < 3; i++){
    80005e3c:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e3e:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005e40:	0001dc17          	auipc	s8,0x1d
    80005e44:	1c0c0c13          	addi	s8,s8,448 # 80023000 <disk>
    80005e48:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005e4a:	4b0d                	li	s6,3
    80005e4c:	a0ad                	j	80005eb6 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005e4e:	00fc0733          	add	a4,s8,a5
    80005e52:	975e                	add	a4,a4,s7
    80005e54:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005e58:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005e5a:	0207c563          	bltz	a5,80005e84 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e5e:	2905                	addiw	s2,s2,1
    80005e60:	0611                	addi	a2,a2,4
    80005e62:	19690d63          	beq	s2,s6,80005ffc <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80005e66:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005e68:	0001f717          	auipc	a4,0x1f
    80005e6c:	1b070713          	addi	a4,a4,432 # 80025018 <disk+0x2018>
    80005e70:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005e72:	00074683          	lbu	a3,0(a4)
    80005e76:	fee1                	bnez	a3,80005e4e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005e78:	2785                	addiw	a5,a5,1
    80005e7a:	0705                	addi	a4,a4,1
    80005e7c:	fe979be3          	bne	a5,s1,80005e72 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005e80:	57fd                	li	a5,-1
    80005e82:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005e84:	01205d63          	blez	s2,80005e9e <virtio_disk_rw+0xa2>
    80005e88:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005e8a:	000a2503          	lw	a0,0(s4)
    80005e8e:	00000097          	auipc	ra,0x0
    80005e92:	da8080e7          	jalr	-600(ra) # 80005c36 <free_desc>
      for(int j = 0; j < i; j++)
    80005e96:	2d85                	addiw	s11,s11,1
    80005e98:	0a11                	addi	s4,s4,4
    80005e9a:	ffb918e3          	bne	s2,s11,80005e8a <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e9e:	0001f597          	auipc	a1,0x1f
    80005ea2:	20a58593          	addi	a1,a1,522 # 800250a8 <disk+0x20a8>
    80005ea6:	0001f517          	auipc	a0,0x1f
    80005eaa:	17250513          	addi	a0,a0,370 # 80025018 <disk+0x2018>
    80005eae:	ffffc097          	auipc	ra,0xffffc
    80005eb2:	32c080e7          	jalr	812(ra) # 800021da <sleep>
  for(int i = 0; i < 3; i++){
    80005eb6:	f8040a13          	addi	s4,s0,-128
{
    80005eba:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005ebc:	894e                	mv	s2,s3
    80005ebe:	b765                	j	80005e66 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005ec0:	0001f717          	auipc	a4,0x1f
    80005ec4:	14073703          	ld	a4,320(a4) # 80025000 <disk+0x2000>
    80005ec8:	973e                	add	a4,a4,a5
    80005eca:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005ece:	0001d517          	auipc	a0,0x1d
    80005ed2:	13250513          	addi	a0,a0,306 # 80023000 <disk>
    80005ed6:	0001f717          	auipc	a4,0x1f
    80005eda:	12a70713          	addi	a4,a4,298 # 80025000 <disk+0x2000>
    80005ede:	6314                	ld	a3,0(a4)
    80005ee0:	96be                	add	a3,a3,a5
    80005ee2:	00c6d603          	lhu	a2,12(a3)
    80005ee6:	00166613          	ori	a2,a2,1
    80005eea:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005eee:	f8842683          	lw	a3,-120(s0)
    80005ef2:	6310                	ld	a2,0(a4)
    80005ef4:	97b2                	add	a5,a5,a2
    80005ef6:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80005efa:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    80005efe:	0612                	slli	a2,a2,0x4
    80005f00:	962a                	add	a2,a2,a0
    80005f02:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005f06:	00469793          	slli	a5,a3,0x4
    80005f0a:	630c                	ld	a1,0(a4)
    80005f0c:	95be                	add	a1,a1,a5
    80005f0e:	6689                	lui	a3,0x2
    80005f10:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80005f14:	96ca                	add	a3,a3,s2
    80005f16:	96aa                	add	a3,a3,a0
    80005f18:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80005f1a:	6314                	ld	a3,0(a4)
    80005f1c:	96be                	add	a3,a3,a5
    80005f1e:	4585                	li	a1,1
    80005f20:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f22:	6314                	ld	a3,0(a4)
    80005f24:	96be                	add	a3,a3,a5
    80005f26:	4509                	li	a0,2
    80005f28:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80005f2c:	6314                	ld	a3,0(a4)
    80005f2e:	97b6                	add	a5,a5,a3
    80005f30:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f34:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005f38:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80005f3c:	6714                	ld	a3,8(a4)
    80005f3e:	0026d783          	lhu	a5,2(a3)
    80005f42:	8b9d                	andi	a5,a5,7
    80005f44:	0789                	addi	a5,a5,2
    80005f46:	0786                	slli	a5,a5,0x1
    80005f48:	97b6                	add	a5,a5,a3
    80005f4a:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80005f4e:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80005f52:	6718                	ld	a4,8(a4)
    80005f54:	00275783          	lhu	a5,2(a4)
    80005f58:	2785                	addiw	a5,a5,1
    80005f5a:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005f5e:	100017b7          	lui	a5,0x10001
    80005f62:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005f66:	004aa783          	lw	a5,4(s5)
    80005f6a:	02b79163          	bne	a5,a1,80005f8c <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80005f6e:	0001f917          	auipc	s2,0x1f
    80005f72:	13a90913          	addi	s2,s2,314 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80005f76:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005f78:	85ca                	mv	a1,s2
    80005f7a:	8556                	mv	a0,s5
    80005f7c:	ffffc097          	auipc	ra,0xffffc
    80005f80:	25e080e7          	jalr	606(ra) # 800021da <sleep>
  while(b->disk == 1) {
    80005f84:	004aa783          	lw	a5,4(s5)
    80005f88:	fe9788e3          	beq	a5,s1,80005f78 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80005f8c:	f8042483          	lw	s1,-128(s0)
    80005f90:	20048793          	addi	a5,s1,512
    80005f94:	00479713          	slli	a4,a5,0x4
    80005f98:	0001d797          	auipc	a5,0x1d
    80005f9c:	06878793          	addi	a5,a5,104 # 80023000 <disk>
    80005fa0:	97ba                	add	a5,a5,a4
    80005fa2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80005fa6:	0001f917          	auipc	s2,0x1f
    80005faa:	05a90913          	addi	s2,s2,90 # 80025000 <disk+0x2000>
    80005fae:	a019                	j	80005fb4 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80005fb0:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80005fb4:	8526                	mv	a0,s1
    80005fb6:	00000097          	auipc	ra,0x0
    80005fba:	c80080e7          	jalr	-896(ra) # 80005c36 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80005fbe:	0492                	slli	s1,s1,0x4
    80005fc0:	00093783          	ld	a5,0(s2)
    80005fc4:	94be                	add	s1,s1,a5
    80005fc6:	00c4d783          	lhu	a5,12(s1)
    80005fca:	8b85                	andi	a5,a5,1
    80005fcc:	f3f5                	bnez	a5,80005fb0 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005fce:	0001f517          	auipc	a0,0x1f
    80005fd2:	0da50513          	addi	a0,a0,218 # 800250a8 <disk+0x20a8>
    80005fd6:	ffffb097          	auipc	ra,0xffffb
    80005fda:	cdc080e7          	jalr	-804(ra) # 80000cb2 <release>
}
    80005fde:	60aa                	ld	ra,136(sp)
    80005fe0:	640a                	ld	s0,128(sp)
    80005fe2:	74e6                	ld	s1,120(sp)
    80005fe4:	7946                	ld	s2,112(sp)
    80005fe6:	79a6                	ld	s3,104(sp)
    80005fe8:	7a06                	ld	s4,96(sp)
    80005fea:	6ae6                	ld	s5,88(sp)
    80005fec:	6b46                	ld	s6,80(sp)
    80005fee:	6ba6                	ld	s7,72(sp)
    80005ff0:	6c06                	ld	s8,64(sp)
    80005ff2:	7ce2                	ld	s9,56(sp)
    80005ff4:	7d42                	ld	s10,48(sp)
    80005ff6:	7da2                	ld	s11,40(sp)
    80005ff8:	6149                	addi	sp,sp,144
    80005ffa:	8082                	ret
  if(write)
    80005ffc:	01a037b3          	snez	a5,s10
    80006000:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    80006004:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006008:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    8000600c:	f8042483          	lw	s1,-128(s0)
    80006010:	00449913          	slli	s2,s1,0x4
    80006014:	0001f997          	auipc	s3,0x1f
    80006018:	fec98993          	addi	s3,s3,-20 # 80025000 <disk+0x2000>
    8000601c:	0009ba03          	ld	s4,0(s3)
    80006020:	9a4a                	add	s4,s4,s2
    80006022:	f7040513          	addi	a0,s0,-144
    80006026:	ffffb097          	auipc	ra,0xffffb
    8000602a:	0a4080e7          	jalr	164(ra) # 800010ca <kvmpa>
    8000602e:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    80006032:	0009b783          	ld	a5,0(s3)
    80006036:	97ca                	add	a5,a5,s2
    80006038:	4741                	li	a4,16
    8000603a:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000603c:	0009b783          	ld	a5,0(s3)
    80006040:	97ca                	add	a5,a5,s2
    80006042:	4705                	li	a4,1
    80006044:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006048:	f8442783          	lw	a5,-124(s0)
    8000604c:	0009b703          	ld	a4,0(s3)
    80006050:	974a                	add	a4,a4,s2
    80006052:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006056:	0792                	slli	a5,a5,0x4
    80006058:	0009b703          	ld	a4,0(s3)
    8000605c:	973e                	add	a4,a4,a5
    8000605e:	058a8693          	addi	a3,s5,88
    80006062:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    80006064:	0009b703          	ld	a4,0(s3)
    80006068:	973e                	add	a4,a4,a5
    8000606a:	40000693          	li	a3,1024
    8000606e:	c714                	sw	a3,8(a4)
  if(write)
    80006070:	e40d18e3          	bnez	s10,80005ec0 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006074:	0001f717          	auipc	a4,0x1f
    80006078:	f8c73703          	ld	a4,-116(a4) # 80025000 <disk+0x2000>
    8000607c:	973e                	add	a4,a4,a5
    8000607e:	4689                	li	a3,2
    80006080:	00d71623          	sh	a3,12(a4)
    80006084:	b5a9                	j	80005ece <virtio_disk_rw+0xd2>

0000000080006086 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006086:	1101                	addi	sp,sp,-32
    80006088:	ec06                	sd	ra,24(sp)
    8000608a:	e822                	sd	s0,16(sp)
    8000608c:	e426                	sd	s1,8(sp)
    8000608e:	e04a                	sd	s2,0(sp)
    80006090:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006092:	0001f517          	auipc	a0,0x1f
    80006096:	01650513          	addi	a0,a0,22 # 800250a8 <disk+0x20a8>
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	b64080e7          	jalr	-1180(ra) # 80000bfe <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800060a2:	0001f717          	auipc	a4,0x1f
    800060a6:	f5e70713          	addi	a4,a4,-162 # 80025000 <disk+0x2000>
    800060aa:	02075783          	lhu	a5,32(a4)
    800060ae:	6b18                	ld	a4,16(a4)
    800060b0:	00275683          	lhu	a3,2(a4)
    800060b4:	8ebd                	xor	a3,a3,a5
    800060b6:	8a9d                	andi	a3,a3,7
    800060b8:	cab9                	beqz	a3,8000610e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800060ba:	0001d917          	auipc	s2,0x1d
    800060be:	f4690913          	addi	s2,s2,-186 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800060c2:	0001f497          	auipc	s1,0x1f
    800060c6:	f3e48493          	addi	s1,s1,-194 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800060ca:	078e                	slli	a5,a5,0x3
    800060cc:	97ba                	add	a5,a5,a4
    800060ce:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    800060d0:	20078713          	addi	a4,a5,512
    800060d4:	0712                	slli	a4,a4,0x4
    800060d6:	974a                	add	a4,a4,s2
    800060d8:	03074703          	lbu	a4,48(a4)
    800060dc:	ef21                	bnez	a4,80006134 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800060de:	20078793          	addi	a5,a5,512
    800060e2:	0792                	slli	a5,a5,0x4
    800060e4:	97ca                	add	a5,a5,s2
    800060e6:	7798                	ld	a4,40(a5)
    800060e8:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800060ec:	7788                	ld	a0,40(a5)
    800060ee:	ffffc097          	auipc	ra,0xffffc
    800060f2:	26c080e7          	jalr	620(ra) # 8000235a <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    800060f6:	0204d783          	lhu	a5,32(s1)
    800060fa:	2785                	addiw	a5,a5,1
    800060fc:	8b9d                	andi	a5,a5,7
    800060fe:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006102:	6898                	ld	a4,16(s1)
    80006104:	00275683          	lhu	a3,2(a4)
    80006108:	8a9d                	andi	a3,a3,7
    8000610a:	fcf690e3          	bne	a3,a5,800060ca <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000610e:	10001737          	lui	a4,0x10001
    80006112:	533c                	lw	a5,96(a4)
    80006114:	8b8d                	andi	a5,a5,3
    80006116:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006118:	0001f517          	auipc	a0,0x1f
    8000611c:	f9050513          	addi	a0,a0,-112 # 800250a8 <disk+0x20a8>
    80006120:	ffffb097          	auipc	ra,0xffffb
    80006124:	b92080e7          	jalr	-1134(ra) # 80000cb2 <release>
}
    80006128:	60e2                	ld	ra,24(sp)
    8000612a:	6442                	ld	s0,16(sp)
    8000612c:	64a2                	ld	s1,8(sp)
    8000612e:	6902                	ld	s2,0(sp)
    80006130:	6105                	addi	sp,sp,32
    80006132:	8082                	ret
      panic("virtio_disk_intr status");
    80006134:	00002517          	auipc	a0,0x2
    80006138:	6c450513          	addi	a0,a0,1732 # 800087f8 <syscalls+0x3d0>
    8000613c:	ffffa097          	auipc	ra,0xffffa
    80006140:	406080e7          	jalr	1030(ra) # 80000542 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
