/********************************************************************************
 * TOSLOAD fuer TOS.IMG V2.8                                                    *
 * Dieses kleine Programm laedt ein TOS.IMG (RAM-TOS) an die im TOS             *
 * definierte Adresse. Das TOS wird nur geladen, wenn es nicht im Ram steht.    *
 * Das ermoeglicht es dieses Programm auch in den AUTO-Ordner zu kopieren.      *
 * Dann muss man lediglich TOS.IMG ins Rootdirectory  kopieren.                 *
 * Es ist nun auch moeglich, das TOS korrekt ins TT-Fastram zu laden.           *
 * Man kann das Laden des TOS mit Hotkey (Default: Control) abbrechen.          *
 * Das Ueberladen eines sich bereits im Speicher befindlichden TOS ist moeglich,*
 * wenn der File-Name des TOS in der Commandline uebergeben wird.               *
 * Vor dem Starten des TOS wird die Systemzeit noch neu gesetzt, damit der      *
 * CRC-Test und der Speichertest noch ausgefuehrt werden koennen.               *
 *                                                                              *
 * (C)1990  Sigma-soft, Markus Fritze                                  05.11.90 *
 * (C)1992-93 Markus Heiden                                            20.08.93 *
 * (C)1993    EWK                                                      14.02.93 *
 ********************************************************************************/

#define version '2.8'
#define date    '03.01.1996'

                TEXT

start:
                movea.l 4(SP),A5        ;Basepageadresse holen
                lea     stack(pc),sp

                lea     cover_msg(PC),a0   ;'RAM-TOS Loader Vx.x'
                bsr     printstr
                lea     get_os_base(PC),a0 ;OS-Basisadresse holen
                bsr     supexec

                moveq   #0,d0
                lea     128(a5),a4
                move.b  (a4)+,D0        ;Commandline vorhanden?
                beq     normal          ;Nein! =>
                cmp.b   #127,D0         ;ARGV?
                beq     argv            ;Ja! =>
                bcc     normal          ;Commandline zu lang?

argv:           st      cmdflag
                clr.b   0(A4,D0.w)   ;Ende markieren
                move.l  a4,a0
                bra     open

normal:         sf      cmdflag
                cmp.l   #'NoLo',noload
                beq     noloaderr
                bsr     kbshift
                beq     abbruch
                lea     fname(PC),a0    ;Name des TOS (default)

****************************************
* Start mit Commandline-Pfad


open:           clr.w   -(SP)
                move.l  a0,-(a7)        ;Kommandozeile
                move.w  #$3D,-(SP)
                trap    #1              ;Fopen ("TOS.IMG",ReadOnly)
                addq.l  #8,SP

                move.l  D0,D7
                bmi     fnf_error       ;Datei nicht gefunden, o.ae. => raus

                moveq   #48,D6          ;48 Bytes lesen
                pea     tos_header(PC)  ;Puffer
                move.l  D6,-(SP)        ;Laenge (48 Bytes)
                move.w  D7,-(SP)        ;handle
                move.w  #$3F,-(SP)
                trap    #1              ;48 Bytes des TOS-Header lesen (Fread)
                lea     12(SP),SP

                cmp.l   D6,D0           ;auch den kompletten Header gelesen?
                bne     load_error      ;Nein => raus, da Fehler

                movea.l tos_header+8(PC),A6 ;TOS-Basisadresse holen

                cmpa.l  os_base(PC),A6  ;TOS schon installiert?
                seq     existflag

                tst.b   cmdflag
                bne.s   loadit
                tst.b   existflag
                bne     exist_error

                moveq   #100,D5         ;0,5s warten
                move.l  uptime(pc),d4
                lea.l   get_hz(pc),a0
                bsr     supexec
                cmp.l   uptime(pc),d4
                bhi.s   loadit
                add.l   d5,d4
                bcs.s   loadit
wait:
                bsr     kbshift
                beq     abbruch2
                lea.l   get_hz(pc),a0
                bsr     supexec
                cmp.l   uptime(pc),d4
                bhi.s   wait
                
loadit:
                clr.w   -(SP)           ;Pointer wieder auf Anfang
                move.w  D7,-(SP)        ;der TOS-Datei setzen
                clr.l   -(SP)
                move.w  #$42,-(SP)      ;Fseek
                trap    #1
                lea     10(SP),SP

                move.l  D0,D6           ;Fehler?
                bmi     load_error      ;Ja! =>

                move.w  #2,-(SP)        ;Pointer auf Ende
                move.w  D7,-(SP)        ;der TOS-Datei setzen
                clr.l   -(SP)           ;und Position speichern
                move.w  #$42,-(SP)      ;Fseek
                trap    #1
                lea     10(SP),SP

                tst.l   D0              ;Fehler?
                bmi     load_error      ;Ja! =>

                sub.l   D6,D0           ;Laenge = Ende - Anfang
                move.l  D0,D6

                clr.w   -(SP)           ;Pointer wieder auf Anfang
                move.w  D7,-(SP)        ;der TOS-Datei setzen
                clr.l   -(SP)
                move.w  #$42,-(SP)      ;Fseek
                trap    #1
                lea     10(SP),SP

                tst.l   D0              ;Fehler?
                bmi     load_error      ;Ja! =>

                lea.l     0(a6,d6.l),a0
                lea.l     start(pc),a1
                cmpa.l    a0,a1
                bcc.s     loadok
                lea.l     header_end(pc),a1
                cmpa.l    a6,a1
                bhi       overlap_error
