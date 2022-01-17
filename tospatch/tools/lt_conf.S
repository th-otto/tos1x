/********************************************************************************
 * LoadTos Configuration V1.0:                                                  *
 * Dient zum Einstellen der Defaults im LoadTos-Prg (AUTO_206.PRG).             *
 *                                                                              *
 * (C)1993 Markus Heiden                                             01.09.1993 *
 ********************************************************************************/

version         EQU '1'
revision        EQU '2'

COUNTRY         equ 1

/* PART 'RSC-Definitionen' */
/****************************************
 * Resource Datei Indizes fuer AUTOCONF
 ****************************************/
#include "autoconf.si"
/* ENDPART */

/* PART 'AES/VDI-Library-EQUs' */
/************************************************************************
 * Die AES-"Library"                                                    *
 ************************************************************************/
appl_init       EQU $0A000100
appl_read       EQU $0B020101
appl_write      EQU $0C020101
appl_find       EQU $0D000101
appl_tplay      EQU $0E020101
appl_trecord    EQU $0F010101
appl_bvset      EQU $10020100   /* ab GEM 2.0 */
appl_yield      EQU $11000100   /* ab GEM 2.0 */
appl_exit       EQU $13000100

evnt_keybd      EQU $14000100
evnt_button     EQU $15030500
evnt_mouse      EQU $16050500
evnt_mesag      EQU $17000101
evnt_timer      EQU $18020100
evnt_multi      EQU $19100701
evnt_dclick     EQU $1A020100

menu_bar        EQU $1E010101
menu_icheck     EQU $1F020101
menu_ienable    EQU $20020101
menu_tnormal    EQU $21020101
menu_text       EQU $22010102
menu_register   EQU $23010101
menu_unregister EQU $24010100   /* ab GEM 2.0 */

objc_add        EQU $28020101
objc_delete     EQU $29010101
objc_draw       EQU $2A060101
objc_find       EQU $2B040101
objc_offset     EQU $2C010301
objc_order      EQU $2D020101
objc_edit       EQU $2E040201
objc_change     EQU $2F080101

form_do         EQU $32010101
form_dial       EQU $33090100
form_alert      EQU $34010101
form_error      EQU $35010100
form_center     EQU $36000501
form_keybd      EQU $37030301
form_button     EQU $38020201

graf_rubberbox  EQU $46040300
graf_rubbox     EQU $46040300   /* dies ist der richtige Name! */
graf_dragbox    EQU $47080300
graf_movebox    EQU $48060100
graf_mbox       EQU $48060100   /* dies ist der richtige Name! */
graf_growbox    EQU $49080100
graf_shrinkbox  EQU $4A080100
graf_watchbox   EQU $4B040101
graf_slidebox   EQU $4C030101
graf_handle     EQU $4D000500
graf_mouse      EQU $4E010101
graf_mkstate    EQU $4F000500

srcp_read       EQU $50000101
srcp_write      EQU $51000101
scrp_clear      EQU $52000100   /* ab GEM 2.0 */

fsel_input      EQU $5A000202
fsel_exinput    EQU $5B000203   /* ab TOS 1.4 */

wind_create     EQU $64050100
wind_open       EQU $65050100
wind_close      EQU $66010100
wind_delete     EQU $67010100

wind_get        EQU $68020500
wind_set        EQU $69060100
wind_find       EQU $6A020100
wind_update     EQU $6B010100
wind_calc       EQU $6C060500
wind_new        EQU $6D000000   /* ab TOS 1.4 */

rsrc_load       EQU $6E000101
rsrc_free       EQU $6F000100
rsrc_gaddr      EQU $70020100
rsrc_saddr      EQU $71020101
rsrc_obfix      EQU $72010101

shel_read       EQU $78000102
shel_write      EQU $79030102
shel_get        EQU $7A010101
shel_put        EQU $7B010101
shel_find       EQU $7C000101
shel_envrn      EQU $7D000102
shel_rdef       EQU $7E000102   /* ab GEM 2.0 */
shel_wdef       EQU $7F000002   /* ab GEM 2.0 */

xgrf_stepcalc   EQU $82060600   /* ab GEM 2.0 */
xgrf_2box       EQU $83090100   /* ab GEM 2.0 */

/* Die Messages des AES */
MN_SELECTED     EQU 10          /* Menueeintrag angewaehlt */
WM_REDRAW       EQU 20          /* Teil eines Windows muss neu gezeichnet werden */
WM_TOPPED       EQU 21          /* Window ist nun das aktuelle Fenster */
WM_CLOSED       EQU 22          /* Window soll geschlossen werden */
WM_FULLED       EQU 23          /* Window soll auf max.Groesse gebracht werden */
WM_ARROWED      EQU 24          /* Scollbalken angeklickt */
WM_HSLID        EQU 25          /* Der horizontale Slider wurde bewegt */
WM_VSLID        EQU 26          /* Der vertikale Slider wurde bewegt */
WM_SIZED        EQU 27          /* Die Groesse des Windows wurde geaendert */
WM_MOVED        EQU 28          /* Das Window wurde bewegt */
WM_NEWTOP       EQU 29          /* Das Fenster wurde aktiviert (siehe WM_TOPPED) */
WM_UNTOPPED     EQU 30          /* Der Fenster wird gleich inaktiv (erst ab GEM 2.0!) */
AC_OPEN         EQU 40          /* Ein Acc wurde angeklickt.(30 bzw. 31 ist FALSCH!) */
AC_CLOSE        EQU 41          /* Prg wurde beendet, ACC soll seinen Speicher freigeben. */
CT_UPDATE       EQU 50
CT_MOVE         EQU 51          /* Funktion unbekannt */
CT_NEWTOP       EQU 52

