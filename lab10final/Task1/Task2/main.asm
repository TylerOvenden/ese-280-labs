;
; Task2.asm
;
; Created: 11/13/2020 12:59:26 PM
; Author : user38x
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list


.dseg
digit_number: .byte 1     ;creates variable representing the place of the digits
bcd_entires: .byte 4      ;creates array representing bcd digits
led_display: .byte 4      ;creates array representing the led
hex_values: .byte 4       ;creates array of hex values 

.cseg				;start of code segment
reset:
 	jmp start			;reset vector executed a power on

.org TCA0_OVF_vect
	 jmp display_ISR
.org PORTE_PORT_vect
	jmp porte_isr		;vector for all PORTE pin change IRQs


start:
    ; Configure I/O ports

	cbi VPORTE_DIR, 0	;PE0 input- gets output from PB1
	cbi VPORTE_DIR, 2	;PE2 input- gets output from PB2
		ldi r18, $00           ;0 in 7 segment display
	sts led_display, r18    ;resets all display digits to 0
	sts led_display+1, r18
	sts led_display+2, r18
	sts led_display+3, r18
	sts digit_number, r16   ;sets digital number to 0, to represent the first digit being set to display


		ldi r16, 0x00     ;
	out VPORTA_DIR, r16    ;loads porta as an input
	ldi r17, 0xFF          ;register to set outputs
	out VPORTC_DIR, r17     ;sets portc as output
	out VPORTD_DIR, r17     ;sets portd as output      


	ldi r16, 0x00     ;loads r16 with all 0s
	out VPORTA_DIR, r16    ;sets PORTA as inputs
	ldi XH, HIGH(PORTA_PIN0CTRL)     ;creates pointer set to PINOCTRL
	ldi XL, LOW(PORTA_PIN0CTRL)      ;
	ldi r17, 8                    ;loops control variable 
	ldi r17, 8                    ;loops control variable 
	rcall enable_pullups


	ldi XH, HIGH(led_display)     ;creates pointer set to led_display array
	ldi XL, LOW(led_display)      ;
	



	
	;Configure interrupts
	lds r16, PORTE_PIN0CTRL	;set ISC for PE0 to pos. edge
	ori r16, 0x02		;set ISC for rising edge
	sts PORTE_PIN0CTRL, r16

	lds r16, PORTE_PIN2CTRL	;set ISC for PE2 to pos. edge
	ori r16, 0x02		;set ISC for rising edge
	sts PORTE_PIN2CTRL, r16

	ldi r16, TCA_SINGLE_WGMODE_NORMAL_gc  ;WGMODE normal 
	sts TCA0_SINGLE_CTRLB, r16 
	ldi r16, TCA_SINGLE_OVF_bm
	sts TCA0_SINGLE_INTCTRL, r16 

	;load period low byte then high byte
	ldi r16, LOW(160)
	sts TCA0_SINGLE_PER, r16
	ldi r16, HIGH(160)
	sts TCA0_SINGLE_PER+1, r16
	ldi r16, TCA_SINGLE_CLKSEL_DIV256_gc | TCA_SINGLE_ENABLE_bm
	sts TCA0_SINGLE_CTRLA, r16






	sei			;enable global interrupts
    
main_loop:		;main program loop
	nop
	rjmp main_loop 




	display_ISR: 
	push r16
	cli				;clear global interrupt enable

	rcall multiplex
	ldi r16, TCA_SINGLE_OVF_bm ;clear OVF flag
	sts TCA0_SINGLE_INTFLAGS, r16

	pop r16
	reti			;return from PORTE pin change ISR


;Interrupt service routine for any PORTE pin change IRQ
porte_ISR:


	
	push r16
	cli				;clear global interrupt enable

	;Determine which pins of PORTE have IRQs
	lds r16, PORTE_INTFLAGS	;check for PE0 IRQ flag set
	sbrc r16, 0
	rcall intr_digit_entry			;execute subroutine for PE0

	lds r16, PORTE_INTFLAGS	;check for PE2 IRQ flag set
	sbrc r16, 2
	rcall intr_bcd_hex			;execute subroutine for PE2
	
	ldi r16, PORT_INT0_bm	;clear IRQ flag for PE2
	sts PORTE_INTFLAGS, r16
	ldi r16, PORT_INT2_bm	;clear IRQ flag for PE2
	sts PORTE_INTFLAGS, r16
	
	pop r16			;restore SREG then r16


	reti			;return from PORTE pin change ISR


