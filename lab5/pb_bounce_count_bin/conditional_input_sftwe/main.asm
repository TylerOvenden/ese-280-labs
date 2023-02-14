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
	out VPORTA_DIR, r17 ;PORTA - all pins configured as inputs	mov r19, r17        ;load r19 to be a counter	   	 main_loop:      sbis VPORTE_IN, 2       ;checks if PORTE2 (switch button) is 1	rjmp main_loop          ;restarts loop when switch button is 0    rjmp first_one          ;calls first_one loop if PORTE2 is 1      first_one: 	  ldi r16, 100;        ;sets register to 100 for delay      rcall var_delay       ;calls delay subroutine for debouncing	 sbis VPORTE_IN, 2     ;checks if PORTE2 (switch button) is still one 1	 rjmp main_loop        ;if it is no longer 1, restarts main_loop 	 rjmp display          ;calls display function    display:	sbi VPORTE_IN , 1       ;sets flip flop output to 1 	cbi VPORTE_IN , 0       ;sets clear to 0     in r16, VPORTA_IN       ;loads switch values into register
    out VPORTD_OUT, r16     ;sets display to switch values	rjmp check_zero         ;calls check_zero loop    check_zero: 	 ldi r16, 100;              ;sets register to 100 for delay 	 sbic VPORTE_IN, 2          ;checks if push button is released	 rjmp check_zero            ;if push button still down restarts loop	 rcall var_delay           ;calls delay subroutine for debouncing	 sbic VPORTE_IN, 2         ;checks if push button is still released	 rjmp check_zero           ;if push button no longer released restart loop	 rjmp reset                ;calls loop to reset & clear the display		reset: 	ldi r16, 0x00        ;clear a register	out VPORTD_OUT, r16  ;clears the display    cbi VPORTE_IN , 1    ;sets flip flop output to 0 	sbi VPORTE_IN , 0    ;sets clear to 0 	rjmp main_loop       ;return to main_loop       var_delay: 		outer_loop:		ldi r17, 110              ;loads r17 with 110		inner_loop: 		dec r17                  ;decreases r17		brne inner_loop         ;branchs to start of inner_loop if not equal		dec r16                 ;decreases 16		brne outer_loop          ;branchs to outer_loop if not equal		ret            ;ends subroutine 	