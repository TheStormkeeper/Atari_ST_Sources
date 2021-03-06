;HI THERE! THIS IS THE WILD BOYS
;FIRST EVER DEMO! IF YOU WANT TO
;SEND ME GRAFIX OR MUZIX, OR WANT
;TO WRITE TO ME, HERE'S MY ADDRESS;
;
;   THE WILD BOYS
;   131 GUNNERSBURY AVENUE
;   ACTON W3 8LE
;   LONDON
;NOW, THE SOURCE CODE!  


    	JSR INIT		;INITIALISE
	JSR CONVERT		;CONVERT TEXT
	JSR SETUP2		;SET UP DATA
	MOVE.W #$777,$FFFF8244.W
	JSR TWB			;DRAW SOUND CHANNEL FLASHER GRAFIX
	JSR DO_LOGO		;DRAW LOGO
	JSR SETMUS		;START MUZIX
	MOVE.L #VBL,$70.W
	JSR WAIT	
	JMP END

DO_LOGO	LEA LOGO,A0
	LEA $78002+48,A1	;POSITION OF LOGO ON SCREEN
	MOVEQ.W #80-1,D0	;HEIGHT OF LOGO -1
.L2	MOVEQ.W #8-1,D1		;WIDTH IN 16 PIXEL STEPS -1
.L1	MOVE.L (A0)+,(A1)+	
	MOVE.W (A0)+,(A1)+
	ADDQ.W #2,A1
	DBF D1,.L1
	LEA 160-64(A1),A1	;NEXT LINE
	DBF D0,.L2
	RTS

VOICE	LEA $FFFF8800.W,A0
	MOVEQ.W #0,D0
	MOVEQ.W #0,D1
	MOVEQ.W #0,D2
	MOVE.B #8,(A0)		;GET CHANNEL A VOLUME
	MOVE.B (A0),D0
	MOVE.B #9,(A0)		;GET CHANNEL B VOLUME
	MOVE.B (A0),D1
	MOVE.B #10,(A0)		;GET CHANNEL C VOLUME
	MOVE.B (A0),D2
	BTST #4,D0		;IS IT AN ENVELOPE?
	BEQ .L1
	MOVE.B #10,D0		;IF IT IS,VOLUME=10
.L1	ADD.B D0,D0		;MULTIPLY BY 2 FOR WORD ALIGNMENT
	BTST #4,D1
	BEQ .L2
	MOVE.B #10,D1
.L2	ADD.B D1,D1
	BTST #4,D2
	BEQ .L3
	MOVE.B #10,D2
.L3	ADD.B D2,D2
	LEA COLS1,A0
	LEA COLS2,A1
	LEA COLS3,A2
	LEA (A0,D0.W),A0
	LEA (A1,D1.W),A1
	LEA (A2,D2.W),A2
	MOVE.L A0,VOICE1	;SET UP NEW COLOURS FOR EACH CHANNEL	
	MOVE.L A1,VOICE2
	MOVE.L A2,VOICE3
	RTS

TWB	LEA $78006+(160*162)+(6*8),A0	;DESTINATION ADDRESSES
	LEA $78002+(160*162)+(6*8)+24,A1
	LEA $78004+(160*162)+(6*8)+48,A2
	LEA FONT+(144*('T'-65)),A3	;SOURCE ADDRESSES
	LEA FONT+(144*('W'-65)),A4
	LEA FONT+(144*('B'-65)),A5
	MOVEQ.W #4-1,D0
	MOVEQ.L #0,D7
.L1	MOVEQ.W #36-1,D1
	MOVEM.L A0-A2,-(A7)
.L2	MOVE.B (A3)+,(A0)
	MOVE.B (A4)+,(A1)
	MOVE.B (A5)+,(A2)
	LEA 160(A0),A0
	LEA 160(A1),A1
	LEA 160(A2),A2
	DBF D1,.L2
	MOVEM.L (A7)+,A0-A2
	CMPI.L #1,D7		;IF D7=1,THEN ADD 1 TO DESTINATION ADDRESS
				 ;TO INCREASE BY 8 PIXELS(1 BYTE)
	BEQ .L3
	ADDQ.L #1,A0
	ADDQ.L #1,A1
	ADDQ.L #1,A2
	MOVE.L #1,D7
	DBF D0,.L1
	RTS	
