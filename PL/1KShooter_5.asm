
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
            PCOLR2 = $2c2             ; Kolor/jasność trzeciego gracza/pocisku
            CHBAS  = $2f4             ; Adres zestawu znaków (starszy bajt)
            HPOSP0 = $d000            ; Pozycja pozioma pierwszego gracza (zapis)
            HPOSP1 = $d001            ; Pozycja pozioma drugiego gracza (zapis)
            P0PF   = $d004            ; Detekcja kolizji pierwszego gracza
            HPOSM2 = $d006            ; Pozycja pozioma trzeciego pocisku (zapis)
            M2PF   = $d002            ; Detekcja kolizji trzeciego pocisku
            SIZEM  = $d00c            ; Szerokość pocisków (zapis)
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
            HSCROL = $d404            ; Przewinięcie poziome w pikselach (rejestr, tylko zapis)
            PMBASE = $d407            ; Wskaźnik obszaru pamięci przeznaczonego dla grafiki P/M
            NMIEN  = $d40e            ; Konfiguracja przerwań niemaskowalnych
            WSYNC  = $d40a            ; Czekaj na synchronizację poziomą 
                                      ; zapis do tego rejestru powoduje zatrzymanie 6502
            PMBASEADR = $3000         ; Adres danych P/M
            MDATA   = PMBASEADR+$180  ; Adres danych pocisków
            PMDATA1 = PMBASEADR+$200  ; Adres danych pierwszego gracza
            PMDATA2 = PMBASEADR+$280  ; Adres danych drugiego gracza
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Rozmiar gracza (w bajtach)
            STARTPOSH = 60            ; Początkowa pozycja statku w poziomie
            STARTPOSV = 56            ; Początkowa pozycja statku w pionie
            ANTICMODE = $57+$80       ; Domyślny tryb ANTIC-a
            WIDTH = 32                ; Szerokość wirtualnego ekranu (w znakach)
            BGCOL = 12                ; Liczba linii tła do pokolorowania w DLI
            LINES = 8                 ; Liczba przewijanych wierszy w DL
            CLOCKS = 8                ; Liczba pikseli do płynnego przewinięcia
            POSV = $80                ; Pozycja statku w pionie (górna krawędź)
            POSH = $81                ; Pozycja statku w poziomie (lewa krawędź)
            M2POSV = $82              ; Pozycja pocisku w pionie
            M2POSH = $83              ; Pozycja pocisku w poziomie
            MVSRCE = $84              ; Adres źródłowy (2 bajty) dla procedury kopiującej dane 
            MVDEST = $86              ; Adres docelowy (2 bajty) dla procedury kopiującej dane
            LENPTR = $88              ; Długość bloku danych do skopiowania (w bajtach)
            BGCOUNTER = $89           ; Licznik kolorów tła
            CHRADR = $8a              ; Wskaźnik do znaków (2 bajty)
            LMSV   = $8c              ; Wskaźnik do pamięci obrazu (2 bajty)
            SPEED  = $8e              ; Szybkość przewijania obrazu
            TIMER  = $8f              ; Zmienna synchronizująca kod z przerwaniami VBI
            SHOTSPEED = $90           ; Prędkość pocisku (w pikselach na odświeżenie ekranu)

            org $91
VBIFLAG     .byte 1                   ; Flaga zezwalająca na przewijanie obrazu w przerwaniach
SHOTFIRED   .byte 0                   ; Wystrzelono pocisk (flaga)
SCROLLPOS   .byte 0                   ; Przewinięcie poziome w pikselach
SCROLLCOUNT .byte 0                   ; Licznik przewiniętych (zgrubnie) znaków

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

GAMEOVERTXT .byte "GAME OVER"

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

HIGHTXT     .byte "HIGH"
SCORETXT    .byte "SCORE:0000"

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
            sta SPEED            ; początkowa szybkość przewijania obrazu (=1) 

            lda #3
            sta PCOLR1           ; ustaw kolor drugiego gracza (ciemno szary)
            sta GRACTL           ; włącz P/M
            sta SHOTSPEED        ; ustaw prędkość pocisku
            lda #8
            sta PCOLR0           ; ustaw kolor pierwszego gracza (jasno szary)
            asl                  ;  8 x 2 = 16 (0x10)
            sta SIZEM            ; ustaw szerokość pocisku (na podwójną)
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

            ldy #9
resetscore  lda SCORETXT,y       ; skopiuj napis "SCORE:0000"
            sta line10+2,y       ; do linii statusu gry
            dey
            bpl resetscore