/* WM_ARROWED angeklickt (nun die genauere Definition) */
WA_UPPAGE       EQU 0           /* Balken oberhalb des Sliders */
WA_DNPAGE       EQU 1           /* Balken unterhalb des Sliders */
WA_UPLINE       EQU 2           /* Pfeil nach oben */
WA_DNLINE       EQU 3           /* Pfeil nach unten */
WA_LFPAGE       EQU 4           /* Balken links vom Slider */
WA_RTPAGE       EQU 5           /* Balken rechts vom Slider */
WA_LFLINE       EQU 6           /* Pfeil nach links */
WA_RTLINE       EQU 7           /* und Pfeil nach rechts */

/* Die Objekttypen des Resource-Baumes */
G_BOX           EQU 20
G_TEXT          EQU 21
G_BOXTEXT       EQU 22
G_IMAGE         EQU 23
G_PROGDEF       EQU 24
G_IBOX          EQU 25          /* Bitte in entsprechender Literatur nachschlagen */
G_BUTTON        EQU 26
G_BOXCHAR       EQU 27
G_STRING        EQU 28
G_FTEXT         EQU 29
G_FBOXTEXT      EQU 30
G_ICON          EQU 31
G_TITLE         EQU 32

/* Object-Flags bei einem Objekt */
NONE_FLG        EQU $00000000
SELECTABLE_FLG  EQU $00000001
DEFAULT_FLG     EQU $00000002
EXIT_FLG        EQU $00000004
EDITABLE_FLG    EQU $00000008
RBUTTON_FLG     EQU $00000010   /* Bitte ebenfalls in der Literatur nachlesen */
LASTOB_FLG      EQU $00000020
TOUCHEXIT_FLG   EQU $00000040
HIDETREE_FLG    EQU $00000080
INDIRECT_FLG    EQU $00000100

/* Objekt-Status bei einem Objekt */
NORMAL          EQU $00000000
SELECTED        EQU $00000001
CROSSED         EQU $00000002
CHECKED         EQU $00000004   /* s.o. */
DISABLED        EQU $00000008
OUTLINED        EQU $00000010
SHADOWED        EQU $00000020

/* Die einzelnen Bits bei evnt_multi() */
MU_KEYBD        EQU $00000001   /* Tastaturereignis */
MU_BUTTON       EQU $00000002   /* Maustastenereignis */
MU_M1           EQU $00000004   /* 1.Mausereignis */
MU_M2           EQU $00000008   /* 2.Mausereignis */
MU_MESAG        EQU $00000010   /* Message des AES */
MU_TIMER        EQU $00000020   /* Timer-Ereignis */

/* form_dial() */
FMD_START       EQU $00000000   /* Bildschirmhintergrund reservieren */
FMD_GROW        EQU $00000001   /* Ausdehnende Box zeichnen */
FMD_SHRINK      EQU $00000002   /* Schrumpfende Box zeichnen */
FMD_FINISH      EQU $00000003   /* Bildschirmbereich wieder freigeben */

/* graf_mouse() */
ARROW           EQU $00000000
TEXT_CRSR       EQU $00000001
HOURGLASS       EQU $00000002
BUSYBEE         EQU $00000002
POINT_HAND      EQU $00000003
FLAT_HAND       EQU $00000004
THIN_CROSS      EQU $00000005
THICK_CROSS     EQU $00000006
OUTL_CROSS      EQU $00000007
USER_DEF        EQU $000000FF
M_OFF           EQU $00000100
M_ON            EQU $00000101

/* Parameter bei wind_create() */
WI_NAME         EQU $00000001
WI_CLOSE        EQU $00000002
WI_FULL         EQU $00000004
WI_MOVE         EQU $00000008
WI_INFO         EQU $00000010
WI_SIZE         EQU $00000020
WI_UPARROW      EQU $00000040
WI_DNARROW      EQU $00000080
WI_VSLIDE       EQU $00000100
WI_LFARROW      EQU $00000200
WI_RARROW       EQU $00000400
WI_HSLIDE       EQU $00000800

/* Parameter bei wind_get() & wind_set() */
WF_KIND         EQU 1
WF_NAME         EQU 2
WF_INFO         EQU 3
WF_WORKXYWH     EQU 4
WF_CURRXYWH     EQU 5
WF_PREVXYWH     EQU 6
WF_FULLXYWH     EQU 7
WF_HSLIDE       EQU 8
WF_VSLIDE       EQU 9
WF_TOP          EQU 10
WF_FIRSTXYWH    EQU 11
WF_NEXTXYWH     EQU 12
WF_NEWDESK      EQU 14
WF_HSLSIZE      EQU 15
WF_VSLSIZE      EQU 16

/* wind_update() */
END_UPDATE      EQU 0
BEG_UPDATE      EQU 1
END_MCTRL       EQU 2
BEG_MCTRL       EQU 3
/* ENDPART */

/* PART 'Objekt-Header' */
/************************************************************************
 * Sigma-soft GEM-Library                                               *
 * (c)1989/90 SIgma-soft, written by Markus Fritze     18.01.1990 13:27 *
 ************************************************************************/
/************************************************************************
 * Globale Variablen:                                                   *
 ************************************************************************/
_StackSize      EQU 1024        /* 1k Stack fuer das Programm */

		text

/************************************************************************
 * Initialisierung der Library (GEMDOS & AES)                           *
 ************************************************************************/
