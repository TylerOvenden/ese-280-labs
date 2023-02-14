;
; task4.asm
;
; Created: 10/30/2020 1:35:51 PM
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

.cseg
;***************************************************************************
;*
;* Title: Enter Digits
;* Author:
;* Version:
;* Last updated:
;* Target:			;ATmega4809 @3.3MHz
;*
;* DESCRIPTION
;* This program polls the flag associated with pushbutton 1. This flag is
;* connected to PE0. If the flag is set, the contents of the array bcd_entries
;* is shifted left and the BCD digit set on the least significant 4 bits of
;* PORTA_IN are stored in the least significant byte of the bcd_entries array.
;* Then the corresponding segment values for each digit in the bcd_entries
;* display are written into the led_display. Note: entry of a non-BCD value
;* is ignored.
;*
;* This program also continually multiplexes the display so that the digits
;* entered are conatantly seen on the display. Before any digits are entered
;* the display displays 0000.
;*
;* VERSION HISTORY
;* 1.0 Original version
;***************************************************************************


start:
	ldi r16, 0x00     ;
	out VPORTA_DIR, r16    ;loads porta as an input
	ldi r17, 0xFF          ;register to set outputs
	out VPORTC_DIR, r17     ;sets portc as output
	out VPORTD_DIR, r17     ;sets portd as output      
	cbi VPORTE_DIR, 0	;PE0 input- gets output from PB1
	cbi VPORTE_DIR, 2	;PE2 input- gets output from PB2
	ldi r18, $01           ;0 in 7 segment display
	sts led_display, r18    ;resets all display digits to 0
	sts led_display+1, r18
	sts led_display+2, r18
	sts led_display+3, r18
	sts digit_number, r16   ;sets digital number to 0, to represent the first digit being set to display
	ldi XH, HIGH(led_display)     ;creates pointer set to led_display array
	ldi XL, LOW(led_display)      ;
	cbi VPORTE_DIR, 0	;PE0 input- gets output from PB1

main_loop:
	rcall multiplex                
	ldi r16, 100
//	rcall delay
	rcall poll 
	rjmp main_loop


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
	lsr r17
	rol r16
	inc r18
	cpi r18, 0x08
	brne reverse
	swap r16
	mov r17, r16
	ret




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
	in r17, VPORTE_IN          ;loads register to check porte
	sbrc r17, 0                     ;   
	rjmp test1                        ;restarts subroutine if 2nd bit is 1
	ldi r18, 0x00                     ;sets r18 to a blank register
	mov r16, r18
	rcall reverse
	cpi r17, 0x0A                    ;compares it to 10 for BCD
	brsh test1                   ;if r17 >= 10, start over in main_loop
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
	test1:
	ret 





;***************************************************************************
;* 
;* "mux_digit_delay" - title
;*
;* Description:
;* runs a 10 ms delay
;* Author:    Tyler Ovenden
;* Version:      1.0
;* Last updated:      10/29/20
;* Target:         
;* Number of words:   5
;* Number of cycles: 356
;* Low registers modified:
;* High registers modified:
;*
;* Parameters:
;* Returns:
;*
;* Notes: 
;*
;***************************************************************************

	delay:             
	outer_loop:
	ldi r17, 110
	inner_loop:
	dec r17
	brne inner_loop
	dec r16
	brne outer_loop
	ret