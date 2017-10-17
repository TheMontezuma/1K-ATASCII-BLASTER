
            run start

            RTCLOK = $14              ; System counter, incremented in every VBI
            ATRACT = $4d              ; Screensaver control
            VDSLST = $200             ; Vector for DLI
            SDMCTL = $22f             ; DMA access control
            SDLSTL = $230             ; Display List address
            GPRIOR = $26f             ; P/M configuration (priorities, etc.)
            STICK0 = $278             ; Joystick 1 position
            STRIG0 = $284             ; Joystick 1 FIRE button (0=pressed)
            PCOLR0 = $2c0             ; Color/Brightness of the first Player/Missile
            PCOLR1 = $2c1             ; Color/Brightness of the second Player/Missile
            HPOSP0 = $d000            ; Horizontal position of the first Player (write)
            HPOSP1 = $d001            ; Horizontal position of the second Player (write)
            P0PF   = $d004            ; Collision detection of the first Player
            COLPF0 = $d016            ; Color/Brightness of Playfield 0
            COLBK  = $d01a            ; Color/Brightness of Background
            GRACTL = $d01d            ; P/M graphics configuration
            HITCLR = $d01e            ; A write to this register clears P/M collision detection registers
            AUDF1  = $d200            ; Frequency register (Audio Channel 1) 
            AUDC1  = $d201            ; Control register (Audio Channel 1)
            AUDF2  = $d202            ; Frequency register (Audio Channel 2)
            AUDC2  = $d203            ; Control register (Audio Channel 2)
            AUDCTL = $d208            ; Audio Control
            RANDOM = $d20a            ; Random number generator
            PMBASE = $d407            ; A pointer to the memory used for P/M graphics (write)
            NMIEN  = $d40e            ; Non-Maskable Interrupt (NMI) Enable
            WSYNC  = $d40a            ; Wait For Horizontal Sync 
                                      ; A write to this register halts the 6502 program 
                                      ; through the end of the current scanline
            PMBASEADR = $3000         ; P/M memory address
            PMDATA1 = PMBASEADR+$200  ; First player P/M data address
            PMDATA2 = PMBASEADR+$280  ; Second player P/M data address
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Player size (in bytes)
            STARTPOSH = 60            ; Initial spaceship horizontal position
            STARTPOSV = 56            ; Initial spaceship vertical position
            ANTICMODE = $57+$80       ; Default ANTIC-a mode for playfield lines
            WIDTH = 32                ; Width of the virtual screen (in characters)
            BGCOL = 12                ; Number of lines to be colored in DLI
            POSV = $80                ; Spaceship vertical position (of the top pixels)
            POSH = $81                ; Spaceship horizontal position (of the most left pixels)
            MVSRCE = $84              ; Source address (2 bytes) for the copy procedure 
            MVDEST = $86              ; Destination address (2 bytes) for the copy procedure
            LENPTR = $88              ; Length of data to be copied (in bytes)
            BGCOUNTER = $89           ; Background color counter
            TIMER  = $8f              ; Variable for synchronization of the main loop with VBI  

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

            org $C5
            
PMSHAPE1    .byte %00000000 ; Spaceship graphic for the first player   
            .byte %11100000 ; Data will be copied from here to the P/M memory
            .byte %11000000
            .byte %01110000
            .byte %00101100
            .byte %00111110
            .byte %00000001
            .byte %00111110
            .byte %00101100
            .byte %01110000
            .byte %11000000
            .byte %11100000
;           .byte %00000000
;The last byte of the graphic for the first player and the first byte for the second are identical
;We save one byte by taking the overlap into account (PMSHAPESIZE is increased by 1)

PMSHAPE2    .byte %00000000
            .byte %00110000
            .byte %00000000
            .byte %00000000
            .byte %00110000
PROPULSION  .byte %10111100
            .byte %01111111
            .byte %10111100
            .byte %00110000
            .byte %00000000
            .byte %00000000
MSHAPE      .byte %00110000 ; MSHAPE points to a missile graphic (1 byte) 
;           .byte %00000000 ; borrowed from the second player graphic
;We share 1 byte between PMSHAPE2 (last byte) and TABLE (first byte)

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

checktrig   lda STRIG0           ; wait for a FIRE with starting the game
            bne restart
            sta ATRACT           ; write 0 to postpone the screen saver activation
            sta AUDC1            ; switch off the sound (channel 1) 
            sta AUDC2            ; switch off the sound (channel 2)
            tax                  ; keep 0 value in X for later

waitrelease lda STRIG0
            beq waitrelease      ; is FIRE still pressed? 

            lda #3
            sta PCOLR1           ; set the color of the second player (dark gray)
            sta GRACTL           ; switch on P/M
            lda #8
            sta PCOLR0           ; set the color of the first player (light gray)
            asl                  ;  8 x 2 = 16 (0x10)
            asl                  ; 16 x 2 = 32 (0x20)
            sta GPRIOR           ; enable mixing colors for the players
            lda #>PMBASEADR      ; MSB of PMBASEADR  
            sta PMBASE           ; set as a starting address for the P/M memory

            lda LENPTR           ; if LENPTR was not yet used (is equal 0)
            beq playerinit       ; then jump over memory cleanup

            txa                  ; take 0 from X
