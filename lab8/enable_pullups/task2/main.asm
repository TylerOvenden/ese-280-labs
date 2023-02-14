;
; task2.asm
;
; Created: 10/30/2020 1:06:38 PM
; Author : user38x
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list
.dseg
digit_number: .byte 1     ;creates variable representing the place of the digits
led_display: .byte 4      ;creates array representing the led

.cseg
; Replace with your application code
start:
    ldi r16, 0x00     ;
	out VPORTA_DIR, r16    ;loads porta as an input
	ldi r17, 0xFF          ;register to set outputs
	ldi XH, HIGH(led_display)     ;creates pointer set to PINOCTRL
	ldi XL, LOW(led_display)      ;
	out VPORTC_DIR, r17     ;sets portc as output
	out VPORTD_DIR, r17     ;sets portd as output
	sts digit_number, r16   ;sets digital number to 0, to represent the first digit being set to display

main_loop:
	rcall multiplex         ;calls multiplex subroutine     
	rjmp main_loop

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
;* Number of words:            50 
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
;* Returns: Outputs segment pattern and turns on digit driver for the next
;*  position in the display to be turned ON in the multiplexing sequence.
;*
;* Notes: 
;*
;***************************************************************************
	
multiplex:
	lds r16, digit_number            ;loads digit number into register
	andi r16, 3                      ;isolates last 2 bits
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
	rjmp end
 second: 
	ldi r18, 0xDF
	out VPORTC_OUT, r18            ;turns on second digit
	rjmp end
 third: 
	ldi r18, 0xBF
	out VPORTC_OUT, r18           ;turns on 3rd digit
	rjmp end
 fourth:   
	ldi r18, 0x7F 
	out VPORTC_OUT, r18            ;turns on 4th digit
	ldi XH, HIGH(led_display)     ;resets pointer 
	ldi XL, LOW(led_display)      ;
	rjmp end
 end:
	out VPORTD_OUT, r17            ;puts array contents into display
	inc r16                           
	sts digit_number, r16          ;increases digit number
	ret

