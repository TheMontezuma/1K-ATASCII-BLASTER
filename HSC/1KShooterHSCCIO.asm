DataMatrix_code equ $2800
DataMatrix_data equ $2A00
DataMatrix_SIZE equ 24
            icl 'datamatrix.asx'

; 512 ($200) bytes DataMatrix_code size
; URL length = 32 bytes -> DataMatrix_SIZE = 24
; DataMatrix_data size = 832 ($340) bytes = 256+24*24 

; symbolic names for CIO
            IOCB   equ $0340
            ICCHID equ IOCB+0
            ICCMD  equ IOCB+2
            ICBAL  equ IOCB+4
            ICBAH  equ IOCB+5
            ICBLL  equ IOCB+8
            ICBLH  equ IOCB+9
            ICAX1  equ IOCB+10
            ICAX2  equ IOCB+11
            CIOV   equ $E456

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
            PCOLR2 = $2c2             ; Color/Brightness of the third Player/Missile
            CHBAS  = $2f4             ; Character set address (MSB)
            HPOSP0 = $d000            ; Horizontal position of the first Player (write)
            HPOSP1 = $d001            ; Horizontal position of the second Player (write)
            P0PF   = $d004            ; Collision detection of the first Player
            HPOSM2 = $d006            ; Horizontal position of the third Missile (write)
            M2PF   = $d002            ; Collision detection of the third Missile
            SIZEM  = $d00c            ; Missile width (write)
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
            HSCROL = $d404            ; Distance of the horizontal fine scrolling shift (write)
            PMBASE = $d407            ; A pointer to the memory used for P/M graphics (write)
            NMIEN  = $d40e            ; Non-Maskable Interrupt (NMI) Enable
            WSYNC  = $d40a            ; Wait For Horizontal Sync 
                                      ; A write to this register halts the 6502 
                                      ; until the end of the current scanline
            PMBASEADR = $3000         ; P/M memory address
            MDATA   = PMBASEADR+$180  ; Missile P/M data address
            PMDATA1 = PMBASEADR+$200  ; First player P/M data address
            PMDATA2 = PMBASEADR+$280  ; Second player P/M data address
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Player size (in bytes)
            STARTPOSH = 60            ; Initial spaceship horizontal position
            STARTPOSV = 56            ; Initial spaceship vertical position
            ANTICMODE = $57+$80       ; Default ANTIC-a mode for playfield lines
            WIDTH = 32                ; Width of the virtual screen (in characters)
            BGCOL = 12                ; Number of lines to be colored in DLI
            LINES = 8                 ; Number of lines in DL, which are involved in scrolling
            CLOCKS = 8                ; Pixel count for fine scrolling
            POSV = $80                ; Spaceship vertical position (of the top pixels)
            POSH = $81                ; Spaceship horizontal position (of the most left pixels)
            M2POSV = $82              ; Missile vertical position
            M2POSH = $83              ; Missile horizontal position
            MVSRCE = $84              ; Source address (2 bytes) for the copy procedure 
            MVDEST = $86              ; Destination address (2 bytes) for the copy procedure
            LENPTR = $88              ; Length of data to be copied (in bytes)
            BGCOUNTER = $89           ; Background color counter
            CHRADR = $8a              ; Pointer to characters (2 bytes)
            LMSV   = $8c              ; Pointer to the screen memory (2 bytes)
            SPEED  = $8e              ; Scrolling speed
            TIMER  = $8f              ; Variable for synchronization of the main loop with VBI  
            SHOTSPEED = $90           ; Missile speed (in pixels per frame)

            org $91
VBIFLAG     .byte 1                   ; Controls scrolling in VBI (0=allowed)
SHOTFIRED   .byte 0                   ; missile was fired (flag)
SCROLLPOS   .byte 0                   ; Horizontal fine scrolling position (in pixels)
SCROLLCOUNT .byte 0                   ; Coarse scrolled characters counter

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

GAMEOVERTXT .byte "GAME OVER"

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

HIGHTXT     .byte "HIGH"
SCORETXT    .byte "SCORE:0000"

            org $2000
                
start       jsr game_init

