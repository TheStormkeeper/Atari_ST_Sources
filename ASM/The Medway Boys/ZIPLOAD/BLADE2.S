**************************************************************************
* ZIP LOAD V3.00 - 1st June 1990                                         *
*                                                                        *
* Since most raw data games now use the Rob Northen dma routines I've    *
* made some permanent changes to the 'handler' routine so that it can    *
* deal with most of the parameters passed to it by a Rob N routine.      *
*                                                                        *
* All available expansion ram is used, so if you have a hard drive and   *
* 2.5 Meg ram, you should be able to play any game from your hard drive! *
*                                                                        *
* If the game tries to size your ram by writing to $80000+, or tries to  *
* set up it's own ramdisk, then you will have to remove those routines,  *
* or else they will probably corrupt my ramdisk !!                       *
*                                                                        *
* If 'T' was pressed (For trainer), then $8.w will be zero.              *
*                                                                        *
* Please Note: The Disk is assumed to be 10 Sectors and 2 Sides !!!      *
**************************************************************************

space	equ	$74000			;Handler/Buffer/Depack/DMA routs
					;Must be at least $2000 bytes free
	opt	s-
	clr.l	-(sp)			;super mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	$140.w
	move.w	#$0001,$144.w
	lea	$80000,sp		;setup stack
	lea	$ffff8240.w,a0		;black screen
	moveq	#7,d0
clrpal	clr.l	(a0)+
	dbf	d0,clrpal
	move.l	$42e.w,$420.w		;save ramsize
	move.l	#$80000,$42e.w		;force half meg
	clr.w	-(sp)			;low res
	pea	$78000			;screen address
	pea	$78000			;screen address
	move.w	#5,-(sp)		;setup screen
	trap	#14
	add.l	#12,sp
	lea	text(pc),a0		;show title page text
	bsr	print
	bsr	fadeup			;fade colours up
	bsr	getkey			;wait for key
	cmp.b	#'/',d0			;check for disk loader force
	bne	notdl
	clr.w	(dbs+6)			;no files in ramdisk
	move.l	#$80000,$420.w
notdl	or.b	#$20,d0
	cmp.b	#'t',d0			;trainer ?
	bne	notr			;no
	bsr	fadedn
	lea	text1(pc),a0
	bsr	print
	bsr	fadeup
	bsr	getkey
	or.b	#$20,d0
	cmp.b	#'y',d0
	bne	nn1
	move.w	#1,$140.w
nn1	lea text2(pc),a0
	bsr print
	bsr getkey
	or.b #$20,d0
	cmp.b #'y',d0
	bne nn2
	move.w #1,$142.w
nn2	lea text3(pc),a0
	bsr print
zz	bsr getkey
	cmp.b #'1',d0
	blt zz
	cmp.b #'6',d0
	bgt zz
	and.l #$ff,d0
	sub.b #'0',d0
	move.w d0,$144.w
notr	bsr	fadedn			;fade colours down
	cmp.l	#$80000,$420.w		;expansion ram ?
	ble	norl			;no
	bsr	rload			;yes, so fill expansion ramdisk
norl	move.w	#$2700,sr
	move.w	#1,$43e.w		;disable disk int
	lea	handler(pc),a0		;copy handler
	lea	space,a1		;address of handler
chl	move.l	(a0)+,(a1)+		;copy data
	cmp.l	#fadeup,a0		;end ?
	ble	chl
	move.w	#4,d7
	move.w	#26,d0
	move.l	#$71000,a0
	jsr	space			;call handler
	move.w	#5,d7
	move.w	#20,d0
	move.l	#$71800,a0
	jsr	space			;call handler
	move.l	#$4eb90007,$71132
	move.l	#$40004e75,$71136
	move.b #$60,$71a02
	lea crack,a0
	lea $380,a1
hh	move.l (a0)+,(a1)+
	cmp.l #rload,a0
	ble hh
	jmp	$71000
crack	lea $74000,a0
	lea $58000,a1
