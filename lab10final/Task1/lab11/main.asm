;
; lab11.asm
;
; Created: 11/16/2020 9:48:42 AM
; Author : tyler
;


; Replace with your application code

reset:
 	jmp start			;reset vector executed a power on

.org TCA0_OVF_vect
	 jmp display_ISR
start:
;load period low byte then high byte
		ldi r17, 0xFF          ;register to set outputs
	out VPORTC_DIR, r17     ;sets portc as output
	out VPORTD_DIR, r17     ;sets portd as output    
	
	
	
	ldi r16, LOW(160)
	sts TCA0_SINGLE_PER, r16
	ldi r16, HIGH(160)
	sts TCA0_SINGLE_PER+1, r16
	ldi r16, TCA_SINGLE_CLKSEL_DIV256_gc | TCA_SINGLE_ENABLE_bm
	sts TCA0_SINGLE_CTRLA, r16


	sei		