restart     lda RTCLOK
            cmp #25
            bne checkspace       ; has 0,5 seconds passed?
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

checkspace  jsr space
            bne checktrig        ; space key was not pressed
            lda line10+18
            beq checktrig        ; no high score

            lda #0
            sta ATRACT           ; write 0 to postpone the screen saver activation
            sta AUDC1            ; switch off the sound (channel 1) 
            sta AUDC2            ; switch off the sound (channel 2)
            jsr hsc              ; submit hi score

checktrig   lda STRIG0           ; wait for a FIRE with starting the game
            bne restart
            sta ATRACT           ; write 0 to postpone the screen saver activation
            sta AUDC1            ; switch off the sound (channel 1) 
            sta AUDC2            ; switch off the sound (channel 2)
            tax                  ; keep 0 value in X for later

waitrelease lda STRIG0
            beq waitrelease      ; is FIRE still pressed? 
            sta SPEED            ; initial scrolling speed (1=slow) 

            lda #3
            sta PCOLR1           ; set the color of the second player (dark gray)
            sta GRACTL           ; switch on P/M

            sta SHOTSPEED        ; set missile speed
            lda #8
            sta PCOLR0           ; set the color of the first player (light gray)
            asl                  ;  8 x 2 = 16 (0x10)
            sta SIZEM            ; set missile width (double width)
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

            ldy #9
resetscore  lda SCORETXT,y       ; copy string "SCORE:0000"
            sta line10+2,y       ; to the status line
            dey
            bpl resetscore

main        lda P0PF            ; was there a collision of the first player?
            sta VBIFLAG         ; 0 = scrolling allowed
            beq highscore       ; if not, let's continue the game

gameover    lda #0              ; if yes, game over
            sta AUDC2           ; switch off missile sound
            lda #214            ; move missile outside visible area
            sta HPOSM2          ; write 214 to the missile horizontal position register
            sta M2POSH          ; and update variable storing missile horizontal position
            lda #$8f
            sta AUDC1           ; configure audio channel 1
            sta RTCLOK          ; set RTCLOK counter
            
waitsound   lda RTCLOK          ; play the sound of the spaceship beeing damaged
            sta AUDF1           ; for about 2 seconds (255-143=112 frames)
            sta PCOLR0          ; and keep changing the color of the first player (blinking)
            bne waitsound       ; until RTCLOK reaches 0
            sta AUDC1           ; then switch of the sound (channel 1)

            lda #214            ; move players outside visible area
            sta HPOSP0
            sta HPOSP1

            ldy #9
textend     lda GAMEOVERTXT,y   ; copy string "GAME OVER"
            sta line10+2,y      ; to the status line
            dey
            bpl textend

            lda #$ff             ; clear the last pressed key
            sta $2fc

            jmp restart
                
highscore   tay                 ; A=0, because there was no collision (P0PF)
checkhigh   lda line10+8,y      ; load the next score digit (starting from a thousands digit)
            cmp line10+18,y     ; and compare it with the corresponding digit of a Hi-Score
            bcc prepmove        ; we are done if current score digit is smaller
            bne sethigh         ; if current score digit is greater, we have a Hi-Score
            iny                 ; otherwise digits must have been equal
            cpy #2              ; and we continue with checking next digits (hundreads and tens)
            bne checkhigh
sethigh     ldy #4              ; if Hi-Score <= Score
copyscore   lda line10+7,y      ; copy the current score
            sta line10+17,y     ; together with the preceding character ":" into Hi-Score
            dey                 ; for example ":1710"
            bpl copyscore
            ldy #3
hightext    lda HIGHTXT,y
            sta line10+13,y     ; copy string "HIGH"
            dey                 ; to the status line
            bpl hightext

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
            
