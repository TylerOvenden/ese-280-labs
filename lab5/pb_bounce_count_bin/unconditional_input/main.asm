;
; unconditional_input.asm
;
; Created: 10/4/2020 3:35:17 PM
; Author : tyler
;

.nolist
.include "m4809def.inc"
.list
; Replace with your application code
 start:
 ; configure I/O ports
	ldi r16, 0xFF ;load r16 with all 1s
	out VPORTD_DIR, r16 ;PORTD - all pins configured as outputs
	ldi r16, 0x00 ; load r16 with all 0s
	out VPORTA_DIR, r16 ; PORTA - all pins configured as inputs
main_loop:
in r16, VPORTA_IN  ;load r16 with input from the switch
out VPORTD_OUT, r16   ;display inputs from switch onto 7 segment display
rjmp main_loop       ;repeat the loop