;***************************************************************************
hex_to_7seg:
	andi r18, 0x0F				;clear ms nibble
    ldi ZH, HIGH(hextable * 2)  ;set Z to point to start of table
    ldi ZL, LOW(hextable * 2)
    ldi r16, $00                ;add offset to Z pointer
    add ZL, r18
    adc ZH, r16 
    lpm r18, Z                  ;load byte from table pointed to by Z
	ret

	;table of segment values from 0-F
hextable: .db $01, $4F, $12, $06, $4C, $24, $20, $0F, $00, $04, $08, $60, $31, $32, $30, $38	


;***************************************************************************
;* 
;* "reverses" - reverses a register 
;*
;* Description: Reverses a register using two different registers.
;* shifts r16 then moving that shifted bit into r17 8 times to reverse
;*
;* Author:						Tyler Ovenden
;* Version:						1.0						
;* Last updated:				102120
;* Target:						ATmega4809
;* Number of words:				11
;* Number of cycles:			
;* Low registers modified:		none		
;* High registers modified:		r16, r17
;*
;* Parameters: r16: input from switch
;* Returns: r16: reversed switch input, shifted 4 times to get only bits 7-4 from reversed bit
;*
;* Notes: 
;*
;***************************************************************************


	reverse: 
	ldi r18, 0x00
	repeat:
	lsr r17
	rol r16
	inc r18
	cpi r18, 0x08
	brne repeat
	//swap r16
	mov r17, r16
	ret



;***************************************************************************
;* 
;* "multiplex_display" - Multiplex the Four Digit LED Display
;*
;* Description: Updates a single digit of the display and increments the 
;*  digit_num to the value of the digit position to be displayed next.
;*
;* Author:                  Tyler Ovenden 
;* Version:                    1.0
;* Last updated:                    10/29/20
;* Target:						;ATmega4809 @ 3.3MHz
;* Number of words:             50
;* Number of cycles:           98
;* Low registers modified:	none
;* High registers modified:	none
;*
;* Parameters:
;* led_display: a four byte array that holds the segment values
;*  for each digit of the display. led_display[0] holds the segment pattern
;*  for digit 0 (the rightmost digit) and so on.
;* digit_num: a byte variable, the least significant two bits provide the
;* index of the next digit to be displayed.
;*
;* Parameters: r17, bcd_entires
;* Returns: bcd_entires with added bcd value, updated led_display with current values from bcd_values converted to 7 segment
;* Notes: 
;*
;***************************************************************************
	
	
;***************************************************************************
;* 
;* "multiplex_display" - Multiplex the Four Digit LED Display
;*
;* Description: Updates a single digit of the display and increments the 
;*  digit_num to the value of the digit position to be displayed next.
;*
;* Author:                  Tyler Ovenden 
;* Version:                    1.0
;* Last updated:                    10/29/20
;* Target:						;ATmega4809 @ 3.3MHz
;* Number of words:             50
;* Number of cycles:           98
;* Low registers modified:	none
;* High registers modified:	none
;*
;* Parameters:
;* led_display: a four byte array that holds the segment values
;*  for each digit of the display. led_display[0] holds the segment pattern
;*  for digit 0 (the rightmost digit) and so on.
;* digit_num: a byte variable, the least significant two bits provide the
;* index of the next digit to be displayed.
;*
;* Parameters: r17, bcd_entires
;* Returns: bcd_entires with added bcd value, updated led_display with current values from bcd_values converted to 7 segment
;* Notes: 
;*
;***************************************************************************
	
	
multiplex:
	push r16
	push r17
	push r18
	in r18, CPU_SREG
	push r18

	lds r16, digit_number            ;loads digit number into register
	ld r17, X+                       ;loads register with pointer's contents of array element, increases pointer
	cpi r16, 0                       ;checks if digit number is 0
	breq first
	cpi r16, 1                      ;checks if digit number is 1
	breq second
	cpi r16, 2                      ;checks if digit number is 2
	breq third
	cpi r16, 3                       ;checks if digit number is 3
	breq fourth

  first: 
	ldi r18, 0xEF               
	out VPORTC_OUT, r18             ;turns on first digit
	inc r16   
	rjmp end
 second: 
	ldi r18, 0xDF
	out VPORTC_OUT, r18            ;turns on second digit
	inc r16   
	rjmp end
 third: 
	ldi r18, 0xBF
	out VPORTC_OUT, r18           ;turns on 3rd digit
	inc r16   
	rjmp end
 fourth:   
	ldi r18, 0x7F 
	out VPORTC_OUT, r18            ;turns on 4th digit
	ldi XH, HIGH(led_display)     ;resets pointer 
	ldi XL, LOW(led_display)      ;
	ldi r16, 0                    ;resets registe for digit number
	rjmp end
 end:
	out VPORTD_OUT, r17            ;puts array contents into display                        
	sts digit_number, r16          ;increases digit number
	pop r18
	out CPU_SREG, r18
	pop r18
	pop r17
	pop r16
	ret