movem       lda SHOTFIRED       ; has missile been fired?
            beq noshot

            lda #<MDATA         ; if yes, load the LSB of the missile P/M data address
            clc
            adc M2POSV          ; add the vertical missile position to it
            sta MVDEST          ; store the result in MVDEST
            lda #>MDATA         ; load MSB of the missile P/M data address
            sta MVDEST+1        ; store it in MVDEST+1
            ldy #00
            lda MSHAPE          ; copy missile data (1 byte)
            sta (MVDEST),y      ; to MDATA+M2POSV

            lda M2POSH          ; load current horizontal position of the missile
            sta HPOSM2          ; write it to the corresponding hardware register
            sta PCOLR2          ; a missile changes its color while moving across the screen
            sbc POSH            ; subtract the spaceship horizontal position from it
            sta AUDF2           ; the greater the distance from spaceship
            lda #$6a            ; the lower is missile sound frequency
            sta AUDC2           ; set the sound distortion to simulate a missile sound
noshot

            lda TIMER           ; load TIMER value
wait        cmp TIMER           ; has it changed?
            beq wait            ; if not, continue checking

            lda STRIG0          ; is FIRE pressed?
            bne checkmove
            jsr shot            ; if yes, then shoot
checkmove
vertical    ldx POSV            ; load current vertical spaceship position
            stx AUDF1           ; it has influence on the sound frequency
            lda #$83            ; by playing with AUDC1 register we can get
            sta AUDC1           ; distorted sound similar to a spaceship sound
up          lda STICK0          ; load joystick position
            tay                 ; store it in Y
            and #%00000001      ; up? (is bit 0 of the STICK0 register equal 0?)
            bne down            ; otherwise check if down
            cpx #32             ; if we reached the upper limit (31=$1F) 
            bcc horizontal      ; then check the horizontal move
            dec POSV            ; if not, move the spaceship up
down        tya                 ; load joystick position from Y
            and #%00000010      ; down? (is bit 1 of the STICK0 register equal 0?)
            bne horizontal      ; otherwise check the horizontal move
            cpx #84             ; if we reached the lower limit (84=$54)
            bcs horizontal      ; then check the horizontal move
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

            lda SCROLLCOUNT     ; load the coarse scrolled characters counter
            cmp #8              ; have 8 characters already been scrolled?
            bne checkshot       ; if not, continue from checkshot label

            lda #0              ; prepare screen memory
            sta SCROLLCOUNT     ; reset the coarse scrolled characters counter
            lda CHBAS           ; load MSB of the character set
            clc
            adc #2              ; add 2 to it (character set uses 4 pages)
            sta CHRADR+1        ; store result in MSB of a pointer to characters
            lda RANDOM          ; load random value (from 0 to 255)
            and #%11111000      ; make sure that it is divisible by 8
                                ; (is a valid address of a character from the third page)
            sta CHRADR          ; store result in LSB of a pointer to characters
                        
            lda LMS1            ; load LSB of the first line's address
            clc
            adc #24             ; add 24 to it (number of characters in a line)
            sta LMSV            ; and store it in LMSV
            lda LMS1+1          ; load MSB of the first line's address
            adc #0              ; add 0 to it (considering carryover)
            sta LMSV+1          ; and store it in LMSV+1

            ldy #0              ; reset Y register

nextbyte    ldx #8              ; store 8 in X (a bit counter for a character's row)
            lda (CHRADR),y      ; load next byte (row) of a character definition

nextbit     asl                 ; shift pixels to the left (bit 7 -> Carry)
            pha                 ; push A to the stack
            bcc setblank
            lda #"O"            ; if Carry bit is set
            bcs checkbit        ; load internal code of "0" and jump to checkbit
setblank    lda #" "            ; otherwise load internal code of " "
checkbit    sta (LMSV),y        ; store "0" or " " at LMSV+Y
            inc LMSV            ; increment pointer LMSV
            bne singlebyte2
            inc LMSV+1          ; consider carryover
singlebyte2 pla                 ; recover A
            dex                 ; decrement X
            bne nextbit         ; is it the last bit (in the current row)?

            lda LMSV            ; load LSB of LMSV pointer
            clc                 ; move LMSV to the end of the next line
            adc #WIDTH*2-9      ; and compensate growing value of the Y register (-1 byte)
            bcc singlebyte      ; consider carryover
            inc LMSV+1
singlebyte  sta LMSV

            iny                 ; next byte (row) of the character definition
            cpy #8              ; is it the last row?
            bne nextbyte        ; if not, jump to nextbyte