main        lda P0PF            ; czy nastąpiła kolizja pierwszego gracza?
            sta VBIFLAG         ; 0 = zgoda na przewijanie obrazu
            beq highscore       ; jeśli nie, kontynuujemy grę

gameover    lda #0              ; a jeśli tak: game over
            sta AUDC2           ; wyłącz dźwięk strzału
            lda #214            ; przesuń pocisk poza widoczny obszar
            sta HPOSM2          ; wpisz wartość 214 do rejestru pozycji poziomej pocisku
            sta M2POSH          ; uaktualnij zmienną przechowującą pozycję poziomą pocisku  
            lda #$8f
            sta AUDC1           ; ustaw zniekształcenie dźwięku
            sta RTCLOK          ; ustaw zegar
            
waitsound   lda RTCLOK          ; odtwarzaj dźwięk rozbijającego się statku kosmicznego
            sta AUDF1           ; przez około 2 sekund (255-143=112 odświeżeń ekranu)
            sta PCOLR0          ; i zmieniaj kolor pierwszego gracza (efekt migotania)
            bne waitsound       ; dopóki RTCLOK nie osiągnie wartości 0
            sta AUDC1           ; następnie wyłącz dźwięk

            ldy #9
textend     lda GAMEOVERTXT,y   ; skopiuj napis "GAME OVER"
            sta line10+2,y      ; do linii statusu gry
            dey
            bpl textend

            jmp restart
                
highscore   tay                 ; A=0, bo nie było kolizji (P0PF)
checkhigh   lda line10+8,y      ; pobierz kolejną cyfrę wyniku (zaczynając od cyfry tysięcy)
            cmp line10+18,y     ; porównaj ją z odpowiadającą jej cyfrą Hi-Score
            bcc prepmove        ; koniec sprawdzania jeśli cyfra aktualnego wyniku jest mniejsza
            bne sethigh         ; jeśli cyfra aktualnego wyniku jest większa to mamy Hi-Score
            iny                 ; w przeciwnym wypadku obie cyfry są równe
            cpy #2              ; więc kontynuuj sprawdzanie kolejnych cyfr (setek i dziesiątek)
            bne checkhigh
sethigh     ldy #4              ; jeśli Hi-Score <= Score
copyscore   lda line10+7,y      ; skopiuj aktualny wynik (Score)
            sta line10+17,y     ; łącznie z poprzedzającym go znakiem ":" do Hi-Score
            dey                 ; np. ":1710"
            bpl copyscore
            ldy #3
hightext    lda HIGHTXT,y
            sta line10+13,y     ; skopiuj napis "HIGH"
            dey                 ; do linii statusu gry
            bpl hightext

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
            
movem       lda SHOTFIRED       ; czy wystrzelono pocisk ?
            beq noshot

            lda #<MDATA         ; jeśli tak, to pobierz młodszy bajt adresu danych P/M pocisku
            clc
            adc M2POSV          ; dodaj do niego pozycję pionową pocisku
            sta MVDEST          ; ustaw młodszy bajt adresu docelowego (dokąd)
            lda #>MDATA         ; pobierz starszy bajt adresu danych P/M pocisku
            sta MVDEST+1        ; ustaw starszy bajt adresu docelowego (dokąd)
            ldy #00
            lda MSHAPE          ; skopiuj dane pocisku (1 bajt)
            sta (MVDEST),y      ; pod adres MDATA+M2POSV

            lda M2POSH          ; załaduj aktualną pozycję poziomą pocisku
            sta HPOSM2          ; wpisz ją do rejestru pozycji poziomej pocisku
            sta PCOLR2          ; pocisk zmienia kolor w trakcie lotu
            sbc POSH            ; odejmij od niej poziomą pozycję statku kosmicznego 
            sta AUDF2           ; im większa odległość tym niższa częstotliwość dźwięku 
            lda #$6a
            sta AUDC2           ; ustaw zniekształcenie dźwięku przypominające odgłos pocisku
noshot

            lda TIMER           ; pobierz wartość zmiennej TIMER
wait        cmp TIMER           ; czy się zmieniła ?
            beq wait            ; jeśli nie to czekaj dalej

            lda STRIG0          ; czy FIRE jest wciśnięty ?
            bne checkmove
            jsr shot            ; jeśli tak, to strzelaj
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
            inc POSH            ; a jeśli nie, przesuwamy statek o jedną pozycję w lewo
