* L�schen eines Bildschirmbereiches
* Aufruf clearscreen(logbase,ystart,yend)
* <logbase> steht f�r die logische Bildschirmbasis
* <ystart> steht f�r die erste zu l�schende Zeile, <yend> f�r die letzte

.text
.xdef _clearscreen
_clearscreen:           movem.l d0-d7/a0-a3,-(a7) *Register retten
                        movea.l 52(a7),a0         *Zeiger auf Bildschirmseite
                        move.w  #58(a7),d0        *y2_Wert laden
                        addq.w  #1,d0             *Um 1 erh�hen
                        mulu    #160,d0           *Zeile berechnen
                        adda.l  d0,a0             *Adresse berechnen
                        move.w  58(a7),d0         *y2_Wert
                        sub.w   56(a7),d0         *y2_Wert - y1_Wert
                        addq.w  #1,d0             *Zahl der zu l�sch. Zeilen
                        asl.w   #2,d0             *Zahl der L�schoperationen
                        sub.w   #1,d0             *Da dbra-Bef.(Abbruch bei -1)

                        moveq   #0,d1              *Register l�schen
                        moveq   #0,d2
                        moveq   #0,d3
                        moveq   #0,d4
                        moveq   #0,d5
                        moveq   #0,d6
                        moveq   #0,d7
                        clr.l   a1
                        clr.l   a2
                        clr.l   a3

clscr_j1:               movem.l d1-d7/a1-a3,-(a0) *L�schen von 40 Bytes
                        dbra    d0,clscr_j1       *In Schleife

                        movem.l (a7)+,d0-d7/a0-a3 *Register holen
                        rts
