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
	out VPORTE_DIR, r17		; PORTE - all pins configured as inputs