_gem_init:      movea.l 4(SP),A6        /* Basepageadresse holen */
                movea.w #$0100+_StackSize,A5 /* Groesse der Basepage + Stackgroesse (1k) */
                adda.l  12(A6),A5       /* + Groesse des TEXT-Segments */
                adda.l  20(A6),A5       /* + Groesse des DATA-Segments */
                adda.l  28(A6),A5       /* + Groesse des BSS-Segments */
                move.l  A5,D1           /* = Gesamtlaenge des Programms */
                and.b   #$FE,D1         /* Laenge nun gerade */
                add.l   A6,D1           /* + Programmstart (Basepageadresse) */
                movea.l D1,SP           /* Stack endet dort */
                move.l  A5,-(SP)        /* Programmlaenge */
                move.l  A6,-(SP)        /* Adresse der Basepage */
                move.l  A6,basepage     /* Basepageadresse merken */
                move.l  #$004A0000,-(SP) /* Funktionsnummer + Dummyword (0) */
                trap    #1              /* Mshrink(0,Basepageadr,Prglaenge) */
                lea     12(SP),SP       /* Nur noch den Stack korrigieren */

				moveq.l    #-1,d7
				tst.l      d0
				bne        _pterm

                move.l  #appl_init,D0
                bsr     _aes            /* Programm als GEM-Applikation anmelden */
                moveq   #-1,D7          /* -1: appl_init() Fehler (kann beim */
                addq.w  #1,D0           /* aktuellen GEM nie (!) auftreten!) */
                beq     _pterm          /* keine ID fuer das Programm => Ende */
/* ENDPART */

/********************************************************************************
 * Intitialisierung der Resourcen
 ********************************************************************************/
/********************************************************************************
 * (C) Andreas Alich, 06.01.90                                                  *
 ********************************************************************************/

rsc_init:       lea     rsc(PC),A0
                move.l  A0,D2

                movea.l A0,A1
                adda.w  2(A0),A1        /* A1 = ptr to objects */
                movea.l A0,A2
                adda.w  4(A0),A2        /* A2 = ptr to tedinfos */
#if 0
                movea.l A0,A3
                adda.w  6(A0),A3        /* A3 = pointer to iconblks */
                movea.l A0,A4
                adda.w  8(A0),A4        /* A4 = pointer to bitblks */
#endif

                move.w  20(A0),D0       /* Anzahl der Objekte = 0? */
                beq.s   rscini1         /* Ja! => */

ob_init:        move.w  6(A1),D1
                cmp.w   #G_BOX,D1
                beq.s   next_ob
                cmp.w   #G_IBOX,D1
                beq.s   next_ob
                cmp.w   #G_BOXCHAR,D1
                beq.s   next_ob
                cmp.w   #G_PROGDEF,D1
                beq.s   next_ob
                add.l   D2,12(A1)
next_ob:        lea     24(A1),A1
                subq.w  #1,D0
                bne.s   ob_init

rscini1:        move.w  24(A0),D0       /* Anzahl der Tedinfos = 0? */
                beq.s   rscini2         /* Ja! => */

te_init:        add.l   D2,(A2)+
                add.l   D2,(A2)+
                add.l   D2,(A2)
                lea     20(A2),A2
                subq.w  #1,D0
                bne.s   te_init

rscini2: ds.b 0
#if 0
                move.w  26(A0),D0       /* Anzahl der Iconblocks = 0? */
                beq.s   rscini3         /* Ja! => */

ib_init:        add.l   D2,(A3)+
                add.l   D2,(A3)+
                add.l   D2,(A3)
                lea     26(A3),A3
                subq.w  #1,D0
                bne.s   ib_init

rscini3:        move.w  28(A0),D0
                beq.s   rscini4

bb_init:        add.l   D2,(A4)
                lea     14(A4),A4
                subq.w  #1,D0
                bne.s   bb_init

rscini4: ds.b 0
#endif
                movea.l A0,A1
                adda.w  18(A0),A1
                movea.l CONF*4(A1),A2
                adda.l  A0,A2
                move.l  A2,conf_addr

                movea.l A0,A1
                adda.w  2(A0),A1

                move.l  TOS_FILE*24+12(A1),tos_addr
                movea.l MSG*24+12(A1),A2
                movea.l (A2),A2
                move.b  #version,23(A2)
                move.b  #revision,25(A2)
                move.l  LT_FILE*24+12(A1),lt_addr
                move.l  TIME*24+12(A1),time_addr

                move.w  20(A0),D7
                subq.w  #1,D7
fix_obj:        move.w  D7,int_in
                move.l  conf_addr(PC),addr_in
                move.l  #rsrc_obfix,D0
                bsr     _aes
                subq.w  #1,D7
                bpl.s   fix_obj

/****************************************
 * Hauptprogramm
 ****************************************/
init:           movea.l basepage(PC),A0
                lea     128(A0),A0      /* Zeiger auf die Commandline */
                moveq   #0,D0
                move.b  (A0)+,D0        /* Filename angegeben? */
                beq.s   init1           /* Nein! => */
                cmp.b   #126,D0         /* Commandline zu lang? */
                bhi.s   init1           /* Ja! => */
                clr.b   0(A0,D0.w)      /* Commandline mit einem Nullbyte abschliessen */
                bra.s   init2

init1:          lea     default_lt(PC),A0 /* Default-LoadTos benutzen */

init2:          lea     fsell_path(PC),A1 /* Pfad und Filenamen trennen */
                lea     fsell_file(PC),A2
                bsr     convert

                lea     fsell_path(PC),A0
                lea     fsell_file(PC),A1
                bsr     copy

