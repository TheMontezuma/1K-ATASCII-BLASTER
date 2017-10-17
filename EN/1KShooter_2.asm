
            run start

            RTCLOK = $14              ; System counter, incremented in every VBI
            VDSLST = $200             ; Vector for DLI
            SDMCTL = $22f             ; DMA access control
            SDLSTL = $230             ; Display List address
            COLPF0 = $d016            ; Color/Brightness of Playfield 0
            COLBK  = $d01a            ; Color/Brightness of Background
            AUDF1  = $d200            ; Frequency register (Audio Channel 1) 
            AUDC1  = $d201            ; Control register (Audio Channel 1)
            AUDF2  = $d202            ; Frequency register (Audio Channel 2)
            AUDC2  = $d203            ; Control register (Audio Channel 2)
            AUDCTL = $d208            ; Audio Control
            RANDOM = $d20a            ; Random number generator
            NMIEN  = $d40e            ; Non-Maskable Interrupt (NMI) Enable
            WSYNC  = $d40a            ; Wait For Horizontal Sync 
                                      ; A write to this register halts the 6502 program 
                                      ; through the end of the current scanline
            ANTICMODE = $57+$80       ; Default ANTIC-a mode for playfield lines
            WIDTH = 32                ; Width of the virtual screen (in characters)
            BGCOL = 12                ; Number of lines to be colored in DLI
            BGCOUNTER = $89           ; Background color counter

            org $95

DLIST       .byte $70,$70,$70         ; 3x8=24 empty lines
            .byte $70+$80             ; 8 empty lines + DLI
            .byte ANTICMODE-$10       ; Antic mode 7 + DLI + LMS
            .word line1               ; screen memory address
            .byte $70+$80             ; 8 empty lines + DLI
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
LMS1        .word line2               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line3               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line4               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line5               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line6               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line7               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line8               ; screen memory address
            .byte ANTICMODE           ; Antic mode 7 + DLI + LMS + horizontal scrolling
            .word line9               ; screen memory address
            .byte $70+$80             ; 8 empty lines + DLI
            .byte ANTICMODE-$10       ; Antic mode 7 + DLI + LMS
            .word line10              ; screen memory address
            .byte $41                 ; wait for VBI and jump
            .word DLIST               ; to the beginning of the Display List

            org $DD
            
TABLE       .byte $00,$A0,$A2,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A2,$A0

SOUND       .byte $F3,$D9,$C1,$B6,$A2,$90

            org $2000
                
start       lda #%00101011       ; ‭DMA active for DL and P/M
            sta SDMCTL           ; + P/M double line resolution +‬ wide screen

            lda #<DLIST          ; install DL
            sta SDLSTL
            lda #>DLIST          ; MSB of the DLIST address is equal 0
            sta SDLSTL+1
            sta AUDCTL           ; configure Audio Control register
            sta RTCLOK           ; reset RTCLOK counter
            
            lda #<DLI            ; install DLI routine
            sta VDSLST
            lda #>DLI
            sta VDSLST+1
            lda #$C0             ; enable VBI+DLI
            sta NMIEN
            
setVBI      ldy #<VBI            ; install VBI routine
            ldx #>VBI
            lda #6               ; immediate
            jsr $e45c            ; SETVBV

restart     lda RTCLOK
            cmp #25
            bne checktrig        ; has 0,5 seconds passed?
nextvoice   lda #$a8             ; if yes, then
            sta AUDC1            ; configure audio channel 1
            sta AUDC2            ; and channel 2
            lda RANDOM           ; load a random number
            and #%00000011       ; in range: 0 - 3
            tax                  ; copy it to X register
            lda SOUND,x          ; load a value from SOUND+X
            lsr
            sta AUDF1            ; play a sound (channel 1)
            lda SOUND+2,x        ; load a value from SOUND+2+X
            sta AUDF2            ; play a sound (channel 2)
            lda #0
            sta RTCLOK           ; reset RTCLOK counter

checktrig   jmp restart
            
            org $229D
            
VBI         lda #BGCOL          ; reset background color counter for DLI
            sta BGCOUNTER
exitvbi     jmp $e45f           ; SYSVBV

            org $230D

DLI         pha                 ; push Accumulator on the stack
            txa                 ; copy X register to the Accumulator 
            pha                 ; and push it on the stack
            ldx BGCOUNTER       ; load the counter
            lda TABLE,x         ; load color/brightness from the table
            sta WSYNC           ; wait for horizontal sync
            sta COLBK           ; change background color
            ldx #7              ; initialize loop index
pfloop      lda TABLE+3,x       ; load color/brightness from the table
            sbc #$7D            ; substract OFFSET
            sta WSYNC           ; wait for horizontal sync
            sta COLPF0          ; change color
            dex                 ; decrement loop index
            bne pfloop          ; if the index is different than 0, iterate through the loop 
            dec BGCOUNTER       ; decrement index
exitdli     pla                 ; pull a value from the stack 
            tax                 ; copy it to the X register
            pla                 ; pull a value from the stack (keep it in the Accumulator)
            rti                 ; return from the interrupt

line1       .byte "   1K ATASCII BLASTER"

line2 = line1+WIDTH*2
line3 = line2+WIDTH*2
            
            org line2+3
            .byte "F.HOLST+U.PETERSEN"

line4 = line3+WIDTH*2
            
            org line4+8
            .byte "(P) 2014"

line5 = line4+WIDTH*2
line6 = line5+WIDTH*2
line7 = line6+WIDTH*2
line8 = line7+WIDTH*2
line9 = line8+WIDTH*2
line10 = line9+WIDTH*2
