***********************************
*	ZOOMER ROUTINE by 	  *
*      Cristalion/Hydroxid        *
*    the ....... 		  *
***********************************
;reste un bug avec decalage des bits ...

;pour le facteur on prend comme point de repere 320,ok ???
xfacteur=	320
yfacteur=	320
largeur=	319
hauteur=	51

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	INITS
	BSR	MAKE_PAL
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	bsr	VBL
	CLR.W	$FFFF8240
	BSR	EFFA
	BSR	ZOOMMM
	CMPI.B	#56,$FFFFC02
*	BNE.S	NO_SHIFT
*	ADDQ.W	#4,FACTEUR
NO_SHIFT
*	MOVE.W	#$5,$FFFF8240
*	MOVE.W	#7,-(SP)
*	TRAP	#1
*	ADDQ.L	#2,SP 
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP
	BRA	FIN
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		*
	MOVE.W	#88,-(SP)		*
	TRAP	#14			*
	ADDQ.L	#4,SP			*
	MOVE.W	D0,OLDMODECODE		*

	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$9B00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS
***********************SOUS ROUTINES****************************************************
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
AFF_IMG
	MOVE.L	AFFECR,A0
	LEA	IMAGE+34,A1
	MOVE.W	#7999,D1
OK
	MOVE.L	(A1)+,(A0)+
	DBF	D1,OK
	RTS
MAKE_PAL
	MOVE.L	#$FFFF8240,A0
	MOVEQ	#15,D1
	LEA	IMAGE+2,A1
PAL
	BSR	VBL
	MOVE.W	(A1)+,(A0)+
	DBF	D1,PAL
	RTS
EFFA
	MOVEM.L	A1/D1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ.W	#0,D0
	MOVEQ.W	#60,D1	
.EFF
	REPT	80
	MOVE.W	D0,(A1)+
	ENDR 	
	DBF	D1,.EFF	
	MOVEM.L	(SP)+,A1/D1
	RTS	
********************ZZZOOOOOOOOOOOOOOOOOOOOOOOMMMMMMMMMMMMMMMMMM**********************************
ZOOMMM
;on prend les addresses de base(A5,A6,D1,D2)
	LEA	IMAGE+34,A5
	MOVE.L	AFFECR,A6
	MOVE.W	#xfacteur,D1	;D1 compteur pour x
	MOVE.W	#yfacteur,D2	;D2 compteur pour y
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
	MOVEQ	#hauteur,D4	;D4 fait 40 lignes
	MOVEQ	#0,D5		;D5 compteur pour numero du pts image
	MOVEQ	#0,D6		;D6 .......... ecran		
;on fait le zoom
ZOOMER_Y
	ADD.W	#yfacteur,D2	
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
	CMPI.W	#320,D2
	BLE	ZOOMER_X1
	LEA	160(A6),A6	;ligne ecran suivante
	SUBI.W	#320,D2
	MOVEM.L	D2/D4,-(SP)
	MOVE.L	#0,D2
	MOVE.L	#0,D4
ZOOMER_X
	ADD.W	#xfacteur,D1	
	CMPI.W	#320,D1		;si facteur>320 affiche le point
	BLE.S	NO_POINT
	BSR	MAKE_POINT
	ADDQ.W	#1,D6		;point ecran suivant
	SUBI.W	#320,D1
NO_POINT
	ADDQ.W	#1,D5		;point image suivant
	DBF	D3,ZOOMER_X
	MOVEM.L	(SP)+,D2/D4
ZOOMER_X1
	MOVEQ	#0,D5		;remise a 0 pour nouvelle ligne
	MOVEQ	#0,D6		;remise a 0 pour nouvelle ligne
	LEA	160(A5),A5	;ligne image suivante
	DBF	D4,ZOOMER_Y
	RTS

;procedure chargee de voir quel point il faut afficher
MAKE_POINT
; conversion de coordonnees en adresse ecran
; les x	
	MOVE.W	D5,D2
	MOVE.W	D5,D7
	LSR.W	D2
	ANDI.W	#$FFF8,D2
; le decalage
	ANDI.W	#$F,D7			; decalage sur 16 pixels	
	LSL.W	#2,D7
	JMP	DECA_TAB(PC,D7.W)
DECA_TAB
	BRA	DECA0
	BRA	DECA1
	BRA	DECA2
	BRA	DECA3
	BRA	DECA4
	BRA	DECA5
	BRA	DECA6
	BRA	DECA7                                     
	BRA	DECA8
	BRA	DECA9
	BRA	DECA10
	BRA	DECA11
	BRA	DECA12
	BRA	DECA13
	BRA	DECA14
	BRA	DECA15
DECA0
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%10000000000000001000000000000000,D7
	ANDI.L	#%10000000000000001000000000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA1
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%01000000000000000100000000000000,D7
	ANDI.L	#%01000000000000000100000000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA2
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00100000000000000010000000000000,D7
	ANDI.L	#%00100000000000000010000000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA3
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00010000000000000001000000000000,D7
	ANDI.L	#%00010000000000000001000000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA4
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00001000000000000000100000000000,D7
	ANDI.L	#%00001000000000000000100000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA5
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000100000000000000010000000000,D7
	ANDI.L	#%00000100000000000000010000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA6
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000010000000000000001000000000,D7
	ANDI.L	#%00000010000000000000001000000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA7
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000001000000000000000100000000,D7
	ANDI.L	#%00000001000000000000000100000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA8
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000100000000000000010000000,D7
	ANDI.L	#%00000000100000000000000010000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA9
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000010000000000000001000000,D7
	ANDI.L	#%00000000010000000000000001000000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA10
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000001000000000000000100000,D7
	ANDI.L	#%00000000001000000000000000100000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA11
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000100000000000000010000,D7
	ANDI.L	#%00000000000100000000000000010000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA12
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000010000000000000001000,D7
	ANDI.L	#%00000000000010000000000000001000,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA13
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000001000000000000000100,D7
 	ANDI.L	#%00000000000001000000000000000100,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA14
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000000100000000000000010,D7
	ANDI.L	#%00000000000000100000000000000010,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
DECA15
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000000010000000000000001,D7
	ANDI.L	#%00000000000000010000000000000001,D4
	MOVE.W	D6,D0
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
*******************c'est FI-NI********************************************************************

FIN	
	CLR.L	$4D2
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

		SECTION	DATA
IMAGE		INCBIN	"E:\GRAPHS\HYDROXID.PI1\SAYA\1123.PI1"
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
*FACTEUR		DC.W	2

		SECTION BSS
	DS.L 2000
PILE	DS.L 10
	END
	 																																																																						 	 			