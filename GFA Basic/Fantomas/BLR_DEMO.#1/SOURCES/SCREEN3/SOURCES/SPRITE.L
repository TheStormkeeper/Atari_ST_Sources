 move.l 4(sp),d0
 move.l 8(sp),d1
 move.l 12(sp),a1
 lea donnees(pc),a0
 mulu #160,d1
 move.w d0,d7
 and.l #15,d7
 lsr #1,d0
 andi #$F8,d0
 add.w d0,d1
 adda.l d1,a1
 move.w #15,d4
sprite:
 movem.l (a0)+,d0-d3
 ror.l d7,d0
 ror.l d7,d1
 ror.l d7,d2
 ror.l d7,d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 swap d0
 swap d1
 swap d2
 swap d3
 and d3,(a1)
 or d0,(a1)+
 and d3,(a1)
 or d1,(a1)+
 and d3,(a1)
 or d2,(a1)+
 and d3,(a1)+
 adda.l #144,a1
 dbra d4,sprite
 rts
donnees:
 dc.l $FFFF,$C000,$3FFF,$ffff0000
 dc.l $8001,$FFFE,$7FFF,$ffff0000
 dc.l $8001,$7FFE,$FFFF,$ffff0000
 dc.l $9FFF,$6000,$FFFF,$ffff0000
 dc.l $9001,$6FFE,$FFFF,$ffff0000
 dc.l $9001,$6FFE,$FFFF,$ffff0000
 dc.l $93FF,$6C00,$FFFF,$ffff0000
 dc.l $9201,$6DFE,$FFFF,$ffff0000
 dc.l $9201,$6DFE,$FFFF,$ffff0000
 dc.l $927F,$6D80,$FFFF,$ffff0000
 dc.l $9241,$6DBE,$FFFF,$ffff0000
 dc.l $9241,$6DBE,$FFFF,$ffff0000
 dc.l $9241,$6DBE,$FFFF,$ffff0000
 dc.l $9241,$6DBE,$FFFF,$ffff0000
 dc.l $9241,$6DBE,$FFFF,$ffff0000
 dc.l $FFFF,$0000,$FFFF,$ffff0000
 end

 