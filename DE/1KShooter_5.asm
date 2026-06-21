
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
            PCOLR2 = $2c2             ; Farbe/Helligkeit des dritten Spielers/Geschosses
            CHBAS  = $2f4             ; Zeichensatzadresse (höherwertiges Byte)
            HPOSP0 = $d000            ; Horizontale Position des ersten Spielers (Schreiben)
            HPOSP1 = $d001            ; Horizontale Position des zweiten Spielers (Schreiben)
            P0PF   = $d004            ; Kollisionserkennung des ersten Spielers
            HPOSM2 = $d006            ; Horizontale Position des dritten Geschosses (Schreiben)
            M2PF   = $d002            ; Kollisionserkennung des dritten Geschosses
            SIZEM  = $d00c            ; Breite der Geschosse (Schreiben)
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
            HSCROL = $d404            ; Horizontales Scrollen in Pixeln (Register, nur Schreiben)
            PMBASE = $d407            ; Zeiger auf den Speicherbereich für P/M-Grafik
            NMIEN  = $d40e            ; Konfiguration der nicht maskierbaren Interrupts
            WSYNC  = $d40a            ; Warte auf horizontale Synchronisation
                                      ; Schreiben in dieses Register hält den 6502 an
            PMBASEADR = $3000         ; P/M-Datenadresse
            MDATA   = PMBASEADR+$180  ; Geschossdatenadresse
            PMDATA1 = PMBASEADR+$200  ; Datenadresse des ersten Spielers
            PMDATA2 = PMBASEADR+$280  ; Datenadresse des zweiten Spielers
            PMSHAPESIZE = PMSHAPE2-PMSHAPE1+1 ; Spielergröße (in Bytes)
            STARTPOSH = 60            ; Anfangshorizontalposition des Schiffes
            STARTPOSV = 56            ; Anfangsvertikalposition des Schiffes
            ANTICMODE = $57+$80       ; Standard-ANTIC-Modus
            WIDTH = 32                ; Breite des virtuellen Bildschirms (in Zeichen)
            BGCOL = 12                ; Anzahl der Hintergrundzeilen zum Einfärben im DLI
            LINES = 8                 ; Anzahl der gescrollten Zeilen in der DL
            CLOCKS = 8                ; Anzahl der Pixel für sanftes Scrollen
            POSV = $80                ; Vertikale Position des Schiffes (oberer Rand)
            POSH = $81                ; Horizontale Position des Schiffes (linker Rand)
            M2POSV = $82              ; Vertikale Position des Geschosses
            M2POSH = $83              ; Horizontale Position des Geschosses
            MVSRCE = $84              ; Quelladresse (2 Bytes) für die Datenkopier-Prozedur
            MVDEST = $86              ; Zieladresse (2 Bytes) für die Datenkopier-Prozedur
            LENPTR = $88              ; Länge des zu kopierenden Datenblocks (in Bytes)
            BGCOUNTER = $89           ; Hintergrundfarbzähler
            CHRADR = $8a              ; Zeiger auf Zeichen (2 Bytes)
            LMSV   = $8c              ; Zeiger auf Bildspeicher (2 Bytes)
            SPEED  = $8e              ; Scrollgeschwindigkeit des Bildes
            TIMER  = $8f              ; Variable zur Synchronisation des Codes mit VBI-Interrupts
            SHOTSPEED = $90           ; Geschossgeschwindigkeit (in Pixeln pro Bildschirmaktualisierung)

            org $91
VBIFLAG     .byte 1                   ; Flag, die das Scrollen des Bildes in Interrupts erlaubt
SHOTFIRED   .byte 0                   ; Geschoss abgefeuert (Flag)
SCROLLPOS   .byte 0                   ; Horizontales Scrollen in Pixeln
SCROLLCOUNT .byte 0                   ; Zähler der (grob) gescrollten Zeichen

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

GAMEOVERTXT .byte "GAME OVER"

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

