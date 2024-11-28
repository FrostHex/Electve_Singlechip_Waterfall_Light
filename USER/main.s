;
;ʵ�����ƣ�LED��ʱ��˸ʵ��
;
;Ӳ��ģ�飺�����ԭ��Ӧ��ʵ����
;
;Ӳ�����ߣ�ARM P12�ӿ�---------LED P2�ӿ�
;           PC0~PC7----------LED0~LED7
;		     ע����ʹ��20P����ֱ��P12��P2�ӿڡ�
;					 
;ʵ������LED��ÿ500�����ƽ��תһ�Σ�ʵ����ʱ��˸Ч����
;
;����ʱ�䣺2018-10-11
;**************************************************************
        THUMB
        REQUIRE8
        PRESERVE8

__ARM_use_no_argv EQU 0
		
; define several constants
; e.g. .equ OFFSET,0x00 is for GNU assembler (GNU ���). We should use standard assember like: OFFSET EQU 0x00
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

MODER3_OUT              EQU     1<<6 ; every port occupies 2 places, and set to 01 for universal output mode, which can be found in STM32F4xx manual, P187

LED3_ON                 EQU     1<<3
LED3_OFF                EQU     0<<3

	
        EXPORT __ARM_use_no_argv
        EXPORT main

        IMPORT Delay_Init
        IMPORT Delay_Ms

        AREA ||i.main||, CODE, READONLY, ALIGN=2

|GPIOC| ; use the port of C
        DCD      0x40021400
;int main(void)		
main PROC  ; compile instruction (����ָʾָ��), which indicates it's a sub-function (�Ӻ���)
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
		ORR		R1,#MODER3_OUT
		STR		R1,[R0]

		BL      Delay_Init				;delay initialize

		; GPIOC->ODR |= LED_ON
		LDR 	R0,=GPIOC_ODR
		LDR		R1,=LED3_ON
		STR		R1,[R0] 

        MOV     r0,#0x1f4
		BL      Delay_Ms

|loop|
        LDR 	R0,=GPIOC_ODR
		LDR		R1,=LED3_OFF
		STR		R1,[R0]

        MOV     r0,#0x1f4
        BL      Delay_Ms				; delay 500ms

        LDR 	R0,=GPIOC_ODR
		LDR		R1,=LED3_ON
		STR		R1,[R0]
 
        MOV     r0,#0x1f4
        BL      Delay_Ms				; delay 500ms
        
		B       |loop|
        ENDP    ; the end of the sub-function

        END