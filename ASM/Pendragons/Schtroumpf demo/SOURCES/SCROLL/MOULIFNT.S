
	lea	pic+34,a0
	lea	dest,a1

	move.w	#17-1,d0

loop1:
st	set	0
	rept	8
	move.b	st(a0),(a1)+
	move.b	st+2(a0),(a1)+
	move.b	st+4(a0),(a1)+
	move.b	st+6(a0),(a1)+
st	set	st+160
	endr

st	set	0
	rept	8
	move.b	st+1(a0),(a1)+
	move.b	st+1+2(a0),(a1)+
	move.b	st+1+4(a0),(a1)+
	move.b	st+1+6(a0),(a1)+
st	set	st+160
	endr

	addq.l	#8,a0

	dbf	d0,loop1


	move.w	#0,-(sp)
	move.l	#name,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp

	move.w	d0,handle

	pea	dest
	move.l	#fin-dest,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	add.l	#4,sp

	move.w	#0,-(sp)
	move.l	#name2,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp

	move.w	d0,handle

	pea	pic+2
	move.l	#32,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	add.l	#4,sp

	clr.w	-(sp)
	trap	#1

name:	dc.b	"a:\scroll\font.bin",0
	even	

name2:	dc.b	"a:\scroll\pal.pal",0
	even	

handle:	ds.w	1

pic:
	incbin	"a:\scroll\font.pi1"
	even

dest:
	ds.b	34*32
fin:
	end