HIGHTXT     .byte "HIGH"
SCORETXT    .byte "SCORE:0000"

            org $2000

start       lda #%00101011       ; ‭aktives DMA für DL und P/M + 2-Linien-P/M +‬ breiter Bildschirm
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
            sta SPEED            ; anfängliche Scrollgeschwindigkeit des Bildes (=1)

            lda #3
            sta PCOLR1           ; setze Farbe des zweiten Spielers (dunkelgrau)
            sta GRACTL           ; aktiviere P/M
            sta SHOTSPEED        ; setze Geschossgeschwindigkeit
            lda #8
            sta PCOLR0           ; setze Farbe des ersten Spielers (hellgrau)
            asl                  ;  8 x 2 = 16 (0x10)
            sta SIZEM            ; setze Geschossbreite (auf doppelt)
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

            ldy #9
resetscore  lda SCORETXT,y       ; kopiere den Text "SCORE:0000"
            sta line10+2,y       ; in die Spielstatuszeile
            dey
            bpl resetscore

main        lda P0PF            ; ist eine Kollision des ersten Spielers aufgetreten?
            sta VBIFLAG         ; 0 = Erlaubnis zum Scrollen des Bildes
            beq highscore       ; wenn nicht, setzen wir das Spiel fort

gameover    lda #0              ; wenn ja: Game Over
            sta AUDC2           ; deaktiviere Schussgeräusch
            lda #214            ; verschiebe das Geschoss aus dem sichtbaren Bereich
            sta HPOSM2          ; schreibe Wert 214 in das Horizontalpositionsregister des Geschosses
            sta M2POSH          ; aktualisiere die Variable, die die horizontale Geschossposition speichert
            lda #$8f
            sta AUDC1           ; setze Tonverzerrung
            sta RTCLOK          ; setze Uhr

waitsound   lda RTCLOK          ; spiele den Absturzton des Raumschiffs
            sta AUDF1           ; für ca. 2 Sekunden (255-143=112 Bildwiederholungen)
            sta PCOLR0          ; und ändere die Farbe des ersten Spielers (Flimmereffekt)
            bne waitsound       ; bis RTCLOK den Wert 0 erreicht
            sta AUDC1           ; danach deaktiviere Ton

            ldy #9
textend     lda GAMEOVERTXT,y   ; kopiere den Text "GAME OVER"
            sta line10+2,y      ; in die Spielstatuszeile
            dey
            bpl textend

            jmp restart

highscore   tay                 ; A=0, weil keine Kollision (P0PF)
checkhigh   lda line10+8,y      ; hole die nächste Stelle des Ergebnisses (beginnend bei den Tausenden)
            cmp line10+18,y     ; vergleiche sie mit der entsprechenden Hi-Score-Stelle
            bcc prepmove        ; Ende der Prüfung, wenn die aktuelle Ergebnisziffer kleiner ist
            bne sethigh         ; wenn die aktuelle Ergebnisziffer größer ist, haben wir Hi-Score
            iny                 ; andernfalls sind beide Ziffern gleich
            cpy #2              ; also prüfe weiterhin die nächsten Stellen (Hunderte und Zehner)
            bne checkhigh
sethigh     ldy #4              ; wenn Hi-Score <= Score
copyscore   lda line10+7,y      ; kopiere den aktuellen Punktestand (Score)
            sta line10+17,y     ; zusammen mit dem vorangestellten Zeichen ":" zum Hi-Score
            dey                 ; z.B. ":1710"
            bpl copyscore
            ldy #3
hightext    lda HIGHTXT,y
            sta line10+13,y     ; kopiere den Text "HIGH"
            dey                 ; in die Spielstatuszeile
            bpl hightext

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

movem       lda SHOTFIRED       ; wurde ein Geschoss abgefeuert?
            beq noshot

            lda #<MDATA         ; wenn ja, hole das niederwertige Byte der P/M-Datenadresse des Geschosses
            clc
            adc M2POSV          ; addiere die vertikale Position des Geschosses dazu
            sta MVDEST          ; setze das niederwertige Byte der Zieladresse (wohin)
            lda #>MDATA         ; hole das höherwertige Byte der P/M-Datenadresse des Geschosses
            sta MVDEST+1        ; setze das höherwertige Byte der Zieladresse (wohin)
            ldy #00
            lda MSHAPE          ; kopiere Geschossdaten (1 Byte)
            sta (MVDEST),y      ; an die Adresse MDATA+M2POSV

            lda M2POSH          ; lade die aktuelle horizontale Position des Geschosses
            sta HPOSM2          ; schreibe sie in das Horizontalpositionsregister des Geschosses
            sta PCOLR2          ; das Geschoss ändert die Farbe während des Fluges
            sbc POSH            ; subtrahiere die horizontale Position des Raumschiffs davon
            sta AUDF2           ; je größer der Abstand, desto niedriger die Tonfrequenz
            lda #$6a
            sta AUDC2           ; setze Tonverzerrung, die einem Geschossgeräusch ähnelt
noshot

            lda TIMER           ; hole den Wert der TIMER-Variable
wait        cmp TIMER           ; hat er sich geändert?
            beq wait            ; wenn nicht, warte weiter

            lda STRIG0          ; ist FIRE gedrückt?
            bne checkmove
            jsr shot            ; wenn ja, schieße
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

            lda SCROLLCOUNT     ; lade den Zähler der grob gescrollten Zeichen
            cmp #8              ; haben wir bereits 8 Zeichen gescrollt?
            bne checkshot       ; wenn nicht, Spielfortsetzung ab Marke checkshot

            lda #0              ; wir bereiten den Bildspeicher vor
            sta SCROLLCOUNT     ; setze Zähler der gescrollten Zeichen zurück
            lda CHBAS           ; lade das höherwertige Byte der Zeichensatzadresse
            clc
            adc #2              ; addiere 2 dazu (der Zeichensatz belegt 4 Seiten)
            sta CHRADR+1        ; und speichere das Ergebnis im höherwertigen Byte des Zeichenzeigers
            lda RANDOM          ; hole Zufallswert von 0-255
            and #%11111000      ; die Maske stellt sicher, dass der Wert durch 8 teilbar ist
                                ; d.h. es ist die Adresse eines der 32 Zeichen auf der 3. Seite des Zeichensatzes
            sta CHRADR          ; speichere das Ergebnis im niederwertigen Byte des Zeichenzeigers

            lda LMS1            ; lade das niederwertige Byte der Datenadresse der ersten Zeile
            clc
            adc #24             ; addiere 24 dazu (Anzahl der Zeichen in einer Zeile)
            sta LMSV            ; und speichere es in LMSV
            lda LMS1+1          ; lade das höherwertige Byte der Adresse der ersten Zeile
            adc #0              ; addiere 0 dazu (unter Berücksichtigung des Carry-Flags)
            sta LMSV+1          ; und speichere es in LMSV+1

            ldy #0              ; setze Register Y zurück

nextbyte    ldx #8              ; schreibe 8 in X (Bitzähler in der Zeichenlinie)
            lda (CHRADR),y      ; hole das nächste Byte (Zeile) der Zeichendefinition

nextbit     asl                 ; verschiebe Pixel um 1 Bit nach links (Bit 7 -> Carry)
            pha                 ; lege Akkumulator auf den Stack
            bcc setblank
            lda #"O"            ; wenn das Carry-Flag gesetzt war
            bcs checkbit        ; lade internen Code "0" und springe zu checkbit
setblank    lda #" "            ; andernfalls lade internen Code " "
checkbit    sta (LMSV),y        ; schreibe "0" oder " " an die Adresse LMSV+Y
            inc LMSV            ; verschiebe LMSV-Zeiger um 1 Byte nach rechts
            bne singlebyte2
            inc LMSV+1          ; unter Berücksichtigung eines eventuellen Übertrags
