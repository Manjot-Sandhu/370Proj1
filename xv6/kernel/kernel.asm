
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	32013103          	ld	sp,800(sp) # 8000a320 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb14f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	26a020ef          	jal	80002364 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	22c50513          	addi	a0,a0,556 # 80012380 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	22048493          	addi	s1,s1,544 # 80012380 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	2b090913          	addi	s2,s2,688 # 80012418 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	071010ef          	jal	800019f0 <myproc>
    80000184:	072020ef          	jal	800021f6 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	631010ef          	jal	80001fbe <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	1e070713          	addi	a4,a4,480 # 80012380 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	148020ef          	jal	8000231a <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	19650513          	addi	a0,a0,406 # 80012380 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	20f72223          	sw	a5,516(a4) # 80012418 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	15650513          	addi	a0,a0,342 # 80012380 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	10250513          	addi	a0,a0,258 # 80012380 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	10e020ef          	jal	800023ae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	0dc50513          	addi	a0,a0,220 # 80012380 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	0be70713          	addi	a4,a4,190 # 80012380 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	09878793          	addi	a5,a5,152 # 80012380 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	1027a783          	lw	a5,258(a5) # 80012418 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	05470713          	addi	a4,a4,84 # 80012380 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	04448493          	addi	s1,s1,68 # 80012380 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	00270713          	addi	a4,a4,2 # 80012380 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	08f72623          	sw	a5,140(a4) # 80012420 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	fce78793          	addi	a5,a5,-50 # 80012380 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	04c7a323          	sw	a2,70(a5) # 8001241c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	03a50513          	addi	a0,a0,58 # 80012418 <cons+0x98>
    800003e6:	425010ef          	jal	8000200a <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	f8450513          	addi	a0,a0,-124 # 80012380 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	10c78793          	addi	a5,a5,268 # 80022518 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	3d260613          	addi	a2,a2,978 # 80007818 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	f607a783          	lw	a5,-160(a5) # 80012440 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	efc50513          	addi	a0,a0,-260 # 80012428 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	12cb8b93          	addi	s7,s7,300 # 80007818 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	ca250513          	addi	a0,a0,-862 # 80012428 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	ca07a023          	sw	zero,-864(a5) # 80012440 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	86850513          	addi	a0,a0,-1944 # 80007010 <etext+0x10>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86250513          	addi	a0,a0,-1950 # 80007018 <etext+0x18>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	b6f72e23          	sw	a5,-1156(a4) # 8000a340 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	c5048493          	addi	s1,s1,-944 # 80012428 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84058593          	addi	a1,a1,-1984 # 80007020 <etext+0x20>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f058593          	addi	a1,a1,2032 # 80007028 <etext+0x28>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	c0850513          	addi	a0,a0,-1016 # 80012448 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	adc7a783          	lw	a5,-1316(a5) # 8000a340 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	aae7b783          	ld	a5,-1362(a5) # 8000a348 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	aae73703          	ld	a4,-1362(a4) # 8000a350 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	b80a8a93          	addi	s5,s5,-1152 # 80012448 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	a7848493          	addi	s1,s1,-1416 # 8000a348 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	a7498993          	addi	s3,s3,-1420 # 8000a350 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	70c010ef          	jal	8000200a <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	afc50513          	addi	a0,a0,-1284 # 80012448 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	9e87a783          	lw	a5,-1560(a5) # 8000a340 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	9ee73703          	ld	a4,-1554(a4) # 8000a350 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	9de7b783          	ld	a5,-1570(a5) # 8000a348 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	ad298993          	addi	s3,s3,-1326 # 80012448 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	9ca48493          	addi	s1,s1,-1590 # 8000a348 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	9ca90913          	addi	s2,s2,-1590 # 8000a350 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	628010ef          	jal	80001fbe <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	aa048493          	addi	s1,s1,-1376 # 80012448 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	98e7ba23          	sd	a4,-1644(a5) # 8000a350 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	a2848493          	addi	s1,s1,-1496 # 80012448 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	c5a78793          	addi	a5,a5,-934 # 800236b0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	a0e90913          	addi	s2,s2,-1522 # 80012480 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59450513          	addi	a0,a0,1428 # 80007030 <etext+0x30>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54058593          	addi	a1,a1,1344 # 80007038 <etext+0x38>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	98050513          	addi	a0,a0,-1664 # 80012480 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	ba050513          	addi	a0,a0,-1120 # 800236b0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	95248493          	addi	s1,s1,-1710 # 80012480 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	93e50513          	addi	a0,a0,-1730 # 80012480 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	91a50513          	addi	a0,a0,-1766 # 80012480 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	637000ef          	jal	800019d4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	609000ef          	jal	800019d4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	601000ef          	jal	800019d4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	5ed000ef          	jal	800019d4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	5b9000ef          	jal	800019d4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41450513          	addi	a0,a0,1044 # 80007040 <etext+0x40>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	595000ef          	jal	800019d4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3d450513          	addi	a0,a0,980 # 80007048 <etext+0x48>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e050513          	addi	a0,a0,992 # 80007060 <etext+0x60>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3ac50513          	addi	a0,a0,940 # 80007068 <etext+0x68>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb951>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	35b000ef          	jal	800019c4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	4ea70713          	addi	a4,a4,1258 # 8000a358 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	343000ef          	jal	800019c4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	20850513          	addi	a0,a0,520 # 80007090 <etext+0x90>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	648010ef          	jal	800024e0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	4dc040ef          	jal	80005378 <plicinithart>
  }

  scheduler();        
    80000ea0:	785000ef          	jal	80001e24 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1c450513          	addi	a0,a0,452 # 80007070 <etext+0x70>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c050513          	addi	a0,a0,448 # 80007078 <etext+0x78>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1ac50513          	addi	a0,a0,428 # 80007070 <etext+0x70>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	233000ef          	jal	8000190e <procinit>
    trapinit();      // trap vectors
    80000ee0:	5dc010ef          	jal	800024bc <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	5fc010ef          	jal	800024e0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	476040ef          	jal	8000535e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	48c040ef          	jal	80005378 <plicinithart>
    binit();         // buffer cache
    80000ef0:	437010ef          	jal	80002b26 <binit>
    iinit();         // inode table
    80000ef4:	228020ef          	jal	8000311c <iinit>
    fileinit();      // file table
    80000ef8:	7d5020ef          	jal	80003ecc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	56c040ef          	jal	80005468 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	559000ef          	jal	80001c58 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	44f72723          	sw	a5,1102(a4) # 8000a358 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	4427b783          	ld	a5,1090(a5) # 8000a360 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14650513          	addi	a0,a0,326 # 800070a8 <etext+0xa8>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb947>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	03850513          	addi	a0,a0,56 # 800070b0 <etext+0xb0>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	04c50513          	addi	a0,a0,76 # 800070d0 <etext+0xd0>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06050513          	addi	a0,a0,96 # 800070f0 <etext+0xf0>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06450513          	addi	a0,a0,100 # 80007100 <etext+0x100>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03050513          	addi	a0,a0,48 # 80007110 <etext+0x110>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	6ea000ef          	jal	80001876 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	1aa7bb23          	sd	a0,438(a5) # 8000a360 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f1e50513          	addi	a0,a0,-226 # 80007118 <etext+0x118>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f2a50513          	addi	a0,a0,-214 # 80007130 <etext+0x130>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f2e50513          	addi	a0,a0,-210 # 80007140 <etext+0x140>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f3a50513          	addi	a0,a0,-198 # 80007158 <etext+0x158>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8250513          	addi	a0,a0,-382 # 80007170 <etext+0x170>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d6e50513          	addi	a0,a0,-658 # 80007190 <etext+0x190>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc050513          	addi	a0,a0,-832 # 800071a0 <etext+0x1a0>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cd450513          	addi	a0,a0,-812 # 800071c0 <etext+0x1c0>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	c9a50513          	addi	a0,a0,-870 # 800071e0 <etext+0x1e0>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <showProcs>:
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

int showProcs(void){
    80001766:	7159                	addi	sp,sp,-112
    80001768:	f486                	sd	ra,104(sp)
    8000176a:	f0a2                	sd	s0,96(sp)
    8000176c:	eca6                	sd	s1,88(sp)
    8000176e:	e8ca                	sd	s2,80(sp)
    80001770:	e4ce                	sd	s3,72(sp)
    80001772:	e0d2                	sd	s4,64(sp)
    80001774:	fc56                	sd	s5,56(sp)
    80001776:	f85a                	sd	s6,48(sp)
    80001778:	f45e                	sd	s7,40(sp)
    8000177a:	f062                	sd	s8,32(sp)
    8000177c:	ec66                	sd	s9,24(sp)
    8000177e:	e86a                	sd	s10,16(sp)
    80001780:	e46e                	sd	s11,8(sp)
    80001782:	1880                	addi	s0,sp,112
	  };

	struct proc *p;
	char *state;
	
	printf("name \t pid \t state \t\t memory \t ParID \t ParName \t Open Files\n");
    80001784:	00006517          	auipc	a0,0x6
    80001788:	a7450513          	addi	a0,a0,-1420 # 800071f8 <etext+0x1f8>
    8000178c:	d37fe0ef          	jal	800004c2 <printf>
	for(p = proc; p < &proc[NPROC]; p++){
    80001790:	00011997          	auipc	s3,0x11
    80001794:	14098993          	addi	s3,s3,320 # 800128d0 <proc>
		acquire(&p->lock);
		
		state = states[p->state];

		if(p->state == RUNNING || p->state == RUNNABLE || p->state == SLEEPING){
    80001798:	4b89                	li	s7,2
		state = states[p->state];
    8000179a:	00006d97          	auipc	s11,0x6
    8000179e:	096d8d93          	addi	s11,s11,150 # 80007830 <states.2>
			int parentPid = p->parent ? p->parent->pid : 0;
			char *parentName = p->parent ? p->parent->name : "-";
			printf("%s \t %d \t %s \t %ld \t\t %d \t %s \t\t",
    800017a2:	00006d17          	auipc	s10,0x6
    800017a6:	a96d0d13          	addi	s10,s10,-1386 # 80007238 <etext+0x238>
				       	p->name, p->pid, state, p->sz, parentPid, parentName);

			printf("[");
    800017aa:	00006c97          	auipc	s9,0x6
    800017ae:	ab6c8c93          	addi	s9,s9,-1354 # 80007260 <etext+0x260>
			for(int i = 0; i < NOFILE; i++){
    800017b2:	4c01                	li	s8,0
				if(p->ofile[i]){
					printf(" FD%d ", i);
    800017b4:	00006a97          	auipc	s5,0x6
    800017b8:	ab4a8a93          	addi	s5,s5,-1356 # 80007268 <etext+0x268>
	for(p = proc; p < &proc[NPROC]; p++){
    800017bc:	00017b17          	auipc	s6,0x17
    800017c0:	b14b0b13          	addi	s6,s6,-1260 # 800182d0 <tickslock>
    800017c4:	a081                	j	80001804 <showProcs+0x9e>
			int parentPid = p->parent ? p->parent->pid : 0;
    800017c6:	87e2                	mv	a5,s8
			char *parentName = p->parent ? p->parent->name : "-";
    800017c8:	00006817          	auipc	a6,0x6
    800017cc:	a2880813          	addi	a6,a6,-1496 # 800071f0 <etext+0x1f0>
    800017d0:	a899                	j	80001826 <showProcs+0xc0>
					printf(" FD%d ", i);
    800017d2:	85a6                	mv	a1,s1
    800017d4:	8556                	mv	a0,s5
    800017d6:	cedfe0ef          	jal	800004c2 <printf>
			for(int i = 0; i < NOFILE; i++){
    800017da:	2485                	addiw	s1,s1,1 # fffffffffffff001 <end+0xffffffff7ffdb951>
    800017dc:	0921                	addi	s2,s2,8
    800017de:	01448663          	beq	s1,s4,800017ea <showProcs+0x84>
				if(p->ofile[i]){
    800017e2:	00093783          	ld	a5,0(s2)
    800017e6:	f7f5                	bnez	a5,800017d2 <showProcs+0x6c>
    800017e8:	bfcd                	j	800017da <showProcs+0x74>
				}

			}
			printf("]\n");
    800017ea:	00006517          	auipc	a0,0x6
    800017ee:	a8650513          	addi	a0,a0,-1402 # 80007270 <etext+0x270>
    800017f2:	cd1fe0ef          	jal	800004c2 <printf>
		}
		
		release(&p->lock);
    800017f6:	854e                	mv	a0,s3
    800017f8:	c94ff0ef          	jal	80000c8c <release>
	for(p = proc; p < &proc[NPROC]; p++){
    800017fc:	16898993          	addi	s3,s3,360
    80001800:	05698b63          	beq	s3,s6,80001856 <showProcs+0xf0>
		acquire(&p->lock);
    80001804:	854e                	mv	a0,s3
    80001806:	beeff0ef          	jal	80000bf4 <acquire>
		state = states[p->state];
    8000180a:	0189a703          	lw	a4,24(s3)
		if(p->state == RUNNING || p->state == RUNNABLE || p->state == SLEEPING){
    8000180e:	ffe7079b          	addiw	a5,a4,-2
    80001812:	fefbe2e3          	bltu	s7,a5,800017f6 <showProcs+0x90>
			int parentPid = p->parent ? p->parent->pid : 0;
    80001816:	0389b803          	ld	a6,56(s3)
    8000181a:	fa0806e3          	beqz	a6,800017c6 <showProcs+0x60>
    8000181e:	03082783          	lw	a5,48(a6)
			char *parentName = p->parent ? p->parent->name : "-";
    80001822:	15880813          	addi	a6,a6,344
		state = states[p->state];
    80001826:	02071693          	slli	a3,a4,0x20
    8000182a:	01d6d713          	srli	a4,a3,0x1d
    8000182e:	00ed86b3          	add	a3,s11,a4
			printf("%s \t %d \t %s \t %ld \t\t %d \t %s \t\t",
    80001832:	0489b703          	ld	a4,72(s3)
    80001836:	6294                	ld	a3,0(a3)
    80001838:	0309a603          	lw	a2,48(s3)
    8000183c:	15898593          	addi	a1,s3,344
    80001840:	856a                	mv	a0,s10
    80001842:	c81fe0ef          	jal	800004c2 <printf>
			printf("[");
    80001846:	8566                	mv	a0,s9
    80001848:	c7bfe0ef          	jal	800004c2 <printf>
			for(int i = 0; i < NOFILE; i++){
    8000184c:	0d098913          	addi	s2,s3,208
    80001850:	84e2                	mv	s1,s8
    80001852:	4a41                	li	s4,16
    80001854:	b779                	j	800017e2 <showProcs+0x7c>

	}
	return 0;
}
    80001856:	4501                	li	a0,0
    80001858:	70a6                	ld	ra,104(sp)
    8000185a:	7406                	ld	s0,96(sp)
    8000185c:	64e6                	ld	s1,88(sp)
    8000185e:	6946                	ld	s2,80(sp)
    80001860:	69a6                	ld	s3,72(sp)
    80001862:	6a06                	ld	s4,64(sp)
    80001864:	7ae2                	ld	s5,56(sp)
    80001866:	7b42                	ld	s6,48(sp)
    80001868:	7ba2                	ld	s7,40(sp)
    8000186a:	7c02                	ld	s8,32(sp)
    8000186c:	6ce2                	ld	s9,24(sp)
    8000186e:	6d42                	ld	s10,16(sp)
    80001870:	6da2                	ld	s11,8(sp)
    80001872:	6165                	addi	sp,sp,112
    80001874:	8082                	ret

0000000080001876 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001876:	7139                	addi	sp,sp,-64
    80001878:	fc06                	sd	ra,56(sp)
    8000187a:	f822                	sd	s0,48(sp)
    8000187c:	f426                	sd	s1,40(sp)
    8000187e:	f04a                	sd	s2,32(sp)
    80001880:	ec4e                	sd	s3,24(sp)
    80001882:	e852                	sd	s4,16(sp)
    80001884:	e456                	sd	s5,8(sp)
    80001886:	e05a                	sd	s6,0(sp)
    80001888:	0080                	addi	s0,sp,64
    8000188a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	00011497          	auipc	s1,0x11
    80001890:	04448493          	addi	s1,s1,68 # 800128d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001894:	8b26                	mv	s6,s1
    80001896:	04fa5937          	lui	s2,0x4fa5
    8000189a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000189e:	0932                	slli	s2,s2,0xc
    800018a0:	fa590913          	addi	s2,s2,-91
    800018a4:	0932                	slli	s2,s2,0xc
    800018a6:	fa590913          	addi	s2,s2,-91
    800018aa:	0932                	slli	s2,s2,0xc
    800018ac:	fa590913          	addi	s2,s2,-91
    800018b0:	040009b7          	lui	s3,0x4000
    800018b4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018b6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b8:	00017a97          	auipc	s5,0x17
    800018bc:	a18a8a93          	addi	s5,s5,-1512 # 800182d0 <tickslock>
    char *pa = kalloc();
    800018c0:	a64ff0ef          	jal	80000b24 <kalloc>
    800018c4:	862a                	mv	a2,a0
    if(pa == 0)
    800018c6:	cd15                	beqz	a0,80001902 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800018c8:	416485b3          	sub	a1,s1,s6
    800018cc:	858d                	srai	a1,a1,0x3
    800018ce:	032585b3          	mul	a1,a1,s2
    800018d2:	2585                	addiw	a1,a1,1
    800018d4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d8:	4719                	li	a4,6
    800018da:	6685                	lui	a3,0x1
    800018dc:	40b985b3          	sub	a1,s3,a1
    800018e0:	8552                	mv	a0,s4
    800018e2:	fe2ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e6:	16848493          	addi	s1,s1,360
    800018ea:	fd549be3          	bne	s1,s5,800018c0 <proc_mapstacks+0x4a>
  }
}
    800018ee:	70e2                	ld	ra,56(sp)
    800018f0:	7442                	ld	s0,48(sp)
    800018f2:	74a2                	ld	s1,40(sp)
    800018f4:	7902                	ld	s2,32(sp)
    800018f6:	69e2                	ld	s3,24(sp)
    800018f8:	6a42                	ld	s4,16(sp)
    800018fa:	6aa2                	ld	s5,8(sp)
    800018fc:	6b02                	ld	s6,0(sp)
    800018fe:	6121                	addi	sp,sp,64
    80001900:	8082                	ret
      panic("kalloc");
    80001902:	00006517          	auipc	a0,0x6
    80001906:	97650513          	addi	a0,a0,-1674 # 80007278 <etext+0x278>
    8000190a:	e8bfe0ef          	jal	80000794 <panic>

000000008000190e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000190e:	7139                	addi	sp,sp,-64
    80001910:	fc06                	sd	ra,56(sp)
    80001912:	f822                	sd	s0,48(sp)
    80001914:	f426                	sd	s1,40(sp)
    80001916:	f04a                	sd	s2,32(sp)
    80001918:	ec4e                	sd	s3,24(sp)
    8000191a:	e852                	sd	s4,16(sp)
    8000191c:	e456                	sd	s5,8(sp)
    8000191e:	e05a                	sd	s6,0(sp)
    80001920:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001922:	00006597          	auipc	a1,0x6
    80001926:	95e58593          	addi	a1,a1,-1698 # 80007280 <etext+0x280>
    8000192a:	00011517          	auipc	a0,0x11
    8000192e:	b7650513          	addi	a0,a0,-1162 # 800124a0 <pid_lock>
    80001932:	a42ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001936:	00006597          	auipc	a1,0x6
    8000193a:	95258593          	addi	a1,a1,-1710 # 80007288 <etext+0x288>
    8000193e:	00011517          	auipc	a0,0x11
    80001942:	b7a50513          	addi	a0,a0,-1158 # 800124b8 <wait_lock>
    80001946:	a2eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194a:	00011497          	auipc	s1,0x11
    8000194e:	f8648493          	addi	s1,s1,-122 # 800128d0 <proc>
      initlock(&p->lock, "proc");
    80001952:	00006b17          	auipc	s6,0x6
    80001956:	946b0b13          	addi	s6,s6,-1722 # 80007298 <etext+0x298>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000195a:	8aa6                	mv	s5,s1
    8000195c:	04fa5937          	lui	s2,0x4fa5
    80001960:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001964:	0932                	slli	s2,s2,0xc
    80001966:	fa590913          	addi	s2,s2,-91
    8000196a:	0932                	slli	s2,s2,0xc
    8000196c:	fa590913          	addi	s2,s2,-91
    80001970:	0932                	slli	s2,s2,0xc
    80001972:	fa590913          	addi	s2,s2,-91
    80001976:	040009b7          	lui	s3,0x4000
    8000197a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000197c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	00017a17          	auipc	s4,0x17
    80001982:	952a0a13          	addi	s4,s4,-1710 # 800182d0 <tickslock>
      initlock(&p->lock, "proc");
    80001986:	85da                	mv	a1,s6
    80001988:	8526                	mv	a0,s1
    8000198a:	9eaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000198e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001992:	415487b3          	sub	a5,s1,s5
    80001996:	878d                	srai	a5,a5,0x3
    80001998:	032787b3          	mul	a5,a5,s2
    8000199c:	2785                	addiw	a5,a5,1
    8000199e:	00d7979b          	slliw	a5,a5,0xd
    800019a2:	40f987b3          	sub	a5,s3,a5
    800019a6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	16848493          	addi	s1,s1,360
    800019ac:	fd449de3          	bne	s1,s4,80001986 <procinit+0x78>
  }
}
    800019b0:	70e2                	ld	ra,56(sp)
    800019b2:	7442                	ld	s0,48(sp)
    800019b4:	74a2                	ld	s1,40(sp)
    800019b6:	7902                	ld	s2,32(sp)
    800019b8:	69e2                	ld	s3,24(sp)
    800019ba:	6a42                	ld	s4,16(sp)
    800019bc:	6aa2                	ld	s5,8(sp)
    800019be:	6b02                	ld	s6,0(sp)
    800019c0:	6121                	addi	sp,sp,64
    800019c2:	8082                	ret

00000000800019c4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019c4:	1141                	addi	sp,sp,-16
    800019c6:	e422                	sd	s0,8(sp)
    800019c8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019ca:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019cc:	2501                	sext.w	a0,a0
    800019ce:	6422                	ld	s0,8(sp)
    800019d0:	0141                	addi	sp,sp,16
    800019d2:	8082                	ret

00000000800019d4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019d4:	1141                	addi	sp,sp,-16
    800019d6:	e422                	sd	s0,8(sp)
    800019d8:	0800                	addi	s0,sp,16
    800019da:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019dc:	2781                	sext.w	a5,a5
    800019de:	079e                	slli	a5,a5,0x7
  return c;
}
    800019e0:	00011517          	auipc	a0,0x11
    800019e4:	af050513          	addi	a0,a0,-1296 # 800124d0 <cpus>
    800019e8:	953e                	add	a0,a0,a5
    800019ea:	6422                	ld	s0,8(sp)
    800019ec:	0141                	addi	sp,sp,16
    800019ee:	8082                	ret

00000000800019f0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019f0:	1101                	addi	sp,sp,-32
    800019f2:	ec06                	sd	ra,24(sp)
    800019f4:	e822                	sd	s0,16(sp)
    800019f6:	e426                	sd	s1,8(sp)
    800019f8:	1000                	addi	s0,sp,32
  push_off();
    800019fa:	9baff0ef          	jal	80000bb4 <push_off>
    800019fe:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a00:	2781                	sext.w	a5,a5
    80001a02:	079e                	slli	a5,a5,0x7
    80001a04:	00011717          	auipc	a4,0x11
    80001a08:	a9c70713          	addi	a4,a4,-1380 # 800124a0 <pid_lock>
    80001a0c:	97ba                	add	a5,a5,a4
    80001a0e:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a10:	a28ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001a14:	8526                	mv	a0,s1
    80001a16:	60e2                	ld	ra,24(sp)
    80001a18:	6442                	ld	s0,16(sp)
    80001a1a:	64a2                	ld	s1,8(sp)
    80001a1c:	6105                	addi	sp,sp,32
    80001a1e:	8082                	ret

0000000080001a20 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a20:	1141                	addi	sp,sp,-16
    80001a22:	e406                	sd	ra,8(sp)
    80001a24:	e022                	sd	s0,0(sp)
    80001a26:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a28:	fc9ff0ef          	jal	800019f0 <myproc>
    80001a2c:	a60ff0ef          	jal	80000c8c <release>

  if (first) {
    80001a30:	00009797          	auipc	a5,0x9
    80001a34:	8a07a783          	lw	a5,-1888(a5) # 8000a2d0 <first.1>
    80001a38:	e799                	bnez	a5,80001a46 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001a3a:	2bf000ef          	jal	800024f8 <usertrapret>
}
    80001a3e:	60a2                	ld	ra,8(sp)
    80001a40:	6402                	ld	s0,0(sp)
    80001a42:	0141                	addi	sp,sp,16
    80001a44:	8082                	ret
    fsinit(ROOTDEV);
    80001a46:	4505                	li	a0,1
    80001a48:	668010ef          	jal	800030b0 <fsinit>
    first = 0;
    80001a4c:	00009797          	auipc	a5,0x9
    80001a50:	8807a223          	sw	zero,-1916(a5) # 8000a2d0 <first.1>
    __sync_synchronize();
    80001a54:	0330000f          	fence	rw,rw
    80001a58:	b7cd                	j	80001a3a <forkret+0x1a>

0000000080001a5a <allocpid>:
{
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a66:	00011917          	auipc	s2,0x11
    80001a6a:	a3a90913          	addi	s2,s2,-1478 # 800124a0 <pid_lock>
    80001a6e:	854a                	mv	a0,s2
    80001a70:	984ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001a74:	00009797          	auipc	a5,0x9
    80001a78:	86078793          	addi	a5,a5,-1952 # 8000a2d4 <nextpid>
    80001a7c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a7e:	0014871b          	addiw	a4,s1,1
    80001a82:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a84:	854a                	mv	a0,s2
    80001a86:	a06ff0ef          	jal	80000c8c <release>
}
    80001a8a:	8526                	mv	a0,s1
    80001a8c:	60e2                	ld	ra,24(sp)
    80001a8e:	6442                	ld	s0,16(sp)
    80001a90:	64a2                	ld	s1,8(sp)
    80001a92:	6902                	ld	s2,0(sp)
    80001a94:	6105                	addi	sp,sp,32
    80001a96:	8082                	ret

0000000080001a98 <proc_pagetable>:
{
    80001a98:	1101                	addi	sp,sp,-32
    80001a9a:	ec06                	sd	ra,24(sp)
    80001a9c:	e822                	sd	s0,16(sp)
    80001a9e:	e426                	sd	s1,8(sp)
    80001aa0:	e04a                	sd	s2,0(sp)
    80001aa2:	1000                	addi	s0,sp,32
    80001aa4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa6:	fd0ff0ef          	jal	80001276 <uvmcreate>
    80001aaa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aac:	cd05                	beqz	a0,80001ae4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aae:	4729                	li	a4,10
    80001ab0:	00004697          	auipc	a3,0x4
    80001ab4:	55068693          	addi	a3,a3,1360 # 80006000 <_trampoline>
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	040005b7          	lui	a1,0x4000
    80001abe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ac0:	05b2                	slli	a1,a1,0xc
    80001ac2:	d52ff0ef          	jal	80001014 <mappages>
    80001ac6:	02054663          	bltz	a0,80001af2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aca:	4719                	li	a4,6
    80001acc:	05893683          	ld	a3,88(s2)
    80001ad0:	6605                	lui	a2,0x1
    80001ad2:	020005b7          	lui	a1,0x2000
    80001ad6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ad8:	05b6                	slli	a1,a1,0xd
    80001ada:	8526                	mv	a0,s1
    80001adc:	d38ff0ef          	jal	80001014 <mappages>
    80001ae0:	00054f63          	bltz	a0,80001afe <proc_pagetable+0x66>
}
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	60e2                	ld	ra,24(sp)
    80001ae8:	6442                	ld	s0,16(sp)
    80001aea:	64a2                	ld	s1,8(sp)
    80001aec:	6902                	ld	s2,0(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret
    uvmfree(pagetable, 0);
    80001af2:	4581                	li	a1,0
    80001af4:	8526                	mv	a0,s1
    80001af6:	94fff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001afa:	4481                	li	s1,0
    80001afc:	b7e5                	j	80001ae4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001afe:	4681                	li	a3,0
    80001b00:	4605                	li	a2,1
    80001b02:	040005b7          	lui	a1,0x4000
    80001b06:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b08:	05b2                	slli	a1,a1,0xc
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	eaeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001b10:	4581                	li	a1,0
    80001b12:	8526                	mv	a0,s1
    80001b14:	931ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	b7e9                	j	80001ae4 <proc_pagetable+0x4c>

0000000080001b1c <proc_freepagetable>:
{
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
    80001b28:	84aa                	mv	s1,a0
    80001b2a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	e82ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b3c:	4681                	li	a3,0
    80001b3e:	4605                	li	a2,1
    80001b40:	020005b7          	lui	a1,0x2000
    80001b44:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b46:	05b6                	slli	a1,a1,0xd
    80001b48:	8526                	mv	a0,s1
    80001b4a:	e70ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	8526                	mv	a0,s1
    80001b52:	8f3ff0ef          	jal	80001444 <uvmfree>
}
    80001b56:	60e2                	ld	ra,24(sp)
    80001b58:	6442                	ld	s0,16(sp)
    80001b5a:	64a2                	ld	s1,8(sp)
    80001b5c:	6902                	ld	s2,0(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <freeproc>:
{
    80001b62:	1101                	addi	sp,sp,-32
    80001b64:	ec06                	sd	ra,24(sp)
    80001b66:	e822                	sd	s0,16(sp)
    80001b68:	e426                	sd	s1,8(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6e:	6d28                	ld	a0,88(a0)
    80001b70:	c119                	beqz	a0,80001b76 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001b72:	ed1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c501                	beqz	a0,80001b84 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	f9dff0ef          	jal	80001b1c <proc_freepagetable>
  p->pagetable = 0;
    80001b84:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b88:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b90:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b94:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b98:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba4:	0004ac23          	sw	zero,24(s1)
}
    80001ba8:	60e2                	ld	ra,24(sp)
    80001baa:	6442                	ld	s0,16(sp)
    80001bac:	64a2                	ld	s1,8(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <allocproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	e04a                	sd	s2,0(sp)
    80001bbc:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	00011497          	auipc	s1,0x11
    80001bc2:	d1248493          	addi	s1,s1,-750 # 800128d0 <proc>
    80001bc6:	00016917          	auipc	s2,0x16
    80001bca:	70a90913          	addi	s2,s2,1802 # 800182d0 <tickslock>
    acquire(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	824ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001bd4:	4c9c                	lw	a5,24(s1)
    80001bd6:	cb91                	beqz	a5,80001bea <allocproc+0x38>
      release(&p->lock);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	8b2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bde:	16848493          	addi	s1,s1,360
    80001be2:	ff2496e3          	bne	s1,s2,80001bce <allocproc+0x1c>
  return 0;
    80001be6:	4481                	li	s1,0
    80001be8:	a089                	j	80001c2a <allocproc+0x78>
  p->pid = allocpid();
    80001bea:	e71ff0ef          	jal	80001a5a <allocpid>
    80001bee:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bf0:	4785                	li	a5,1
    80001bf2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bf4:	f31fe0ef          	jal	80000b24 <kalloc>
    80001bf8:	892a                	mv	s2,a0
    80001bfa:	eca8                	sd	a0,88(s1)
    80001bfc:	cd15                	beqz	a0,80001c38 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bfe:	8526                	mv	a0,s1
    80001c00:	e99ff0ef          	jal	80001a98 <proc_pagetable>
    80001c04:	892a                	mv	s2,a0
    80001c06:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c08:	c121                	beqz	a0,80001c48 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001c0a:	07000613          	li	a2,112
    80001c0e:	4581                	li	a1,0
    80001c10:	06048513          	addi	a0,s1,96
    80001c14:	8b4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001c18:	00000797          	auipc	a5,0x0
    80001c1c:	e0878793          	addi	a5,a5,-504 # 80001a20 <forkret>
    80001c20:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c22:	60bc                	ld	a5,64(s1)
    80001c24:	6705                	lui	a4,0x1
    80001c26:	97ba                	add	a5,a5,a4
    80001c28:	f4bc                	sd	a5,104(s1)
}
    80001c2a:	8526                	mv	a0,s1
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
    freeproc(p);
    80001c38:	8526                	mv	a0,s1
    80001c3a:	f29ff0ef          	jal	80001b62 <freeproc>
    release(&p->lock);
    80001c3e:	8526                	mv	a0,s1
    80001c40:	84cff0ef          	jal	80000c8c <release>
    return 0;
    80001c44:	84ca                	mv	s1,s2
    80001c46:	b7d5                	j	80001c2a <allocproc+0x78>
    freeproc(p);
    80001c48:	8526                	mv	a0,s1
    80001c4a:	f19ff0ef          	jal	80001b62 <freeproc>
    release(&p->lock);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	83cff0ef          	jal	80000c8c <release>
    return 0;
    80001c54:	84ca                	mv	s1,s2
    80001c56:	bfd1                	j	80001c2a <allocproc+0x78>

0000000080001c58 <userinit>:
{
    80001c58:	1101                	addi	sp,sp,-32
    80001c5a:	ec06                	sd	ra,24(sp)
    80001c5c:	e822                	sd	s0,16(sp)
    80001c5e:	e426                	sd	s1,8(sp)
    80001c60:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c62:	f51ff0ef          	jal	80001bb2 <allocproc>
    80001c66:	84aa                	mv	s1,a0
  initproc = p;
    80001c68:	00008797          	auipc	a5,0x8
    80001c6c:	70a7b023          	sd	a0,1792(a5) # 8000a368 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c70:	03400613          	li	a2,52
    80001c74:	00008597          	auipc	a1,0x8
    80001c78:	66c58593          	addi	a1,a1,1644 # 8000a2e0 <initcode>
    80001c7c:	6928                	ld	a0,80(a0)
    80001c7e:	e1eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001c82:	6785                	lui	a5,0x1
    80001c84:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001c86:	6cb8                	ld	a4,88(s1)
    80001c88:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001c8c:	6cb8                	ld	a4,88(s1)
    80001c8e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001c90:	4641                	li	a2,16
    80001c92:	00005597          	auipc	a1,0x5
    80001c96:	60e58593          	addi	a1,a1,1550 # 800072a0 <etext+0x2a0>
    80001c9a:	15848513          	addi	a0,s1,344
    80001c9e:	968ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001ca2:	00005517          	auipc	a0,0x5
    80001ca6:	60e50513          	addi	a0,a0,1550 # 800072b0 <etext+0x2b0>
    80001caa:	515010ef          	jal	800039be <namei>
    80001cae:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cb2:	478d                	li	a5,3
    80001cb4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	fd5fe0ef          	jal	80000c8c <release>
}
    80001cbc:	60e2                	ld	ra,24(sp)
    80001cbe:	6442                	ld	s0,16(sp)
    80001cc0:	64a2                	ld	s1,8(sp)
    80001cc2:	6105                	addi	sp,sp,32
    80001cc4:	8082                	ret

0000000080001cc6 <growproc>:
{
    80001cc6:	1101                	addi	sp,sp,-32
    80001cc8:	ec06                	sd	ra,24(sp)
    80001cca:	e822                	sd	s0,16(sp)
    80001ccc:	e426                	sd	s1,8(sp)
    80001cce:	e04a                	sd	s2,0(sp)
    80001cd0:	1000                	addi	s0,sp,32
    80001cd2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001cd4:	d1dff0ef          	jal	800019f0 <myproc>
    80001cd8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001cda:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001cdc:	01204c63          	bgtz	s2,80001cf4 <growproc+0x2e>
  } else if(n < 0){
    80001ce0:	02094463          	bltz	s2,80001d08 <growproc+0x42>
  p->sz = sz;
    80001ce4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ce6:	4501                	li	a0,0
}
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6902                	ld	s2,0(sp)
    80001cf0:	6105                	addi	sp,sp,32
    80001cf2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cf4:	4691                	li	a3,4
    80001cf6:	00b90633          	add	a2,s2,a1
    80001cfa:	6928                	ld	a0,80(a0)
    80001cfc:	e42ff0ef          	jal	8000133e <uvmalloc>
    80001d00:	85aa                	mv	a1,a0
    80001d02:	f16d                	bnez	a0,80001ce4 <growproc+0x1e>
      return -1;
    80001d04:	557d                	li	a0,-1
    80001d06:	b7cd                	j	80001ce8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d08:	00b90633          	add	a2,s2,a1
    80001d0c:	6928                	ld	a0,80(a0)
    80001d0e:	decff0ef          	jal	800012fa <uvmdealloc>
    80001d12:	85aa                	mv	a1,a0
    80001d14:	bfc1                	j	80001ce4 <growproc+0x1e>

0000000080001d16 <fork>:
{
    80001d16:	7139                	addi	sp,sp,-64
    80001d18:	fc06                	sd	ra,56(sp)
    80001d1a:	f822                	sd	s0,48(sp)
    80001d1c:	f04a                	sd	s2,32(sp)
    80001d1e:	e456                	sd	s5,8(sp)
    80001d20:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d22:	ccfff0ef          	jal	800019f0 <myproc>
    80001d26:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d28:	e8bff0ef          	jal	80001bb2 <allocproc>
    80001d2c:	0e050a63          	beqz	a0,80001e20 <fork+0x10a>
    80001d30:	e852                	sd	s4,16(sp)
    80001d32:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d34:	048ab603          	ld	a2,72(s5)
    80001d38:	692c                	ld	a1,80(a0)
    80001d3a:	050ab503          	ld	a0,80(s5)
    80001d3e:	f38ff0ef          	jal	80001476 <uvmcopy>
    80001d42:	04054a63          	bltz	a0,80001d96 <fork+0x80>
    80001d46:	f426                	sd	s1,40(sp)
    80001d48:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d4a:	048ab783          	ld	a5,72(s5)
    80001d4e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d52:	058ab683          	ld	a3,88(s5)
    80001d56:	87b6                	mv	a5,a3
    80001d58:	058a3703          	ld	a4,88(s4)
    80001d5c:	12068693          	addi	a3,a3,288
    80001d60:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001d64:	6788                	ld	a0,8(a5)
    80001d66:	6b8c                	ld	a1,16(a5)
    80001d68:	6f90                	ld	a2,24(a5)
    80001d6a:	01073023          	sd	a6,0(a4)
    80001d6e:	e708                	sd	a0,8(a4)
    80001d70:	eb0c                	sd	a1,16(a4)
    80001d72:	ef10                	sd	a2,24(a4)
    80001d74:	02078793          	addi	a5,a5,32
    80001d78:	02070713          	addi	a4,a4,32
    80001d7c:	fed792e3          	bne	a5,a3,80001d60 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001d80:	058a3783          	ld	a5,88(s4)
    80001d84:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001d88:	0d0a8493          	addi	s1,s5,208
    80001d8c:	0d0a0913          	addi	s2,s4,208
    80001d90:	150a8993          	addi	s3,s5,336
    80001d94:	a831                	j	80001db0 <fork+0x9a>
    freeproc(np);
    80001d96:	8552                	mv	a0,s4
    80001d98:	dcbff0ef          	jal	80001b62 <freeproc>
    release(&np->lock);
    80001d9c:	8552                	mv	a0,s4
    80001d9e:	eeffe0ef          	jal	80000c8c <release>
    return -1;
    80001da2:	597d                	li	s2,-1
    80001da4:	6a42                	ld	s4,16(sp)
    80001da6:	a0b5                	j	80001e12 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001da8:	04a1                	addi	s1,s1,8
    80001daa:	0921                	addi	s2,s2,8
    80001dac:	01348963          	beq	s1,s3,80001dbe <fork+0xa8>
    if(p->ofile[i])
    80001db0:	6088                	ld	a0,0(s1)
    80001db2:	d97d                	beqz	a0,80001da8 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001db4:	19a020ef          	jal	80003f4e <filedup>
    80001db8:	00a93023          	sd	a0,0(s2)
    80001dbc:	b7f5                	j	80001da8 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001dbe:	150ab503          	ld	a0,336(s5)
    80001dc2:	4ec010ef          	jal	800032ae <idup>
    80001dc6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001dca:	4641                	li	a2,16
    80001dcc:	158a8593          	addi	a1,s5,344
    80001dd0:	158a0513          	addi	a0,s4,344
    80001dd4:	832ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001dd8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ddc:	8552                	mv	a0,s4
    80001dde:	eaffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001de2:	00010497          	auipc	s1,0x10
    80001de6:	6d648493          	addi	s1,s1,1750 # 800124b8 <wait_lock>
    80001dea:	8526                	mv	a0,s1
    80001dec:	e09fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001df0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	e97fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001dfa:	8552                	mv	a0,s4
    80001dfc:	df9fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001e00:	478d                	li	a5,3
    80001e02:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e06:	8552                	mv	a0,s4
    80001e08:	e85fe0ef          	jal	80000c8c <release>
  return pid;
    80001e0c:	74a2                	ld	s1,40(sp)
    80001e0e:	69e2                	ld	s3,24(sp)
    80001e10:	6a42                	ld	s4,16(sp)
}
    80001e12:	854a                	mv	a0,s2
    80001e14:	70e2                	ld	ra,56(sp)
    80001e16:	7442                	ld	s0,48(sp)
    80001e18:	7902                	ld	s2,32(sp)
    80001e1a:	6aa2                	ld	s5,8(sp)
    80001e1c:	6121                	addi	sp,sp,64
    80001e1e:	8082                	ret
    return -1;
    80001e20:	597d                	li	s2,-1
    80001e22:	bfc5                	j	80001e12 <fork+0xfc>

0000000080001e24 <scheduler>:
{
    80001e24:	715d                	addi	sp,sp,-80
    80001e26:	e486                	sd	ra,72(sp)
    80001e28:	e0a2                	sd	s0,64(sp)
    80001e2a:	fc26                	sd	s1,56(sp)
    80001e2c:	f84a                	sd	s2,48(sp)
    80001e2e:	f44e                	sd	s3,40(sp)
    80001e30:	f052                	sd	s4,32(sp)
    80001e32:	ec56                	sd	s5,24(sp)
    80001e34:	e85a                	sd	s6,16(sp)
    80001e36:	e45e                	sd	s7,8(sp)
    80001e38:	e062                	sd	s8,0(sp)
    80001e3a:	0880                	addi	s0,sp,80
    80001e3c:	8792                	mv	a5,tp
  int id = r_tp();
    80001e3e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e40:	00779b13          	slli	s6,a5,0x7
    80001e44:	00010717          	auipc	a4,0x10
    80001e48:	65c70713          	addi	a4,a4,1628 # 800124a0 <pid_lock>
    80001e4c:	975a                	add	a4,a4,s6
    80001e4e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e52:	00010717          	auipc	a4,0x10
    80001e56:	68670713          	addi	a4,a4,1670 # 800124d8 <cpus+0x8>
    80001e5a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e5c:	4c11                	li	s8,4
        c->proc = p;
    80001e5e:	079e                	slli	a5,a5,0x7
    80001e60:	00010a17          	auipc	s4,0x10
    80001e64:	640a0a13          	addi	s4,s4,1600 # 800124a0 <pid_lock>
    80001e68:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e6a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e6c:	00016997          	auipc	s3,0x16
    80001e70:	46498993          	addi	s3,s3,1124 # 800182d0 <tickslock>
    80001e74:	a0a9                	j	80001ebe <scheduler+0x9a>
      release(&p->lock);
    80001e76:	8526                	mv	a0,s1
    80001e78:	e15fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e7c:	16848493          	addi	s1,s1,360
    80001e80:	03348563          	beq	s1,s3,80001eaa <scheduler+0x86>
      acquire(&p->lock);
    80001e84:	8526                	mv	a0,s1
    80001e86:	d6ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001e8a:	4c9c                	lw	a5,24(s1)
    80001e8c:	ff2795e3          	bne	a5,s2,80001e76 <scheduler+0x52>
        p->state = RUNNING;
    80001e90:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e94:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001e98:	06048593          	addi	a1,s1,96
    80001e9c:	855a                	mv	a0,s6
    80001e9e:	5b4000ef          	jal	80002452 <swtch>
        c->proc = 0;
    80001ea2:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001ea6:	8ade                	mv	s5,s7
    80001ea8:	b7f9                	j	80001e76 <scheduler+0x52>
    if(found == 0) {
    80001eaa:	000a9a63          	bnez	s5,80001ebe <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eb2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001eb6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001eba:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ebe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ec2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ec6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001eca:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ecc:	00011497          	auipc	s1,0x11
    80001ed0:	a0448493          	addi	s1,s1,-1532 # 800128d0 <proc>
      if(p->state == RUNNABLE) {
    80001ed4:	490d                	li	s2,3
    80001ed6:	b77d                	j	80001e84 <scheduler+0x60>

0000000080001ed8 <sched>:
{
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	e84a                	sd	s2,16(sp)
    80001ee2:	e44e                	sd	s3,8(sp)
    80001ee4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ee6:	b0bff0ef          	jal	800019f0 <myproc>
    80001eea:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001eec:	c9ffe0ef          	jal	80000b8a <holding>
    80001ef0:	c92d                	beqz	a0,80001f62 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ef2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ef4:	2781                	sext.w	a5,a5
    80001ef6:	079e                	slli	a5,a5,0x7
    80001ef8:	00010717          	auipc	a4,0x10
    80001efc:	5a870713          	addi	a4,a4,1448 # 800124a0 <pid_lock>
    80001f00:	97ba                	add	a5,a5,a4
    80001f02:	0a87a703          	lw	a4,168(a5)
    80001f06:	4785                	li	a5,1
    80001f08:	06f71363          	bne	a4,a5,80001f6e <sched+0x96>
  if(p->state == RUNNING)
    80001f0c:	4c98                	lw	a4,24(s1)
    80001f0e:	4791                	li	a5,4
    80001f10:	06f70563          	beq	a4,a5,80001f7a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f14:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f18:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f1a:	e7b5                	bnez	a5,80001f86 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f1c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f1e:	00010917          	auipc	s2,0x10
    80001f22:	58290913          	addi	s2,s2,1410 # 800124a0 <pid_lock>
    80001f26:	2781                	sext.w	a5,a5
    80001f28:	079e                	slli	a5,a5,0x7
    80001f2a:	97ca                	add	a5,a5,s2
    80001f2c:	0ac7a983          	lw	s3,172(a5)
    80001f30:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f32:	2781                	sext.w	a5,a5
    80001f34:	079e                	slli	a5,a5,0x7
    80001f36:	00010597          	auipc	a1,0x10
    80001f3a:	5a258593          	addi	a1,a1,1442 # 800124d8 <cpus+0x8>
    80001f3e:	95be                	add	a1,a1,a5
    80001f40:	06048513          	addi	a0,s1,96
    80001f44:	50e000ef          	jal	80002452 <swtch>
    80001f48:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f4a:	2781                	sext.w	a5,a5
    80001f4c:	079e                	slli	a5,a5,0x7
    80001f4e:	993e                	add	s2,s2,a5
    80001f50:	0b392623          	sw	s3,172(s2)
}
    80001f54:	70a2                	ld	ra,40(sp)
    80001f56:	7402                	ld	s0,32(sp)
    80001f58:	64e2                	ld	s1,24(sp)
    80001f5a:	6942                	ld	s2,16(sp)
    80001f5c:	69a2                	ld	s3,8(sp)
    80001f5e:	6145                	addi	sp,sp,48
    80001f60:	8082                	ret
    panic("sched p->lock");
    80001f62:	00005517          	auipc	a0,0x5
    80001f66:	35650513          	addi	a0,a0,854 # 800072b8 <etext+0x2b8>
    80001f6a:	82bfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001f6e:	00005517          	auipc	a0,0x5
    80001f72:	35a50513          	addi	a0,a0,858 # 800072c8 <etext+0x2c8>
    80001f76:	81ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001f7a:	00005517          	auipc	a0,0x5
    80001f7e:	35e50513          	addi	a0,a0,862 # 800072d8 <etext+0x2d8>
    80001f82:	813fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001f86:	00005517          	auipc	a0,0x5
    80001f8a:	36250513          	addi	a0,a0,866 # 800072e8 <etext+0x2e8>
    80001f8e:	807fe0ef          	jal	80000794 <panic>

0000000080001f92 <yield>:
{
    80001f92:	1101                	addi	sp,sp,-32
    80001f94:	ec06                	sd	ra,24(sp)
    80001f96:	e822                	sd	s0,16(sp)
    80001f98:	e426                	sd	s1,8(sp)
    80001f9a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f9c:	a55ff0ef          	jal	800019f0 <myproc>
    80001fa0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001fa2:	c53fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001fa6:	478d                	li	a5,3
    80001fa8:	cc9c                	sw	a5,24(s1)
  sched();
    80001faa:	f2fff0ef          	jal	80001ed8 <sched>
  release(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	cddfe0ef          	jal	80000c8c <release>
}
    80001fb4:	60e2                	ld	ra,24(sp)
    80001fb6:	6442                	ld	s0,16(sp)
    80001fb8:	64a2                	ld	s1,8(sp)
    80001fba:	6105                	addi	sp,sp,32
    80001fbc:	8082                	ret

0000000080001fbe <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001fbe:	7179                	addi	sp,sp,-48
    80001fc0:	f406                	sd	ra,40(sp)
    80001fc2:	f022                	sd	s0,32(sp)
    80001fc4:	ec26                	sd	s1,24(sp)
    80001fc6:	e84a                	sd	s2,16(sp)
    80001fc8:	e44e                	sd	s3,8(sp)
    80001fca:	1800                	addi	s0,sp,48
    80001fcc:	89aa                	mv	s3,a0
    80001fce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001fd0:	a21ff0ef          	jal	800019f0 <myproc>
    80001fd4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001fd6:	c1ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001fda:	854a                	mv	a0,s2
    80001fdc:	cb1fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001fe0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fe4:	4789                	li	a5,2
    80001fe6:	cc9c                	sw	a5,24(s1)

  sched();
    80001fe8:	ef1ff0ef          	jal	80001ed8 <sched>

  // Tidy up.
  p->chan = 0;
    80001fec:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	c9bfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ff6:	854a                	mv	a0,s2
    80001ff8:	bfdfe0ef          	jal	80000bf4 <acquire>
}
    80001ffc:	70a2                	ld	ra,40(sp)
    80001ffe:	7402                	ld	s0,32(sp)
    80002000:	64e2                	ld	s1,24(sp)
    80002002:	6942                	ld	s2,16(sp)
    80002004:	69a2                	ld	s3,8(sp)
    80002006:	6145                	addi	sp,sp,48
    80002008:	8082                	ret

000000008000200a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000200a:	7139                	addi	sp,sp,-64
    8000200c:	fc06                	sd	ra,56(sp)
    8000200e:	f822                	sd	s0,48(sp)
    80002010:	f426                	sd	s1,40(sp)
    80002012:	f04a                	sd	s2,32(sp)
    80002014:	ec4e                	sd	s3,24(sp)
    80002016:	e852                	sd	s4,16(sp)
    80002018:	e456                	sd	s5,8(sp)
    8000201a:	0080                	addi	s0,sp,64
    8000201c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000201e:	00011497          	auipc	s1,0x11
    80002022:	8b248493          	addi	s1,s1,-1870 # 800128d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002026:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002028:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000202a:	00016917          	auipc	s2,0x16
    8000202e:	2a690913          	addi	s2,s2,678 # 800182d0 <tickslock>
    80002032:	a801                	j	80002042 <wakeup+0x38>
      }
      release(&p->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	c57fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000203a:	16848493          	addi	s1,s1,360
    8000203e:	03248263          	beq	s1,s2,80002062 <wakeup+0x58>
    if(p != myproc()){
    80002042:	9afff0ef          	jal	800019f0 <myproc>
    80002046:	fea48ae3          	beq	s1,a0,8000203a <wakeup+0x30>
      acquire(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	ba9fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002050:	4c9c                	lw	a5,24(s1)
    80002052:	ff3791e3          	bne	a5,s3,80002034 <wakeup+0x2a>
    80002056:	709c                	ld	a5,32(s1)
    80002058:	fd479ee3          	bne	a5,s4,80002034 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000205c:	0154ac23          	sw	s5,24(s1)
    80002060:	bfd1                	j	80002034 <wakeup+0x2a>
    }
  }
}
    80002062:	70e2                	ld	ra,56(sp)
    80002064:	7442                	ld	s0,48(sp)
    80002066:	74a2                	ld	s1,40(sp)
    80002068:	7902                	ld	s2,32(sp)
    8000206a:	69e2                	ld	s3,24(sp)
    8000206c:	6a42                	ld	s4,16(sp)
    8000206e:	6aa2                	ld	s5,8(sp)
    80002070:	6121                	addi	sp,sp,64
    80002072:	8082                	ret

0000000080002074 <reparent>:
{
    80002074:	7179                	addi	sp,sp,-48
    80002076:	f406                	sd	ra,40(sp)
    80002078:	f022                	sd	s0,32(sp)
    8000207a:	ec26                	sd	s1,24(sp)
    8000207c:	e84a                	sd	s2,16(sp)
    8000207e:	e44e                	sd	s3,8(sp)
    80002080:	e052                	sd	s4,0(sp)
    80002082:	1800                	addi	s0,sp,48
    80002084:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002086:	00011497          	auipc	s1,0x11
    8000208a:	84a48493          	addi	s1,s1,-1974 # 800128d0 <proc>
      pp->parent = initproc;
    8000208e:	00008a17          	auipc	s4,0x8
    80002092:	2daa0a13          	addi	s4,s4,730 # 8000a368 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002096:	00016997          	auipc	s3,0x16
    8000209a:	23a98993          	addi	s3,s3,570 # 800182d0 <tickslock>
    8000209e:	a029                	j	800020a8 <reparent+0x34>
    800020a0:	16848493          	addi	s1,s1,360
    800020a4:	01348b63          	beq	s1,s3,800020ba <reparent+0x46>
    if(pp->parent == p){
    800020a8:	7c9c                	ld	a5,56(s1)
    800020aa:	ff279be3          	bne	a5,s2,800020a0 <reparent+0x2c>
      pp->parent = initproc;
    800020ae:	000a3503          	ld	a0,0(s4)
    800020b2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800020b4:	f57ff0ef          	jal	8000200a <wakeup>
    800020b8:	b7e5                	j	800020a0 <reparent+0x2c>
}
    800020ba:	70a2                	ld	ra,40(sp)
    800020bc:	7402                	ld	s0,32(sp)
    800020be:	64e2                	ld	s1,24(sp)
    800020c0:	6942                	ld	s2,16(sp)
    800020c2:	69a2                	ld	s3,8(sp)
    800020c4:	6a02                	ld	s4,0(sp)
    800020c6:	6145                	addi	sp,sp,48
    800020c8:	8082                	ret

00000000800020ca <exit>:
{
    800020ca:	7179                	addi	sp,sp,-48
    800020cc:	f406                	sd	ra,40(sp)
    800020ce:	f022                	sd	s0,32(sp)
    800020d0:	ec26                	sd	s1,24(sp)
    800020d2:	e84a                	sd	s2,16(sp)
    800020d4:	e44e                	sd	s3,8(sp)
    800020d6:	e052                	sd	s4,0(sp)
    800020d8:	1800                	addi	s0,sp,48
    800020da:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020dc:	915ff0ef          	jal	800019f0 <myproc>
    800020e0:	89aa                	mv	s3,a0
  if(p == initproc)
    800020e2:	00008797          	auipc	a5,0x8
    800020e6:	2867b783          	ld	a5,646(a5) # 8000a368 <initproc>
    800020ea:	0d050493          	addi	s1,a0,208
    800020ee:	15050913          	addi	s2,a0,336
    800020f2:	00a79f63          	bne	a5,a0,80002110 <exit+0x46>
    panic("init exiting");
    800020f6:	00005517          	auipc	a0,0x5
    800020fa:	20a50513          	addi	a0,a0,522 # 80007300 <etext+0x300>
    800020fe:	e96fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002102:	693010ef          	jal	80003f94 <fileclose>
      p->ofile[fd] = 0;
    80002106:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000210a:	04a1                	addi	s1,s1,8
    8000210c:	01248563          	beq	s1,s2,80002116 <exit+0x4c>
    if(p->ofile[fd]){
    80002110:	6088                	ld	a0,0(s1)
    80002112:	f965                	bnez	a0,80002102 <exit+0x38>
    80002114:	bfdd                	j	8000210a <exit+0x40>
  begin_op();
    80002116:	265010ef          	jal	80003b7a <begin_op>
  iput(p->cwd);
    8000211a:	1509b503          	ld	a0,336(s3)
    8000211e:	348010ef          	jal	80003466 <iput>
  end_op();
    80002122:	2c3010ef          	jal	80003be4 <end_op>
  p->cwd = 0;
    80002126:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000212a:	00010497          	auipc	s1,0x10
    8000212e:	38e48493          	addi	s1,s1,910 # 800124b8 <wait_lock>
    80002132:	8526                	mv	a0,s1
    80002134:	ac1fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002138:	854e                	mv	a0,s3
    8000213a:	f3bff0ef          	jal	80002074 <reparent>
  wakeup(p->parent);
    8000213e:	0389b503          	ld	a0,56(s3)
    80002142:	ec9ff0ef          	jal	8000200a <wakeup>
  acquire(&p->lock);
    80002146:	854e                	mv	a0,s3
    80002148:	aadfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000214c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002150:	4795                	li	a5,5
    80002152:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002156:	8526                	mv	a0,s1
    80002158:	b35fe0ef          	jal	80000c8c <release>
  sched();
    8000215c:	d7dff0ef          	jal	80001ed8 <sched>
  panic("zombie exit");
    80002160:	00005517          	auipc	a0,0x5
    80002164:	1b050513          	addi	a0,a0,432 # 80007310 <etext+0x310>
    80002168:	e2cfe0ef          	jal	80000794 <panic>

000000008000216c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000216c:	7179                	addi	sp,sp,-48
    8000216e:	f406                	sd	ra,40(sp)
    80002170:	f022                	sd	s0,32(sp)
    80002172:	ec26                	sd	s1,24(sp)
    80002174:	e84a                	sd	s2,16(sp)
    80002176:	e44e                	sd	s3,8(sp)
    80002178:	1800                	addi	s0,sp,48
    8000217a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000217c:	00010497          	auipc	s1,0x10
    80002180:	75448493          	addi	s1,s1,1876 # 800128d0 <proc>
    80002184:	00016997          	auipc	s3,0x16
    80002188:	14c98993          	addi	s3,s3,332 # 800182d0 <tickslock>
    acquire(&p->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	a67fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002192:	589c                	lw	a5,48(s1)
    80002194:	01278b63          	beq	a5,s2,800021aa <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	af3fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000219e:	16848493          	addi	s1,s1,360
    800021a2:	ff3495e3          	bne	s1,s3,8000218c <kill+0x20>
  }
  return -1;
    800021a6:	557d                	li	a0,-1
    800021a8:	a819                	j	800021be <kill+0x52>
      p->killed = 1;
    800021aa:	4785                	li	a5,1
    800021ac:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800021ae:	4c98                	lw	a4,24(s1)
    800021b0:	4789                	li	a5,2
    800021b2:	00f70d63          	beq	a4,a5,800021cc <kill+0x60>
      release(&p->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	ad5fe0ef          	jal	80000c8c <release>
      return 0;
    800021bc:	4501                	li	a0,0
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6145                	addi	sp,sp,48
    800021ca:	8082                	ret
        p->state = RUNNABLE;
    800021cc:	478d                	li	a5,3
    800021ce:	cc9c                	sw	a5,24(s1)
    800021d0:	b7dd                	j	800021b6 <kill+0x4a>

00000000800021d2 <setkilled>:

void
setkilled(struct proc *p)
{
    800021d2:	1101                	addi	sp,sp,-32
    800021d4:	ec06                	sd	ra,24(sp)
    800021d6:	e822                	sd	s0,16(sp)
    800021d8:	e426                	sd	s1,8(sp)
    800021da:	1000                	addi	s0,sp,32
    800021dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021de:	a17fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800021e2:	4785                	li	a5,1
    800021e4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021e6:	8526                	mv	a0,s1
    800021e8:	aa5fe0ef          	jal	80000c8c <release>
}
    800021ec:	60e2                	ld	ra,24(sp)
    800021ee:	6442                	ld	s0,16(sp)
    800021f0:	64a2                	ld	s1,8(sp)
    800021f2:	6105                	addi	sp,sp,32
    800021f4:	8082                	ret

00000000800021f6 <killed>:

int
killed(struct proc *p)
{
    800021f6:	1101                	addi	sp,sp,-32
    800021f8:	ec06                	sd	ra,24(sp)
    800021fa:	e822                	sd	s0,16(sp)
    800021fc:	e426                	sd	s1,8(sp)
    800021fe:	e04a                	sd	s2,0(sp)
    80002200:	1000                	addi	s0,sp,32
    80002202:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002204:	9f1fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002208:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000220c:	8526                	mv	a0,s1
    8000220e:	a7ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002212:	854a                	mv	a0,s2
    80002214:	60e2                	ld	ra,24(sp)
    80002216:	6442                	ld	s0,16(sp)
    80002218:	64a2                	ld	s1,8(sp)
    8000221a:	6902                	ld	s2,0(sp)
    8000221c:	6105                	addi	sp,sp,32
    8000221e:	8082                	ret

0000000080002220 <wait>:
{
    80002220:	715d                	addi	sp,sp,-80
    80002222:	e486                	sd	ra,72(sp)
    80002224:	e0a2                	sd	s0,64(sp)
    80002226:	fc26                	sd	s1,56(sp)
    80002228:	f84a                	sd	s2,48(sp)
    8000222a:	f44e                	sd	s3,40(sp)
    8000222c:	f052                	sd	s4,32(sp)
    8000222e:	ec56                	sd	s5,24(sp)
    80002230:	e85a                	sd	s6,16(sp)
    80002232:	e45e                	sd	s7,8(sp)
    80002234:	e062                	sd	s8,0(sp)
    80002236:	0880                	addi	s0,sp,80
    80002238:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000223a:	fb6ff0ef          	jal	800019f0 <myproc>
    8000223e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002240:	00010517          	auipc	a0,0x10
    80002244:	27850513          	addi	a0,a0,632 # 800124b8 <wait_lock>
    80002248:	9adfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000224c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000224e:	4a15                	li	s4,5
        havekids = 1;
    80002250:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002252:	00016997          	auipc	s3,0x16
    80002256:	07e98993          	addi	s3,s3,126 # 800182d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000225a:	00010c17          	auipc	s8,0x10
    8000225e:	25ec0c13          	addi	s8,s8,606 # 800124b8 <wait_lock>
    80002262:	a871                	j	800022fe <wait+0xde>
          pid = pp->pid;
    80002264:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002268:	000b0c63          	beqz	s6,80002280 <wait+0x60>
    8000226c:	4691                	li	a3,4
    8000226e:	02c48613          	addi	a2,s1,44
    80002272:	85da                	mv	a1,s6
    80002274:	05093503          	ld	a0,80(s2)
    80002278:	adaff0ef          	jal	80001552 <copyout>
    8000227c:	02054b63          	bltz	a0,800022b2 <wait+0x92>
          freeproc(pp);
    80002280:	8526                	mv	a0,s1
    80002282:	8e1ff0ef          	jal	80001b62 <freeproc>
          release(&pp->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	a05fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000228c:	00010517          	auipc	a0,0x10
    80002290:	22c50513          	addi	a0,a0,556 # 800124b8 <wait_lock>
    80002294:	9f9fe0ef          	jal	80000c8c <release>
}
    80002298:	854e                	mv	a0,s3
    8000229a:	60a6                	ld	ra,72(sp)
    8000229c:	6406                	ld	s0,64(sp)
    8000229e:	74e2                	ld	s1,56(sp)
    800022a0:	7942                	ld	s2,48(sp)
    800022a2:	79a2                	ld	s3,40(sp)
    800022a4:	7a02                	ld	s4,32(sp)
    800022a6:	6ae2                	ld	s5,24(sp)
    800022a8:	6b42                	ld	s6,16(sp)
    800022aa:	6ba2                	ld	s7,8(sp)
    800022ac:	6c02                	ld	s8,0(sp)
    800022ae:	6161                	addi	sp,sp,80
    800022b0:	8082                	ret
            release(&pp->lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	9d9fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800022b8:	00010517          	auipc	a0,0x10
    800022bc:	20050513          	addi	a0,a0,512 # 800124b8 <wait_lock>
    800022c0:	9cdfe0ef          	jal	80000c8c <release>
            return -1;
    800022c4:	59fd                	li	s3,-1
    800022c6:	bfc9                	j	80002298 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800022c8:	16848493          	addi	s1,s1,360
    800022cc:	03348063          	beq	s1,s3,800022ec <wait+0xcc>
      if(pp->parent == p){
    800022d0:	7c9c                	ld	a5,56(s1)
    800022d2:	ff279be3          	bne	a5,s2,800022c8 <wait+0xa8>
        acquire(&pp->lock);
    800022d6:	8526                	mv	a0,s1
    800022d8:	91dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800022dc:	4c9c                	lw	a5,24(s1)
    800022de:	f94783e3          	beq	a5,s4,80002264 <wait+0x44>
        release(&pp->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	9a9fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800022e8:	8756                	mv	a4,s5
    800022ea:	bff9                	j	800022c8 <wait+0xa8>
    if(!havekids || killed(p)){
    800022ec:	cf19                	beqz	a4,8000230a <wait+0xea>
    800022ee:	854a                	mv	a0,s2
    800022f0:	f07ff0ef          	jal	800021f6 <killed>
    800022f4:	e919                	bnez	a0,8000230a <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022f6:	85e2                	mv	a1,s8
    800022f8:	854a                	mv	a0,s2
    800022fa:	cc5ff0ef          	jal	80001fbe <sleep>
    havekids = 0;
    800022fe:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002300:	00010497          	auipc	s1,0x10
    80002304:	5d048493          	addi	s1,s1,1488 # 800128d0 <proc>
    80002308:	b7e1                	j	800022d0 <wait+0xb0>
      release(&wait_lock);
    8000230a:	00010517          	auipc	a0,0x10
    8000230e:	1ae50513          	addi	a0,a0,430 # 800124b8 <wait_lock>
    80002312:	97bfe0ef          	jal	80000c8c <release>
      return -1;
    80002316:	59fd                	li	s3,-1
    80002318:	b741                	j	80002298 <wait+0x78>

000000008000231a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000231a:	7179                	addi	sp,sp,-48
    8000231c:	f406                	sd	ra,40(sp)
    8000231e:	f022                	sd	s0,32(sp)
    80002320:	ec26                	sd	s1,24(sp)
    80002322:	e84a                	sd	s2,16(sp)
    80002324:	e44e                	sd	s3,8(sp)
    80002326:	e052                	sd	s4,0(sp)
    80002328:	1800                	addi	s0,sp,48
    8000232a:	84aa                	mv	s1,a0
    8000232c:	892e                	mv	s2,a1
    8000232e:	89b2                	mv	s3,a2
    80002330:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002332:	ebeff0ef          	jal	800019f0 <myproc>
  if(user_dst){
    80002336:	cc99                	beqz	s1,80002354 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002338:	86d2                	mv	a3,s4
    8000233a:	864e                	mv	a2,s3
    8000233c:	85ca                	mv	a1,s2
    8000233e:	6928                	ld	a0,80(a0)
    80002340:	a12ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002344:	70a2                	ld	ra,40(sp)
    80002346:	7402                	ld	s0,32(sp)
    80002348:	64e2                	ld	s1,24(sp)
    8000234a:	6942                	ld	s2,16(sp)
    8000234c:	69a2                	ld	s3,8(sp)
    8000234e:	6a02                	ld	s4,0(sp)
    80002350:	6145                	addi	sp,sp,48
    80002352:	8082                	ret
    memmove((char *)dst, src, len);
    80002354:	000a061b          	sext.w	a2,s4
    80002358:	85ce                	mv	a1,s3
    8000235a:	854a                	mv	a0,s2
    8000235c:	9c9fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002360:	8526                	mv	a0,s1
    80002362:	b7cd                	j	80002344 <either_copyout+0x2a>

0000000080002364 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002364:	7179                	addi	sp,sp,-48
    80002366:	f406                	sd	ra,40(sp)
    80002368:	f022                	sd	s0,32(sp)
    8000236a:	ec26                	sd	s1,24(sp)
    8000236c:	e84a                	sd	s2,16(sp)
    8000236e:	e44e                	sd	s3,8(sp)
    80002370:	e052                	sd	s4,0(sp)
    80002372:	1800                	addi	s0,sp,48
    80002374:	892a                	mv	s2,a0
    80002376:	84ae                	mv	s1,a1
    80002378:	89b2                	mv	s3,a2
    8000237a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000237c:	e74ff0ef          	jal	800019f0 <myproc>
  if(user_src){
    80002380:	cc99                	beqz	s1,8000239e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002382:	86d2                	mv	a3,s4
    80002384:	864e                	mv	a2,s3
    80002386:	85ca                	mv	a1,s2
    80002388:	6928                	ld	a0,80(a0)
    8000238a:	a9eff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000238e:	70a2                	ld	ra,40(sp)
    80002390:	7402                	ld	s0,32(sp)
    80002392:	64e2                	ld	s1,24(sp)
    80002394:	6942                	ld	s2,16(sp)
    80002396:	69a2                	ld	s3,8(sp)
    80002398:	6a02                	ld	s4,0(sp)
    8000239a:	6145                	addi	sp,sp,48
    8000239c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000239e:	000a061b          	sext.w	a2,s4
    800023a2:	85ce                	mv	a1,s3
    800023a4:	854a                	mv	a0,s2
    800023a6:	97ffe0ef          	jal	80000d24 <memmove>
    return 0;
    800023aa:	8526                	mv	a0,s1
    800023ac:	b7cd                	j	8000238e <either_copyin+0x2a>

00000000800023ae <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800023ae:	715d                	addi	sp,sp,-80
    800023b0:	e486                	sd	ra,72(sp)
    800023b2:	e0a2                	sd	s0,64(sp)
    800023b4:	fc26                	sd	s1,56(sp)
    800023b6:	f84a                	sd	s2,48(sp)
    800023b8:	f44e                	sd	s3,40(sp)
    800023ba:	f052                	sd	s4,32(sp)
    800023bc:	ec56                	sd	s5,24(sp)
    800023be:	e85a                	sd	s6,16(sp)
    800023c0:	e45e                	sd	s7,8(sp)
    800023c2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800023c4:	00005517          	auipc	a0,0x5
    800023c8:	cac50513          	addi	a0,a0,-852 # 80007070 <etext+0x70>
    800023cc:	8f6fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d0:	00010497          	auipc	s1,0x10
    800023d4:	65848493          	addi	s1,s1,1624 # 80012a28 <proc+0x158>
    800023d8:	00016917          	auipc	s2,0x16
    800023dc:	05090913          	addi	s2,s2,80 # 80018428 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023e0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023e2:	00005997          	auipc	s3,0x5
    800023e6:	f3e98993          	addi	s3,s3,-194 # 80007320 <etext+0x320>
    printf("%d %s %s", p->pid, state, p->name);
    800023ea:	00005a97          	auipc	s5,0x5
    800023ee:	f3ea8a93          	addi	s5,s5,-194 # 80007328 <etext+0x328>
    printf("\n");
    800023f2:	00005a17          	auipc	s4,0x5
    800023f6:	c7ea0a13          	addi	s4,s4,-898 # 80007070 <etext+0x70>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023fa:	00005b97          	auipc	s7,0x5
    800023fe:	436b8b93          	addi	s7,s7,1078 # 80007830 <states.2>
    80002402:	a829                	j	8000241c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002404:	ed86a583          	lw	a1,-296(a3)
    80002408:	8556                	mv	a0,s5
    8000240a:	8b8fe0ef          	jal	800004c2 <printf>
    printf("\n");
    8000240e:	8552                	mv	a0,s4
    80002410:	8b2fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002414:	16848493          	addi	s1,s1,360
    80002418:	03248263          	beq	s1,s2,8000243c <procdump+0x8e>
    if(p->state == UNUSED)
    8000241c:	86a6                	mv	a3,s1
    8000241e:	ec04a783          	lw	a5,-320(s1)
    80002422:	dbed                	beqz	a5,80002414 <procdump+0x66>
      state = "???";
    80002424:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002426:	fcfb6fe3          	bltu	s6,a5,80002404 <procdump+0x56>
    8000242a:	02079713          	slli	a4,a5,0x20
    8000242e:	01d75793          	srli	a5,a4,0x1d
    80002432:	97de                	add	a5,a5,s7
    80002434:	7b90                	ld	a2,48(a5)
    80002436:	f679                	bnez	a2,80002404 <procdump+0x56>
      state = "???";
    80002438:	864e                	mv	a2,s3
    8000243a:	b7e9                	j	80002404 <procdump+0x56>
  }
}
    8000243c:	60a6                	ld	ra,72(sp)
    8000243e:	6406                	ld	s0,64(sp)
    80002440:	74e2                	ld	s1,56(sp)
    80002442:	7942                	ld	s2,48(sp)
    80002444:	79a2                	ld	s3,40(sp)
    80002446:	7a02                	ld	s4,32(sp)
    80002448:	6ae2                	ld	s5,24(sp)
    8000244a:	6b42                	ld	s6,16(sp)
    8000244c:	6ba2                	ld	s7,8(sp)
    8000244e:	6161                	addi	sp,sp,80
    80002450:	8082                	ret

0000000080002452 <swtch>:
    80002452:	00153023          	sd	ra,0(a0)
    80002456:	00253423          	sd	sp,8(a0)
    8000245a:	e900                	sd	s0,16(a0)
    8000245c:	ed04                	sd	s1,24(a0)
    8000245e:	03253023          	sd	s2,32(a0)
    80002462:	03353423          	sd	s3,40(a0)
    80002466:	03453823          	sd	s4,48(a0)
    8000246a:	03553c23          	sd	s5,56(a0)
    8000246e:	05653023          	sd	s6,64(a0)
    80002472:	05753423          	sd	s7,72(a0)
    80002476:	05853823          	sd	s8,80(a0)
    8000247a:	05953c23          	sd	s9,88(a0)
    8000247e:	07a53023          	sd	s10,96(a0)
    80002482:	07b53423          	sd	s11,104(a0)
    80002486:	0005b083          	ld	ra,0(a1)
    8000248a:	0085b103          	ld	sp,8(a1)
    8000248e:	6980                	ld	s0,16(a1)
    80002490:	6d84                	ld	s1,24(a1)
    80002492:	0205b903          	ld	s2,32(a1)
    80002496:	0285b983          	ld	s3,40(a1)
    8000249a:	0305ba03          	ld	s4,48(a1)
    8000249e:	0385ba83          	ld	s5,56(a1)
    800024a2:	0405bb03          	ld	s6,64(a1)
    800024a6:	0485bb83          	ld	s7,72(a1)
    800024aa:	0505bc03          	ld	s8,80(a1)
    800024ae:	0585bc83          	ld	s9,88(a1)
    800024b2:	0605bd03          	ld	s10,96(a1)
    800024b6:	0685bd83          	ld	s11,104(a1)
    800024ba:	8082                	ret

00000000800024bc <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800024bc:	1141                	addi	sp,sp,-16
    800024be:	e406                	sd	ra,8(sp)
    800024c0:	e022                	sd	s0,0(sp)
    800024c2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800024c4:	00005597          	auipc	a1,0x5
    800024c8:	ecc58593          	addi	a1,a1,-308 # 80007390 <etext+0x390>
    800024cc:	00016517          	auipc	a0,0x16
    800024d0:	e0450513          	addi	a0,a0,-508 # 800182d0 <tickslock>
    800024d4:	ea0fe0ef          	jal	80000b74 <initlock>
}
    800024d8:	60a2                	ld	ra,8(sp)
    800024da:	6402                	ld	s0,0(sp)
    800024dc:	0141                	addi	sp,sp,16
    800024de:	8082                	ret

00000000800024e0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024e0:	1141                	addi	sp,sp,-16
    800024e2:	e422                	sd	s0,8(sp)
    800024e4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024e6:	00003797          	auipc	a5,0x3
    800024ea:	e1a78793          	addi	a5,a5,-486 # 80005300 <kernelvec>
    800024ee:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024f2:	6422                	ld	s0,8(sp)
    800024f4:	0141                	addi	sp,sp,16
    800024f6:	8082                	ret

00000000800024f8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800024f8:	1141                	addi	sp,sp,-16
    800024fa:	e406                	sd	ra,8(sp)
    800024fc:	e022                	sd	s0,0(sp)
    800024fe:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002500:	cf0ff0ef          	jal	800019f0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002504:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002508:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000250a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000250e:	00004697          	auipc	a3,0x4
    80002512:	af268693          	addi	a3,a3,-1294 # 80006000 <_trampoline>
    80002516:	00004717          	auipc	a4,0x4
    8000251a:	aea70713          	addi	a4,a4,-1302 # 80006000 <_trampoline>
    8000251e:	8f15                	sub	a4,a4,a3
    80002520:	040007b7          	lui	a5,0x4000
    80002524:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002526:	07b2                	slli	a5,a5,0xc
    80002528:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000252a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000252e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002530:	18002673          	csrr	a2,satp
    80002534:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002536:	6d30                	ld	a2,88(a0)
    80002538:	6138                	ld	a4,64(a0)
    8000253a:	6585                	lui	a1,0x1
    8000253c:	972e                	add	a4,a4,a1
    8000253e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002540:	6d38                	ld	a4,88(a0)
    80002542:	00000617          	auipc	a2,0x0
    80002546:	11060613          	addi	a2,a2,272 # 80002652 <usertrap>
    8000254a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000254c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000254e:	8612                	mv	a2,tp
    80002550:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002552:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002556:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000255a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000255e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002562:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002564:	6f18                	ld	a4,24(a4)
    80002566:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000256a:	6928                	ld	a0,80(a0)
    8000256c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000256e:	00004717          	auipc	a4,0x4
    80002572:	b2e70713          	addi	a4,a4,-1234 # 8000609c <userret>
    80002576:	8f15                	sub	a4,a4,a3
    80002578:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000257a:	577d                	li	a4,-1
    8000257c:	177e                	slli	a4,a4,0x3f
    8000257e:	8d59                	or	a0,a0,a4
    80002580:	9782                	jalr	a5
}
    80002582:	60a2                	ld	ra,8(sp)
    80002584:	6402                	ld	s0,0(sp)
    80002586:	0141                	addi	sp,sp,16
    80002588:	8082                	ret

000000008000258a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000258a:	1101                	addi	sp,sp,-32
    8000258c:	ec06                	sd	ra,24(sp)
    8000258e:	e822                	sd	s0,16(sp)
    80002590:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002592:	c32ff0ef          	jal	800019c4 <cpuid>
    80002596:	cd11                	beqz	a0,800025b2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002598:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000259c:	000f4737          	lui	a4,0xf4
    800025a0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800025a4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800025a6:	14d79073          	csrw	stimecmp,a5
}
    800025aa:	60e2                	ld	ra,24(sp)
    800025ac:	6442                	ld	s0,16(sp)
    800025ae:	6105                	addi	sp,sp,32
    800025b0:	8082                	ret
    800025b2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800025b4:	00016497          	auipc	s1,0x16
    800025b8:	d1c48493          	addi	s1,s1,-740 # 800182d0 <tickslock>
    800025bc:	8526                	mv	a0,s1
    800025be:	e36fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800025c2:	00008517          	auipc	a0,0x8
    800025c6:	dae50513          	addi	a0,a0,-594 # 8000a370 <ticks>
    800025ca:	411c                	lw	a5,0(a0)
    800025cc:	2785                	addiw	a5,a5,1
    800025ce:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800025d0:	a3bff0ef          	jal	8000200a <wakeup>
    release(&tickslock);
    800025d4:	8526                	mv	a0,s1
    800025d6:	eb6fe0ef          	jal	80000c8c <release>
    800025da:	64a2                	ld	s1,8(sp)
    800025dc:	bf75                	j	80002598 <clockintr+0xe>

00000000800025de <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025de:	1101                	addi	sp,sp,-32
    800025e0:	ec06                	sd	ra,24(sp)
    800025e2:	e822                	sd	s0,16(sp)
    800025e4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025e6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025ea:	57fd                	li	a5,-1
    800025ec:	17fe                	slli	a5,a5,0x3f
    800025ee:	07a5                	addi	a5,a5,9
    800025f0:	00f70c63          	beq	a4,a5,80002608 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025f4:	57fd                	li	a5,-1
    800025f6:	17fe                	slli	a5,a5,0x3f
    800025f8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025fa:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025fc:	04f70763          	beq	a4,a5,8000264a <devintr+0x6c>
  }
}
    80002600:	60e2                	ld	ra,24(sp)
    80002602:	6442                	ld	s0,16(sp)
    80002604:	6105                	addi	sp,sp,32
    80002606:	8082                	ret
    80002608:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000260a:	5a3020ef          	jal	800053ac <plic_claim>
    8000260e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002610:	47a9                	li	a5,10
    80002612:	00f50963          	beq	a0,a5,80002624 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002616:	4785                	li	a5,1
    80002618:	00f50963          	beq	a0,a5,8000262a <devintr+0x4c>
    return 1;
    8000261c:	4505                	li	a0,1
    } else if(irq){
    8000261e:	e889                	bnez	s1,80002630 <devintr+0x52>
    80002620:	64a2                	ld	s1,8(sp)
    80002622:	bff9                	j	80002600 <devintr+0x22>
      uartintr();
    80002624:	be2fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002628:	a819                	j	8000263e <devintr+0x60>
      virtio_disk_intr();
    8000262a:	248030ef          	jal	80005872 <virtio_disk_intr>
    if(irq)
    8000262e:	a801                	j	8000263e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002630:	85a6                	mv	a1,s1
    80002632:	00005517          	auipc	a0,0x5
    80002636:	d6650513          	addi	a0,a0,-666 # 80007398 <etext+0x398>
    8000263a:	e89fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000263e:	8526                	mv	a0,s1
    80002640:	58d020ef          	jal	800053cc <plic_complete>
    return 1;
    80002644:	4505                	li	a0,1
    80002646:	64a2                	ld	s1,8(sp)
    80002648:	bf65                	j	80002600 <devintr+0x22>
    clockintr();
    8000264a:	f41ff0ef          	jal	8000258a <clockintr>
    return 2;
    8000264e:	4509                	li	a0,2
    80002650:	bf45                	j	80002600 <devintr+0x22>

0000000080002652 <usertrap>:
{
    80002652:	1101                	addi	sp,sp,-32
    80002654:	ec06                	sd	ra,24(sp)
    80002656:	e822                	sd	s0,16(sp)
    80002658:	e426                	sd	s1,8(sp)
    8000265a:	e04a                	sd	s2,0(sp)
    8000265c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002662:	1007f793          	andi	a5,a5,256
    80002666:	ef85                	bnez	a5,8000269e <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002668:	00003797          	auipc	a5,0x3
    8000266c:	c9878793          	addi	a5,a5,-872 # 80005300 <kernelvec>
    80002670:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002674:	b7cff0ef          	jal	800019f0 <myproc>
    80002678:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000267a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000267c:	14102773          	csrr	a4,sepc
    80002680:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002682:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002686:	47a1                	li	a5,8
    80002688:	02f70163          	beq	a4,a5,800026aa <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    8000268c:	f53ff0ef          	jal	800025de <devintr>
    80002690:	892a                	mv	s2,a0
    80002692:	c135                	beqz	a0,800026f6 <usertrap+0xa4>
  if(killed(p))
    80002694:	8526                	mv	a0,s1
    80002696:	b61ff0ef          	jal	800021f6 <killed>
    8000269a:	cd1d                	beqz	a0,800026d8 <usertrap+0x86>
    8000269c:	a81d                	j	800026d2 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000269e:	00005517          	auipc	a0,0x5
    800026a2:	d1a50513          	addi	a0,a0,-742 # 800073b8 <etext+0x3b8>
    800026a6:	8eefe0ef          	jal	80000794 <panic>
    if(killed(p))
    800026aa:	b4dff0ef          	jal	800021f6 <killed>
    800026ae:	e121                	bnez	a0,800026ee <usertrap+0x9c>
    p->trapframe->epc += 4;
    800026b0:	6cb8                	ld	a4,88(s1)
    800026b2:	6f1c                	ld	a5,24(a4)
    800026b4:	0791                	addi	a5,a5,4
    800026b6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026bc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026c0:	10079073          	csrw	sstatus,a5
    syscall();
    800026c4:	248000ef          	jal	8000290c <syscall>
  if(killed(p))
    800026c8:	8526                	mv	a0,s1
    800026ca:	b2dff0ef          	jal	800021f6 <killed>
    800026ce:	c901                	beqz	a0,800026de <usertrap+0x8c>
    800026d0:	4901                	li	s2,0
    exit(-1);
    800026d2:	557d                	li	a0,-1
    800026d4:	9f7ff0ef          	jal	800020ca <exit>
  if(which_dev == 2)
    800026d8:	4789                	li	a5,2
    800026da:	04f90563          	beq	s2,a5,80002724 <usertrap+0xd2>
  usertrapret();
    800026de:	e1bff0ef          	jal	800024f8 <usertrapret>
}
    800026e2:	60e2                	ld	ra,24(sp)
    800026e4:	6442                	ld	s0,16(sp)
    800026e6:	64a2                	ld	s1,8(sp)
    800026e8:	6902                	ld	s2,0(sp)
    800026ea:	6105                	addi	sp,sp,32
    800026ec:	8082                	ret
      exit(-1);
    800026ee:	557d                	li	a0,-1
    800026f0:	9dbff0ef          	jal	800020ca <exit>
    800026f4:	bf75                	j	800026b0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026f6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800026fa:	5890                	lw	a2,48(s1)
    800026fc:	00005517          	auipc	a0,0x5
    80002700:	cdc50513          	addi	a0,a0,-804 # 800073d8 <etext+0x3d8>
    80002704:	dbffd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002708:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000270c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002710:	00005517          	auipc	a0,0x5
    80002714:	cf850513          	addi	a0,a0,-776 # 80007408 <etext+0x408>
    80002718:	dabfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000271c:	8526                	mv	a0,s1
    8000271e:	ab5ff0ef          	jal	800021d2 <setkilled>
    80002722:	b75d                	j	800026c8 <usertrap+0x76>
    yield();
    80002724:	86fff0ef          	jal	80001f92 <yield>
    80002728:	bf5d                	j	800026de <usertrap+0x8c>

000000008000272a <kerneltrap>:
{
    8000272a:	7179                	addi	sp,sp,-48
    8000272c:	f406                	sd	ra,40(sp)
    8000272e:	f022                	sd	s0,32(sp)
    80002730:	ec26                	sd	s1,24(sp)
    80002732:	e84a                	sd	s2,16(sp)
    80002734:	e44e                	sd	s3,8(sp)
    80002736:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002738:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002740:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002744:	1004f793          	andi	a5,s1,256
    80002748:	c795                	beqz	a5,80002774 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000274a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000274e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002750:	eb85                	bnez	a5,80002780 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002752:	e8dff0ef          	jal	800025de <devintr>
    80002756:	c91d                	beqz	a0,8000278c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002758:	4789                	li	a5,2
    8000275a:	04f50a63          	beq	a0,a5,800027ae <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000275e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002762:	10049073          	csrw	sstatus,s1
}
    80002766:	70a2                	ld	ra,40(sp)
    80002768:	7402                	ld	s0,32(sp)
    8000276a:	64e2                	ld	s1,24(sp)
    8000276c:	6942                	ld	s2,16(sp)
    8000276e:	69a2                	ld	s3,8(sp)
    80002770:	6145                	addi	sp,sp,48
    80002772:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002774:	00005517          	auipc	a0,0x5
    80002778:	cbc50513          	addi	a0,a0,-836 # 80007430 <etext+0x430>
    8000277c:	818fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002780:	00005517          	auipc	a0,0x5
    80002784:	cd850513          	addi	a0,a0,-808 # 80007458 <etext+0x458>
    80002788:	80cfe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000278c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002790:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002794:	85ce                	mv	a1,s3
    80002796:	00005517          	auipc	a0,0x5
    8000279a:	ce250513          	addi	a0,a0,-798 # 80007478 <etext+0x478>
    8000279e:	d25fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    800027a2:	00005517          	auipc	a0,0x5
    800027a6:	cfe50513          	addi	a0,a0,-770 # 800074a0 <etext+0x4a0>
    800027aa:	febfd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    800027ae:	a42ff0ef          	jal	800019f0 <myproc>
    800027b2:	d555                	beqz	a0,8000275e <kerneltrap+0x34>
    yield();
    800027b4:	fdeff0ef          	jal	80001f92 <yield>
    800027b8:	b75d                	j	8000275e <kerneltrap+0x34>

00000000800027ba <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027ba:	1101                	addi	sp,sp,-32
    800027bc:	ec06                	sd	ra,24(sp)
    800027be:	e822                	sd	s0,16(sp)
    800027c0:	e426                	sd	s1,8(sp)
    800027c2:	1000                	addi	s0,sp,32
    800027c4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027c6:	a2aff0ef          	jal	800019f0 <myproc>
  switch (n) {
    800027ca:	4795                	li	a5,5
    800027cc:	0497e163          	bltu	a5,s1,8000280e <argraw+0x54>
    800027d0:	048a                	slli	s1,s1,0x2
    800027d2:	00005717          	auipc	a4,0x5
    800027d6:	0be70713          	addi	a4,a4,190 # 80007890 <states.0+0x30>
    800027da:	94ba                	add	s1,s1,a4
    800027dc:	409c                	lw	a5,0(s1)
    800027de:	97ba                	add	a5,a5,a4
    800027e0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027e2:	6d3c                	ld	a5,88(a0)
    800027e4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	64a2                	ld	s1,8(sp)
    800027ec:	6105                	addi	sp,sp,32
    800027ee:	8082                	ret
    return p->trapframe->a1;
    800027f0:	6d3c                	ld	a5,88(a0)
    800027f2:	7fa8                	ld	a0,120(a5)
    800027f4:	bfcd                	j	800027e6 <argraw+0x2c>
    return p->trapframe->a2;
    800027f6:	6d3c                	ld	a5,88(a0)
    800027f8:	63c8                	ld	a0,128(a5)
    800027fa:	b7f5                	j	800027e6 <argraw+0x2c>
    return p->trapframe->a3;
    800027fc:	6d3c                	ld	a5,88(a0)
    800027fe:	67c8                	ld	a0,136(a5)
    80002800:	b7dd                	j	800027e6 <argraw+0x2c>
    return p->trapframe->a4;
    80002802:	6d3c                	ld	a5,88(a0)
    80002804:	6bc8                	ld	a0,144(a5)
    80002806:	b7c5                	j	800027e6 <argraw+0x2c>
    return p->trapframe->a5;
    80002808:	6d3c                	ld	a5,88(a0)
    8000280a:	6fc8                	ld	a0,152(a5)
    8000280c:	bfe9                	j	800027e6 <argraw+0x2c>
  panic("argraw");
    8000280e:	00005517          	auipc	a0,0x5
    80002812:	ca250513          	addi	a0,a0,-862 # 800074b0 <etext+0x4b0>
    80002816:	f7ffd0ef          	jal	80000794 <panic>

000000008000281a <fetchaddr>:
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	e04a                	sd	s2,0(sp)
    80002824:	1000                	addi	s0,sp,32
    80002826:	84aa                	mv	s1,a0
    80002828:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000282a:	9c6ff0ef          	jal	800019f0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000282e:	653c                	ld	a5,72(a0)
    80002830:	02f4f663          	bgeu	s1,a5,8000285c <fetchaddr+0x42>
    80002834:	00848713          	addi	a4,s1,8
    80002838:	02e7e463          	bltu	a5,a4,80002860 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000283c:	46a1                	li	a3,8
    8000283e:	8626                	mv	a2,s1
    80002840:	85ca                	mv	a1,s2
    80002842:	6928                	ld	a0,80(a0)
    80002844:	de5fe0ef          	jal	80001628 <copyin>
    80002848:	00a03533          	snez	a0,a0
    8000284c:	40a00533          	neg	a0,a0
}
    80002850:	60e2                	ld	ra,24(sp)
    80002852:	6442                	ld	s0,16(sp)
    80002854:	64a2                	ld	s1,8(sp)
    80002856:	6902                	ld	s2,0(sp)
    80002858:	6105                	addi	sp,sp,32
    8000285a:	8082                	ret
    return -1;
    8000285c:	557d                	li	a0,-1
    8000285e:	bfcd                	j	80002850 <fetchaddr+0x36>
    80002860:	557d                	li	a0,-1
    80002862:	b7fd                	j	80002850 <fetchaddr+0x36>

0000000080002864 <fetchstr>:
{
    80002864:	7179                	addi	sp,sp,-48
    80002866:	f406                	sd	ra,40(sp)
    80002868:	f022                	sd	s0,32(sp)
    8000286a:	ec26                	sd	s1,24(sp)
    8000286c:	e84a                	sd	s2,16(sp)
    8000286e:	e44e                	sd	s3,8(sp)
    80002870:	1800                	addi	s0,sp,48
    80002872:	892a                	mv	s2,a0
    80002874:	84ae                	mv	s1,a1
    80002876:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002878:	978ff0ef          	jal	800019f0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000287c:	86ce                	mv	a3,s3
    8000287e:	864a                	mv	a2,s2
    80002880:	85a6                	mv	a1,s1
    80002882:	6928                	ld	a0,80(a0)
    80002884:	e2bfe0ef          	jal	800016ae <copyinstr>
    80002888:	00054c63          	bltz	a0,800028a0 <fetchstr+0x3c>
  return strlen(buf);
    8000288c:	8526                	mv	a0,s1
    8000288e:	daafe0ef          	jal	80000e38 <strlen>
}
    80002892:	70a2                	ld	ra,40(sp)
    80002894:	7402                	ld	s0,32(sp)
    80002896:	64e2                	ld	s1,24(sp)
    80002898:	6942                	ld	s2,16(sp)
    8000289a:	69a2                	ld	s3,8(sp)
    8000289c:	6145                	addi	sp,sp,48
    8000289e:	8082                	ret
    return -1;
    800028a0:	557d                	li	a0,-1
    800028a2:	bfc5                	j	80002892 <fetchstr+0x2e>

00000000800028a4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800028a4:	1101                	addi	sp,sp,-32
    800028a6:	ec06                	sd	ra,24(sp)
    800028a8:	e822                	sd	s0,16(sp)
    800028aa:	e426                	sd	s1,8(sp)
    800028ac:	1000                	addi	s0,sp,32
    800028ae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b0:	f0bff0ef          	jal	800027ba <argraw>
    800028b4:	c088                	sw	a0,0(s1)
}
    800028b6:	60e2                	ld	ra,24(sp)
    800028b8:	6442                	ld	s0,16(sp)
    800028ba:	64a2                	ld	s1,8(sp)
    800028bc:	6105                	addi	sp,sp,32
    800028be:	8082                	ret

00000000800028c0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028c0:	1101                	addi	sp,sp,-32
    800028c2:	ec06                	sd	ra,24(sp)
    800028c4:	e822                	sd	s0,16(sp)
    800028c6:	e426                	sd	s1,8(sp)
    800028c8:	1000                	addi	s0,sp,32
    800028ca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028cc:	eefff0ef          	jal	800027ba <argraw>
    800028d0:	e088                	sd	a0,0(s1)
}
    800028d2:	60e2                	ld	ra,24(sp)
    800028d4:	6442                	ld	s0,16(sp)
    800028d6:	64a2                	ld	s1,8(sp)
    800028d8:	6105                	addi	sp,sp,32
    800028da:	8082                	ret

00000000800028dc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028dc:	7179                	addi	sp,sp,-48
    800028de:	f406                	sd	ra,40(sp)
    800028e0:	f022                	sd	s0,32(sp)
    800028e2:	ec26                	sd	s1,24(sp)
    800028e4:	e84a                	sd	s2,16(sp)
    800028e6:	1800                	addi	s0,sp,48
    800028e8:	84ae                	mv	s1,a1
    800028ea:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800028ec:	fd840593          	addi	a1,s0,-40
    800028f0:	fd1ff0ef          	jal	800028c0 <argaddr>
  return fetchstr(addr, buf, max);
    800028f4:	864a                	mv	a2,s2
    800028f6:	85a6                	mv	a1,s1
    800028f8:	fd843503          	ld	a0,-40(s0)
    800028fc:	f69ff0ef          	jal	80002864 <fetchstr>
}
    80002900:	70a2                	ld	ra,40(sp)
    80002902:	7402                	ld	s0,32(sp)
    80002904:	64e2                	ld	s1,24(sp)
    80002906:	6942                	ld	s2,16(sp)
    80002908:	6145                	addi	sp,sp,48
    8000290a:	8082                	ret

000000008000290c <syscall>:
[SYS_showProcs] sys_showProcs,
};

void
syscall(void)
{
    8000290c:	1101                	addi	sp,sp,-32
    8000290e:	ec06                	sd	ra,24(sp)
    80002910:	e822                	sd	s0,16(sp)
    80002912:	e426                	sd	s1,8(sp)
    80002914:	e04a                	sd	s2,0(sp)
    80002916:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002918:	8d8ff0ef          	jal	800019f0 <myproc>
    8000291c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000291e:	05853903          	ld	s2,88(a0)
    80002922:	0a893783          	ld	a5,168(s2)
    80002926:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000292a:	37fd                	addiw	a5,a5,-1
    8000292c:	4755                	li	a4,21
    8000292e:	00f76f63          	bltu	a4,a5,8000294c <syscall+0x40>
    80002932:	00369713          	slli	a4,a3,0x3
    80002936:	00005797          	auipc	a5,0x5
    8000293a:	f7278793          	addi	a5,a5,-142 # 800078a8 <syscalls>
    8000293e:	97ba                	add	a5,a5,a4
    80002940:	639c                	ld	a5,0(a5)
    80002942:	c789                	beqz	a5,8000294c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002944:	9782                	jalr	a5
    80002946:	06a93823          	sd	a0,112(s2)
    8000294a:	a829                	j	80002964 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000294c:	15848613          	addi	a2,s1,344
    80002950:	588c                	lw	a1,48(s1)
    80002952:	00005517          	auipc	a0,0x5
    80002956:	b6650513          	addi	a0,a0,-1178 # 800074b8 <etext+0x4b8>
    8000295a:	b69fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000295e:	6cbc                	ld	a5,88(s1)
    80002960:	577d                	li	a4,-1
    80002962:	fbb8                	sd	a4,112(a5)
  }
}
    80002964:	60e2                	ld	ra,24(sp)
    80002966:	6442                	ld	s0,16(sp)
    80002968:	64a2                	ld	s1,8(sp)
    8000296a:	6902                	ld	s2,0(sp)
    8000296c:	6105                	addi	sp,sp,32
    8000296e:	8082                	ret

0000000080002970 <sys_showProcs>:
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_showProcs(void){
    80002970:	1141                	addi	sp,sp,-16
    80002972:	e406                	sd	ra,8(sp)
    80002974:	e022                	sd	s0,0(sp)
    80002976:	0800                	addi	s0,sp,16
	return showProcs();
    80002978:	deffe0ef          	jal	80001766 <showProcs>
}
    8000297c:	60a2                	ld	ra,8(sp)
    8000297e:	6402                	ld	s0,0(sp)
    80002980:	0141                	addi	sp,sp,16
    80002982:	8082                	ret

0000000080002984 <sys_exit>:
uint64
sys_exit(void)
{
    80002984:	1101                	addi	sp,sp,-32
    80002986:	ec06                	sd	ra,24(sp)
    80002988:	e822                	sd	s0,16(sp)
    8000298a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000298c:	fec40593          	addi	a1,s0,-20
    80002990:	4501                	li	a0,0
    80002992:	f13ff0ef          	jal	800028a4 <argint>
  exit(n);
    80002996:	fec42503          	lw	a0,-20(s0)
    8000299a:	f30ff0ef          	jal	800020ca <exit>
  return 0;  // not reached
}
    8000299e:	4501                	li	a0,0
    800029a0:	60e2                	ld	ra,24(sp)
    800029a2:	6442                	ld	s0,16(sp)
    800029a4:	6105                	addi	sp,sp,32
    800029a6:	8082                	ret

00000000800029a8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800029a8:	1141                	addi	sp,sp,-16
    800029aa:	e406                	sd	ra,8(sp)
    800029ac:	e022                	sd	s0,0(sp)
    800029ae:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029b0:	840ff0ef          	jal	800019f0 <myproc>
}
    800029b4:	5908                	lw	a0,48(a0)
    800029b6:	60a2                	ld	ra,8(sp)
    800029b8:	6402                	ld	s0,0(sp)
    800029ba:	0141                	addi	sp,sp,16
    800029bc:	8082                	ret

00000000800029be <sys_fork>:

uint64
sys_fork(void)
{
    800029be:	1141                	addi	sp,sp,-16
    800029c0:	e406                	sd	ra,8(sp)
    800029c2:	e022                	sd	s0,0(sp)
    800029c4:	0800                	addi	s0,sp,16
  return fork();
    800029c6:	b50ff0ef          	jal	80001d16 <fork>
}
    800029ca:	60a2                	ld	ra,8(sp)
    800029cc:	6402                	ld	s0,0(sp)
    800029ce:	0141                	addi	sp,sp,16
    800029d0:	8082                	ret

00000000800029d2 <sys_wait>:

uint64
sys_wait(void)
{
    800029d2:	1101                	addi	sp,sp,-32
    800029d4:	ec06                	sd	ra,24(sp)
    800029d6:	e822                	sd	s0,16(sp)
    800029d8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029da:	fe840593          	addi	a1,s0,-24
    800029de:	4501                	li	a0,0
    800029e0:	ee1ff0ef          	jal	800028c0 <argaddr>
  return wait(p);
    800029e4:	fe843503          	ld	a0,-24(s0)
    800029e8:	839ff0ef          	jal	80002220 <wait>
}
    800029ec:	60e2                	ld	ra,24(sp)
    800029ee:	6442                	ld	s0,16(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret

00000000800029f4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029f4:	7179                	addi	sp,sp,-48
    800029f6:	f406                	sd	ra,40(sp)
    800029f8:	f022                	sd	s0,32(sp)
    800029fa:	ec26                	sd	s1,24(sp)
    800029fc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800029fe:	fdc40593          	addi	a1,s0,-36
    80002a02:	4501                	li	a0,0
    80002a04:	ea1ff0ef          	jal	800028a4 <argint>
  addr = myproc()->sz;
    80002a08:	fe9fe0ef          	jal	800019f0 <myproc>
    80002a0c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002a0e:	fdc42503          	lw	a0,-36(s0)
    80002a12:	ab4ff0ef          	jal	80001cc6 <growproc>
    80002a16:	00054863          	bltz	a0,80002a26 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	70a2                	ld	ra,40(sp)
    80002a1e:	7402                	ld	s0,32(sp)
    80002a20:	64e2                	ld	s1,24(sp)
    80002a22:	6145                	addi	sp,sp,48
    80002a24:	8082                	ret
    return -1;
    80002a26:	54fd                	li	s1,-1
    80002a28:	bfcd                	j	80002a1a <sys_sbrk+0x26>

0000000080002a2a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002a2a:	7139                	addi	sp,sp,-64
    80002a2c:	fc06                	sd	ra,56(sp)
    80002a2e:	f822                	sd	s0,48(sp)
    80002a30:	f04a                	sd	s2,32(sp)
    80002a32:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a34:	fcc40593          	addi	a1,s0,-52
    80002a38:	4501                	li	a0,0
    80002a3a:	e6bff0ef          	jal	800028a4 <argint>
  if(n < 0)
    80002a3e:	fcc42783          	lw	a5,-52(s0)
    80002a42:	0607c763          	bltz	a5,80002ab0 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002a46:	00016517          	auipc	a0,0x16
    80002a4a:	88a50513          	addi	a0,a0,-1910 # 800182d0 <tickslock>
    80002a4e:	9a6fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002a52:	00008917          	auipc	s2,0x8
    80002a56:	91e92903          	lw	s2,-1762(s2) # 8000a370 <ticks>
  while(ticks - ticks0 < n){
    80002a5a:	fcc42783          	lw	a5,-52(s0)
    80002a5e:	cf8d                	beqz	a5,80002a98 <sys_sleep+0x6e>
    80002a60:	f426                	sd	s1,40(sp)
    80002a62:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a64:	00016997          	auipc	s3,0x16
    80002a68:	86c98993          	addi	s3,s3,-1940 # 800182d0 <tickslock>
    80002a6c:	00008497          	auipc	s1,0x8
    80002a70:	90448493          	addi	s1,s1,-1788 # 8000a370 <ticks>
    if(killed(myproc())){
    80002a74:	f7dfe0ef          	jal	800019f0 <myproc>
    80002a78:	f7eff0ef          	jal	800021f6 <killed>
    80002a7c:	ed0d                	bnez	a0,80002ab6 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002a7e:	85ce                	mv	a1,s3
    80002a80:	8526                	mv	a0,s1
    80002a82:	d3cff0ef          	jal	80001fbe <sleep>
  while(ticks - ticks0 < n){
    80002a86:	409c                	lw	a5,0(s1)
    80002a88:	412787bb          	subw	a5,a5,s2
    80002a8c:	fcc42703          	lw	a4,-52(s0)
    80002a90:	fee7e2e3          	bltu	a5,a4,80002a74 <sys_sleep+0x4a>
    80002a94:	74a2                	ld	s1,40(sp)
    80002a96:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a98:	00016517          	auipc	a0,0x16
    80002a9c:	83850513          	addi	a0,a0,-1992 # 800182d0 <tickslock>
    80002aa0:	9ecfe0ef          	jal	80000c8c <release>
  return 0;
    80002aa4:	4501                	li	a0,0
}
    80002aa6:	70e2                	ld	ra,56(sp)
    80002aa8:	7442                	ld	s0,48(sp)
    80002aaa:	7902                	ld	s2,32(sp)
    80002aac:	6121                	addi	sp,sp,64
    80002aae:	8082                	ret
    n = 0;
    80002ab0:	fc042623          	sw	zero,-52(s0)
    80002ab4:	bf49                	j	80002a46 <sys_sleep+0x1c>
      release(&tickslock);
    80002ab6:	00016517          	auipc	a0,0x16
    80002aba:	81a50513          	addi	a0,a0,-2022 # 800182d0 <tickslock>
    80002abe:	9cefe0ef          	jal	80000c8c <release>
      return -1;
    80002ac2:	557d                	li	a0,-1
    80002ac4:	74a2                	ld	s1,40(sp)
    80002ac6:	69e2                	ld	s3,24(sp)
    80002ac8:	bff9                	j	80002aa6 <sys_sleep+0x7c>

0000000080002aca <sys_kill>:

uint64
sys_kill(void)
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ad2:	fec40593          	addi	a1,s0,-20
    80002ad6:	4501                	li	a0,0
    80002ad8:	dcdff0ef          	jal	800028a4 <argint>
  return kill(pid);
    80002adc:	fec42503          	lw	a0,-20(s0)
    80002ae0:	e8cff0ef          	jal	8000216c <kill>
}
    80002ae4:	60e2                	ld	ra,24(sp)
    80002ae6:	6442                	ld	s0,16(sp)
    80002ae8:	6105                	addi	sp,sp,32
    80002aea:	8082                	ret

0000000080002aec <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002aec:	1101                	addi	sp,sp,-32
    80002aee:	ec06                	sd	ra,24(sp)
    80002af0:	e822                	sd	s0,16(sp)
    80002af2:	e426                	sd	s1,8(sp)
    80002af4:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002af6:	00015517          	auipc	a0,0x15
    80002afa:	7da50513          	addi	a0,a0,2010 # 800182d0 <tickslock>
    80002afe:	8f6fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002b02:	00008497          	auipc	s1,0x8
    80002b06:	86e4a483          	lw	s1,-1938(s1) # 8000a370 <ticks>
  release(&tickslock);
    80002b0a:	00015517          	auipc	a0,0x15
    80002b0e:	7c650513          	addi	a0,a0,1990 # 800182d0 <tickslock>
    80002b12:	97afe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002b16:	02049513          	slli	a0,s1,0x20
    80002b1a:	9101                	srli	a0,a0,0x20
    80002b1c:	60e2                	ld	ra,24(sp)
    80002b1e:	6442                	ld	s0,16(sp)
    80002b20:	64a2                	ld	s1,8(sp)
    80002b22:	6105                	addi	sp,sp,32
    80002b24:	8082                	ret

0000000080002b26 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b26:	7179                	addi	sp,sp,-48
    80002b28:	f406                	sd	ra,40(sp)
    80002b2a:	f022                	sd	s0,32(sp)
    80002b2c:	ec26                	sd	s1,24(sp)
    80002b2e:	e84a                	sd	s2,16(sp)
    80002b30:	e44e                	sd	s3,8(sp)
    80002b32:	e052                	sd	s4,0(sp)
    80002b34:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b36:	00005597          	auipc	a1,0x5
    80002b3a:	9a258593          	addi	a1,a1,-1630 # 800074d8 <etext+0x4d8>
    80002b3e:	00015517          	auipc	a0,0x15
    80002b42:	7aa50513          	addi	a0,a0,1962 # 800182e8 <bcache>
    80002b46:	82efe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b4a:	0001d797          	auipc	a5,0x1d
    80002b4e:	79e78793          	addi	a5,a5,1950 # 800202e8 <bcache+0x8000>
    80002b52:	0001e717          	auipc	a4,0x1e
    80002b56:	9fe70713          	addi	a4,a4,-1538 # 80020550 <bcache+0x8268>
    80002b5a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b5e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b62:	00015497          	auipc	s1,0x15
    80002b66:	79e48493          	addi	s1,s1,1950 # 80018300 <bcache+0x18>
    b->next = bcache.head.next;
    80002b6a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b6c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b6e:	00005a17          	auipc	s4,0x5
    80002b72:	972a0a13          	addi	s4,s4,-1678 # 800074e0 <etext+0x4e0>
    b->next = bcache.head.next;
    80002b76:	2b893783          	ld	a5,696(s2)
    80002b7a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b7c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b80:	85d2                	mv	a1,s4
    80002b82:	01048513          	addi	a0,s1,16
    80002b86:	248010ef          	jal	80003dce <initsleeplock>
    bcache.head.next->prev = b;
    80002b8a:	2b893783          	ld	a5,696(s2)
    80002b8e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b90:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b94:	45848493          	addi	s1,s1,1112
    80002b98:	fd349fe3          	bne	s1,s3,80002b76 <binit+0x50>
  }
}
    80002b9c:	70a2                	ld	ra,40(sp)
    80002b9e:	7402                	ld	s0,32(sp)
    80002ba0:	64e2                	ld	s1,24(sp)
    80002ba2:	6942                	ld	s2,16(sp)
    80002ba4:	69a2                	ld	s3,8(sp)
    80002ba6:	6a02                	ld	s4,0(sp)
    80002ba8:	6145                	addi	sp,sp,48
    80002baa:	8082                	ret

0000000080002bac <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bac:	7179                	addi	sp,sp,-48
    80002bae:	f406                	sd	ra,40(sp)
    80002bb0:	f022                	sd	s0,32(sp)
    80002bb2:	ec26                	sd	s1,24(sp)
    80002bb4:	e84a                	sd	s2,16(sp)
    80002bb6:	e44e                	sd	s3,8(sp)
    80002bb8:	1800                	addi	s0,sp,48
    80002bba:	892a                	mv	s2,a0
    80002bbc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bbe:	00015517          	auipc	a0,0x15
    80002bc2:	72a50513          	addi	a0,a0,1834 # 800182e8 <bcache>
    80002bc6:	82efe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bca:	0001e497          	auipc	s1,0x1e
    80002bce:	9d64b483          	ld	s1,-1578(s1) # 800205a0 <bcache+0x82b8>
    80002bd2:	0001e797          	auipc	a5,0x1e
    80002bd6:	97e78793          	addi	a5,a5,-1666 # 80020550 <bcache+0x8268>
    80002bda:	02f48b63          	beq	s1,a5,80002c10 <bread+0x64>
    80002bde:	873e                	mv	a4,a5
    80002be0:	a021                	j	80002be8 <bread+0x3c>
    80002be2:	68a4                	ld	s1,80(s1)
    80002be4:	02e48663          	beq	s1,a4,80002c10 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002be8:	449c                	lw	a5,8(s1)
    80002bea:	ff279ce3          	bne	a5,s2,80002be2 <bread+0x36>
    80002bee:	44dc                	lw	a5,12(s1)
    80002bf0:	ff3799e3          	bne	a5,s3,80002be2 <bread+0x36>
      b->refcnt++;
    80002bf4:	40bc                	lw	a5,64(s1)
    80002bf6:	2785                	addiw	a5,a5,1
    80002bf8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bfa:	00015517          	auipc	a0,0x15
    80002bfe:	6ee50513          	addi	a0,a0,1774 # 800182e8 <bcache>
    80002c02:	88afe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c06:	01048513          	addi	a0,s1,16
    80002c0a:	1fa010ef          	jal	80003e04 <acquiresleep>
      return b;
    80002c0e:	a889                	j	80002c60 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c10:	0001e497          	auipc	s1,0x1e
    80002c14:	9884b483          	ld	s1,-1656(s1) # 80020598 <bcache+0x82b0>
    80002c18:	0001e797          	auipc	a5,0x1e
    80002c1c:	93878793          	addi	a5,a5,-1736 # 80020550 <bcache+0x8268>
    80002c20:	00f48863          	beq	s1,a5,80002c30 <bread+0x84>
    80002c24:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c26:	40bc                	lw	a5,64(s1)
    80002c28:	cb91                	beqz	a5,80002c3c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c2a:	64a4                	ld	s1,72(s1)
    80002c2c:	fee49de3          	bne	s1,a4,80002c26 <bread+0x7a>
  panic("bget: no buffers");
    80002c30:	00005517          	auipc	a0,0x5
    80002c34:	8b850513          	addi	a0,a0,-1864 # 800074e8 <etext+0x4e8>
    80002c38:	b5dfd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002c3c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c40:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c44:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c48:	4785                	li	a5,1
    80002c4a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c4c:	00015517          	auipc	a0,0x15
    80002c50:	69c50513          	addi	a0,a0,1692 # 800182e8 <bcache>
    80002c54:	838fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c58:	01048513          	addi	a0,s1,16
    80002c5c:	1a8010ef          	jal	80003e04 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c60:	409c                	lw	a5,0(s1)
    80002c62:	cb89                	beqz	a5,80002c74 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c64:	8526                	mv	a0,s1
    80002c66:	70a2                	ld	ra,40(sp)
    80002c68:	7402                	ld	s0,32(sp)
    80002c6a:	64e2                	ld	s1,24(sp)
    80002c6c:	6942                	ld	s2,16(sp)
    80002c6e:	69a2                	ld	s3,8(sp)
    80002c70:	6145                	addi	sp,sp,48
    80002c72:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c74:	4581                	li	a1,0
    80002c76:	8526                	mv	a0,s1
    80002c78:	1e9020ef          	jal	80005660 <virtio_disk_rw>
    b->valid = 1;
    80002c7c:	4785                	li	a5,1
    80002c7e:	c09c                	sw	a5,0(s1)
  return b;
    80002c80:	b7d5                	j	80002c64 <bread+0xb8>

0000000080002c82 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c82:	1101                	addi	sp,sp,-32
    80002c84:	ec06                	sd	ra,24(sp)
    80002c86:	e822                	sd	s0,16(sp)
    80002c88:	e426                	sd	s1,8(sp)
    80002c8a:	1000                	addi	s0,sp,32
    80002c8c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c8e:	0541                	addi	a0,a0,16
    80002c90:	1f2010ef          	jal	80003e82 <holdingsleep>
    80002c94:	c911                	beqz	a0,80002ca8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c96:	4585                	li	a1,1
    80002c98:	8526                	mv	a0,s1
    80002c9a:	1c7020ef          	jal	80005660 <virtio_disk_rw>
}
    80002c9e:	60e2                	ld	ra,24(sp)
    80002ca0:	6442                	ld	s0,16(sp)
    80002ca2:	64a2                	ld	s1,8(sp)
    80002ca4:	6105                	addi	sp,sp,32
    80002ca6:	8082                	ret
    panic("bwrite");
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	85850513          	addi	a0,a0,-1960 # 80007500 <etext+0x500>
    80002cb0:	ae5fd0ef          	jal	80000794 <panic>

0000000080002cb4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cb4:	1101                	addi	sp,sp,-32
    80002cb6:	ec06                	sd	ra,24(sp)
    80002cb8:	e822                	sd	s0,16(sp)
    80002cba:	e426                	sd	s1,8(sp)
    80002cbc:	e04a                	sd	s2,0(sp)
    80002cbe:	1000                	addi	s0,sp,32
    80002cc0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cc2:	01050913          	addi	s2,a0,16
    80002cc6:	854a                	mv	a0,s2
    80002cc8:	1ba010ef          	jal	80003e82 <holdingsleep>
    80002ccc:	c135                	beqz	a0,80002d30 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002cce:	854a                	mv	a0,s2
    80002cd0:	17a010ef          	jal	80003e4a <releasesleep>

  acquire(&bcache.lock);
    80002cd4:	00015517          	auipc	a0,0x15
    80002cd8:	61450513          	addi	a0,a0,1556 # 800182e8 <bcache>
    80002cdc:	f19fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002ce0:	40bc                	lw	a5,64(s1)
    80002ce2:	37fd                	addiw	a5,a5,-1
    80002ce4:	0007871b          	sext.w	a4,a5
    80002ce8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cea:	e71d                	bnez	a4,80002d18 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cec:	68b8                	ld	a4,80(s1)
    80002cee:	64bc                	ld	a5,72(s1)
    80002cf0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002cf2:	68b8                	ld	a4,80(s1)
    80002cf4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002cf6:	0001d797          	auipc	a5,0x1d
    80002cfa:	5f278793          	addi	a5,a5,1522 # 800202e8 <bcache+0x8000>
    80002cfe:	2b87b703          	ld	a4,696(a5)
    80002d02:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d04:	0001e717          	auipc	a4,0x1e
    80002d08:	84c70713          	addi	a4,a4,-1972 # 80020550 <bcache+0x8268>
    80002d0c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d0e:	2b87b703          	ld	a4,696(a5)
    80002d12:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d14:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d18:	00015517          	auipc	a0,0x15
    80002d1c:	5d050513          	addi	a0,a0,1488 # 800182e8 <bcache>
    80002d20:	f6dfd0ef          	jal	80000c8c <release>
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6902                	ld	s2,0(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret
    panic("brelse");
    80002d30:	00004517          	auipc	a0,0x4
    80002d34:	7d850513          	addi	a0,a0,2008 # 80007508 <etext+0x508>
    80002d38:	a5dfd0ef          	jal	80000794 <panic>

0000000080002d3c <bpin>:

void
bpin(struct buf *b) {
    80002d3c:	1101                	addi	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	e426                	sd	s1,8(sp)
    80002d44:	1000                	addi	s0,sp,32
    80002d46:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d48:	00015517          	auipc	a0,0x15
    80002d4c:	5a050513          	addi	a0,a0,1440 # 800182e8 <bcache>
    80002d50:	ea5fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002d54:	40bc                	lw	a5,64(s1)
    80002d56:	2785                	addiw	a5,a5,1
    80002d58:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d5a:	00015517          	auipc	a0,0x15
    80002d5e:	58e50513          	addi	a0,a0,1422 # 800182e8 <bcache>
    80002d62:	f2bfd0ef          	jal	80000c8c <release>
}
    80002d66:	60e2                	ld	ra,24(sp)
    80002d68:	6442                	ld	s0,16(sp)
    80002d6a:	64a2                	ld	s1,8(sp)
    80002d6c:	6105                	addi	sp,sp,32
    80002d6e:	8082                	ret

0000000080002d70 <bunpin>:

void
bunpin(struct buf *b) {
    80002d70:	1101                	addi	sp,sp,-32
    80002d72:	ec06                	sd	ra,24(sp)
    80002d74:	e822                	sd	s0,16(sp)
    80002d76:	e426                	sd	s1,8(sp)
    80002d78:	1000                	addi	s0,sp,32
    80002d7a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d7c:	00015517          	auipc	a0,0x15
    80002d80:	56c50513          	addi	a0,a0,1388 # 800182e8 <bcache>
    80002d84:	e71fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002d88:	40bc                	lw	a5,64(s1)
    80002d8a:	37fd                	addiw	a5,a5,-1
    80002d8c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d8e:	00015517          	auipc	a0,0x15
    80002d92:	55a50513          	addi	a0,a0,1370 # 800182e8 <bcache>
    80002d96:	ef7fd0ef          	jal	80000c8c <release>
}
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret

0000000080002da4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002da4:	1101                	addi	sp,sp,-32
    80002da6:	ec06                	sd	ra,24(sp)
    80002da8:	e822                	sd	s0,16(sp)
    80002daa:	e426                	sd	s1,8(sp)
    80002dac:	e04a                	sd	s2,0(sp)
    80002dae:	1000                	addi	s0,sp,32
    80002db0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002db2:	00d5d59b          	srliw	a1,a1,0xd
    80002db6:	0001e797          	auipc	a5,0x1e
    80002dba:	c0e7a783          	lw	a5,-1010(a5) # 800209c4 <sb+0x1c>
    80002dbe:	9dbd                	addw	a1,a1,a5
    80002dc0:	dedff0ef          	jal	80002bac <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dc4:	0074f713          	andi	a4,s1,7
    80002dc8:	4785                	li	a5,1
    80002dca:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002dce:	14ce                	slli	s1,s1,0x33
    80002dd0:	90d9                	srli	s1,s1,0x36
    80002dd2:	00950733          	add	a4,a0,s1
    80002dd6:	05874703          	lbu	a4,88(a4)
    80002dda:	00e7f6b3          	and	a3,a5,a4
    80002dde:	c29d                	beqz	a3,80002e04 <bfree+0x60>
    80002de0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002de2:	94aa                	add	s1,s1,a0
    80002de4:	fff7c793          	not	a5,a5
    80002de8:	8f7d                	and	a4,a4,a5
    80002dea:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002dee:	711000ef          	jal	80003cfe <log_write>
  brelse(bp);
    80002df2:	854a                	mv	a0,s2
    80002df4:	ec1ff0ef          	jal	80002cb4 <brelse>
}
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6902                	ld	s2,0(sp)
    80002e00:	6105                	addi	sp,sp,32
    80002e02:	8082                	ret
    panic("freeing free block");
    80002e04:	00004517          	auipc	a0,0x4
    80002e08:	70c50513          	addi	a0,a0,1804 # 80007510 <etext+0x510>
    80002e0c:	989fd0ef          	jal	80000794 <panic>

0000000080002e10 <balloc>:
{
    80002e10:	711d                	addi	sp,sp,-96
    80002e12:	ec86                	sd	ra,88(sp)
    80002e14:	e8a2                	sd	s0,80(sp)
    80002e16:	e4a6                	sd	s1,72(sp)
    80002e18:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e1a:	0001e797          	auipc	a5,0x1e
    80002e1e:	b927a783          	lw	a5,-1134(a5) # 800209ac <sb+0x4>
    80002e22:	0e078f63          	beqz	a5,80002f20 <balloc+0x110>
    80002e26:	e0ca                	sd	s2,64(sp)
    80002e28:	fc4e                	sd	s3,56(sp)
    80002e2a:	f852                	sd	s4,48(sp)
    80002e2c:	f456                	sd	s5,40(sp)
    80002e2e:	f05a                	sd	s6,32(sp)
    80002e30:	ec5e                	sd	s7,24(sp)
    80002e32:	e862                	sd	s8,16(sp)
    80002e34:	e466                	sd	s9,8(sp)
    80002e36:	8baa                	mv	s7,a0
    80002e38:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e3a:	0001eb17          	auipc	s6,0x1e
    80002e3e:	b6eb0b13          	addi	s6,s6,-1170 # 800209a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e42:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e44:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e46:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e48:	6c89                	lui	s9,0x2
    80002e4a:	a0b5                	j	80002eb6 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e4c:	97ca                	add	a5,a5,s2
    80002e4e:	8e55                	or	a2,a2,a3
    80002e50:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e54:	854a                	mv	a0,s2
    80002e56:	6a9000ef          	jal	80003cfe <log_write>
        brelse(bp);
    80002e5a:	854a                	mv	a0,s2
    80002e5c:	e59ff0ef          	jal	80002cb4 <brelse>
  bp = bread(dev, bno);
    80002e60:	85a6                	mv	a1,s1
    80002e62:	855e                	mv	a0,s7
    80002e64:	d49ff0ef          	jal	80002bac <bread>
    80002e68:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e6a:	40000613          	li	a2,1024
    80002e6e:	4581                	li	a1,0
    80002e70:	05850513          	addi	a0,a0,88
    80002e74:	e55fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002e78:	854a                	mv	a0,s2
    80002e7a:	685000ef          	jal	80003cfe <log_write>
  brelse(bp);
    80002e7e:	854a                	mv	a0,s2
    80002e80:	e35ff0ef          	jal	80002cb4 <brelse>
}
    80002e84:	6906                	ld	s2,64(sp)
    80002e86:	79e2                	ld	s3,56(sp)
    80002e88:	7a42                	ld	s4,48(sp)
    80002e8a:	7aa2                	ld	s5,40(sp)
    80002e8c:	7b02                	ld	s6,32(sp)
    80002e8e:	6be2                	ld	s7,24(sp)
    80002e90:	6c42                	ld	s8,16(sp)
    80002e92:	6ca2                	ld	s9,8(sp)
}
    80002e94:	8526                	mv	a0,s1
    80002e96:	60e6                	ld	ra,88(sp)
    80002e98:	6446                	ld	s0,80(sp)
    80002e9a:	64a6                	ld	s1,72(sp)
    80002e9c:	6125                	addi	sp,sp,96
    80002e9e:	8082                	ret
    brelse(bp);
    80002ea0:	854a                	mv	a0,s2
    80002ea2:	e13ff0ef          	jal	80002cb4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ea6:	015c87bb          	addw	a5,s9,s5
    80002eaa:	00078a9b          	sext.w	s5,a5
    80002eae:	004b2703          	lw	a4,4(s6)
    80002eb2:	04eaff63          	bgeu	s5,a4,80002f10 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002eb6:	41fad79b          	sraiw	a5,s5,0x1f
    80002eba:	0137d79b          	srliw	a5,a5,0x13
    80002ebe:	015787bb          	addw	a5,a5,s5
    80002ec2:	40d7d79b          	sraiw	a5,a5,0xd
    80002ec6:	01cb2583          	lw	a1,28(s6)
    80002eca:	9dbd                	addw	a1,a1,a5
    80002ecc:	855e                	mv	a0,s7
    80002ece:	cdfff0ef          	jal	80002bac <bread>
    80002ed2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ed4:	004b2503          	lw	a0,4(s6)
    80002ed8:	000a849b          	sext.w	s1,s5
    80002edc:	8762                	mv	a4,s8
    80002ede:	fca4f1e3          	bgeu	s1,a0,80002ea0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002ee2:	00777693          	andi	a3,a4,7
    80002ee6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002eea:	41f7579b          	sraiw	a5,a4,0x1f
    80002eee:	01d7d79b          	srliw	a5,a5,0x1d
    80002ef2:	9fb9                	addw	a5,a5,a4
    80002ef4:	4037d79b          	sraiw	a5,a5,0x3
    80002ef8:	00f90633          	add	a2,s2,a5
    80002efc:	05864603          	lbu	a2,88(a2)
    80002f00:	00c6f5b3          	and	a1,a3,a2
    80002f04:	d5a1                	beqz	a1,80002e4c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f06:	2705                	addiw	a4,a4,1
    80002f08:	2485                	addiw	s1,s1,1
    80002f0a:	fd471ae3          	bne	a4,s4,80002ede <balloc+0xce>
    80002f0e:	bf49                	j	80002ea0 <balloc+0x90>
    80002f10:	6906                	ld	s2,64(sp)
    80002f12:	79e2                	ld	s3,56(sp)
    80002f14:	7a42                	ld	s4,48(sp)
    80002f16:	7aa2                	ld	s5,40(sp)
    80002f18:	7b02                	ld	s6,32(sp)
    80002f1a:	6be2                	ld	s7,24(sp)
    80002f1c:	6c42                	ld	s8,16(sp)
    80002f1e:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f20:	00004517          	auipc	a0,0x4
    80002f24:	60850513          	addi	a0,a0,1544 # 80007528 <etext+0x528>
    80002f28:	d9afd0ef          	jal	800004c2 <printf>
  return 0;
    80002f2c:	4481                	li	s1,0
    80002f2e:	b79d                	j	80002e94 <balloc+0x84>

0000000080002f30 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f30:	7179                	addi	sp,sp,-48
    80002f32:	f406                	sd	ra,40(sp)
    80002f34:	f022                	sd	s0,32(sp)
    80002f36:	ec26                	sd	s1,24(sp)
    80002f38:	e84a                	sd	s2,16(sp)
    80002f3a:	e44e                	sd	s3,8(sp)
    80002f3c:	1800                	addi	s0,sp,48
    80002f3e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f40:	47ad                	li	a5,11
    80002f42:	02b7e663          	bltu	a5,a1,80002f6e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f46:	02059793          	slli	a5,a1,0x20
    80002f4a:	01e7d593          	srli	a1,a5,0x1e
    80002f4e:	00b504b3          	add	s1,a0,a1
    80002f52:	0504a903          	lw	s2,80(s1)
    80002f56:	06091a63          	bnez	s2,80002fca <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f5a:	4108                	lw	a0,0(a0)
    80002f5c:	eb5ff0ef          	jal	80002e10 <balloc>
    80002f60:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f64:	06090363          	beqz	s2,80002fca <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f68:	0524a823          	sw	s2,80(s1)
    80002f6c:	a8b9                	j	80002fca <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f6e:	ff45849b          	addiw	s1,a1,-12
    80002f72:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f76:	0ff00793          	li	a5,255
    80002f7a:	06e7ee63          	bltu	a5,a4,80002ff6 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f7e:	08052903          	lw	s2,128(a0)
    80002f82:	00091d63          	bnez	s2,80002f9c <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f86:	4108                	lw	a0,0(a0)
    80002f88:	e89ff0ef          	jal	80002e10 <balloc>
    80002f8c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f90:	02090d63          	beqz	s2,80002fca <bmap+0x9a>
    80002f94:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f96:	0929a023          	sw	s2,128(s3)
    80002f9a:	a011                	j	80002f9e <bmap+0x6e>
    80002f9c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f9e:	85ca                	mv	a1,s2
    80002fa0:	0009a503          	lw	a0,0(s3)
    80002fa4:	c09ff0ef          	jal	80002bac <bread>
    80002fa8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002faa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fae:	02049713          	slli	a4,s1,0x20
    80002fb2:	01e75593          	srli	a1,a4,0x1e
    80002fb6:	00b784b3          	add	s1,a5,a1
    80002fba:	0004a903          	lw	s2,0(s1)
    80002fbe:	00090e63          	beqz	s2,80002fda <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fc2:	8552                	mv	a0,s4
    80002fc4:	cf1ff0ef          	jal	80002cb4 <brelse>
    return addr;
    80002fc8:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fca:	854a                	mv	a0,s2
    80002fcc:	70a2                	ld	ra,40(sp)
    80002fce:	7402                	ld	s0,32(sp)
    80002fd0:	64e2                	ld	s1,24(sp)
    80002fd2:	6942                	ld	s2,16(sp)
    80002fd4:	69a2                	ld	s3,8(sp)
    80002fd6:	6145                	addi	sp,sp,48
    80002fd8:	8082                	ret
      addr = balloc(ip->dev);
    80002fda:	0009a503          	lw	a0,0(s3)
    80002fde:	e33ff0ef          	jal	80002e10 <balloc>
    80002fe2:	0005091b          	sext.w	s2,a0
      if(addr){
    80002fe6:	fc090ee3          	beqz	s2,80002fc2 <bmap+0x92>
        a[bn] = addr;
    80002fea:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002fee:	8552                	mv	a0,s4
    80002ff0:	50f000ef          	jal	80003cfe <log_write>
    80002ff4:	b7f9                	j	80002fc2 <bmap+0x92>
    80002ff6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002ff8:	00004517          	auipc	a0,0x4
    80002ffc:	54850513          	addi	a0,a0,1352 # 80007540 <etext+0x540>
    80003000:	f94fd0ef          	jal	80000794 <panic>

0000000080003004 <iget>:
{
    80003004:	7179                	addi	sp,sp,-48
    80003006:	f406                	sd	ra,40(sp)
    80003008:	f022                	sd	s0,32(sp)
    8000300a:	ec26                	sd	s1,24(sp)
    8000300c:	e84a                	sd	s2,16(sp)
    8000300e:	e44e                	sd	s3,8(sp)
    80003010:	e052                	sd	s4,0(sp)
    80003012:	1800                	addi	s0,sp,48
    80003014:	89aa                	mv	s3,a0
    80003016:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003018:	0001e517          	auipc	a0,0x1e
    8000301c:	9b050513          	addi	a0,a0,-1616 # 800209c8 <itable>
    80003020:	bd5fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003024:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003026:	0001e497          	auipc	s1,0x1e
    8000302a:	9ba48493          	addi	s1,s1,-1606 # 800209e0 <itable+0x18>
    8000302e:	0001f697          	auipc	a3,0x1f
    80003032:	44268693          	addi	a3,a3,1090 # 80022470 <log>
    80003036:	a039                	j	80003044 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003038:	02090963          	beqz	s2,8000306a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000303c:	08848493          	addi	s1,s1,136
    80003040:	02d48863          	beq	s1,a3,80003070 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003044:	449c                	lw	a5,8(s1)
    80003046:	fef059e3          	blez	a5,80003038 <iget+0x34>
    8000304a:	4098                	lw	a4,0(s1)
    8000304c:	ff3716e3          	bne	a4,s3,80003038 <iget+0x34>
    80003050:	40d8                	lw	a4,4(s1)
    80003052:	ff4713e3          	bne	a4,s4,80003038 <iget+0x34>
      ip->ref++;
    80003056:	2785                	addiw	a5,a5,1
    80003058:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000305a:	0001e517          	auipc	a0,0x1e
    8000305e:	96e50513          	addi	a0,a0,-1682 # 800209c8 <itable>
    80003062:	c2bfd0ef          	jal	80000c8c <release>
      return ip;
    80003066:	8926                	mv	s2,s1
    80003068:	a02d                	j	80003092 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000306a:	fbe9                	bnez	a5,8000303c <iget+0x38>
      empty = ip;
    8000306c:	8926                	mv	s2,s1
    8000306e:	b7f9                	j	8000303c <iget+0x38>
  if(empty == 0)
    80003070:	02090a63          	beqz	s2,800030a4 <iget+0xa0>
  ip->dev = dev;
    80003074:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003078:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000307c:	4785                	li	a5,1
    8000307e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003082:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003086:	0001e517          	auipc	a0,0x1e
    8000308a:	94250513          	addi	a0,a0,-1726 # 800209c8 <itable>
    8000308e:	bfffd0ef          	jal	80000c8c <release>
}
    80003092:	854a                	mv	a0,s2
    80003094:	70a2                	ld	ra,40(sp)
    80003096:	7402                	ld	s0,32(sp)
    80003098:	64e2                	ld	s1,24(sp)
    8000309a:	6942                	ld	s2,16(sp)
    8000309c:	69a2                	ld	s3,8(sp)
    8000309e:	6a02                	ld	s4,0(sp)
    800030a0:	6145                	addi	sp,sp,48
    800030a2:	8082                	ret
    panic("iget: no inodes");
    800030a4:	00004517          	auipc	a0,0x4
    800030a8:	4b450513          	addi	a0,a0,1204 # 80007558 <etext+0x558>
    800030ac:	ee8fd0ef          	jal	80000794 <panic>

00000000800030b0 <fsinit>:
fsinit(int dev) {
    800030b0:	7179                	addi	sp,sp,-48
    800030b2:	f406                	sd	ra,40(sp)
    800030b4:	f022                	sd	s0,32(sp)
    800030b6:	ec26                	sd	s1,24(sp)
    800030b8:	e84a                	sd	s2,16(sp)
    800030ba:	e44e                	sd	s3,8(sp)
    800030bc:	1800                	addi	s0,sp,48
    800030be:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800030c0:	4585                	li	a1,1
    800030c2:	aebff0ef          	jal	80002bac <bread>
    800030c6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800030c8:	0001e997          	auipc	s3,0x1e
    800030cc:	8e098993          	addi	s3,s3,-1824 # 800209a8 <sb>
    800030d0:	02000613          	li	a2,32
    800030d4:	05850593          	addi	a1,a0,88
    800030d8:	854e                	mv	a0,s3
    800030da:	c4bfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800030de:	8526                	mv	a0,s1
    800030e0:	bd5ff0ef          	jal	80002cb4 <brelse>
  if(sb.magic != FSMAGIC)
    800030e4:	0009a703          	lw	a4,0(s3)
    800030e8:	102037b7          	lui	a5,0x10203
    800030ec:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030f0:	02f71063          	bne	a4,a5,80003110 <fsinit+0x60>
  initlog(dev, &sb);
    800030f4:	0001e597          	auipc	a1,0x1e
    800030f8:	8b458593          	addi	a1,a1,-1868 # 800209a8 <sb>
    800030fc:	854a                	mv	a0,s2
    800030fe:	1f9000ef          	jal	80003af6 <initlog>
}
    80003102:	70a2                	ld	ra,40(sp)
    80003104:	7402                	ld	s0,32(sp)
    80003106:	64e2                	ld	s1,24(sp)
    80003108:	6942                	ld	s2,16(sp)
    8000310a:	69a2                	ld	s3,8(sp)
    8000310c:	6145                	addi	sp,sp,48
    8000310e:	8082                	ret
    panic("invalid file system");
    80003110:	00004517          	auipc	a0,0x4
    80003114:	45850513          	addi	a0,a0,1112 # 80007568 <etext+0x568>
    80003118:	e7cfd0ef          	jal	80000794 <panic>

000000008000311c <iinit>:
{
    8000311c:	7179                	addi	sp,sp,-48
    8000311e:	f406                	sd	ra,40(sp)
    80003120:	f022                	sd	s0,32(sp)
    80003122:	ec26                	sd	s1,24(sp)
    80003124:	e84a                	sd	s2,16(sp)
    80003126:	e44e                	sd	s3,8(sp)
    80003128:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000312a:	00004597          	auipc	a1,0x4
    8000312e:	45658593          	addi	a1,a1,1110 # 80007580 <etext+0x580>
    80003132:	0001e517          	auipc	a0,0x1e
    80003136:	89650513          	addi	a0,a0,-1898 # 800209c8 <itable>
    8000313a:	a3bfd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000313e:	0001e497          	auipc	s1,0x1e
    80003142:	8b248493          	addi	s1,s1,-1870 # 800209f0 <itable+0x28>
    80003146:	0001f997          	auipc	s3,0x1f
    8000314a:	33a98993          	addi	s3,s3,826 # 80022480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000314e:	00004917          	auipc	s2,0x4
    80003152:	43a90913          	addi	s2,s2,1082 # 80007588 <etext+0x588>
    80003156:	85ca                	mv	a1,s2
    80003158:	8526                	mv	a0,s1
    8000315a:	475000ef          	jal	80003dce <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000315e:	08848493          	addi	s1,s1,136
    80003162:	ff349ae3          	bne	s1,s3,80003156 <iinit+0x3a>
}
    80003166:	70a2                	ld	ra,40(sp)
    80003168:	7402                	ld	s0,32(sp)
    8000316a:	64e2                	ld	s1,24(sp)
    8000316c:	6942                	ld	s2,16(sp)
    8000316e:	69a2                	ld	s3,8(sp)
    80003170:	6145                	addi	sp,sp,48
    80003172:	8082                	ret

0000000080003174 <ialloc>:
{
    80003174:	7139                	addi	sp,sp,-64
    80003176:	fc06                	sd	ra,56(sp)
    80003178:	f822                	sd	s0,48(sp)
    8000317a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000317c:	0001e717          	auipc	a4,0x1e
    80003180:	83872703          	lw	a4,-1992(a4) # 800209b4 <sb+0xc>
    80003184:	4785                	li	a5,1
    80003186:	06e7f063          	bgeu	a5,a4,800031e6 <ialloc+0x72>
    8000318a:	f426                	sd	s1,40(sp)
    8000318c:	f04a                	sd	s2,32(sp)
    8000318e:	ec4e                	sd	s3,24(sp)
    80003190:	e852                	sd	s4,16(sp)
    80003192:	e456                	sd	s5,8(sp)
    80003194:	e05a                	sd	s6,0(sp)
    80003196:	8aaa                	mv	s5,a0
    80003198:	8b2e                	mv	s6,a1
    8000319a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000319c:	0001ea17          	auipc	s4,0x1e
    800031a0:	80ca0a13          	addi	s4,s4,-2036 # 800209a8 <sb>
    800031a4:	00495593          	srli	a1,s2,0x4
    800031a8:	018a2783          	lw	a5,24(s4)
    800031ac:	9dbd                	addw	a1,a1,a5
    800031ae:	8556                	mv	a0,s5
    800031b0:	9fdff0ef          	jal	80002bac <bread>
    800031b4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031b6:	05850993          	addi	s3,a0,88
    800031ba:	00f97793          	andi	a5,s2,15
    800031be:	079a                	slli	a5,a5,0x6
    800031c0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800031c2:	00099783          	lh	a5,0(s3)
    800031c6:	cb9d                	beqz	a5,800031fc <ialloc+0x88>
    brelse(bp);
    800031c8:	aedff0ef          	jal	80002cb4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031cc:	0905                	addi	s2,s2,1
    800031ce:	00ca2703          	lw	a4,12(s4)
    800031d2:	0009079b          	sext.w	a5,s2
    800031d6:	fce7e7e3          	bltu	a5,a4,800031a4 <ialloc+0x30>
    800031da:	74a2                	ld	s1,40(sp)
    800031dc:	7902                	ld	s2,32(sp)
    800031de:	69e2                	ld	s3,24(sp)
    800031e0:	6a42                	ld	s4,16(sp)
    800031e2:	6aa2                	ld	s5,8(sp)
    800031e4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031e6:	00004517          	auipc	a0,0x4
    800031ea:	3aa50513          	addi	a0,a0,938 # 80007590 <etext+0x590>
    800031ee:	ad4fd0ef          	jal	800004c2 <printf>
  return 0;
    800031f2:	4501                	li	a0,0
}
    800031f4:	70e2                	ld	ra,56(sp)
    800031f6:	7442                	ld	s0,48(sp)
    800031f8:	6121                	addi	sp,sp,64
    800031fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031fc:	04000613          	li	a2,64
    80003200:	4581                	li	a1,0
    80003202:	854e                	mv	a0,s3
    80003204:	ac5fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003208:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000320c:	8526                	mv	a0,s1
    8000320e:	2f1000ef          	jal	80003cfe <log_write>
      brelse(bp);
    80003212:	8526                	mv	a0,s1
    80003214:	aa1ff0ef          	jal	80002cb4 <brelse>
      return iget(dev, inum);
    80003218:	0009059b          	sext.w	a1,s2
    8000321c:	8556                	mv	a0,s5
    8000321e:	de7ff0ef          	jal	80003004 <iget>
    80003222:	74a2                	ld	s1,40(sp)
    80003224:	7902                	ld	s2,32(sp)
    80003226:	69e2                	ld	s3,24(sp)
    80003228:	6a42                	ld	s4,16(sp)
    8000322a:	6aa2                	ld	s5,8(sp)
    8000322c:	6b02                	ld	s6,0(sp)
    8000322e:	b7d9                	j	800031f4 <ialloc+0x80>

0000000080003230 <iupdate>:
{
    80003230:	1101                	addi	sp,sp,-32
    80003232:	ec06                	sd	ra,24(sp)
    80003234:	e822                	sd	s0,16(sp)
    80003236:	e426                	sd	s1,8(sp)
    80003238:	e04a                	sd	s2,0(sp)
    8000323a:	1000                	addi	s0,sp,32
    8000323c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000323e:	415c                	lw	a5,4(a0)
    80003240:	0047d79b          	srliw	a5,a5,0x4
    80003244:	0001d597          	auipc	a1,0x1d
    80003248:	77c5a583          	lw	a1,1916(a1) # 800209c0 <sb+0x18>
    8000324c:	9dbd                	addw	a1,a1,a5
    8000324e:	4108                	lw	a0,0(a0)
    80003250:	95dff0ef          	jal	80002bac <bread>
    80003254:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003256:	05850793          	addi	a5,a0,88
    8000325a:	40d8                	lw	a4,4(s1)
    8000325c:	8b3d                	andi	a4,a4,15
    8000325e:	071a                	slli	a4,a4,0x6
    80003260:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003262:	04449703          	lh	a4,68(s1)
    80003266:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000326a:	04649703          	lh	a4,70(s1)
    8000326e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003272:	04849703          	lh	a4,72(s1)
    80003276:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000327a:	04a49703          	lh	a4,74(s1)
    8000327e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003282:	44f8                	lw	a4,76(s1)
    80003284:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003286:	03400613          	li	a2,52
    8000328a:	05048593          	addi	a1,s1,80
    8000328e:	00c78513          	addi	a0,a5,12
    80003292:	a93fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003296:	854a                	mv	a0,s2
    80003298:	267000ef          	jal	80003cfe <log_write>
  brelse(bp);
    8000329c:	854a                	mv	a0,s2
    8000329e:	a17ff0ef          	jal	80002cb4 <brelse>
}
    800032a2:	60e2                	ld	ra,24(sp)
    800032a4:	6442                	ld	s0,16(sp)
    800032a6:	64a2                	ld	s1,8(sp)
    800032a8:	6902                	ld	s2,0(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret

00000000800032ae <idup>:
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
    800032b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032ba:	0001d517          	auipc	a0,0x1d
    800032be:	70e50513          	addi	a0,a0,1806 # 800209c8 <itable>
    800032c2:	933fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800032c6:	449c                	lw	a5,8(s1)
    800032c8:	2785                	addiw	a5,a5,1
    800032ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800032cc:	0001d517          	auipc	a0,0x1d
    800032d0:	6fc50513          	addi	a0,a0,1788 # 800209c8 <itable>
    800032d4:	9b9fd0ef          	jal	80000c8c <release>
}
    800032d8:	8526                	mv	a0,s1
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6105                	addi	sp,sp,32
    800032e2:	8082                	ret

00000000800032e4 <ilock>:
{
    800032e4:	1101                	addi	sp,sp,-32
    800032e6:	ec06                	sd	ra,24(sp)
    800032e8:	e822                	sd	s0,16(sp)
    800032ea:	e426                	sd	s1,8(sp)
    800032ec:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032ee:	cd19                	beqz	a0,8000330c <ilock+0x28>
    800032f0:	84aa                	mv	s1,a0
    800032f2:	451c                	lw	a5,8(a0)
    800032f4:	00f05c63          	blez	a5,8000330c <ilock+0x28>
  acquiresleep(&ip->lock);
    800032f8:	0541                	addi	a0,a0,16
    800032fa:	30b000ef          	jal	80003e04 <acquiresleep>
  if(ip->valid == 0){
    800032fe:	40bc                	lw	a5,64(s1)
    80003300:	cf89                	beqz	a5,8000331a <ilock+0x36>
}
    80003302:	60e2                	ld	ra,24(sp)
    80003304:	6442                	ld	s0,16(sp)
    80003306:	64a2                	ld	s1,8(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret
    8000330c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000330e:	00004517          	auipc	a0,0x4
    80003312:	29a50513          	addi	a0,a0,666 # 800075a8 <etext+0x5a8>
    80003316:	c7efd0ef          	jal	80000794 <panic>
    8000331a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000331c:	40dc                	lw	a5,4(s1)
    8000331e:	0047d79b          	srliw	a5,a5,0x4
    80003322:	0001d597          	auipc	a1,0x1d
    80003326:	69e5a583          	lw	a1,1694(a1) # 800209c0 <sb+0x18>
    8000332a:	9dbd                	addw	a1,a1,a5
    8000332c:	4088                	lw	a0,0(s1)
    8000332e:	87fff0ef          	jal	80002bac <bread>
    80003332:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003334:	05850593          	addi	a1,a0,88
    80003338:	40dc                	lw	a5,4(s1)
    8000333a:	8bbd                	andi	a5,a5,15
    8000333c:	079a                	slli	a5,a5,0x6
    8000333e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003340:	00059783          	lh	a5,0(a1)
    80003344:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003348:	00259783          	lh	a5,2(a1)
    8000334c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003350:	00459783          	lh	a5,4(a1)
    80003354:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003358:	00659783          	lh	a5,6(a1)
    8000335c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003360:	459c                	lw	a5,8(a1)
    80003362:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003364:	03400613          	li	a2,52
    80003368:	05b1                	addi	a1,a1,12
    8000336a:	05048513          	addi	a0,s1,80
    8000336e:	9b7fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003372:	854a                	mv	a0,s2
    80003374:	941ff0ef          	jal	80002cb4 <brelse>
    ip->valid = 1;
    80003378:	4785                	li	a5,1
    8000337a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000337c:	04449783          	lh	a5,68(s1)
    80003380:	c399                	beqz	a5,80003386 <ilock+0xa2>
    80003382:	6902                	ld	s2,0(sp)
    80003384:	bfbd                	j	80003302 <ilock+0x1e>
      panic("ilock: no type");
    80003386:	00004517          	auipc	a0,0x4
    8000338a:	22a50513          	addi	a0,a0,554 # 800075b0 <etext+0x5b0>
    8000338e:	c06fd0ef          	jal	80000794 <panic>

0000000080003392 <iunlock>:
{
    80003392:	1101                	addi	sp,sp,-32
    80003394:	ec06                	sd	ra,24(sp)
    80003396:	e822                	sd	s0,16(sp)
    80003398:	e426                	sd	s1,8(sp)
    8000339a:	e04a                	sd	s2,0(sp)
    8000339c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000339e:	c505                	beqz	a0,800033c6 <iunlock+0x34>
    800033a0:	84aa                	mv	s1,a0
    800033a2:	01050913          	addi	s2,a0,16
    800033a6:	854a                	mv	a0,s2
    800033a8:	2db000ef          	jal	80003e82 <holdingsleep>
    800033ac:	cd09                	beqz	a0,800033c6 <iunlock+0x34>
    800033ae:	449c                	lw	a5,8(s1)
    800033b0:	00f05b63          	blez	a5,800033c6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033b4:	854a                	mv	a0,s2
    800033b6:	295000ef          	jal	80003e4a <releasesleep>
}
    800033ba:	60e2                	ld	ra,24(sp)
    800033bc:	6442                	ld	s0,16(sp)
    800033be:	64a2                	ld	s1,8(sp)
    800033c0:	6902                	ld	s2,0(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret
    panic("iunlock");
    800033c6:	00004517          	auipc	a0,0x4
    800033ca:	1fa50513          	addi	a0,a0,506 # 800075c0 <etext+0x5c0>
    800033ce:	bc6fd0ef          	jal	80000794 <panic>

00000000800033d2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800033d2:	7179                	addi	sp,sp,-48
    800033d4:	f406                	sd	ra,40(sp)
    800033d6:	f022                	sd	s0,32(sp)
    800033d8:	ec26                	sd	s1,24(sp)
    800033da:	e84a                	sd	s2,16(sp)
    800033dc:	e44e                	sd	s3,8(sp)
    800033de:	1800                	addi	s0,sp,48
    800033e0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033e2:	05050493          	addi	s1,a0,80
    800033e6:	08050913          	addi	s2,a0,128
    800033ea:	a021                	j	800033f2 <itrunc+0x20>
    800033ec:	0491                	addi	s1,s1,4
    800033ee:	01248b63          	beq	s1,s2,80003404 <itrunc+0x32>
    if(ip->addrs[i]){
    800033f2:	408c                	lw	a1,0(s1)
    800033f4:	dde5                	beqz	a1,800033ec <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033f6:	0009a503          	lw	a0,0(s3)
    800033fa:	9abff0ef          	jal	80002da4 <bfree>
      ip->addrs[i] = 0;
    800033fe:	0004a023          	sw	zero,0(s1)
    80003402:	b7ed                	j	800033ec <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003404:	0809a583          	lw	a1,128(s3)
    80003408:	ed89                	bnez	a1,80003422 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000340a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000340e:	854e                	mv	a0,s3
    80003410:	e21ff0ef          	jal	80003230 <iupdate>
}
    80003414:	70a2                	ld	ra,40(sp)
    80003416:	7402                	ld	s0,32(sp)
    80003418:	64e2                	ld	s1,24(sp)
    8000341a:	6942                	ld	s2,16(sp)
    8000341c:	69a2                	ld	s3,8(sp)
    8000341e:	6145                	addi	sp,sp,48
    80003420:	8082                	ret
    80003422:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003424:	0009a503          	lw	a0,0(s3)
    80003428:	f84ff0ef          	jal	80002bac <bread>
    8000342c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000342e:	05850493          	addi	s1,a0,88
    80003432:	45850913          	addi	s2,a0,1112
    80003436:	a021                	j	8000343e <itrunc+0x6c>
    80003438:	0491                	addi	s1,s1,4
    8000343a:	01248963          	beq	s1,s2,8000344c <itrunc+0x7a>
      if(a[j])
    8000343e:	408c                	lw	a1,0(s1)
    80003440:	dde5                	beqz	a1,80003438 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003442:	0009a503          	lw	a0,0(s3)
    80003446:	95fff0ef          	jal	80002da4 <bfree>
    8000344a:	b7fd                	j	80003438 <itrunc+0x66>
    brelse(bp);
    8000344c:	8552                	mv	a0,s4
    8000344e:	867ff0ef          	jal	80002cb4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003452:	0809a583          	lw	a1,128(s3)
    80003456:	0009a503          	lw	a0,0(s3)
    8000345a:	94bff0ef          	jal	80002da4 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000345e:	0809a023          	sw	zero,128(s3)
    80003462:	6a02                	ld	s4,0(sp)
    80003464:	b75d                	j	8000340a <itrunc+0x38>

0000000080003466 <iput>:
{
    80003466:	1101                	addi	sp,sp,-32
    80003468:	ec06                	sd	ra,24(sp)
    8000346a:	e822                	sd	s0,16(sp)
    8000346c:	e426                	sd	s1,8(sp)
    8000346e:	1000                	addi	s0,sp,32
    80003470:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003472:	0001d517          	auipc	a0,0x1d
    80003476:	55650513          	addi	a0,a0,1366 # 800209c8 <itable>
    8000347a:	f7afd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000347e:	4498                	lw	a4,8(s1)
    80003480:	4785                	li	a5,1
    80003482:	02f70063          	beq	a4,a5,800034a2 <iput+0x3c>
  ip->ref--;
    80003486:	449c                	lw	a5,8(s1)
    80003488:	37fd                	addiw	a5,a5,-1
    8000348a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000348c:	0001d517          	auipc	a0,0x1d
    80003490:	53c50513          	addi	a0,a0,1340 # 800209c8 <itable>
    80003494:	ff8fd0ef          	jal	80000c8c <release>
}
    80003498:	60e2                	ld	ra,24(sp)
    8000349a:	6442                	ld	s0,16(sp)
    8000349c:	64a2                	ld	s1,8(sp)
    8000349e:	6105                	addi	sp,sp,32
    800034a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034a2:	40bc                	lw	a5,64(s1)
    800034a4:	d3ed                	beqz	a5,80003486 <iput+0x20>
    800034a6:	04a49783          	lh	a5,74(s1)
    800034aa:	fff1                	bnez	a5,80003486 <iput+0x20>
    800034ac:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034ae:	01048913          	addi	s2,s1,16
    800034b2:	854a                	mv	a0,s2
    800034b4:	151000ef          	jal	80003e04 <acquiresleep>
    release(&itable.lock);
    800034b8:	0001d517          	auipc	a0,0x1d
    800034bc:	51050513          	addi	a0,a0,1296 # 800209c8 <itable>
    800034c0:	fccfd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800034c4:	8526                	mv	a0,s1
    800034c6:	f0dff0ef          	jal	800033d2 <itrunc>
    ip->type = 0;
    800034ca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800034ce:	8526                	mv	a0,s1
    800034d0:	d61ff0ef          	jal	80003230 <iupdate>
    ip->valid = 0;
    800034d4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034d8:	854a                	mv	a0,s2
    800034da:	171000ef          	jal	80003e4a <releasesleep>
    acquire(&itable.lock);
    800034de:	0001d517          	auipc	a0,0x1d
    800034e2:	4ea50513          	addi	a0,a0,1258 # 800209c8 <itable>
    800034e6:	f0efd0ef          	jal	80000bf4 <acquire>
    800034ea:	6902                	ld	s2,0(sp)
    800034ec:	bf69                	j	80003486 <iput+0x20>

00000000800034ee <iunlockput>:
{
    800034ee:	1101                	addi	sp,sp,-32
    800034f0:	ec06                	sd	ra,24(sp)
    800034f2:	e822                	sd	s0,16(sp)
    800034f4:	e426                	sd	s1,8(sp)
    800034f6:	1000                	addi	s0,sp,32
    800034f8:	84aa                	mv	s1,a0
  iunlock(ip);
    800034fa:	e99ff0ef          	jal	80003392 <iunlock>
  iput(ip);
    800034fe:	8526                	mv	a0,s1
    80003500:	f67ff0ef          	jal	80003466 <iput>
}
    80003504:	60e2                	ld	ra,24(sp)
    80003506:	6442                	ld	s0,16(sp)
    80003508:	64a2                	ld	s1,8(sp)
    8000350a:	6105                	addi	sp,sp,32
    8000350c:	8082                	ret

000000008000350e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000350e:	1141                	addi	sp,sp,-16
    80003510:	e422                	sd	s0,8(sp)
    80003512:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003514:	411c                	lw	a5,0(a0)
    80003516:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003518:	415c                	lw	a5,4(a0)
    8000351a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000351c:	04451783          	lh	a5,68(a0)
    80003520:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003524:	04a51783          	lh	a5,74(a0)
    80003528:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000352c:	04c56783          	lwu	a5,76(a0)
    80003530:	e99c                	sd	a5,16(a1)
}
    80003532:	6422                	ld	s0,8(sp)
    80003534:	0141                	addi	sp,sp,16
    80003536:	8082                	ret

0000000080003538 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003538:	457c                	lw	a5,76(a0)
    8000353a:	0ed7eb63          	bltu	a5,a3,80003630 <readi+0xf8>
{
    8000353e:	7159                	addi	sp,sp,-112
    80003540:	f486                	sd	ra,104(sp)
    80003542:	f0a2                	sd	s0,96(sp)
    80003544:	eca6                	sd	s1,88(sp)
    80003546:	e0d2                	sd	s4,64(sp)
    80003548:	fc56                	sd	s5,56(sp)
    8000354a:	f85a                	sd	s6,48(sp)
    8000354c:	f45e                	sd	s7,40(sp)
    8000354e:	1880                	addi	s0,sp,112
    80003550:	8b2a                	mv	s6,a0
    80003552:	8bae                	mv	s7,a1
    80003554:	8a32                	mv	s4,a2
    80003556:	84b6                	mv	s1,a3
    80003558:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000355a:	9f35                	addw	a4,a4,a3
    return 0;
    8000355c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000355e:	0cd76063          	bltu	a4,a3,8000361e <readi+0xe6>
    80003562:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003564:	00e7f463          	bgeu	a5,a4,8000356c <readi+0x34>
    n = ip->size - off;
    80003568:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000356c:	080a8f63          	beqz	s5,8000360a <readi+0xd2>
    80003570:	e8ca                	sd	s2,80(sp)
    80003572:	f062                	sd	s8,32(sp)
    80003574:	ec66                	sd	s9,24(sp)
    80003576:	e86a                	sd	s10,16(sp)
    80003578:	e46e                	sd	s11,8(sp)
    8000357a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000357c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003580:	5c7d                	li	s8,-1
    80003582:	a80d                	j	800035b4 <readi+0x7c>
    80003584:	020d1d93          	slli	s11,s10,0x20
    80003588:	020ddd93          	srli	s11,s11,0x20
    8000358c:	05890613          	addi	a2,s2,88
    80003590:	86ee                	mv	a3,s11
    80003592:	963a                	add	a2,a2,a4
    80003594:	85d2                	mv	a1,s4
    80003596:	855e                	mv	a0,s7
    80003598:	d83fe0ef          	jal	8000231a <either_copyout>
    8000359c:	05850763          	beq	a0,s8,800035ea <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035a0:	854a                	mv	a0,s2
    800035a2:	f12ff0ef          	jal	80002cb4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035a6:	013d09bb          	addw	s3,s10,s3
    800035aa:	009d04bb          	addw	s1,s10,s1
    800035ae:	9a6e                	add	s4,s4,s11
    800035b0:	0559f763          	bgeu	s3,s5,800035fe <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800035b4:	00a4d59b          	srliw	a1,s1,0xa
    800035b8:	855a                	mv	a0,s6
    800035ba:	977ff0ef          	jal	80002f30 <bmap>
    800035be:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035c2:	c5b1                	beqz	a1,8000360e <readi+0xd6>
    bp = bread(ip->dev, addr);
    800035c4:	000b2503          	lw	a0,0(s6)
    800035c8:	de4ff0ef          	jal	80002bac <bread>
    800035cc:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035ce:	3ff4f713          	andi	a4,s1,1023
    800035d2:	40ec87bb          	subw	a5,s9,a4
    800035d6:	413a86bb          	subw	a3,s5,s3
    800035da:	8d3e                	mv	s10,a5
    800035dc:	2781                	sext.w	a5,a5
    800035de:	0006861b          	sext.w	a2,a3
    800035e2:	faf671e3          	bgeu	a2,a5,80003584 <readi+0x4c>
    800035e6:	8d36                	mv	s10,a3
    800035e8:	bf71                	j	80003584 <readi+0x4c>
      brelse(bp);
    800035ea:	854a                	mv	a0,s2
    800035ec:	ec8ff0ef          	jal	80002cb4 <brelse>
      tot = -1;
    800035f0:	59fd                	li	s3,-1
      break;
    800035f2:	6946                	ld	s2,80(sp)
    800035f4:	7c02                	ld	s8,32(sp)
    800035f6:	6ce2                	ld	s9,24(sp)
    800035f8:	6d42                	ld	s10,16(sp)
    800035fa:	6da2                	ld	s11,8(sp)
    800035fc:	a831                	j	80003618 <readi+0xe0>
    800035fe:	6946                	ld	s2,80(sp)
    80003600:	7c02                	ld	s8,32(sp)
    80003602:	6ce2                	ld	s9,24(sp)
    80003604:	6d42                	ld	s10,16(sp)
    80003606:	6da2                	ld	s11,8(sp)
    80003608:	a801                	j	80003618 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000360a:	89d6                	mv	s3,s5
    8000360c:	a031                	j	80003618 <readi+0xe0>
    8000360e:	6946                	ld	s2,80(sp)
    80003610:	7c02                	ld	s8,32(sp)
    80003612:	6ce2                	ld	s9,24(sp)
    80003614:	6d42                	ld	s10,16(sp)
    80003616:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003618:	0009851b          	sext.w	a0,s3
    8000361c:	69a6                	ld	s3,72(sp)
}
    8000361e:	70a6                	ld	ra,104(sp)
    80003620:	7406                	ld	s0,96(sp)
    80003622:	64e6                	ld	s1,88(sp)
    80003624:	6a06                	ld	s4,64(sp)
    80003626:	7ae2                	ld	s5,56(sp)
    80003628:	7b42                	ld	s6,48(sp)
    8000362a:	7ba2                	ld	s7,40(sp)
    8000362c:	6165                	addi	sp,sp,112
    8000362e:	8082                	ret
    return 0;
    80003630:	4501                	li	a0,0
}
    80003632:	8082                	ret

0000000080003634 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003634:	457c                	lw	a5,76(a0)
    80003636:	10d7e063          	bltu	a5,a3,80003736 <writei+0x102>
{
    8000363a:	7159                	addi	sp,sp,-112
    8000363c:	f486                	sd	ra,104(sp)
    8000363e:	f0a2                	sd	s0,96(sp)
    80003640:	e8ca                	sd	s2,80(sp)
    80003642:	e0d2                	sd	s4,64(sp)
    80003644:	fc56                	sd	s5,56(sp)
    80003646:	f85a                	sd	s6,48(sp)
    80003648:	f45e                	sd	s7,40(sp)
    8000364a:	1880                	addi	s0,sp,112
    8000364c:	8aaa                	mv	s5,a0
    8000364e:	8bae                	mv	s7,a1
    80003650:	8a32                	mv	s4,a2
    80003652:	8936                	mv	s2,a3
    80003654:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003656:	00e687bb          	addw	a5,a3,a4
    8000365a:	0ed7e063          	bltu	a5,a3,8000373a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000365e:	00043737          	lui	a4,0x43
    80003662:	0cf76e63          	bltu	a4,a5,8000373e <writei+0x10a>
    80003666:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003668:	0a0b0f63          	beqz	s6,80003726 <writei+0xf2>
    8000366c:	eca6                	sd	s1,88(sp)
    8000366e:	f062                	sd	s8,32(sp)
    80003670:	ec66                	sd	s9,24(sp)
    80003672:	e86a                	sd	s10,16(sp)
    80003674:	e46e                	sd	s11,8(sp)
    80003676:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003678:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000367c:	5c7d                	li	s8,-1
    8000367e:	a825                	j	800036b6 <writei+0x82>
    80003680:	020d1d93          	slli	s11,s10,0x20
    80003684:	020ddd93          	srli	s11,s11,0x20
    80003688:	05848513          	addi	a0,s1,88
    8000368c:	86ee                	mv	a3,s11
    8000368e:	8652                	mv	a2,s4
    80003690:	85de                	mv	a1,s7
    80003692:	953a                	add	a0,a0,a4
    80003694:	cd1fe0ef          	jal	80002364 <either_copyin>
    80003698:	05850a63          	beq	a0,s8,800036ec <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000369c:	8526                	mv	a0,s1
    8000369e:	660000ef          	jal	80003cfe <log_write>
    brelse(bp);
    800036a2:	8526                	mv	a0,s1
    800036a4:	e10ff0ef          	jal	80002cb4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036a8:	013d09bb          	addw	s3,s10,s3
    800036ac:	012d093b          	addw	s2,s10,s2
    800036b0:	9a6e                	add	s4,s4,s11
    800036b2:	0569f063          	bgeu	s3,s6,800036f2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036b6:	00a9559b          	srliw	a1,s2,0xa
    800036ba:	8556                	mv	a0,s5
    800036bc:	875ff0ef          	jal	80002f30 <bmap>
    800036c0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800036c4:	c59d                	beqz	a1,800036f2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800036c6:	000aa503          	lw	a0,0(s5)
    800036ca:	ce2ff0ef          	jal	80002bac <bread>
    800036ce:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036d0:	3ff97713          	andi	a4,s2,1023
    800036d4:	40ec87bb          	subw	a5,s9,a4
    800036d8:	413b06bb          	subw	a3,s6,s3
    800036dc:	8d3e                	mv	s10,a5
    800036de:	2781                	sext.w	a5,a5
    800036e0:	0006861b          	sext.w	a2,a3
    800036e4:	f8f67ee3          	bgeu	a2,a5,80003680 <writei+0x4c>
    800036e8:	8d36                	mv	s10,a3
    800036ea:	bf59                	j	80003680 <writei+0x4c>
      brelse(bp);
    800036ec:	8526                	mv	a0,s1
    800036ee:	dc6ff0ef          	jal	80002cb4 <brelse>
  }

  if(off > ip->size)
    800036f2:	04caa783          	lw	a5,76(s5)
    800036f6:	0327fa63          	bgeu	a5,s2,8000372a <writei+0xf6>
    ip->size = off;
    800036fa:	052aa623          	sw	s2,76(s5)
    800036fe:	64e6                	ld	s1,88(sp)
    80003700:	7c02                	ld	s8,32(sp)
    80003702:	6ce2                	ld	s9,24(sp)
    80003704:	6d42                	ld	s10,16(sp)
    80003706:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003708:	8556                	mv	a0,s5
    8000370a:	b27ff0ef          	jal	80003230 <iupdate>

  return tot;
    8000370e:	0009851b          	sext.w	a0,s3
    80003712:	69a6                	ld	s3,72(sp)
}
    80003714:	70a6                	ld	ra,104(sp)
    80003716:	7406                	ld	s0,96(sp)
    80003718:	6946                	ld	s2,80(sp)
    8000371a:	6a06                	ld	s4,64(sp)
    8000371c:	7ae2                	ld	s5,56(sp)
    8000371e:	7b42                	ld	s6,48(sp)
    80003720:	7ba2                	ld	s7,40(sp)
    80003722:	6165                	addi	sp,sp,112
    80003724:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003726:	89da                	mv	s3,s6
    80003728:	b7c5                	j	80003708 <writei+0xd4>
    8000372a:	64e6                	ld	s1,88(sp)
    8000372c:	7c02                	ld	s8,32(sp)
    8000372e:	6ce2                	ld	s9,24(sp)
    80003730:	6d42                	ld	s10,16(sp)
    80003732:	6da2                	ld	s11,8(sp)
    80003734:	bfd1                	j	80003708 <writei+0xd4>
    return -1;
    80003736:	557d                	li	a0,-1
}
    80003738:	8082                	ret
    return -1;
    8000373a:	557d                	li	a0,-1
    8000373c:	bfe1                	j	80003714 <writei+0xe0>
    return -1;
    8000373e:	557d                	li	a0,-1
    80003740:	bfd1                	j	80003714 <writei+0xe0>

0000000080003742 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003742:	1141                	addi	sp,sp,-16
    80003744:	e406                	sd	ra,8(sp)
    80003746:	e022                	sd	s0,0(sp)
    80003748:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000374a:	4639                	li	a2,14
    8000374c:	e48fd0ef          	jal	80000d94 <strncmp>
}
    80003750:	60a2                	ld	ra,8(sp)
    80003752:	6402                	ld	s0,0(sp)
    80003754:	0141                	addi	sp,sp,16
    80003756:	8082                	ret

0000000080003758 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003758:	7139                	addi	sp,sp,-64
    8000375a:	fc06                	sd	ra,56(sp)
    8000375c:	f822                	sd	s0,48(sp)
    8000375e:	f426                	sd	s1,40(sp)
    80003760:	f04a                	sd	s2,32(sp)
    80003762:	ec4e                	sd	s3,24(sp)
    80003764:	e852                	sd	s4,16(sp)
    80003766:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003768:	04451703          	lh	a4,68(a0)
    8000376c:	4785                	li	a5,1
    8000376e:	00f71a63          	bne	a4,a5,80003782 <dirlookup+0x2a>
    80003772:	892a                	mv	s2,a0
    80003774:	89ae                	mv	s3,a1
    80003776:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003778:	457c                	lw	a5,76(a0)
    8000377a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000377c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000377e:	e39d                	bnez	a5,800037a4 <dirlookup+0x4c>
    80003780:	a095                	j	800037e4 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003782:	00004517          	auipc	a0,0x4
    80003786:	e4650513          	addi	a0,a0,-442 # 800075c8 <etext+0x5c8>
    8000378a:	80afd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000378e:	00004517          	auipc	a0,0x4
    80003792:	e5250513          	addi	a0,a0,-430 # 800075e0 <etext+0x5e0>
    80003796:	ffffc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000379a:	24c1                	addiw	s1,s1,16
    8000379c:	04c92783          	lw	a5,76(s2)
    800037a0:	04f4f163          	bgeu	s1,a5,800037e2 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037a4:	4741                	li	a4,16
    800037a6:	86a6                	mv	a3,s1
    800037a8:	fc040613          	addi	a2,s0,-64
    800037ac:	4581                	li	a1,0
    800037ae:	854a                	mv	a0,s2
    800037b0:	d89ff0ef          	jal	80003538 <readi>
    800037b4:	47c1                	li	a5,16
    800037b6:	fcf51ce3          	bne	a0,a5,8000378e <dirlookup+0x36>
    if(de.inum == 0)
    800037ba:	fc045783          	lhu	a5,-64(s0)
    800037be:	dff1                	beqz	a5,8000379a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800037c0:	fc240593          	addi	a1,s0,-62
    800037c4:	854e                	mv	a0,s3
    800037c6:	f7dff0ef          	jal	80003742 <namecmp>
    800037ca:	f961                	bnez	a0,8000379a <dirlookup+0x42>
      if(poff)
    800037cc:	000a0463          	beqz	s4,800037d4 <dirlookup+0x7c>
        *poff = off;
    800037d0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800037d4:	fc045583          	lhu	a1,-64(s0)
    800037d8:	00092503          	lw	a0,0(s2)
    800037dc:	829ff0ef          	jal	80003004 <iget>
    800037e0:	a011                	j	800037e4 <dirlookup+0x8c>
  return 0;
    800037e2:	4501                	li	a0,0
}
    800037e4:	70e2                	ld	ra,56(sp)
    800037e6:	7442                	ld	s0,48(sp)
    800037e8:	74a2                	ld	s1,40(sp)
    800037ea:	7902                	ld	s2,32(sp)
    800037ec:	69e2                	ld	s3,24(sp)
    800037ee:	6a42                	ld	s4,16(sp)
    800037f0:	6121                	addi	sp,sp,64
    800037f2:	8082                	ret

00000000800037f4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800037f4:	711d                	addi	sp,sp,-96
    800037f6:	ec86                	sd	ra,88(sp)
    800037f8:	e8a2                	sd	s0,80(sp)
    800037fa:	e4a6                	sd	s1,72(sp)
    800037fc:	e0ca                	sd	s2,64(sp)
    800037fe:	fc4e                	sd	s3,56(sp)
    80003800:	f852                	sd	s4,48(sp)
    80003802:	f456                	sd	s5,40(sp)
    80003804:	f05a                	sd	s6,32(sp)
    80003806:	ec5e                	sd	s7,24(sp)
    80003808:	e862                	sd	s8,16(sp)
    8000380a:	e466                	sd	s9,8(sp)
    8000380c:	1080                	addi	s0,sp,96
    8000380e:	84aa                	mv	s1,a0
    80003810:	8b2e                	mv	s6,a1
    80003812:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003814:	00054703          	lbu	a4,0(a0)
    80003818:	02f00793          	li	a5,47
    8000381c:	00f70e63          	beq	a4,a5,80003838 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003820:	9d0fe0ef          	jal	800019f0 <myproc>
    80003824:	15053503          	ld	a0,336(a0)
    80003828:	a87ff0ef          	jal	800032ae <idup>
    8000382c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000382e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003832:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003834:	4b85                	li	s7,1
    80003836:	a871                	j	800038d2 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003838:	4585                	li	a1,1
    8000383a:	4505                	li	a0,1
    8000383c:	fc8ff0ef          	jal	80003004 <iget>
    80003840:	8a2a                	mv	s4,a0
    80003842:	b7f5                	j	8000382e <namex+0x3a>
      iunlockput(ip);
    80003844:	8552                	mv	a0,s4
    80003846:	ca9ff0ef          	jal	800034ee <iunlockput>
      return 0;
    8000384a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000384c:	8552                	mv	a0,s4
    8000384e:	60e6                	ld	ra,88(sp)
    80003850:	6446                	ld	s0,80(sp)
    80003852:	64a6                	ld	s1,72(sp)
    80003854:	6906                	ld	s2,64(sp)
    80003856:	79e2                	ld	s3,56(sp)
    80003858:	7a42                	ld	s4,48(sp)
    8000385a:	7aa2                	ld	s5,40(sp)
    8000385c:	7b02                	ld	s6,32(sp)
    8000385e:	6be2                	ld	s7,24(sp)
    80003860:	6c42                	ld	s8,16(sp)
    80003862:	6ca2                	ld	s9,8(sp)
    80003864:	6125                	addi	sp,sp,96
    80003866:	8082                	ret
      iunlock(ip);
    80003868:	8552                	mv	a0,s4
    8000386a:	b29ff0ef          	jal	80003392 <iunlock>
      return ip;
    8000386e:	bff9                	j	8000384c <namex+0x58>
      iunlockput(ip);
    80003870:	8552                	mv	a0,s4
    80003872:	c7dff0ef          	jal	800034ee <iunlockput>
      return 0;
    80003876:	8a4e                	mv	s4,s3
    80003878:	bfd1                	j	8000384c <namex+0x58>
  len = path - s;
    8000387a:	40998633          	sub	a2,s3,s1
    8000387e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003882:	099c5063          	bge	s8,s9,80003902 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003886:	4639                	li	a2,14
    80003888:	85a6                	mv	a1,s1
    8000388a:	8556                	mv	a0,s5
    8000388c:	c98fd0ef          	jal	80000d24 <memmove>
    80003890:	84ce                	mv	s1,s3
  while(*path == '/')
    80003892:	0004c783          	lbu	a5,0(s1)
    80003896:	01279763          	bne	a5,s2,800038a4 <namex+0xb0>
    path++;
    8000389a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000389c:	0004c783          	lbu	a5,0(s1)
    800038a0:	ff278de3          	beq	a5,s2,8000389a <namex+0xa6>
    ilock(ip);
    800038a4:	8552                	mv	a0,s4
    800038a6:	a3fff0ef          	jal	800032e4 <ilock>
    if(ip->type != T_DIR){
    800038aa:	044a1783          	lh	a5,68(s4)
    800038ae:	f9779be3          	bne	a5,s7,80003844 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800038b2:	000b0563          	beqz	s6,800038bc <namex+0xc8>
    800038b6:	0004c783          	lbu	a5,0(s1)
    800038ba:	d7dd                	beqz	a5,80003868 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038bc:	4601                	li	a2,0
    800038be:	85d6                	mv	a1,s5
    800038c0:	8552                	mv	a0,s4
    800038c2:	e97ff0ef          	jal	80003758 <dirlookup>
    800038c6:	89aa                	mv	s3,a0
    800038c8:	d545                	beqz	a0,80003870 <namex+0x7c>
    iunlockput(ip);
    800038ca:	8552                	mv	a0,s4
    800038cc:	c23ff0ef          	jal	800034ee <iunlockput>
    ip = next;
    800038d0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800038d2:	0004c783          	lbu	a5,0(s1)
    800038d6:	01279763          	bne	a5,s2,800038e4 <namex+0xf0>
    path++;
    800038da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038dc:	0004c783          	lbu	a5,0(s1)
    800038e0:	ff278de3          	beq	a5,s2,800038da <namex+0xe6>
  if(*path == 0)
    800038e4:	cb8d                	beqz	a5,80003916 <namex+0x122>
  while(*path != '/' && *path != 0)
    800038e6:	0004c783          	lbu	a5,0(s1)
    800038ea:	89a6                	mv	s3,s1
  len = path - s;
    800038ec:	4c81                	li	s9,0
    800038ee:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800038f0:	01278963          	beq	a5,s2,80003902 <namex+0x10e>
    800038f4:	d3d9                	beqz	a5,8000387a <namex+0x86>
    path++;
    800038f6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800038f8:	0009c783          	lbu	a5,0(s3)
    800038fc:	ff279ce3          	bne	a5,s2,800038f4 <namex+0x100>
    80003900:	bfad                	j	8000387a <namex+0x86>
    memmove(name, s, len);
    80003902:	2601                	sext.w	a2,a2
    80003904:	85a6                	mv	a1,s1
    80003906:	8556                	mv	a0,s5
    80003908:	c1cfd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    8000390c:	9cd6                	add	s9,s9,s5
    8000390e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003912:	84ce                	mv	s1,s3
    80003914:	bfbd                	j	80003892 <namex+0x9e>
  if(nameiparent){
    80003916:	f20b0be3          	beqz	s6,8000384c <namex+0x58>
    iput(ip);
    8000391a:	8552                	mv	a0,s4
    8000391c:	b4bff0ef          	jal	80003466 <iput>
    return 0;
    80003920:	4a01                	li	s4,0
    80003922:	b72d                	j	8000384c <namex+0x58>

0000000080003924 <dirlink>:
{
    80003924:	7139                	addi	sp,sp,-64
    80003926:	fc06                	sd	ra,56(sp)
    80003928:	f822                	sd	s0,48(sp)
    8000392a:	f04a                	sd	s2,32(sp)
    8000392c:	ec4e                	sd	s3,24(sp)
    8000392e:	e852                	sd	s4,16(sp)
    80003930:	0080                	addi	s0,sp,64
    80003932:	892a                	mv	s2,a0
    80003934:	8a2e                	mv	s4,a1
    80003936:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003938:	4601                	li	a2,0
    8000393a:	e1fff0ef          	jal	80003758 <dirlookup>
    8000393e:	e535                	bnez	a0,800039aa <dirlink+0x86>
    80003940:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003942:	04c92483          	lw	s1,76(s2)
    80003946:	c48d                	beqz	s1,80003970 <dirlink+0x4c>
    80003948:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000394a:	4741                	li	a4,16
    8000394c:	86a6                	mv	a3,s1
    8000394e:	fc040613          	addi	a2,s0,-64
    80003952:	4581                	li	a1,0
    80003954:	854a                	mv	a0,s2
    80003956:	be3ff0ef          	jal	80003538 <readi>
    8000395a:	47c1                	li	a5,16
    8000395c:	04f51b63          	bne	a0,a5,800039b2 <dirlink+0x8e>
    if(de.inum == 0)
    80003960:	fc045783          	lhu	a5,-64(s0)
    80003964:	c791                	beqz	a5,80003970 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003966:	24c1                	addiw	s1,s1,16
    80003968:	04c92783          	lw	a5,76(s2)
    8000396c:	fcf4efe3          	bltu	s1,a5,8000394a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003970:	4639                	li	a2,14
    80003972:	85d2                	mv	a1,s4
    80003974:	fc240513          	addi	a0,s0,-62
    80003978:	c52fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    8000397c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003980:	4741                	li	a4,16
    80003982:	86a6                	mv	a3,s1
    80003984:	fc040613          	addi	a2,s0,-64
    80003988:	4581                	li	a1,0
    8000398a:	854a                	mv	a0,s2
    8000398c:	ca9ff0ef          	jal	80003634 <writei>
    80003990:	1541                	addi	a0,a0,-16
    80003992:	00a03533          	snez	a0,a0
    80003996:	40a00533          	neg	a0,a0
    8000399a:	74a2                	ld	s1,40(sp)
}
    8000399c:	70e2                	ld	ra,56(sp)
    8000399e:	7442                	ld	s0,48(sp)
    800039a0:	7902                	ld	s2,32(sp)
    800039a2:	69e2                	ld	s3,24(sp)
    800039a4:	6a42                	ld	s4,16(sp)
    800039a6:	6121                	addi	sp,sp,64
    800039a8:	8082                	ret
    iput(ip);
    800039aa:	abdff0ef          	jal	80003466 <iput>
    return -1;
    800039ae:	557d                	li	a0,-1
    800039b0:	b7f5                	j	8000399c <dirlink+0x78>
      panic("dirlink read");
    800039b2:	00004517          	auipc	a0,0x4
    800039b6:	c3e50513          	addi	a0,a0,-962 # 800075f0 <etext+0x5f0>
    800039ba:	ddbfc0ef          	jal	80000794 <panic>

00000000800039be <namei>:

struct inode*
namei(char *path)
{
    800039be:	1101                	addi	sp,sp,-32
    800039c0:	ec06                	sd	ra,24(sp)
    800039c2:	e822                	sd	s0,16(sp)
    800039c4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800039c6:	fe040613          	addi	a2,s0,-32
    800039ca:	4581                	li	a1,0
    800039cc:	e29ff0ef          	jal	800037f4 <namex>
}
    800039d0:	60e2                	ld	ra,24(sp)
    800039d2:	6442                	ld	s0,16(sp)
    800039d4:	6105                	addi	sp,sp,32
    800039d6:	8082                	ret

00000000800039d8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800039d8:	1141                	addi	sp,sp,-16
    800039da:	e406                	sd	ra,8(sp)
    800039dc:	e022                	sd	s0,0(sp)
    800039de:	0800                	addi	s0,sp,16
    800039e0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800039e2:	4585                	li	a1,1
    800039e4:	e11ff0ef          	jal	800037f4 <namex>
}
    800039e8:	60a2                	ld	ra,8(sp)
    800039ea:	6402                	ld	s0,0(sp)
    800039ec:	0141                	addi	sp,sp,16
    800039ee:	8082                	ret

00000000800039f0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800039f0:	1101                	addi	sp,sp,-32
    800039f2:	ec06                	sd	ra,24(sp)
    800039f4:	e822                	sd	s0,16(sp)
    800039f6:	e426                	sd	s1,8(sp)
    800039f8:	e04a                	sd	s2,0(sp)
    800039fa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800039fc:	0001f917          	auipc	s2,0x1f
    80003a00:	a7490913          	addi	s2,s2,-1420 # 80022470 <log>
    80003a04:	01892583          	lw	a1,24(s2)
    80003a08:	02892503          	lw	a0,40(s2)
    80003a0c:	9a0ff0ef          	jal	80002bac <bread>
    80003a10:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a12:	02c92603          	lw	a2,44(s2)
    80003a16:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a18:	00c05f63          	blez	a2,80003a36 <write_head+0x46>
    80003a1c:	0001f717          	auipc	a4,0x1f
    80003a20:	a8470713          	addi	a4,a4,-1404 # 800224a0 <log+0x30>
    80003a24:	87aa                	mv	a5,a0
    80003a26:	060a                	slli	a2,a2,0x2
    80003a28:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a2a:	4314                	lw	a3,0(a4)
    80003a2c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a2e:	0711                	addi	a4,a4,4
    80003a30:	0791                	addi	a5,a5,4
    80003a32:	fec79ce3          	bne	a5,a2,80003a2a <write_head+0x3a>
  }
  bwrite(buf);
    80003a36:	8526                	mv	a0,s1
    80003a38:	a4aff0ef          	jal	80002c82 <bwrite>
  brelse(buf);
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	a76ff0ef          	jal	80002cb4 <brelse>
}
    80003a42:	60e2                	ld	ra,24(sp)
    80003a44:	6442                	ld	s0,16(sp)
    80003a46:	64a2                	ld	s1,8(sp)
    80003a48:	6902                	ld	s2,0(sp)
    80003a4a:	6105                	addi	sp,sp,32
    80003a4c:	8082                	ret

0000000080003a4e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a4e:	0001f797          	auipc	a5,0x1f
    80003a52:	a4e7a783          	lw	a5,-1458(a5) # 8002249c <log+0x2c>
    80003a56:	08f05f63          	blez	a5,80003af4 <install_trans+0xa6>
{
    80003a5a:	7139                	addi	sp,sp,-64
    80003a5c:	fc06                	sd	ra,56(sp)
    80003a5e:	f822                	sd	s0,48(sp)
    80003a60:	f426                	sd	s1,40(sp)
    80003a62:	f04a                	sd	s2,32(sp)
    80003a64:	ec4e                	sd	s3,24(sp)
    80003a66:	e852                	sd	s4,16(sp)
    80003a68:	e456                	sd	s5,8(sp)
    80003a6a:	e05a                	sd	s6,0(sp)
    80003a6c:	0080                	addi	s0,sp,64
    80003a6e:	8b2a                	mv	s6,a0
    80003a70:	0001fa97          	auipc	s5,0x1f
    80003a74:	a30a8a93          	addi	s5,s5,-1488 # 800224a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a78:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a7a:	0001f997          	auipc	s3,0x1f
    80003a7e:	9f698993          	addi	s3,s3,-1546 # 80022470 <log>
    80003a82:	a829                	j	80003a9c <install_trans+0x4e>
    brelse(lbuf);
    80003a84:	854a                	mv	a0,s2
    80003a86:	a2eff0ef          	jal	80002cb4 <brelse>
    brelse(dbuf);
    80003a8a:	8526                	mv	a0,s1
    80003a8c:	a28ff0ef          	jal	80002cb4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a90:	2a05                	addiw	s4,s4,1
    80003a92:	0a91                	addi	s5,s5,4
    80003a94:	02c9a783          	lw	a5,44(s3)
    80003a98:	04fa5463          	bge	s4,a5,80003ae0 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a9c:	0189a583          	lw	a1,24(s3)
    80003aa0:	014585bb          	addw	a1,a1,s4
    80003aa4:	2585                	addiw	a1,a1,1
    80003aa6:	0289a503          	lw	a0,40(s3)
    80003aaa:	902ff0ef          	jal	80002bac <bread>
    80003aae:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ab0:	000aa583          	lw	a1,0(s5)
    80003ab4:	0289a503          	lw	a0,40(s3)
    80003ab8:	8f4ff0ef          	jal	80002bac <bread>
    80003abc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003abe:	40000613          	li	a2,1024
    80003ac2:	05890593          	addi	a1,s2,88
    80003ac6:	05850513          	addi	a0,a0,88
    80003aca:	a5afd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ace:	8526                	mv	a0,s1
    80003ad0:	9b2ff0ef          	jal	80002c82 <bwrite>
    if(recovering == 0)
    80003ad4:	fa0b18e3          	bnez	s6,80003a84 <install_trans+0x36>
      bunpin(dbuf);
    80003ad8:	8526                	mv	a0,s1
    80003ada:	a96ff0ef          	jal	80002d70 <bunpin>
    80003ade:	b75d                	j	80003a84 <install_trans+0x36>
}
    80003ae0:	70e2                	ld	ra,56(sp)
    80003ae2:	7442                	ld	s0,48(sp)
    80003ae4:	74a2                	ld	s1,40(sp)
    80003ae6:	7902                	ld	s2,32(sp)
    80003ae8:	69e2                	ld	s3,24(sp)
    80003aea:	6a42                	ld	s4,16(sp)
    80003aec:	6aa2                	ld	s5,8(sp)
    80003aee:	6b02                	ld	s6,0(sp)
    80003af0:	6121                	addi	sp,sp,64
    80003af2:	8082                	ret
    80003af4:	8082                	ret

0000000080003af6 <initlog>:
{
    80003af6:	7179                	addi	sp,sp,-48
    80003af8:	f406                	sd	ra,40(sp)
    80003afa:	f022                	sd	s0,32(sp)
    80003afc:	ec26                	sd	s1,24(sp)
    80003afe:	e84a                	sd	s2,16(sp)
    80003b00:	e44e                	sd	s3,8(sp)
    80003b02:	1800                	addi	s0,sp,48
    80003b04:	892a                	mv	s2,a0
    80003b06:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b08:	0001f497          	auipc	s1,0x1f
    80003b0c:	96848493          	addi	s1,s1,-1688 # 80022470 <log>
    80003b10:	00004597          	auipc	a1,0x4
    80003b14:	af058593          	addi	a1,a1,-1296 # 80007600 <etext+0x600>
    80003b18:	8526                	mv	a0,s1
    80003b1a:	85afd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003b1e:	0149a583          	lw	a1,20(s3)
    80003b22:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b24:	0109a783          	lw	a5,16(s3)
    80003b28:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b2a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b2e:	854a                	mv	a0,s2
    80003b30:	87cff0ef          	jal	80002bac <bread>
  log.lh.n = lh->n;
    80003b34:	4d30                	lw	a2,88(a0)
    80003b36:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b38:	00c05f63          	blez	a2,80003b56 <initlog+0x60>
    80003b3c:	87aa                	mv	a5,a0
    80003b3e:	0001f717          	auipc	a4,0x1f
    80003b42:	96270713          	addi	a4,a4,-1694 # 800224a0 <log+0x30>
    80003b46:	060a                	slli	a2,a2,0x2
    80003b48:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b4a:	4ff4                	lw	a3,92(a5)
    80003b4c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b4e:	0791                	addi	a5,a5,4
    80003b50:	0711                	addi	a4,a4,4
    80003b52:	fec79ce3          	bne	a5,a2,80003b4a <initlog+0x54>
  brelse(buf);
    80003b56:	95eff0ef          	jal	80002cb4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b5a:	4505                	li	a0,1
    80003b5c:	ef3ff0ef          	jal	80003a4e <install_trans>
  log.lh.n = 0;
    80003b60:	0001f797          	auipc	a5,0x1f
    80003b64:	9207ae23          	sw	zero,-1732(a5) # 8002249c <log+0x2c>
  write_head(); // clear the log
    80003b68:	e89ff0ef          	jal	800039f0 <write_head>
}
    80003b6c:	70a2                	ld	ra,40(sp)
    80003b6e:	7402                	ld	s0,32(sp)
    80003b70:	64e2                	ld	s1,24(sp)
    80003b72:	6942                	ld	s2,16(sp)
    80003b74:	69a2                	ld	s3,8(sp)
    80003b76:	6145                	addi	sp,sp,48
    80003b78:	8082                	ret

0000000080003b7a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b7a:	1101                	addi	sp,sp,-32
    80003b7c:	ec06                	sd	ra,24(sp)
    80003b7e:	e822                	sd	s0,16(sp)
    80003b80:	e426                	sd	s1,8(sp)
    80003b82:	e04a                	sd	s2,0(sp)
    80003b84:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b86:	0001f517          	auipc	a0,0x1f
    80003b8a:	8ea50513          	addi	a0,a0,-1814 # 80022470 <log>
    80003b8e:	866fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003b92:	0001f497          	auipc	s1,0x1f
    80003b96:	8de48493          	addi	s1,s1,-1826 # 80022470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b9a:	4979                	li	s2,30
    80003b9c:	a029                	j	80003ba6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b9e:	85a6                	mv	a1,s1
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	c1cfe0ef          	jal	80001fbe <sleep>
    if(log.committing){
    80003ba6:	50dc                	lw	a5,36(s1)
    80003ba8:	fbfd                	bnez	a5,80003b9e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003baa:	5098                	lw	a4,32(s1)
    80003bac:	2705                	addiw	a4,a4,1
    80003bae:	0027179b          	slliw	a5,a4,0x2
    80003bb2:	9fb9                	addw	a5,a5,a4
    80003bb4:	0017979b          	slliw	a5,a5,0x1
    80003bb8:	54d4                	lw	a3,44(s1)
    80003bba:	9fb5                	addw	a5,a5,a3
    80003bbc:	00f95763          	bge	s2,a5,80003bca <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003bc0:	85a6                	mv	a1,s1
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	bfafe0ef          	jal	80001fbe <sleep>
    80003bc8:	bff9                	j	80003ba6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003bca:	0001f517          	auipc	a0,0x1f
    80003bce:	8a650513          	addi	a0,a0,-1882 # 80022470 <log>
    80003bd2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003bd4:	8b8fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003bd8:	60e2                	ld	ra,24(sp)
    80003bda:	6442                	ld	s0,16(sp)
    80003bdc:	64a2                	ld	s1,8(sp)
    80003bde:	6902                	ld	s2,0(sp)
    80003be0:	6105                	addi	sp,sp,32
    80003be2:	8082                	ret

0000000080003be4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003be4:	7139                	addi	sp,sp,-64
    80003be6:	fc06                	sd	ra,56(sp)
    80003be8:	f822                	sd	s0,48(sp)
    80003bea:	f426                	sd	s1,40(sp)
    80003bec:	f04a                	sd	s2,32(sp)
    80003bee:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003bf0:	0001f497          	auipc	s1,0x1f
    80003bf4:	88048493          	addi	s1,s1,-1920 # 80022470 <log>
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	ffbfc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003bfe:	509c                	lw	a5,32(s1)
    80003c00:	37fd                	addiw	a5,a5,-1
    80003c02:	0007891b          	sext.w	s2,a5
    80003c06:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c08:	50dc                	lw	a5,36(s1)
    80003c0a:	ef9d                	bnez	a5,80003c48 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c0c:	04091763          	bnez	s2,80003c5a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c10:	0001f497          	auipc	s1,0x1f
    80003c14:	86048493          	addi	s1,s1,-1952 # 80022470 <log>
    80003c18:	4785                	li	a5,1
    80003c1a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c1c:	8526                	mv	a0,s1
    80003c1e:	86efd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c22:	54dc                	lw	a5,44(s1)
    80003c24:	04f04b63          	bgtz	a5,80003c7a <end_op+0x96>
    acquire(&log.lock);
    80003c28:	0001f497          	auipc	s1,0x1f
    80003c2c:	84848493          	addi	s1,s1,-1976 # 80022470 <log>
    80003c30:	8526                	mv	a0,s1
    80003c32:	fc3fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003c36:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	bcefe0ef          	jal	8000200a <wakeup>
    release(&log.lock);
    80003c40:	8526                	mv	a0,s1
    80003c42:	84afd0ef          	jal	80000c8c <release>
}
    80003c46:	a025                	j	80003c6e <end_op+0x8a>
    80003c48:	ec4e                	sd	s3,24(sp)
    80003c4a:	e852                	sd	s4,16(sp)
    80003c4c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c4e:	00004517          	auipc	a0,0x4
    80003c52:	9ba50513          	addi	a0,a0,-1606 # 80007608 <etext+0x608>
    80003c56:	b3ffc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003c5a:	0001f497          	auipc	s1,0x1f
    80003c5e:	81648493          	addi	s1,s1,-2026 # 80022470 <log>
    80003c62:	8526                	mv	a0,s1
    80003c64:	ba6fe0ef          	jal	8000200a <wakeup>
  release(&log.lock);
    80003c68:	8526                	mv	a0,s1
    80003c6a:	822fd0ef          	jal	80000c8c <release>
}
    80003c6e:	70e2                	ld	ra,56(sp)
    80003c70:	7442                	ld	s0,48(sp)
    80003c72:	74a2                	ld	s1,40(sp)
    80003c74:	7902                	ld	s2,32(sp)
    80003c76:	6121                	addi	sp,sp,64
    80003c78:	8082                	ret
    80003c7a:	ec4e                	sd	s3,24(sp)
    80003c7c:	e852                	sd	s4,16(sp)
    80003c7e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c80:	0001fa97          	auipc	s5,0x1f
    80003c84:	820a8a93          	addi	s5,s5,-2016 # 800224a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c88:	0001ea17          	auipc	s4,0x1e
    80003c8c:	7e8a0a13          	addi	s4,s4,2024 # 80022470 <log>
    80003c90:	018a2583          	lw	a1,24(s4)
    80003c94:	012585bb          	addw	a1,a1,s2
    80003c98:	2585                	addiw	a1,a1,1
    80003c9a:	028a2503          	lw	a0,40(s4)
    80003c9e:	f0ffe0ef          	jal	80002bac <bread>
    80003ca2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ca4:	000aa583          	lw	a1,0(s5)
    80003ca8:	028a2503          	lw	a0,40(s4)
    80003cac:	f01fe0ef          	jal	80002bac <bread>
    80003cb0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003cb2:	40000613          	li	a2,1024
    80003cb6:	05850593          	addi	a1,a0,88
    80003cba:	05848513          	addi	a0,s1,88
    80003cbe:	866fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	fbffe0ef          	jal	80002c82 <bwrite>
    brelse(from);
    80003cc8:	854e                	mv	a0,s3
    80003cca:	febfe0ef          	jal	80002cb4 <brelse>
    brelse(to);
    80003cce:	8526                	mv	a0,s1
    80003cd0:	fe5fe0ef          	jal	80002cb4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd4:	2905                	addiw	s2,s2,1
    80003cd6:	0a91                	addi	s5,s5,4
    80003cd8:	02ca2783          	lw	a5,44(s4)
    80003cdc:	faf94ae3          	blt	s2,a5,80003c90 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ce0:	d11ff0ef          	jal	800039f0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003ce4:	4501                	li	a0,0
    80003ce6:	d69ff0ef          	jal	80003a4e <install_trans>
    log.lh.n = 0;
    80003cea:	0001e797          	auipc	a5,0x1e
    80003cee:	7a07a923          	sw	zero,1970(a5) # 8002249c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003cf2:	cffff0ef          	jal	800039f0 <write_head>
    80003cf6:	69e2                	ld	s3,24(sp)
    80003cf8:	6a42                	ld	s4,16(sp)
    80003cfa:	6aa2                	ld	s5,8(sp)
    80003cfc:	b735                	j	80003c28 <end_op+0x44>

0000000080003cfe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003cfe:	1101                	addi	sp,sp,-32
    80003d00:	ec06                	sd	ra,24(sp)
    80003d02:	e822                	sd	s0,16(sp)
    80003d04:	e426                	sd	s1,8(sp)
    80003d06:	e04a                	sd	s2,0(sp)
    80003d08:	1000                	addi	s0,sp,32
    80003d0a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d0c:	0001e917          	auipc	s2,0x1e
    80003d10:	76490913          	addi	s2,s2,1892 # 80022470 <log>
    80003d14:	854a                	mv	a0,s2
    80003d16:	edffc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d1a:	02c92603          	lw	a2,44(s2)
    80003d1e:	47f5                	li	a5,29
    80003d20:	06c7c363          	blt	a5,a2,80003d86 <log_write+0x88>
    80003d24:	0001e797          	auipc	a5,0x1e
    80003d28:	7687a783          	lw	a5,1896(a5) # 8002248c <log+0x1c>
    80003d2c:	37fd                	addiw	a5,a5,-1
    80003d2e:	04f65c63          	bge	a2,a5,80003d86 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d32:	0001e797          	auipc	a5,0x1e
    80003d36:	75e7a783          	lw	a5,1886(a5) # 80022490 <log+0x20>
    80003d3a:	04f05c63          	blez	a5,80003d92 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d3e:	4781                	li	a5,0
    80003d40:	04c05f63          	blez	a2,80003d9e <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d44:	44cc                	lw	a1,12(s1)
    80003d46:	0001e717          	auipc	a4,0x1e
    80003d4a:	75a70713          	addi	a4,a4,1882 # 800224a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d4e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d50:	4314                	lw	a3,0(a4)
    80003d52:	04b68663          	beq	a3,a1,80003d9e <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d56:	2785                	addiw	a5,a5,1
    80003d58:	0711                	addi	a4,a4,4
    80003d5a:	fef61be3          	bne	a2,a5,80003d50 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d5e:	0621                	addi	a2,a2,8
    80003d60:	060a                	slli	a2,a2,0x2
    80003d62:	0001e797          	auipc	a5,0x1e
    80003d66:	70e78793          	addi	a5,a5,1806 # 80022470 <log>
    80003d6a:	97b2                	add	a5,a5,a2
    80003d6c:	44d8                	lw	a4,12(s1)
    80003d6e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d70:	8526                	mv	a0,s1
    80003d72:	fcbfe0ef          	jal	80002d3c <bpin>
    log.lh.n++;
    80003d76:	0001e717          	auipc	a4,0x1e
    80003d7a:	6fa70713          	addi	a4,a4,1786 # 80022470 <log>
    80003d7e:	575c                	lw	a5,44(a4)
    80003d80:	2785                	addiw	a5,a5,1
    80003d82:	d75c                	sw	a5,44(a4)
    80003d84:	a80d                	j	80003db6 <log_write+0xb8>
    panic("too big a transaction");
    80003d86:	00004517          	auipc	a0,0x4
    80003d8a:	89250513          	addi	a0,a0,-1902 # 80007618 <etext+0x618>
    80003d8e:	a07fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003d92:	00004517          	auipc	a0,0x4
    80003d96:	89e50513          	addi	a0,a0,-1890 # 80007630 <etext+0x630>
    80003d9a:	9fbfc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003d9e:	00878693          	addi	a3,a5,8
    80003da2:	068a                	slli	a3,a3,0x2
    80003da4:	0001e717          	auipc	a4,0x1e
    80003da8:	6cc70713          	addi	a4,a4,1740 # 80022470 <log>
    80003dac:	9736                	add	a4,a4,a3
    80003dae:	44d4                	lw	a3,12(s1)
    80003db0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003db2:	faf60fe3          	beq	a2,a5,80003d70 <log_write+0x72>
  }
  release(&log.lock);
    80003db6:	0001e517          	auipc	a0,0x1e
    80003dba:	6ba50513          	addi	a0,a0,1722 # 80022470 <log>
    80003dbe:	ecffc0ef          	jal	80000c8c <release>
}
    80003dc2:	60e2                	ld	ra,24(sp)
    80003dc4:	6442                	ld	s0,16(sp)
    80003dc6:	64a2                	ld	s1,8(sp)
    80003dc8:	6902                	ld	s2,0(sp)
    80003dca:	6105                	addi	sp,sp,32
    80003dcc:	8082                	ret

0000000080003dce <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003dce:	1101                	addi	sp,sp,-32
    80003dd0:	ec06                	sd	ra,24(sp)
    80003dd2:	e822                	sd	s0,16(sp)
    80003dd4:	e426                	sd	s1,8(sp)
    80003dd6:	e04a                	sd	s2,0(sp)
    80003dd8:	1000                	addi	s0,sp,32
    80003dda:	84aa                	mv	s1,a0
    80003ddc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003dde:	00004597          	auipc	a1,0x4
    80003de2:	87258593          	addi	a1,a1,-1934 # 80007650 <etext+0x650>
    80003de6:	0521                	addi	a0,a0,8
    80003de8:	d8dfc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003dec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003df0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003df4:	0204a423          	sw	zero,40(s1)
}
    80003df8:	60e2                	ld	ra,24(sp)
    80003dfa:	6442                	ld	s0,16(sp)
    80003dfc:	64a2                	ld	s1,8(sp)
    80003dfe:	6902                	ld	s2,0(sp)
    80003e00:	6105                	addi	sp,sp,32
    80003e02:	8082                	ret

0000000080003e04 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e04:	1101                	addi	sp,sp,-32
    80003e06:	ec06                	sd	ra,24(sp)
    80003e08:	e822                	sd	s0,16(sp)
    80003e0a:	e426                	sd	s1,8(sp)
    80003e0c:	e04a                	sd	s2,0(sp)
    80003e0e:	1000                	addi	s0,sp,32
    80003e10:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e12:	00850913          	addi	s2,a0,8
    80003e16:	854a                	mv	a0,s2
    80003e18:	dddfc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003e1c:	409c                	lw	a5,0(s1)
    80003e1e:	c799                	beqz	a5,80003e2c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e20:	85ca                	mv	a1,s2
    80003e22:	8526                	mv	a0,s1
    80003e24:	99afe0ef          	jal	80001fbe <sleep>
  while (lk->locked) {
    80003e28:	409c                	lw	a5,0(s1)
    80003e2a:	fbfd                	bnez	a5,80003e20 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e2c:	4785                	li	a5,1
    80003e2e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e30:	bc1fd0ef          	jal	800019f0 <myproc>
    80003e34:	591c                	lw	a5,48(a0)
    80003e36:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e38:	854a                	mv	a0,s2
    80003e3a:	e53fc0ef          	jal	80000c8c <release>
}
    80003e3e:	60e2                	ld	ra,24(sp)
    80003e40:	6442                	ld	s0,16(sp)
    80003e42:	64a2                	ld	s1,8(sp)
    80003e44:	6902                	ld	s2,0(sp)
    80003e46:	6105                	addi	sp,sp,32
    80003e48:	8082                	ret

0000000080003e4a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e4a:	1101                	addi	sp,sp,-32
    80003e4c:	ec06                	sd	ra,24(sp)
    80003e4e:	e822                	sd	s0,16(sp)
    80003e50:	e426                	sd	s1,8(sp)
    80003e52:	e04a                	sd	s2,0(sp)
    80003e54:	1000                	addi	s0,sp,32
    80003e56:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e58:	00850913          	addi	s2,a0,8
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	d97fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003e62:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e66:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e6a:	8526                	mv	a0,s1
    80003e6c:	99efe0ef          	jal	8000200a <wakeup>
  release(&lk->lk);
    80003e70:	854a                	mv	a0,s2
    80003e72:	e1bfc0ef          	jal	80000c8c <release>
}
    80003e76:	60e2                	ld	ra,24(sp)
    80003e78:	6442                	ld	s0,16(sp)
    80003e7a:	64a2                	ld	s1,8(sp)
    80003e7c:	6902                	ld	s2,0(sp)
    80003e7e:	6105                	addi	sp,sp,32
    80003e80:	8082                	ret

0000000080003e82 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e82:	7179                	addi	sp,sp,-48
    80003e84:	f406                	sd	ra,40(sp)
    80003e86:	f022                	sd	s0,32(sp)
    80003e88:	ec26                	sd	s1,24(sp)
    80003e8a:	e84a                	sd	s2,16(sp)
    80003e8c:	1800                	addi	s0,sp,48
    80003e8e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e90:	00850913          	addi	s2,a0,8
    80003e94:	854a                	mv	a0,s2
    80003e96:	d5ffc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e9a:	409c                	lw	a5,0(s1)
    80003e9c:	ef81                	bnez	a5,80003eb4 <holdingsleep+0x32>
    80003e9e:	4481                	li	s1,0
  release(&lk->lk);
    80003ea0:	854a                	mv	a0,s2
    80003ea2:	debfc0ef          	jal	80000c8c <release>
  return r;
}
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	70a2                	ld	ra,40(sp)
    80003eaa:	7402                	ld	s0,32(sp)
    80003eac:	64e2                	ld	s1,24(sp)
    80003eae:	6942                	ld	s2,16(sp)
    80003eb0:	6145                	addi	sp,sp,48
    80003eb2:	8082                	ret
    80003eb4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003eb6:	0284a983          	lw	s3,40(s1)
    80003eba:	b37fd0ef          	jal	800019f0 <myproc>
    80003ebe:	5904                	lw	s1,48(a0)
    80003ec0:	413484b3          	sub	s1,s1,s3
    80003ec4:	0014b493          	seqz	s1,s1
    80003ec8:	69a2                	ld	s3,8(sp)
    80003eca:	bfd9                	j	80003ea0 <holdingsleep+0x1e>

0000000080003ecc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ecc:	1141                	addi	sp,sp,-16
    80003ece:	e406                	sd	ra,8(sp)
    80003ed0:	e022                	sd	s0,0(sp)
    80003ed2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ed4:	00003597          	auipc	a1,0x3
    80003ed8:	78c58593          	addi	a1,a1,1932 # 80007660 <etext+0x660>
    80003edc:	0001e517          	auipc	a0,0x1e
    80003ee0:	6dc50513          	addi	a0,a0,1756 # 800225b8 <ftable>
    80003ee4:	c91fc0ef          	jal	80000b74 <initlock>
}
    80003ee8:	60a2                	ld	ra,8(sp)
    80003eea:	6402                	ld	s0,0(sp)
    80003eec:	0141                	addi	sp,sp,16
    80003eee:	8082                	ret

0000000080003ef0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ef0:	1101                	addi	sp,sp,-32
    80003ef2:	ec06                	sd	ra,24(sp)
    80003ef4:	e822                	sd	s0,16(sp)
    80003ef6:	e426                	sd	s1,8(sp)
    80003ef8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003efa:	0001e517          	auipc	a0,0x1e
    80003efe:	6be50513          	addi	a0,a0,1726 # 800225b8 <ftable>
    80003f02:	cf3fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f06:	0001e497          	auipc	s1,0x1e
    80003f0a:	6ca48493          	addi	s1,s1,1738 # 800225d0 <ftable+0x18>
    80003f0e:	0001f717          	auipc	a4,0x1f
    80003f12:	66270713          	addi	a4,a4,1634 # 80023570 <disk>
    if(f->ref == 0){
    80003f16:	40dc                	lw	a5,4(s1)
    80003f18:	cf89                	beqz	a5,80003f32 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f1a:	02848493          	addi	s1,s1,40
    80003f1e:	fee49ce3          	bne	s1,a4,80003f16 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f22:	0001e517          	auipc	a0,0x1e
    80003f26:	69650513          	addi	a0,a0,1686 # 800225b8 <ftable>
    80003f2a:	d63fc0ef          	jal	80000c8c <release>
  return 0;
    80003f2e:	4481                	li	s1,0
    80003f30:	a809                	j	80003f42 <filealloc+0x52>
      f->ref = 1;
    80003f32:	4785                	li	a5,1
    80003f34:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f36:	0001e517          	auipc	a0,0x1e
    80003f3a:	68250513          	addi	a0,a0,1666 # 800225b8 <ftable>
    80003f3e:	d4ffc0ef          	jal	80000c8c <release>
}
    80003f42:	8526                	mv	a0,s1
    80003f44:	60e2                	ld	ra,24(sp)
    80003f46:	6442                	ld	s0,16(sp)
    80003f48:	64a2                	ld	s1,8(sp)
    80003f4a:	6105                	addi	sp,sp,32
    80003f4c:	8082                	ret

0000000080003f4e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f4e:	1101                	addi	sp,sp,-32
    80003f50:	ec06                	sd	ra,24(sp)
    80003f52:	e822                	sd	s0,16(sp)
    80003f54:	e426                	sd	s1,8(sp)
    80003f56:	1000                	addi	s0,sp,32
    80003f58:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f5a:	0001e517          	auipc	a0,0x1e
    80003f5e:	65e50513          	addi	a0,a0,1630 # 800225b8 <ftable>
    80003f62:	c93fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f66:	40dc                	lw	a5,4(s1)
    80003f68:	02f05063          	blez	a5,80003f88 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f6c:	2785                	addiw	a5,a5,1
    80003f6e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f70:	0001e517          	auipc	a0,0x1e
    80003f74:	64850513          	addi	a0,a0,1608 # 800225b8 <ftable>
    80003f78:	d15fc0ef          	jal	80000c8c <release>
  return f;
}
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	60e2                	ld	ra,24(sp)
    80003f80:	6442                	ld	s0,16(sp)
    80003f82:	64a2                	ld	s1,8(sp)
    80003f84:	6105                	addi	sp,sp,32
    80003f86:	8082                	ret
    panic("filedup");
    80003f88:	00003517          	auipc	a0,0x3
    80003f8c:	6e050513          	addi	a0,a0,1760 # 80007668 <etext+0x668>
    80003f90:	805fc0ef          	jal	80000794 <panic>

0000000080003f94 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f94:	7139                	addi	sp,sp,-64
    80003f96:	fc06                	sd	ra,56(sp)
    80003f98:	f822                	sd	s0,48(sp)
    80003f9a:	f426                	sd	s1,40(sp)
    80003f9c:	0080                	addi	s0,sp,64
    80003f9e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003fa0:	0001e517          	auipc	a0,0x1e
    80003fa4:	61850513          	addi	a0,a0,1560 # 800225b8 <ftable>
    80003fa8:	c4dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003fac:	40dc                	lw	a5,4(s1)
    80003fae:	04f05a63          	blez	a5,80004002 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003fb2:	37fd                	addiw	a5,a5,-1
    80003fb4:	0007871b          	sext.w	a4,a5
    80003fb8:	c0dc                	sw	a5,4(s1)
    80003fba:	04e04e63          	bgtz	a4,80004016 <fileclose+0x82>
    80003fbe:	f04a                	sd	s2,32(sp)
    80003fc0:	ec4e                	sd	s3,24(sp)
    80003fc2:	e852                	sd	s4,16(sp)
    80003fc4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003fc6:	0004a903          	lw	s2,0(s1)
    80003fca:	0094ca83          	lbu	s5,9(s1)
    80003fce:	0104ba03          	ld	s4,16(s1)
    80003fd2:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003fd6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003fda:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003fde:	0001e517          	auipc	a0,0x1e
    80003fe2:	5da50513          	addi	a0,a0,1498 # 800225b8 <ftable>
    80003fe6:	ca7fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003fea:	4785                	li	a5,1
    80003fec:	04f90063          	beq	s2,a5,8000402c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003ff0:	3979                	addiw	s2,s2,-2
    80003ff2:	4785                	li	a5,1
    80003ff4:	0527f563          	bgeu	a5,s2,8000403e <fileclose+0xaa>
    80003ff8:	7902                	ld	s2,32(sp)
    80003ffa:	69e2                	ld	s3,24(sp)
    80003ffc:	6a42                	ld	s4,16(sp)
    80003ffe:	6aa2                	ld	s5,8(sp)
    80004000:	a00d                	j	80004022 <fileclose+0x8e>
    80004002:	f04a                	sd	s2,32(sp)
    80004004:	ec4e                	sd	s3,24(sp)
    80004006:	e852                	sd	s4,16(sp)
    80004008:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000400a:	00003517          	auipc	a0,0x3
    8000400e:	66650513          	addi	a0,a0,1638 # 80007670 <etext+0x670>
    80004012:	f82fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004016:	0001e517          	auipc	a0,0x1e
    8000401a:	5a250513          	addi	a0,a0,1442 # 800225b8 <ftable>
    8000401e:	c6ffc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004022:	70e2                	ld	ra,56(sp)
    80004024:	7442                	ld	s0,48(sp)
    80004026:	74a2                	ld	s1,40(sp)
    80004028:	6121                	addi	sp,sp,64
    8000402a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000402c:	85d6                	mv	a1,s5
    8000402e:	8552                	mv	a0,s4
    80004030:	336000ef          	jal	80004366 <pipeclose>
    80004034:	7902                	ld	s2,32(sp)
    80004036:	69e2                	ld	s3,24(sp)
    80004038:	6a42                	ld	s4,16(sp)
    8000403a:	6aa2                	ld	s5,8(sp)
    8000403c:	b7dd                	j	80004022 <fileclose+0x8e>
    begin_op();
    8000403e:	b3dff0ef          	jal	80003b7a <begin_op>
    iput(ff.ip);
    80004042:	854e                	mv	a0,s3
    80004044:	c22ff0ef          	jal	80003466 <iput>
    end_op();
    80004048:	b9dff0ef          	jal	80003be4 <end_op>
    8000404c:	7902                	ld	s2,32(sp)
    8000404e:	69e2                	ld	s3,24(sp)
    80004050:	6a42                	ld	s4,16(sp)
    80004052:	6aa2                	ld	s5,8(sp)
    80004054:	b7f9                	j	80004022 <fileclose+0x8e>

0000000080004056 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004056:	715d                	addi	sp,sp,-80
    80004058:	e486                	sd	ra,72(sp)
    8000405a:	e0a2                	sd	s0,64(sp)
    8000405c:	fc26                	sd	s1,56(sp)
    8000405e:	f44e                	sd	s3,40(sp)
    80004060:	0880                	addi	s0,sp,80
    80004062:	84aa                	mv	s1,a0
    80004064:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004066:	98bfd0ef          	jal	800019f0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000406a:	409c                	lw	a5,0(s1)
    8000406c:	37f9                	addiw	a5,a5,-2
    8000406e:	4705                	li	a4,1
    80004070:	04f76063          	bltu	a4,a5,800040b0 <filestat+0x5a>
    80004074:	f84a                	sd	s2,48(sp)
    80004076:	892a                	mv	s2,a0
    ilock(f->ip);
    80004078:	6c88                	ld	a0,24(s1)
    8000407a:	a6aff0ef          	jal	800032e4 <ilock>
    stati(f->ip, &st);
    8000407e:	fb840593          	addi	a1,s0,-72
    80004082:	6c88                	ld	a0,24(s1)
    80004084:	c8aff0ef          	jal	8000350e <stati>
    iunlock(f->ip);
    80004088:	6c88                	ld	a0,24(s1)
    8000408a:	b08ff0ef          	jal	80003392 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000408e:	46e1                	li	a3,24
    80004090:	fb840613          	addi	a2,s0,-72
    80004094:	85ce                	mv	a1,s3
    80004096:	05093503          	ld	a0,80(s2)
    8000409a:	cb8fd0ef          	jal	80001552 <copyout>
    8000409e:	41f5551b          	sraiw	a0,a0,0x1f
    800040a2:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040a4:	60a6                	ld	ra,72(sp)
    800040a6:	6406                	ld	s0,64(sp)
    800040a8:	74e2                	ld	s1,56(sp)
    800040aa:	79a2                	ld	s3,40(sp)
    800040ac:	6161                	addi	sp,sp,80
    800040ae:	8082                	ret
  return -1;
    800040b0:	557d                	li	a0,-1
    800040b2:	bfcd                	j	800040a4 <filestat+0x4e>

00000000800040b4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040b4:	7179                	addi	sp,sp,-48
    800040b6:	f406                	sd	ra,40(sp)
    800040b8:	f022                	sd	s0,32(sp)
    800040ba:	e84a                	sd	s2,16(sp)
    800040bc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040be:	00854783          	lbu	a5,8(a0)
    800040c2:	cfd1                	beqz	a5,8000415e <fileread+0xaa>
    800040c4:	ec26                	sd	s1,24(sp)
    800040c6:	e44e                	sd	s3,8(sp)
    800040c8:	84aa                	mv	s1,a0
    800040ca:	89ae                	mv	s3,a1
    800040cc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800040ce:	411c                	lw	a5,0(a0)
    800040d0:	4705                	li	a4,1
    800040d2:	04e78363          	beq	a5,a4,80004118 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040d6:	470d                	li	a4,3
    800040d8:	04e78763          	beq	a5,a4,80004126 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800040dc:	4709                	li	a4,2
    800040de:	06e79a63          	bne	a5,a4,80004152 <fileread+0x9e>
    ilock(f->ip);
    800040e2:	6d08                	ld	a0,24(a0)
    800040e4:	a00ff0ef          	jal	800032e4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800040e8:	874a                	mv	a4,s2
    800040ea:	5094                	lw	a3,32(s1)
    800040ec:	864e                	mv	a2,s3
    800040ee:	4585                	li	a1,1
    800040f0:	6c88                	ld	a0,24(s1)
    800040f2:	c46ff0ef          	jal	80003538 <readi>
    800040f6:	892a                	mv	s2,a0
    800040f8:	00a05563          	blez	a0,80004102 <fileread+0x4e>
      f->off += r;
    800040fc:	509c                	lw	a5,32(s1)
    800040fe:	9fa9                	addw	a5,a5,a0
    80004100:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004102:	6c88                	ld	a0,24(s1)
    80004104:	a8eff0ef          	jal	80003392 <iunlock>
    80004108:	64e2                	ld	s1,24(sp)
    8000410a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000410c:	854a                	mv	a0,s2
    8000410e:	70a2                	ld	ra,40(sp)
    80004110:	7402                	ld	s0,32(sp)
    80004112:	6942                	ld	s2,16(sp)
    80004114:	6145                	addi	sp,sp,48
    80004116:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004118:	6908                	ld	a0,16(a0)
    8000411a:	388000ef          	jal	800044a2 <piperead>
    8000411e:	892a                	mv	s2,a0
    80004120:	64e2                	ld	s1,24(sp)
    80004122:	69a2                	ld	s3,8(sp)
    80004124:	b7e5                	j	8000410c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004126:	02451783          	lh	a5,36(a0)
    8000412a:	03079693          	slli	a3,a5,0x30
    8000412e:	92c1                	srli	a3,a3,0x30
    80004130:	4725                	li	a4,9
    80004132:	02d76863          	bltu	a4,a3,80004162 <fileread+0xae>
    80004136:	0792                	slli	a5,a5,0x4
    80004138:	0001e717          	auipc	a4,0x1e
    8000413c:	3e070713          	addi	a4,a4,992 # 80022518 <devsw>
    80004140:	97ba                	add	a5,a5,a4
    80004142:	639c                	ld	a5,0(a5)
    80004144:	c39d                	beqz	a5,8000416a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004146:	4505                	li	a0,1
    80004148:	9782                	jalr	a5
    8000414a:	892a                	mv	s2,a0
    8000414c:	64e2                	ld	s1,24(sp)
    8000414e:	69a2                	ld	s3,8(sp)
    80004150:	bf75                	j	8000410c <fileread+0x58>
    panic("fileread");
    80004152:	00003517          	auipc	a0,0x3
    80004156:	52e50513          	addi	a0,a0,1326 # 80007680 <etext+0x680>
    8000415a:	e3afc0ef          	jal	80000794 <panic>
    return -1;
    8000415e:	597d                	li	s2,-1
    80004160:	b775                	j	8000410c <fileread+0x58>
      return -1;
    80004162:	597d                	li	s2,-1
    80004164:	64e2                	ld	s1,24(sp)
    80004166:	69a2                	ld	s3,8(sp)
    80004168:	b755                	j	8000410c <fileread+0x58>
    8000416a:	597d                	li	s2,-1
    8000416c:	64e2                	ld	s1,24(sp)
    8000416e:	69a2                	ld	s3,8(sp)
    80004170:	bf71                	j	8000410c <fileread+0x58>

0000000080004172 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004172:	00954783          	lbu	a5,9(a0)
    80004176:	10078b63          	beqz	a5,8000428c <filewrite+0x11a>
{
    8000417a:	715d                	addi	sp,sp,-80
    8000417c:	e486                	sd	ra,72(sp)
    8000417e:	e0a2                	sd	s0,64(sp)
    80004180:	f84a                	sd	s2,48(sp)
    80004182:	f052                	sd	s4,32(sp)
    80004184:	e85a                	sd	s6,16(sp)
    80004186:	0880                	addi	s0,sp,80
    80004188:	892a                	mv	s2,a0
    8000418a:	8b2e                	mv	s6,a1
    8000418c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000418e:	411c                	lw	a5,0(a0)
    80004190:	4705                	li	a4,1
    80004192:	02e78763          	beq	a5,a4,800041c0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004196:	470d                	li	a4,3
    80004198:	02e78863          	beq	a5,a4,800041c8 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000419c:	4709                	li	a4,2
    8000419e:	0ce79c63          	bne	a5,a4,80004276 <filewrite+0x104>
    800041a2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041a4:	0ac05863          	blez	a2,80004254 <filewrite+0xe2>
    800041a8:	fc26                	sd	s1,56(sp)
    800041aa:	ec56                	sd	s5,24(sp)
    800041ac:	e45e                	sd	s7,8(sp)
    800041ae:	e062                	sd	s8,0(sp)
    int i = 0;
    800041b0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800041b2:	6b85                	lui	s7,0x1
    800041b4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041b8:	6c05                	lui	s8,0x1
    800041ba:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800041be:	a8b5                	j	8000423a <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800041c0:	6908                	ld	a0,16(a0)
    800041c2:	1fc000ef          	jal	800043be <pipewrite>
    800041c6:	a04d                	j	80004268 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800041c8:	02451783          	lh	a5,36(a0)
    800041cc:	03079693          	slli	a3,a5,0x30
    800041d0:	92c1                	srli	a3,a3,0x30
    800041d2:	4725                	li	a4,9
    800041d4:	0ad76e63          	bltu	a4,a3,80004290 <filewrite+0x11e>
    800041d8:	0792                	slli	a5,a5,0x4
    800041da:	0001e717          	auipc	a4,0x1e
    800041de:	33e70713          	addi	a4,a4,830 # 80022518 <devsw>
    800041e2:	97ba                	add	a5,a5,a4
    800041e4:	679c                	ld	a5,8(a5)
    800041e6:	c7dd                	beqz	a5,80004294 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    800041e8:	4505                	li	a0,1
    800041ea:	9782                	jalr	a5
    800041ec:	a8b5                	j	80004268 <filewrite+0xf6>
      if(n1 > max)
    800041ee:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800041f2:	989ff0ef          	jal	80003b7a <begin_op>
      ilock(f->ip);
    800041f6:	01893503          	ld	a0,24(s2)
    800041fa:	8eaff0ef          	jal	800032e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800041fe:	8756                	mv	a4,s5
    80004200:	02092683          	lw	a3,32(s2)
    80004204:	01698633          	add	a2,s3,s6
    80004208:	4585                	li	a1,1
    8000420a:	01893503          	ld	a0,24(s2)
    8000420e:	c26ff0ef          	jal	80003634 <writei>
    80004212:	84aa                	mv	s1,a0
    80004214:	00a05763          	blez	a0,80004222 <filewrite+0xb0>
        f->off += r;
    80004218:	02092783          	lw	a5,32(s2)
    8000421c:	9fa9                	addw	a5,a5,a0
    8000421e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004222:	01893503          	ld	a0,24(s2)
    80004226:	96cff0ef          	jal	80003392 <iunlock>
      end_op();
    8000422a:	9bbff0ef          	jal	80003be4 <end_op>

      if(r != n1){
    8000422e:	029a9563          	bne	s5,s1,80004258 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004232:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004236:	0149da63          	bge	s3,s4,8000424a <filewrite+0xd8>
      int n1 = n - i;
    8000423a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000423e:	0004879b          	sext.w	a5,s1
    80004242:	fafbd6e3          	bge	s7,a5,800041ee <filewrite+0x7c>
    80004246:	84e2                	mv	s1,s8
    80004248:	b75d                	j	800041ee <filewrite+0x7c>
    8000424a:	74e2                	ld	s1,56(sp)
    8000424c:	6ae2                	ld	s5,24(sp)
    8000424e:	6ba2                	ld	s7,8(sp)
    80004250:	6c02                	ld	s8,0(sp)
    80004252:	a039                	j	80004260 <filewrite+0xee>
    int i = 0;
    80004254:	4981                	li	s3,0
    80004256:	a029                	j	80004260 <filewrite+0xee>
    80004258:	74e2                	ld	s1,56(sp)
    8000425a:	6ae2                	ld	s5,24(sp)
    8000425c:	6ba2                	ld	s7,8(sp)
    8000425e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004260:	033a1c63          	bne	s4,s3,80004298 <filewrite+0x126>
    80004264:	8552                	mv	a0,s4
    80004266:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004268:	60a6                	ld	ra,72(sp)
    8000426a:	6406                	ld	s0,64(sp)
    8000426c:	7942                	ld	s2,48(sp)
    8000426e:	7a02                	ld	s4,32(sp)
    80004270:	6b42                	ld	s6,16(sp)
    80004272:	6161                	addi	sp,sp,80
    80004274:	8082                	ret
    80004276:	fc26                	sd	s1,56(sp)
    80004278:	f44e                	sd	s3,40(sp)
    8000427a:	ec56                	sd	s5,24(sp)
    8000427c:	e45e                	sd	s7,8(sp)
    8000427e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004280:	00003517          	auipc	a0,0x3
    80004284:	41050513          	addi	a0,a0,1040 # 80007690 <etext+0x690>
    80004288:	d0cfc0ef          	jal	80000794 <panic>
    return -1;
    8000428c:	557d                	li	a0,-1
}
    8000428e:	8082                	ret
      return -1;
    80004290:	557d                	li	a0,-1
    80004292:	bfd9                	j	80004268 <filewrite+0xf6>
    80004294:	557d                	li	a0,-1
    80004296:	bfc9                	j	80004268 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004298:	557d                	li	a0,-1
    8000429a:	79a2                	ld	s3,40(sp)
    8000429c:	b7f1                	j	80004268 <filewrite+0xf6>

000000008000429e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000429e:	7179                	addi	sp,sp,-48
    800042a0:	f406                	sd	ra,40(sp)
    800042a2:	f022                	sd	s0,32(sp)
    800042a4:	ec26                	sd	s1,24(sp)
    800042a6:	e052                	sd	s4,0(sp)
    800042a8:	1800                	addi	s0,sp,48
    800042aa:	84aa                	mv	s1,a0
    800042ac:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042ae:	0005b023          	sd	zero,0(a1)
    800042b2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042b6:	c3bff0ef          	jal	80003ef0 <filealloc>
    800042ba:	e088                	sd	a0,0(s1)
    800042bc:	c549                	beqz	a0,80004346 <pipealloc+0xa8>
    800042be:	c33ff0ef          	jal	80003ef0 <filealloc>
    800042c2:	00aa3023          	sd	a0,0(s4)
    800042c6:	cd25                	beqz	a0,8000433e <pipealloc+0xa0>
    800042c8:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800042ca:	85bfc0ef          	jal	80000b24 <kalloc>
    800042ce:	892a                	mv	s2,a0
    800042d0:	c12d                	beqz	a0,80004332 <pipealloc+0x94>
    800042d2:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800042d4:	4985                	li	s3,1
    800042d6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800042da:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800042de:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800042e2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800042e6:	00003597          	auipc	a1,0x3
    800042ea:	3ba58593          	addi	a1,a1,954 # 800076a0 <etext+0x6a0>
    800042ee:	887fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800042f2:	609c                	ld	a5,0(s1)
    800042f4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800042f8:	609c                	ld	a5,0(s1)
    800042fa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800042fe:	609c                	ld	a5,0(s1)
    80004300:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004304:	609c                	ld	a5,0(s1)
    80004306:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000430a:	000a3783          	ld	a5,0(s4)
    8000430e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004312:	000a3783          	ld	a5,0(s4)
    80004316:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000431a:	000a3783          	ld	a5,0(s4)
    8000431e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004322:	000a3783          	ld	a5,0(s4)
    80004326:	0127b823          	sd	s2,16(a5)
  return 0;
    8000432a:	4501                	li	a0,0
    8000432c:	6942                	ld	s2,16(sp)
    8000432e:	69a2                	ld	s3,8(sp)
    80004330:	a01d                	j	80004356 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004332:	6088                	ld	a0,0(s1)
    80004334:	c119                	beqz	a0,8000433a <pipealloc+0x9c>
    80004336:	6942                	ld	s2,16(sp)
    80004338:	a029                	j	80004342 <pipealloc+0xa4>
    8000433a:	6942                	ld	s2,16(sp)
    8000433c:	a029                	j	80004346 <pipealloc+0xa8>
    8000433e:	6088                	ld	a0,0(s1)
    80004340:	c10d                	beqz	a0,80004362 <pipealloc+0xc4>
    fileclose(*f0);
    80004342:	c53ff0ef          	jal	80003f94 <fileclose>
  if(*f1)
    80004346:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000434a:	557d                	li	a0,-1
  if(*f1)
    8000434c:	c789                	beqz	a5,80004356 <pipealloc+0xb8>
    fileclose(*f1);
    8000434e:	853e                	mv	a0,a5
    80004350:	c45ff0ef          	jal	80003f94 <fileclose>
  return -1;
    80004354:	557d                	li	a0,-1
}
    80004356:	70a2                	ld	ra,40(sp)
    80004358:	7402                	ld	s0,32(sp)
    8000435a:	64e2                	ld	s1,24(sp)
    8000435c:	6a02                	ld	s4,0(sp)
    8000435e:	6145                	addi	sp,sp,48
    80004360:	8082                	ret
  return -1;
    80004362:	557d                	li	a0,-1
    80004364:	bfcd                	j	80004356 <pipealloc+0xb8>

0000000080004366 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004366:	1101                	addi	sp,sp,-32
    80004368:	ec06                	sd	ra,24(sp)
    8000436a:	e822                	sd	s0,16(sp)
    8000436c:	e426                	sd	s1,8(sp)
    8000436e:	e04a                	sd	s2,0(sp)
    80004370:	1000                	addi	s0,sp,32
    80004372:	84aa                	mv	s1,a0
    80004374:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004376:	87ffc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000437a:	02090763          	beqz	s2,800043a8 <pipeclose+0x42>
    pi->writeopen = 0;
    8000437e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004382:	21848513          	addi	a0,s1,536
    80004386:	c85fd0ef          	jal	8000200a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000438a:	2204b783          	ld	a5,544(s1)
    8000438e:	e785                	bnez	a5,800043b6 <pipeclose+0x50>
    release(&pi->lock);
    80004390:	8526                	mv	a0,s1
    80004392:	8fbfc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004396:	8526                	mv	a0,s1
    80004398:	eaafc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    8000439c:	60e2                	ld	ra,24(sp)
    8000439e:	6442                	ld	s0,16(sp)
    800043a0:	64a2                	ld	s1,8(sp)
    800043a2:	6902                	ld	s2,0(sp)
    800043a4:	6105                	addi	sp,sp,32
    800043a6:	8082                	ret
    pi->readopen = 0;
    800043a8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043ac:	21c48513          	addi	a0,s1,540
    800043b0:	c5bfd0ef          	jal	8000200a <wakeup>
    800043b4:	bfd9                	j	8000438a <pipeclose+0x24>
    release(&pi->lock);
    800043b6:	8526                	mv	a0,s1
    800043b8:	8d5fc0ef          	jal	80000c8c <release>
}
    800043bc:	b7c5                	j	8000439c <pipeclose+0x36>

00000000800043be <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043be:	711d                	addi	sp,sp,-96
    800043c0:	ec86                	sd	ra,88(sp)
    800043c2:	e8a2                	sd	s0,80(sp)
    800043c4:	e4a6                	sd	s1,72(sp)
    800043c6:	e0ca                	sd	s2,64(sp)
    800043c8:	fc4e                	sd	s3,56(sp)
    800043ca:	f852                	sd	s4,48(sp)
    800043cc:	f456                	sd	s5,40(sp)
    800043ce:	1080                	addi	s0,sp,96
    800043d0:	84aa                	mv	s1,a0
    800043d2:	8aae                	mv	s5,a1
    800043d4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800043d6:	e1afd0ef          	jal	800019f0 <myproc>
    800043da:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800043dc:	8526                	mv	a0,s1
    800043de:	817fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    800043e2:	0b405a63          	blez	s4,80004496 <pipewrite+0xd8>
    800043e6:	f05a                	sd	s6,32(sp)
    800043e8:	ec5e                	sd	s7,24(sp)
    800043ea:	e862                	sd	s8,16(sp)
  int i = 0;
    800043ec:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043ee:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800043f0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800043f4:	21c48b93          	addi	s7,s1,540
    800043f8:	a81d                	j	8000442e <pipewrite+0x70>
      release(&pi->lock);
    800043fa:	8526                	mv	a0,s1
    800043fc:	891fc0ef          	jal	80000c8c <release>
      return -1;
    80004400:	597d                	li	s2,-1
    80004402:	7b02                	ld	s6,32(sp)
    80004404:	6be2                	ld	s7,24(sp)
    80004406:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004408:	854a                	mv	a0,s2
    8000440a:	60e6                	ld	ra,88(sp)
    8000440c:	6446                	ld	s0,80(sp)
    8000440e:	64a6                	ld	s1,72(sp)
    80004410:	6906                	ld	s2,64(sp)
    80004412:	79e2                	ld	s3,56(sp)
    80004414:	7a42                	ld	s4,48(sp)
    80004416:	7aa2                	ld	s5,40(sp)
    80004418:	6125                	addi	sp,sp,96
    8000441a:	8082                	ret
      wakeup(&pi->nread);
    8000441c:	8562                	mv	a0,s8
    8000441e:	bedfd0ef          	jal	8000200a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004422:	85a6                	mv	a1,s1
    80004424:	855e                	mv	a0,s7
    80004426:	b99fd0ef          	jal	80001fbe <sleep>
  while(i < n){
    8000442a:	05495b63          	bge	s2,s4,80004480 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000442e:	2204a783          	lw	a5,544(s1)
    80004432:	d7e1                	beqz	a5,800043fa <pipewrite+0x3c>
    80004434:	854e                	mv	a0,s3
    80004436:	dc1fd0ef          	jal	800021f6 <killed>
    8000443a:	f161                	bnez	a0,800043fa <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000443c:	2184a783          	lw	a5,536(s1)
    80004440:	21c4a703          	lw	a4,540(s1)
    80004444:	2007879b          	addiw	a5,a5,512
    80004448:	fcf70ae3          	beq	a4,a5,8000441c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000444c:	4685                	li	a3,1
    8000444e:	01590633          	add	a2,s2,s5
    80004452:	faf40593          	addi	a1,s0,-81
    80004456:	0509b503          	ld	a0,80(s3)
    8000445a:	9cefd0ef          	jal	80001628 <copyin>
    8000445e:	03650e63          	beq	a0,s6,8000449a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004462:	21c4a783          	lw	a5,540(s1)
    80004466:	0017871b          	addiw	a4,a5,1
    8000446a:	20e4ae23          	sw	a4,540(s1)
    8000446e:	1ff7f793          	andi	a5,a5,511
    80004472:	97a6                	add	a5,a5,s1
    80004474:	faf44703          	lbu	a4,-81(s0)
    80004478:	00e78c23          	sb	a4,24(a5)
      i++;
    8000447c:	2905                	addiw	s2,s2,1
    8000447e:	b775                	j	8000442a <pipewrite+0x6c>
    80004480:	7b02                	ld	s6,32(sp)
    80004482:	6be2                	ld	s7,24(sp)
    80004484:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004486:	21848513          	addi	a0,s1,536
    8000448a:	b81fd0ef          	jal	8000200a <wakeup>
  release(&pi->lock);
    8000448e:	8526                	mv	a0,s1
    80004490:	ffcfc0ef          	jal	80000c8c <release>
  return i;
    80004494:	bf95                	j	80004408 <pipewrite+0x4a>
  int i = 0;
    80004496:	4901                	li	s2,0
    80004498:	b7fd                	j	80004486 <pipewrite+0xc8>
    8000449a:	7b02                	ld	s6,32(sp)
    8000449c:	6be2                	ld	s7,24(sp)
    8000449e:	6c42                	ld	s8,16(sp)
    800044a0:	b7dd                	j	80004486 <pipewrite+0xc8>

00000000800044a2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044a2:	715d                	addi	sp,sp,-80
    800044a4:	e486                	sd	ra,72(sp)
    800044a6:	e0a2                	sd	s0,64(sp)
    800044a8:	fc26                	sd	s1,56(sp)
    800044aa:	f84a                	sd	s2,48(sp)
    800044ac:	f44e                	sd	s3,40(sp)
    800044ae:	f052                	sd	s4,32(sp)
    800044b0:	ec56                	sd	s5,24(sp)
    800044b2:	0880                	addi	s0,sp,80
    800044b4:	84aa                	mv	s1,a0
    800044b6:	892e                	mv	s2,a1
    800044b8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044ba:	d36fd0ef          	jal	800019f0 <myproc>
    800044be:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800044c0:	8526                	mv	a0,s1
    800044c2:	f32fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044c6:	2184a703          	lw	a4,536(s1)
    800044ca:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044ce:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044d2:	02f71563          	bne	a4,a5,800044fc <piperead+0x5a>
    800044d6:	2244a783          	lw	a5,548(s1)
    800044da:	cb85                	beqz	a5,8000450a <piperead+0x68>
    if(killed(pr)){
    800044dc:	8552                	mv	a0,s4
    800044de:	d19fd0ef          	jal	800021f6 <killed>
    800044e2:	ed19                	bnez	a0,80004500 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800044e4:	85a6                	mv	a1,s1
    800044e6:	854e                	mv	a0,s3
    800044e8:	ad7fd0ef          	jal	80001fbe <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800044ec:	2184a703          	lw	a4,536(s1)
    800044f0:	21c4a783          	lw	a5,540(s1)
    800044f4:	fef701e3          	beq	a4,a5,800044d6 <piperead+0x34>
    800044f8:	e85a                	sd	s6,16(sp)
    800044fa:	a809                	j	8000450c <piperead+0x6a>
    800044fc:	e85a                	sd	s6,16(sp)
    800044fe:	a039                	j	8000450c <piperead+0x6a>
      release(&pi->lock);
    80004500:	8526                	mv	a0,s1
    80004502:	f8afc0ef          	jal	80000c8c <release>
      return -1;
    80004506:	59fd                	li	s3,-1
    80004508:	a8b1                	j	80004564 <piperead+0xc2>
    8000450a:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000450c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000450e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004510:	05505263          	blez	s5,80004554 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004514:	2184a783          	lw	a5,536(s1)
    80004518:	21c4a703          	lw	a4,540(s1)
    8000451c:	02f70c63          	beq	a4,a5,80004554 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004520:	0017871b          	addiw	a4,a5,1
    80004524:	20e4ac23          	sw	a4,536(s1)
    80004528:	1ff7f793          	andi	a5,a5,511
    8000452c:	97a6                	add	a5,a5,s1
    8000452e:	0187c783          	lbu	a5,24(a5)
    80004532:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004536:	4685                	li	a3,1
    80004538:	fbf40613          	addi	a2,s0,-65
    8000453c:	85ca                	mv	a1,s2
    8000453e:	050a3503          	ld	a0,80(s4)
    80004542:	810fd0ef          	jal	80001552 <copyout>
    80004546:	01650763          	beq	a0,s6,80004554 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000454a:	2985                	addiw	s3,s3,1
    8000454c:	0905                	addi	s2,s2,1
    8000454e:	fd3a93e3          	bne	s5,s3,80004514 <piperead+0x72>
    80004552:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004554:	21c48513          	addi	a0,s1,540
    80004558:	ab3fd0ef          	jal	8000200a <wakeup>
  release(&pi->lock);
    8000455c:	8526                	mv	a0,s1
    8000455e:	f2efc0ef          	jal	80000c8c <release>
    80004562:	6b42                	ld	s6,16(sp)
  return i;
}
    80004564:	854e                	mv	a0,s3
    80004566:	60a6                	ld	ra,72(sp)
    80004568:	6406                	ld	s0,64(sp)
    8000456a:	74e2                	ld	s1,56(sp)
    8000456c:	7942                	ld	s2,48(sp)
    8000456e:	79a2                	ld	s3,40(sp)
    80004570:	7a02                	ld	s4,32(sp)
    80004572:	6ae2                	ld	s5,24(sp)
    80004574:	6161                	addi	sp,sp,80
    80004576:	8082                	ret

0000000080004578 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004578:	1141                	addi	sp,sp,-16
    8000457a:	e422                	sd	s0,8(sp)
    8000457c:	0800                	addi	s0,sp,16
    8000457e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004580:	8905                	andi	a0,a0,1
    80004582:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004584:	8b89                	andi	a5,a5,2
    80004586:	c399                	beqz	a5,8000458c <flags2perm+0x14>
      perm |= PTE_W;
    80004588:	00456513          	ori	a0,a0,4
    return perm;
}
    8000458c:	6422                	ld	s0,8(sp)
    8000458e:	0141                	addi	sp,sp,16
    80004590:	8082                	ret

0000000080004592 <exec>:

int
exec(char *path, char **argv)
{
    80004592:	df010113          	addi	sp,sp,-528
    80004596:	20113423          	sd	ra,520(sp)
    8000459a:	20813023          	sd	s0,512(sp)
    8000459e:	ffa6                	sd	s1,504(sp)
    800045a0:	fbca                	sd	s2,496(sp)
    800045a2:	0c00                	addi	s0,sp,528
    800045a4:	892a                	mv	s2,a0
    800045a6:	dea43c23          	sd	a0,-520(s0)
    800045aa:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800045ae:	c42fd0ef          	jal	800019f0 <myproc>
    800045b2:	84aa                	mv	s1,a0

  begin_op();
    800045b4:	dc6ff0ef          	jal	80003b7a <begin_op>

  if((ip = namei(path)) == 0){
    800045b8:	854a                	mv	a0,s2
    800045ba:	c04ff0ef          	jal	800039be <namei>
    800045be:	c931                	beqz	a0,80004612 <exec+0x80>
    800045c0:	f3d2                	sd	s4,480(sp)
    800045c2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800045c4:	d21fe0ef          	jal	800032e4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800045c8:	04000713          	li	a4,64
    800045cc:	4681                	li	a3,0
    800045ce:	e5040613          	addi	a2,s0,-432
    800045d2:	4581                	li	a1,0
    800045d4:	8552                	mv	a0,s4
    800045d6:	f63fe0ef          	jal	80003538 <readi>
    800045da:	04000793          	li	a5,64
    800045de:	00f51a63          	bne	a0,a5,800045f2 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800045e2:	e5042703          	lw	a4,-432(s0)
    800045e6:	464c47b7          	lui	a5,0x464c4
    800045ea:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800045ee:	02f70663          	beq	a4,a5,8000461a <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800045f2:	8552                	mv	a0,s4
    800045f4:	efbfe0ef          	jal	800034ee <iunlockput>
    end_op();
    800045f8:	decff0ef          	jal	80003be4 <end_op>
  }
  return -1;
    800045fc:	557d                	li	a0,-1
    800045fe:	7a1e                	ld	s4,480(sp)
}
    80004600:	20813083          	ld	ra,520(sp)
    80004604:	20013403          	ld	s0,512(sp)
    80004608:	74fe                	ld	s1,504(sp)
    8000460a:	795e                	ld	s2,496(sp)
    8000460c:	21010113          	addi	sp,sp,528
    80004610:	8082                	ret
    end_op();
    80004612:	dd2ff0ef          	jal	80003be4 <end_op>
    return -1;
    80004616:	557d                	li	a0,-1
    80004618:	b7e5                	j	80004600 <exec+0x6e>
    8000461a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000461c:	8526                	mv	a0,s1
    8000461e:	c7afd0ef          	jal	80001a98 <proc_pagetable>
    80004622:	8b2a                	mv	s6,a0
    80004624:	2c050b63          	beqz	a0,800048fa <exec+0x368>
    80004628:	f7ce                	sd	s3,488(sp)
    8000462a:	efd6                	sd	s5,472(sp)
    8000462c:	e7de                	sd	s7,456(sp)
    8000462e:	e3e2                	sd	s8,448(sp)
    80004630:	ff66                	sd	s9,440(sp)
    80004632:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004634:	e7042d03          	lw	s10,-400(s0)
    80004638:	e8845783          	lhu	a5,-376(s0)
    8000463c:	12078963          	beqz	a5,8000476e <exec+0x1dc>
    80004640:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004642:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004644:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004646:	6c85                	lui	s9,0x1
    80004648:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000464c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004650:	6a85                	lui	s5,0x1
    80004652:	a085                	j	800046b2 <exec+0x120>
      panic("loadseg: address should exist");
    80004654:	00003517          	auipc	a0,0x3
    80004658:	05450513          	addi	a0,a0,84 # 800076a8 <etext+0x6a8>
    8000465c:	938fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004660:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004662:	8726                	mv	a4,s1
    80004664:	012c06bb          	addw	a3,s8,s2
    80004668:	4581                	li	a1,0
    8000466a:	8552                	mv	a0,s4
    8000466c:	ecdfe0ef          	jal	80003538 <readi>
    80004670:	2501                	sext.w	a0,a0
    80004672:	24a49a63          	bne	s1,a0,800048c6 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004676:	012a893b          	addw	s2,s5,s2
    8000467a:	03397363          	bgeu	s2,s3,800046a0 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000467e:	02091593          	slli	a1,s2,0x20
    80004682:	9181                	srli	a1,a1,0x20
    80004684:	95de                	add	a1,a1,s7
    80004686:	855a                	mv	a0,s6
    80004688:	94ffc0ef          	jal	80000fd6 <walkaddr>
    8000468c:	862a                	mv	a2,a0
    if(pa == 0)
    8000468e:	d179                	beqz	a0,80004654 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004690:	412984bb          	subw	s1,s3,s2
    80004694:	0004879b          	sext.w	a5,s1
    80004698:	fcfcf4e3          	bgeu	s9,a5,80004660 <exec+0xce>
    8000469c:	84d6                	mv	s1,s5
    8000469e:	b7c9                	j	80004660 <exec+0xce>
    sz = sz1;
    800046a0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046a4:	2d85                	addiw	s11,s11,1
    800046a6:	038d0d1b          	addiw	s10,s10,56
    800046aa:	e8845783          	lhu	a5,-376(s0)
    800046ae:	08fdd063          	bge	s11,a5,8000472e <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046b2:	2d01                	sext.w	s10,s10
    800046b4:	03800713          	li	a4,56
    800046b8:	86ea                	mv	a3,s10
    800046ba:	e1840613          	addi	a2,s0,-488
    800046be:	4581                	li	a1,0
    800046c0:	8552                	mv	a0,s4
    800046c2:	e77fe0ef          	jal	80003538 <readi>
    800046c6:	03800793          	li	a5,56
    800046ca:	1cf51663          	bne	a0,a5,80004896 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    800046ce:	e1842783          	lw	a5,-488(s0)
    800046d2:	4705                	li	a4,1
    800046d4:	fce798e3          	bne	a5,a4,800046a4 <exec+0x112>
    if(ph.memsz < ph.filesz)
    800046d8:	e4043483          	ld	s1,-448(s0)
    800046dc:	e3843783          	ld	a5,-456(s0)
    800046e0:	1af4ef63          	bltu	s1,a5,8000489e <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800046e4:	e2843783          	ld	a5,-472(s0)
    800046e8:	94be                	add	s1,s1,a5
    800046ea:	1af4ee63          	bltu	s1,a5,800048a6 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    800046ee:	df043703          	ld	a4,-528(s0)
    800046f2:	8ff9                	and	a5,a5,a4
    800046f4:	1a079d63          	bnez	a5,800048ae <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046f8:	e1c42503          	lw	a0,-484(s0)
    800046fc:	e7dff0ef          	jal	80004578 <flags2perm>
    80004700:	86aa                	mv	a3,a0
    80004702:	8626                	mv	a2,s1
    80004704:	85ca                	mv	a1,s2
    80004706:	855a                	mv	a0,s6
    80004708:	c37fc0ef          	jal	8000133e <uvmalloc>
    8000470c:	e0a43423          	sd	a0,-504(s0)
    80004710:	1a050363          	beqz	a0,800048b6 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004714:	e2843b83          	ld	s7,-472(s0)
    80004718:	e2042c03          	lw	s8,-480(s0)
    8000471c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004720:	00098463          	beqz	s3,80004728 <exec+0x196>
    80004724:	4901                	li	s2,0
    80004726:	bfa1                	j	8000467e <exec+0xec>
    sz = sz1;
    80004728:	e0843903          	ld	s2,-504(s0)
    8000472c:	bfa5                	j	800046a4 <exec+0x112>
    8000472e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004730:	8552                	mv	a0,s4
    80004732:	dbdfe0ef          	jal	800034ee <iunlockput>
  end_op();
    80004736:	caeff0ef          	jal	80003be4 <end_op>
  p = myproc();
    8000473a:	ab6fd0ef          	jal	800019f0 <myproc>
    8000473e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004740:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004744:	6985                	lui	s3,0x1
    80004746:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004748:	99ca                	add	s3,s3,s2
    8000474a:	77fd                	lui	a5,0xfffff
    8000474c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004750:	4691                	li	a3,4
    80004752:	6609                	lui	a2,0x2
    80004754:	964e                	add	a2,a2,s3
    80004756:	85ce                	mv	a1,s3
    80004758:	855a                	mv	a0,s6
    8000475a:	be5fc0ef          	jal	8000133e <uvmalloc>
    8000475e:	892a                	mv	s2,a0
    80004760:	e0a43423          	sd	a0,-504(s0)
    80004764:	e519                	bnez	a0,80004772 <exec+0x1e0>
  if(pagetable)
    80004766:	e1343423          	sd	s3,-504(s0)
    8000476a:	4a01                	li	s4,0
    8000476c:	aab1                	j	800048c8 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000476e:	4901                	li	s2,0
    80004770:	b7c1                	j	80004730 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004772:	75f9                	lui	a1,0xffffe
    80004774:	95aa                	add	a1,a1,a0
    80004776:	855a                	mv	a0,s6
    80004778:	db1fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000477c:	7bfd                	lui	s7,0xfffff
    8000477e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004780:	e0043783          	ld	a5,-512(s0)
    80004784:	6388                	ld	a0,0(a5)
    80004786:	cd39                	beqz	a0,800047e4 <exec+0x252>
    80004788:	e9040993          	addi	s3,s0,-368
    8000478c:	f9040c13          	addi	s8,s0,-112
    80004790:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004792:	ea6fc0ef          	jal	80000e38 <strlen>
    80004796:	0015079b          	addiw	a5,a0,1
    8000479a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000479e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800047a2:	11796e63          	bltu	s2,s7,800048be <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800047a6:	e0043d03          	ld	s10,-512(s0)
    800047aa:	000d3a03          	ld	s4,0(s10)
    800047ae:	8552                	mv	a0,s4
    800047b0:	e88fc0ef          	jal	80000e38 <strlen>
    800047b4:	0015069b          	addiw	a3,a0,1
    800047b8:	8652                	mv	a2,s4
    800047ba:	85ca                	mv	a1,s2
    800047bc:	855a                	mv	a0,s6
    800047be:	d95fc0ef          	jal	80001552 <copyout>
    800047c2:	10054063          	bltz	a0,800048c2 <exec+0x330>
    ustack[argc] = sp;
    800047c6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800047ca:	0485                	addi	s1,s1,1
    800047cc:	008d0793          	addi	a5,s10,8
    800047d0:	e0f43023          	sd	a5,-512(s0)
    800047d4:	008d3503          	ld	a0,8(s10)
    800047d8:	c909                	beqz	a0,800047ea <exec+0x258>
    if(argc >= MAXARG)
    800047da:	09a1                	addi	s3,s3,8
    800047dc:	fb899be3          	bne	s3,s8,80004792 <exec+0x200>
  ip = 0;
    800047e0:	4a01                	li	s4,0
    800047e2:	a0dd                	j	800048c8 <exec+0x336>
  sp = sz;
    800047e4:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800047e8:	4481                	li	s1,0
  ustack[argc] = 0;
    800047ea:	00349793          	slli	a5,s1,0x3
    800047ee:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb8e0>
    800047f2:	97a2                	add	a5,a5,s0
    800047f4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800047f8:	00148693          	addi	a3,s1,1
    800047fc:	068e                	slli	a3,a3,0x3
    800047fe:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004802:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004806:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000480a:	f5796ee3          	bltu	s2,s7,80004766 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000480e:	e9040613          	addi	a2,s0,-368
    80004812:	85ca                	mv	a1,s2
    80004814:	855a                	mv	a0,s6
    80004816:	d3dfc0ef          	jal	80001552 <copyout>
    8000481a:	0e054263          	bltz	a0,800048fe <exec+0x36c>
  p->trapframe->a1 = sp;
    8000481e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004822:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004826:	df843783          	ld	a5,-520(s0)
    8000482a:	0007c703          	lbu	a4,0(a5)
    8000482e:	cf11                	beqz	a4,8000484a <exec+0x2b8>
    80004830:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004832:	02f00693          	li	a3,47
    80004836:	a039                	j	80004844 <exec+0x2b2>
      last = s+1;
    80004838:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000483c:	0785                	addi	a5,a5,1
    8000483e:	fff7c703          	lbu	a4,-1(a5)
    80004842:	c701                	beqz	a4,8000484a <exec+0x2b8>
    if(*s == '/')
    80004844:	fed71ce3          	bne	a4,a3,8000483c <exec+0x2aa>
    80004848:	bfc5                	j	80004838 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000484a:	4641                	li	a2,16
    8000484c:	df843583          	ld	a1,-520(s0)
    80004850:	158a8513          	addi	a0,s5,344
    80004854:	db2fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004858:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000485c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004860:	e0843783          	ld	a5,-504(s0)
    80004864:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004868:	058ab783          	ld	a5,88(s5)
    8000486c:	e6843703          	ld	a4,-408(s0)
    80004870:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004872:	058ab783          	ld	a5,88(s5)
    80004876:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000487a:	85e6                	mv	a1,s9
    8000487c:	aa0fd0ef          	jal	80001b1c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004880:	0004851b          	sext.w	a0,s1
    80004884:	79be                	ld	s3,488(sp)
    80004886:	7a1e                	ld	s4,480(sp)
    80004888:	6afe                	ld	s5,472(sp)
    8000488a:	6b5e                	ld	s6,464(sp)
    8000488c:	6bbe                	ld	s7,456(sp)
    8000488e:	6c1e                	ld	s8,448(sp)
    80004890:	7cfa                	ld	s9,440(sp)
    80004892:	7d5a                	ld	s10,432(sp)
    80004894:	b3b5                	j	80004600 <exec+0x6e>
    80004896:	e1243423          	sd	s2,-504(s0)
    8000489a:	7dba                	ld	s11,424(sp)
    8000489c:	a035                	j	800048c8 <exec+0x336>
    8000489e:	e1243423          	sd	s2,-504(s0)
    800048a2:	7dba                	ld	s11,424(sp)
    800048a4:	a015                	j	800048c8 <exec+0x336>
    800048a6:	e1243423          	sd	s2,-504(s0)
    800048aa:	7dba                	ld	s11,424(sp)
    800048ac:	a831                	j	800048c8 <exec+0x336>
    800048ae:	e1243423          	sd	s2,-504(s0)
    800048b2:	7dba                	ld	s11,424(sp)
    800048b4:	a811                	j	800048c8 <exec+0x336>
    800048b6:	e1243423          	sd	s2,-504(s0)
    800048ba:	7dba                	ld	s11,424(sp)
    800048bc:	a031                	j	800048c8 <exec+0x336>
  ip = 0;
    800048be:	4a01                	li	s4,0
    800048c0:	a021                	j	800048c8 <exec+0x336>
    800048c2:	4a01                	li	s4,0
  if(pagetable)
    800048c4:	a011                	j	800048c8 <exec+0x336>
    800048c6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800048c8:	e0843583          	ld	a1,-504(s0)
    800048cc:	855a                	mv	a0,s6
    800048ce:	a4efd0ef          	jal	80001b1c <proc_freepagetable>
  return -1;
    800048d2:	557d                	li	a0,-1
  if(ip){
    800048d4:	000a1b63          	bnez	s4,800048ea <exec+0x358>
    800048d8:	79be                	ld	s3,488(sp)
    800048da:	7a1e                	ld	s4,480(sp)
    800048dc:	6afe                	ld	s5,472(sp)
    800048de:	6b5e                	ld	s6,464(sp)
    800048e0:	6bbe                	ld	s7,456(sp)
    800048e2:	6c1e                	ld	s8,448(sp)
    800048e4:	7cfa                	ld	s9,440(sp)
    800048e6:	7d5a                	ld	s10,432(sp)
    800048e8:	bb21                	j	80004600 <exec+0x6e>
    800048ea:	79be                	ld	s3,488(sp)
    800048ec:	6afe                	ld	s5,472(sp)
    800048ee:	6b5e                	ld	s6,464(sp)
    800048f0:	6bbe                	ld	s7,456(sp)
    800048f2:	6c1e                	ld	s8,448(sp)
    800048f4:	7cfa                	ld	s9,440(sp)
    800048f6:	7d5a                	ld	s10,432(sp)
    800048f8:	b9ed                	j	800045f2 <exec+0x60>
    800048fa:	6b5e                	ld	s6,464(sp)
    800048fc:	b9dd                	j	800045f2 <exec+0x60>
  sz = sz1;
    800048fe:	e0843983          	ld	s3,-504(s0)
    80004902:	b595                	j	80004766 <exec+0x1d4>

0000000080004904 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004904:	7179                	addi	sp,sp,-48
    80004906:	f406                	sd	ra,40(sp)
    80004908:	f022                	sd	s0,32(sp)
    8000490a:	ec26                	sd	s1,24(sp)
    8000490c:	e84a                	sd	s2,16(sp)
    8000490e:	1800                	addi	s0,sp,48
    80004910:	892e                	mv	s2,a1
    80004912:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004914:	fdc40593          	addi	a1,s0,-36
    80004918:	f8dfd0ef          	jal	800028a4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000491c:	fdc42703          	lw	a4,-36(s0)
    80004920:	47bd                	li	a5,15
    80004922:	02e7e963          	bltu	a5,a4,80004954 <argfd+0x50>
    80004926:	8cafd0ef          	jal	800019f0 <myproc>
    8000492a:	fdc42703          	lw	a4,-36(s0)
    8000492e:	01a70793          	addi	a5,a4,26
    80004932:	078e                	slli	a5,a5,0x3
    80004934:	953e                	add	a0,a0,a5
    80004936:	611c                	ld	a5,0(a0)
    80004938:	c385                	beqz	a5,80004958 <argfd+0x54>
    return -1;
  if(pfd)
    8000493a:	00090463          	beqz	s2,80004942 <argfd+0x3e>
    *pfd = fd;
    8000493e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004942:	4501                	li	a0,0
  if(pf)
    80004944:	c091                	beqz	s1,80004948 <argfd+0x44>
    *pf = f;
    80004946:	e09c                	sd	a5,0(s1)
}
    80004948:	70a2                	ld	ra,40(sp)
    8000494a:	7402                	ld	s0,32(sp)
    8000494c:	64e2                	ld	s1,24(sp)
    8000494e:	6942                	ld	s2,16(sp)
    80004950:	6145                	addi	sp,sp,48
    80004952:	8082                	ret
    return -1;
    80004954:	557d                	li	a0,-1
    80004956:	bfcd                	j	80004948 <argfd+0x44>
    80004958:	557d                	li	a0,-1
    8000495a:	b7fd                	j	80004948 <argfd+0x44>

000000008000495c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000495c:	1101                	addi	sp,sp,-32
    8000495e:	ec06                	sd	ra,24(sp)
    80004960:	e822                	sd	s0,16(sp)
    80004962:	e426                	sd	s1,8(sp)
    80004964:	1000                	addi	s0,sp,32
    80004966:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004968:	888fd0ef          	jal	800019f0 <myproc>
    8000496c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000496e:	0d050793          	addi	a5,a0,208
    80004972:	4501                	li	a0,0
    80004974:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004976:	6398                	ld	a4,0(a5)
    80004978:	cb19                	beqz	a4,8000498e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000497a:	2505                	addiw	a0,a0,1
    8000497c:	07a1                	addi	a5,a5,8
    8000497e:	fed51ce3          	bne	a0,a3,80004976 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004982:	557d                	li	a0,-1
}
    80004984:	60e2                	ld	ra,24(sp)
    80004986:	6442                	ld	s0,16(sp)
    80004988:	64a2                	ld	s1,8(sp)
    8000498a:	6105                	addi	sp,sp,32
    8000498c:	8082                	ret
      p->ofile[fd] = f;
    8000498e:	01a50793          	addi	a5,a0,26
    80004992:	078e                	slli	a5,a5,0x3
    80004994:	963e                	add	a2,a2,a5
    80004996:	e204                	sd	s1,0(a2)
      return fd;
    80004998:	b7f5                	j	80004984 <fdalloc+0x28>

000000008000499a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000499a:	715d                	addi	sp,sp,-80
    8000499c:	e486                	sd	ra,72(sp)
    8000499e:	e0a2                	sd	s0,64(sp)
    800049a0:	fc26                	sd	s1,56(sp)
    800049a2:	f84a                	sd	s2,48(sp)
    800049a4:	f44e                	sd	s3,40(sp)
    800049a6:	ec56                	sd	s5,24(sp)
    800049a8:	e85a                	sd	s6,16(sp)
    800049aa:	0880                	addi	s0,sp,80
    800049ac:	8b2e                	mv	s6,a1
    800049ae:	89b2                	mv	s3,a2
    800049b0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800049b2:	fb040593          	addi	a1,s0,-80
    800049b6:	822ff0ef          	jal	800039d8 <nameiparent>
    800049ba:	84aa                	mv	s1,a0
    800049bc:	10050a63          	beqz	a0,80004ad0 <create+0x136>
    return 0;

  ilock(dp);
    800049c0:	925fe0ef          	jal	800032e4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800049c4:	4601                	li	a2,0
    800049c6:	fb040593          	addi	a1,s0,-80
    800049ca:	8526                	mv	a0,s1
    800049cc:	d8dfe0ef          	jal	80003758 <dirlookup>
    800049d0:	8aaa                	mv	s5,a0
    800049d2:	c129                	beqz	a0,80004a14 <create+0x7a>
    iunlockput(dp);
    800049d4:	8526                	mv	a0,s1
    800049d6:	b19fe0ef          	jal	800034ee <iunlockput>
    ilock(ip);
    800049da:	8556                	mv	a0,s5
    800049dc:	909fe0ef          	jal	800032e4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800049e0:	4789                	li	a5,2
    800049e2:	02fb1463          	bne	s6,a5,80004a0a <create+0x70>
    800049e6:	044ad783          	lhu	a5,68(s5)
    800049ea:	37f9                	addiw	a5,a5,-2
    800049ec:	17c2                	slli	a5,a5,0x30
    800049ee:	93c1                	srli	a5,a5,0x30
    800049f0:	4705                	li	a4,1
    800049f2:	00f76c63          	bltu	a4,a5,80004a0a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800049f6:	8556                	mv	a0,s5
    800049f8:	60a6                	ld	ra,72(sp)
    800049fa:	6406                	ld	s0,64(sp)
    800049fc:	74e2                	ld	s1,56(sp)
    800049fe:	7942                	ld	s2,48(sp)
    80004a00:	79a2                	ld	s3,40(sp)
    80004a02:	6ae2                	ld	s5,24(sp)
    80004a04:	6b42                	ld	s6,16(sp)
    80004a06:	6161                	addi	sp,sp,80
    80004a08:	8082                	ret
    iunlockput(ip);
    80004a0a:	8556                	mv	a0,s5
    80004a0c:	ae3fe0ef          	jal	800034ee <iunlockput>
    return 0;
    80004a10:	4a81                	li	s5,0
    80004a12:	b7d5                	j	800049f6 <create+0x5c>
    80004a14:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a16:	85da                	mv	a1,s6
    80004a18:	4088                	lw	a0,0(s1)
    80004a1a:	f5afe0ef          	jal	80003174 <ialloc>
    80004a1e:	8a2a                	mv	s4,a0
    80004a20:	cd15                	beqz	a0,80004a5c <create+0xc2>
  ilock(ip);
    80004a22:	8c3fe0ef          	jal	800032e4 <ilock>
  ip->major = major;
    80004a26:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a2a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a2e:	4905                	li	s2,1
    80004a30:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a34:	8552                	mv	a0,s4
    80004a36:	ffafe0ef          	jal	80003230 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a3a:	032b0763          	beq	s6,s2,80004a68 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a3e:	004a2603          	lw	a2,4(s4)
    80004a42:	fb040593          	addi	a1,s0,-80
    80004a46:	8526                	mv	a0,s1
    80004a48:	eddfe0ef          	jal	80003924 <dirlink>
    80004a4c:	06054563          	bltz	a0,80004ab6 <create+0x11c>
  iunlockput(dp);
    80004a50:	8526                	mv	a0,s1
    80004a52:	a9dfe0ef          	jal	800034ee <iunlockput>
  return ip;
    80004a56:	8ad2                	mv	s5,s4
    80004a58:	7a02                	ld	s4,32(sp)
    80004a5a:	bf71                	j	800049f6 <create+0x5c>
    iunlockput(dp);
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	a91fe0ef          	jal	800034ee <iunlockput>
    return 0;
    80004a62:	8ad2                	mv	s5,s4
    80004a64:	7a02                	ld	s4,32(sp)
    80004a66:	bf41                	j	800049f6 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a68:	004a2603          	lw	a2,4(s4)
    80004a6c:	00003597          	auipc	a1,0x3
    80004a70:	c5c58593          	addi	a1,a1,-932 # 800076c8 <etext+0x6c8>
    80004a74:	8552                	mv	a0,s4
    80004a76:	eaffe0ef          	jal	80003924 <dirlink>
    80004a7a:	02054e63          	bltz	a0,80004ab6 <create+0x11c>
    80004a7e:	40d0                	lw	a2,4(s1)
    80004a80:	00003597          	auipc	a1,0x3
    80004a84:	c5058593          	addi	a1,a1,-944 # 800076d0 <etext+0x6d0>
    80004a88:	8552                	mv	a0,s4
    80004a8a:	e9bfe0ef          	jal	80003924 <dirlink>
    80004a8e:	02054463          	bltz	a0,80004ab6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a92:	004a2603          	lw	a2,4(s4)
    80004a96:	fb040593          	addi	a1,s0,-80
    80004a9a:	8526                	mv	a0,s1
    80004a9c:	e89fe0ef          	jal	80003924 <dirlink>
    80004aa0:	00054b63          	bltz	a0,80004ab6 <create+0x11c>
    dp->nlink++;  // for ".."
    80004aa4:	04a4d783          	lhu	a5,74(s1)
    80004aa8:	2785                	addiw	a5,a5,1
    80004aaa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004aae:	8526                	mv	a0,s1
    80004ab0:	f80fe0ef          	jal	80003230 <iupdate>
    80004ab4:	bf71                	j	80004a50 <create+0xb6>
  ip->nlink = 0;
    80004ab6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004aba:	8552                	mv	a0,s4
    80004abc:	f74fe0ef          	jal	80003230 <iupdate>
  iunlockput(ip);
    80004ac0:	8552                	mv	a0,s4
    80004ac2:	a2dfe0ef          	jal	800034ee <iunlockput>
  iunlockput(dp);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	a27fe0ef          	jal	800034ee <iunlockput>
  return 0;
    80004acc:	7a02                	ld	s4,32(sp)
    80004ace:	b725                	j	800049f6 <create+0x5c>
    return 0;
    80004ad0:	8aaa                	mv	s5,a0
    80004ad2:	b715                	j	800049f6 <create+0x5c>

0000000080004ad4 <sys_dup>:
{
    80004ad4:	7179                	addi	sp,sp,-48
    80004ad6:	f406                	sd	ra,40(sp)
    80004ad8:	f022                	sd	s0,32(sp)
    80004ada:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004adc:	fd840613          	addi	a2,s0,-40
    80004ae0:	4581                	li	a1,0
    80004ae2:	4501                	li	a0,0
    80004ae4:	e21ff0ef          	jal	80004904 <argfd>
    return -1;
    80004ae8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004aea:	02054363          	bltz	a0,80004b10 <sys_dup+0x3c>
    80004aee:	ec26                	sd	s1,24(sp)
    80004af0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004af2:	fd843903          	ld	s2,-40(s0)
    80004af6:	854a                	mv	a0,s2
    80004af8:	e65ff0ef          	jal	8000495c <fdalloc>
    80004afc:	84aa                	mv	s1,a0
    return -1;
    80004afe:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b00:	00054d63          	bltz	a0,80004b1a <sys_dup+0x46>
  filedup(f);
    80004b04:	854a                	mv	a0,s2
    80004b06:	c48ff0ef          	jal	80003f4e <filedup>
  return fd;
    80004b0a:	87a6                	mv	a5,s1
    80004b0c:	64e2                	ld	s1,24(sp)
    80004b0e:	6942                	ld	s2,16(sp)
}
    80004b10:	853e                	mv	a0,a5
    80004b12:	70a2                	ld	ra,40(sp)
    80004b14:	7402                	ld	s0,32(sp)
    80004b16:	6145                	addi	sp,sp,48
    80004b18:	8082                	ret
    80004b1a:	64e2                	ld	s1,24(sp)
    80004b1c:	6942                	ld	s2,16(sp)
    80004b1e:	bfcd                	j	80004b10 <sys_dup+0x3c>

0000000080004b20 <sys_read>:
{
    80004b20:	7179                	addi	sp,sp,-48
    80004b22:	f406                	sd	ra,40(sp)
    80004b24:	f022                	sd	s0,32(sp)
    80004b26:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b28:	fd840593          	addi	a1,s0,-40
    80004b2c:	4505                	li	a0,1
    80004b2e:	d93fd0ef          	jal	800028c0 <argaddr>
  argint(2, &n);
    80004b32:	fe440593          	addi	a1,s0,-28
    80004b36:	4509                	li	a0,2
    80004b38:	d6dfd0ef          	jal	800028a4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b3c:	fe840613          	addi	a2,s0,-24
    80004b40:	4581                	li	a1,0
    80004b42:	4501                	li	a0,0
    80004b44:	dc1ff0ef          	jal	80004904 <argfd>
    80004b48:	87aa                	mv	a5,a0
    return -1;
    80004b4a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b4c:	0007ca63          	bltz	a5,80004b60 <sys_read+0x40>
  return fileread(f, p, n);
    80004b50:	fe442603          	lw	a2,-28(s0)
    80004b54:	fd843583          	ld	a1,-40(s0)
    80004b58:	fe843503          	ld	a0,-24(s0)
    80004b5c:	d58ff0ef          	jal	800040b4 <fileread>
}
    80004b60:	70a2                	ld	ra,40(sp)
    80004b62:	7402                	ld	s0,32(sp)
    80004b64:	6145                	addi	sp,sp,48
    80004b66:	8082                	ret

0000000080004b68 <sys_write>:
{
    80004b68:	7179                	addi	sp,sp,-48
    80004b6a:	f406                	sd	ra,40(sp)
    80004b6c:	f022                	sd	s0,32(sp)
    80004b6e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b70:	fd840593          	addi	a1,s0,-40
    80004b74:	4505                	li	a0,1
    80004b76:	d4bfd0ef          	jal	800028c0 <argaddr>
  argint(2, &n);
    80004b7a:	fe440593          	addi	a1,s0,-28
    80004b7e:	4509                	li	a0,2
    80004b80:	d25fd0ef          	jal	800028a4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b84:	fe840613          	addi	a2,s0,-24
    80004b88:	4581                	li	a1,0
    80004b8a:	4501                	li	a0,0
    80004b8c:	d79ff0ef          	jal	80004904 <argfd>
    80004b90:	87aa                	mv	a5,a0
    return -1;
    80004b92:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b94:	0007ca63          	bltz	a5,80004ba8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b98:	fe442603          	lw	a2,-28(s0)
    80004b9c:	fd843583          	ld	a1,-40(s0)
    80004ba0:	fe843503          	ld	a0,-24(s0)
    80004ba4:	dceff0ef          	jal	80004172 <filewrite>
}
    80004ba8:	70a2                	ld	ra,40(sp)
    80004baa:	7402                	ld	s0,32(sp)
    80004bac:	6145                	addi	sp,sp,48
    80004bae:	8082                	ret

0000000080004bb0 <sys_close>:
{
    80004bb0:	1101                	addi	sp,sp,-32
    80004bb2:	ec06                	sd	ra,24(sp)
    80004bb4:	e822                	sd	s0,16(sp)
    80004bb6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004bb8:	fe040613          	addi	a2,s0,-32
    80004bbc:	fec40593          	addi	a1,s0,-20
    80004bc0:	4501                	li	a0,0
    80004bc2:	d43ff0ef          	jal	80004904 <argfd>
    return -1;
    80004bc6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004bc8:	02054063          	bltz	a0,80004be8 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004bcc:	e25fc0ef          	jal	800019f0 <myproc>
    80004bd0:	fec42783          	lw	a5,-20(s0)
    80004bd4:	07e9                	addi	a5,a5,26
    80004bd6:	078e                	slli	a5,a5,0x3
    80004bd8:	953e                	add	a0,a0,a5
    80004bda:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004bde:	fe043503          	ld	a0,-32(s0)
    80004be2:	bb2ff0ef          	jal	80003f94 <fileclose>
  return 0;
    80004be6:	4781                	li	a5,0
}
    80004be8:	853e                	mv	a0,a5
    80004bea:	60e2                	ld	ra,24(sp)
    80004bec:	6442                	ld	s0,16(sp)
    80004bee:	6105                	addi	sp,sp,32
    80004bf0:	8082                	ret

0000000080004bf2 <sys_fstat>:
{
    80004bf2:	1101                	addi	sp,sp,-32
    80004bf4:	ec06                	sd	ra,24(sp)
    80004bf6:	e822                	sd	s0,16(sp)
    80004bf8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004bfa:	fe040593          	addi	a1,s0,-32
    80004bfe:	4505                	li	a0,1
    80004c00:	cc1fd0ef          	jal	800028c0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c04:	fe840613          	addi	a2,s0,-24
    80004c08:	4581                	li	a1,0
    80004c0a:	4501                	li	a0,0
    80004c0c:	cf9ff0ef          	jal	80004904 <argfd>
    80004c10:	87aa                	mv	a5,a0
    return -1;
    80004c12:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c14:	0007c863          	bltz	a5,80004c24 <sys_fstat+0x32>
  return filestat(f, st);
    80004c18:	fe043583          	ld	a1,-32(s0)
    80004c1c:	fe843503          	ld	a0,-24(s0)
    80004c20:	c36ff0ef          	jal	80004056 <filestat>
}
    80004c24:	60e2                	ld	ra,24(sp)
    80004c26:	6442                	ld	s0,16(sp)
    80004c28:	6105                	addi	sp,sp,32
    80004c2a:	8082                	ret

0000000080004c2c <sys_link>:
{
    80004c2c:	7169                	addi	sp,sp,-304
    80004c2e:	f606                	sd	ra,296(sp)
    80004c30:	f222                	sd	s0,288(sp)
    80004c32:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c34:	08000613          	li	a2,128
    80004c38:	ed040593          	addi	a1,s0,-304
    80004c3c:	4501                	li	a0,0
    80004c3e:	c9ffd0ef          	jal	800028dc <argstr>
    return -1;
    80004c42:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c44:	0c054e63          	bltz	a0,80004d20 <sys_link+0xf4>
    80004c48:	08000613          	li	a2,128
    80004c4c:	f5040593          	addi	a1,s0,-176
    80004c50:	4505                	li	a0,1
    80004c52:	c8bfd0ef          	jal	800028dc <argstr>
    return -1;
    80004c56:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c58:	0c054463          	bltz	a0,80004d20 <sys_link+0xf4>
    80004c5c:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c5e:	f1dfe0ef          	jal	80003b7a <begin_op>
  if((ip = namei(old)) == 0){
    80004c62:	ed040513          	addi	a0,s0,-304
    80004c66:	d59fe0ef          	jal	800039be <namei>
    80004c6a:	84aa                	mv	s1,a0
    80004c6c:	c53d                	beqz	a0,80004cda <sys_link+0xae>
  ilock(ip);
    80004c6e:	e76fe0ef          	jal	800032e4 <ilock>
  if(ip->type == T_DIR){
    80004c72:	04449703          	lh	a4,68(s1)
    80004c76:	4785                	li	a5,1
    80004c78:	06f70663          	beq	a4,a5,80004ce4 <sys_link+0xb8>
    80004c7c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004c7e:	04a4d783          	lhu	a5,74(s1)
    80004c82:	2785                	addiw	a5,a5,1
    80004c84:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c88:	8526                	mv	a0,s1
    80004c8a:	da6fe0ef          	jal	80003230 <iupdate>
  iunlock(ip);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	f02fe0ef          	jal	80003392 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c94:	fd040593          	addi	a1,s0,-48
    80004c98:	f5040513          	addi	a0,s0,-176
    80004c9c:	d3dfe0ef          	jal	800039d8 <nameiparent>
    80004ca0:	892a                	mv	s2,a0
    80004ca2:	cd21                	beqz	a0,80004cfa <sys_link+0xce>
  ilock(dp);
    80004ca4:	e40fe0ef          	jal	800032e4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ca8:	00092703          	lw	a4,0(s2)
    80004cac:	409c                	lw	a5,0(s1)
    80004cae:	04f71363          	bne	a4,a5,80004cf4 <sys_link+0xc8>
    80004cb2:	40d0                	lw	a2,4(s1)
    80004cb4:	fd040593          	addi	a1,s0,-48
    80004cb8:	854a                	mv	a0,s2
    80004cba:	c6bfe0ef          	jal	80003924 <dirlink>
    80004cbe:	02054b63          	bltz	a0,80004cf4 <sys_link+0xc8>
  iunlockput(dp);
    80004cc2:	854a                	mv	a0,s2
    80004cc4:	82bfe0ef          	jal	800034ee <iunlockput>
  iput(ip);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	f9cfe0ef          	jal	80003466 <iput>
  end_op();
    80004cce:	f17fe0ef          	jal	80003be4 <end_op>
  return 0;
    80004cd2:	4781                	li	a5,0
    80004cd4:	64f2                	ld	s1,280(sp)
    80004cd6:	6952                	ld	s2,272(sp)
    80004cd8:	a0a1                	j	80004d20 <sys_link+0xf4>
    end_op();
    80004cda:	f0bfe0ef          	jal	80003be4 <end_op>
    return -1;
    80004cde:	57fd                	li	a5,-1
    80004ce0:	64f2                	ld	s1,280(sp)
    80004ce2:	a83d                	j	80004d20 <sys_link+0xf4>
    iunlockput(ip);
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	809fe0ef          	jal	800034ee <iunlockput>
    end_op();
    80004cea:	efbfe0ef          	jal	80003be4 <end_op>
    return -1;
    80004cee:	57fd                	li	a5,-1
    80004cf0:	64f2                	ld	s1,280(sp)
    80004cf2:	a03d                	j	80004d20 <sys_link+0xf4>
    iunlockput(dp);
    80004cf4:	854a                	mv	a0,s2
    80004cf6:	ff8fe0ef          	jal	800034ee <iunlockput>
  ilock(ip);
    80004cfa:	8526                	mv	a0,s1
    80004cfc:	de8fe0ef          	jal	800032e4 <ilock>
  ip->nlink--;
    80004d00:	04a4d783          	lhu	a5,74(s1)
    80004d04:	37fd                	addiw	a5,a5,-1
    80004d06:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	d24fe0ef          	jal	80003230 <iupdate>
  iunlockput(ip);
    80004d10:	8526                	mv	a0,s1
    80004d12:	fdcfe0ef          	jal	800034ee <iunlockput>
  end_op();
    80004d16:	ecffe0ef          	jal	80003be4 <end_op>
  return -1;
    80004d1a:	57fd                	li	a5,-1
    80004d1c:	64f2                	ld	s1,280(sp)
    80004d1e:	6952                	ld	s2,272(sp)
}
    80004d20:	853e                	mv	a0,a5
    80004d22:	70b2                	ld	ra,296(sp)
    80004d24:	7412                	ld	s0,288(sp)
    80004d26:	6155                	addi	sp,sp,304
    80004d28:	8082                	ret

0000000080004d2a <sys_unlink>:
{
    80004d2a:	7151                	addi	sp,sp,-240
    80004d2c:	f586                	sd	ra,232(sp)
    80004d2e:	f1a2                	sd	s0,224(sp)
    80004d30:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d32:	08000613          	li	a2,128
    80004d36:	f3040593          	addi	a1,s0,-208
    80004d3a:	4501                	li	a0,0
    80004d3c:	ba1fd0ef          	jal	800028dc <argstr>
    80004d40:	16054063          	bltz	a0,80004ea0 <sys_unlink+0x176>
    80004d44:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d46:	e35fe0ef          	jal	80003b7a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d4a:	fb040593          	addi	a1,s0,-80
    80004d4e:	f3040513          	addi	a0,s0,-208
    80004d52:	c87fe0ef          	jal	800039d8 <nameiparent>
    80004d56:	84aa                	mv	s1,a0
    80004d58:	c945                	beqz	a0,80004e08 <sys_unlink+0xde>
  ilock(dp);
    80004d5a:	d8afe0ef          	jal	800032e4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d5e:	00003597          	auipc	a1,0x3
    80004d62:	96a58593          	addi	a1,a1,-1686 # 800076c8 <etext+0x6c8>
    80004d66:	fb040513          	addi	a0,s0,-80
    80004d6a:	9d9fe0ef          	jal	80003742 <namecmp>
    80004d6e:	10050e63          	beqz	a0,80004e8a <sys_unlink+0x160>
    80004d72:	00003597          	auipc	a1,0x3
    80004d76:	95e58593          	addi	a1,a1,-1698 # 800076d0 <etext+0x6d0>
    80004d7a:	fb040513          	addi	a0,s0,-80
    80004d7e:	9c5fe0ef          	jal	80003742 <namecmp>
    80004d82:	10050463          	beqz	a0,80004e8a <sys_unlink+0x160>
    80004d86:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d88:	f2c40613          	addi	a2,s0,-212
    80004d8c:	fb040593          	addi	a1,s0,-80
    80004d90:	8526                	mv	a0,s1
    80004d92:	9c7fe0ef          	jal	80003758 <dirlookup>
    80004d96:	892a                	mv	s2,a0
    80004d98:	0e050863          	beqz	a0,80004e88 <sys_unlink+0x15e>
  ilock(ip);
    80004d9c:	d48fe0ef          	jal	800032e4 <ilock>
  if(ip->nlink < 1)
    80004da0:	04a91783          	lh	a5,74(s2)
    80004da4:	06f05763          	blez	a5,80004e12 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004da8:	04491703          	lh	a4,68(s2)
    80004dac:	4785                	li	a5,1
    80004dae:	06f70963          	beq	a4,a5,80004e20 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004db2:	4641                	li	a2,16
    80004db4:	4581                	li	a1,0
    80004db6:	fc040513          	addi	a0,s0,-64
    80004dba:	f0ffb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004dbe:	4741                	li	a4,16
    80004dc0:	f2c42683          	lw	a3,-212(s0)
    80004dc4:	fc040613          	addi	a2,s0,-64
    80004dc8:	4581                	li	a1,0
    80004dca:	8526                	mv	a0,s1
    80004dcc:	869fe0ef          	jal	80003634 <writei>
    80004dd0:	47c1                	li	a5,16
    80004dd2:	08f51b63          	bne	a0,a5,80004e68 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004dd6:	04491703          	lh	a4,68(s2)
    80004dda:	4785                	li	a5,1
    80004ddc:	08f70d63          	beq	a4,a5,80004e76 <sys_unlink+0x14c>
  iunlockput(dp);
    80004de0:	8526                	mv	a0,s1
    80004de2:	f0cfe0ef          	jal	800034ee <iunlockput>
  ip->nlink--;
    80004de6:	04a95783          	lhu	a5,74(s2)
    80004dea:	37fd                	addiw	a5,a5,-1
    80004dec:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004df0:	854a                	mv	a0,s2
    80004df2:	c3efe0ef          	jal	80003230 <iupdate>
  iunlockput(ip);
    80004df6:	854a                	mv	a0,s2
    80004df8:	ef6fe0ef          	jal	800034ee <iunlockput>
  end_op();
    80004dfc:	de9fe0ef          	jal	80003be4 <end_op>
  return 0;
    80004e00:	4501                	li	a0,0
    80004e02:	64ee                	ld	s1,216(sp)
    80004e04:	694e                	ld	s2,208(sp)
    80004e06:	a849                	j	80004e98 <sys_unlink+0x16e>
    end_op();
    80004e08:	dddfe0ef          	jal	80003be4 <end_op>
    return -1;
    80004e0c:	557d                	li	a0,-1
    80004e0e:	64ee                	ld	s1,216(sp)
    80004e10:	a061                	j	80004e98 <sys_unlink+0x16e>
    80004e12:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e14:	00003517          	auipc	a0,0x3
    80004e18:	8c450513          	addi	a0,a0,-1852 # 800076d8 <etext+0x6d8>
    80004e1c:	979fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e20:	04c92703          	lw	a4,76(s2)
    80004e24:	02000793          	li	a5,32
    80004e28:	f8e7f5e3          	bgeu	a5,a4,80004db2 <sys_unlink+0x88>
    80004e2c:	e5ce                	sd	s3,200(sp)
    80004e2e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e32:	4741                	li	a4,16
    80004e34:	86ce                	mv	a3,s3
    80004e36:	f1840613          	addi	a2,s0,-232
    80004e3a:	4581                	li	a1,0
    80004e3c:	854a                	mv	a0,s2
    80004e3e:	efafe0ef          	jal	80003538 <readi>
    80004e42:	47c1                	li	a5,16
    80004e44:	00f51c63          	bne	a0,a5,80004e5c <sys_unlink+0x132>
    if(de.inum != 0)
    80004e48:	f1845783          	lhu	a5,-232(s0)
    80004e4c:	efa1                	bnez	a5,80004ea4 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e4e:	29c1                	addiw	s3,s3,16
    80004e50:	04c92783          	lw	a5,76(s2)
    80004e54:	fcf9efe3          	bltu	s3,a5,80004e32 <sys_unlink+0x108>
    80004e58:	69ae                	ld	s3,200(sp)
    80004e5a:	bfa1                	j	80004db2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004e5c:	00003517          	auipc	a0,0x3
    80004e60:	89450513          	addi	a0,a0,-1900 # 800076f0 <etext+0x6f0>
    80004e64:	931fb0ef          	jal	80000794 <panic>
    80004e68:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004e6a:	00003517          	auipc	a0,0x3
    80004e6e:	89e50513          	addi	a0,a0,-1890 # 80007708 <etext+0x708>
    80004e72:	923fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004e76:	04a4d783          	lhu	a5,74(s1)
    80004e7a:	37fd                	addiw	a5,a5,-1
    80004e7c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e80:	8526                	mv	a0,s1
    80004e82:	baefe0ef          	jal	80003230 <iupdate>
    80004e86:	bfa9                	j	80004de0 <sys_unlink+0xb6>
    80004e88:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	e62fe0ef          	jal	800034ee <iunlockput>
  end_op();
    80004e90:	d55fe0ef          	jal	80003be4 <end_op>
  return -1;
    80004e94:	557d                	li	a0,-1
    80004e96:	64ee                	ld	s1,216(sp)
}
    80004e98:	70ae                	ld	ra,232(sp)
    80004e9a:	740e                	ld	s0,224(sp)
    80004e9c:	616d                	addi	sp,sp,240
    80004e9e:	8082                	ret
    return -1;
    80004ea0:	557d                	li	a0,-1
    80004ea2:	bfdd                	j	80004e98 <sys_unlink+0x16e>
    iunlockput(ip);
    80004ea4:	854a                	mv	a0,s2
    80004ea6:	e48fe0ef          	jal	800034ee <iunlockput>
    goto bad;
    80004eaa:	694e                	ld	s2,208(sp)
    80004eac:	69ae                	ld	s3,200(sp)
    80004eae:	bff1                	j	80004e8a <sys_unlink+0x160>

0000000080004eb0 <sys_open>:

uint64
sys_open(void)
{
    80004eb0:	7131                	addi	sp,sp,-192
    80004eb2:	fd06                	sd	ra,184(sp)
    80004eb4:	f922                	sd	s0,176(sp)
    80004eb6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004eb8:	f4c40593          	addi	a1,s0,-180
    80004ebc:	4505                	li	a0,1
    80004ebe:	9e7fd0ef          	jal	800028a4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ec2:	08000613          	li	a2,128
    80004ec6:	f5040593          	addi	a1,s0,-176
    80004eca:	4501                	li	a0,0
    80004ecc:	a11fd0ef          	jal	800028dc <argstr>
    80004ed0:	87aa                	mv	a5,a0
    return -1;
    80004ed2:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004ed4:	0a07c263          	bltz	a5,80004f78 <sys_open+0xc8>
    80004ed8:	f526                	sd	s1,168(sp)

  begin_op();
    80004eda:	ca1fe0ef          	jal	80003b7a <begin_op>

  if(omode & O_CREATE){
    80004ede:	f4c42783          	lw	a5,-180(s0)
    80004ee2:	2007f793          	andi	a5,a5,512
    80004ee6:	c3d5                	beqz	a5,80004f8a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004ee8:	4681                	li	a3,0
    80004eea:	4601                	li	a2,0
    80004eec:	4589                	li	a1,2
    80004eee:	f5040513          	addi	a0,s0,-176
    80004ef2:	aa9ff0ef          	jal	8000499a <create>
    80004ef6:	84aa                	mv	s1,a0
    if(ip == 0){
    80004ef8:	c541                	beqz	a0,80004f80 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004efa:	04449703          	lh	a4,68(s1)
    80004efe:	478d                	li	a5,3
    80004f00:	00f71763          	bne	a4,a5,80004f0e <sys_open+0x5e>
    80004f04:	0464d703          	lhu	a4,70(s1)
    80004f08:	47a5                	li	a5,9
    80004f0a:	0ae7ed63          	bltu	a5,a4,80004fc4 <sys_open+0x114>
    80004f0e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f10:	fe1fe0ef          	jal	80003ef0 <filealloc>
    80004f14:	892a                	mv	s2,a0
    80004f16:	c179                	beqz	a0,80004fdc <sys_open+0x12c>
    80004f18:	ed4e                	sd	s3,152(sp)
    80004f1a:	a43ff0ef          	jal	8000495c <fdalloc>
    80004f1e:	89aa                	mv	s3,a0
    80004f20:	0a054a63          	bltz	a0,80004fd4 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f24:	04449703          	lh	a4,68(s1)
    80004f28:	478d                	li	a5,3
    80004f2a:	0cf70263          	beq	a4,a5,80004fee <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f2e:	4789                	li	a5,2
    80004f30:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f34:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f38:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f3c:	f4c42783          	lw	a5,-180(s0)
    80004f40:	0017c713          	xori	a4,a5,1
    80004f44:	8b05                	andi	a4,a4,1
    80004f46:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f4a:	0037f713          	andi	a4,a5,3
    80004f4e:	00e03733          	snez	a4,a4
    80004f52:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f56:	4007f793          	andi	a5,a5,1024
    80004f5a:	c791                	beqz	a5,80004f66 <sys_open+0xb6>
    80004f5c:	04449703          	lh	a4,68(s1)
    80004f60:	4789                	li	a5,2
    80004f62:	08f70d63          	beq	a4,a5,80004ffc <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004f66:	8526                	mv	a0,s1
    80004f68:	c2afe0ef          	jal	80003392 <iunlock>
  end_op();
    80004f6c:	c79fe0ef          	jal	80003be4 <end_op>

  return fd;
    80004f70:	854e                	mv	a0,s3
    80004f72:	74aa                	ld	s1,168(sp)
    80004f74:	790a                	ld	s2,160(sp)
    80004f76:	69ea                	ld	s3,152(sp)
}
    80004f78:	70ea                	ld	ra,184(sp)
    80004f7a:	744a                	ld	s0,176(sp)
    80004f7c:	6129                	addi	sp,sp,192
    80004f7e:	8082                	ret
      end_op();
    80004f80:	c65fe0ef          	jal	80003be4 <end_op>
      return -1;
    80004f84:	557d                	li	a0,-1
    80004f86:	74aa                	ld	s1,168(sp)
    80004f88:	bfc5                	j	80004f78 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004f8a:	f5040513          	addi	a0,s0,-176
    80004f8e:	a31fe0ef          	jal	800039be <namei>
    80004f92:	84aa                	mv	s1,a0
    80004f94:	c11d                	beqz	a0,80004fba <sys_open+0x10a>
    ilock(ip);
    80004f96:	b4efe0ef          	jal	800032e4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f9a:	04449703          	lh	a4,68(s1)
    80004f9e:	4785                	li	a5,1
    80004fa0:	f4f71de3          	bne	a4,a5,80004efa <sys_open+0x4a>
    80004fa4:	f4c42783          	lw	a5,-180(s0)
    80004fa8:	d3bd                	beqz	a5,80004f0e <sys_open+0x5e>
      iunlockput(ip);
    80004faa:	8526                	mv	a0,s1
    80004fac:	d42fe0ef          	jal	800034ee <iunlockput>
      end_op();
    80004fb0:	c35fe0ef          	jal	80003be4 <end_op>
      return -1;
    80004fb4:	557d                	li	a0,-1
    80004fb6:	74aa                	ld	s1,168(sp)
    80004fb8:	b7c1                	j	80004f78 <sys_open+0xc8>
      end_op();
    80004fba:	c2bfe0ef          	jal	80003be4 <end_op>
      return -1;
    80004fbe:	557d                	li	a0,-1
    80004fc0:	74aa                	ld	s1,168(sp)
    80004fc2:	bf5d                	j	80004f78 <sys_open+0xc8>
    iunlockput(ip);
    80004fc4:	8526                	mv	a0,s1
    80004fc6:	d28fe0ef          	jal	800034ee <iunlockput>
    end_op();
    80004fca:	c1bfe0ef          	jal	80003be4 <end_op>
    return -1;
    80004fce:	557d                	li	a0,-1
    80004fd0:	74aa                	ld	s1,168(sp)
    80004fd2:	b75d                	j	80004f78 <sys_open+0xc8>
      fileclose(f);
    80004fd4:	854a                	mv	a0,s2
    80004fd6:	fbffe0ef          	jal	80003f94 <fileclose>
    80004fda:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004fdc:	8526                	mv	a0,s1
    80004fde:	d10fe0ef          	jal	800034ee <iunlockput>
    end_op();
    80004fe2:	c03fe0ef          	jal	80003be4 <end_op>
    return -1;
    80004fe6:	557d                	li	a0,-1
    80004fe8:	74aa                	ld	s1,168(sp)
    80004fea:	790a                	ld	s2,160(sp)
    80004fec:	b771                	j	80004f78 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004fee:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004ff2:	04649783          	lh	a5,70(s1)
    80004ff6:	02f91223          	sh	a5,36(s2)
    80004ffa:	bf3d                	j	80004f38 <sys_open+0x88>
    itrunc(ip);
    80004ffc:	8526                	mv	a0,s1
    80004ffe:	bd4fe0ef          	jal	800033d2 <itrunc>
    80005002:	b795                	j	80004f66 <sys_open+0xb6>

0000000080005004 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005004:	7175                	addi	sp,sp,-144
    80005006:	e506                	sd	ra,136(sp)
    80005008:	e122                	sd	s0,128(sp)
    8000500a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000500c:	b6ffe0ef          	jal	80003b7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005010:	08000613          	li	a2,128
    80005014:	f7040593          	addi	a1,s0,-144
    80005018:	4501                	li	a0,0
    8000501a:	8c3fd0ef          	jal	800028dc <argstr>
    8000501e:	02054363          	bltz	a0,80005044 <sys_mkdir+0x40>
    80005022:	4681                	li	a3,0
    80005024:	4601                	li	a2,0
    80005026:	4585                	li	a1,1
    80005028:	f7040513          	addi	a0,s0,-144
    8000502c:	96fff0ef          	jal	8000499a <create>
    80005030:	c911                	beqz	a0,80005044 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005032:	cbcfe0ef          	jal	800034ee <iunlockput>
  end_op();
    80005036:	baffe0ef          	jal	80003be4 <end_op>
  return 0;
    8000503a:	4501                	li	a0,0
}
    8000503c:	60aa                	ld	ra,136(sp)
    8000503e:	640a                	ld	s0,128(sp)
    80005040:	6149                	addi	sp,sp,144
    80005042:	8082                	ret
    end_op();
    80005044:	ba1fe0ef          	jal	80003be4 <end_op>
    return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	bfcd                	j	8000503c <sys_mkdir+0x38>

000000008000504c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000504c:	7135                	addi	sp,sp,-160
    8000504e:	ed06                	sd	ra,152(sp)
    80005050:	e922                	sd	s0,144(sp)
    80005052:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005054:	b27fe0ef          	jal	80003b7a <begin_op>
  argint(1, &major);
    80005058:	f6c40593          	addi	a1,s0,-148
    8000505c:	4505                	li	a0,1
    8000505e:	847fd0ef          	jal	800028a4 <argint>
  argint(2, &minor);
    80005062:	f6840593          	addi	a1,s0,-152
    80005066:	4509                	li	a0,2
    80005068:	83dfd0ef          	jal	800028a4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000506c:	08000613          	li	a2,128
    80005070:	f7040593          	addi	a1,s0,-144
    80005074:	4501                	li	a0,0
    80005076:	867fd0ef          	jal	800028dc <argstr>
    8000507a:	02054563          	bltz	a0,800050a4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000507e:	f6841683          	lh	a3,-152(s0)
    80005082:	f6c41603          	lh	a2,-148(s0)
    80005086:	458d                	li	a1,3
    80005088:	f7040513          	addi	a0,s0,-144
    8000508c:	90fff0ef          	jal	8000499a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005090:	c911                	beqz	a0,800050a4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005092:	c5cfe0ef          	jal	800034ee <iunlockput>
  end_op();
    80005096:	b4ffe0ef          	jal	80003be4 <end_op>
  return 0;
    8000509a:	4501                	li	a0,0
}
    8000509c:	60ea                	ld	ra,152(sp)
    8000509e:	644a                	ld	s0,144(sp)
    800050a0:	610d                	addi	sp,sp,160
    800050a2:	8082                	ret
    end_op();
    800050a4:	b41fe0ef          	jal	80003be4 <end_op>
    return -1;
    800050a8:	557d                	li	a0,-1
    800050aa:	bfcd                	j	8000509c <sys_mknod+0x50>

00000000800050ac <sys_chdir>:

uint64
sys_chdir(void)
{
    800050ac:	7135                	addi	sp,sp,-160
    800050ae:	ed06                	sd	ra,152(sp)
    800050b0:	e922                	sd	s0,144(sp)
    800050b2:	e14a                	sd	s2,128(sp)
    800050b4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050b6:	93bfc0ef          	jal	800019f0 <myproc>
    800050ba:	892a                	mv	s2,a0
  
  begin_op();
    800050bc:	abffe0ef          	jal	80003b7a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050c0:	08000613          	li	a2,128
    800050c4:	f6040593          	addi	a1,s0,-160
    800050c8:	4501                	li	a0,0
    800050ca:	813fd0ef          	jal	800028dc <argstr>
    800050ce:	04054363          	bltz	a0,80005114 <sys_chdir+0x68>
    800050d2:	e526                	sd	s1,136(sp)
    800050d4:	f6040513          	addi	a0,s0,-160
    800050d8:	8e7fe0ef          	jal	800039be <namei>
    800050dc:	84aa                	mv	s1,a0
    800050de:	c915                	beqz	a0,80005112 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800050e0:	a04fe0ef          	jal	800032e4 <ilock>
  if(ip->type != T_DIR){
    800050e4:	04449703          	lh	a4,68(s1)
    800050e8:	4785                	li	a5,1
    800050ea:	02f71963          	bne	a4,a5,8000511c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800050ee:	8526                	mv	a0,s1
    800050f0:	aa2fe0ef          	jal	80003392 <iunlock>
  iput(p->cwd);
    800050f4:	15093503          	ld	a0,336(s2)
    800050f8:	b6efe0ef          	jal	80003466 <iput>
  end_op();
    800050fc:	ae9fe0ef          	jal	80003be4 <end_op>
  p->cwd = ip;
    80005100:	14993823          	sd	s1,336(s2)
  return 0;
    80005104:	4501                	li	a0,0
    80005106:	64aa                	ld	s1,136(sp)
}
    80005108:	60ea                	ld	ra,152(sp)
    8000510a:	644a                	ld	s0,144(sp)
    8000510c:	690a                	ld	s2,128(sp)
    8000510e:	610d                	addi	sp,sp,160
    80005110:	8082                	ret
    80005112:	64aa                	ld	s1,136(sp)
    end_op();
    80005114:	ad1fe0ef          	jal	80003be4 <end_op>
    return -1;
    80005118:	557d                	li	a0,-1
    8000511a:	b7fd                	j	80005108 <sys_chdir+0x5c>
    iunlockput(ip);
    8000511c:	8526                	mv	a0,s1
    8000511e:	bd0fe0ef          	jal	800034ee <iunlockput>
    end_op();
    80005122:	ac3fe0ef          	jal	80003be4 <end_op>
    return -1;
    80005126:	557d                	li	a0,-1
    80005128:	64aa                	ld	s1,136(sp)
    8000512a:	bff9                	j	80005108 <sys_chdir+0x5c>

000000008000512c <sys_exec>:

uint64
sys_exec(void)
{
    8000512c:	7121                	addi	sp,sp,-448
    8000512e:	ff06                	sd	ra,440(sp)
    80005130:	fb22                	sd	s0,432(sp)
    80005132:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005134:	e4840593          	addi	a1,s0,-440
    80005138:	4505                	li	a0,1
    8000513a:	f86fd0ef          	jal	800028c0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000513e:	08000613          	li	a2,128
    80005142:	f5040593          	addi	a1,s0,-176
    80005146:	4501                	li	a0,0
    80005148:	f94fd0ef          	jal	800028dc <argstr>
    8000514c:	87aa                	mv	a5,a0
    return -1;
    8000514e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005150:	0c07c463          	bltz	a5,80005218 <sys_exec+0xec>
    80005154:	f726                	sd	s1,424(sp)
    80005156:	f34a                	sd	s2,416(sp)
    80005158:	ef4e                	sd	s3,408(sp)
    8000515a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000515c:	10000613          	li	a2,256
    80005160:	4581                	li	a1,0
    80005162:	e5040513          	addi	a0,s0,-432
    80005166:	b63fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000516a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000516e:	89a6                	mv	s3,s1
    80005170:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005172:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005176:	00391513          	slli	a0,s2,0x3
    8000517a:	e4040593          	addi	a1,s0,-448
    8000517e:	e4843783          	ld	a5,-440(s0)
    80005182:	953e                	add	a0,a0,a5
    80005184:	e96fd0ef          	jal	8000281a <fetchaddr>
    80005188:	02054663          	bltz	a0,800051b4 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000518c:	e4043783          	ld	a5,-448(s0)
    80005190:	c3a9                	beqz	a5,800051d2 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005192:	993fb0ef          	jal	80000b24 <kalloc>
    80005196:	85aa                	mv	a1,a0
    80005198:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000519c:	cd01                	beqz	a0,800051b4 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000519e:	6605                	lui	a2,0x1
    800051a0:	e4043503          	ld	a0,-448(s0)
    800051a4:	ec0fd0ef          	jal	80002864 <fetchstr>
    800051a8:	00054663          	bltz	a0,800051b4 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800051ac:	0905                	addi	s2,s2,1
    800051ae:	09a1                	addi	s3,s3,8
    800051b0:	fd4913e3          	bne	s2,s4,80005176 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051b4:	f5040913          	addi	s2,s0,-176
    800051b8:	6088                	ld	a0,0(s1)
    800051ba:	c931                	beqz	a0,8000520e <sys_exec+0xe2>
    kfree(argv[i]);
    800051bc:	887fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051c0:	04a1                	addi	s1,s1,8
    800051c2:	ff249be3          	bne	s1,s2,800051b8 <sys_exec+0x8c>
  return -1;
    800051c6:	557d                	li	a0,-1
    800051c8:	74ba                	ld	s1,424(sp)
    800051ca:	791a                	ld	s2,416(sp)
    800051cc:	69fa                	ld	s3,408(sp)
    800051ce:	6a5a                	ld	s4,400(sp)
    800051d0:	a0a1                	j	80005218 <sys_exec+0xec>
      argv[i] = 0;
    800051d2:	0009079b          	sext.w	a5,s2
    800051d6:	078e                	slli	a5,a5,0x3
    800051d8:	fd078793          	addi	a5,a5,-48
    800051dc:	97a2                	add	a5,a5,s0
    800051de:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800051e2:	e5040593          	addi	a1,s0,-432
    800051e6:	f5040513          	addi	a0,s0,-176
    800051ea:	ba8ff0ef          	jal	80004592 <exec>
    800051ee:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051f0:	f5040993          	addi	s3,s0,-176
    800051f4:	6088                	ld	a0,0(s1)
    800051f6:	c511                	beqz	a0,80005202 <sys_exec+0xd6>
    kfree(argv[i]);
    800051f8:	84bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051fc:	04a1                	addi	s1,s1,8
    800051fe:	ff349be3          	bne	s1,s3,800051f4 <sys_exec+0xc8>
  return ret;
    80005202:	854a                	mv	a0,s2
    80005204:	74ba                	ld	s1,424(sp)
    80005206:	791a                	ld	s2,416(sp)
    80005208:	69fa                	ld	s3,408(sp)
    8000520a:	6a5a                	ld	s4,400(sp)
    8000520c:	a031                	j	80005218 <sys_exec+0xec>
  return -1;
    8000520e:	557d                	li	a0,-1
    80005210:	74ba                	ld	s1,424(sp)
    80005212:	791a                	ld	s2,416(sp)
    80005214:	69fa                	ld	s3,408(sp)
    80005216:	6a5a                	ld	s4,400(sp)
}
    80005218:	70fa                	ld	ra,440(sp)
    8000521a:	745a                	ld	s0,432(sp)
    8000521c:	6139                	addi	sp,sp,448
    8000521e:	8082                	ret

0000000080005220 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005220:	7139                	addi	sp,sp,-64
    80005222:	fc06                	sd	ra,56(sp)
    80005224:	f822                	sd	s0,48(sp)
    80005226:	f426                	sd	s1,40(sp)
    80005228:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000522a:	fc6fc0ef          	jal	800019f0 <myproc>
    8000522e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005230:	fd840593          	addi	a1,s0,-40
    80005234:	4501                	li	a0,0
    80005236:	e8afd0ef          	jal	800028c0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000523a:	fc840593          	addi	a1,s0,-56
    8000523e:	fd040513          	addi	a0,s0,-48
    80005242:	85cff0ef          	jal	8000429e <pipealloc>
    return -1;
    80005246:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005248:	0a054463          	bltz	a0,800052f0 <sys_pipe+0xd0>
  fd0 = -1;
    8000524c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005250:	fd043503          	ld	a0,-48(s0)
    80005254:	f08ff0ef          	jal	8000495c <fdalloc>
    80005258:	fca42223          	sw	a0,-60(s0)
    8000525c:	08054163          	bltz	a0,800052de <sys_pipe+0xbe>
    80005260:	fc843503          	ld	a0,-56(s0)
    80005264:	ef8ff0ef          	jal	8000495c <fdalloc>
    80005268:	fca42023          	sw	a0,-64(s0)
    8000526c:	06054063          	bltz	a0,800052cc <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005270:	4691                	li	a3,4
    80005272:	fc440613          	addi	a2,s0,-60
    80005276:	fd843583          	ld	a1,-40(s0)
    8000527a:	68a8                	ld	a0,80(s1)
    8000527c:	ad6fc0ef          	jal	80001552 <copyout>
    80005280:	00054e63          	bltz	a0,8000529c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005284:	4691                	li	a3,4
    80005286:	fc040613          	addi	a2,s0,-64
    8000528a:	fd843583          	ld	a1,-40(s0)
    8000528e:	0591                	addi	a1,a1,4
    80005290:	68a8                	ld	a0,80(s1)
    80005292:	ac0fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005296:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005298:	04055c63          	bgez	a0,800052f0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000529c:	fc442783          	lw	a5,-60(s0)
    800052a0:	07e9                	addi	a5,a5,26
    800052a2:	078e                	slli	a5,a5,0x3
    800052a4:	97a6                	add	a5,a5,s1
    800052a6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052aa:	fc042783          	lw	a5,-64(s0)
    800052ae:	07e9                	addi	a5,a5,26
    800052b0:	078e                	slli	a5,a5,0x3
    800052b2:	94be                	add	s1,s1,a5
    800052b4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800052b8:	fd043503          	ld	a0,-48(s0)
    800052bc:	cd9fe0ef          	jal	80003f94 <fileclose>
    fileclose(wf);
    800052c0:	fc843503          	ld	a0,-56(s0)
    800052c4:	cd1fe0ef          	jal	80003f94 <fileclose>
    return -1;
    800052c8:	57fd                	li	a5,-1
    800052ca:	a01d                	j	800052f0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800052cc:	fc442783          	lw	a5,-60(s0)
    800052d0:	0007c763          	bltz	a5,800052de <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800052d4:	07e9                	addi	a5,a5,26
    800052d6:	078e                	slli	a5,a5,0x3
    800052d8:	97a6                	add	a5,a5,s1
    800052da:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800052de:	fd043503          	ld	a0,-48(s0)
    800052e2:	cb3fe0ef          	jal	80003f94 <fileclose>
    fileclose(wf);
    800052e6:	fc843503          	ld	a0,-56(s0)
    800052ea:	cabfe0ef          	jal	80003f94 <fileclose>
    return -1;
    800052ee:	57fd                	li	a5,-1
}
    800052f0:	853e                	mv	a0,a5
    800052f2:	70e2                	ld	ra,56(sp)
    800052f4:	7442                	ld	s0,48(sp)
    800052f6:	74a2                	ld	s1,40(sp)
    800052f8:	6121                	addi	sp,sp,64
    800052fa:	8082                	ret
    800052fc:	0000                	unimp
	...

0000000080005300 <kernelvec>:
    80005300:	7111                	addi	sp,sp,-256
    80005302:	e006                	sd	ra,0(sp)
    80005304:	e40a                	sd	sp,8(sp)
    80005306:	e80e                	sd	gp,16(sp)
    80005308:	ec12                	sd	tp,24(sp)
    8000530a:	f016                	sd	t0,32(sp)
    8000530c:	f41a                	sd	t1,40(sp)
    8000530e:	f81e                	sd	t2,48(sp)
    80005310:	e4aa                	sd	a0,72(sp)
    80005312:	e8ae                	sd	a1,80(sp)
    80005314:	ecb2                	sd	a2,88(sp)
    80005316:	f0b6                	sd	a3,96(sp)
    80005318:	f4ba                	sd	a4,104(sp)
    8000531a:	f8be                	sd	a5,112(sp)
    8000531c:	fcc2                	sd	a6,120(sp)
    8000531e:	e146                	sd	a7,128(sp)
    80005320:	edf2                	sd	t3,216(sp)
    80005322:	f1f6                	sd	t4,224(sp)
    80005324:	f5fa                	sd	t5,232(sp)
    80005326:	f9fe                	sd	t6,240(sp)
    80005328:	c02fd0ef          	jal	8000272a <kerneltrap>
    8000532c:	6082                	ld	ra,0(sp)
    8000532e:	6122                	ld	sp,8(sp)
    80005330:	61c2                	ld	gp,16(sp)
    80005332:	7282                	ld	t0,32(sp)
    80005334:	7322                	ld	t1,40(sp)
    80005336:	73c2                	ld	t2,48(sp)
    80005338:	6526                	ld	a0,72(sp)
    8000533a:	65c6                	ld	a1,80(sp)
    8000533c:	6666                	ld	a2,88(sp)
    8000533e:	7686                	ld	a3,96(sp)
    80005340:	7726                	ld	a4,104(sp)
    80005342:	77c6                	ld	a5,112(sp)
    80005344:	7866                	ld	a6,120(sp)
    80005346:	688a                	ld	a7,128(sp)
    80005348:	6e6e                	ld	t3,216(sp)
    8000534a:	7e8e                	ld	t4,224(sp)
    8000534c:	7f2e                	ld	t5,232(sp)
    8000534e:	7fce                	ld	t6,240(sp)
    80005350:	6111                	addi	sp,sp,256
    80005352:	10200073          	sret
	...

000000008000535e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000535e:	1141                	addi	sp,sp,-16
    80005360:	e422                	sd	s0,8(sp)
    80005362:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005364:	0c0007b7          	lui	a5,0xc000
    80005368:	4705                	li	a4,1
    8000536a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000536c:	0c0007b7          	lui	a5,0xc000
    80005370:	c3d8                	sw	a4,4(a5)
}
    80005372:	6422                	ld	s0,8(sp)
    80005374:	0141                	addi	sp,sp,16
    80005376:	8082                	ret

0000000080005378 <plicinithart>:

void
plicinithart(void)
{
    80005378:	1141                	addi	sp,sp,-16
    8000537a:	e406                	sd	ra,8(sp)
    8000537c:	e022                	sd	s0,0(sp)
    8000537e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005380:	e44fc0ef          	jal	800019c4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005384:	0085171b          	slliw	a4,a0,0x8
    80005388:	0c0027b7          	lui	a5,0xc002
    8000538c:	97ba                	add	a5,a5,a4
    8000538e:	40200713          	li	a4,1026
    80005392:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005396:	00d5151b          	slliw	a0,a0,0xd
    8000539a:	0c2017b7          	lui	a5,0xc201
    8000539e:	97aa                	add	a5,a5,a0
    800053a0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053a4:	60a2                	ld	ra,8(sp)
    800053a6:	6402                	ld	s0,0(sp)
    800053a8:	0141                	addi	sp,sp,16
    800053aa:	8082                	ret

00000000800053ac <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053ac:	1141                	addi	sp,sp,-16
    800053ae:	e406                	sd	ra,8(sp)
    800053b0:	e022                	sd	s0,0(sp)
    800053b2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053b4:	e10fc0ef          	jal	800019c4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800053b8:	00d5151b          	slliw	a0,a0,0xd
    800053bc:	0c2017b7          	lui	a5,0xc201
    800053c0:	97aa                	add	a5,a5,a0
  return irq;
}
    800053c2:	43c8                	lw	a0,4(a5)
    800053c4:	60a2                	ld	ra,8(sp)
    800053c6:	6402                	ld	s0,0(sp)
    800053c8:	0141                	addi	sp,sp,16
    800053ca:	8082                	ret

00000000800053cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053cc:	1101                	addi	sp,sp,-32
    800053ce:	ec06                	sd	ra,24(sp)
    800053d0:	e822                	sd	s0,16(sp)
    800053d2:	e426                	sd	s1,8(sp)
    800053d4:	1000                	addi	s0,sp,32
    800053d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053d8:	decfc0ef          	jal	800019c4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053dc:	00d5151b          	slliw	a0,a0,0xd
    800053e0:	0c2017b7          	lui	a5,0xc201
    800053e4:	97aa                	add	a5,a5,a0
    800053e6:	c3c4                	sw	s1,4(a5)
}
    800053e8:	60e2                	ld	ra,24(sp)
    800053ea:	6442                	ld	s0,16(sp)
    800053ec:	64a2                	ld	s1,8(sp)
    800053ee:	6105                	addi	sp,sp,32
    800053f0:	8082                	ret

00000000800053f2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053f2:	1141                	addi	sp,sp,-16
    800053f4:	e406                	sd	ra,8(sp)
    800053f6:	e022                	sd	s0,0(sp)
    800053f8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053fa:	479d                	li	a5,7
    800053fc:	04a7ca63          	blt	a5,a0,80005450 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005400:	0001e797          	auipc	a5,0x1e
    80005404:	17078793          	addi	a5,a5,368 # 80023570 <disk>
    80005408:	97aa                	add	a5,a5,a0
    8000540a:	0187c783          	lbu	a5,24(a5)
    8000540e:	e7b9                	bnez	a5,8000545c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005410:	00451693          	slli	a3,a0,0x4
    80005414:	0001e797          	auipc	a5,0x1e
    80005418:	15c78793          	addi	a5,a5,348 # 80023570 <disk>
    8000541c:	6398                	ld	a4,0(a5)
    8000541e:	9736                	add	a4,a4,a3
    80005420:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005424:	6398                	ld	a4,0(a5)
    80005426:	9736                	add	a4,a4,a3
    80005428:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000542c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005430:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005434:	97aa                	add	a5,a5,a0
    80005436:	4705                	li	a4,1
    80005438:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000543c:	0001e517          	auipc	a0,0x1e
    80005440:	14c50513          	addi	a0,a0,332 # 80023588 <disk+0x18>
    80005444:	bc7fc0ef          	jal	8000200a <wakeup>
}
    80005448:	60a2                	ld	ra,8(sp)
    8000544a:	6402                	ld	s0,0(sp)
    8000544c:	0141                	addi	sp,sp,16
    8000544e:	8082                	ret
    panic("free_desc 1");
    80005450:	00002517          	auipc	a0,0x2
    80005454:	2c850513          	addi	a0,a0,712 # 80007718 <etext+0x718>
    80005458:	b3cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000545c:	00002517          	auipc	a0,0x2
    80005460:	2cc50513          	addi	a0,a0,716 # 80007728 <etext+0x728>
    80005464:	b30fb0ef          	jal	80000794 <panic>

0000000080005468 <virtio_disk_init>:
{
    80005468:	1101                	addi	sp,sp,-32
    8000546a:	ec06                	sd	ra,24(sp)
    8000546c:	e822                	sd	s0,16(sp)
    8000546e:	e426                	sd	s1,8(sp)
    80005470:	e04a                	sd	s2,0(sp)
    80005472:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005474:	00002597          	auipc	a1,0x2
    80005478:	2c458593          	addi	a1,a1,708 # 80007738 <etext+0x738>
    8000547c:	0001e517          	auipc	a0,0x1e
    80005480:	21c50513          	addi	a0,a0,540 # 80023698 <disk+0x128>
    80005484:	ef0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005488:	100017b7          	lui	a5,0x10001
    8000548c:	4398                	lw	a4,0(a5)
    8000548e:	2701                	sext.w	a4,a4
    80005490:	747277b7          	lui	a5,0x74727
    80005494:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005498:	18f71063          	bne	a4,a5,80005618 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000549c:	100017b7          	lui	a5,0x10001
    800054a0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800054a2:	439c                	lw	a5,0(a5)
    800054a4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054a6:	4709                	li	a4,2
    800054a8:	16e79863          	bne	a5,a4,80005618 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054ac:	100017b7          	lui	a5,0x10001
    800054b0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800054b2:	439c                	lw	a5,0(a5)
    800054b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054b6:	16e79163          	bne	a5,a4,80005618 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054ba:	100017b7          	lui	a5,0x10001
    800054be:	47d8                	lw	a4,12(a5)
    800054c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054c2:	554d47b7          	lui	a5,0x554d4
    800054c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054ca:	14f71763          	bne	a4,a5,80005618 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ce:	100017b7          	lui	a5,0x10001
    800054d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054d6:	4705                	li	a4,1
    800054d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054da:	470d                	li	a4,3
    800054dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054de:	10001737          	lui	a4,0x10001
    800054e2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800054e4:	c7ffe737          	lui	a4,0xc7ffe
    800054e8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb0af>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054ec:	8ef9                	and	a3,a3,a4
    800054ee:	10001737          	lui	a4,0x10001
    800054f2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054f4:	472d                	li	a4,11
    800054f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054f8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800054fc:	439c                	lw	a5,0(a5)
    800054fe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005502:	8ba1                	andi	a5,a5,8
    80005504:	12078063          	beqz	a5,80005624 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005508:	100017b7          	lui	a5,0x10001
    8000550c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005510:	100017b7          	lui	a5,0x10001
    80005514:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005518:	439c                	lw	a5,0(a5)
    8000551a:	2781                	sext.w	a5,a5
    8000551c:	10079a63          	bnez	a5,80005630 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005520:	100017b7          	lui	a5,0x10001
    80005524:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005528:	439c                	lw	a5,0(a5)
    8000552a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000552c:	10078863          	beqz	a5,8000563c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005530:	471d                	li	a4,7
    80005532:	10f77b63          	bgeu	a4,a5,80005648 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005536:	deefb0ef          	jal	80000b24 <kalloc>
    8000553a:	0001e497          	auipc	s1,0x1e
    8000553e:	03648493          	addi	s1,s1,54 # 80023570 <disk>
    80005542:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005544:	de0fb0ef          	jal	80000b24 <kalloc>
    80005548:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000554a:	ddafb0ef          	jal	80000b24 <kalloc>
    8000554e:	87aa                	mv	a5,a0
    80005550:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005552:	6088                	ld	a0,0(s1)
    80005554:	10050063          	beqz	a0,80005654 <virtio_disk_init+0x1ec>
    80005558:	0001e717          	auipc	a4,0x1e
    8000555c:	02073703          	ld	a4,32(a4) # 80023578 <disk+0x8>
    80005560:	0e070a63          	beqz	a4,80005654 <virtio_disk_init+0x1ec>
    80005564:	0e078863          	beqz	a5,80005654 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005568:	6605                	lui	a2,0x1
    8000556a:	4581                	li	a1,0
    8000556c:	f5cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005570:	0001e497          	auipc	s1,0x1e
    80005574:	00048493          	mv	s1,s1
    80005578:	6605                	lui	a2,0x1
    8000557a:	4581                	li	a1,0
    8000557c:	6488                	ld	a0,8(s1)
    8000557e:	f4afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005582:	6605                	lui	a2,0x1
    80005584:	4581                	li	a1,0
    80005586:	6888                	ld	a0,16(s1)
    80005588:	f40fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000558c:	100017b7          	lui	a5,0x10001
    80005590:	4721                	li	a4,8
    80005592:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005594:	4098                	lw	a4,0(s1)
    80005596:	100017b7          	lui	a5,0x10001
    8000559a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000559e:	40d8                	lw	a4,4(s1)
    800055a0:	100017b7          	lui	a5,0x10001
    800055a4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055a8:	649c                	ld	a5,8(s1)
    800055aa:	0007869b          	sext.w	a3,a5
    800055ae:	10001737          	lui	a4,0x10001
    800055b2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055b6:	9781                	srai	a5,a5,0x20
    800055b8:	10001737          	lui	a4,0x10001
    800055bc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055c0:	689c                	ld	a5,16(s1)
    800055c2:	0007869b          	sext.w	a3,a5
    800055c6:	10001737          	lui	a4,0x10001
    800055ca:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055ce:	9781                	srai	a5,a5,0x20
    800055d0:	10001737          	lui	a4,0x10001
    800055d4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055d8:	10001737          	lui	a4,0x10001
    800055dc:	4785                	li	a5,1
    800055de:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800055e0:	00f48c23          	sb	a5,24(s1) # 80023588 <disk+0x18>
    800055e4:	00f48ca3          	sb	a5,25(s1)
    800055e8:	00f48d23          	sb	a5,26(s1)
    800055ec:	00f48da3          	sb	a5,27(s1)
    800055f0:	00f48e23          	sb	a5,28(s1)
    800055f4:	00f48ea3          	sb	a5,29(s1)
    800055f8:	00f48f23          	sb	a5,30(s1)
    800055fc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005600:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005604:	100017b7          	lui	a5,0x10001
    80005608:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000560c:	60e2                	ld	ra,24(sp)
    8000560e:	6442                	ld	s0,16(sp)
    80005610:	64a2                	ld	s1,8(sp)
    80005612:	6902                	ld	s2,0(sp)
    80005614:	6105                	addi	sp,sp,32
    80005616:	8082                	ret
    panic("could not find virtio disk");
    80005618:	00002517          	auipc	a0,0x2
    8000561c:	13050513          	addi	a0,a0,304 # 80007748 <etext+0x748>
    80005620:	974fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005624:	00002517          	auipc	a0,0x2
    80005628:	14450513          	addi	a0,a0,324 # 80007768 <etext+0x768>
    8000562c:	968fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005630:	00002517          	auipc	a0,0x2
    80005634:	15850513          	addi	a0,a0,344 # 80007788 <etext+0x788>
    80005638:	95cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000563c:	00002517          	auipc	a0,0x2
    80005640:	16c50513          	addi	a0,a0,364 # 800077a8 <etext+0x7a8>
    80005644:	950fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005648:	00002517          	auipc	a0,0x2
    8000564c:	18050513          	addi	a0,a0,384 # 800077c8 <etext+0x7c8>
    80005650:	944fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005654:	00002517          	auipc	a0,0x2
    80005658:	19450513          	addi	a0,a0,404 # 800077e8 <etext+0x7e8>
    8000565c:	938fb0ef          	jal	80000794 <panic>

0000000080005660 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005660:	7159                	addi	sp,sp,-112
    80005662:	f486                	sd	ra,104(sp)
    80005664:	f0a2                	sd	s0,96(sp)
    80005666:	eca6                	sd	s1,88(sp)
    80005668:	e8ca                	sd	s2,80(sp)
    8000566a:	e4ce                	sd	s3,72(sp)
    8000566c:	e0d2                	sd	s4,64(sp)
    8000566e:	fc56                	sd	s5,56(sp)
    80005670:	f85a                	sd	s6,48(sp)
    80005672:	f45e                	sd	s7,40(sp)
    80005674:	f062                	sd	s8,32(sp)
    80005676:	ec66                	sd	s9,24(sp)
    80005678:	1880                	addi	s0,sp,112
    8000567a:	8a2a                	mv	s4,a0
    8000567c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000567e:	00c52c83          	lw	s9,12(a0)
    80005682:	001c9c9b          	slliw	s9,s9,0x1
    80005686:	1c82                	slli	s9,s9,0x20
    80005688:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000568c:	0001e517          	auipc	a0,0x1e
    80005690:	00c50513          	addi	a0,a0,12 # 80023698 <disk+0x128>
    80005694:	d60fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005698:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000569a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000569c:	0001eb17          	auipc	s6,0x1e
    800056a0:	ed4b0b13          	addi	s6,s6,-300 # 80023570 <disk>
  for(int i = 0; i < 3; i++){
    800056a4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056a6:	0001ec17          	auipc	s8,0x1e
    800056aa:	ff2c0c13          	addi	s8,s8,-14 # 80023698 <disk+0x128>
    800056ae:	a8b9                	j	8000570c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800056b0:	00fb0733          	add	a4,s6,a5
    800056b4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800056b8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056ba:	0207c563          	bltz	a5,800056e4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800056be:	2905                	addiw	s2,s2,1
    800056c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056c2:	05590963          	beq	s2,s5,80005714 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800056c6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056c8:	0001e717          	auipc	a4,0x1e
    800056cc:	ea870713          	addi	a4,a4,-344 # 80023570 <disk>
    800056d0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800056d2:	01874683          	lbu	a3,24(a4)
    800056d6:	fee9                	bnez	a3,800056b0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800056d8:	2785                	addiw	a5,a5,1
    800056da:	0705                	addi	a4,a4,1
    800056dc:	fe979be3          	bne	a5,s1,800056d2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800056e0:	57fd                	li	a5,-1
    800056e2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800056e4:	01205d63          	blez	s2,800056fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056e8:	f9042503          	lw	a0,-112(s0)
    800056ec:	d07ff0ef          	jal	800053f2 <free_desc>
      for(int j = 0; j < i; j++)
    800056f0:	4785                	li	a5,1
    800056f2:	0127d663          	bge	a5,s2,800056fe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056f6:	f9442503          	lw	a0,-108(s0)
    800056fa:	cf9ff0ef          	jal	800053f2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056fe:	85e2                	mv	a1,s8
    80005700:	0001e517          	auipc	a0,0x1e
    80005704:	e8850513          	addi	a0,a0,-376 # 80023588 <disk+0x18>
    80005708:	8b7fc0ef          	jal	80001fbe <sleep>
  for(int i = 0; i < 3; i++){
    8000570c:	f9040613          	addi	a2,s0,-112
    80005710:	894e                	mv	s2,s3
    80005712:	bf55                	j	800056c6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005714:	f9042503          	lw	a0,-112(s0)
    80005718:	00451693          	slli	a3,a0,0x4

  if(write)
    8000571c:	0001e797          	auipc	a5,0x1e
    80005720:	e5478793          	addi	a5,a5,-428 # 80023570 <disk>
    80005724:	00a50713          	addi	a4,a0,10
    80005728:	0712                	slli	a4,a4,0x4
    8000572a:	973e                	add	a4,a4,a5
    8000572c:	01703633          	snez	a2,s7
    80005730:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005732:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005736:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000573a:	6398                	ld	a4,0(a5)
    8000573c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000573e:	0a868613          	addi	a2,a3,168
    80005742:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005744:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005746:	6390                	ld	a2,0(a5)
    80005748:	00d605b3          	add	a1,a2,a3
    8000574c:	4741                	li	a4,16
    8000574e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005750:	4805                	li	a6,1
    80005752:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005756:	f9442703          	lw	a4,-108(s0)
    8000575a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000575e:	0712                	slli	a4,a4,0x4
    80005760:	963a                	add	a2,a2,a4
    80005762:	058a0593          	addi	a1,s4,88
    80005766:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005768:	0007b883          	ld	a7,0(a5)
    8000576c:	9746                	add	a4,a4,a7
    8000576e:	40000613          	li	a2,1024
    80005772:	c710                	sw	a2,8(a4)
  if(write)
    80005774:	001bb613          	seqz	a2,s7
    80005778:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000577c:	00166613          	ori	a2,a2,1
    80005780:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005784:	f9842583          	lw	a1,-104(s0)
    80005788:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000578c:	00250613          	addi	a2,a0,2
    80005790:	0612                	slli	a2,a2,0x4
    80005792:	963e                	add	a2,a2,a5
    80005794:	577d                	li	a4,-1
    80005796:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000579a:	0592                	slli	a1,a1,0x4
    8000579c:	98ae                	add	a7,a7,a1
    8000579e:	03068713          	addi	a4,a3,48
    800057a2:	973e                	add	a4,a4,a5
    800057a4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057a8:	6398                	ld	a4,0(a5)
    800057aa:	972e                	add	a4,a4,a1
    800057ac:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057b0:	4689                	li	a3,2
    800057b2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057b6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057ba:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800057be:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057c2:	6794                	ld	a3,8(a5)
    800057c4:	0026d703          	lhu	a4,2(a3)
    800057c8:	8b1d                	andi	a4,a4,7
    800057ca:	0706                	slli	a4,a4,0x1
    800057cc:	96ba                	add	a3,a3,a4
    800057ce:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057d2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057d6:	6798                	ld	a4,8(a5)
    800057d8:	00275783          	lhu	a5,2(a4)
    800057dc:	2785                	addiw	a5,a5,1
    800057de:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057e2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800057e6:	100017b7          	lui	a5,0x10001
    800057ea:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800057ee:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800057f2:	0001e917          	auipc	s2,0x1e
    800057f6:	ea690913          	addi	s2,s2,-346 # 80023698 <disk+0x128>
  while(b->disk == 1) {
    800057fa:	4485                	li	s1,1
    800057fc:	01079a63          	bne	a5,a6,80005810 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005800:	85ca                	mv	a1,s2
    80005802:	8552                	mv	a0,s4
    80005804:	fbafc0ef          	jal	80001fbe <sleep>
  while(b->disk == 1) {
    80005808:	004a2783          	lw	a5,4(s4)
    8000580c:	fe978ae3          	beq	a5,s1,80005800 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005810:	f9042903          	lw	s2,-112(s0)
    80005814:	00290713          	addi	a4,s2,2
    80005818:	0712                	slli	a4,a4,0x4
    8000581a:	0001e797          	auipc	a5,0x1e
    8000581e:	d5678793          	addi	a5,a5,-682 # 80023570 <disk>
    80005822:	97ba                	add	a5,a5,a4
    80005824:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005828:	0001e997          	auipc	s3,0x1e
    8000582c:	d4898993          	addi	s3,s3,-696 # 80023570 <disk>
    80005830:	00491713          	slli	a4,s2,0x4
    80005834:	0009b783          	ld	a5,0(s3)
    80005838:	97ba                	add	a5,a5,a4
    8000583a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000583e:	854a                	mv	a0,s2
    80005840:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005844:	bafff0ef          	jal	800053f2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005848:	8885                	andi	s1,s1,1
    8000584a:	f0fd                	bnez	s1,80005830 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000584c:	0001e517          	auipc	a0,0x1e
    80005850:	e4c50513          	addi	a0,a0,-436 # 80023698 <disk+0x128>
    80005854:	c38fb0ef          	jal	80000c8c <release>
}
    80005858:	70a6                	ld	ra,104(sp)
    8000585a:	7406                	ld	s0,96(sp)
    8000585c:	64e6                	ld	s1,88(sp)
    8000585e:	6946                	ld	s2,80(sp)
    80005860:	69a6                	ld	s3,72(sp)
    80005862:	6a06                	ld	s4,64(sp)
    80005864:	7ae2                	ld	s5,56(sp)
    80005866:	7b42                	ld	s6,48(sp)
    80005868:	7ba2                	ld	s7,40(sp)
    8000586a:	7c02                	ld	s8,32(sp)
    8000586c:	6ce2                	ld	s9,24(sp)
    8000586e:	6165                	addi	sp,sp,112
    80005870:	8082                	ret

0000000080005872 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005872:	1101                	addi	sp,sp,-32
    80005874:	ec06                	sd	ra,24(sp)
    80005876:	e822                	sd	s0,16(sp)
    80005878:	e426                	sd	s1,8(sp)
    8000587a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000587c:	0001e497          	auipc	s1,0x1e
    80005880:	cf448493          	addi	s1,s1,-780 # 80023570 <disk>
    80005884:	0001e517          	auipc	a0,0x1e
    80005888:	e1450513          	addi	a0,a0,-492 # 80023698 <disk+0x128>
    8000588c:	b68fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005890:	100017b7          	lui	a5,0x10001
    80005894:	53b8                	lw	a4,96(a5)
    80005896:	8b0d                	andi	a4,a4,3
    80005898:	100017b7          	lui	a5,0x10001
    8000589c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000589e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058a2:	689c                	ld	a5,16(s1)
    800058a4:	0204d703          	lhu	a4,32(s1)
    800058a8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058ac:	04f70663          	beq	a4,a5,800058f8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058b0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058b4:	6898                	ld	a4,16(s1)
    800058b6:	0204d783          	lhu	a5,32(s1)
    800058ba:	8b9d                	andi	a5,a5,7
    800058bc:	078e                	slli	a5,a5,0x3
    800058be:	97ba                	add	a5,a5,a4
    800058c0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058c2:	00278713          	addi	a4,a5,2
    800058c6:	0712                	slli	a4,a4,0x4
    800058c8:	9726                	add	a4,a4,s1
    800058ca:	01074703          	lbu	a4,16(a4)
    800058ce:	e321                	bnez	a4,8000590e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058d0:	0789                	addi	a5,a5,2
    800058d2:	0792                	slli	a5,a5,0x4
    800058d4:	97a6                	add	a5,a5,s1
    800058d6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058d8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058dc:	f2efc0ef          	jal	8000200a <wakeup>

    disk.used_idx += 1;
    800058e0:	0204d783          	lhu	a5,32(s1)
    800058e4:	2785                	addiw	a5,a5,1
    800058e6:	17c2                	slli	a5,a5,0x30
    800058e8:	93c1                	srli	a5,a5,0x30
    800058ea:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058ee:	6898                	ld	a4,16(s1)
    800058f0:	00275703          	lhu	a4,2(a4)
    800058f4:	faf71ee3          	bne	a4,a5,800058b0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800058f8:	0001e517          	auipc	a0,0x1e
    800058fc:	da050513          	addi	a0,a0,-608 # 80023698 <disk+0x128>
    80005900:	b8cfb0ef          	jal	80000c8c <release>
}
    80005904:	60e2                	ld	ra,24(sp)
    80005906:	6442                	ld	s0,16(sp)
    80005908:	64a2                	ld	s1,8(sp)
    8000590a:	6105                	addi	sp,sp,32
    8000590c:	8082                	ret
      panic("virtio_disk_intr status");
    8000590e:	00002517          	auipc	a0,0x2
    80005912:	ef250513          	addi	a0,a0,-270 # 80007800 <etext+0x800>
    80005916:	e7ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