init3:          lea     file(PC),A0
                lea     fsel_path(PC),A1
                lea     fsel_file(PC),A2
                bsr     reconvert

                bsr     open_file       /* LoadTos laden */
                bmi.s   init5           /* Fehler! => */

                bsr     get_data        /* Daten aus LoadTos auslesen */
                bpl.s   init7           /* O.K.! => */


init5: ds.b 0
#if 0
                bsr.s   draw_dial       /* Dialogbox zeichnen */
                bsr     end_dial
#endif

                lea     lt_txt(PC),A2
                bsr     fsel
                bmi.s   general_error
                bne.s   init3
                bra.s   init8


init7:          lea     fsell_path(PC),A0 /* Pfad und */
                lea     fsell_file(PC),A1 /* Name des LoadTos */
                bsr     recopy          /* holen */

                bsr     do_dial
                bmi.s   general_error

init8:          moveq   #0,D0

/* PART 'Exit' */
/************************************************************************
 * Verlassen des Programms                                              *
 ************************************************************************/
_gem_exit:      move.w  D0,D7           /* Exit-Status merken */

_do_pterm:      move.l  #appl_exit,D0
                bsr     _aes            /* Applikation wieder abmelden */

_pterm:         move.w  D7,-(SP)        /* Fehlercode */
                move.w  #$004C,-(SP)
                trap    #1              /* Pterm(Fehlercode) */
/* ENDPART */

/****************************************
 * Fehlerbehandlung
 ****************************************/
general_error:  lea     gen_error_txt(PC),A0
                bra.s   do_error
rsc_error:      lea     rsc_err_txt(PC),A0

do_error:       move.w  #1,int_in
                move.l  A0,addr_in
                move.l  #form_alert,D0
                bsr     _aes

                moveq   #1,D0
                bra.s   _gem_exit

/****************************************
 * Subroutinen
 ****************************************/
/* Zeichnet die Dialogbox CONF */

center_dial:    move.l  conf_addr(PC),addr_in
                move.l  #form_center,D0
                bsr     _aes
                lea     int_out+2(PC),A0
                lea     dial_xywh(PC),A1
                moveq   #4-1,D0
centdia1:       move.w  (A0)+,(A1)+
                dbra    D0,centdia1
				rts

draw_dial:
                move.w  #BEG_UPDATE,int_in
                move.l  #wind_update,D0
                bsr     _aes

                lea     int_in(PC),A0
                move.w  #FMD_START,(a0)+
                lea     dial_xywh(PC),A1
                moveq   #4-1,D0
drawdia4:       move.w  (A1)+,(A0)+
                dbra    D0,drawdia4
                lea     dial_xywh(PC),A1
                moveq   #4-1,D0
drawdia5:       move.w  (A1)+,(A0)+
                dbra    D0,drawdia5

                move.l  #form_dial,D0
                bsr     _aes
                beq.s   drawdia2
                moveq   #0,D0
                rts
drawdia2:       moveq   #-1,D0
                rts

redrawdia:      bsr.s   center_dial
                bsr     init_keys

                lea     int_in(PC),A0
                move.w  #0,(A0)+
                move.w  #1,(A0)+
                moveq   #4-1,D0
                lea     dial_xywh(PC),A1
drawdia1:       move.w  (A1)+,(A0)+
                dbra    D0,drawdia1
                move.l  conf_addr(PC),addr_in
                move.l  #objc_draw,D0
                bsr     _aes
                beq.s   drawdia3
                moveq   #0,D0
                rts
drawdia3:
                moveq   #-1,D0
                rts

/************************************************
 * Intitialisiert die Anzeigen der Dialogbox CONF
 ************************************************/
init_dial:      lea     file(PC),A0
                lea     fselt_path(PC),A1
                lea     fselt_file(PC),A2
                bsr     reconvert

                movea.l tos_addr(PC),A1
                movea.l (A1),A1
                moveq   #40-1,D0
initdia1:       move.b  (A0)+,(A1)+
                dbeq    D0,initdia1
                bne.s   initdia3
initdia2:       clr.b   (A1)+
                dbra    D0,initdia2

initdia3:       lea     file(PC),A0
                lea     fsell_path(PC),A1
                lea     fsell_file(PC),A2
                bsr     reconvert

                movea.l lt_addr(PC),A1
                movea.l (A1),A1
                moveq   #40-1,D0
initdia4:       move.b  (A0)+,(A1)+
                dbeq    D0,initdia4
                bne.s   initdia6
initdia5:       clr.b   (A1)+
                dbra    D0,initdia5

initdia6:       movea.l time_addr(PC),A0
                movea.l (A0),A0
                move.l  startup_time(PC),D0
                bsr     set_time

init_keys:      lea     hotkey_tab(PC),A0
                moveq   #0,D7
initdia8:       move.b  hot_keys(PC),D6
                move.w  #NORMAL,D1
                btst    D7,D6
                beq.s   initdia7
                move.w  #SELECTED,D1
initdia7:       move.w  (A0)+,D0
                moveq   #0,D2
                movem.l D7-A0,-(SP)
                bsr     change_obj
                movem.l (SP)+,D7-A0
                addq.l  #1,D7
                cmp.l   #5,D7
                blo.s   initdia8

                rts

/****************************************
 * Fuehrt die Dialogbox CONF aus
 ****************************************/
do_dial:        bsr     init_dial
                bsr     center_dial
                bsr     draw_dial
                bmi.s   do_dial3
                bsr     redrawdia
                bmi.s   do_dial3

do_dial4:       move.w  #TOS_FILE,int_in
                move.l  conf_addr(PC),addr_in
                move.l  #form_do,D0
                bsr     _aes

                move.w  D0,D1
                moveq   #0,D0
                btst    #15,D1
                beq.s   do_dial0
                moveq   #1,D0
