;
; enable_pullups.asm
;
; Created: 10/30/2020 1:05:04 PM
; Author : user38x
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list

.dseg
bcd_entires: .byte 4
led_display: .byte 4
.cseg
; Replace with your application code
start:
	ldi r16, 0x00     ;loads r16 with all 0s
	out VPORTA_DIR, r16    ;sets PORTA as inputs
	ldi XH, HIGH(PORTA_PIN0CTRL)     ;creates pointer set to PINOCTRL
	ldi XL, LOW(PORTA_PIN0CTRL)      ;
	ldi r17, 8                    ;loops control variable 
   
main_loop:
rcall enable_pullups;
rjmp main_loop


enable_pullups:
//	ori r16, 0x08                 ;enables inverted pullup
	ori r16, 0xF4 
	st X+, r16                    ;stores results & increases pointer
	dec r17                       ;decreases r17 for next loop
	brne enable_pullups            ;loops back if r17 is not 0
	ret