checkshot   lda SHOTFIRED       ; has missile been fired?
            bne delchar
            jmp endofmain       ; if not, jump to the end of the main loop

delchar     lda M2PF            ; a missile is on its way, check missile collision
            beq nocoll

            lda M2POSH          ; missile hit something, load missile horizontal position
            sec
            sbc #30             ; subtract an offset ($1E)
            sbc SCROLLPOS       ; subtract the number of fine scrolled pixels
            lsr                 ; and devide it by 8 (2*2*2)
            lsr
            lsr                 ; result is a horizontal position of the character to be deleted
            tay                 ; store it in Y register

            lda M2POSV          ; load missile vertical position
            sec
            sbc #31             ; subtract an offset ($1F)
            lsr                 ; and devide it by 8 (2*2*2)
            lsr
            lsr                 ; result is a vertical position of the character to be deleted
            tax                 ; store it in X register
            
            lda LMS1            ; load LSB of the address of the first playfield line
            sta LMSV            ; and store it in LMSV
            lda LMS1+1          ; load MSB of the address of the first playfield line
            sta LMSV+1          ; and store it in LMSV+1
            cpx #0              ; if the character to be deleted is in the first line
            beq clearchar       ; then we are ready
nextline    lda LMSV            ; otherwise we move the LMSV pointer
            clc                 ; to the beginning of the line
            adc #WIDTH*2        ; where the character is located
            bcc onebyte
            inc LMSV+1          ; carryover
onebyte     sta LMSV
            dex
            bne nextline        ; there is 0 in the X register at the end of the loop
            
clearchar   lda #" "            ; load the internal code of the space character (0)
            sta (LMSV),y        ; and store it at the position of the character to be deleted

            ldy #2              ; add 10 points for every shot character
scoreloop   lda line10+8,y      ; we are manipulating directly the screen memory
            clc                 ; there is a tens digit under address line10+8+2
            adc #1              ; we add 1 to its code and check carryover
            cmp #":"            ; is this the code of the ":" character? (next after "9") 
            bne writescore
            lda #"0"            ; carrover, so write "0"
            sta line10+8,y      ; at the ":" location
            dey                 ; and go to a more significant digit of the game score
            bpl scoreloop       ; add 1 to its code (in the next iteration of the scoreloop)
writescore  sta line10+8,y      ; write incremented digit on the current position
            cpy #0              ; if it is a thousands digit
            bne resmissile
            cmp #"1"            ; then check if the change was from "0" to "1"
            bne resmissile
            stx SPEED           ; if yes, increase scrolling speed (X=0)
            inc SHOTSPEED       ; and accelerate the missile

resmissile  lda #211            ; move missile outside visible area
            sta M2POSH          ; update variable storing horizontal missile position
            sta HITCLR          ; clear P/M collision detection registers

nocoll      lda M2POSH          ; load horizontal missile position
            clc
            adc SHOTSPEED       ; add missile speed to it
            sta M2POSH          ; update variable storing horizontal missile position
            cmp #212            ; has missile reached the right side of the screen?
            bcc endofmain       ; if not yet, jump to the end of the main loop
            lda #0              ; 
            sta AUDC2           ; otherwise switch off the missile sound
            sta SHOTFIRED       ; reset SHOTFIRED flag (0=no missile fired)
            ldy #$80            ; clear missile P/M memory (128 bytes)
clearm      sta MDATA,y
            dey
            bne clearm

endofmain
            jmp main            ; main loop starts at main label 

shot        lda SHOTFIRED       ; check if missile is on its way
            cmp #1
            bne contshot
            rts                 ; if yes, return
contshot    inc SHOTFIRED       ; otherwise set SHOTFIRED flag (1=missile fired)
            lda POSV            ; load vertical spaceship position
            clc
            adc #6              ; add 6 to it (a cannon is located in the middle of the spaceship)
            sta M2POSV          ; store calculated vertical missile position
            lda POSH            ; load horizontal spaceship position
            sta M2POSH          ; and store it as a horizontal missile position
            rts