do_dial0:       and.w   #$7FFF,D1
                cmp.w   #20,D1
                bhs.s   do_dial4

                tst.l   D0
                bne.s   do_dial1
                cmp.w   last_obj(PC),D1
                bne.s   do_dial1
                addq.l  #1,last_cnt
                bra.s   do_dial2
do_dial1:       move.w  D1,last_obj
                clr.l   last_cnt

do_dial2:       lsl.w   #2,D1
                lea     aktion_tab(PC),A0
                movea.l 0(A0,D1.w),A0
                jsr     (A0)
                tst.l   D0
                bmi.s   do_dial3
                bne.s   do_dial4
do_dial3:       rts

none:           moveq   #1,D0
                rts

/****************************************
 * Beendet die Dialogbox CONF
 ****************************************/
end_dial:       lea     int_in(pc),a0
                move.w  #FMD_FINISH,(a0)+
				lea.l      dial_xywh(pc),a1
				moveq.l    #3,d0
enddia1:
				move.w     (a1)+,(a0)+
				dbf        d0,enddia1
				lea.l      dial_xywh(pc),a1
				moveq.l    #3,d0
enddia2:
				move.w     (a1)+,(a0)+
				dbf        d0,enddia2
                move.l  #form_dial,D0
                bsr     _aes
                beq.s   enddia3
				move.w     #END_UPDATE,int_in
				move.l     #wind_update,d0
				bsr        _aes
				moveq.l    #0,d0
                rts
enddia3:        moveq   #-1,D0
                rts

/****************************************
 * Subroutinen fuer die Dialogbox CONF
 ****************************************/
/* Cancel */
do_cancel:      move.w  #CANCEL,D0
                move.w  #SHADOWED,D1
                moveq   #1,D2
                bsr     change_obj
                bsr     end_dial
                bmi.s   do_canc1
                moveq   #0,D0
do_canc1:
                rts

/* Time +/- */

do_inc:         movea.l time_addr(PC),A0
                movea.l (A0),A0

                tst.l   D0
                beq.s   do_inc2
                move.l  #100*60-1,D0
                bra.s   do_inc1

do_inc2:        bsr     get_time
                moveq   #1,D1
                cmpi.l  #10,last_cnt
                blo.s   do_inc0
                moveq   #2,D1
                cmpi.l  #20,last_cnt
                blo.s   do_inc0
                moveq   #5,D1
                cmpi.l  #26,last_cnt
                blo.s   do_inc0
                moveq   #10,D1
                cmpi.l  #32,last_cnt
                blo.s   do_inc0
                moveq   #30,D1
                cmpi.l  #36,last_cnt
                blo.s   do_inc0
                moveq   #60,D1
do_inc0:        add.w   D1,D0
                cmp.w   #100*60-1,D0
                bls.s   do_inc1
                moveq   #0,D0
                cmp.w   #1,D1
                beq.s   do_inc1
                move.w  #100*60-1,D0
do_inc1:        bsr     set_time
                bra.s   do_incdec

do_dec:         movea.l time_addr(PC),A0
                movea.l (A0),A0

                tst.l   D0
                beq.s   do_dec2
                moveq   #0,D0
                bra.s   do_dec1

do_dec2:        bsr     get_time
                moveq   #1,D1
                cmpi.l  #10,last_cnt
                blo.s   do_dec0
                moveq   #2,D1
                cmpi.l  #20,last_cnt
                blo.s   do_dec0
                moveq   #5,D1
                cmpi.l  #26,last_cnt
                blo.s   do_dec0
                moveq   #10,D1
                cmpi.l  #32,last_cnt
                blo.s   do_dec0
                moveq   #30,D1
                cmpi.l  #36,last_cnt
                blo.s   do_dec0
                moveq   #60,D1
do_dec0:        sub.w   D1,D0
                cmp.w   #100*60-1,D0
                bls.s   do_dec1
                moveq   #0,D0
                cmp.w   #1,D1
                bne.s   do_dec1
                move.w  #100*60-1,D0
do_dec1:        bsr.s   set_time
/*                bra     do_incdec */

do_incdec:      lea     int_in(PC),A0
                move.w  #TIME,(A0)+
                clr.w   (A0)+
                moveq   #4-1,D0
                lea     dial_xywh(PC),A1
do_incd1:       move.w  (A1)+,(A0)+
                dbra    D0,do_incd1
                move.l  conf_addr(PC),addr_in
                move.l  #objc_draw,D0
                bsr     _aes
                moveq   #1,D0
                tst.w   int_out
                bne.s   do_incd2
                moveq   #-1,D0
do_incd2:       rts

get_time:       lea     timetab(PC),A1
                lea     timetab2(PC),A2
                moveq   #0,D0
                moveq   #0,D1
gettim1:        moveq   #0,D2
                move.b  0(A0,D1.w),D2
                sub.b   #'0',D2
                cmp.b   0(A2,D1.w),D2
                bhi.s   gettim2
                mulu    (A1)+,D2
                add.w   D2,D0
                addq.w  #1,D1
                cmp.w   #4,D1
                blo.s   gettim1
gettim2:        rts

set_time:       move.l  D0,startup_time
                lea     timetab(PC),A1
                moveq   #0,D1
settim1:        divu    (A1)+,D0
                add.b   #'0',D0
                move.b  D0,0(A0,D1.w)
                clr.w   D0
                swap    D0
                addq.w  #1,D1
                cmp.w   #4,D1
                blo.s   settim1
                rts

/* Undo */