wipe        sta line2,x          ; clean screen and P/M memory
            sta line2+256,x
            sta PMDATA1,x
            dex
            bne wipe
            
playerinit  sta HITCLR           ; clear P/M collision detection registers
            lda #STARTPOSV       ; set starting spaceship position
            sta POSV
            lda #STARTPOSH
            sta POSH

main        lda P0PF            ; was there a first player collision?
            beq prepmove        ; if not, let's continue the game

gameover    lda #$8f            ; if yes, game over
            sta AUDC1           ; configure audio channel 1
            sta RTCLOK          ; set RTCLOK counter
            
waitsound   lda RTCLOK          ; play the sound of the spaceship beeing damaged
            sta AUDF1           ; for about 2 seconds (255-143=112 frames)
            sta PCOLR0          ; and keep changing the color of the first player (blinking)
            bne waitsound       ; until RTCLOK reaches 0
            sta AUDC1           ; then switch of the sound (channel 1)

            jmp restart
                
prepmove    lda #<PMSHAPE1      ; load LSB of the player 1 graphic location
            sta MVSRCE          ; set LSB of the SOURCE address
            
            lda POSH            ; load current horizontal position of the spaceship
            sta HPOSP0          ; write it to horizontal position register for player 1
            sta HPOSP1          ; write it to horizontal position register for player 2
            
            lda #<PMDATA1       ; load LSB of the player 1 P/M memory
            clc
            adc POSV            ; add current vertical position to it
            sta MVDEST          ; set LSB of the DESTINATION address
            lda #>PMDATA1       ; load MSB of the player 1 P/M memory
            sta MVDEST+1        ; set MSB of the DESTINATION address
            lda #PMSHAPESIZE    ; how many bytes?
            sta LENPTR
            jsr move            ; call "move" to copy LENPTR bytes from MVSRCE to MVDEST

            lda #<PMSHAPE2      ; load LSB of the player 2 graphic location
            sta MVSRCE          ; set LSB of the SOURCE address
            
            lda #<PMDATA2       ; load LSB of the player 2 P/M memory
            clc
            adc POSV            ; add current vertical position to it
            sta MVDEST          ; set LSB of the DESTINATION address
            lda #PMSHAPESIZE    ; how many bytes?
            sta LENPTR
            jsr move            ; call "move" to copy LENPTR bytes from MVSRCE to MVDEST
            
            lda TIMER           ; load TIMER value
wait        cmp TIMER           ; has it changed?
            beq wait            ; if not, continue checking

checkmove
vertical    ldx POSV            ; load current vertical spaceship position
            stx AUDF1           ; it has influence on the sound frequency
            lda #$83            ; and playing with AUDC1 register we can get
            sta AUDC1           ; distorted sound similar to a spaceship
up          lda STICK0          ; load joystick position
            tay                 ; store it in Y
            and #%00000001      ; up? (is bit 0 of the STICK0 register equal 0?)
            bne down            ; otherwise check if down
            cpx #32             ; if we reached the upper limit (31=$1F) 
            bcc horizontal      ; then we check the horizontal move
            dec POSV            ; if not, move the spaceship up
down        tya                 ; load joystick position from Y
            and #%00000010      ; down? (is bit 1 of the STICK0 register equal 0?)
            bne horizontal      ; otherwise check the horizontal move
            cpx #84             ; if we reached the lower limit (84=$54)
            bcs horizontal      ; then we check the horizontal move
            inc POSV            ; if not, move the spaceship down
horizontal  ldx POSH            ; load current horizontal spaceship position
left        tya                 ; load joystick position from Y
            and #%00000100      ; to the left? (is bit 2 of the STICK0 register equal 0?)
            bne right           ; otherwise check if to the right
            cpx #45             ; if we reached the left side (44=$2C)
            bcc endmove         ; then we are done with joystick check
            dec POSH            ; if not, move the spaceship to the left 
right       tya                 ; load joystick position from Y
            and #%00001000      ; to the right? (is bit 3 of the STICK0 register equal 0?)
            bne endmove         ; otherwise we are done with joystick check
            cpx #200            ; if we reached the right side (200=$C8)
            bcs endmove         ; then we are done with joystick check
            inc POSH            ; if not, move the spaceship to the right
endmove

            jmp main            ; main loop starts at main label 

move        ldy #0              ; procedure to copy LENPTR bytes from MVSRCE to MVDEST
            sty MVSRCE+1        ; data to be copied are stored on the zero page
            ldx LENPTR          ; we copy up to 255 bytes
mvlast      lda (MVSRCE),y      ; from MVSRCE
            sta (MVDEST),y      ; to MVDEST
            iny
            dex                 ; X register in a loop counter
            bne mvlast
mvexit      rts

            org $229D
            
VBI         lda #BGCOL          ; reset background color counter for DLI
            sta BGCOUNTER

            lda TIMER           ; TIMER variable toggles between 0 and 3
            eor #%00000011      ; every ~ 1/50 second
            sta TIMER

            ldx #2              ; Animation of the spaceship propulsion  
animate     lda PROPULSION,x    ; modify 3 bytes in the middle of the player 2
            eor #%11000000      ; by inverting 2 oldest bits (2 pixels on the left) 
            sta PROPULSION,x
            dex
            bpl animate         ; loop is executed 3 times

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
