; MACROS pour le TIMER A et le TIMER B

               TEXT

TIMERA         MACRO         $\1,$\2,$\3
               and.b         #%11011111,$FFFA13
               and.b         #%11011111,$FFFA0F
               and.b         #%11011111,$FFFA0B
               and.b         #%11011111,$FFFA07
               pea           \1
               move.w        #\2,-(sp)
               move.w        #\3,-(sp)
               move.w        #0,-(sp)
               move.w        #$1F,-(sp)
               trap          #14
               adda.l        #12,sp
               or.b          #%100000,$FFFA07
               or.b          #%100000,$FFFA13
               ENDM


 
TIMERB         MACRO         $\1,$\2,$\3
               and.b         #%11111110,$FFFA13
               and.b         #%11111110,$FFFA0F
               and.b         #%11111110,$FFFA0B
               and.b         #%11111110,$FFFA07
               pea           \1
               move.w        #\2,-(sp)
               move.w        #\3,-(sp)
               move.w        #1,-(sp)
               move.w        #$1F,-(sp)
               trap          #14
               adda.l        #12,sp
               or.b          #%1,$FFFA07
               or.b          #%1,$FFFA13
               ENDM

     
STOPTIMEA      MACRO
               move.w        #13,-(sp)
               move.w        #26,-(sp)
               trap          #14
               addq.l        #4,sp
               ENDM

STOPTIMEB      MACRO
               move.w        #8,-(sp)
               move.w        #26,-(sp)
               trap          #14
               addq.l        #4,sp
               ENDM

               END
 