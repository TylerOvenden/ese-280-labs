;
; ADC_sgnl_conv.asm
;
; Created: 11/16/2020 7:13:59 PM
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

.cseg				;start of code segment
reset:
 	jmp start			;reset vector executed a power on

.org TCA0_OVF_vect
	 jmp display_ISR

start: 

	ldi r18, $00           ;0 in 7 segment display
	sts led_display, r18    ;resets all display digits to 0
	sts led_display+1, r18
	sts led_display+2, r18
	sts led_display+3, r18

	ldi r16, 0x00     ;
	out VPORTA_DIR, r16    ;loads porta as an input
	ldi r17, 0xFF          ;register to set outputs
	out VPORTC_DIR, r17     ;sets portc as output
	out VPORTD_DIR, r17     ;sets portd as output      
	ldi r16, 2              ;2 = 
	sts VREF_CTRLA, r16     ;
	ldi r16, 4              ;4 = input disable, used to configure porte pin1 as analog
	sts PORTE_PIN1CTRL, r16
	ldi r16, 0              
	ori r16, 0x45        ;setting SAMPCAP to 1, setting ADC0 clock prescalar to divide by 64 (0100 0101) 
	sts ADC0_CTRLC, r16
	ldi r16, 9           ;configuring pin 9 as the mux input
	sts   ADC0_MUXPOS,r16
	ldi r16, 1           ;turn on ACD0
	sts ADC0_CTRLA, r16

main_loop:
rcall analogvolt
rjmp main_loop

analogvolt:
ldi r18, 1          ;enable polling
sts ADC0_COMMAND, r18  
polling:
ldi r18, ADC0_INTFLAGS
sbrs r18, 0
rjmp polling
ret 




display_ISR:

