
            run start

            RTCLOK = $14              ; Systemowy licznik, zwiększany o 1 co 1/50 sekundy 
            ATRACT = $4d              ; Sterowanie wygaszaczem ekranu
            VDSLST = $200             ; Wektor przerwania DLI
            SDMCTL = $22f             ; Kontrola dostępu do pamięci DMA
            SDLSTL = $230             ; Wskaźnik pierwszego rozkazu Display List
            GPRIOR = $26f             ; Konfiguracja grafiki P/M (priorytety, itd.)
            STICK0 = $278             ; Położenie pierwszego joysticka
            STRIG0 = $284             ; Stan przycisku FIRE pierwszego joysticka (0-wciśnięty)
            PCOLR0 = $2c0             ; Kolor/jasność pierwszego gracza/pocisku
            PCOLR1 = $2c1             ; Kolor/jasność drugiego gracza/pocisku
            HPOSP0 = $d000            ; Pozycja pozioma pierwszego gracza (zapis)
            HPOSP1 = $d001            ; Pozycja pozioma drugiego gracza (zapis)
            P0PF   = $d004            ; Detekcja kolizji pierwszego gracza
            COLPF0 = $d016            ; Kolor/jasność Playfield 0
            COLBK  = $d01a            ; Kolor/jasność tła
            GRACTL = $d01d            ; Konfiguracja grafiki P/M
            HITCLR = $d01e            ; Zapis do tego rejestru czyści rejestry kolizji P/M
            AUDF1  = $d200            ; Częstotliwość pierwszego generatora dźwięku 
            AUDC1  = $d201            ; Konfiguracja pierwszego generatora dźwięku
            AUDF2  = $d202            ; Częstotliwość drugiego generatora dźwięku
            AUDC2  = $d203            ; Konfiguracja drugiego generatora dźwięku
            AUDCTL = $d208            ; Rejestr kontroli dźwięku
            RANDOM = $d20a            ; Generator liczb losowych
            PMBASE = $d407            ; Wskaźnik obszaru pamięci przeznaczonego dla grafiki P/M
            NMIEN  = $d40e            ; Konfiguracja przerwań niemaskowalnych
            WSYNC  = $d40a            ; Czekaj na synchronizację poziomą 
                                      ; zapis do tego rejestru powoduje zatrzymanie 6502
            PMBASEADR = $3000         ; Adres danych P/M
            PMDATA1 = PMBASEADR+$200  ; Adres danych pierwszego gracza
            PMDATA2 = PMBASEADR+$280  ; Adres danych drugiego gracza
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Rozmiar gracza (w bajtach)
            STARTPOSH = 60            ; Początkowa pozycja statku w poziomie
            STARTPOSV = 56            ; Początkowa pozycja statku w pionie
            ANTICMODE = $57+$80       ; Domyślny tryb ANTIC-a
            WIDTH = 32                ; Szerokość wirtualnego ekranu (w znakach)
            BGCOL = 12                ; Liczba linii tła do pokolorowania w DLI
            POSV = $80                ; Pozycja statku w pionie (górna krawędź)
            POSH = $81                ; Pozycja statku w poziomie (lewa krawędź)
            MVSRCE = $84              ; Adres źródłowy (2 bajty) dla procedury kopiującej dane 
            MVDEST = $86              ; Adres docelowy (2 bajty) dla procedury kopiującej dane
            LENPTR = $88              ; Długość bloku danych do skopiowania (w bajtach)
            BGCOUNTER = $89           ; Licznik kolorów tła
            TIMER  = $8f              ; Zmienna synchronizująca kod z przerwaniami VBI

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

            org $C5
            
PMSHAPE1    .byte %00000000 ; Grafika statku kosmicznego dla pierwszego gracza   
            .byte %11100000 ; Stąd dane kopiowane będą do obszaru pamięci P/M
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
;Ostatni bajt grafiki pierwszego gracza i pierwszy bajt grafiki drugiego gracza są identyczne 
;Uwzględniając nakładanie się ich na siebie (PMSHAPESIZE jest zwiększony o 1) oszczędzamy 1 bajt 

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
MSHAPE      .byte %00110000 ; MSHAPE to dane graficzne pocisku (1 bajt) 
;           .byte %00000000 ; zapożyczone z grafiki drugiego gracza
;Tutaj pamięć jest dzielona pomiędzy ostatni bajt PMSHAPE2 oraz pierwszy bajt TABLE

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

