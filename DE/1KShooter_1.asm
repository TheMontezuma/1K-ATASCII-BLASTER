
            run start

            SDMCTL = $22f             ; DMA-Speicherzugriffssteuerung
            SDLSTL = $230             ; Zeiger auf den ersten Display-List-Befehl
            ANTICMODE = $57+$80       ; Standard-ANTIC-Modus
            WIDTH = 32                ; Breite des virtuellen Bildschirms (in Zeichen)

            org $95

DLIST       .byte $70,$70,$70         ; 3x8=24 leere Zeilen
            .byte $70+$80             ; 8 leere Zeilen + DLI
            .byte ANTICMODE-$10       ; Modus-7-Zeile + DLI + LMS
            .word line1               ; Datenadresse zur Anzeige
            .byte $70+$80             ; 8 leere Zeilen + DLI
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
LMS1        .word line2               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line3               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line4               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line5               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line6               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line7               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line8               ; Datenadresse zur Anzeige
            .byte ANTICMODE           ; Modus-7-Zeile + DLI + LMS + horizontales Scrollen
            .word line9               ; Datenadresse zur Anzeige
            .byte $70+$80             ; 8 leere Zeilen + DLI
            .byte ANTICMODE-$10       ; Modus-7-Zeile + DLI + LMS
            .word line10              ; Datenadresse zur Anzeige
            .byte $41                 ; warte auf VBI und springe
            .word DLIST               ; zum Anfang der DL

            org $2000

start       lda #%00101011       ; ‭aktives DMA für DL und P/M + 2-Linien-P/M +‬ breiter Bildschirm
            sta SDMCTL

            lda #<DLIST          ; installiere DL
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
