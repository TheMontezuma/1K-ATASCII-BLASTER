
            run start

            RTCLOK = $14              ; Systemzähler, wird um 1 pro 1/50 Sekunde erhöht
            ATRACT = $4d              ; Steuerung des Bildschirmschoners
            VDSLST = $200             ; DLI-Interruptvektor
            SDMCTL = $22f             ; DMA-Speicherzugriffssteuerung
            SDLSTL = $230             ; Zeiger auf den ersten Display-List-Befehl
            GPRIOR = $26f             ; P/M-Grafikkonfiguration (Prioritäten, usw.)
            STICK0 = $278             ; Position des ersten Joysticks
            STRIG0 = $284             ; Status des FIRE-Knopfs des ersten Joysticks (0-gedrückt)
            PCOLR0 = $2c0             ; Farbe/Helligkeit des ersten Spielers/Geschosses
            PCOLR1 = $2c1             ; Farbe/Helligkeit des zweiten Spielers/Geschosses
            HPOSP0 = $d000            ; Horizontale Position des ersten Spielers (Schreiben)
            HPOSP1 = $d001            ; Horizontale Position des zweiten Spielers (Schreiben)
            P0PF   = $d004            ; Kollisionserkennung des ersten Spielers
            COLPF0 = $d016            ; Farbe/Helligkeit Playfield 0
            COLBK  = $d01a            ; Farbe/Helligkeit des Hintergrunds
            GRACTL = $d01d            ; P/M-Grafikkonfiguration
            HITCLR = $d01e            ; Schreiben in dieses Register löscht die P/M-Kollisionsregister
            AUDF1  = $d200            ; Frequenz des ersten Tongenerators
            AUDC1  = $d201            ; Konfiguration des ersten Tongenerators
            AUDF2  = $d202            ; Frequenz des zweiten Tongenerators
            AUDC2  = $d203            ; Konfiguration des zweiten Tongenerators
            AUDCTL = $d208            ; Tonsteuerungsregister
            RANDOM = $d20a            ; Zufallszahlengenerator
            PMBASE = $d407            ; Zeiger auf den Speicherbereich für P/M-Grafik
            NMIEN  = $d40e            ; Konfiguration der nicht maskierbaren Interrupts
            WSYNC  = $d40a            ; Warte auf horizontale Synchronisation
                                      ; Schreiben in dieses Register hält den 6502 an
            PMBASEADR = $3000         ; P/M-Datenadresse
            PMDATA1 = PMBASEADR+$200  ; Datenadresse des ersten Spielers
            PMDATA2 = PMBASEADR+$280  ; Datenadresse des zweiten Spielers
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Spielergröße (in Bytes)
            STARTPOSH = 60            ; Anfangshorizontalposition des Schiffes
            STARTPOSV = 56            ; Anfangsvertikalposition des Schiffes
            ANTICMODE = $57+$80       ; Standard-ANTIC-Modus
            WIDTH = 32                ; Breite des virtuellen Bildschirms (in Zeichen)
            BGCOL = 12                ; Anzahl der Hintergrundzeilen zum Einfärben im DLI
            POSV = $80                ; Vertikale Position des Schiffes (oberer Rand)
            POSH = $81                ; Horizontale Position des Schiffes (linker Rand)
            MVSRCE = $84              ; Quelladresse (2 Bytes) für die Datenkopier-Prozedur
            MVDEST = $86              ; Zieladresse (2 Bytes) für die Datenkopier-Prozedur
            LENPTR = $88              ; Länge des zu kopierenden Datenblocks (in Bytes)
            BGCOUNTER = $89           ; Hintergrundfarbzähler
            TIMER  = $8f              ; Variable zur Synchronisation des Codes mit VBI-Interrupts

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

            org $C5

PMSHAPE1    .byte %00000000 ; Grafik des Raumschiffs für den ersten Spieler
            .byte %11100000 ; Von hier werden Daten in den P/M-Speicherbereich kopiert
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
;Das letzte Byte der Grafik des ersten Spielers und das erste Byte der Grafik des zweiten Spielers sind identisch
;Unter Berücksichtigung ihrer Überlappung (PMSHAPESIZE wird um 1 erhöht) sparen wir 1 Byte

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
MSHAPE      .byte %00110000 ; MSHAPE sind die grafischen Daten des Geschosses (1 Byte)
;           .byte %00000000 ; geliehen von der Grafik des zweiten Spielers
;Hier wird der Speicher zwischen dem letzten Byte von PMSHAPE2 und dem ersten Byte von TABLE geteilt

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

