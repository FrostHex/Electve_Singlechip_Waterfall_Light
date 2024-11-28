        THUMB
        REQUIRE8
        PRESERVE8

        EXPORT Delay_Init
        EXPORT Delay_Ms
        EXPORT Delay_Us

        IMPORT SystemCoreClock [DATA]
			
;*******************************
;��  �ܣ���ʱ��ʼ������
;��  ������
;����ֵ����
;******************************

        AREA ||i.Delay_Init||, CODE, READONLY, ALIGN=2

|L048|  DCD      SystemCoreClock    ; SystemCoreClock is a variable from outside. Define Constant Data. |L048| is the pointer of variable SystemCoreClock, so it's an address
	
|L052|  EQU      0x007a1200
|US|    EQU      fam_nus
|MS|    EQU      fam_nms

Delay_Init PROC
        MOVS     r0,#0
        MOV      r1,#0xe000e000		; SCS_BASE
        STR      r0,[r1,#0x10]		; SysTick->CTRL = 0x0. Store the value of R0 to the address (the address of r1 + 0x10 as offset)
        LDR      r0,=|L048|         ; r0 = SystemCoreClock. =αָ��. Used "=" to get the address of |L048|
        LDR      r0,[r0,#0]  		
        LDR      r1,=|L052|         ; r1 = 0x007a1200 = 8000000
        UDIV     r0,r0,r1           ; unsigned division. r0 = r0/r1 = SystemCoreClock/8000000
        LDR      r1,=|US|            
        STR      r0,[r1,#0]  		; fam_nus = SystemCoreClock/8000000
        MOV      r0,r1			
        LDR      r0,[r0,#0]  		; fam_nus
        MOV      r1,#0x3e8
        MULS     r0,r1,r0
        LDR      r1,=|MS|
        STR      r0,[r1,#0]  		; fam_nms = am_nus*1000
        MOVS     r0,#0
        MOV      r1,#0xe000e000
        STR      r0,[r1,#0x18]		; SysTick->VAL = 0x00, set to zero
        BX       lr
        ENDP

;*******************************
;��  �ܣ�΢����ʱ
;��  ����ctr  ΢��
;����ֵ����
;********************************
        AREA ||i.Delay_Us||, CODE, READONLY, ALIGN=2

;void Delay_Init(void)
Delay_Us PROC
        MOV      r1,r0
        MOVS     r0,#0
        LDR      r2,=|US|
        LDR      r2,[r2,#0]  		; fam_nus
        MULS     r2,r1,r2
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x14]		; SysTick->LOAD = fam_nus*ctr		
        MOVS     r2,#0
        STR      r2,[r3,#0x18]		; SysTick->VAL = 0
        MOV      r2,r3
        LDR      r2,[r2,#0x10]		; Tick_Flag = SysTick->CTRL
        ORR      r2,r2,#1
        STR      r2,[r3,#0x10]		; SysTick->CTRL |= 0x01
        NOP      
|us_do|
        MOV      r2,#0xe000e000
        LDR      r0,[r2,#0x10]
        AND      r2,r0,#0x10000
        CBNZ     r2,|us_while|
        AND      r2,r0,#1
        CMP      r2,#0
        BNE      |us_do|
|us_while|
        MOVS     r2,#0
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x10]		; SysTick->CTRL |= 0x00
        BX       lr
        ENDP

;*******************************
;��  �ܣ�������ʱ
;��  ����ctr  ����
;����ֵ����
;*******************************
        AREA ||i.Delay_Ms||, CODE, READONLY, ALIGN=2

;void Delay_Us(uint16_t ctr)
Delay_Ms PROC
        MOV      r1,r0
        MOVS     r0,#0
        LDR      r2,=|MS|
        LDR      r2,[r2,#0]  ; fam_nms
        MULS     r2,r1,r2
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x14]		; SysTick->LOAD = fam_nms*ctr	
        MOVS     r2,#0
        STR      r2,[r3,#0x18]		; SysTick->VAL = 0
        MOVS     r2,#1
        STR      r2,[r3,#0x10]		; SysTick->CTRL |= 0x01. Set CTRL=1, the timer begins.
        NOP      
|ms_do|
        MOV      r2,#0xe000e000
        LDR      r0,[r2,#0x10]
        AND      r2,r0,#0x10000
        CBNZ     r2,|ms_while|
        AND      r2,r0,#1
        CMP      r2,#0
        BNE      |ms_do|
|ms_while|
        MOVS     r2,#0
        MOV      r3,#0xe000e000
        STR      r2,[r3,#0x10]
        BX       lr
        ENDP

        AREA ||.data||, DATA, ALIGN=2 ; set to DATA region, which in RAM

fam_nus
        DCD      0x00000000
fam_nms
        DCD      0x00000000

        KEEP fam_nus
        KEEP fam_nms

        END