singlebyte2 pla                 ; hole Akkumulator vom Stack
            dex                 ; wir zählen herunter
            bne nextbit         ; ist das bereits das 8. Bit (in dieser Zeile)?

            lda LMSV            ; lade das niederwertige Byte des LMSV-Zeigers
            clc                 ; verschiebe ihn auf den Anfang der nächsten Zeile
            adc #WIDTH*2-9      ; unter Kompensierung des wachsenden Werts von Register Y (-1 Byte)
            bcc singlebyte      ; und unter Berücksichtigung eines eventuellen Übertrags
            inc LMSV+1
singlebyte  sta LMSV

            iny                 ; nächstes Byte (Zeile) der Zeichendefinition
            cpy #8              ; ist das die letzte Zeile im Zeichen?
            bne nextbyte        ; wenn nicht, springe zu nextbyte

checkshot   lda SHOTFIRED       ; wurde ein Geschoss abgefeuert?
            bne delchar
            jmp endofmain       ; wenn nicht, springe zum Ende der Hauptschleife

delchar     lda M2PF            ; Geschoss ist unterwegs, prüfe das Kollisionsregister des Geschosses
            beq nocoll

            lda M2POSH          ; Geschoss hat etwas getroffen, lade horizontale Position des Geschosses
            sec
            sbc #30             ; subtrahiere Offset ($1E) davon
            sbc SCROLLPOS       ; subtrahiere die Anzahl der gescrollten Pixel
            lsr                 ; und teile durch 8 (2*2*2)
            lsr
            lsr                 ; das Ergebnis ist die horizontale Position des zu löschenden Zeichens
            tay                 ; speichere das Ergebnis in Register Y

            lda M2POSV          ; lade die vertikale Position des Geschosses
            sec
            sbc #31             ; subtrahiere Offset ($1F) davon
            lsr                 ; und teile durch 8 (2*2*2)
            lsr
            lsr                 ; das Ergebnis ist die vertikale Position des zu löschenden Zeichens
            tax                 ; speichere das Ergebnis in Register X

            lda LMS1            ; hole das niederwertige Byte der Adresse der ersten Spielfeldzeile
            sta LMSV            ; und speichere es in LMSV
            lda LMS1+1          ; hole das höherwertige Byte der Adresse der ersten Spielfeldzeile
            sta LMSV+1          ; und speichere es in LMSV+1
            cpx #0              ; wenn das zu löschende Zeichen in der ersten Zeile liegt
            beq clearchar       ; dann sind wir bereit
nextline    lda LMSV            ; andernfalls verschieben wir den LMSV-Zeiger
            clc                 ; auf den Anfang der Bilddaten der Zeile
            adc #WIDTH*2        ; in der sich das zu löschende Zeichen befindet
            bcc onebyte
            inc LMSV+1          ; Übertrag beim Addieren
onebyte     sta LMSV
            dex
            bne nextline        ; am Ende der Schleife haben wir 0 in Register X

clearchar   lda #" "            ; lade den internen Code des Leerzeichens (0)
            sta (LMSV),y        ; und schreibe es in den Bildspeicher an der Position des zu löschenden Zeichens

            ldy #2              ; zähle 10 Punkte für jedes abgeschossene Zeichen
scoreloop   lda line10+8,y      ; wir manipulieren direkt die Bildschirmdaten
            clc                 ; an der Adresse line10+8+2 befindet sich die Zehnerstelle
            adc #1              ; wir addieren 1 zum Code und prüfen den Übertrag
            cmp #":"            ; ist das der Code des Zeichens ":"? (das nächste nach der Ziffer "9")
            bne writescore
            lda #"0"            ; es gibt einen Übertrag, also schreibe die Ziffer "0"
            sta line10+8,y      ; an der Stelle ":"
            dey                 ; gehe zur bedeutenderen Stelle der Spielpunktzahl
            bpl scoreloop       ; addiere 1 dazu (in der nächsten Iteration)
