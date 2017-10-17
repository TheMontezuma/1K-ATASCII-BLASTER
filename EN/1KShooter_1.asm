
            run start

            SDMCTL = $22f             ; DMA access control
            SDLSTL = $230             ; Display List address
            ANTICMODE = $57+$80       ; Default ANTIC-a mode for playfield lines
            WIDTH = 32                ; Width of the virtual screen (in characters)

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

            org $2000
                
start       lda #%00101011       ; ‭DMA active for DL and P/M 
            sta SDMCTL           ; + P/M double line resolution +‬ wide screen

            lda #<DLIST          ; install DL
            sta SDLSTL
            lda #>DLIST
            sta SDLSTL+1
            
            jmp *

            org $232F

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
