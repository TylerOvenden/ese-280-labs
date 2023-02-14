;
; conditional_input_sftwe.asm
;
; Created: 10/7/2020 5:48:15 PM
; Author : tyler
;
.nolist
.include "m4809def.inc"
.list

; Replace with your application code
start:
 ; configure I/O ports
	ldi r17, 0xFF ;load r16 with all 1s
	out VPORTD_DIR, r17 ;PORTD - all pins configured as outputs
	ldi r17, 0x00       ;load r16 with all 0s
	out VPORTE_DIR, r17 ;PORTA - all pins configured as inputs
	out VPORTA_DIR, r17 ;PORTA - all pins configured as inputs
    out VPORTD_OUT, r16     ;sets display to switch values