.L3	ADDQ.L #7,A0		;IF D7 IS NOT 1,ADD 7 TO DESTINATION ADDRESS
				;TO BYPASS BITPLANES 2,3 AND 4
	ADDQ.L #7,A1
	ADDQ.L #7,A2
	MOVE.L #0,D7
	DBF D0,.L1
	RTS	
	
TB1	CLR.B $FFFFFA1B.W	;STOP TIMER B
	MOVE.L #TB,$120.W	;SET UP NEW INTERRUPT VECTOR
	MOVE.B #4,$FFFFFA21.W	;EVERY 4 SCANLINES, DO TIMER B INTERRUPT
	MOVE.B #8,$FFFFFA1B.W	;START TIMER B
	BCLR #0,$FFFFFA0F.W	;O.K CPU I'VE DONE THE TIMER B INTERRUPT
	RTE

PAL1	DC.W 0,0,0,0,0,0,$707,$706,$705,$704,$703,$702,$701,$700
	DC.W $710,$720,$730,$740,$750,$760,$770
	DC.W $670,$570,$470,$370,$270,$170,$070

PALST	DC.L PAL1+2

LOGOCOL	DC.L LCOL1
	DC.L LCOL2
	DC.L LCOL3
TIMER	DC.B 3,0
	DC.B 4,0
	DC.B 5,0
LCOL1	DC.W $505,$303,$404	;COLOURS FOR LOGO
	DC.W $606,$404,$505
	DC.W $707,$505,$606
	DC.W $717,$606,$707
	DC.W $727,$707,$717
	DC.W -1
LCOL2	DC.W $066,$033
	DC.W $077,$044
	DC.W $177,$055
	DC.W $277,$066
	DC.W $377,$077
	DC.W $477,$177
	DC.W $577,$277
	DC.W -1
LCOL3	DC.W $003,$001
	DC.W $004,$002
	DC.W $005,$003
	DC.W $006,$004
	DC.W $007,$005
	DC.W $117,$006
	DC.W $117,$007
	DC.W $227,$117
	DC.W -1

SHADE	SUBQ.B #1,TIMER		;ROUT. TO FLASH LOGO 
	BNE .L2
	MOVE.B #2,TIMER
	ADDQ.L #6,LOGOCOL
	MOVEA.L LOGOCOL,A0
	CMPI.W #-1,(A0)
	BNE .L2
	MOVE.L #LCOL1,LOGOCOL
.L2	SUBQ.B #1,TIMER+2
	BNE .L3
	ADDQ.L #4,LOGOCOL+4
	MOVE.B #3,TIMER+2
	MOVEA.L LOGOCOL+4,A0
	CMPI.W #-1,(A0)
	BNE .L3
	MOVE.L #LCOL2,LOGOCOL+4
.L3	SUBQ.B #1,TIMER+4
	BNE .L4
	ADDQ.L #4,LOGOCOL+8
	MOVE.B #5,TIMER+4
	MOVEA.L LOGOCOL+8,A0
	CMPI.W #-1,(A0)
	BNE .L4
	MOVE.L #LCOL3,LOGOCOL+8
.L4	RTS

VBL	CLR.B $FFFFFA1B.W
	MOVE.L #TB1,$120.W	;FIRST TIMER B VECTOR
	MOVE.B #30,$FFFFFA21.W
	MOVE.B #8,$FFFFFFA1B.W
	LEA $FFFF8240.W,A0
	LEA LOGOCOL,A2
	MOVEA.L (A2)+,A1
	CLR.W (A0)+
	MOVE.W PAL1,(A0)+
	MOVE.L #PAL1+2,PALST
	MOVE.W (A1)+,(A0)+
	MOVE.W (A1)+,2(A0)
	MOVE.W (A1)+,6(A0)
	MOVEA.L (A2)+,A1
	MOVE.W (A1)+,10(A0)
	MOVE.W (A1)+,14(A0)
	MOVEA.L (A2)+,A1
	MOVE.W (A1)+,18(A0)
	MOVE.W (A1)+,22(A0)	
	MOVE.B #33,COUNT
	MOVE.L #BARS,BARST
	JSR SCROLL
	MOVEA.L $4DA.W,A0
	JSR (A0)
	JSR VOICE
	JSR SHADE
	RTE

