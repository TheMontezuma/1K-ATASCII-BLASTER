
            run start

            RTCLOK = $14              ; Systemowy licznik, zwiększany o 1 co 1/50 sekundy 
            VDSLST = $200             ; Wektor przerwania DLI
            SDMCTL = $22f             ; Kontrola dostępu do pamięci DMA
            SDLSTL = $230             ; Wskaźnik pierwszego rozkazu Display List
            COLPF0 = $d016            ; Kolor/jasność Playfield 0
            COLBK  = $d01a            ; Kolor/jasność tła
            AUDF1  = $d200            ; Częstotliwość pierwszego generatora dźwięku 
            AUDC1  = $d201            ; Konfiguracja pierwszego generatora dźwięku
            AUDF2  = $d202            ; Częstotliwość drugiego generatora dźwięku
            AUDC2  = $d203            ; Konfiguracja drugiego generatora dźwięku
            AUDCTL = $d208            ; Rejestr kontroli dźwięku
            RANDOM = $d20a            ; Generator liczb losowych
            NMIEN  = $d40e            ; Konfiguracja przerwań niemaskowalnych
            WSYNC  = $d40a            ; Czekaj na synchronizację poziomą 
                                      ; zapis do tego rejestru powoduje zatrzymanie 6502
            ANTICMODE = $57+$80       ; Domyślny tryb ANTIC-a
            WIDTH = 32                ; Szerokość wirtualnego ekranu (w znakach)
            BGCOL = 12                ; Liczba linii tła do pokolorowania w DLI
            BGCOUNTER = $89           ; Licznik kolorów tła

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

            org $DD
            
TABLE       .byte $00,$A0,$A2,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A2,$A0

SOUND       .byte $F3,$D9,$C1,$B6,$A2,$90

            org $2000
                
start       lda #%00101011       ; ‭aktywne DMA dla DL i P/M + 2 liniowe P/M +‬ szeroki ekran
            sta SDMCTL

            lda #<DLIST          ; zainstaluj DL
            sta SDLSTL
            lda #>DLIST          ; starszy bajt adresu DLIST jest równy 0
            sta SDLSTL+1
            sta AUDCTL           ; konfiguruj rejestr kontroli dźwięku
            sta RTCLOK           ; zeruj licznik RTCLOK
            
            lda #<DLI            ; zainstaluj DLI
            sta VDSLST
            lda #>DLI
            sta VDSLST+1
            lda #$C0             ; włącz VBI+DLI
            sta NMIEN
            
setVBI      ldy #<VBI            ; zainstaluj VBI
            ldx #>VBI
            lda #6               ; natychmiastowe VBI
            jsr $e45c            ; SETVBV

restart     lda RTCLOK
            cmp #25
            bne checktrig        ; czy mineło już 0,5 sekundy ?
nextvoice   lda #$a8             ; jeśli tak, to:
            sta AUDC1            ; skonfiguruj kanał 1
            sta AUDC2            ; i kanał 2
            lda RANDOM           ; załaduj losową wartość
            and #%00000011       ; z zakresu 0 - 3
            tax                  ; załaduj ją do X
            lda SOUND,x          ; pobierz wartość spod adresu SOUND+X
            lsr
            sta AUDF1            ; odegraj dźwięk na kanale 1
            lda SOUND+2,x        ; pobierz wartość spod adresu SOUND+2+X
            sta AUDF2            ; odegraj dźwięk na kanale 2
            lda #0
            sta RTCLOK           ; zeruj licznik RTCLOK

checktrig   jmp restart
            
            org $229D
            
VBI         lda #BGCOL          ; ustaw licznik kolorów dla DLI
            sta BGCOUNTER
exitvbi     jmp $e45f           ; SYSVBV

            org $230D

DLI         pha                 ; odłóż akumulator na stosie
            txa                 ; rejestr X do akumulatora 
            pha                 ; i na stos
            ldx BGCOUNTER       ; pobierz indeks
            lda TABLE,x         ; pobierz kolor/jasność z tablicy
            sta WSYNC           ; czekaj na synchronizację poziomą
            sta COLBK           ; zmień kolor tła
            ldx #7              ; zainicjalizuj licznik pętli
pfloop      lda TABLE+3,x       ; pobierz kolor/jasność z tablicy
            sbc #$7D            ; odejmij OFFSET
            sta WSYNC           ; czekaj na synchronizację poziomą
            sta COLPF0          ; zmień kolor
            dex                 ; zmniejsz licznik pętli
            bne pfloop          ; jeśli licznik jest różny od zera, wykonaj pętlę ponownie 
            dec BGCOUNTER       ; zmniejsz indeks
exitdli     pla                 ; pobierz ze stosu (do akumulatora) wartość rejestru X 
            tax                 ; odtwórz rejestr X
            pla                 ; pobierz ze stosu akumulator
            rti                 ; powrót z przerwania

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