move        ldy #0              ; procedure to copy LENPTR bytes from MVSRCE to MVDEST
            sty MVSRCE+1        ; data to be copied are stored on the zero page
            ldx LENPTR          ; we copy up to 255 bytes
mvlast      lda (MVSRCE),y      ; from MVSRCE
            sta (MVDEST),y      ; to MVDEST
            iny
            dex                 ; X register in a loop counter
            bne mvlast
mvexit      rts
            
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

            lda VBIFLAG         ; is scrolling allowed?
            bne exitvbi         ; if not, exit VBI

            lda SCROLLPOS       ; load current horizontal fine scrolling position
            sta HSCROL          ; write it to the hardware register
            lda TIMER           ; load TIMER variable (which toggles between 0 and 3)
            and SPEED           ; execute AND operation with SPEED
            bne exitvbi         ; exit every second VBI when SPEED=1 (slow)
            dec SCROLLPOS       ; decrement horizontal fine scrolling position
            bpl exitvbi         ; if value is positive or 0, exit VBI

setmove     lda LMS1            ; load LSB of the first line's address
            cmp <line2+WIDTH    ; compare it with LSB of a character located
                                ; just after the first line's screen memory
            bne coarsescrol     ; if they are different, continue with coarse scrolling

; LMS1=LMSC means that we have already scrolled the whole line
; and it is time for every line in DL to restore its LMS' operand (subtract WIDTH)
; and copy current screen memory to the new address

            ldx #(LINES-1)*3    ; load 21 to X (21=(line count-1)*3 bytes per line)

rollover    lda LMS1+1,x        ; load MSB of the X/3 line's address
            sta MVSRCE+1        ; store it in MVSRCE+1
            lda LMS1,x          ; load LSB of the X/3 line's address
            sta MVSRCE          ; store it in MVSRCE
            sec
            sbc #WIDTH          ; subtract WIDTH (of the virtual screen)
            bcs byteonly        ; consider carryover
            dec LMS1+1,x
byteonly    sta LMS1,x          ; store result in LMS's operand of the X/3 line
            sta MVDEST          ; and in MVDEST variable
            lda LMS1+1,x
            sta MVDEST+1

            ldy #WIDTH-1        ; load WITDH-1 to Y (loop counter) 
mirror      lda (MVSRCE),y      ; copy screen memory data
            sta (MVDEST),y      ; 32 bytes backward
            dey
            bpl mirror

            dex                 ; Playfield line definition contains 3 bytes:
            dex                 ; ANTIC command with LMS (1 byte) + 2 bytes operand
            dex                 ; when decreasing X by 3, we go one line above
            bpl rollover        ; if X is positive or 0, we modify next line

coarsescrol inc SCROLLCOUNT     ; coarse scrolling, we manipulate DL !!!
            ldx #(LINES-1)*3    ; load 21 to X (21=(line count-1)*3 bytes per line)
                                ; for every of 8 lines (starting from the bottom)
nextcs      inc LMS1,x          ; increment LSB of LMS
            bne done            ; screen memory for a given line
            inc LMS1+1,x        ; consider carryover
done        dex                 ; Playfield line definition contains 3 bytes:
            dex                 ; ANTIC command with LMS (1 byte) + 2 bytes operand
            dex                 ; when decreasing X by 3, we go one line above
            bpl nextcs          ; if X is positive or 0, we modify next line

            lda #CLOCKS         ; load color clocks (pixels) to be fine scrolled (8)
            sta SCROLLPOS       ; store it as a horizontal fine scrolling position
            sta HSCROL          ; and write it to the hardware register
            dec SCROLLPOS       ; decrement horizontal fine scrolling position

exitvbi     jmp $e45f           ; SYSVBV

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

game_init   lda #%00101011       ; ‭DMA active for DL and P/M
            sta SDMCTL           ; + P/M double line resolution +‬ wide screen

            lda #<DLIST          ; install DL
            sta SDLSTL
            lda #>DLIST          ; MSB of the DLIST address is equal 0
            sta SDLSTL+1
            sta AUDCTL           ; configure Audio Control register
            sta RTCLOK           ; reset RTCLOK counter
            sta $2c8             ; black border
            
            lda #<DLI            ; install DLI routine
            sta VDSLST
            lda #>DLI
            sta VDSLST+1
            lda #$C0             ; enable VBI+DLI
            sta NMIEN
            
            ldy #<VBI            ; install VBI routine
            ldx #>VBI
            lda #6               ; immediate
            jsr $e45c            ; SETVBV
            rts

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

            org line8+7
            .byte "PRESS SPACE"

