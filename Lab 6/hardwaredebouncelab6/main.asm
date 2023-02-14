;
; hardwaredebouncelab6.asm
;
; Created: 10/16/2020 2:13:23 PM
; Author : user38x
;


; Replace with your application code
.nolist
.include "m4809def.inc"
.list
; Replace with your application code
 start:
 ; configure I/O ports
	ldi r16, 0xFF ;load r16 with all 1s
	out VPORTD_DIR, r16 ;PORTD - all pins configured as outputs
	out VPORTD_OUT,r16   ;clearing the output
	ldi r16, 0x00 ; load r16 with all 0s
	mov r19, r16      ;  load r19 to be a counter
	out VPORTE_DIR, r19 ; PORTE - all pins configured as inputs
 
 main_loop:
   sbis VPORTE_IN, 0    ;skip if PORTDE0 == 1
   rjmp main_loop       ;if PORTDE0 is 0 calls the loop again & will repeat until PORTDE0 is 1
   rjmp check_one       ;if PORTDE0 is 1 calls check_one loop


check_one:
   sbic VPORTE_IN, 0     ;skip if PORTDE0 == 0
   rjmp check_one         ;if PORTDE0 is 1 calls the loop again & will repeat until PORTDE0 is 0
   rjmp count             ;if PORTDE0 is 0 calls loop to increment the counter

count:             
	cpi r19, 0xFF          ;compares the counter to a full 8 bit counter 
	breq reset             ;if r19 = 0xFF calls loop to set counter to 0
    inc r19                 ;else the counter is increased by one            
	com r19                 ;gets complement of count to set portd
	out VPORTD_OUT, r19      ;VPORTD is set to display the counter
	com r19                 ;complements the register back
	rjmp main_loop        ;calls the main loop again

reset: 
	ldi r19, 0x00             ;clears the counter by setting the register to 0                  
	out VPORTD_OUT, r19          ;VPORTD is set to display the counter
	rjmp main_loop            ;calls the main loop again
   