;Subroutines called by porte_ISR
intr_digit_entry:		;PE0's task to be done
		push r16
	push r17
	push r18
	in r18, CPU_SREG
	in r17, VPORTA_IN               ;loads switch inputs
	rcall reverse
	andi r17, 0x0F                   ;isolates first 4 bits
	cpi r17, 0x0A                    ;compares it to 10 for BCD
	brsh test                   ;if r17 >= 10, start over in main_loop
	ldi r18, 0x00                     ;sets r18 to a blank register
	mov r16, r18
	
	lds r18, bcd_entires+2           ;loads 3rd element in bcd_entires
	sts bcd_entires+3, r18           ;replaces 4th element with 3rd element
	lds r18, bcd_entires+1            ;loads 2nd element in bcd_entires
	sts bcd_entires+2, r18              ;replaces 3rd element with 2nd element
	lds r18, bcd_entires              ;loads 1st element in bcd_entires
	sts bcd_entires+1, r18            ;replaces 2nd element with 1st element
	sts bcd_entires, r17              ;replaces 1st element with switch values element
	lds r18, bcd_entires+3            ;loads 4th element in bcd_entires
	rcall hex_to_7seg                 ;converts hex to 7seg digit
	sts led_display+3, r18            ;loads 7seg digit into 4th element of led_display
	lds r18, bcd_entires+2            ;loads 3rd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+2, r18            ;loads 7seg digit into 3rd element of led_display 
	lds r18, bcd_entires+1           ;loads 2nd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+1, r18             ;loads 7seg digit into 2nd element of led_display
	lds r18, bcd_entires               ;loads 1st element in bcd_entires
	rcall hex_to_7seg                  ;converts hex to 7seg digit
	sts led_display, r18               ;loads 7seg digit into 1st element of led_display 
	test:
	cbi VPORTE_OUT, 1
	sbi VPORTE_OUT, 1
//	ldi r16, PORT_INT0_bm	;clear IRQ flag for PE0
//	sts PORTE_INTFLAGS, r16
pop r18
	out CPU_SREG, r18
	pop r18
	pop r17
	pop r16
	ret 




