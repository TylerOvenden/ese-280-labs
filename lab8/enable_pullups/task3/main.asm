;
; task3.asm
;
; Created: 10/30/2020 1:07:59 PM
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
    ldi r16, 0x00     ;
	out VPORTA_DIR, r16    ;
	ldi r17, 0xFF
	out VPORTE_DIR, r17
	out VPORTE_DIR, r17
	out VPORTC_DIR, r17
	out VPORTD_OUT, r17

main_loop:
	rcall poll
	rjmp main_loop

		;***************************************************************************
;* 
;* "hex_to_7seg" - Hexadecimal to Seven Segment Conversion
;*
;* Description: Converts a right justified hexadecimal digit to the seven
;* segment pattern required to display it. Pattern is right justified a
;* through g. Pattern uses 0s to turn segments on ON.
;*
;* Author:						Ken Short
;* Version:						1.0						
;* Last updated:				101620
;* Target:						ATmega4809
;* Number of words:				8
;* Number of cycles:			13
;* Low registers modified:		none		
;* High registers modified:		r16, r18, ZL, ZH
;*
;* Parameters: r18: right justified hex digit, high nibble 0
;* Returns: r18: segment values a through g right justified
;*
;* Notes: 
;*
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
;* "poll_digit_entry" - Polls Pushbutton 1 for Conditional Digit Entry
;*
;* Description:
;* Polls the flag associated with pushbutton 1. This flag is connected to
;* PE0. If the flag is set, the contents of the array bcd_entries is shifted
;* left and the BCD digit set on the least significant 4 bits of PORTA_IN are 
;* stored in the least significant byte of the bcd_entries array. Then the
;* corresponding segment values for each digit in the bcd_entries display are
;* written into the led_display. Note: entry of a non-BCD value is ignored.
;* Author:   Tyler Ovenden
;* Version:
;* Last updated:
;* Target:
;* Number of words: 43
;* Number of cycles: 110
;* Low registers modified: 
;* High registers modified:
;*
;* Parameters: r17, bcd_entires
;* Returns: bcd_entires with added bcd value, updated led_display with current values from bcd_values converted to 7 segment
;*
;* Notes: 
;*
;***************************************************************************
poll:
	ldi r17, VPORTE_IN               ;loads register to check porte
	ldi r17, 2
	andi r17,2                       ;isolates 2nd bit of r17
	cpi r17, 2                   ;checks if 2nd bit is on (0)
	brne poll                        ;restarts subroutine if 2nd bit is 1
	ldi r17, VPORTA_IN               ;loads switch inputs
	andi r17, 0x0F                   ;isolates first 4 bits
	cpi r17, 0x0A                    ;compares it to 10 for BCD
	brge main_loop                   ;if r17 >= 10, start over in main_loop