loadok:
                tst.b   cmdflag
                bne.s   goload
                move.l  a6,d0
                add.l   d6,d0
                cmpa.l  #$01000000,a6
                bcs.s   not_ttram
                move.l  ramtop(pc),d1
                beq     notinram_error
                cmp.l   d1,d0
                bls.s   goload
                bra.s   checkram
not_ttram:
                cmp.l   phystop(pc),d0
                bls.s   goload
checkram:
                lea.l   testram(pc),a0
                bsr     supexec
                tst.b   buserrorflag
                beq     notinram_error

goload:
                lea     tos_header(PC),A0 ;Anfang des Puffers
                move.l  4(A5),D4        ;Ende des Speichers
                sub.l   A0,D4           ;Laenge des Speichers
                bmi     domem_error     ;Fehler, falls nicht genug Speicher

                cmp.l   D4,D6           ;Genug Speicher fuer das ganze TOS?
                bhi     domem_error     ;Nein! =>

                lea     load_msg(PC),a0 ;'loading RAM-TOS...'
                bsr     printstr        ;ausgeben

                pea     tos_header(PC)  ;Puffer
                move.l  D6,-(SP)        ;Laenge
                move.w  D7,-(SP)        ;handle
                move.w  #$3F,-(SP)
                trap    #1              ;Fread
                lea     12(SP),SP

                cmp.l   D0,D6           ;alles geladen?
                bne     load_error      ;Nein! =>

                move.w    d7,-(a7)
                move.w    #$003E,-(a7)
                trap      #1
                addq.l    #4,a7

                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1              ;Super(0L) - Supervisormode an
                addq.l  #6,SP

                ori     #$0700,SR       ;Interrupts aus

                lea     tos_header(PC),A0 ;Anfang des TOS
                adda.l  d6,a0           ;Ende TOS
                lea.l   0(a6,d6.l),a1   ;Ende Zielbereich

                lsr.l   #4,D6           ;Anzahl in 4*Longword

copy_loop:      move.l  -(A0),-(A1)     ;16 Bytes kopieren
                move.l  -(A0),-(A1)
                move.l  -(A0),-(A1)
                move.l  -(A0),-(A1)
                subq.l  #1,D6
                bne.s   copy_loop

                bra     tos_start       ;TOS aktivieren

domem_error:
                tst.b     existflag
                beq.s     domem1
                tst.b     cmdflag
                bne       mem_error
domem1:
                lea.l     loaddir_msg(pc),a0
                bsr       printstr
                clr.l     -(a7)
                move.w    #$0020,-(a7)
                trap      #1
                addq.l    #6,a7
                move.l    a6,-(a7)
                move.l    d6,-(a7)
                move.w    d7,-(a7)
                move.w    #$003F,-(a7)
                trap      #1
                lea.l     12(a7),a7
                cmp.l     d0,d6
                bne.s     load_error
                move.w    d7,-(a7)
                move.w    #$003E,-(a7)
                trap      #1
                addq.l    #4,a7
                ori.w     #$0700,sr

****************************************
* Starten des TOS

tos_start:      move.l  startup_time(PC),$04BA.w ;Timer setzen
                move.l  #'ToLo',($3fc).w

                cmpa.l  #$01000000,A6   ;TOS im TT-Ram?
                blo.s   st_ram_start    ;Nein! =>

tt_ram_start:   clr.l   $0426.w         ;Resetvektor ungueltig machen
                move.l  A6,$05A4.w      ;memtop_tt = TOS-Anfang im Ram
                move.l  #$1357BD13,$05A8.w ;memval_tt setzen
                move.l  #$5555AAAA,$051A.w ;memval3 setzen, gibt es bei TOS 1.0 nicht!
                jmp     (A6)            ;und nun RESET ausloesen

st_ram_start:   clr.l   $0426.w         ;Resetvektor ungueltig machen
                move.l  A6,$042E.w      ;phystop = TOS-Anfang im Ram
                move.l  #$5555AAAA,$051A.w ;memval3 setzen, gibt es bei TOS 1.0 nicht!
                jmp     (A6)            ;und nun RESET ausloesen


****************************************
* Fehlerbehandlung

abbruch:        lea     hotkey_msg(PC),a6
                bra.s   error_out

noloaderr:      lea     noload_msg(pc),a6
                bra.s   error_out

abbruch2:       lea     hotkey_msg(PC),a6
                bra.s   close

exist_error:    lea     existerr_msg(PC),a6 ;'TOS schon geladen...'
                bra.s   close

notinram_error: lea     inram_msg(pc),a6
                bra.s   close

fnf_error:      lea     fnferr_msg(PC),a6 ;'TOS-Datei nicht gefunden!'
                bra.s   error_out

