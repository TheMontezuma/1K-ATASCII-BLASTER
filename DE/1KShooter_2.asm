
            run start

            RTCLOK = $14              ; Systemzähler, wird um 1 pro 1/50 Sekunde erhöht
            VDSLST = $200             ; DLI-Interruptvektor
            SDMCTL = $22f             ; DMA-Speicherzugriffssteuerung
            SDLSTL = $230             ; Zeiger auf den ersten Display-List-Befehl
            COLPF0 = $d016            ; Farbe/Helligkeit Playfield 0
            COLBK  = $d01a            ; Farbe/Helligkeit des Hintergrunds
            AUDF1  = $d200            ; Frequenz des ersten Tongenerators
            AUDC1  = $d201            ; Konfiguration des ersten Tongenerators
            AUDF2  = $d202            ; Frequenz des zweiten Tongenerators
            AUDC2  = $d203            ; Konfiguration des zweiten Tongenerators
            AUDCTL = $d208            ; Tonsteuerungsregister
            RANDOM = $d20a            ; Zufallszahlengenerator
            NMIEN  = $d40e            ; Konfiguration der nicht maskierbaren Interrupts
            WSYNC  = $d40a            ; Warte auf horizontale Synchronisation
                                      ; Schreiben in dieses Register hält den 6502 an
            ANTICMODE = $57+$80       ; Standard-ANTIC-Modus
            WIDTH = 32                ; Breite des virtuellen Bildschirms (in Zeichen)
            BGCOL = 12                ; Anzahl der Hintergrundzeilen zum Einfärben im DLI
            BGCOUNTER = $89           ; Hintergrundfarbzähler

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

            org $DD

TABLE       .byte $00,$A0,$A2,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A2,$A0

SOUND       .byte $F3,$D9,$C1,$B6,$A2,$90

            org $2000

start       lda #%00101011       ; aktives DMA für DL und P/M + 2-Linien-P/M + breiter Bildschirm
            sta SDMCTL

            lda #<DLIST          ; installiere DL
            sta SDLSTL
            lda #>DLIST          ; höherwertiges Byte der DLIST-Adresse ist 0
            sta SDLSTL+1
            sta AUDCTL           ; konfiguriere das Tonsteuerungsregister
            sta RTCLOK           ; setze RTCLOK-Zähler zurück

            lda #<DLI            ; installiere DLI
            sta VDSLST
            lda #>DLI
            sta VDSLST+1
            lda #$C0             ; aktiviere VBI+DLI
            sta NMIEN

setVBI      ldy #<VBI            ; installiere VBI
            ldx #>VBI
            lda #6               ; sofortiges VBI
            jsr $e45c            ; SETVBV

restart     lda RTCLOK
            cmp #25
            bne checktrig        ; sind bereits 0,5 Sekunden vergangen?
nextvoice   lda #$a8             ; wenn ja:
            sta AUDC1            ; konfiguriere Kanal 1
            sta AUDC2            ; und Kanal 2
            lda RANDOM           ; lade Zufallswert
            and #%00000011       ; im Bereich 0 - 3
            tax                  ; lade ihn in X
            lda SOUND,x          ; hole Wert von Adresse SOUND+X
            lsr
            sta AUDF1            ; spiele Ton auf Kanal 1
            lda SOUND+2,x        ; hole Wert von Adresse SOUND+2+X
            sta AUDF2            ; spiele Ton auf Kanal 2
            lda #0
            sta RTCLOK           ; setze RTCLOK-Zähler zurück

checktrig   jmp restart

            org $229D

VBI         lda #BGCOL          ; setze den Farbzähler für DLI
            sta BGCOUNTER
exitvbi     jmp $e45f           ; SYSVBV

            org $230D

DLI         pha                 ; lege Akkumulator auf den Stack
            txa                 ; Register X in Akkumulator
            pha                 ; und auf den Stack
            ldx BGCOUNTER       ; hole den Index
            lda TABLE,x         ; hole Farbe/Helligkeit aus der Tabelle
            sta WSYNC           ; warte auf horizontale Synchronisation
            sta COLBK           ; ändere Hintergrundfarbe
            ldx #7              ; initialisiere den Schleifenzähler
pfloop      lda TABLE+3,x       ; hole Farbe/Helligkeit aus der Tabelle
            sbc #$7D            ; subtrahiere OFFSET
            sta WSYNC           ; warte auf horizontale Synchronisation
            sta COLPF0          ; ändere Farbe
            dex                 ; verringere den Schleifenzähler
            bne pfloop          ; wenn der Zähler ungleich null ist, führe die Schleife erneut aus
            dec BGCOUNTER       ; verringere den Index
exitdli     pla                 ; hole den Wert von Register X vom Stack (in den Akkumulator)
            tax                 ; stelle Register X wieder her
            pla                 ; hole Akkumulator vom Stack
            rti                 ; Rückkehr aus dem Interrupt

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
