; This demo was only possible because of the 8Blit tutoria "S01E02 Generating a stable screen" on Youtube - https://youtu.be/WcRtIpvjKNI


	processor 6502
	include	 "vcs.h"

TOPCOLOR            = $9a                   ; define a symbol to represent a TIA color value (NTSC)
BORDERHEIGHT		equ		#5			; How many scan lines are our top and bottom borders
	
	seg
	org $f000
	
reset:
; clear RAM and all TIA registers
	ldx #0                              ; load the value 0 into (x)
	lda #0                              ; load the value 0 into (a)
clear:                                  ; define a label 
	sta 0,x                             ; store the value in (a) into the address of 0 at offset (x)
	inx                                 ; increase (x) by 1. it will count up to 255 and then rollover back to 0
	bne clear                           ; branch up to the 'clear' label if (x) != 0

	lda 	#%00000001					; Set D0 to reflect the playfield
	sta 	CTRLPF						; Apply to the CTRLPF register

startFrame:
; start of new frame
; start of vertical blank processing
	lda #0                              ; load the value 0 into (a)
	sta VBLANK                          ; store (a) into the TIA VBLANK register
	lda #2                              ; load the value 2 into (a). 
	sta VSYNC                           ; store (a) into the TIA VSYNC register to turn on vertical sync
	sta WSYNC                           ; write to the TIA WSYNC register to wait until horizontal sync (any value)
;---------------------------------------
	sta WSYNC
;---------------------------------------
	sta WSYNC                           ; we need 3 scanlines of VSYNC for a stable frame
;---------------------------------------
	lda #0
	sta VSYNC                           ; store 0 into the TIA VSUNC register to turn off vertical sync

; generate 37 scanlines of vertical blank
	ldx #0
    stx COLUBK


verticalBlank:   
	sta WSYNC                           ; write to the TIA WSYNC register to wait until horizontal sync (any value)
;---------------------------------------	
	inx
	cpx #37                             ; compare the value in (x) to the immeadiate value of 37
	bne verticalBlank                   ; branch up to the 'verticalBlank' label the compare is not equal

; generate 192 lines of playfield
	ldx #0
    ldy TOPCOLOR
	cpy $EF
	bne setTopColor
	ldy $10
	sty TOPCOLOR
setTopColor:
	inc TOPCOLOR

playfield:

;---------------------------------------
	inx

setLogo:
	cpx #BORDERHEIGHT
	beq step1

	cpx #100
	beq step2

	cpx #110
	beq step2

	cpx #120
	beq step3

	cpx #140
	beq step4

	cpx #150
	beq step5

	cpx #165
	beq step6

	cpx #192-BORDERHEIGHT
	beq endLogo

	jmp drawLogo

step1:
	lda #%11100111
	sta PF2
	jmp drawLogo
	 

step2:
	lda #%00000001
	sta PF1
	jmp drawLogo

step3: 
	lda #%00000011
	sta PF1
	lda #%11100011
	sta PF2
	jmp drawLogo
	

step4:
	lda #%00001111
	sta PF1
	lda #%11100001
	sta PF2
	jmp drawLogo

step5:
	lda #%00111111
	sta PF1
	lda #%11100000
	sta PF2
	jmp drawLogo

step6: 
	lda #%11111100
	sta PF1
	lda #%10000000
	sta PF0
	jmp drawLogo

endLogo:
	lda #%00000000
	sta PF1
	sta PF2
	sta PF0


drawLogo:
    sta WSYNC
	dey
	cpy $0F
	bne setPlayfieldColor
	ldy $DE
setPlayfieldColor:
    sty COLUPF
	cpx #192                            ; compare the value in (x) to the immeadiate value of 192

	bne playfield                       ; branch up to the 'drawField' label the compare is not equal

endplayfield:							; end of playfield - turn on vertical blank
    lda #%01000010
    sta VBLANK          

; generate 30 scanlines of overscan
	ldx #0

overscan:        
	sta WSYNC
;---------------------------------------
	inx
	cpx #30                             ; compare the value in (x) to the immeadiate value of 30
	bne overscan                        ; branch up to the 'overscan' label the compare is not equal
	jmp startFrame                    ; frame is completed, branch back up to the 'startFrame' label
;------------------------------------------------

	org $fffa                           ; set origin to last 6 bytes of 4k rom
	
InterruptVectors:
	.word reset                         ; nmi
	.word reset                         ; reset
	.word reset                         ; irq