azx	move.l (a0)+,(a1)+
	cmp.l #$76000,a0
	blt.s azx
	move.b #$60,$1eed6
	move.l #$4eb90005,$1f25e
	move.l #$80004e75,$1f262
	tst.w $140.w
	beq.s qq1
	move.b #$4a,$11588
qq1	tst.w $142.w
	beq.s qq2
	move.w #$6002,$12206
qq2	move.w $144.w,$10dfc
	jmp $602

rload	move.l	(pat_fl-12),(pat_fl-8)	;copy last table entry
	add.l	#$1400,(pat_fl-8)	;add 1 track length
	lea	ramess,a0		;expansion ramdisk message
	bsr	print
	bsr	fadeup			;fade up colours
	lea	table,a5		;lump table
	lea	$80100,a6		;ramdisk start address
ramlo	tst.l	4(a5)			;whole disk read yet
	bmi	allin			;yes, so read all disk image
	move.l	4(a5),d6		;get next table entry
	sub.l	(a5)+,d6		;calc track chunk size
	add.l	d6,a6			;update ramdisk address
	cmp.l	$420.w,a6		;expansion ramdisk full yet ?
	bge	full			;yes, so exit
	add.w	#10,(dbs+6)		;ok, that track now in ramdisk
	lea	back6,a0		;print new address
	bsr	print
	move.l	a6,d5
	rol.l	#8,d5			;only 24 bits wanted
	move.w	#5,d4			;6 chars
prlo	rol.l	#4,d5
	move.b	d5,d6
	and.b	#$f,d6			;mask lower 4 bits
	add.b	#'0',d6			;convert to char
	cmp.b	#'9',d6			;check for hex
	ble	numok
	add.b	#7,d6			;adjust hex char
numok	move.b	d6,num			;print char
	lea	num,a0
	bsr	print
	dbf	d4,prlo			;next char
	bra	ramlo			;get next track
allin	move.l	#$00100000,a6		;dummy end of ramdisk
	moveq	#0,d6			;all tracks fitted
full	sub.l	d6,a6			;sub last track that didn't fit
	sub.l	#$80100,a6		;sub start address of ramdisk
	lea	loadt,a0		;loading message
	bsr	print
	lea	name,a0			;filename
	bsr	print
	move.w	#0,-(sp)		;open disk file
	pea	name
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,d7
	pea	$80100			;start of disk image
	pea	(a6)			;length to read from disk image
	move.w	d7,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	d7,-(sp)		;close disk file
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bsr	fadedn			;fade down colours
	rts				;return to main

handler	movem.l d1-a6,-(sp)		;lump handler
	lea	data(pc),a6		;offset for relative vars
dbs	clr.w	ram-data(a6)		;assume no ramdisk
	cmp.w	#0,d0			;is file in ramdisk ?
	bge	nok			;no
	move.w	#1,ram-data(a6)		;yes, so set flag
nok	cmp.w	#770,d0
	ble	dd
	add.w	#50,d0
dd	move.w	d0,d0			;start sector in D0
	move.w	d7,d1			;Length in D1
	move.l	a0,a0			;Address in A0
	move.w	d0,start_sec-data(a6)	;save parameters
	move.w	d1,length_sec-data(a6)
	move.l	a0,load_adds-data(a6)
	movem.l	d1/a0,-(sp)		;save start/length
	tst.w	ram-data(a6)		;is file in ramdisk ?
	bne	lram			;yes, so ram load
	lea	$ffff8606.w,a5		;No, so must disk load
	lea	trackbuff(pc),a1	;track buffer
	move.l	a1,loadaddr-data(a6)
	move.l	a1,offset-data(a6)
	lea	name(pc),a0		;filename
	move.l	a0,filename-data(a6)
	bsr	do_boot			;get boot details
	bsr	do_dir			;open file
	move.w	load_sec-data(a6),old_sec-data(a6)	;save file start

