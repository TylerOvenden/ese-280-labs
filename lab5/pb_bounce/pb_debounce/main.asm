;
; pb_debounce.asm
;
; Created: 10/9/2020 2:01:16 PM
; Author : user38x
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
	out VPORTD_OUT,r17
	ldi r17, 0x00			; load r16 with all 0s
	out VPORTE_DIR, r17		; PORTE - all pins configured as inputs
	ldi r19, 0x00			;  load r19 to be a counter

main_loop:  
    sbis VPORTE_IN, 0        ;skip if PORTDE0 == 1
	rjmp main_loop           ;calls main_loop until PORTDE0 ==1
    rjmp first_one           ;calls first_one loop

first_one: 
	  ldi r16, 100;           ;loads r16 for using in delay subroutine
	 sbic VPORTE_IN, 0         ;skip if PORTDE0 == 0
	 rjmp first_one           ;if PORTED0 is 1, reruns loop until it's 0
     rcall var_delay          ;calls var_delay subroutine for debouncing
	 sbic VPORTE_IN, 0        ;checks if PORTDE0 is still 0
	 rjmp main_loop           ;if it is now 1, calls first loop again
	 rjmp count               ;PORTDE0 is so calls count loop

count:             
	cpi r19, 0xFF          ;compares the counter to a full 8 bit counter 
	breq reset             ;if r19 = 0x99 calls loop to set counter to 0
    inc r19                ;else the counter is increased by one
	com r19
	out VPORTD_OUT, r19      ;VPORTD is set to display the counter
	com r19
	rjmp check_one         ;now calls check_one loop


reset: 
	ldi r19, 0x00             ;clears the counter by setting the register to 0                  
	out VPORTD_OUT, r19          ;VPORTD is set to display the counter
	rjmp check_one             ;calls check_one loop
   
  check_one:  
    ldi r16, 100;                  ;loads r16 for using in delay subroutine
    sbis VPORTE_IN, 0              ;checks if VPORTDE0 is 1 
    rjmp check_one                 ;keep restarting loop until PORTDE is 1
	rcall var_delay               ;calls var_delay subroutine for debouncing
	sbis VPORTE_IN, 0             ;checks if VPORTDE0 is still 1
    rjmp check_one                ;restarts loop if it is 0
	rjmp main_loop                ;restarts main_loop


     var_delay: 
		outer_loop:
		ldi r17, 110              ;loads r17 with 110
		inner_loop: 
		dec r17                  ;decreases r17
		brne inner_loop         ;branchs to start of inner_loop if not equal
		dec r16                 ;decreases 16
		brne outer_loop          ;branchs to outer_loop if not equal
		ret            ;ends subroutine 
	