endmove

            lda SCROLLCOUNT     ; załaduj licznik przewiniętych zgrubnie znaków
            cmp #8              ; czy przewinęliśmy już 8 znaków ?
            bne checkshot       ; jeśli nie, to kontynuacja gry od etykiety checkshot

            lda #0              ; przygotowujemy pamięć obrazu
            sta SCROLLCOUNT     ; wyzeruj licznik przewiniętych znaków
            lda CHBAS           ; załaduj starszy bajt adresu zestawu znaków
            clc
            adc #2              ; dodaj do niego 2 (zestaw znaków zajmuje 4 strony)
            sta CHRADR+1        ; i wynik zapisz w starszym bajcie wskaźnika do znaków 
            lda RANDOM          ; pobierz wartość losową od 0-255
            and #%11111000      ; maska zapewnia, że wartość jest podzielna przez 8
                                ; czyli jest to adres jednego z 32 znaków na 3 stronie zestawu
            sta CHRADR          ; wynik zapisz w młodszym bajcie wskaźnika do znaków
                        
            lda LMS1            ; załaduj młodszy bajt adresu danych dla pierwszego wiersza
            clc
            adc #24             ; dodaj do niego 24 (liczba znaków w wierszu) 
            sta LMSV            ; i zapisz go w LMSV
            lda LMS1+1          ; załaduj starszy bajt adresu pierwszego wiersza
            adc #0              ; dodaj do niego 0 (uwzględniając znacznik Carry)
            sta LMSV+1          ; i zapisz go w LMSV+1

            ldy #0              ; wyzeruj rejestr Y

nextbyte    ldx #8              ; wpisz 8 do X (licznik bitów w linii znaku)
            lda (CHRADR),y      ; pobierz kolejny bajt (linię) definicji znaku 

nextbit     asl                 ; przesuń piksele w lewo o 1 bit (7 bit -> Carry)
            pha                 ; odłóż akumulator na stos
            bcc setblank
            lda #"O"            ; jeśli znacznik Carry był zapalony
            bcs checkbit        ; załaduj kod wewnętrzny "0" i skocz do checkbit
setblank    lda #" "            ; w przeciwnym razie załaduj kod wewnętrzny " "
checkbit    sta (LMSV),y        ; zapisz "0" lub " " pod adres LMSV+Y
            inc LMSV            ; przesuń wskaźnik LMSV o 1 bajt w prawo            
            bne singlebyte2
            inc LMSV+1          ; uwzględniając ewentualne przeniesienie
singlebyte2 pla                 ; pobierz akumulator ze stosu 
            dex                 ; odliczamy w dół
            bne nextbit         ; czy to już 8 bit (w tej linii) ?
            
            lda LMSV            ; załaduj młodszy bajt wskaźnika LMSV
            clc                 ; przesuń go na koniec następnego wiersza 
            adc #WIDTH*2-9      ; kompensując rosnącą wartość rejestru Y (-1 bajt)
            bcc singlebyte      ; i uwzględniając ewentualne przeniesienie
            inc LMSV+1
singlebyte  sta LMSV

            iny                 ; następny bajt (linia) definicji znaku 
            cpy #8              ; czy to ostatnia linia w znaku ?
            bne nextbyte        ; jeśli nie, to skocz do nextbyte

checkshot   lda SHOTFIRED       ; czy wystrzelono pocisk ?
            bne delchar
            jmp endofmain       ; jeśli nie, to skacz na koniec pętli głównej

delchar     lda M2PF            ; pocisk jest w drodze, sprawdź rejestr kolizji pocisku
            beq nocoll

            lda M2POSH          ; pocisk w coś trafił, załaduj pozycję poziomą pocisku
            sec
            sbc #30             ; odejmij od niej offset ($1E)
            sbc SCROLLPOS       ; odejmij liczbę przewiniętych pikseli
            lsr                 ; i podziel przez 8 (2*2*2)
            lsr
            lsr                 ; wynik to pozycja pozioma znaku do usunięcia 
            tay                 ; przechowaj wynik w rejestrze Y

            lda M2POSV          ; załaduj pozycję pionową pocisku
            sec
            sbc #31             ; odejmij od niej offset ($1F)
            lsr                 ; i podziel przez 8 (2*2*2)
            lsr
            lsr                 ; wynik to pozycja pionowa znaku do usunięcia
            tax                 ; przechowaj wynik w rejestrze X
            
            lda LMS1            ; pobierz młodszy bajt adresu pierwszej linii pola gry
            sta LMSV            ; i zapisz go w LMSV
            lda LMS1+1          ; pobierz starszy bajt adresu pierwszej linii pola gry
            sta LMSV+1          ; i zapisz go w LMSV+1
            cpx #0              ; jeśli znak do usunięcia znajduje się w pierwszej linii
            beq clearchar       ; to jesteśmy gotowi
