********************************************************************************
* RESETTOS V1.7 fuer alle RAM-TOS:                                             *
* Loescht den gesamten Speicher (ST-RAM und TT-Fast-RAM). RESETTOS dient zum   *
* kompletten Entfernen eines resetfest gemachten RAM-TOS aus dem Speicher.     *
*                                                                              *
* (C)1992-93 Markus Heiden                                          20.08.1993 *
********************************************************************************

version         EQU '1'
revision        EQU '7'

/* PART 'AES/VDI-Library-EQUs' */
/************************************************************************
 * Die AES-"Library"                                                    *
 ************************************************************************/
appl_init       EQU $0A000100
appl_exit       EQU $13000100
form_alert      EQU $34010101

                TEXT

				movea.l    4(a7),a6
				lea.l      ($00000500).w,a5
				adda.l     12(a6),a5
				adda.l     20(a6),a5
				adda.l     28(a6),a5
				move.l     a5,d1
				and.b      #$FE,d1
				add.l      a6,d1
				movea.l    d1,a7
				move.l     a5,-(a7)
				move.l     a6,-(a7)
				move.l     #$004A0000,-(a7) ; Mshrink
				trap       #1
				lea.l      12(a7),a7
				tst.l      d0
				bne.s      quit

				move.l     #appl_init,d0
				bsr        _aes
				addq.w     #1,d0
				beq.s      quit

                lea     get_os_base(PC),a0 ;OS-Basisadresse holen
                bsr     supexec

				tst.b      ramtos_flag
				beq.s      notos
				lea.l      alert_msg(pc),a0
				moveq.l    #1,d0
				bra.s      ask
notos:
				lea.l      noramtos_msg(pc),a0
				moveq.l    #3,d0
ask:
				lea        control(pc),a1
                move.l     a0,addr_in-control(a1)
                move.w     d0,int_in-control(a1)
				move.l     #form_alert,d0
				bsr        _aes

				cmp.w      #3,d0
				beq.s      exit
				subq.w     #2,d0
				move.w     d0,loadflag
		
				tst.b      ramtos_flag
				beq.s      noload
				move.l     #appl_exit,d0
				bsr        _aes
                lea     reset(PC),a0    ;Resetroutine
                bsr     supexec         ;im Supervisormodus
				illegal

noload:

                lea     prevent_load(PC),a0    ;Resetroutine
                bsr     supexec         ;im Supervisormodus

exit:
				move.l     #appl_exit,d0
				bsr        _aes

quit:
                clr.w   -(SP)           ;Programm
                trap    #1              ;beenden

                illegal                 ;Abbruch, falls Gemdos doch zurueckkehrt


****************************************
* Supervisor-Subroutinen

get_os_base:    movea.l $04F2.w,A0      ;Systemheaderadresse holen
                move.l  8(A0),d0        ;OS-Basisadresse holen
                cmp.l   #$00E00000,D0   ;ROM-TOS aktiv?
                bcs.s   found           ;Nein! => RAM-TOS loeschen
                cmp.l   #$01000000,D0   ;ROM-TOS aktiv?
                bcc.s   found          ;Nein! => RAM-TOS loeschen
				sf      ramtos_flag
				rts
found:
				st      ramtos_flag
				rts

prevent_load:
		moveq.l    #0,d0
		move.w     loadflag(pc),d1
		beq.s      prev1
		move.l     #'NoLo',d0
prev1:
		move.l     d0,($000003FC).w
		rts

****************************************
* Loeschroutine ins Lowlevelmemory kopieren:

reset:
                ori     #$0700,SR       ;Interrupts sperren
		move.l     ($000005A0).w,d0
		beq.s      not_030

		movea.l    d0,a0
searchcookie:
		move.l     (a0)+,d0
		beq.s      not_030
		cmp.l      #'_CPU',d0
		beq.s      cpufound
		addq.l     #4,a0
		bra.s      searchcookie
cpufound:
		move.l     (a0),d0
		cmp.l      #20,d0
		bcs.s      not_030

		lea.l      not_030(pc),a0
		move.l     a0,($00000010).w
		move.l     a0,($0000002C).w

		move.l  #$00000808,D0                 ;Nur fuer den TT (TOS3.06)
		dc.w    $4e7b,2      ; MOVEC     D0,CACR
		moveq   #0,D0
		dc.w    $4e7b,$0801    ; MOVEC     D0,VBR
		lea.l   zero(pc),a0
		dc.w    $f010,$4000      ; PMOVE     (a0),TC
		dc.w    $f010,$0800      ; PMOVE     (a0),TT0
		dc.w    $f010,$0c00      ; PMOVE     (a0),TT1

not_030:
                moveq   #(rst_end-rst_st)/4,D0
                lea     rst_st(PC),A0 ;Resetroutine
                lea     $0000000C.w,A1  ;nach $C
