;
; condition.asm
;
; Created: 10/9/2020 2:01:59 PM
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
	ldi r17, 0x00       ;load r16 with all 0s
	out VPORTE_DIR, r17 ;PORTA - all pins configured as inputs
	out VPORTA_DIR, r17 ;PORTA - all pins configured as inputs
	mov r19, r17        ;load r19 to be a counter
	
   

	
 main_loop:  
    sbis VPORTE_IN, 0       ;checks if PORTE0 flip flop is 1
	rjmp main_loop          ;restarts loop when switch button is 0
    rjmp first_one          ;calls first_one loop if PORTE2 is 1

  
    first_one: 
	 rjmp main_loop        ;if it is no longer 1, restarts main_loop 
	 rjmp display          ;calls display function

    display:
	cbi VPORTE_IN , 1       ;sets clear to 0 
    in r16, VPORTA_IN       ;loads switch values into register
	com r16                  ;complement r16
    out VPORTD_OUT, r16     ;sets display to switch values
	rjmp check_zero         ;calls check_zero loop

    check_zero: 
	 sbic VPORTE_IN, 0          ;checks if flip flop outputs 0
	 rjmp check_zero            ;if push button still down restarts loop
	 rjmp reset                ;calls loop to reset & clear the display
	
	reset: 
	ldi r16, 0x00        ;clear a register
	out VPORTD_OUT, r16  ;clears the display
	sbi VPORTE_IN , 1    ;sets clear to 1 
	rjmp main_loop       ;return to main_loop

 