mem_error:      lea     memerr_msg(PC),a6 ;'Nicht genug RAM vorhanden!'
                bra.s   close

load_error:     lea     loaderr_msg(PC),a6 ;'Fehler beim Laden der TOS-Datei!'
                bra.s   close

overlap_error:  lea     overl_msg(pc),a6

close:          move.w  D7,-(SP)        ;handle
                move.w  #$3E,-(SP)      ;Fclose
                trap    #1              ;Tos-Datei schliessen
                addq.l  #4,SP

error_out:      move.l  a6,a0
                bsr     printstr

                clr.w   -(SP)           ;Pterm0
                trap    #1              ;weiter mit dem AUTO-Ordner

                illegal                 ;Abbruch, falls Gemdos doch zurueckkehrt


kbshift:
                move.w  #-1,-(SP)       ;Status lesen
                move.w  #11,-(SP)       ;Kbshift
                trap    #13             ;(BIOS 11)
                addq.l  #4,SP

                and.b   defmask(PC),D0  ;mit der Maske verknuepfen
                cmp.b   defbits(PC),D0  ;laden abbrechen?
                rts

****************************************
* Supervisor-Subroutinen

get_os_base:    move.l  $3fc.w,noload
                movea.l $04F2.w,A0      ;Systemheaderadresse holen
                move.l  8(A0),os_base   ;OS-Basisadresse holen
                move.l  $42e.w,phystop
                moveq.l #0,d0
                cmpi.l  #$1357BD13,($05A8).w
                bne.s   get_os1
                move.l  ($05A4).w,d0
get_os1:
                move.l  d0,ramtop
get_hz:
                move.l  ($04BA).w,uptime
                rts

testram:
                sf        buserrorflag
                move.w    sr,-(a7)
                ori.w     #$0700,sr
                move.l    ($00000008).w,-(a7)
                movea.l   a7,a0
                lea.l     testram2(pc),a1
                move.l    a1,($00000008).w
                lea.l     tos_header(pc),a1
                movea.l   8(a1),a2
                move.l    (a2),(a2)
                moveq.l   #48/4,d0
testram1:       cmpm.l    (a1)+,(a2)+
                bne.s     testram2
                subq.l    #1,d0
                bne.s     testram1
                st        buserrorflag
testram2:       movea.l   a0,a7
                move.l    (a7)+,($00000008).w
                move.w    (a7)+,sr
                rts

printstr:       move.l  a0,-(sp)
                move.w  #9,-(sp)
                trap    #1              ;ausgeben
                addq.l  #6,SP
                rts

supexec:        move.l  a0,-(sp)
                move.w  #$26,-(SP)      ;Supexec
                trap    #14             ;(XBIOS 38)
                addq.l  #6,SP
                rts

****************************************
* Datenbereich

                DATA

hotkey_msg:     dc.b ' Abbruch durch Hotkey...',13,10,10,0
noload_msg:     dc.b ' Abbruch durch Magic...',13,10,10,0
load_msg:       DC.B ' Lade RAM-TOS...',13,10,10,0
loaddir_msg:    DC.B ' Lade RAM-TOS direkt...',13,10,10,0
existerr_msg:   DC.B ' TOS schon geladen...',13,10,10,0
loaderr_msg:    DC.B ' Fehler beim Laden der TOS-Datei!',13,10,10,0
fnferr_msg:     DC.B ' TOS-Datei nicht gefunden!',13,10,10,0
memerr_msg:     DC.B ' Nicht genug Speicher vorhanden!',13,10,10,0
inram_msg:      DC.B ' Das TOS l',$84,'ge au',$9e,'erhalb des Speichers!',13,10,10,0
overl_msg:      DC.B ' TOS und LOADTOS ',$81,'berschneiden sich!',13,10,10,0
cover_msg:      DC.B 13,10,27,'p RAM-TOS Loader V',version,'         ',date,' ',27,'q',13,10,0

                DC.b '>>> LOADTOS V',version,' - '
                DC.B $bd,'1992-96 Markus Heiden / '
                DC.B $bd,'1990 ',$e4,'-soft, Markus Fritze / '
                DC.B $bd,'1994 EWK <<<',0

                EVEN

                DC.B ' PATCH HERE:'
defmask:        DC.B $04        ;Hotkey-Maske
defbits:        DC.B $04        ;Hotkey
startup_time:   DC.L 0          ;Systemzeit beim Starten des TOS
                DS.B 10         ;Platz fuer zukuenftige Flags
fname:          DC.B 'TOS.IMG'  ;Pfad + File-Namen des Default-TOS
                DS.B 256-7


****************************************
* Variablenbereich

                BSS

                EVEN

os_base:        DS.L 1
phystop:        DS.L 1
ramtop:         DS.L 1
noload:         DS.L 1
uptime:         DS.L 1
cmdflag:        DS.B 1
buserrorflag:   DS.B 1
existflag:      DS.B 1
                even

                ds.b 1024
stack:

tos_header:     DS.B 48
header_end:     ds.b 0
