;
;实验名称：LED延时闪烁实验
;
;硬件模块：计算机原理应用实验箱
;
;硬件接线：ARM P12接口---------LED P2接口
;           PC0~PC7----------LED0~LED7
;		     注：可使用20P排线直连P12、P2接口。
;					 
;实验现象：LED灯每500毫秒电平翻转一次，实现延时闪烁效果。
;
;更新时间：2018-10-11
;**************************************************************
        THUMB
        REQUIRE8
        PRESERVE8

__ARM_use_no_argv EQU 0
		
; define several constants
; e.g. .equ OFFSET,0x00 is for GNU assembler (GNU 汇编). We should use standard assember like: OFFSET EQU 0x00
GPIOC_BASE              EQU     0x40020800 ; base address, can be found in STM32F4xx manual, P53
GPIOC_MODER_OFFSET      EQU     0x00
GPIOC_ODR_OFFSET        EQU     0x14

GPIOC_MODER             EQU     GPIOC_BASE + GPIOC_MODER_OFFSET
GPIOC_ODR               EQU     GPIOC_BASE + GPIOC_ODR_OFFSET

; @RCC:    AHB1ENR
; @rcc base:        0x4002 3800
RCC_BASE                EQU     0x40023800
RCC_AHB1ENR_OFFSET      EQU     0x30

RCC_AHB1ENR             EQU     RCC_BASE + RCC_AHB1ENR_OFFSET

GPIOC_EN                EQU     1<<2

MODER0_OUT              EQU     1<<0
MODER1_OUT              EQU     1<<2 ; every port occupies 2 places, and set to 01 for universal output mode, which can be found in STM32F4xx manual, P187
MODER2_OUT              EQU     1<<4 
MODER3_OUT              EQU     1<<6 
MODER4_OUT              EQU     1<<8
MODER5_OUT              EQU     1<<10 
MODER6_OUT              EQU     1<<12 
MODER7_OUT              EQU     1<<14 

LED0_ON                 EQU     1<<0
LED0_OFF                EQU     0<<0
LED1_ON                 EQU     1<<1
LED1_OFF                EQU     0<<1
LED2_ON                 EQU     1<<2
LED2_OFF                EQU     0<<2
LED3_ON                 EQU     1<<3
LED3_OFF                EQU     0<<3
LED4_ON                 EQU     1<<4
LED4_OFF                EQU     0<<4
LED5_ON                 EQU     1<<5
LED5_OFF                EQU     0<<5
LED6_ON                 EQU     1<<6
LED6_OFF                EQU     0<<6
LED7_ON                 EQU     1<<7
LED7_OFF                EQU     0<<7
	
        EXPORT __ARM_use_no_argv
        EXPORT main

        IMPORT Delay_Init
        IMPORT Delay_Ms

        AREA ||i.main||, CODE, READONLY, ALIGN=2

|GPIOC| ; use the port of C
        DCD      0x40021400
;int main(void)		
main PROC  ; compile instruction (编译指示指令), which indicates it's a sub-function (子函数)
		; RCC->AHB1ENR	|= GPIOC_EN
		; Load address of RCC_AHB1ENR(Enable Register) to r0
		LDR		R0,=RCC_AHB1ENR
		; Load value at the address found in r0 into r1
		LDR		R1,[R0]

		ORR		R1,#GPIOC_EN ; set to 1
		; Store the content in R1 to the address found in r0
		STR		R1,[R0]

		; GPIOC->MODER |= MODER13_OUT
		; the default value of MODE register is 00, which is input mode
		LDR 	R0,=GPIOC_MODER
		LDR		R1,[R0]
		ORR		R1,#MODER0_OUT
		ORR		R1,#MODER1_OUT
		ORR		R1,#MODER2_OUT
		ORR		R1,#MODER3_OUT
		ORR		R1,#MODER4_OUT
		ORR		R1,#MODER5_OUT
		ORR		R1,#MODER6_OUT
		ORR		R1,#MODER7_OUT
		STR		R1,[R0]

		BL      Delay_Init				;delay initialize

		; GPIOC->ODR |= LED_ON
		LDR 	R0,=GPIOC_ODR
		LDR		R1,=LED7_ON
		STR		R1,[R0] 
        MOV     r0,#0x1f4
		 BL      Delay_Ms

|loop|
        LDR 	R0,=GPIOC_ODR
		LDR     R1, [R0]           ; Load current LED state
		ROR     R1, R1, #1         ; 循环右移1位, 7灭6亮, 以此类推
		CMP     R1, #0x80          ; Compare R1 with 10000000b (0x80)
		MOVHI   R1, #0x80          ; If the result of CMP is "higher", then set R1 to 10000000b
		STR		R1,[R0]
        MOV     r0,#0x1f4
        BL      Delay_Ms				; delay 500ms
		
		B       |loop|
        ENDP    ; the end of the sub-function

        END