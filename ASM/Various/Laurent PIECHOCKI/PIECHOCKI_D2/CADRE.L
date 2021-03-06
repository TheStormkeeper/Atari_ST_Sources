
               TEXT

               INCLUDE       "LINEQU.L"
               INCLUDE       "INIT_TOS.L"
               INCLUDE       "MACROS.L"

               SETBLOCK

               DC.W          $A000
               movea.l       a0,a5

               move.l        #CONTROL,ticontrol(a0)
               move.l        #INTIN,tiintin(a0)
               move.l        #PTSIN,tiptsin(a0)
               move.l        #INTOUT,tiintout(a0)
               move.l        #PTSOUT,tiptsout(a0)

               PRINTLINE     CADRE
               WAIT
               DC.W          $A00A
               CCONOUT       #27
               CCONOUT       #'E'

               move          #1,_fg_bp_1(a5)
               move          #1,_fg_bp_2(a5)
               move          #0,_wrt_mode(a5)
               move          #1,_patmsk(a5)
               move.l        #LIGNE,_patptr(a5)
               move          #%1111111111111111,_ln_mask(a5)

               move          #0,d5
               move          #22,d6

BOUCLE         move          #0,_x1(a5)
               move          d5,_y1(a5)
               move          #630,_x2(a5)
               move          d5,_y1(a5)
               add           #9,d5
               DC.W          $A004
               dbf           d6,BOUCLE

               move          #0,d5
               move          #42,d6


LOOP           move          d5,_x1(a5)
               move          #0,_y1(a5)
               move          d5,_x2(a5)
               move          #197,_y2(a5)
               add           #15,d5
               DC.W          $A003
               dbf           d6,LOOP

               WAIT
               TERM

               DATA

LIGNE          DC.W          %1111111111111111
               DC.W          %1111111111111111

CADRE          DC.B          27,'E','Je vais tracer un quadrillage ...'
               DC.B          13,10,'Fonctions LINE et H-LINE :',0

               BSS

               INCLUDE       "TABLEAU.L"

               END


 