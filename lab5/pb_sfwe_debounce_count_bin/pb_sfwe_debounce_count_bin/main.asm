;
; pb_sfwe_debounce_count_bin.asm
;
; Created: 10/4/2020 3:50:51 PM
; Author : tyler
;

.nolist
.include "m4809def.inc"
.list
; Replace with your application code
start:
 ; configure I/O ports
	ldi r17, 0xFF			;load r16 with all 1s
	out VPORTD_DIR, r17		;PORTD - all pins configured as outputs
	ldi r17, 0x00			; load r16 with all 0s
	out VPORTE_DIR, r17		; PORTE - all pins configured as inputs
	ldi r19, 0x00			;  load r19 to be a counter