checktrig   lda STRIG0           ; czekaj z uruchomieniem gry na naciśnięcie przycisku FIRE
            bne restart
            sta ATRACT           ; wpisz 0, żeby opóźnić aktywację wygaszacza ekranu
            sta AUDC1            ; wyłącz dźwięk (kanał 1) 
            sta AUDC2            ; wyłącz dźwięk (kanał 2)
            tax                  ; odłóż wartość 0 na później

waitrelease lda STRIG0
            beq waitrelease      ; czy przycisk FIRE jest dalej wciśnięty? 

            lda #3
            sta PCOLR1           ; ustaw kolor drugiego gracza (ciemno szary)
            sta GRACTL           ; włącz P/M
            lda #8
            sta PCOLR0           ; ustaw kolor pierwszego gracza (jasno szary)
            asl                  ;  8 x 2 = 16 (0x10)
            asl                  ; 16 x 2 = 32 (0x20)
            sta GPRIOR           ; włącz mieszanie kolorów dla graczy
            lda #>PMBASEADR      ; starszy bajt adresu PMBASEADR 
            sta PMBASE           ; jako początek obszaru pamięci dla grafiki P/M

            lda LENPTR           ; jeśli LENPTR nie został jeszcze użyty, czyli ma wartość 0
            beq playerinit       ; to przeskocz czyszczenie pamięci

            txa                  ; sięgnij do rejestru X po odłożone tam wcześniej 0
wipe        sta line2,x          ; wyczyść pamięć obrazu oraz P/M
            sta line2+256,x
            sta PMDATA1,x
            dex
            bne wipe
            
playerinit  sta HITCLR           ; wyczyść rejestry kolizcji P/M
            lda #STARTPOSV       ; ustaw początkową pozycję statku kosmicznego
            sta POSV
            lda #STARTPOSH
            sta POSH

main        lda P0PF            ; czy nastąpiła kolizja pierwszego gracza?
            beq prepmove        ; jeśli nie, kontynuujemy grę

gameover    lda #$8f            ; a jeśli tak: game over
            sta AUDC1           ; ustaw zniekształcenie dźwięku
            sta RTCLOK          ; ustaw zegar
            
waitsound   lda RTCLOK          ; odtwarzaj dźwięk rozbijającego się statku kosmicznego
            sta AUDF1           ; przez około 2 sekund (255-143=112 odświeżeń ekranu)
            sta PCOLR0          ; i zmieniaj kolor pierwszego gracza (efekt migotania)
            bne waitsound       ; dopóki RTCLOK nie osiągnie wartości 0
            sta AUDC1           ; następnie wyłącz dźwięk

            jmp restart
                
prepmove    lda #<PMSHAPE1      ; pobierz młodszy bajt adresu grafiki pierwszego gracza
            sta MVSRCE          ; ustaw młodszy bajt adresu adresu źródłowego (skąd)
            lda POSH            ; załaduj aktualną pozycję poziomą statku kosmicznego
            sta HPOSP0          ; wpisz ją do rejestru pozycji poziomej gracza 1
            sta HPOSP1          ; wpisz ją do rejestru pozycji poziomej gracza 2
            lda #<PMDATA1       ; pobierz młodszy bajt adresu obszaru danych P/M gracza 1
            clc
            adc POSV            ; dodaj do niego pozycję w pionie
            sta MVDEST          ; ustaw młodszy bajt adresu docelowego (dokąd)
            lda #>PMDATA1       ; pobierz starszy bajt adresu obszaru danych P/M gracza 1
            sta MVDEST+1        ; ustaw starszy bajt adresu docelowego (dokąd)
            lda #PMSHAPESIZE    ; ile bajtów ?
            sta LENPTR
            jsr move            ; wywołaj procedurę kopiującą LENPTR bajtów z MVSRCE do MVDEST

            lda #<PMSHAPE2      ; pobierz młodszy bajt adresu grafiki drugiego gracza
            sta MVSRCE          ; ustaw młodzy bajt adresu adresu źródłowego (skąd)
            lda #<PMDATA2       ; pobierz młodszy bajt adresu obszaru danych P/M drugiego gracza
            clc
            adc POSV            ; dodaj do niego pozycję w pionie
            sta MVDEST          ; ustaw młodszy bajt adresu docelowego (dokąd)
            lda #PMSHAPESIZE    ; ile bajtów ?
            sta LENPTR
            jsr move            ; wywołaj procedurę kopiującą LENPTR bajtów z MVSRCE do MVDEST
            
            lda TIMER           ; pobierz wartość zmiennej TIMER