writescore  sta line10+8,y      ; schreibe die um 1 erhöhte Ziffer an der aktuellen Position
            cpy #0              ; wenn das die Tausenderstelle ist
            bne resmissile
            cmp #"1"            ; dann prüfe, ob eine Änderung von "0" auf "1" stattgefunden hat
            bne resmissile
            stx SPEED           ; wenn ja, erhöhe die Scrollgeschwindigkeit (X=0)
            inc SHOTSPEED       ; und erhöhe die Geschossgeschwindigkeit

resmissile  lda #211            ; verschiebe das Geschoss aus dem sichtbaren Bereich
            sta M2POSH          ; aktualisiere die Variable, die die horizontale Geschossposition speichert
            sta HITCLR          ; lösche P/M-Kollisionsregister

nocoll      lda M2POSH          ; lade die horizontale Position des Geschosses
            clc
            adc SHOTSPEED       ; addiere die Geschossgeschwindigkeit dazu
            sta M2POSH          ; aktualisiere die Variable, die die horizontale Geschossposition speichert
            cmp #212            ; hat das Geschoss die rechte Seite des Bildschirms erreicht?
            bcc endofmain       ; wenn noch nicht, dann springe zum Ende der Hauptschleife
            lda #0              ; das Geschoss ist auf der rechten Seite verschwunden
            sta AUDC2           ; deaktiviere Schussgeräusch
            sta SHOTFIRED       ; setze Flag SHOTFIRED=0 zurück (kein Geschoss)
            ldy #$80            ; lösche in einer Schleife die P/M-Daten des Geschosses (128 Bytes)
clearm      sta MDATA,y
            dey
            bne clearm

endofmain
            jmp main            ; die Hauptschleife des Spiels beginnt bei der Marke main

shot        lda SHOTFIRED       ; prüfe, ob das Geschoss bereits unterwegs ist
            cmp #1
            bne contshot
            rts                 ; wenn ja, Rückkehr
contshot    inc SHOTFIRED       ; wenn nicht - setze Flag SHOTFIRED=1
            lda POSV            ; lade die vertikale Position des Schiffes
            clc
            adc #6              ; addiere die Zahl 6 (die Kanone befindet sich in der Mitte des Schiffes)
            sta M2POSV          ; speichere die so berechnete vertikale Position des Geschosses
            lda POSH            ; hole die horizontale Position des Schiffes
            sta M2POSH          ; und speichere sie als horizontale Position des Geschosses
            rts

move        ldy #0              ; Prozedur zum Kopieren von LENPTR Bytes von MVSRCE nach MVDEST
            sty MVSRCE+1        ; die zu kopierenden Daten befinden sich auf Seite Null
            ldx LENPTR          ; die Prozedur kopiert maximal 255 Bytes
mvlast      lda (MVSRCE),y      ; von MVSRCE
            sta (MVDEST),y      ; nach MVDEST
            iny
            dex                 ; Register X ist der Schleifenzähler
            bne mvlast
mvexit      rts

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

            lda VBIFLAG         ; haben wir die Erlaubnis zum Scrollen des Bildes?
            bne exitvbi         ; wenn nicht, verlasse den Interrupt

            lda SCROLLPOS       ; lade die aktuelle horizontale Position (sanftes Scrollen)
            sta HSCROL          ; schreibe sie in das Hardware-Register
            lda TIMER           ; lade die TIMER-Variable (0-3-0-3, usw.)
            and SPEED           ; AND mit der SPEED-Variable: Wert 1=langsam oder 0=schnell
            bne exitvbi         ; Wenn SPEED=1, überspringe jeden zweiten Interrupt (wenn TIMER=3)
            dec SCROLLPOS       ; verringere die Anzahl der zu scrollenden Pixel um 1
            bpl exitvbi         ; wenn der Wert nicht negativ ist, verlasse den Interrupt