readl	move.w	old_sec-data(a6),load_sec-data(a6)	;restor file start
lram	lea	trackbuff(pc),a1	;track buffer
	move.l	a1,loadaddr-data(a6)
	move.l	a1,offset-data(a6)
	move.w	start_sec-data(a6),d0	;get required sec
	divu	#10,d0			;which track ? (Note: SS)
	swap 	d0			;which sector ?
	move.w	d0,sector-data(a6)	;store sector
	swap 	d0			;track
	and.l	#$ffff,d0		;mask
	lsl.l	#2,d0			;offset for table
	lea	table(pc),a0		;get table
	move.l	$0(a0,d0.l),d0		;get offset into file
	tst.w	ram-data(a6)		;is file in ramdisk ?
	beq	cdl			;no, so continue disk load
	add.l	#$80100,d0		;yes, so calc start of disk
	move.l	d0,a0			;address of required track
	move.l	loadaddr-data(a6),a1	;copy into track buffer
	move.w	#319,d0			;320*16 bytes
rdl	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	dbf	d0,rdl			;loop
	bra conl			;continue handler
cdl	divu	#$200,d0		;which sector
	add.w	d0,load_sec-data(a6)	;add to start
	swap	d0			;get extra bytes
	and.l	#$ffff,d0		;mask
	add.l	d0,offset-data(a6)	;add to buffer start
	move.l	#$1600,load_len-data(a6);must read extra sector in case
					;track starts at +510 bytes !!
	bsr	do_file			;read file
conl	move.l	offset-data(a6),a0	;start of track
	bsr	decrunch		;depack
	move.w	sector-data(a6),d0	;sector in track
	move.w	d0,d1			;save sector
	mulu	#$200,d0		;sector length
	add.l	d0,a0			;sector address
	move.l	load_adds-data(a6),a1	;destination address
notes	move.l	#31,d0			;32*16 bytes long
copl	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	move.l	(a0)+,(a1)+		;copy data
	dbf	d0,copl			;loop
	subq.w	#1,length_sec-data(a6)	;1 sector copied
	beq	endh			;last sector
	addq.w	#1,d1			;1 sector copied
	cmp.w	#10,d1			;finished this track
	bne	notes			;no ?
	sub.w	sector-data(a6),d1	;how many sectors ?
	add.w 	d1,start_sec-data(a6)	;add sectors read
	mulu	#$200,d1		;length read
	add.l	d1,load_adds-data(a6)	;add length
	bra	readl			;round loop again
endh	bra	pat_fl			;search/patch Rob N dma routs
exit	movem.l (sp)+,d1-a6		;exit
	moveq	#0,d0			;no errors
	rts				;return

name	dc.b	"BLADE2     ",0		;filename of lump
table	incbin	"g:\table"		;get track table
	dc.l	0,-1

pat_fl	movem.l	(sp)+,d0/a0		;restore start/length
	bra	exit			;continue search

do_boot	; Read boot sector and calculate dir/data posns

	moveq	#0,d0
	bsr	read_log	Read boot sector
		
	move.l	loadaddr-data(a6),a0
	
	moveq	#0,d0
	moveq	#0,d1
	move.b	$10(a0),d0
	move.b	$16(a0),d1
	mulu	d1,d0
	addq.w	#1,d0
	move.w	d0,dir_pos-data(a6)

	move.b	$11(a0),d1
	lsr.w	#4,d1
	move.w	d1,dir_len-data(a6)

	rts


do_dir	; Reads dir and get load_sec and load_len

	move.w	dir_pos-data(a6),d6
	move.w	dir_len-data(a6),d7
	add.w	d7,dir_pos-data(a6)	Posn of cluster 2

.1	move.w	d6,d0
	bsr	read_log
	
	moveq	#15,d0		16 file entries per sec
	move.l	loadaddr-data(a6),a0
	move.l	filename-data(a6),a1

.2	moveq	#10,d1		11 chars in filename

.3	move.b	0(a0,d1.w),d2
	cmp.b	0(a1,d1.w),d2
	bne	.4
	dbf	d1,.3
	lea	26(a0),a0		File found!
	lea	load_sec+2-data(a6),a1
	move.b	(a0)+,-(a1)
	move.b	(a0)+,-(a1)
	move.w	load_sec-data(a6),d0
	subq.w	#2,d0
	add.w	d0,d0
	add.w	dir_pos-data(a6),d0
	move.w	d0,load_sec-data(a6)
	moveq	#0,d0
	rts

