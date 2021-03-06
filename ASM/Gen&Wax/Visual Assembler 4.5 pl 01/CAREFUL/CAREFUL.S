	output	d:\assemble\sources.v45\careful\careful.app

OPT_GWVA_DEBUG_ERROR			; [option][root] generates an illegal when something goes wrong (for debugging purposes)
OPT_GWVA_DEBUG_PRINT_COMMENTS		; [option][root] print comments/warnings when assembling source

*OPT_GWVA_DEBUG_SEARCH_EXEC		; [option][root] is needed to do any log alert_box/logger
*OPT_GWVA_DEBUG_SEARCH_EXEC_IN_ALERT_BOX	; [option][root][LIB_HEXA][LIB_DECI][OPT_GWVA_DEBUG_SEARCH_EXEC] prints an alert box at each method distribution
*OPT_GWVA_DEBUG_SEARCH_EXEC_IN_LOGGER	; [option][root][LIB_HEXA][LIB_DECI][OPT_GWVA_DEBUG_SEARCH_EXEC] prints in log window each method distribution
*LIB_DECI				; [none]

*GWVA_DEBUG_MSG_MAX_SIZE = 256		; [var] defines the debug message max length (generated by SEARCH_EXEC)
*GWVA_DEBUG_MAX_MSG_DEBUG_PENDING = 64	; [var] how many debug messages can be sent in a row
*PATCH_GWVA_ROOT_GEM_MESSAGE_PADDED16	; [option][MDL_GEM] aligns automatically the length of outgoing messages on multiple of 16 bytes

OPT_FULL_PATHNAMES
*OPT_DEBUG_IN_ACCESSORY_MODE
*OPT_DEBUG

	lea objet_application,a1
	
	include careful.def
	include visual45.s
	include careful.hs
	include careful.obj

	comment HEAD=7
	section TEXT

my_inits:	tst	GWVA_ROOT_IS_ACC_PRG
	beq	acc_init

	;bset	#GWVA_APP_BIT_MENU,objet_application+GWVA_APP_OBJ_FLAGS	; menu principal
	;bclr	#GWVA_WIN_BIT_AMENU,fenetre_generale+GWVA_WIND_OBJ_PROPERTIES+1	; menu dans la fenetre

acc_open:	SUPEXEC	superinit
	bsr	aff_mem
	lea	fenetre_generale,a0
	bsr GWVA_WIND_CREATE_OPEN_ONE_WIND
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts

acc_init:	;bclr	#GWVA_APP_BIT_MENU,objet_application+GWVA_APP_OBJ_FLAGS	; menu principal
	;bset	#GWVA_WIN_BIT_AMENU,fenetre_generale+GWVA_WIND_OBJ_PROPERTIES+1	; menu dans la fenetre
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts

superinit:	move.l	$8.w,old_bus_error
	move.l	#buserror,$8.w
	rts

*--------------------------------------------------------------------------*
menu_info:	
	lea	fenetre_information,a0
	bsr GWVA_WIND_CREATE_OPEN_ONE_WIND
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts


	*-------------------------*
acc_close:
app_term:
menu_quit:
close_fenetre_generale:
	SUPEXEC	superquit

	bsr GWVA_ROOT_KILL_APPLICATION

	moveq #GWVA_PRGRET_CONSUMED,d6
	rts
	
superquit:
	move.l	old_bus_error,$8
	rts 

*--------------------------------------------------------------------------*

curs_moins_page:
	sub.l	#$10*16,adresse
	bra.s	redraw

curs_moins:
	sub.l	#$10,adresse
	bra.s	redraw
	
curs_plus:
	add.l	#$10,adresse
	bra.s	redraw

curs_plus_page:
	add.l	#$10*16,adresse

redraw:	bsr	aff_mem
	lea 	fenetre_generale,a0
	lea	buffer_objet_redraw,a1
	move.w	#I_REDRAW,(a1)
	move.w 	#1,2(a1)
	move.w	#GWVA_WRSC_CTE_REDRAW_PART_END_LIST,4(a1)
	GWVA_CALL_METHOD_OTHER_OBJ	#GWVA_METHOD_WRSC_REDRAW_PART_CONTENTS
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts
	
