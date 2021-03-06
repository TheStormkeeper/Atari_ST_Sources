***********************************************************************
* This small code was written by Jens Bauer, using Hisoft Devpac 2.07 *
*     It's PD, and can freely be implemented in your own programs.    *
*  I used Tab size 12, so it can easily be easy for you to read it..  *
*                           Great greetings                           *
*                              - Jens -                               *
***********************************************************************
	opt	x+ o+	extended debugsymbols, and optimising
	output	view_ps.prg

f_attr:	equ	4+21	attributes on dta
f_time:	equ	4+22	time on dta
f_date:	equ	4+24	date on dta
f_length:	equ	4+26	length on dta     <-- we only use this
f_name:	equ	4+30	filename on dta

*----------------------{ Setup SP and shrink memory }----------------------*
std_init:	lea	oldstack(pc),a5	I really don't have to call
	move.l	sp,(a5)		this twice, so it becomes
	move.l	4(sp),a5		Disk-Transfer-Address

	lea	my_stack(pc),sp
	move.l	#256,d0
	add.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#74,-(sp)	mshrink
	trap	#1
	lea	12(sp),sp

	move	#47,-(sp)
	trap	#1
	addq.l	#2,sp

	lea	std_init(pc),a0	overwrite used memory 8-)
	move.l	d0,(a0)+
	move.l	a0,-(sp)
	move	#26,-(sp)		set new dta
	trap	#1
	addq.l	#6,sp

	move	#39,-(sp)
	pea	filename(pc)
	move	#78,-(sp)		fsfirst
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	exit

	lea	26+4+std_init(pc),a0
	move.l	(a0),-(sp)		picture-buffer
	move	#72,-(sp)		malloc
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq	exit

	lea	buffer(pc),a0
	move.l	d0,(a0)

	clr	-(sp)
	pea	filename(pc)
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	tst.l	d0
	bmi	exit

	lea	handle(pc),a0
	move	d0,(a0)
	
	lea	buffer(pc),a0
	move.l	(a0),-(sp)		store buffer
	pea	32768		maxlength of a picture
	move	d0,-(sp)		handle
	move	#63,-(sp)		read
	trap	#1		now call gemdos
	lea	12(sp),sp

	move.l	d0,-(sp)		store error if any...
	lea	handle(pc),a0
	move	(a0),-(sp)
	move	#62,-(sp)		close the file
	trap	#1
	addq.l	#4,sp
	move.l	(sp)+,d0
	tst.l	d0		if there was error reading
	bmi.s	exit		the picture, then exit

getscreen:	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	lea	screen(pc),a1
	move.l	d0,(a1)		store screen-address

colors:	dc.w	$a00a		showtime, remove the meuz
	lea	buffer(pc),a0	address of buffer
	move.l	(a0),a0		address of picture
	lea	2(a0),a0		points now to palette
	move.l	a0,-(sp)		push palette on stack
	move	#6,-(sp)		set colors..
	trap	#14
	addq.l	#2,sp
	move.l	(sp)+,a0
	lea	32(a0),a0		points to real start now

	lea	screen(pc),a1
	move.l	(a1),-(sp)
	move.l	a0,-(sp)
	bsr.s	decode

exit:	dc.w	$a009		unshowtime, show me a mouse
	lea	std_init(pc),a0	laa-lalalla-la... put old 
	move.l	(a0),-(sp)		dta back
	move	#26,-(sp)
	trap	#1
	addq.l	#6,sp

	pea	131074		wait for a key
	trap	#13
	addq.l	#4,sp

	clr	-(sp)
	move	#76,-(sp)
	trap	#1

*--------------------{ Here's the magic routine then: }--------------------*
decode:	movem.l	d0-d7/a0-a6,-(sp)	save all reggies
	move.l	64(sp),a0		source address
	move.l	68(sp),a1		destination address
	move.l	#31999,d2		maximum screen size

loop0:	moveq	#0,d0		clean d0
	move.b	(a0)+,d0
	btst	#7,d0
	beq.s	not_comp

compressed:	not.b	d0		invert d0.b
	addq	#1,d0
	move.b	(a0)+,d1
loop1:	move.b	d1,(a1)+
	subq	#1,d2
	bmi.s	exit_comp
	dbra	d0,loop1
	bra.s	loop0

not_comp:	move.b	(a0)+,(a1)+
	subq	#1,d2
	bmi.s	exit_comp
	dbra	d0,not_comp
	bra.s	loop0
exit_comp:	movem.l	(sp)+,d0-d7/a0-a6	GfA-basic don't like when I
	rts			use a6!

*---------------------{ Data for the picture viewer: }---------------------*
	section	data
	ds.l	127
my_stack:	ds.l	1
oldstack:	ds.l	1
buffer:	ds.l	1
screen:	ds.l	1
handle:	ds.w	1
filename:	dc.b	'PITTSTOP.PC3',0
                                                                                                                                                                                                                       