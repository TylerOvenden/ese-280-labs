;
; conditionalHardware.asm
;
; Created: 10/16/2020 3:14:19 PM
; Author : user38x
;




; Replace with your application code
.nolist
.include "m4809def.inc"
.list

; Replace with your application code
start:
 ; configure I/O ports
	ldi r17, 0xFF ;load r16 with all 1s
	out VPORTD_DIR, r17 ;PORTD - all pins configured as outputs
	out VPORTD_OUT,r17   ;clears the display
	ldi r17, 0x02       ;load r16 with all 0s
	out VPORTE_DIR, r17 ;PORTA - all pins configured as inputs
	
 main_loop:  
    sbis VPORTE_IN, 0       ;checks if PORTE0 flip flop is 1
	rjmp main_loop          ;restarts loop when switch button is 0


    display:
	cbi VPORTE_IN , 1       ;sets clear to 0 
    in r16, VPORTA_IN       ;loads switch values into register
	com r16                  ;complement r16
    out VPORTD_OUT, r16     ;sets display to switch values
	sbi VPORTE_IN , 1    ;sets clear to 1 
	rjmp main_loop       ;return to main_loop

 