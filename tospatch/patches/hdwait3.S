/********************************************************************************
 * Harddiskwaiter
 *
 * Geschrieben von EWK, fuer TOSPATCH umgeschrieben von Markus Heiden
 *
 * (C)1992 EWK
 * (C)1993 Markus Heiden                                             09.03.1993
 ********************************************************************************/

hd_wait:
                cmpi.w  #2,(_bootdev).w /* Schon mal von Harddisk gebootet? */
                bhs.s   abbruch         /* Ja! => Ende, da kein Kaltstart */

                bsr.s   acsiw           /* Platte schon fertig? */
                beq.s   abbruch         /* Ja! => Ende */

                lea     wait_txt(PC),A0 /* Text ausgeben */
                bsr.s   string_out

                move.l  (_hz_200).w,D5  /* Systemtimer holen */
                moveq   #HD_WAITTIME,D6 /* Wartezeit in Sekunden */

next_second:    add.l   #200,D5         /* eine Sekunde warten */

                lea     prefix_txt(PC),A0 /* Cursor setzen */
                bsr.s   string_out

dez_out:        move.l  D6,D4
                divu    #10,D4
                bsr.s   digit_out
                swap    D4
                bsr.s   digit_out

wait_key:       move.l  #$000BFFFF,-(SP)
                trap    #13             /* Kbshift */
                addq.l  #4,SP

                and.b   #3,D0           /* Beide Shift-Tasten */
                subq.b  #3,D0           /* gedrueckt? */
                beq.s   abbruch         /* Ja! => Ende */

                bsr.s   acsiw           /* Platte schon fertig? */
                beq.s   abbruch         /* Ja! => Ende */

                cmp.l   (_hz_200).w,D5  /* Ist eine Sekunde zu Ende? */
                bhi.s   wait_key        /* Nein! => weiter warten */

                subq.w  #1,D6           /* Zeit dekrementieren; Wartezeit-Timeout? */
                bpl.s   next_second     /* Nein! => nochmal */

abbruch:        lea     clr_scr(PC),A0  /* Bildschirm loeschen und zurueck zum TOS */

/*    ***   Subroutines   *** */

string_out:     move.l  A0,-(SP)
                move.w  #9,-(SP)        /* Cconws */
                trap    #1
                addq.l  #6,SP
                rts

digit_out:      moveq   #$30,d0
                add.w   D4,D0

char_out:       move.w  D0,-(SP)
                move.w  #2,-(SP)        /* Cconout */
                trap    #1
                addq.l  #4,SP
                rts

acsiw:          st      (_flock).w      /* DMA-Zugriff sperren */

                lea     (DMA_DATA).w,a0  /* Register belegen */
                lea     2(a0),a1

                move.l  #(HD_WAITDEVICE*$200000)+$0088,d4   /* Unit Ready Drive X (nicht senden) */
                move.l  #$0000008a,d2
                move.l  #(HD_WAITDEVICE*$200000)+$008A,d0   /* Unit Ready Drive X (senden) */

                move.w  d4,(a1)         /* #$0088 Attention! */
                move.l  d4,(a0)
                move.l  d4,(a0)

                btst    #5,$FFFFFA01.w  /* DMA-Interrupt? ( = Harddisk blockiert) */
                beq.s   acsiw2          /* Ja! => Ende */

                move.l  D0,(a0)         /* Test Unit Ready: Drive X/Unit 0 */
                bsr.s   waitdm          /* Senden des 1. Bytes abwarten */
                bne.s   acsiw2

                moveq   #3,D3           /* Kommandoblock uebertragen */
acsiw1:         move.l  d2,(a0)
                bsr.s   waitdm          /* Senden des Bytes abwarten */
                bne.s   acsiw2
                dbra    D3,acsiw1

                move.l  D2,(a0)         /* letztes Byte uebertragen */

                move.l  #800,D0         /* 4s */
                bsr.s   waitdm1         /* warten auf DMA-IRQ */
                bne.s   acsiw2

                move.w  (a0),D0         /* ACSI-Status holen */
                and.w   #$00FF,D0

acsiw2:         move.w  D4,(a1)         /* #$0088 Attention! */
                move.l  D4,(a0)

                move.w  #$0080,(a1)     /* auf FDC zurueckschalten */

                sf      (_flock).w      /* DMA-Zugriff wieder freigeben */

                tst.w   D0
                rts

waitdm:         moveq   #20,D0          /* 100ms */
waitdm1:        add.l   (_hz_200).w,D0  /* auf DMA-IRQ warten */
waitdm2:        btst    #5,$FFFFFA01.w  /* DMA-Interrupt? */
                beq.s   waitdm3         /* Ja! => Ende */
                cmp.l   (_hz_200).w,D0  /* Zeit abgelaufen? */
                bhi.s   waitdm2         /* Nein! => nochmal */
                moveq   #-1,D0          /* NE, falls Fehler */
waitdm3:        rts

prefix_txt:     DC.B $1B,'H',$0A,' ',0
wait_txt:       DC.B $1B,'E',$0A,' .. Warte auf DMA '
                dc.b HD_WAITDEVICE+'0'
                dc.b $0D,$0A
                DC.B " Platten-Warter ",$bd,"'92 by EWK",$0D,$0A,$0A
                DC.B ' ',$1B,'p',' Shift+Shift = Abbruch ',$1B,'q',0
clr_scr:        DC.B $1B,'E',0
				even