checktrig   lda STRIG0           ; warte mit dem Spielstart auf das Drücken des FIRE-Knopfs
            bne restart
            sta ATRACT           ; schreibe 0, um die Aktivierung des Bildschirmschoners zu verzögern
            sta AUDC1            ; deaktiviere Ton (Kanal 1)
            sta AUDC2            ; deaktiviere Ton (Kanal 2)
            tax                  ; lege Wert 0 für später zurück

waitrelease lda STRIG0
            beq waitrelease      ; ist der FIRE-Knopf noch gedrückt?

            lda #3
            sta PCOLR1           ; setze Farbe des zweiten Spielers (dunkelgrau)
            sta GRACTL           ; aktiviere P/M
            lda #8
            sta PCOLR0           ; setze Farbe des ersten Spielers (hellgrau)
            asl                  ;  8 x 2 = 16 (0x10)
            asl                  ; 16 x 2 = 32 (0x20)
            sta GPRIOR           ; aktiviere Farbmischung für Spieler
            lda #>PMBASEADR      ; höherwertiges Byte der PMBASEADR-Adresse
            sta PMBASE           ; als Anfang des Speicherbereichs für P/M-Grafik

            lda LENPTR           ; wenn LENPTR noch nicht verwendet wurde, also den Wert 0 hat
            beq playerinit       ; dann überspringe das Speicherlöschen

            txa                  ; hole das zuvor in Register X gespeicherte 0
wipe        sta line2,x          ; lösche Bildspeicher und P/M
            sta line2+256,x
            sta PMDATA1,x
            dex
            bne wipe

playerinit  sta HITCLR           ; lösche P/M-Kollisionsregister
            lda #STARTPOSV       ; setze Anfangsposition des Raumschiffs
            sta POSV
            lda #STARTPOSH
            sta POSH

main        lda P0PF            ; ist eine Kollision des ersten Spielers aufgetreten?
            beq prepmove        ; wenn nicht, setzen wir das Spiel fort

gameover    lda #$8f            ; wenn ja: Game Over
            sta AUDC1           ; setze Tonverzerrung
            sta RTCLOK          ; setze Uhr

waitsound   lda RTCLOK          ; spiele den Absturzton des Raumschiffs
            sta AUDF1           ; für ca. 2 Sekunden (255-143=112 Bildwiederholungen)
            sta PCOLR0          ; und ändere die Farbe des ersten Spielers (Flimmereffekt)
            bne waitsound       ; bis RTCLOK den Wert 0 erreicht
            sta AUDC1           ; danach deaktiviere Ton

            jmp restart

prepmove    lda #<PMSHAPE1      ; hole das niederwertige Byte der Adresse der Grafik des ersten Spielers
            sta MVSRCE          ; setze das niederwertige Byte der Quelladresse (woher)
            lda POSH            ; lade die aktuelle horizontale Position des Raumschiffs
            sta HPOSP0          ; schreibe sie in das Horizontalpositionsregister von Spieler 1
            sta HPOSP1          ; schreibe sie in das Horizontalpositionsregister von Spieler 2
            lda #<PMDATA1       ; hole das niederwertige Byte der P/M-Datenadresse von Spieler 1
            clc
            adc POSV            ; addiere die vertikale Position dazu
            sta MVDEST          ; setze das niederwertige Byte der Zieladresse (wohin)
            lda #>PMDATA1       ; hole das höherwertige Byte der P/M-Datenadresse von Spieler 1
            sta MVDEST+1        ; setze das höherwertige Byte der Zieladresse (wohin)
            lda #PMSHAPESIZE    ; wie viele Bytes?
            sta LENPTR
            jsr move            ; rufe die Prozedur auf, die LENPTR Bytes von MVSRCE nach MVDEST kopiert

            lda #<PMSHAPE2      ; hole das niederwertige Byte der Adresse der Grafik des zweiten Spielers
            sta MVSRCE          ; setze das niederwertige Byte der Quelladresse (woher)
            lda #<PMDATA2       ; hole das niederwertige Byte der P/M-Datenadresse des zweiten Spielers
            clc
            adc POSV            ; addiere die vertikale Position dazu
            sta MVDEST          ; setze das niederwertige Byte der Zieladresse (wohin)
            lda #PMSHAPESIZE    ; wie viele Bytes?
            sta LENPTR
            jsr move            ; rufe die Prozedur auf, die LENPTR Bytes von MVSRCE nach MVDEST kopiert

            lda TIMER           ; hole den Wert der TIMER-Variable