nextline    lda LMSV            ; w przeciwnym razie przesuwamy wskaźnik LMSV 
            clc                 ; na początek danych obrazu linii
            adc #WIDTH*2        ; w której znajduje się znak do usunięcia
            bcc onebyte
            inc LMSV+1          ; przeniesienie w dodawaniu
onebyte     sta LMSV
            dex
            bne nextline        ; na końcu pętli w rejestrze X mamy 0
            
clearchar   lda #" "            ; załaduj kod wewnętrzny znaku spacji (0)
            sta (LMSV),y        ; i wpisz go w pamięci obrazu na pozycji znaku do usunięcia

            ldy #2              ; dolicz 10 punktów za każdy zestrzelony znak
scoreloop   lda line10+8,y      ; manipulujemy bezpośrednio na danych ekranu
            clc                 ; pod adresem line10+8+2 znajduje się cyfra dziesiątek
            adc #1              ; dodajemy do jej kodu 1 i sprawdzamy przeniesienie
            cmp #":"            ; czy jest to kod znaku ":" ? (kolejny po cyfrze "9") 
            bne writescore
            lda #"0"            ; jest przeniesienie, więc wpisz cyfrę "0"
            sta line10+8,y      ; w miejscu ":"
            dey                 ; przejdź do bardziej znaczącej cyfry wyniku gry
            bpl scoreloop       ; dodaj do niej 1 (w kolejnej iteracji)
writescore  sta line10+8,y      ; wpisz cyfrę powiększoną o 1 na aktualnej pozycji
            cpy #0              ; jeśli to cyfra tysięcy
            bne resmissile
            cmp #"1"            ; to sprawdź, czy nastąpiła zmiana z "0" na "1"
            bne resmissile
            stx SPEED           ; jeśli tak, to zwiększ szybkość przewijania (X=0)
            inc SHOTSPEED       ; i zwiększ prędkość pocisku

resmissile  lda #211            ; przesuń pocisk poza widoczny obszar
            sta M2POSH          ; uaktualnij zmienną przechowującą pozycję poziomą pocisku 
            sta HITCLR          ; wyczyść rejestry kolizcji P/M 

nocoll      lda M2POSH          ; załaduj pozycję poziomą pocisku
            clc
            adc SHOTSPEED       ; dodaj do niej prędkość pocisku
            sta M2POSH          ; uaktualnij zmienną przechowującą pozycję poziomą pocisku
            cmp #212            ; czy pocisk osiągnął prawą stronę ekranu ?
            bcc endofmain       ; jeśli jeszcze nie, to skocz na koniec pętli głównej 
            lda #0              ; pocisk zniknął z prawej strony
            sta AUDC2           ; wyłącz dźwięk strzału
            sta SHOTFIRED       ; wyzeruj flagę SHOTFIRED=0 (brak pocisku)
            ldy #$80            ; wyzeruj w pętli dane P/M pocisku (128 bajtów)
clearm      sta MDATA,y
            dey
            bne clearm

endofmain
            jmp main            ; główna pętla gry zaczyna się od etykiety main 

shot        lda SHOTFIRED       ; sprawdź, czy czy pocisk jest już w drodze 
            cmp #1
            bne contshot
            rts                 ; jeśli tak, to powrót
contshot    inc SHOTFIRED       ; jeśli nie - ustaw flagę SHOTFIRED=1
            lda POSV            ; załaduj pozycję pionową statku
            clc
            adc #6              ; dodaj do niej liczbę 6 (działko znajduje się na środku statku)
            sta M2POSV          ; zapisz wyliczoną w ten sposób pozycję pionową pocisku 
            lda POSH            ; pobierz pozycję poziomą statku
            sta M2POSH          ; i zapisz ją jako pozycję poziomą pocisku
            rts

move        ldy #0              ; procedura kopiująca LENPTR bajtów z MVSRCE do MVDEST
            sty MVSRCE+1        ; dane to kopiowania znajdują się na stronie zerowej
            ldx LENPTR          ; procedura kopiuje maksymalnie 255 bajtów
mvlast      lda (MVSRCE),y      ; z MVSRCE
            sta (MVDEST),y      ; do MVDEST
            iny
            dex                 ; rejestr X jest licznikiem pętli
            bne mvlast