do_undo:        move.w  #UNDO,D0
                move.w  #SHADOWED,D1
                moveq   #1,D2
                bsr     change_obj

                bsr     get_data
                bmi.s   do_undo1

                bsr     init_dial
                bsr     redrawdia
                bmi.s   do_undo1

                moveq   #1,D0
do_undo1:       rts

/********************
 * TOS speichern
 ********************/
do_save:        move.w  #SAVE,D0
                move.w  #SHADOWED,D1
                moveq   #1,D2
                bsr     change_obj
                bsr     end_dial
                bmi     do_save3

                lea     fsell_path(PC),A0
                lea     fsell_file(PC),A1
                lea     lt_save_txt(PC),A2
                bsr     fsel_direct
                bmi.s   do_save3
                beq.s   do_save2

                movea.l patch_addr(PC),A0
                move.b  hot_mask(PC),(A0)
                move.b  hot_keys(PC),1(A0)

                move.l  startup_time(PC),D0
                lsl.l   #3,D0
                move.l  D0,D1
                lsl.l   #3,D0
                add.l   D0,D1
                add.l   D0,D0
                add.l   D0,D1
                move.l  D1,2(A0)

                lea     16(A0),A0       /* Tospfad und -name aus Dialogbox lesen */
                movea.l A0,A1
                moveq   #128-1,D0
do_save7:       clr.b   (A1)+
                dbra    D0,do_save7

                movea.l A0,A1
                movea.l tos_addr(PC),A2
                movea.l (A2),A2
                moveq   #40-1,D0
do_save5:       move.b  (A2)+,(A1)+
                dbeq    D0,do_save5
                beq.s   do_save6

                lea     fselt_path(PC),A1 /* Falls laenger als 40 Zeichen, */
                lea     fselt_file(PC),A2 /* Tospfad und -name aus Fileselector- */
                bsr     reconvert       /* Variablen lesen */

do_save6:       lea     file(PC),A0
                lea     fsell_path(PC),A1
                lea     fsell_file(PC),A2
                bsr     reconvert

                bsr     save_file
                tst.l   D0
                bmi.s   do_save3

                moveq   #0,D0
                rts

do_save2:       bsr     center_dial
                bsr     draw_dial
                bsr     redrawdia
                moveq   #1,D0
                rts

do_save3:       moveq   #-1,D0
                rts

/********************
 * TOS auswaehlen
 ********************/
sel_tos:        tst.l   D0
                beq.s   sel_tos3

                bsr     end_dial
                bmi.s   sel_tos4

                lea     fselt_path(PC),A0
                lea     fselt_file(PC),A1
                bsr     copy
                lea     tos_txt(PC),A2
                bsr     fsel
                bmi.s   sel_tos4
                beq.s   sel_tos2

                lea     fselt_path(PC),A0
                lea     fselt_file(PC),A1
                bsr     recopy
                bsr     init_dial

sel_tos2:       bsr     center_dial
                bsr     draw_dial
                bsr     redrawdia
sel_tos3:       moveq   #1,D0
                rts

sel_tos4:       moveq   #-1,D0
                rts

/********************
 * LoadTos auswaehlen
 ********************/

sel_lt:         tst.l   D0
                beq.s   sel_lt2a

                bsr     end_dial
                bmi.s   sel_lt3

                lea     fsell_path(PC),A0
                lea     fsell_file(PC),A1
                bsr     copy

sel_lt1:        lea     lt_txt(PC),A2
                bsr     fsel
                bmi.s   sel_lt3
                beq.s   sel_lt2

                lea     file(PC),A0
                lea     fsel_path(PC),A1
                lea     fsel_file(PC),A2
                bsr     reconvert

                bsr     open_file       /* LoadTos laden */
                bmi.s   sel_lt1         /* Fehler! => Nochmal */

                bsr     get_data        /* Daten aus LoadTos auslesen */
                bmi.s   sel_lt1         /* Fehler! => Nochmal */

                lea     fsell_path(PC),A0
                lea     fsell_file(PC),A1
                bsr     recopy
                bsr     init_dial

sel_lt2:        bsr     center_dial
                bsr     draw_dial
                bsr     redrawdia
sel_lt2a:       moveq   #1,D0
                rts

sel_lt3:        moveq   #-1,D0
                rts

/********************
 * Hotkey-Buttons
 ********************/
do_ctrl:        moveq   #$04,D0
                bra.s   do_button
do_lshift:      moveq   #$02,D0
                bra.s   do_button
do_alt:         moveq   #$08,D0
                bra.s   do_button
do_rshift:      moveq   #$01,D0
                bra.s   do_button
do_caps:        moveq   #$10,D0

do_button:      move.b  hot_keys(PC),D1
                eor.b   D0,D1
                move.b  D1,hot_keys
                move.b  D1,hot_mask
                moveq   #1,D0
                rts

/****************************************
 * Filebehandlung-Subroutinen
 ****************************************
/* Convertiert einen Filestring in Pfad- und Filestring */

convert:        clr.b   (A1)            /* Pfad */
                clr.b   (A2)            /* und Filenamen loeschen */

                tst.b   (A0)            /* 0-String? */
                beq.s   convert7        /* Ja! => Ende */

                movea.l A0,A6
convert1:       tst.b   (A6)+           /* Stringende suchen */
                bne.s   convert1
convert2:       cmpi.b  #'\',-(A6)      /* Pfad-Ende/Filenamen-Anfang suchen */
                beq.s   convert4
                cmpa.l  A0,A6
                bhi.s   convert2

convert3:       move.b  (A6)+,D0        /* Kein Pfad gefunden: */
                move.b  D0,(A2)+        /* Filenamen kopieren */
                bne.s   convert3
                rts