wait        cmp TIMER           ; czy się zmieniła ?
            beq wait            ; jeśli nie to czekaj dalej

checkmove
vertical    ldx POSV            ; załaduj aktualną pozycję pionową statku
            stx AUDF1           ; ma ona wpływ na częstotliwość dżwięku
            lda #$83            ; a eksperymentując z rejestrem AUDC1 można uzyskać
            sta AUDC1           ; zniekształcony dzwięk przypominający odgłos statku kosmicznego
up          lda STICK0          ; załaduj pozycję joysticka
            tay                 ; zachowaj ją w rejestrze Y
            and #%00000001      ; do góry? (czy skasowany jest bit 0 rejestru STICK0?)
            bne down            ; w przeciwnym wypadku sprawdzamy czy w dół
            cpx #32             ; jeśli osiągnęliśmy już górę (31=$1F) 
            bcc horizontal      ; to sprawdzamy wychylenie w poziomie
            dec POSV            ; a jeśli nie, podnosimy statek o jedną pozycję
down        tya                 ; odczytaj pozycję joysticka zachowaną w rejestrze Y
            and #%00000010      ; w dół? (czy skasowany jest bit 1 rejestru STICK0?)
            bne horizontal      ; w przeciwnym wypadku sprawdzamy wychylenie w poziomie
            cpx #84             ; jeśli osiągnęliśmy już dół (84=$54)
            bcs horizontal      ; to sprawdzamy wychylenie w poziomie
            inc POSV            ; a jeśli nie, obniżamy statek o jedną pozycję
horizontal  ldx POSH            ; załaduj aktualną pozycję poziomą statku
left        tya                 ; odczytaj pozycję joysticka zachowaną w rejestrze Y
            and #%00000100      ; w lewo? (czy skasowany jest bit 2 rejestru STICK0?)
            bne right           ; w przeciwnym wypadku sprawdzamy czy w prawo
            cpx #45             ; jeśli osiągnęliśmy już lewą stronę (44=$2C)
            bcc endmove         ; to kończymy sprawdzanie joysticka
            dec POSH            ; a jeśli nie, przesuwamy statek o jedną pozycję w lewo 
right       tya                 ; odczytaj pozycję joysticka zachowaną w rejestrze Y
            and #%00001000      ; w prawo? (czy skasowany jest bit 3 rejestru STICK0?)
            bne endmove         ; w przeciwnym wypadku koniec sprawdzania
            cpx #200            ; jeśli osiągnęliśmy już prawą stronę (200=$C8)
            bcs endmove         ; to kończymy sprawdzanie joysticka
            inc POSH            ; a jeśli nie, przesuwamy statek o jedną pozycję w prawo
endmove

            jmp main            ; główna pętla gry zaczyna się od etykiety main 

move        ldy #0              ; procedura kopiująca LENPTR bajtów z MVSRCE do MVDEST
            sty MVSRCE+1        ; dane do kopiowania znajdują się na stronie zerowej
            ldx LENPTR          ; procedura kopiuje maksymalnie 255 bajtów
mvlast      lda (MVSRCE),y      ; z MVSRCE
            sta (MVDEST),y      ; do MVDEST
            iny
            dex                 ; rejestr X jest licznikiem pętli
            bne mvlast
mvexit      rts

            org $229D
            
VBI         lda #BGCOL          ; ustaw licznik kolorów dla DLI
            sta BGCOUNTER

            lda TIMER           ; Zmienna TIMER przyjmuje wartości 0 i 3
            eor #%00000011      ; przełączane co 1/50 sekundy
            sta TIMER

            ldx #2              ; Animacja napędu statku kosmicznego:  
animate     lda PROPULSION,x    ; Modyfikujemy 3 środkowe bajty drugiego gracza
            eor #%11000000      ; odwracając 2 najstarsze bity (czyli 2 piksele z lewej strony) 
            sta PROPULSION,x
            dex
            bpl animate         ; skacz, jeśli wynik dodatni, czyli pętla wykona się 3 razy

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