aff_mem:	
	move.w	#FORM_PRINCIPAL,d0
	move.w	#T_ADRESSE,d1
	movea.l	adresse,a6
	move.w	#15,d7
.colonne
	save.w	d0-d1
	save.l	a6
	bsr	GWVA_RSC_RETURN_PTR_ON_TEXT	;->a1.l
	load.l	d0
	move.l	#32,d1
	bsr 	GWVA_STOCK_HEXA
	load.w	d0-d1
	
	adda.l	#$10,a6
	addq.w	#1,d1
	dbra	d7,.colonne
	
	
	move.w	#FORM_PRINCIPAL,d0
	move.w	#T_DUMP,d3
	move.w	#T_ASCII,d1
	movea.l	adresse,a6
	move.l	a6,adresse_special
	move.w	#15,d2
ascii
	save.w	d0-d3
	
	bsr	GWVA_RSC_RETURN_PTR_ON_TEXT	;->a1.l ASCII
	movea.l	a1,a2
	move.w	#FORM_PRINCIPAL,d0
	move.w	d3,d1
	save.l a2
	bsr	GWVA_RSC_RETURN_PTR_ON_TEXT	;->a1.l DUMP
	load.l a2
	
	move.w	#15,d2
bcl	save.l	d0-d2/a1
	SUPEXEC	supercharge
	load.l	d0-d2/a1
	move.b	data_special,d0
	tst.b	data_valid
	beq.s	.valid
	move.w	#'..',(a1)+
	move.b	#' ',d0
	bra.s	.affich
.valid	moveq.l	#8,d1
	save.l	d0-d2/a1
	bsr	GWVA_STOCK_HEXA
	load.l	d0-d2/a1
	addq.l	#2,a1
.affich	cmpi.b	#' ',d0
	bge.s	.affichable
	move.b	#250,d0
.affichable	move.b	d0,(a2)+
	dbra	d2,bcl
	
	load.w	d0-d3
	addq.w	#1,d1
	addq.w	#1,d3
	dbra	d2,ascii
	
	rts
	
supercharge:
	sf	data_valid
	move.b	([adresse_special]),data_special
reterror:	add.l	#1,adresse_special
	rts
	
buserror:	
	move.w	#$2700,sr
	*move.b	#'*',data_special
	st	data_valid
	move.l	d0,save_d0
	
	move.w	$a(a7),d0
	bclr	#8,d0
	move.w	d0,$a(a7)
	
	move.l	save_d0,d0
	move.l	#reterror,2(sp)
	rte
	
save_d0	dc.l	0
	
inq_adresse:
	save.l 	d0
	move.w	#QUESTION,d0
	bsr 	GWVA_RSC_MODAL_FORM
	cmpi	#B_ADR_ABANDON,d0
	beq.s	.fin
	move.w	#QUESTION,d0
	move.w	#F_NOUV_ADRESSE,d1
	bsr	GWVA_RSC_RETURN_PTR_ON_TEXT
	
	clr.l	d0
.hexa	move.b	(a1)+,d1
	beq.s	.complete
	subi.b	#'0',d1
	bmi.s	.fin
	cmpi.b	#9,d1
	ble.s	.cont
	ori.b	#$20,d1
	subi.b	#'a'-'0',d1
	bmi.s	.fin
	cmpi.b	#6,d1
	bgt.s	.fin
	add.b	#$A,d1
.cont	lsl.l	#4,d0
	or.b	d1,d0
	bra.s	.hexa
.complete	move.l	d0,adresse
	load.l	d0
	bra	redraw
.fin	load.l 	d0
	moveq #GWVA_PRGRET_CONSUMED,d6
	rts	

 data
 	even
adresse		dc.l	my_inits
 
 bss
 	even
old_bus_error	ds.l	1
adresse_special	ds.l	1
dummy		ds.w	1
data_special	ds.b	1
data_valid		ds.b	1
buffer_objet_redraw:	ds.w	3
 end