convert4:       addq.l  #1,A6           /* Pointer auf Filenamen-Anfang */
                movea.l A6,A5
convert5:       move.b  (A6)+,D0        /* Filenamen kopieren */
                move.b  D0,(A2)+
                bne.s   convert5
                movea.l A0,A6
convert6:       move.b  (A6)+,(A1)+     /* Pfad kopieren */
                cmpa.l  A5,A6
                blo.s   convert6

convert7:       rts

/****************************************
 * Erzeugt aus Pfadstring und Filestring einen String mit beidem
 ****************************************/
reconvert:      movea.l A0,A6
reconv1:        move.b  (A1)+,(A6)+
                bne.s   reconv1
reconv1a:       cmpi.b  #'\',-(A6)
                beq.s   reconv3
                cmpa.l  A0,A6
                bhi.s   reconv1a

reconv2:        move.b  (A2)+,(A6)+
                bne.s   reconv2
                rts

reconv3:        addq.l  #1,A6
reconv4:        move.b  (A2)+,(A6)+
                bne.s   reconv4
                rts

/****************************************
 * Fileselector aufrufen
 ****************************************/
fsel:           lea     fsel_path(PC),A0
                lea     fsel_file(PC),A1
fsel_direct:    move.l  A0,addr_in
                move.l  A1,addr_in+4
                move.l  A2,addr_in+8
                move.l  #fsel_exinput,D0
                bsr     _aes
                beq.s   fsel1
                moveq   #0,D0
                move.w  int_out+2(PC),D0
                rts
fsel1:          moveq   #-1,D0
                rts

/****************************************
 * Kopiert Strings in die Standardstrings
 ****************************************/
copy:           movea.l A0,A5
                lea     fsel_path(PC),A6
copy1:          move.b  (A5)+,(A6)+
                bne.s   copy1
                movea.l A1,A5
                lea     fsel_file(PC),A6
copy2:          move.b  (A5)+,(A6)+
                bne.s   copy2
                rts

/****************************************
 * Liest Standardstrings aus
 ****************************************/
recopy:         movea.l A0,A5
                lea     fsel_path(PC),A6
recopy1:        move.b  (A6)+,(A5)+
                bne.s   recopy1
                movea.l A1,A5
                lea     fsel_file(PC),A6
recopy2:        move.b  (A6)+,(A5)+
                bne.s   recopy2
                rts

/****************************************
 * LoadTos laden
 ****************************************/
open_file:      clr.w   -(SP)
                move.l  A0,-(SP)
                move.w  #$003D,-(SP)
                trap    #1              /* Fopen */
                addq.l  #8,SP

                tst.w   D0
                bmi     load_error

                move.w  D0,D7           /* Handle sichern */

