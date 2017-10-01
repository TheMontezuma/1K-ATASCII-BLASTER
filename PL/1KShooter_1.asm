
            run start

            SDMCTL = $22f             ; Kontrola dostępu do pamięci DMA
            SDLSTL = $230             ; Wskaźnik pierwszego rozkazu Display List
            ANTICMODE = $57+$80       ; Domyślny tryb ANTIC-a
            WIDTH = 32                ; Szerokość wirtualnego ekranu (w znakach)

            org $95

DLIST       .byte $70,$70,$70         ; 3x8=24 puste linie
            .byte $70+$80             ; 8 pustych linii + DLI
            .byte ANTICMODE-$10       ; wiersz trybu 7 + DLI + LMS
            .word line1               ; adres danych do wyświetlenia
            .byte $70+$80             ; 8 pustych linii + DLI
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
LMS1        .word line2               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line3               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line4               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line5               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line6               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line7               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line8               ; adres danych do wyświetlenia
            .byte ANTICMODE           ; wiersz trybu 7 + DLI + LMS + przewijanie w poziomie
            .word line9               ; adres danych do wyświetlenia
            .byte $70+$80             ; 8 pustych linii + DLI
            .byte ANTICMODE-$10       ; wiersz trybu 7 + DLI + LMS
            .word line10              ; adres danych do wyświetlenia
            .byte $41                 ; czekaj na VBI i skocz
            .word DLIST               ; na początek DL

            org $2000
                
start       lda #%00101011       ; ‭aktywne DMA dla DL i P/M + 2 liniowe P/M +‬ szeroki ekran
            sta SDMCTL

            lda #<DLIST          ; zainstaluj DL
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