mvexit      rts
            
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

            lda VBIFLAG         ; czy mamy zgodę na przewijanie obrazu?
            bne exitvbi         ; jeśli nie, opuść przerwanie

            lda SCROLLPOS       ; załaduj aktualną pozycję poziomą (płynne przewijanie) 
            sta HSCROL          ; wpisz ją do rejestru sprzętowego
            lda TIMER           ; załaduj zmienną TIMER (0-3-0-3, itd.)
            and SPEED           ; AND ze zmienną SPEED: wartość 1=powoli lub 0=szybko 
            bne exitvbi         ; Jeśli SPEED=1, opuść co drugie przerwanie (gdy TIMER=3)
            dec SCROLLPOS       ; zmniejsz o 1 liczbę pikseli do przewinięcia
            bpl exitvbi         ; jeśli wartość jest nieujemna, opuść przerwanie

setmove     lda LMS1            ; załaduj młodszy bajt adresu danych obrazu pierwszego wiersza
            cmp <line2+WIDTH    ; porównaj go z młodszym bajtem adresu znaku znajdującego się
                                ; zaraz za pierwszym wierszem w pamieci obrazu
            bne coarsescrol     ; jeśli są różne, kontynuujemy zgrubne przewijanie

; jeśli LMS1 równy jest LMSC, to znaczy, że przewinęliśmy już całkiem dane obrazu
; i czas teraz dla każdego wiersza przeładować operandy LMS-ów (zmniejszyć je o WIDTH)
; oraz skopiować ich pamięć obrazu pod nowy adres 

            ldx #(LINES-1)*3    ; załaduj do X 21 =(liczba wierszy-1)*3 bajty na wiersz

rollover    lda LMS1+1,x        ; pobierz starszy bajt adresu danych obrazu wiersza X/3
            sta MVSRCE+1        ; zapamiętaj go w MVSRCE+1
            lda LMS1,x          ; pobierz młodszy bajt adresu danych obrazu wiersza X/3
            sta MVSRCE          ; zapamiętaj go w MVSRCE
            sec
            sbc #WIDTH          ; odejmij WIDTH (szerokość wirtualnego ekranu)
            bcs byteonly        ; z uwzględnieniem przeniesienia
            dec LMS1+1,x
byteonly    sta LMS1,x          ; wynik zapisz w adresie danych obrazu wiersza X/3
            sta MVDEST          ; oraz w zmiennej MVDEST 
            lda LMS1+1,x
            sta MVDEST+1

            ldy #WIDTH-1        ; załaduj WITDH do Y (licznik pętli) 
mirror      lda (MVSRCE),y      ; skopiuj dane obrazu
            sta (MVDEST),y      ; o 32 bajty wstecz
            dey
            bpl mirror

            dex                 ; definicja wierszy pola gry składa się z 3 bajtów:
            dex                 ; rozkazu ANTIC-a (1 bajt) i 2 bajtów adresu
            dex                 ; zmniejszając X o 3, idziemy więc do wiersza wyżej
            bpl rollover        ; jeśli X jest nieujemny, modyfikujemy kolejny wiersz

coarsescrol inc SCROLLCOUNT     ; zgrubne przewijanie, manipulujemy DL !!!
            ldx #(LINES-1)*3    ; załaduj do X 21 =(liczba wierszy-1)*3 bajty na wiersz 
                                ; dla każdego z 8 wierszy pola gry (zaczynając od dołu) 
nextcs      inc LMS1,x          ; zwiększamy o 1 młodszy bajt adresu dla LMS
            bne done            ; czyli adres pamięci obrazu dla danego wiersza 
            inc LMS1+1,x        ; uwzględniamy ewentualne przeniesienie
done        dex                 ; definicja wierszy pola gry składa się z 3 bajtów:
            dex                 ; rozkazu ANTIC-a (1 bajt) i 2 bajtów adresu
            dex                 ; zmniejszając X o 3, idziemy więc do wiersza wyżej
            bpl nextcs          ; jeśli X jest nieujemny, modyfikujemy kolejny wiersz  

            lda #CLOCKS         ; załaduj liczbę cykli koloru do przewijania (8)
            sta SCROLLPOS       ; ustaw liczbę pikseli do przewinięcia
            sta HSCROL          ; wpisz ją do rejestru sprzętowego
            dec SCROLLPOS       ; 

exitvbi     jmp $e45f           ; SYSVBV

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