.4	lea	32(a0),a0		Next entry
	dbf	d0,.2

	addq.w	#1,d6		Next dir sector
	subq.w	#1,d7	
	bpl	.1
	rts			d0=-1,file not found error


do_file	; Read file in!

	move.w	load_sec-data(a6),d0
	ext.l	d0
	bsr	calc_sec		d0=trk,d1=sec
	move.w	d1,d2
	mulu	#$200,d2
	move.l	#$1600,d3
	sub.l	d2,d3		d3=max load amount of this track
	move.l	load_len-data(a6),d2
	cmp.l	d2,d3
	bge.s	.1
	move.l	d3,d2
.1	move.l	d2,-(a7)		d2=amount
	bsr	readdisk
	move.l	(a7)+,d2
	add.l	d2,loadaddr-data(a6)
	sub.l	d2,load_len-data(a6)
	divu	#$200,d2
	add.w	d2,load_sec-data(a6)
	tst.l	load_len-data(a6)
	bne.s	do_file		More to load?
	rts
	

; Little subbies (!)

read_log	; Read logical sector in d0

	bsr	calc_sec
	move.l	#$200,d2		One sector only
	bsr.s	readdisk
	rts


readdisk	; Read d0=trk,d1=sec,d2=amount

	move.w	d1,d4			Sector to d4
	add.w	#$1ff,d2
	divu	#$200,d2
	move.w	d2,d3			Count to d3
	move.l	loadaddr-data(a6),a0	Load address

	move.w	#$86,(a5)		Move head to track d0
	move.w	d0,d1
	bsr	shove_fdc
	move.w	#$80,(a5)
	move.w	#$13,d1
	bsr	shove_fdc
	bsr	wait_fdc
	bmi	stat_bad
	move.w	#$82,(a5)		Set track register
	move.w	d0,d1		d0=track
	bsr	shove_fdc
.next_sec	moveq	#2,d5		3 tries
.err_loop	move.l	a0,d1
	move.b	d1,7(a5)
	lsr.l	#8,d1
	move.b	d1,5(a5)
	lsr.w	#8,d1
	move.b	d1,3(a5)
	move.w	#$84,(a5)
	move.w	d4,d1		d4=sec
	bsr	shove_fdc
	move.w	#$90,(a5)
	move.w	#$190,(a5)
	move.w	#$90,(a5)
	move.w	#$1,d1		1 sec
	bsr	shove_fdc
	move.w	#$80,(a5)
	move.w	#$80,d1
	bsr	shove_fdc
	bsr	wait_fdc		Read sec
	bmi	stat_bad
	move.w	-2(a5),d1
	and.w	#$70,d1
	beq.s	.ok
	dbf	d5,.err_loop
	bra	stat_bad
.ok	lea	$200(a0),a0
	addq.w	#1,d4
	subq.w	#1,d3
	bne	.next_sec
	rts

shove_fdc
	bsr.s	.1
	move.w	d1,-2(a5)
.1	moveq	#32,d2
.2	dbf	d2,.2
	rts

wait_fdc
	move.l	#$400000,d1
.1	btst	#5,$fffa01
	beq.s	.2
	subq.l	#1,d1
	bpl	.1
	rts
.2	moveq	#0,d1
	rts

stat_bad
	addq.l	#8,a7		Error
	bra	select_2
	

calc_sec	; Logical sector in d0,outputs trk,sec in d0,d1

	divu	#10,d0
	btst	#0,d0
	bne.s	.1
	bsr	select_0	Side 0
	bra.s	.2
.1	bsr	select_1	Side 1
.2	move.l	d0,d1
	lsr.w	#1,d0	Trk
	swap	d1
	addq.w	#1,d1	Sec
	rts

select_0
	movem.l	d0-d1,-(a7)	Select side 0
	moveq	#5,d0	
	bra.s	sel

select_1
	movem.l	d0-d1,-(a7)	Select side 1
	moveq	#4,d0	
	bra.s	sel

select_2
	movem.l	d0-d1,-(a7)	Select nothing
	moveq	#7,d0	

