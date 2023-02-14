;
; pb_bounce_count_bin.asm
;
; Created: 10/4/2020 2:03:45 PM
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
	mov r19, r16      ;  load r19 to be a counter
	out VPORTE_DIR, r19 ; PORTE - all pins configured as inputs