get_length:     clr.w   -(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.w  #$0042,-(SP)
                trap    #1              /* Fseek */
                lea     10(SP),SP

                tst.l   D0
                bmi.s   load_error

                move.l  D0,D5

                move.w  #2,-(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.w  #$0042,-(SP)
                trap    #1              /* Fseek */
                lea     10(SP),SP

                tst.l   D0
                bmi.s   load_error

                move.l  D0,D6

                clr.w   -(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.w  #$0042,-(SP)
                trap    #1
                lea     10(SP),SP

                tst.l   D0
                bmi.s   load_error

                sub.l   D5,D6           /* Laenge = Ende - Anfang */
                move.l  D6,length

get_buffer:     move.l  D6,-(SP)
                move.w  #$0048,-(SP)
                trap    #1              /* Malloc */
                addq.l  #6,SP

                tst.l   D0
                beq.s   load_error

                addq.l  #1,D0           /* EVEN */
                and.b   #$FE,D0
                move.l  D0,addr

                move.l  D0,-(SP)
                move.l  D6,-(SP)
                move.w  D7,-(SP)
                move.w  #$003F,-(SP)
                trap    #1              /* Fread */
                lea     12(SP),SP

                tst.l   D0
                bmi.s   load_error

                cmp.l   D6,D0           /* Alles gelesen? */
                blo.s   load_error      /* Nein! => */

                move.w  D7,-(SP)
                move.w  #$003E,-(SP)
                trap    #1              /* Fclose */
                addq.l  #4,SP

                tst.w   D0
                bmi.s   loaderr1
                moveq   #0,D0
                rts

load_error:     move.w  D7,-(SP)
                move.w  #$003E,-(SP)
                trap    #1              /* Fclose */
                addq.l  #4,SP

loaderr1:       moveq   #-1,D0
                rts

/****************************************
 * LoadTos sichern
 ****************************************/
save_file:      clr.w   -(SP)
                move.l  A0,-(SP)
                move.w  #$003C,-(SP)
                trap    #1              /* Fcreate */
                addq.l  #8,SP

                tst.w   D0
                bmi.s   load_error

                move.w  D0,D7           /* Handle sichern */

                move.l  addr(PC),-(SP)
                move.l  length(PC),-(SP)
                move.w  D7,-(SP)
                move.w  #$0040,-(SP)
                trap    #1              /* Fread */
                lea     12(SP),SP

                tst.l   D0
                bmi.s   load_error

                cmp.l   length(PC),D0   /* Alles gelesen? */
                blo.s   load_error      /* Nein! => */

                move.w  D7,-(SP)
                move.w  #$003E,-(SP)
                trap    #1              /* Fclose */
                addq.l  #4,SP

                tst.w   D0
                bmi.s   loaderr1
                moveq   #0,D0
                rts

/****************************************
 * Daten aus LaodTos auslesen
 ****************************************/
get_data:       movea.l addr(PC),A0
                move.l  length(PC),D0
                lea     0(A0,D0.l),A1
                lea     patch_txt(PC),A2
                move.b  (A2)+,D1

getdata1:       move.b  (A0)+,D0
                cmp.b   D1,D0
                beq.s   getdata2
                cmpa.l  A1,A0
                blt.s   getdata1

                moveq   #-1,D0          /* Kein LoadTos! */
                rts

getdata2:       movea.l A2,A3
                movea.l A0,A4
getdata3:       move.b  (A3)+,D0
                beq.s   getdata4
                cmp.b   (A4)+,D0
                beq.s   getdata3
                bra.s   getdata1

getdata4:       movea.l A4,A0
                move.l  A0,patch_addr
                move.b  (A0),hot_mask
                move.b  1(A0),hot_keys

                lea     16(A0),A0
                lea     fselt_path(PC),A1
                lea     fselt_file(PC),A2
                bsr     convert

                move.l  2-16(A0),D0
                cmp.l   #(100*60-1)*200,D0
                blo.s   getdata5
                move.l  #(100*60-1)*200,D0
getdata5:       divu    #200,D0
                ext.l   D0
                move.l  D0,startup_time
                movea.l time_addr(PC),A0
                movea.l (A0),A0
                bsr     set_time

                moveq   #0,D0
                rts

/********************************************************************************
 * GEM-Subroutinen
 ********************************************************************************/
/* Objektstatus setzen */

change_obj:     lea     int_in(PC),A0
                move.w  D0,(A0)+
                clr.w   (A0)+
                moveq   #4-1,D0
                lea     dial_xywh(PC),A1
changeo1:       move.w  (A1)+,(A0)+
                dbra    D0,changeo1
                move.w  D1,(A0)+
                move.w  D2,(A0)+
                move.l  conf_addr(PC),addr_in
                move.l  #objc_change,D0
                bsr.s   _aes
                moveq   #0,D0
                tst.w   int_out
                bne.s   changeo2
                moveq   #-1,D0
changeo2:       rts

/* PART 'AES-Call' */
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
_aes:           movem.l D1-A6,-(SP)     /* besser retten, man kann nie wissen */
                lea     control(PC),A0
                clr.l   (A0)+
                clr.l   (A0)+           /* control-Array loeschen */
                clr.w   (A0)
                movep.l D0,-7(A0)       /* und die neuen Daten eintragen */
                cmpi.b  #112,-7(A0)     /* Ist es rsrc_gaddr()? */
                bne.s   _aes1           /* Nein! => */
                move.b  #1,1(A0)        /* Anzahl der Eintraege in addr_out=1 */
_aes1:          lea     _aes_pb(PC),A0
                move.l  A0,D1
                move.w  #200,D0
                trap    #2              /* AES aufrufen */
                movem.l (SP)+,D1-A6
                moveq   #0,D0
                move.w  int_out(PC),D0  /* int_out[0] */
                rts

_aes_pb:        DC.L control    /* Der AES-Parameterblock */
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out
/* ENDPART */

/********************************************************************************
 * Datenbereich
 ********************************************************************************/
                DATA

tos_default:    DC.B 'C:\TOS.IMG',0
default_lt:     DC.B 'C:\AUTO\LOADTOS.PRG',0
tos_txt:        DC.B 'Select your TOS-Image',0
lt_txt:         DC.B 'Select the LoadTos-Prg',0
lt_save_txt:    DC.B 'Save LoadTos-Prg',0

patch_txt:      DC.B 'PATCH HERE:',0

   IFEQ COUNTRY-0
rsc_err_txt:    DC.B '[3][Error while loading/|initialising the|RSC-File!][Cancel]',0
gen_error_txt:  DC.B '[3][Error during|programm execution!][Cancel]',0
   ENDC
   IFEQ COUNTRY-1
rsc_err_txt:    DC.B '[3][Fehler beim Laden|oder Initialisieren|des RSC-Files!][Abbruch]',0
gen_error_txt:  DC.B '[3][Allgemeiner Fehler!][Abbruch]',0
   ENDC

                EVEN

timetab:        DC.W 600,60,10,1
timetab2:       DC.B 9,9,5,9

hotkey_tab:     DC.W RSHIFT,LSHIFT,CTRL,ALT,CAPS

aktion_tab:     DC.L none,do_ctrl,do_lshift,do_alt
                DC.L do_rshift,do_caps,none,none
                DC.L sel_tos,do_cancel,do_undo,do_save
                DC.L none,none,sel_lt,none
                DC.L do_inc,none,do_dec,none

rsc: ds.b 0
#include "autoconf.i"

                EVEN

/********************************************************************************
 * Variablenbereich
 ********************************************************************************/
                BSS

conf_addr:      DS.L 1
time_addr:      DS.L 1
tos_addr:       DS.L 1
lt_addr:        DS.L 1
dial_xywh:      DS.W 4

last_obj:       DS.W 1
last_cnt:       DS.L 1

addr:           DS.L 1
length:         DS.L 1

patch_addr:     DS.L 1
hot_mask:       DS.B 1
hot_keys:       DS.B 1
startup_time:   DS.L 1

file:           DS.B 256

   ds.b 64

fsel_path:      DS.B 256
fsel_file:      DS.B 64

fselt_path:     DS.B 256
fselt_file:     DS.B 64
fsell_path:     DS.B 256
fsell_file:     DS.B 64

basepage:       DS.L 1          /* Adresse der Basepage */
control:        DS.W 16
global:         DS.W 15
addr_in:        DS.L 3
addr_out:       DS.L 1
int_in:         DS.W 128
int_out:        DS.W 128

                END