intr_bcd_hex:		;PE2's task to be done

	push r16
	push r17
	push r18

    lds r16, bcd_entires+1           ;take entry 1 to be higher nibble of BCD byte 2
	swap r16                         
	lds r17, bcd_entires              ;take entry 2 to be lower nibble of BCD byte 2
	or r16, r17                        ;creating BCD byte 2
	lds r17, bcd_entires+3              ;take entry 3 to be higher nibble of BCD byte 1
	swap r17
	lds r18, bcd_entires+2              ;take entry 4 to be lower nibble of BCD byte 1
	or r17, r18                         ;creating BCD byte 1   
	ldi r18, 0                          ;creating BCD byte 2
	mov r15, r18                        ; mp10H
	mov r14, r18                        ;mp10L
	mov r19, r17                        ;adder 
	swap r19
	rcall BCD2bin16
	mov r19, r17
	rcall BCD2bin16
	mov r19, r16
	swap r19
	rcall BCD2bin16
	mov r19, r16
    rcall BCD2bin16
	mov r19, r14                  ;copy of tbinH
	mov r17, r19                  ;copy of tbinH
	mov r20, r15			      ;copy of tbinL
	mov r18, r20                  ;copy of tbinL
	andi r19, 0x0F
	andi r20, 0x0F
	andi r17, 0xF0
	andi r18, 0xF0
	swap r17
	swap r18
	sts hex_values, r19         ;storing 1st nibble of  
	sts hex_values+1, r17          ;replaces 1st element with switch values element
	sts hex_values+2, r20           ;replaces 1st element with switch values element
	sts hex_values+3, r18          ;replaces 1st element with switch values element
    lds r18, hex_values+3            ;loads 4th element in bcd_entires
	rcall hex_to_7seg                 ;converts hex to 7seg digit
	sts led_display+3, r18            ;loads 7seg digit into 4th element of led_display
	lds r18, hex_values+2            ;loads 3rd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+2, r18            ;loads 7seg digit into 3rd element of led_display 
	lds r18, hex_values+1           ;loads 2nd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+1, r18             ;loads 7seg digit into 2nd element of led_display
	lds r18, hex_values               ;loads 1st element in bcd_entires
	rcall hex_to_7seg                  ;converts hex to 7seg digit
	sts led_display, r18               ;loads 7seg digit into 1st element of led_display 
	rjmp test1
	   
	test1:
	cbi VPORTE_OUT, 3
	sbi VPORTE_OUT, 3
//	ldi r16, PORT_INT2_bm	;clear IRQ flag for PE2
//	sts PORTE_INTFLAGS, r16
	pop r18
	pop r17
	pop r16
	ret



	;***************************************************************************
;*
;* "BCD2bin16" - BCD to 16-Bit Binary Conversion
;*
;* This subroutine converts a 5-digit packed BCD number represented by
;* 3 bytes (fBCD2:fBCD1:fBCD0) to a 16-bit number (tbinH:tbinL).
;* MSD of the 5-digit number must be placed in the lowermost nibble of fBCD2.
;*
;* Let "abcde" denote the 5-digit number. The conversion is done by
;* computing the formula: 10(10(10(10a+b)+c)+d)+e.
;* The subroutine "mul10a"/"mul10b" does the multiply-and-add operation
;* which is repeated four times during the computation.
;*
;* Number of words	:30
;* Number of cycles	:108
;* Low registers used	:4 (copyL,copyH,mp10L/tbinL,mp10H/tbinH)
;* High registers used  :4 (fBCD0,fBCD1,fBCD2,adder)	
;*
;***************************************************************************
	BCD2bin16:
	mov r12, r14    ;copy of low
	mov r13, r15    ;copy of high
	lsl r14         ;shifting number to left (multiplying by 2)
	rol r15
	lsl r12         ;shifting copy to left (multiplying by 2)
	rol r13
	lsl r12         ;shifting copy to left (multiplying by 4)
	rol r13
	lsl r12         ;shifting copy to left (multiplying by 6)
	rol r13
	add r14, r12    ;add copy to corresponding nibbles of original
	adc r15, r13
	andi r19, 0x0f   ;masking lower half of adder
	add r14, r19     ;adding adder to lower byte
	brcc finish      ;if carry is not cleared
	inc r15          ;increases high byte
	finish: 
	ret            





		enable_pullups:
	ori r16, 0x08                 ;enables inverted pullup
	st X+, r16                    ;stores results & increases pointer
	dec r17                       ;decreases r17 for next loop
	brne enable_pullups            ;loops back if r17 is not 0
	ret