wait        cmp TIMER           ; hat er sich geändert?
            beq wait            ; wenn nicht, warte weiter

checkmove
vertical    ldx POSV            ; lade die aktuelle vertikale Position des Schiffes
            stx AUDF1           ; sie beeinflusst die Tonfrequenz
            lda #$83            ; durch Experimentieren mit dem AUDC1-Register kann man
            sta AUDC1           ; ein verzerrtes Geräusch erzeugen, das einem Raumschiff ähnelt
up          lda STICK0          ; lade die Joystick-Position
            tay                 ; speichere sie in Register Y
            and #%00000001      ; nach oben? (ist Bit 0 von STICK0 gelöscht?)
            bne down            ; andernfalls prüfen wir, ob nach unten
            cpx #32             ; wenn wir die obere Grenze erreicht haben (31=$1F)
            bcc horizontal      ; dann prüfen wir die horizontale Auslenkung
            dec POSV            ; wenn nicht, heben wir das Schiff um eine Position
down        tya                 ; lese die in Register Y gespeicherte Joystick-Position
            and #%00000010      ; nach unten? (ist Bit 1 von STICK0 gelöscht?)
            bne horizontal      ; andernfalls prüfen wir die horizontale Auslenkung
            cpx #84             ; wenn wir die untere Grenze erreicht haben (84=$54)
            bcs horizontal      ; dann prüfen wir die horizontale Auslenkung
            inc POSV            ; wenn nicht, senken wir das Schiff um eine Position
horizontal  ldx POSH            ; lade die aktuelle horizontale Position des Schiffes
left        tya                 ; lese die in Register Y gespeicherte Joystick-Position
            and #%00000100      ; nach links? (ist Bit 2 von STICK0 gelöscht?)
            bne right           ; andernfalls prüfen wir, ob nach rechts
            cpx #45             ; wenn wir die linke Grenze erreicht haben (44=$2C)
            bcc endmove         ; dann beenden wir die Joystick-Abfrage
            dec POSH            ; wenn nicht, bewegen wir das Schiff um eine Position nach links
right       tya                 ; lese die in Register Y gespeicherte Joystick-Position
            and #%00001000      ; nach rechts? (ist Bit 3 von STICK0 gelöscht?)
            bne endmove         ; andernfalls Ende der Abfrage
            cpx #200            ; wenn wir die rechte Grenze erreicht haben (200=$C8)
            bcs endmove         ; dann beenden wir die Joystick-Abfrage
            inc POSH            ; wenn nicht, bewegen wir das Schiff um eine Position nach rechts
endmove

            jmp main            ; die Hauptschleife des Spiels beginnt bei der Marke main

move        ldy #0              ; Prozedur zum Kopieren von LENPTR Bytes von MVSRCE nach MVDEST
            sty MVSRCE+1        ; die zu kopierenden Daten befinden sich auf Seite Null
            ldx LENPTR          ; die Prozedur kopiert maximal 255 Bytes
mvlast      lda (MVSRCE),y      ; von MVSRCE
            sta (MVDEST),y      ; nach MVDEST
            iny
            dex                 ; Register X ist der Schleifenzähler
            bne mvlast
mvexit      rts

            org $229D

VBI         lda #BGCOL          ; setze den Farbzähler für DLI
            sta BGCOUNTER

            lda TIMER           ; Die TIMER-Variable nimmt die Werte 0 und 3 an
            eor #%00000011      ; umgeschaltet alle 1/50 Sekunde
            sta TIMER

            ldx #2              ; Animation des Raumschiffantriebs:
animate     lda PROPULSION,x    ; Wir modifizieren die 3 mittleren Bytes des zweiten Spielers
            eor #%11000000      ; indem wir die 2 höchstwertigen Bits umkehren (d.h. 2 Pixel von links)
            sta PROPULSION,x
            dex
            bpl animate         ; springe, wenn Ergebnis positiv, d.h. die Schleife führt sich 3-mal aus

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