line9 = line8+WIDTH*2

            org line9+2
            .byte "TO SUBMIT YOUR SCORE"

line10 = line9+WIDTH*2

    org line10+24
    
url
    .byte 'http://atari.pl/hsc/?x=106000000'
url_len equ *-url

browser_device
    .byte 'B:'

yourRecord
    dta d'YOUR BEST SCORE:     '

urlScreen equ DataMatrix_data

; Display List for DataMatrix
urlDL
    dta $70,$70,$46,a(yourRecord),$70,$48,a(urlScreen)
:23 dta 8
    dta $41,a(urlDL)

space ; SPACE key preseed?
    ldx #$ff
    lda $2fc
    and #$3f
    cmp #$21
    sne:stx $2fc
    rts

hsc
    ; copy best score to DataMatrix_data
    ldx #url_len-1
    mva:rpl url,x DataMatrix_data,x-
    ldx #3
urlRecord
    mva line10+18,x yourRecord+16,x
    sne:lda #'0'
    ora #' '
    sta DataMatrix_data+url_len-4,x
    sta url+url_len-4,x
    dex
    bpl urlRecord
    mva #DataMatrix_EOF DataMatrix_data+url_len

    jsr DataMatrix_code  ; calculate DataMatrix

; setup screen for DataMatrix
    lda #$c
    sta $2c6
    sta $2c8
    lda #0  
    sta $2c4
    sta $2c5
    lda #%00101010
    sta SDMCTL
    lda #$40
    sta NMIEN
    lda #<urlDL
    sta SDLSTL
    lda #>urlDL
    sta SDLSTL+1

; display DataMatrix
    mwa #DataMatrix_symbol  urlGfxSrc
    ldx #0
urlGfxLine
    jsr urlClr
    ldy #6
urlGfxByte
    lda #1
urlGfxPixel
    asl @
    lsr DataMatrix_symbol
urlGfxSrc   equ *-2
    inw urlGfxSrc
    rol @
    bcc urlGfxPixel
    sta urlScreen,x+
    dey
    bne urlGfxByte
    jsr urlClr
    cpx #240
    bcc urlGfxLine

    jsr write2Bdevice    ; submit HSC via CIO

    jsr:rne space ; wait for SPACE key pressed
    jmp game_init ; game_init ends with RTS, so let's jump there

putchar
    mvx #11 $342
    mwx #0  $348
    jmp $e456
    
urlClr
    lda #0
:2  sta urlScreen,x+
    rts

write2Bdevice
    JSR lookup
    BPL do_cio
    RTS

do_cio
    LDA #$03 ; open
    STA ICCMD,X
    LDA #<browser_device
    STA ICBAL,X
    LDA #>browser_device
    STA ICBAH,X
    LDA #$00
    STA ICBLH,X
    LDA #$02
    STA ICBLL,X
    LDA #$08
    STA ICAX1,X
    LDA #$00
    STA ICAX2,X
    JSR CIOV
    
    LDA #$09 ; write
    STA ICCMD,X
    LDA #<url
    STA ICBAL,X
    LDA #>url
    STA ICBAH,X
    LDA #$00
    STA ICBLH,X
    LDA #url_len
    STA ICBLL,X
    JSR CIOV
    
    LDA #$0C ; close
    STA ICCMD,X
    JMP CIOV

LOOKUP  LDX #$00 ; search for a free CIO channel
        LDY #$01
LOOP    LDA ICCHID,X
        CMP #$FF
        BEQ FOUND
        TXA
        CLC
        ADC #$10
        TAX
        BPL LOOP
        LDY #-95 ; error code "TOO MANY CHANNELS OPEN"
FOUND   RTS      ; X contains the offset for a channel