setmove     lda LMS1            ; lade das niederwertige Byte der Bilddatenadresse der ersten Zeile
            cmp <line2+WIDTH    ; vergleiche es mit dem niederwertigen Byte der Adresse des Zeichens
                                ; direkt nach der ersten Zeile im Bildspeicher
            bne coarsescrol     ; wenn sie verschieden sind, setzen wir das grobe Scrollen fort

; wenn LMS1 gleich LMSC ist, bedeutet das, dass wir die Bilddaten vollständig gescrollt haben
; und es ist Zeit, für jede Zeile die LMS-Operanden neu zu laden (um WIDTH zu verringern)
; und ihren Bildspeicher an die neue Adresse zu kopieren

            ldx #(LINES-1)*3    ; lade in X 21 = (Zeilenanzahl-1)*3 Bytes pro Zeile

rollover    lda LMS1+1,x        ; hole das höherwertige Byte der Bilddatenadresse der Zeile X/3
            sta MVSRCE+1        ; speichere es in MVSRCE+1
            lda LMS1,x          ; hole das niederwertige Byte der Bilddatenadresse der Zeile X/3
            sta MVSRCE          ; speichere es in MVSRCE
            sec
            sbc #WIDTH          ; subtrahiere WIDTH (Breite des virtuellen Bildschirms)
            bcs byteonly        ; unter Berücksichtigung des Übertrags
            dec LMS1+1,x
byteonly    sta LMS1,x          ; speichere das Ergebnis in der Bilddatenadresse der Zeile X/3
            sta MVDEST          ; sowie in der Variable MVDEST
            lda LMS1+1,x
            sta MVDEST+1

            ldy #WIDTH-1        ; lade WIDTH-1 in Y (Schleifenzähler)
mirror      lda (MVSRCE),y      ; kopiere Bilddaten
            sta (MVDEST),y      ; um 32 Bytes zurück
            dey
            bpl mirror

            dex                 ; die Definition der Spielfeldzeilenbesteht aus 3 Bytes:
            dex                 ; einem ANTIC-Befehl (1 Byte) und 2 Adress-Bytes
            dex                 ; indem wir X um 3 verringern, gehen wir zur höheren Zeile
            bpl rollover        ; wenn X nicht negativ ist, modifizieren wir die nächste Zeile

coarsescrol inc SCROLLCOUNT     ; grobes Scrollen, wir manipulieren die DL!!!
            ldx #(LINES-1)*3    ; lade in X 21 = (Zeilenanzahl-1)*3 Bytes pro Zeile
                                ; für jede der 8 Spielfeldzeilen (beginnend von unten)
nextcs      inc LMS1,x          ; wir erhöhen das niederwertige Byte der LMS-Adresse um 1
            bne done            ; d.h. die Bildspeicheradresse für die jeweilige Zeile
            inc LMS1+1,x        ; wir berücksichtigen einen eventuellen Übertrag
done        dex                 ; die Definition der Spielfeldzeilen besteht aus 3 Bytes:
            dex                 ; einem ANTIC-Befehl (1 Byte) und 2 Adress-Bytes
            dex                 ; indem wir X um 3 verringern, gehen wir zur höheren Zeile
            bpl nextcs          ; wenn X nicht negativ ist, modifizieren wir die nächste Zeile

            lda #CLOCKS         ; lade die Anzahl der Farb-Zyklen zum Scrollen (8)
            sta SCROLLPOS       ; setze die Anzahl der zu scrollenden Pixel
            sta HSCROL          ; schreibe es in das Hardware-Register
            dec SCROLLPOS       ; verringere die Anzahl der zu scrollenden Pixel um 1

exitvbi     jmp $e45f           ; SYSVBV

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