sel	move	sr,-(a7)
	or	#$700,sr
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d1
	and.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,$ffff8802.w
	move	(a7)+,sr
	movem.l	(a7)+,d0-d1
	rts


data	; All variables relative to this for pos-ind code

filename	dc.l	0	;Address of filename
loadaddr	dc.l	0	;Load address for buffer
load_sec	dc.w	0	;Sector to load from
load_len	dc.l	0	;File length left to load
dir_pos	dc.w	0		;Start sec of directory (then data)
dir_len	dc.w	0		;Directory length in secs	
start_sec	dc.w 	0	;Sector to load from
length_sec	dc.w	0	;Length of sectors to load
load_adds	dc.l	0	;Address to load to
offset		dc.l	0	;Address of sector in buffer
sector		dc.w	0	;Which sector in track
old_sec		dc.w	0	;Temp storage for start of file
sides		dc.w	0	;Single or Double sided access
ram		dc.w	0	;Flag for ram disk

;********************************************* Unpackroutine von ICE-PACK
; Eingabe: a0 = Adresse gepackter Daten
decrunch
	move.w	$ffff8240.w,-(sp)
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte L�nge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte L�nge holen (original)
	move.l	d0,(sp)		; Originall�nge: sp�ter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1

	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken f�r Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes
	move.l	a3,a5		; f�r 120 Bytes restore

.no_picture
	movem.l	(sp),d0-a3	; hole n�tige Register

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um �berschriebenen Bereich
.rest	move.b	-(a3),-(a5)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	move.w	(sp)+,$ffff8240.w
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu �bertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	move.w	a6,$ffff8240.w
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schlu�

.get_1_bit:
	add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und �bernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; n�chstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = �berschu�-L�nge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_�ber		; kein �berschu� n�tig
.get_�ber:
	bsr.s	.get_d0_bits
.no_�ber:	move.b	6(a1,d2.w),d4	; Standard-L�nge zu �berschu� add.
	add.w	d1,d4		; d4 = String-L�nge-2
	beq.s	.get_offset_2	; L�nge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-�berschu�
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu �berschu� add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; �berschu�-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + �ber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-L�nge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;*************************************************** Ende der Unpackroutine

trackbuff	ds.l 1408

fadeup	move.w #6,d0
ful	move.w #$1234,d2
	move.w #$2000,d1
paa	mulu d1,d2
	dbf d1,paa
	add.w #$111,$ffff825e.w
	dbf d0,ful
	rts

fadedn	move.w #6,d0
ful1	move.w #$1234,d2
	move.w #$2000,d1
paa1	mulu d1,d2
	dbf d1,paa1
	sub.w #$111,$ffff825e.w
	dbf d0,ful1
	rts

getkey	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	rts

print	pea (a0)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	rts

back6		dc.b 8,8,8,8,8,8,0,0
num		dc.w 0

ramess		dc.b 27,'f',27,'E'
		dc.b "ZIP-LOAD V3.00",10,10,13
		dc.b "Expansion Ram Detected.",10,10,10,13
		dc.b "Creating Ram Disk, Please wait....",10,10,13
		dc.b "Building from: $080100 to $080100",0
loadt		dc.b 10,10,13
		dc.b "Loading file: ",0
text		dc.b 27,'f',27,'E'
		dc.b "The Medway Boys Present",10,13
		DC.B "~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
		DC.B "SWITCHBLADE 2++",10,10,13
		dc.b "Cracked/Packed/Filed/Trained by ZIPPY",10,13
		dc.b "Original by Gino",10,10,13
		dc.b "Press 'T' for trainer",10,10,10,13
		dc.b "Golden regards go to:",10,13
		dc.b "Vapour, Replicants, Superior, Elite,",10,13
		dc.b "Hotline/MCA, and Pompey Pirates",0 
text1		dc.b 27,'E',27,'f'
		dc.b "Do you want infinite lives (y/n) ?",0
text2		dc.b 10,10,13
		dc.b "Do you want free items in shop (y/n) ?",0
text3		dc.b 10,10,13
		dc.b "Start on which level (1-6) ?",0
	even
		dc.w 0
		
