;
; segment_and_digit_test.asm
;
; Created: 10/18/2020 7:47:38 PM
; Author : tyler ovenden
; 112122685
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list
; Replace with your application code
start:
 ; configure I/O ports
	ldi r17, 0xFF			;load r16 with all 1s
	out VPORTD_DIR, r17		;PORTD - all pins configured as outputs
	out VPORTC_DIR, r17 ;PORTD - all pins configured as outputs
	ldi r17, 0x00			; load r16 with all 0s
	out VPORTE_DIR, r17		; PORTE - all pins configured as inputsmain_loop:	mov r19, r17            ;setting r19 to 0 for counter	out VPORTD_OUT, r17     ;set 7 segment display with          	ldi r18, 0x7F           ;register representing first 7 segmenet delay digit	out VPORTC_OUT, r18     ;turns on first digit of display 	rcall delay             ;1 second delay	ldi r18, 0xBF           ;register representing 2nd 7 segmenet delay digit	out VPORTC_OUT, 0xBF    ;turns on 2nd digit of display	rcall delay             ;1 second delay	ldi r18, 0xDF           ;register representing 3rd 7 segmenet delay digit	out VPORTC_OUT, 0xDF    ;turns on 3rd digit of display	rcall delay             ;1 second delay	ldi r18, 0xEF           ;register representing 4th 7 segmenet delay digit	out VPORTC_OUT, 0xEF    ;turns on 4th digit of display	rcall delay             ;1 second delay	rjmp main_loop          ;restart loop	delay: 	ldi r16, 0xFA           ;load r16 with hex for 250, so there's a 250 ms delay	rcall var_delay         ;calls var_delay once	inc r19                 ;increase r19 which acts as a counter 	cpi r19, 0x28           ;hex for 40, used to repeat loop 40 times because 250 ms * 40 = 1 second	brne delay              ;branchs back to beginning if r19 is not 40	ldi r19, 0x00           ;when it is 40, set r19 back to 0	ret                     ;end subroutine    var_delay: 		outer_loop:		ldi r17, 110              ;loads r17 with 110		inner_loop: 		dec r17                  ;decreases r17		brne inner_loop         ;branchs to start of inner_loop if not equal		dec r16                 ;decreases 16		brne outer_loop          ;branchs to outer_loop if not equal		ret            ;ends subroutine 	