copy1:          move.l  (A0)+,(A1)+     ;kopieren
                dbf     d0,copy1
                jmp     $0000000C.w     ;und starten


****************************************
* Loeschroutine fuer das ST-RAM

rst_st:         lea     rst_tt(PC),A0 ;Buserrorvektor auf
                move.l  A0,8.w          ;TT-RAM-Loesch-Routine setzen

                moveq   #0,D1           ;Datenregister mit 0 zum ueberschreiben des Speichers laden
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movea.l D1,A1
                movea.l D1,A2
                movea.l D1,A3
                movea.l D1,A4
                movea.l D1,A5
                movea.l D1,A6

                lea     rst_end(PC),A0 ;ST-Ram ab Routinenende

rst_st1:        movem.l D1-D7/A1-A6,(A0) ;loeschen
                movem.l D1-D7/A1-A6,$0034(A0)
                movem.l D1-D7/A1-A6,$0068(A0)
                movem.l D1-D7/A1-A6,$009C(A0)
                movem.l D1-D7/A1-A5,$00D0(A0)
                lea     $0100(A0),A0    ;naechste Speicher-Seite berechnen
                bra.s   rst_st1    ;bis Buserror schreiben


****************************************
* Loeschroutine fuer das TT-Ram

rst_tt:         move.l  4.w,8.w         ;Buserror => Reset

				move.w     loadflag(pc),d0
				beq.s      rst_tt0
				move.l     #'NoLo',($000003FC).w

rst_tt0:
                lea     $01000000,A0    ;Fast-Ram ab Anfang

rst_tt1:        movem.l D1-D7/A1-A6,(A0) ;loeschen
                movem.l D1-D7/A1-A6,$0034(A0)
                movem.l D1-D7/A1-A6,$0068(A0)
                movem.l D1-D7/A1-A6,$009C(A0)
                movem.l D1-D7/A1-A5,$00D0(A0)
                lea     $0100(A0),A0    ;naechste Speicherseite berechnen
                bra.s   rst_tt1    ;bis Buserror (=Reset) loeschen

loadflag:       dc.w -1

rst_end:

/*************************************************************************
 * Mein eigener kleiner AES-Aufruf                                       *
 * D0=Die ersten 4 Eintraege im control-Array (Bytebreite!)              *
 *    Bit 24-31 = Der Opcode bzw. die Funktionsnummer                    *
 *    Bit 16-23 = Anzahl der Eintraege in int_in                         *
 *    Bit 8-15  = Anzahl der Eintraege in int_out                        *
 *    Bit 0-7   = Anzahl der Eintraege in addr_in                        *
 * Die Anzahl der Eintraege in addr_out ist stets 0.                     *
 * Ausnahme:Bei rsrc_gaddr() sollte dort eine 1 stehen (Atari haelt sich *
 *          allerdings selbst nicht dran)                                *
 *************************************************************************/
_aes:
				movem.l    d1-d7/a0-a6,-(a7)
				lea        control(pc),a0
				clr.l      (a0)+
				clr.l      (a0)+
				clr.w      (a0)
				movep.l    d0,-7(a0)
				lea.l      _aes_pb(pc),a0
				move.l     a0,d1
				move.w     #200,d0
				trap       #2
				movem.l    (a7)+,d1-d7/a0-a6
				moveq.l    #0,d0
				move.w     int_out(pc),d0
				rts

supexec:        move.l  a0,-(sp)
                move.w  #$26,-(SP)      ;Supexec
                trap    #14             ;(XBIOS 38)
                addq.l  #6,SP
                rts


****************************************
* Datenbereich

                DATA

zero:           dc.l 0

_aes_pb:
	dc.l control
	dc.l global
	dc.l int_in
	dc.l int_out
	dc.l addr_in
	dc.l addr_out

alert_msg:
	DC.B '[1][RESETTOS V',version,'.',revision,' (03.01.1996)|l',$94,'scht das RAM-TOS aus dem Speicher.|'
	dc.b 'Soll ein Nachladen mit LOADTOS|verhindert werden?][Ja|Nein|Abbruch]',0
noramtos_msg:
	DC.B '[1][RESETTOS V',version,'.',revision,' (03.01.1996)|Es ist kein RAM-TOS aktiv.|'
	dc.b 'Soll nur ein Nachladen mit|LOADTOS verhindert werden?][Ja|Nein|Abbruch]',0
	
cover_msg:
                DC.B '>>> RESETTOS V',version,'.',revision,' - ',$bd,'1992-96 Markus Heiden / ',$bd,'1994 EWK <<<',0
				even

				BSS
ramtos_flag:    ds.b 1
				even
control:        ds.w 16
global:         ds.w 15
addr_in:        ds.l 3
addr_out:       ds.l 1
int_in:         ds.w 16
int_out:        ds.w 16
