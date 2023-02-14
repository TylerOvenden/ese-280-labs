;
; lab8task5.asm
;
; Created: 11/6/2020 1:27:33 PM
; Author : user38x
;


; Replace with your application code
;
; task5.asm
;
; Created: 11/4/2020 11:56:21 PM
; Author : tyler
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list

.dseg
digit_number: .byte 1     ;creates variable representing the place of the digits
bcd_entires: .byte 4      ;creates array representing bcd digits
led_display: .byte 4      ;creates array representing the led
hex_values: .byte 4       ;creates array of hex values 

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
	sbi VPORTE_DIR, 1
	sbi VPORTE_DIR, 3
	cbi VPORTE_DIR, 0	;PE0 input- gets output from PB1
	cbi VPORTE_DIR, 2	;PE2 input- gets output from PB2
	sbi VPORTE_OUT, 1
	sbi VPORTE_OUT, 3

	ldi r16, 0x00     ;loads r16 with all 0s
	out VPORTA_DIR, r16    ;sets PORTA as inputs
	ldi XH, HIGH(PORTA_PIN0CTRL)     ;creates pointer set to PINOCTRL
	ldi XL, LOW(PORTA_PIN0CTRL)      ;
	ldi r17, 8                    ;loops control variable 
	ldi r17, 8                    ;loops control variable 
	rcall enable_pullups

	ldi r18, $01           ;0 in 7 segment display
	sts led_display, r18    ;resets all display digits to 0
	sts led_display+1, r18
	sts led_display+2, r18
	sts led_display+3, r18
	sts digit_number, r16   ;sets digital number to 0, to represent the first digit being set to display
	ldi XH, HIGH(led_display)     ;creates pointer set to led_display array
	ldi XL, LOW(led_display)      ;

	 
main_loop:
	rcall multiplex                
	ldi r16, 20
	rcall delay 
	rcall poll 
	rcall poll_bcd_hex
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
//	andi r19, $
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
	sbrs r17, 0                     ;   
	rjmp test1                        ;restarts subroutine if 2nd bit is 1
	ldi r18, 0x00                     ;sets r18 to a blank register
	mov r16, r18
    in r17, VPORTA_IN               ;loads switch inputs
	rcall reverse
	andi r17, 0x0F                   ;isolates first 4 bits
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
	cbi VPORTE_OUT, 1
	sbi VPORTE_OUT, 1
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
poll_bcd_hex:   
	in r17, VPORTE_IN          ;loads register to check porte
//	ldi r17, 2                 ;cannot set r17 to 2
	sbrs r17, 2                      ;   
	rjmp test                        ;restarts subroutine if 2nd bit is 1
    lds r16, bcd_entires+1           ;take entry 1 to be higher nibble of BCD byte 2
	swap r16                         
	lds r17, bcd_entires              ;take entry 2 to be lower nibble of BCD byte 2
	or r16, r17                        ;creating BCD byte 2
	lds r17, bcd_entires+3              ;take entry 3 to be higher nibble of BCD byte 1
	swap r17
	lds r18, bcd_entires+2              ;take entry 4 to be lower nibble of BCD byte 1
	or r17, r18                         ;creating BCD byte 1   
	ldi r18, 0                          ;creating BCD byte 2
	mov r15, r18                        ; mp10H
	mov r14, r18                        ;mp10L
	mov r19, r17                        ;adder 
	swap r19
	rcall BCD2bin16
	mov r19, r17
	rcall BCD2bin16
	mov r19, r16
	swap r19
	rcall BCD2bin16
	mov r19, r16
    rcall BCD2bin16
	mov r19, r14                  ;copy of tbinH
	mov r17, r19                  ;copy of tbinH
	mov r20, r15			      ;copy of tbinL
	mov r18, r20                  ;copy of tbinL
	andi r19, 0x0F
	andi r20, 0x0F
	andi r17, 0xF0
	andi r18, 0xF0
	swap r17
	swap r18
	sts hex_values, r19         ;storing 1st nibble of  
	sts hex_values+1, r17          ;replaces 1st element with switch values element
	sts hex_values+2, r20           ;replaces 1st element with switch values element
	sts hex_values+3, r18          ;replaces 1st element with switch values element
    lds r18, hex_values+3            ;loads 4th element in bcd_entires
	rcall hex_to_7seg                 ;converts hex to 7seg digit
	sts led_display+3, r18            ;loads 7seg digit into 4th element of led_display
	lds r18, hex_values+2            ;loads 3rd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+2, r18            ;loads 7seg digit into 3rd element of led_display 
	lds r18, hex_values+1           ;loads 2nd element in bcd_entires
	rcall hex_to_7seg                    ;converts hex to 7seg digit
	sts led_display+1, r18             ;loads 7seg digit into 2nd element of led_display
	lds r18, hex_values               ;loads 1st element in bcd_entires
	rcall hex_to_7seg                  ;converts hex to 7seg digit
	sts led_display, r18               ;loads 7seg digit into 1st element of led_display 
	rjmp test
	   
	test:
	cbi VPORTE_OUT, 3
	sbi VPORTE_OUT, 3
	ret 

		
;***************************************************************************
;*
;* "BCD2bin16" - BCD to 16-Bit Binary Conversion
;*
;* This subroutine converts a 5-digit packed BCD number represented by
;* 3 bytes (fBCD2:fBCD1:fBCD0) to a 16-bit number (tbinH:tbinL).
;* MSD of the 5-digit number must be placed in the lowermost nibble of fBCD2.
;*
;* Let "abcde" denote the 5-digit number. The conversion is done by
;* computing the formula: 10(10(10(10a+b)+c)+d)+e.
;* The subroutine "mul10a"/"mul10b" does the multiply-and-add operation
;* which is repeated four times during the computation.
;*
;* Number of words	:30
;* Number of cycles	:108
;* Low registers used	:4 (copyL,copyH,mp10L/tbinL,mp10H/tbinH)
;* High registers used  :4 (fBCD0,fBCD1,fBCD2,adder)	
;*
;***************************************************************************
	BCD2bin16:
	mov r12, r14    ;copy of low
	mov r13, r15    ;copy of high
	lsl r14         ;shifting number to left (multiplying by 2)
	rol r15
	lsl r12         ;shifting copy to left (multiplying by 2)
	rol r13
	lsl r12         ;shifting copy to left (multiplying by 4)
	rol r13
	lsl r12         ;shifting copy to left (multiplying by 6)
	rol r13
	add r14, r12    ;add copy to corresponding nibbles of original
	adc r15, r13
	andi r19, 0x0f   ;masking lower half of adder
	add r14, r19     ;adding adder to lower byte
	brcc finish      ;if carry is not cleared
	inc r15          ;increases high byte
	finish: 
	ret            




	enable_pullups:
	ori r16, 0x08                 ;enables inverted pullup
//	ori r16, 0xF4 
	st X+, r16                    ;stores results & increases pointer
	dec r17                       ;decreases r17 for next loop
	brne enable_pullups            ;loops back if r17 is not 0
	ret