BARS	DC.W $400,$500,$600,$700,$600,$500,$400
	DC.W 0,0,0,0
	DC.W $040,$050,$060,$070,$060,$050,$040
	DC.W 0,0,0,0
	DC.W $004,$005,$006,$007,$006,$005,$004
	DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0
BARST	DC.L BARS

SCROLL	MOVEA.L TPOS,A0	    ;THE GOOD BIT,THE BYTE BENDER ROUT!
	LEA YPOS,A1
	MOVEA.L A1,A6
	MOVE.W #40-1,D1
.L2	MOVEA.L (A1)+,A2    ;A2=DESTINATION
	MOVEA.L (A0)+,A3    ;A3=SOURCE
	REPT 36
	MOVE.B (A3)+,(A2)
	LEA 160(A2),A2
	ENDR
	DBF D1,.L2	
	ADDQ.L #4,TPOS	    ;INCREASE POSITION IN TEXT.
			    ;1 LONGWORD=8 PIXELS OF TEXT
	SUBQ.W #1,LENGTH       ;END OF TEXT?    
	BNE .L3
	MOVE.W #8000-40,LENGTH ;8000=2000 CHARACTERS DIVIDED BY 4
	MOVE.L #TEXTAB,TPOS    ;SET POINTER TO START OF TEXT
.L3	RTS		       ;PISS OFF

SETUP2	MOVE.L #2000-1,D0      ;2000 CHARACTER OF TEXT(TOOK ME AGES!)
	LEA TEXTAB,A0
	LEA FONT,A1
	LEA TEXT1,A2
.L1	MOVEQ.W #0,D1
	MOVE.B (A2)+,D1
	SUBI.B #'A',D1
	MULU #(4*36),D1 	;4*36=LENGTH OF 1 CHARACTER IN FONT(BYTES)
	LEA (A1,D1.W),A3
	MOVE.L A3,(A0)+		;FIRST STRIP OF 8 PIXELS
	LEA 36(A3),A3		;1 STRIP = 36 BYTES(EACH CHARACTER IN FONT IS
			 	;36 PIXELS IN HEIGHT, AND 1 BIT PLANE) 
	MOVE.L A3,(A0)+		;SECOND STRIP
	LEA 36(A3),A3
	MOVE.L A3,(A0)+		;THIRD STRIP
	LEA 36(A3),A3
	MOVE.L A3,(A0)+		;FOURTH STRIP 
	DBF D0,.L1	

	MOVEQ.B #0,D7		;SET UP SINE WAVE SCREEN ADDRESSES	
	MOVEQ.L #0,D1
	MOVEQ.W #40-1,D0
	LEA SINETAB,A0		;SINE TABLE,DATA STORED AS Y COORDINATES(0-199)
	LEA YPOS,A1
	LEA $78000+(12*160),A6  ;OFFSET FOR ADDRESSES
.L4	MOVEQ.W #0,D6
	MOVE.B (A0)+,D6
	MULU #160,D6		;160=1 SCANLINE
	LEA (A6,D6),A3		;ADD OFFSET TO ADDRESS
	LEA (A3,D1),A3		;ADD 1 OR 7 TO ADDRESS.1=SECOND BYTE OF THE
				;WORD,7=1ST BYTE OF NEXT WORD.
	MOVE.L A3,(A1)+
	CMPI.B #0,D7
	BNE .L5			
	ADDQ.L #1,D1
	MOVE.B #1,D7
	DBF D0,.L4
	RTS
.L5	ADDQ.L #7,D1
	MOVE.B #0,D7
	DBF D0,.L4
	RTS

INIT	
;I
