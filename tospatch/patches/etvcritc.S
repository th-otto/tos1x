ERRSTKSIZE equ 1028

xdef dos_etvcritic

		text
dos_etvcritic:
		lea.l      4(a7),a0
		movem.l    d3/d6-d7/a3-a4,-(a7)
		move.w     (a0)+,d7
		bpl        FE0096
		move.w     (a0),d6
		move.l     a7,(errsave).w
		lea.l      (errstk+ERRSTKSIZE-4).w,a7
		move.w     d7,d1
		not.w      d1
		cmp.w      #17,d1
		bgt.s      FE0060
		lea.l      _err_tbl,a1
		move.b     0(a1,d1.w),d3
		ext.w      d3
		add.w      d3,d3
		lea.l      ETV_MSG(pc),a4
		adda.w     0(a4,d3.w),a4
		bsr.s      FE009C
		cmp.w      #12,d3
		beq.s      FE0064
FE0040:
		lea.l      ETV_QUEST(pc),a4
		bsr.s      FE009C
		bsr.s      FE00C2
		bclr       #5,d0
#if (COUNTRY == CTRY_DE) | (COUNTRY == CTRY_SG)
		cmp.b      #'A',d0
#else
		cmp.b      #'C',d0
#endid
		beq.s      FE0070
		cmp.b      #'I',d0
		beq.s      FE007C
#if (COUNTRY == CTRY_DE) | (COUNTRY == CTRY_SG)
		cmp.b      #'N',d0
#else
		cmp.b      #'T',d0
#endif
		beq.s      FE0076
		bra.s      FE0040
FE0060:
		moveq.l    #-1,d0
		bra.s      FE0092
FE0064:
		lea.l      ETV_KEY(pc),a4
		bsr.s      FE009C
		bsr.s      FE00C2
		moveq.l    #0,d3
		bra.s      FE008A
FE0070:
		move.w     d7,d3
		ext.l      d3
		bra.s      FE007E
FE0076:
		moveq.l    #1,d3
		swap       d3
		bra.s      FE007E
FE007C:
		moveq.l    #0,d3
FE007E:
		move.w     d0,-(a7)
		move.l     #$00030002,-(a7)
		trap       #13
		addq.l     #6,a7
FE008A:
		lea.l      ETV_CRNL(pc),a3
		bsr.s      FE00A4
		move.l     d3,d0
FE0092:
		movea.l    (errsave).w,a7
FE0096:
		movem.l    (a7)+,d3/d6-d7/a3-a4
		rts
FE009C:
		lea.l      ETV_ESC(pc),a3
		bsr.s      FE00A4
		movea.l    a4,a3
FE00A4:
		move.b     (a3)+,d0
		beq.s      FE00C0
		cmp.b      #'%',d0
		bne.s      FE00B2
		moveq.l    #'A',d0
		add.b      d6,d0
FE00B2:
		move.w     d0,-(a7)
		move.l     #$00030002,-(a7)
		trap       #13
		addq.l     #6,a7
		bra.s      FE00A4
FE00C0:
		rts
FE00C2:
		move.l     #$00020002,-(a7)
		trap       #13
		addq.l     #4,a7
		rts

ETV_MSG:
	dc.w ETV_MSG1-ETV_MSG
	dc.w ETV_MSG2-ETV_MSG
	dc.w ETV_MSG3-ETV_MSG
	dc.w ETV_MSG4-ETV_MSG
	dc.w ETV_MSG5-ETV_MSG
	dc.w ETV_MSG6-ETV_MSG
	dc.w ETV_MSG7-ETV_MSG

ETV_ESC:
	dc.b $1b,$6c,$20,0

#if (COUNTRY == CTRY_DE) | (COUNTRY == CTRY_SG)

ETV_MSG1:
	ascii 'Disk in Laufwerk %: ist schreibgeschÅtzt.'
	dc.b 13,10,0
ETV_MSG2:
	ascii 'Floppy %: antwortet nicht (?)...'
	dc.b 13,10,0
ETV_MSG3:
	ascii 'Daten auf Disk %: defekt? '
	dc.b 13,10,0
ETV_MSG4:
	ascii 'Anwendung kann Disk %: nicht lesen.'
	dc.b 13,10,0
ETV_MSG5:
	ascii 'AusgabegerÑt antwortet nicht!'
	dc.b 13,10,0
ETV_MSG6:
	dc.b 0 
ETV_MSG7:
	ascii 'Bitte Disk %: in Laufwerk A: einlegen!'
ETV_QUEST:
	ascii 'A)bbruch, N)ochmal, I)gnorieren? '
	dc.b 0
ETV_KEY:
	ascii 'Taste...'
	dc.b 0

#else

ETV_MSG1:
	ascii 'Disk in drive %: is write-protected.'
	dc.b 13,10,0
ETV_MSG2:
	ascii 'Drive %: is not responding (?)...'
	dc.b 13,10,0
ETV_MSG3:
	ascii 'Data on disk %: defect? '
	dc.b 13,10,0
ETV_MSG4:
	ascii 'Application cannot read disk %:.'
	dc.b 13,10,0
ETV_MSG5:
	ascii 'Drive is not responding!'
	dc.b 13,10,0
ETV_MSG6:
	dc.b 0 
ETV_MSG7:
	ascii 'Please insert Disk %: in drive A:!'
ETV_QUEST:
	ascii 'C)ancel, T)ry again, I)gnore? '
	dc.b 0
ETV_KEY:
	ascii 'Key...'
	dc.b 0
#endif

ETV_CRNL:
	dc.b 13,10,0

	even
