/********************************************************************************
 * TosPatch V2.9.8:                                                             *
 * Dieses Programm dient zum Patchen des TOS mit einem einfachen ASCII-File.    *
 *                                                                              *
 * (C)1990    Sigma-soft, Markus Fritze                                         *
 * (C)1992-99 Markus Heiden                                          11.07.1999 *
 ********************************************************************************/

stack_size      EQU 4096        ;Stack fuer das Programm

                TEXT

init:           movea.l 4(SP),A6        ;Basepageadresse holen
                movea.w #$0100,A5       ;Groesse der Basepage
                adda.l  12(A6),A5       ;+ Groesse des TEXT-Segments
                adda.l  20(A6),A5       ;+ Groesse des DATA-Segments
                adda.l  28(A6),A5       ;+ Groesse des BSS-Segments

                move.l  A5,-(SP)        ;Programmlaenge
                move.l  A6,-(SP)        ;Adresse der Basepage
                move.l  #$004A0000,-(SP) ;Funktionsnummer + Dummyword (0)
                trap    #1              ;Mshrink(0,Basepageadr,Prglaenge)

                lea     stack+stack_size,SP ;eigenen Stack setzen

                bsr     getargs
                
                lea     init_text(pc),A0
                bsr     print_line

                bsr     openlog
                bsr     setlog

                lea     read_1st_text(pc),A0
                bsr     print_line

                movea.l a6,a0
                bsr     read_length     ;Laenge des Files holen
                bsr     malloc
                move.l  a0,btchbuf
                movea.l a0,a1
                movea.l a6,a0
                bsr     read_file       ;Batch-File einlesen
                clr.b   0(a1,d0.l)
                
                bsr     mkplis          ;ASCII-Datei auswerten
                movea.l btchbuf(pc),a0
                bsr     mfree

                move.l  buffer(pc),d0
                beq.s   exit
                
                bsr     reloc_it        ;TOS patchen...

                bsr     crc_checksum    ;Pruefsumme ggf. setzen...

                bsr     save_tos        ;und das TOS wieder abspeichern

exit:           moveq.l #0,d7
exit1:          bsr     setlog0
                bsr     closelog

quit:           move.w    d7,-(a7)
                move.w    #$004C,-(a7)
                trap    #1              ;Pterm()

                illegal                 ;Abbruch falls GEMDOS doch zurueckkehrt.

getargs:
                lea     128(A6),A6      ;Zeiger auf die Commandline
                moveq   #0,D0
                move.b  (A6)+,D0
                clr.b   0(A6,D0.w)      ;Commandline mit einem Nullbyte abschliessen
                bsr     getfname
                bne.s   getargs7        ;if not filename, use "PATCH.FIL"
getargs1:
                cmp.b   #'-',d0
                bne.s   getargs8
                addq.l  #1,a6
                move.b  (a6)+,d0
                beq     error44
getargs2:
                cmpi.b    #'q',d0
                beq.s     getargs3
                cmp.b     #'m',d0
                beq.s     getargs4
                cmp.b     #'l',d0
                beq.s     getargs9
                cmp.b     #'a',d0
                beq.s     getarg10
                cmp.b     #'K',d0
                beq.s     getargs5
                bra       error44
getargs9:
                move.b    #1,logflg
                bra.s     getargs6
getarg10:
                move.b    #1,adrflg
                bra.s     getargs6
getargs4:
                move.b    #1,allyes
                bra.s     getargs6
getargs3:
                move.b    #1,quiet
                bra.s     getargs6
getargs5:
                move.b    #1,soundflg
getargs6:
                move.b    (a6)+,d0
                beq.s     getargs7
                cmp.b     #$20,d0
                bne.s     getargs2
                bsr       getfname
                beq.s     getargs1
getargs7:
                lea.l     bfname(pc),a6
getargs8:
                rts

****************************************

openlog:        movem.l   d0/a0,-(a7)
                move.b    logflg(pc),d0
                beq.s     openlog1
                lea.l     logopen_txt(pc),a0
                bsr       print_line
                lea.l     logname(pc),a0
                bsr       fcreate
                move.w    d0,loghdl
                bpl.s     openlog1
                clr.b     logflg
openlog1:       movem.l   (a7)+,d0/a0
                rts

closelog:       movem.l   d0/a0,-(a7)
                move.b    logflg(pc),d0
                beq.s     closelg1
                lea.l     logclose_txt(pc),a0
                bsr       print_line
                lea.l     logname(pc),a0
                move.w    loghdl(pc),d0
                bsr       fclose
closelg1:       movem.l   (a7)+,d0/a0
                rts

setlog:         tst.b     logflg
                beq.s     setlog0
                move.b    #1,dolog
                rts
setlog0:        clr.b     dolog
                rts

logline:
                movem.l   d0-d7/a0-a6,-(a7)
                move.b    dolog(pc),d0
                beq.s     logline3
                moveq.l   #0,d0
                movea.l   a0,a1
logline1:       tst.b     (a1)+
                beq.s     logline2
                addq.l    #1,d0
                bra.s     logline1
logline2:       pea.l     (a0)
                move.l    d0,-(a7)
                move.w    loghdl(pc),-(a7)
                move.w    #$0040,-(a7)
                trap      #1
                lea.l     12(a7),a7
logline3:       movem.l   (a7)+,d0-d7/a0-a6
                rts

clrrange:
                move.l    d0,-(a7)
                move.b    adrflg(pc),d0
                beq.s     clrrang1
                moveq.l   #0,d0
                move.l    d0,rangelo
                move.l    d0,rangehi
                move.b    #1,neednl
clrrang1:       move.l    (a7)+,d0
                rts

prrange:        movem.l   d0-d1,-(a7)
                clr.b     neednl
                move.l    rangelo(pc),d0
                move.l    rangehi(pc),d1
                beq.s     prrange1
                bsr       logrange
prrange1:       movem.l   (a7)+,d0-d1
                rts

prcrange:       movem.l   d0-d1,-(a7)
                move.b    neednl(pc),d0
                beq.s     prcrang1
                move.l    rangelo(pc),d0
                move.l    rangehi(pc),d1
                beq.s     prcrang1
                bsr.s     logrange
                moveq.l   #0,d0
                move.l    d0,rangelo
                move.l    d0,rangehi
prcrang1:       movem.l   (a7)+,d0-d1
                rts

ckrange:        movem.l   d0-d3/a0,-(a7)
                move.b    neednl(pc),d2
                beq.s     ckrange4
                add.l     d1,d0
                movem.l   rangelo(pc),d2-d3
                tst.l     d3
                beq.s     ckrange2
                cmp.l     d3,d1
                bhi.s     ckrange3
                cmp.l     d2,d0
                bcs.s     ckrange3
                cmp.l     d2,d1
                bcc.s     ckrange1
                move.l    d1,rangelo
ckrange1:       cmp.l     d3,d0
                bls.s     ckrange4
                move.l    d0,rangehi
                bra.s     ckrange4
ckrange2:       move.l    d1,rangelo
                move.l    d0,rangehi
                bra.s     ckrange4
ckrange3:       move.l    d1,rangelo
                move.l    d0,rangehi
                move.l    d2,d0
                move.l    d3,d1
                bsr.s     logrange
ckrange4:       movem.l   (a7)+,d0-d3/a0
                rts

logrange:       movem.l   d0-d1/a0,-(a7)
                lea.l     log_patch(pc),a0
                bsr       print_line
                bsr       hex_out
                neg.l     d0
                add.l     d1,d0
                subq.l    #1,d0
                beq.s     lograng1
                lea.l     log_hyphen(pc),a0
                bsr       print_line
                move.l    d1,d0
                bsr       hex_out
lograng1:       lea.l     lf_text(pc),a0
                bsr       print_line
                movem.l   (a7)+,d0-d1/a0
                rts

clradr:         move.l    d0,-(a7)
                move.b    adrflg(pc),d0
                beq.s     clradr1
                clr.l     lastadr
                move.b    #1,neednl
clradr1:        move.l    (a7)+,d0
                rts

lognl:          movem.l   d0/a0,-(a7)
                clr.b     neednl
                move.l    lastadr(pc),d0
                beq.s     lognl1
                lea.l     lf_text(pc),a0
                bsr       print_line
lognl1:         movem.l   (a7)+,d0/a0
                rts

logadr:         movem.l   d0-d1/a0,-(a7)
                move.b    neednl(pc),d1
                beq.s     logadr3
                move.l    lastadr(pc),d1
                bne.s     logadr1
                lea.l     log_reloc(pc),a0
                bsr       print_line
                bra.s     logadr2
logadr1:        lea.l     comma_text(pc),a0
                bsr       print_line
logadr2:        bsr       hex_out
                addq.l    #1,d1
                and.b     #7,d1
                move.l    d1,lastadr
                bne.s     logadr3
                lea.l     lf_text(pc),a0
                bsr       print_line
logadr3:        movem.l   (a7)+,d0-d1/a0
                rts

clradrx:
                move.l    d0,-(a7)
                move.b    adrflg(pc),d0
                beq.s     clradrx1
                clr.l     lastadr
                move.b    #1,neednl
clradrx1:       move.l    (a7)+,d0
                rts

lognlx:
                movem.l   d0/a0,-(a7)
                clr.b     neednl
                move.l    lastadr(pc),d0
                beq.s     lognlx1
                lea.l     lf_text(pc),a0
                bsr       print_line
lognlx1:
                movem.l   (a7)+,d0/a0
                rts

logcrc:         movem.l   d0-d1/a0,-(a7)
                move.b    neednl(pc),d1
                beq.s     logcrc3
                move.l    lastadr(pc),d1
                bne.s     logcrc1
                lea.l     log_crc(pc),a0
                bsr       print_line
                bra.s     logcrc2
logcrc1:        lea.l     comma_text(pc),a0
                bsr       print_line
logcrc2:        bsr       hex_out
                addq.l    #1,d1
                and.b     #$07,d1
                move.l    d1,lastadr
                bne.s     logcrc3
                lea.l     lf_text(pc),a0
                bsr       print_line
logcrc3:        movem.l   (a7)+,d0-d1/a0
                rts

****************************************
* save_tos: Speichert das TOS-File
* IN length.l       : Laenge des TOS
*    output_format.l: Anzahl der zu speichernden Teildateien
*    width.l        : Breite des TOS

save_tos:       move.l  output_format(pc),D2 ;D2 = Anzahl der Files
                beq     savtos_end      ;kein File? Ja! =>
                
                lea     write_tos(pc),A0 ;'Schreibe TOS'
                bsr     print_line      ;ausgeben

                cmp.l   #32,D2          ;Zu viele Files?
                bhi     error12         ;Ja! =>
                cmp.l   #1,D2           ;Nur ein Ausgabefile?
                bne.s   savtos1         ;Nein! =>

                bsr     get_length      ;TOS in einem Stueck abspeichern
                lea     fname(pc),A0
                movea.l buffer(pc),a1
                bra     write_file

savtos1:        bsr     get_width
                move.l  d0,d3
                add.l   d0,d0
                cmp.l   d0,d2           ;mehr als 16 Baenke?
                bhi     error12         ;Ja! =>

                lsr.l   #3,D3           ;D1 = Offset
                move.l  d3,d0           ;(WIDTH/8)
                subq.l  #1,D0
                and.l   D2,D0           ;Passt WIDTH und Anzahl der Files zusammen?
                bne     error21         ;Nein! =>

                bsr     get_length      ;Laenge eines Files berechnen (LENGTH/OUTPUT_FORMAT)
                moveq.l #0,d1
                move.w  d0,d1
                move.w  #0,d0
                swap    d0
                divu.w  d2,d0
                move.w  d0,d4
                swap    d4
                move.w  d1,d0
                divu.w  d2,d0
                move.w  d0,d4
                swap    d0
                tst.w   d0
                bne     error23
                move.l  d4,d0
                bsr     malloc

                movea.l   a0,a4           ;log 2 (WIDTH/8)
                move.l    d3,d1
                moveq.l   #0,d0
savtos2:        lsr.w     #1,d1
                beq.s     savtos3
                addq.w    #1,d0
                bra.s     savtos2

savtos3:        asl.w   #2,D0             ;auf Longword-Offset

                lea     wx_tab(pc),A5   ;Adresse der Extensiontabelle berechnen
                move.l  machine_type(pc),d1
                cmp.l   (a5)+,d1
                bhi     error55
                asl.l   #2,d1
                movea.l 0(a5,d1.l),a5
                movea.l 0(A5,D0.w),A5
                movea.l buffer(pc),a6

                moveq   #'0',D7         ;Nummer fuer TOS-Dateien

                moveq   #0,D5           ;Offset-Zaehler
                moveq   #0,D6           ;Laengen-Zaehler
savtos4:        moveq.l #0,d1
savtos4a:       move.l    d1,d0
                asl.l     #2,d0
                lea.l     0(a5,d0.l),a0
                lea.l     fname_ext(pc),a1
                move.b    (a0)+,(a1)+
                move.b    (a0)+,(a1)+
                move.b    (a0)+,(a1)
                cmp.l     output_format(pc),d3
                beq.s     savtos5
                tst.b     (a1)
                bne       error56
                move.b    d7,(a1)

savtos5:        lea     0(A6,D6.l),A2   ;Anfangsadresse berechnen
                adda.l  d1,a2
                movea.l a4,a3           ;Zwischenspeicher fuer File

                lea.l     space_text(pc),a0
                bsr       print_line
                bsr       get_reloc_adr
                move.l    a2,d0
                sub.l     a6,d0
                add.l     a0,d0
                bsr       hex_out
                lea.l     colon_text(pc),a0
                bsr       print_line

                move.l  D4,D0

savtos6:        move.b  (A2),(A3)+      ;TOS in Zwischenspeicher kopieren
                adda.l  d3,a2
                subq.l  #1,D0
                bne.s   savtos6

                add.l   D4,D5           ;Laenge aufsummieren

                move.l  d4,d0
                lea     fname(pc),A0    ;File schreiben
                movea.l a4,a1
                bsr     write_file

                addq.l  #1,D1           ;naechstes File
                cmp.l   d3,d1           ;schon eine Bank fertig?
                bcs.s   savtos4a        ;Nein! =>

                move.l  d5,d6
                addq.b  #1,D7           ;Nummer der TOS-Dateien erhoehen
                cmp.b   #'9'+1,D7
                bne.s   savtos8
                addq.b  #'A'-('9'+1),D7

savtos8:        sub.l   D3,D2           ;schon alle Files?
                bne     savtos4         ;Nein! =>
                movea.l a4,a0
                bsr     mfree

savtos_end:     rts

mkplis:         bsr     clrrange
                move.l  btchbuf(pc),A6
                
                move.w    #$002A,-(a7) /* Tgetdate */
                trap      #1
                addq.l    #2,a7
                lea.l     datevar(pc),a0
                bsr       write_var
                move.l    d0,d1
                moveq.l   #31,d0
                and.l     d1,d0
                lea.l     dayvar(pc),a0
                bsr       write_var
                lsr.l     #5,d1
                moveq.l   #15,d0
                and.l     d1,d0
                lea.l     monthvar(pc),a0
                bsr       write_var
                lsr.l     #4,d1
                moveq.l   #127,d0
                and.l     d1,d0
                add.w     #1980,d0
                lea.l     yearvar(pc),a0
                bsr       write_var

                moveq   #0,D0           ;'CRC' erzeugen und auf 0 setzen
                lea.l   crcvar(pc),a0
                bsr     write_var

                moveq.l   #0,d0
                lea.l     countries(pc),a0
wrctry0:
                tst.w     (a0)
                beq.s     wrctry1
                bsr       write_var
                addq.l    #1,d0
                lea.l     16(a0),a0
                bra.s     wrctry0
wrctry1:

mkplis0:        move.l  #1,line         ;Zeilennummer initialisieren
                clr.w   cond_flag
                clr.l   nest_count
                clr.l   if_count        ;Bedingungszaehler initialisieren
                clr.l   sw_count
                clr.l   sel_count
mkplis1:        bsr     skip_space
                bne.s   mkplis2         ;Zeilenende? Ja! =>
                cmp.b   #'_',d0
                beq     mkplis41
                tst.w   cond_flag
                beq.s   mkplis1a

****************************************
* Naechsten Zeilenanfang suchen

mkplis2:        move.b  (A6)+,D0        ;naechste Zeile suchen
                beq     mkplis25        ;Datei-Ende? Ja! =>
                cmp.b   #$0A,D0         ;naechste Zeile?
                bne.s   mkplis2         ;Nein! =>
                addq.l  #1,line         ;Zeilennummer um 1 erhoehen
                bra     mkplis1

mkplis1a:       cmp.b   #'.',d0
                beq     handle_dot
                cmp.b   #'-',d0
                beq     handle_chdir
                cmp.b   #'+',d0
                beq     handle_batch
                cmp.b   #'!',d0
                beq     handle_relocs
                cmp.b   #'#',d0
                beq     handle_variable
                cmp.b   #'/',d0
                beq     handle_print
                cmp.b   #'>',d0
                beq     handle_format
                cmp.b   #'<',d0
                beq     handle_tos
                cmp.b   #'=',d0
                beq     handle_date
                cmp.b   #$dd,d0
                beq     handle_crc
                cmp.b   #'?',d0
                beq     handle_forced


****************************************
* Patches auswerten

handle_patch:   bsr     get_term        ;Patchoffset holen
                cmp.l   max_length(pc),d0
                bcs.s   mkplis4
                bsr       get_base        ;TOS-Basisadresse holen
                sub.l     a0,d0
                bcs       error1
                cmp.l     max_length(pc),d0
                bcc       error1
mkplis4:        move.l    d0,d6
                bsr       skip_space
                beq.s     mkplis5
                move.l    d6,current_adr
                bra       mkplis2

mkplis5:        cmp.b   #':',d0         ;~ setzen?
                bne.s   mkplis5d        ;Nein! => weiter
                addq.l    #1,a6
                move.l    d6,current_adr
                bsr     error42
                bra     mkplis1

mkplis5d:       cmpi.b    #'|',d0          ;Flag setzen
                seq       d4
                bne.s     mkplis5x
                addq.l    #1,a6

mkplis5x: 
                move.l    current_adr(pc),d5
                move.l    d6,current_adr

                bsr       skip_space
                bne       error0
                movea.l   buffer(pc),a0
                move.l    a0,d0
                beq       error3
                adda.l    d6,a0
                move.l    max_length(pc),d0
                sub.l     d6,d0
                bsr       read_patches
                bmi       error27
                move.l    d6,d1
                bsr       ckrange
                move.l    d6,d1
                add.l     d0,d1
                move.l    d1,current_adr
                tst.b     d4
                beq       mkplis2
                move.l    d5,current_adr
                bra       mkplis2

****************************************
* Relocausnahmen auswerten

handle_relocs:  addq.l  #1,A6
                lea     ptchtab(pc),A0 ;Ausnahmentabellenende suchen
                movea.l a0,a2
                lea.l   1024*4(a2),a2
mkplis12:       tst.l   (A0)+
                bne.s   mkplis12
                subq.l  #4,A0
                lea     ptchtab2(pc),A1 ;Feldausnahmentabellenende suchen
                movea.l a1,a3
                lea.l   256*2*4(a3),a3
mkpli12a:       tst.l   (A1)
                addq.l  #8,A1
                bne.s   mkpli12a
                subq.l  #8,A1
mkplis13:       bsr     skip_space
                bne     error2
                bsr     get_term        ;Adresse holen
                move.l  D0,(A0)+        ;und in Tabelle sichern
                cmpa.l  a2,a0
                bcc     error32
                bsr     skip_space
                bne     mkplis2
mkpli13a:       cmpi.b  #',',(A6)+      ;noch ein Wert?
                beq.s   mkplis13        ;Ja! =>
                cmpi.b  #'.',D0         ;Feldausnahme?
                bne     error2          ;Nein! =>
                cmpi.b  #'.',(A6)+      ;2. Zeichen pruefen
                bne     error2          ;Fehler? Ja! =>

mkpli13b:       bsr     skip_space
                bne     error0
                bsr     get_term
                cmp.l   -4(A0),D0       ;Ist 2. Adresse groesser als die 1.?
                blo     error28         ;Nein! =>
                beq.s   mkpli13c        ;Bei Gleichheit Wert lassen
                move.l  -(A0),(A1)+     ;Anfangsadresse in richtige Tabelle
                clr.l   (A0)            ;und in der falschen Tabelle loeschen
                move.l  D0,(A1)+        ;Endadresse schreiben
                cmpa.l  a3,a1
                bcc     error32
mkpli13c:       bsr     skip_space
                bne     mkplis2
                cmpi.b  #',',(A6)+      ;noch ein Wert?
                beq.s   mkplis13        ;Ja! =>
                bra     error2


****************************************
* TOS-Datum vergleichen

handle_date:    addq.l  #1,A6
                bsr     skip_space
                bne     error0
                moveq   #0,D1
                bsr     mkplis16        ;Tag holen
                bsr     mkplis16
                bsr     skip_space
                bne     error0
                cmpi.b  #'.',(A6)+
                bne     error26
                bsr     skip_space
                bne     error0
                bsr.s   mkplis16        ;Monat holen
                bsr.s   mkplis16
                ror.w   #8,D1           ;Tag und Monat tauschen (US-Format)
                bsr     skip_space
                bne     error0
                cmpi.b  #'.',(A6)+
                bne     error26
                bsr     skip_space
                bne     error0
                bsr.s   mkplis16        ;Jahr holen
                bsr.s   mkplis16
                bsr.s   mkplis16
                bsr.s   mkplis16
                move.l  buffer(pc),A0 ;Adresse des Datums im TOS
                move.l  a0,d0
                beq     error3
                cmp.l   24(A0),D1       ;Ist es gleich dem angegebenen?
                beq     mkpli14a        ;Ja! =>
                bsr     error14
mkpli14a:
                bsr     skip_space      ; country following?
                bne     mkplis2         ; no
                cmpi.b  #',',d0
                bne     error2
                addq.l  #1,a6
                bsr     get_term
                move.l  buffer(pc),A0
                move.w  28(a0),d1
                asr.b   #1,d1
                ext.w   d1
                ext.l   d1
                cmp.w   d0,d1
                beq     mkplis2
                bsr     error43
                bra     mkplis2

mkplis16:       lsl.l   #4,D1
                move.b  (A6)+,D0
                eori.b  #'0',D0
                cmp.b   #9,D0
                bhi     error26
                or.b    D0,D1
                rts


****************************************
* TOS lesen

handle_tos:     addq.l  #1,A6
                cmpi.b  #'*',(A6)       ;TOS aus ROM lesen?
                bne.s   mkplis19        ;Nein! =>
                bsr     prcrange

****************************************
* TOS aus ROM lesen

                lea     read_rom_text(pc),A0
                bsr     print_line

                bsr     get_base        ;TOS-Basisadresse und
                movea.l a0,a1
                bsr     get_length      ;TOS-Laenge holen
                bsr     malloc
                move.l  a0,buffer
                move.l  d0,max_length
                lsr.l   #4,D0           ;Laenge/16, da 4*move.l
mkplis18:       move.l  (A1)+,(A0)+     ;TOS kopieren
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                subq.l  #1,D0
                bne.s   mkplis18
                bra     mkplis2

****************************************
* TOS von Disk lesen

mkplis19:       bsr     prcrange
                lea     read_tos(pc),A0
                bsr     print_line

                bsr     get_length
                bsr     malloc
                move.l  a0,buffer
                move.l  d0,max_length
                movea.l a0,a1
                move.l  d0,d1
                lsr.l   #4,d0
                moveq.l #-1,d2
mkplis20:       move.l  d2,(a0)+
                move.l  d2,(a0)+
                move.l  d2,(a0)+
                move.l  d2,(a0)+
                subq.l  #1,d0
                bne     mkplis20
                bsr     getfilename
                bne     error0

                bsr     read_length
                cmp.l   d1,d0           ;Zu lang?
                bhi     error5          ;Ja! =>
                bsr     read_file       ;TOS-File einlesen

                cmp.l   D1,D0
                beq     mkplis2
                bsr     error4          ;TOS kuerzer als angegeben
                bra     mkplis2

****************************************
* Ausgabeformat festlegen

handle_format:  addq.l  #1,A6
                bsr     get_term        ;Anzahl der Dateien holen
                move.l  d0,output_format ;und sichern
mkplis22:       bsr     skip_space      ;Ist Relozieradresse angegeben?
                bne.s   mkpli22a        ;Nein! =>
                cmp.b   #',',d0
                beq.s   mkpli22a

                bsr     get_term        ;Relozieradresse holen
                bra.s   mkpli22b

mkpli22a:       bsr     get_base
                move.l  a0,d0

mkpli22b:       lea.l   relocvar(pc),a0
                bsr     write_var
                clr.l     machine_type
                bsr       skip_space
                bne       mkplis2
                cmpi.b    #',',(a6)+
                bne       error2
                bsr       skip_space
                bne       error0
                lea.l     mach_tab(pc),a1
mkpli22h:
                moveq.l   #15,d0
                movea.l   a6,a0
mkpli22c:
                move.b    (a0)+,d2
                beq       error0
                cmp.b     #$0D,d2
                beq       error0
                cmp.b     #$0A,d2
                beq       error0
                cmp.b     #$61,d2
                bcs.s     mkpli22d
                cmp.b     #$7A,d2
                bhi.s     mkpli22d
                and.b     #$DF,d2
mkpli22d:
                cmp.b     (a1)+,d2
                bne.s     mkpli22g
                tst.b     (a1)
                beq.s     mkpli22f
                subq.l    #1,d0
                bpl.s     mkpli22c
mkpli22e:
                movea.l   a0,a6
                move.l    (a1)+,d0
                move.l    d0,machine_type
                cmp.l     wx_tab(pc),d0
                bls       mkplis2
                bra       error55
mkpli22f:
                adda.l    d0,a1
                bra.s     mkpli22e
mkpli22g:
                adda.l    d0,a1
                addq.l    #4,a1
                tst.b     (a1)
                bne.s     mkpli22h
                bra       error57


****************************************
* Aktuellen Pfad aendern

handle_chdir:   addq.l  #1,A6
                bsr       prcrange

                lea     path_text(pc),A0
                bsr     print_line

                bsr     getfilename
                bne     error0
                bsr     print_line

                movem.l d0-d7/a0-a6,-(a7)
                move.l  A0,-(SP)
                move.w  #$003B,-(SP)    ;Dsetpath
                trap    #1              ;GEMDOS 59
                addq.l  #6,SP
                movem.l (a7)+,d0-d7/a0-a6

                lea     path_end_text(pc),A0
                bsr     print_line
                bra     mkplis2


****************************************
* Batchdatei-Ende

mkplis25:       tst.l   if_count        ;noch eine offener _IF-Befehl?
                bne     error20         ;Ja! =>
                tst.l   sw_count        ;noch eine offener _SWITCH-Befehl?
                bne     error40         ;Ja! =>
                tst.l   sel_count       ;noch eine offener _SELECT-Befehl?
                bne     error46         ;Ja! =>
                move.w  filenr(pc),d0 ;Ende des 2. Batchfile?
                bne.s   mkpli25a        ;Ja! =>
                bsr     prrange
                rts

****************************************
* Ende eines 2. Batchfiles

mkpli25a:       bsr     prcrange
                lea.l   batch_end_text(pc),a0
                bsr     print_line
                subq.w  #1,filenr       ;Flag fuer 2. Batchfile loeschen
                move.l  (SP)+,sel_count
                move.l  (SP)+,sw_count
                move.l  (SP)+,if_count  ;Bedingungszaehler,
                move.l  (SP)+,line      ;Zeilennummer und
                movea.l (SP)+,A6        ;Textpointer wieder herstellen
                move.l  (SP)+,A0
                bsr     mfree
                bra     mkplis2


****************************************
* CRC-Berechnung aktivieren

handle_crc:     moveq   #1,D0           ;Eine 1 in Variable 'CRC' schreiben
                lea.l   crcvar(pc),a0
                bsr     write_var
                bra     mkplis2


****************************************
* Focierte Relozierausnahmen auswerten

handle_forced:  addq.l  #1,A6
                lea     forced_table(pc),A0 ;Ausnahmentabellenende suchen
mkplis28:       tst.l   (A0)+
                bne.s   mkplis28
                subq.l  #4,A0
mkplis29:       bsr     skip_space
                bne     error0
                bsr     get_term        ;Adresse holen
                move.l  D0,(A0)+        ;und in Tabelle speichern
                bsr     skip_space
                bne     mkplis2
                cmpi.b  #',',(A6)+      ;noch ein Wert?
                beq.s   mkplis29        ;Ja! =>
                bra     error2


****************************************
* Einfache Variable (#) setzen

handle_variable: addq.l  #1,A6
                bsr     get_term        ;Wert holen
                move.l  D0,variable     ;und in Variable speichern
                bra     mkplis2


****************************************
* 2. Batchfile laden

handle_batch:   addq.l  #1,A6
                bsr       prcrange

                move.w  filenr(pc),d0
                cmp.w   #256,d0
                bcc     error19

                lea     read_2nd_text(pc),A0
                bsr     print_line
                bsr     getfilename
                bne       error0
                movea.l   a0,a5

                bsr     read_length     ;Laenge holen
                bsr       malloc
                movea.l   a0,a1
                move.l    a1,-(a7)        ;batch buffer,
                move.l    a6,-(a7)        ;Textpointer,
                move.l    line(pc),-(a7)  ;Zeilennummer und
                move.l    if_count(pc),-(a7) ;Bedingungszaehler sichern
                move.l    sw_count(pc),-(a7)
                move.l    sel_count(pc),-(a7)
                addq.w    #1,filenr
                movea.l   a5,a0

                bsr     read_file       ;Batch-File einlesen
                movea.l   a1,a6

                clr.b   0(A6,D0.l)      ;mit Nullbyte abschliessen

                bra     mkplis0         ;Auswertung starten


****************************************
* Auswertung aller Zeilen, die mit . anfangen

handle_dot:     movea.l A6,A1
                move.b  1(A6),D0
                cmp.b   #'0',D0         ;dezimaler Patchoffset?
                blo.s   mkplis34        ;Nein! =>
                cmp.b   #'9',D0
                ble     handle_patch    ;Ja! =>
mkplis34:       bsr     get_vname
                bsr     skip_space
                bne     mkplis35
                addq.l  #1,A6
                cmp.b   #'=',D0         ;Variable setzen?
                beq.s   mkpli34a        ;Nein! => Variable ist Patchoffset
                cmp.b   #':',D0         ;~ setzen?
                bne     mkplis35        ;Nein! =>

****************************************
* ~ auf .VARIABLE setzen

                move.l  current_adr(pc),d0
                bsr     write_var
                bra     mkplis1

mkpli34a:       bsr     skip_space
                bne     error0
                tst.l   sel_count
                bne.s   mkpli34b
                bsr     get_term        ;Wert holen
                bsr     write_var       ;und Variable schreiben
                bsr     skip_space
                bne     mkplis2
                cmp.b   #',',d0
                beq     error51
                cmp.b   #':',d0
                beq     error51
                bra     error54
mkpli34b:
                move.l    sel_var(pc),d7
mkpli34c:
                bsr       skip_space
                bne       error48
                cmpi.b    #',',d0
                bne.s     mkpli34d
                tst.l     d7
                beq       error52
                addq.l    #1,a6
                subq.l    #1,d7
                bra.s     mkpli34c
mkpli34d:       bsr       get_term
                tst.l     d7
                beq.s     mkpli34h
                move.l    d0,d1
                bsr       skip_space
                bne.s     mkpli34e
                cmpi.b    #':',(a6)+
                beq.s     mkpli34f
                subq.l    #1,d7
                cmpi.b    #',',d0
                beq.s     mkpli34c
                bra       error48
mkpli34e:       move.l    d1,d0
                cmp.l     sel_var(pc),d7
                beq.s     mkpli34g
                bra       error48
mkpli34f:       bsr       get_term
mkpli34g:       bsr       write_var
                bsr       skip_space
                bne       mkplis2
                bra       error54
mkpli34h:       bsr       write_var
                bsr       skip_space
                bne       mkplis2
                cmp.b     #',',d0
                beq       mkplis2
                cmp.b     #':',d0
                beq       mkplis2
                bra       error54

****************************************
* .VARIABLE ist Patchoffset

mkplis35:       movea.l A1,A6           ;alten Textpointer zurueckholen
                bra     handle_patch    ;Patch auswerten


****************************************
* PRINT-Befehl (/)

handle_print:   addq.l  #1,A6
                bsr     prcrange
mkplis37:       moveq.l #0,d7           ;Flag loeschen
                bsr     skip_space
                bne     error2
                cmpi.b  #39,D0          ;Textausgabe?
                beq.s   mkplis38        ;Ja! =>
                cmp.b   #'"',D0
                beq.s   mkplis38        ;Ja! =>
                cmpi.b  #'$',D0         ;Hexadezimale Ausgabe
                beq.s   mkpli37e        ;Ja! =>
                cmpi.b  #'&',d0
                bne.s   mkpli37a        ;Nein! =>
mkpli37e:       move.b  (A6)+,d7        ;Flag setzen
mkpli37a:       bsr     get_term        ;Wert holen
                tst.b   d7              ;Hexadezimal?
                beq.s   mkpli37b        ;Nein! =>
                cmp.b   #'$',d7
                bne.s   mkpli37d
                bsr     hex_out         ;hexadezimal ausgeben
                bra.s   mkpli37c
mkpli37d:       bsr     bin_out
                bra.s   mkpli37c
mkpli37b:       bsr     dez_out         ;dezimal ausgeben
mkpli37c:       bsr     skip_space      ;Zeilenende?
                bne.s   mkplis40        ;Ja! =>
                cmpi.b  #',',(A6)+      ;noch ein Wert?
                beq.s   mkplis37        ;Ja! =>
                bra     error2
mkplis38:       addq.l  #1,A6
                movea.l A6,A0           ;Zeiger auf Textanfang setzen
mkplis39:       move.b  (A6)+,D1
                beq     error2
                cmp.b   #$0D,D1
                beq     error2
                cmp.b   #$0A,D1
                beq     error2
                cmp.b   D0,D1           ;Textende?
                bne.s   mkplis39        ;Nein! => weiter suchen
                clr.b   -1(A6)          ;Textende mit Nullbyte abschliessen
                bsr     print_line      ;Text ausgeben
                bra.s   mkpli37c
mkplis40:       lea     lf_text(pc),A0  ;Ausgabe mit LF/CR
                bsr     print_line      ;abschliessen
                bra     mkplis2


****************************************
* Befehle, die mit _ anfangen, ausfuehren

mkplis41:       addq.l  #1,A6
                lea     com_tab(pc),A1  ;Befehlstabelle holen
mkplis42:       moveq   #15,D0          ;Ein Befehl ist 16 Bytes lang
                movea.l A6,A0
mkplis43:       move.b  (A0)+,D2        ;Zeichen holen
                beq     error0          ;Textende? Ja! =>
                cmp.b   #$0D,D2         ;Zeilenende?
                beq     error0          ;Ja! =>
                cmp.b   #$0A,D2         ;Zeilenende?
                beq     error0          ;Ja! =>
                and.b   #$DF,D2         ;auf Grossschrift wandeln
                cmp.b   (A1)+,D2        ;mit Befehlstabelle vergleichen
                bne.s   mkplis45        ;Gleich? Nein! =>
                tst.b   (A1)            ;Befehl komplett verglichen?
                beq.s   mkplis44        ;Ja! =>
                subq.l  #1,D0           ;Alle 8 Zeichen verglichen?
                bpl.s   mkplis43        ;Nein! =>
mkpli43b:       movea.l A0,A6           ;Textpointer aktualisieren
                move.w  (a1)+,d1
                move.w  cond_flag(pc),d0
                beq.s   mkpli43a
                cmp.w   d0,d1
                bne     mkplis2
mkpli43a:       movea.l (A1),A1         ;Befehlsadresse holen
                jmp     (A1)            ;und ausfuehren
mkplis44:       adda.l  D0,A1           ;Pointer auf Befehlsadresse setzen
                bra.s   mkpli43b        ;und Befehl ausfuehren
mkplis45:       adda.l  D0,A1           ;Pointer auf
                addq.l  #6,A1           ;naechsten Eintrag setzen
                tst.b   (a1)            ;Alle Befehle verglichen?
                bne.s   mkplis42        ;Nein! =>
                bra     error15

****************************************
* _IF-Befehl

cmdif:          tst.w   d0
                beq.s   cmdif1
                addq.l  #1,nest_count
                bra     mkplis2
cmdif1:         bsr     get_term        ;Ergebnis des Vergleichs holen
                tst.l   D0              ;ist es FALSE (0)?
                beq.s   mkplis47        ;Ja! =>
                subq.l  #1,D0           ;ist es TRUE (1)?
                bne     error16         ;Nein! =>
                addq.l  #1,if_count     ;IF-Verschachtelung um 1 erhoehen
                move.w  #'IF',-(SP)     ;Wert fuer IF/TRUE auf den Stack legen
                bra     mkplis2

mkplis47:       addq.l  #1,if_count
                move.w  #'EL',-(a7)
                move.w  #$4946,cond_flag
                bra     mkplis2

****************************************
* _ELSE-Befehl

cmdelse:     
                tst.w   d0
                beq.s   cmdelse1
                tst.l   nest_count
                bne     mkplis2
                tst.l   if_count        ;Ist ein offener IF-Befehl vorhanden?
                beq     error17         ;Nein! =>
                cmpi.w  #'EL',(SP)      ;War es ein IF/TRUE?
                bne     error17         ;Nein! =>
                clr.w   cond_flag
                bra     mkplis2
cmdelse1:       tst.l   if_count
                beq     error17
                cmpi.w  #'IF',(a7)
                bne     error17
                move.w  #'IF',cond_flag
                bra     mkplis2

****************************************
* _ENDIF-Befehl

cmdendif: 
                tst.w   d0
                beq.s   cmdendi2
                tst.l   nest_count
                beq.s   cmdendi1
                subq.l  #1,nest_count
                bra     mkplis2
cmdendi1:       clr.w   cond_flag
cmdendi2:       tst.l   if_count        ;Ist ein offenener IF-Befehl vorhanden?
                beq     error18         ;Nein! =>
                subq.l  #1,if_count     ;Anzahl der IF-Befehle dekrementieren
                move.w  (SP)+,d0        ;Wert fuer IF-Befehl auf dem Stack?
                cmp.w   #'IF',d0
                beq     mkplis2
                cmp.w   #'EL',d0
                beq     mkplis2
                bra     error18

****************************************
* _ERROR-Befehl

cmderror:       bsr       prcrange
                bsr     skip_space
                bne     error22         ;'_ERROR'-Message ohne zus. Text ausgeben
                cmpi.b  #39,(A6)+       ;ein ' als Textanfang?
                beq.s   mkpli54a        ;Ja! =>
                cmpi.b  #'"',D0         ;ein " als Textanfang?
                bne     error2          ;Nein! =>

mkpli54a:       lea     error_txt(pc),A0 ;'Fehler: '
                bsr     print_line      ;ausgeben

                movea.l A6,A0           ;Zeiger auf Textanfang setzen
mkplis55:       move.b  (A6)+,D1        ;Zeichen holen
                beq     error0          ;Batchdatei zu Ende? Ja! =>
                cmp.b   #$0D,D1         ;Zeile zu Ende?
                beq     error0          ;Ja! =>
                cmp.b   #$0A,D1         ;Zeile zu Ende?
                beq     error0          ;Ja! =>
                cmp.b   d0,d1           ;Textende?
                bne.s   mkplis55        ;Nein! => weiter suchen
                clr.b   -1(A6)          ;Textende mit Nullbyte abschliessen
                moveq   #0,D0           ;Fehlermeldung
                bra     uerror          ;ausgeben

****************************************
* _EVEN-Befehl

cmdeven:        moveq.l #-1,d7
                bsr     skip_space
                bne.s   cmdeven1
                cmp.b   #'$',d0
                bne.s   cmdeven0
                addq.l  #1,a6
cmdeven0:       moveq.l #0,d7
                bsr     get_term
cmdeven1:       move.l  current_adr(pc),D1 ;akt. Adresse holen
                btst    #0,D1           ;gerade?
                beq     mkplis2         ;Ja! => fertig
                move.l  d0,d2
                addq.l  #1,d1           ;1 Byte soll geschrieben werden
                cmp.l   max_length(pc),d1
                bcc     error1
                move.l  d1,current_adr
                tst.l   d7
                bne     mkplis2
                movea.l buffer(pc),a0
                move.l  a0,d7
                beq     error3
                move.b  d2,-1(a0,d1.l)        ;an akt. Adresse schreiben
                subq.l  #1,d1
                moveq.l #1,d0
                bsr     ckrange
                bra     mkplis2

****************************************
* _FILL-Befehl
cmdfill:
                bsr       skip_space
                bmi       error0
                bsr       get_term
                move.l    d0,d6
                cmp.l     max_length(pc),d6
                bcs.s     cmdfill1
                bsr       get_base
                sub.l     a0,d6
                bcs       error1
                cmp.l     max_length(pc),d6
                bcc       error1
cmdfill1:
                bsr       skip_space
                bne       error0
                cmpi.b    #',',(a6)+
                bne       error2
                bsr       skip_space
                bne       error0
                bsr       get_term
                move.l    d0,d7
                cmp.l     max_length(pc),d7
                bcs.s     cmdfill2
                bsr       get_base
                sub.l     a0,d7
                bcs       error1
                cmp.l     max_length(pc),d7
                bcc       error1
cmdfill2:
                bsr       skip_space
                bmi       error0
                cmpi.b    #',',(a6)+
                bne       error2
                bsr       skip_space
                bne       error0
                move.l    d7,d5
                sub.l     d6,d5
                beq       mkplis2
                bmi       error28
                cmpi.b    #'|',d0
                seq       d1
                bne.s     cmdfill3
                addq.l    #1,a6
cmdfill3:
                move.l    current_adr(pc),d4
                move.l    d6,current_adr
                bsr       skip_space
                bmi       error0
                moveq.l   #32,d0
                lea.l     number_puffer(pc),a0
                bsr       read_patches
                bmi       error30
                tst.b     d1
                beq.s     cmdfil3a
                move.l    d4,current_adr
cmdfil3a:       
                move.l    d0,d2
                move.l    d5,d0
                move.l    d6,d1
                bsr       ckrange
                movea.l   buffer(pc),a1
                move.l    a1,d7
                beq       error3
                adda.l    d6,a1
cmdfill4:
                lea.l     number_puffer(pc),a0
                move.l    d2,d1
cmdfill5:
                move.b    (a0)+,(a1)+
                subq.l    #1,d5
                beq       mkplis2
                subq.l    #1,d1
                bne.s     cmdfill5
                bra.s     cmdfill4


****************************************
* _SWITCH--Befehl
cmdswitch:      tst.w     d0
                beq.s     cmdsw1
                addq.l    #1,nest_count
                bra       mkplis2
cmdsw1:         bsr       get_term
                addq.l    #1,sw_count
                move.l    d0,-(a7)
                move.w    #'SW',-(a7)
                move.w    #'SW',cond_flag
                bra       mkplis2

****************************************
* _CASE--Befehl
cmdcase:        tst.w     d0
                beq.s     cmdcase1
                tst.l     nest_count
                bne       mkplis2
cmdcase1:       tst.l     sw_count
                beq       error35
                move.w    (a7),d0
                cmpi.w    #'DE',d0
                beq       error36
                cmpi.w    #'CA',d0
                beq.s     cmdcase2
                cmpi.w    #'SW',d0
                bne       error35
cmdcase2:       move.l    2(a7),d1
                moveq.l   #0,d2
cmdcase3:       bsr       get_term
                cmp.l     d0,d1
                seq       d0
                or.b      d0,d2
                bsr       skip_space
                cmpi.b    #',',(a6)+
                beq.s     cmdcase3
                cmp.b     #':',d0
                bne       error34
                tst.b     d2
                beq.s     cmdcase5
                move.w    #'CA',(a7)
                clr.w     cond_flag
                bra       mkplis1
cmdcase5:       move.w    #'SW',cond_flag
                bra       mkplis2

****************************************
* _DEFAULT--Befehl
cmddefault:
                tst.w     d0
                beq.s     cmddefa1
                tst.l     nest_count
                bne       mkplis2
cmddefa1:       tst.l     sw_count
                beq       error37
                bsr       skip_space
                cmpi.b    #':',(a6)+
                bne       error41
                move.w    (a7),d0
                cmpi.w    #'DE',d0
                beq       error39
                cmpi.w    #'CA',d0
                beq.s     cmddefa2
                cmpi.w    #'SW',d0
                bne       error37
                move.w    #'DE',(a7)
                clr.w     cond_flag
                bra       mkplis1
cmddefa2:       move.w    #'SW',cond_flag
                bra       mkplis2

****************************************
* _ENDSWITCH--Befehl
cmdendswitch:
                tst.w     d0
                beq.s     cmdends2
                tst.l     nest_count
                beq.s     cmdends1
                subq.l    #1,nest_count
                bra       mkplis2
cmdends1:
                clr.w     cond_flag
cmdends2:
                tst.l     sw_count
                beq       error38
                subq.l    #1,sw_count
                move.w    (a7)+,d0
                addq.l    #4,a7
                cmpi.w    #'CA',d0
                beq       mkplis2
                cmpi.w    #'DE',d0
                beq       mkplis2
                cmpi.w    #'SW',d0
                beq       mkplis2
                bra       error38

****************************************
* _SELECT--Befehl
cmdselect:
                bsr       skip_space
                bmi       error0
                bsr       get_term
                addq.l    #1,sel_count
                move.l    sel_var(pc),-(a7)
                move.w    #'SE',-(a7)
                move.l    d0,sel_var
                bra       mkplis2

****************************************
* _ENDSELECT--Befehl
cmdendselect:
                tst.l     sel_count
                beq       error45
                cmpi.w    #'SE',(a7)+
                bne       error47
                subq.l    #1,sel_count
                move.l    (a7)+,sel_var
                bra       mkplis2

****************************************
* _IFDEF/IFNDEF-Befehl
cmdifndef:      moveq.l   #0,d1
                bra.s     cmdifd
cmdifdef:       moveq.l   #-1,d1
cmdifd:         tst.w     d0
                beq.s     cmdifd1
                addq.l    #1,nest_count
                bra       mkplis2
cmdifd1:        bsr       skip_space
                bne       error0
                bsr       get_vname
                bsr       search_var
                seq       d2
                cmp.b     d1,d2
                bne.s     cmdifd2
                addq.l    #1,if_count
                move.w    #'IF',-(a7)
                bra       mkplis2
cmdifd2:        addq.l    #1,if_count
                move.w    #'EL',-(a7)
                move.w    #'IF',cond_flag
                bra       mkplis2

****************************************
* _DEFINE-Befehl
cmddefine:
                bsr       skip_space
                bne       error0
                bsr       get_vname
                moveq.l   #0,d0
                bsr       write_var
                bra       mkplis2

****************************************
* _UNDEF-Befehl
cmdundef:
                bsr       skip_space
                bne       error0
                bsr       get_vname
                bsr       search_var
                bne       mkplis2
                move.w    #$00FF,(a0)
                bra       mkplis2

****************************************
* Einfache Patches lesen
read_patches:
                movem.l   d1-d7/a0-a5,-(a7)
                move.l    d0,d6
                movea.l   a0,a1
                bsr     skip_space
                bne     error0

                cmpi.b  #$27,d0
                beq.s   mkplis5a
                cmpi.b  #$22,d0
                beq.s   mkplis5a
                cmpi.b  #'$',d0
                bne     readpa7

                addq.l    #1,a6
mkplis5a:       moveq.l   #0,d5
readpa1:        bsr       skip_space
                bne       error0

                cmpi.b  #'#',d0
                beq.s   mkplis7a
                cmpi.b  #$27,d0
                beq     mkplis8
                cmpi.b  #$22,d0
                beq     mkplis8

mkplis5b:
                bsr     get_term        ;Patchwert
                bsr     get_extension   ;und dessen Breite holen
mkplis5c:       add.l   D1,D5           ;Breite zur Laenge
                adda.l  d1,a1           ;und zur Adresse addieren
                cmp.l     d6,d5
                bhi       readpaerr
                add.l     d1,current_adr
readpa2:
                movea.l   a1,a0
readpa3:
                move.b    d0,-(a0)
                lsr.l     #8,d0
                subq.l    #1,d1
                bne.s     readpa3
readpa4:
                bsr       skip_space
                bne       readpaend
                cmpi.b    #',',(a6)+
                beq.s     readpa1
                bra       error2
mkplis7a:
                move.l    variable(pc),d0
                addq.l    #1,a6
                move.b    (a6)+,d2
                and.b     #$DF,d2
                moveq.l   #1,d1
                cmpi.b    #'B',d2
                beq.s     mkplis5c
                moveq.l   #2,d1
                cmpi.b    #'W',d2
                beq.s     mkplis5c
                moveq.l   #4,d1
                cmpi.b    #'L',d2
                beq.s     mkplis5c
                bra       error29
mkplis8:
                move.b    (a6)+,d1
readpa6:
                move.b    (a6)+,d0
                beq       error0
                cmp.b     #$0D,d0
                beq       error0
                cmp.b     #$0A,d0
                beq       error0
                cmp.b     d1,d0
                beq.s     readpa4
                cmp.l     d6,d5
                bcc.s     readpaerr
                move.b    d0,(a1)+
                addq.l    #1,d5
                addq.l    #1,current_adr
                bra.s     readpa6
readpa7:        bsr       getfilename
                bne       error0
                bsr       read_length
                cmp.l     d6,d0
                bhi.s     readpaerr
                bsr       read_file
                bra.s     readpae1

readpaerr:
                moveq.l   #-1,d0
                movem.l   (a7)+,d1-d7/a0-a5
                rts
readpaend:
                move.l    d5,d0
readpae1:
                moveq.l   #0,d5
                movem.l   (a7)+,d1-d7/a0-a5
                rts


****************************************
* Routinen zum auslesen der Systemvariablen

get_base:       move.l  d0,-(a7)
                lea.l   basevar(pc),a0
                bsr     read_var        ;Variable auslesen
                bne     error25         ;Nicht gefunden? Ja! =>
                movea.l D0,A0           ;Variablenwert nach A0
                move.l  (a7)+,d0
                rts

get_length:     move.l  a0,-(a7)
                lea.l   lengthvar(pc),a0
                bsr     read_var        ;Variable auslesen
                bne     error25         ;Nicht gefunden? Ja! ?>
                move.l  (a7)+,a0
                rts

get_reloc_adr:  move.l  d0,-(a7)
                lea.l   relocvar(pc),a0
                bsr     read_var        ;Variablenwert lesen
                bne.s   getrel1         ;Nicht vorhanden? Ja! =>
                movea.l D0,A0           ;Variablenwert nach A1
                move.l  (a7)+,d0
                rts
getrel1:        suba.l  A0,A0           ;Defaultwert (= nicht Relozieren) setzen
                move.l  (a7)+,d0
                rts

get_width:      move.l  a0,-(a7)
                lea.l   widthvar(pc),a0
                bsr     read_var        ;Variablewert lesen
                bne     error25         ;Nicht vorhanden? Ja! =>
                cmp.l   #8,D0           ;Wert OK?
                beq.s   getwid1         ;Ja! =>
                cmp.l   #16,D0          ;Wert OK?
                beq.s   getwid1         ;Ja! =>
                cmp.l   #32,D0          ;Wert OK?
                beq.s   getwid1         ;Ja! =>
                cmp.l   #64,D0          ;Wert OK?
                bne     error31         ;Nein! =>
getwid1:        move.l  (a7)+,a0
                rts


get_crc:        move.l    a0,-(a7)
                lea.l     crcvar(pc),a0
                bsr       read_var
                beq.s     get_crc1
                moveq.l   #0,d0
get_crc1:       movea.l   (a7)+,a0
                rts

****************************************
* get_term: Ausdruck aus Text auswerten
* IN  A6.l: Pointer auf Ausdruck
* OUT D0.l: Wert des Ausdrucks
*     D1.w: Prioritaet (high) und Abbruchzeichen (low)

get_term:       movem.l D1-A1,-(SP)     ;Benutzte Register sichern
                moveq   #0,D7           ;Anzahl der Verschachtelungen resetten
                bsr     get_number      ;1. Zahl holen
                beq     getter0
                bpl     getter1
                bra     error33
getter0:        bsr     get_command     ;1. Kommando holen
                beq     gettere3        ;Fertig =>
getter1:        move.l  D0,-(SP)        ;und sichern
                move.w  D1,-(SP)
getter6:        addq.w  #1,D7           ;Anzahl der Verschachtelungen erhoehen
getter2:        bsr     get_number      ;naechste Zahl holen
                beq.s     getter3
                bpl.s     getter4
                tst.b     1(a7)
                bmi.s     getter5
                bra       error50
getter3:
                bsr       get_command
getter4:
                move.l    d0,-(a7)
                move.w    d1,-(a7)
getter4a:       move.b    6(a7),d0
                cmp.b     (a7),d0
                bcs.s     getter6
                move.w    (a7)+,d3
                move.l    (a7)+,d2
getter5:
                move.w    (a7)+,d0
                move.l    (a7)+,d1
                lea.l     optab(pc),a0
                move.w    d0,d4
                and.w     #$007F,d4
                cmp.w     (a0)+,d4
                bcc       error8
                add.w     d4,d4
                move.w    0(a0,d4.w),d4
                bmi       error8
                jmp       opfuncs(pc,d4.w)

opfuncs:

lower:          cmp.l   D2,D1           ;Kleiner-Vergleich
                blo.s   end_true
                bra.s   end_false

lower_equal:    cmp.l   D2,D1           ;Kleinergleich-Vergleich
                bls.s   end_true
                bra.s   end_false

unequal:        cmp.l   D2,D1           ;Ungleichheits-Vergleich
                bne.s   end_true
                bra.s   end_false

greater:        cmp.l   D2,D1           ;Groesser-Vergleich
                bhi.s   end_true
                bra.s   end_false

greater_equal:  cmp.l   D2,D1           ;Groessergleich-Vergleich
                bhs.s   end_true
                bra.s   end_false

equal:          cmp.l   D2,D1           ;Gleichheits-Vergleich
                beq.s   end_true


end_false:      moveq   #0,D1           ;Ende fuer Bedingung nicht erfuellt
                bra     end_do

end_true:       moveq   #1,D1           ;Ende fuer Bedingung erfuellt
                bra     end_do

do_in:
                move.l    d1,d2
do_in1:
                bsr       get_term
                cmp.l     d0,d2
                beq.s     do_in3
                bsr       skip_space
                bne       error0
                cmpi.b    #',',(a6)+
                beq.s     do_in1
                cmp.b     #']',d0
                bne       error49
                moveq.l   #0,d1
                bra       end_in
do_in2:
                bsr       get_term
do_in3:
                bsr       skip_space
                bne       error0
                cmpi.b    #',',(a6)+
                beq.s     do_in2
                cmp.b     #']',d0
                bne       error49
                moveq.l   #1,d1
                bra       end_in
do_push:
                exg       d1,d2
                move.w    d3,d4
                and.w     #$FF00,d4
                cmp.w     #$0100,d4
                beq       end_in
                move.l    d2,-(a7)
                move.w    d0,-(a7)
                move.l    d1,-(a7)
                move.w    d3,-(a7)
                bra       getter6

do_error:
                bra       error10
do_uminus:
                neg.l     d2
                move.l    d2,d1
                bra       end_do
do_not:
                not.l     d2
                move.l    d2,d1
                bra       end_do
do_boolnot:
                tst.l     d2
                bne.s     do_bool1
                moveq.l   #1,d1
                bra       end_do
do_bool1:
                subq.l    #1,d2
                bne       error16
                moveq.l   #0,d1
                bra       end_do

do_xor:         eor.l   D2,D1           ;Exklusivoder-Routine
                bra     end_do

do_or:          or.l    D2,D1           ;Oder-Routine
                bra     end_do

do_and:         and.l   D2,D1           ;Und-Routine
                bra     end_do

do_add:         add.l   D2,D1           ;Additions-Routine
                bra     end_do

do_sub:         sub.l   D2,D1           ;Subtraktions-Routine
                bra     end_do

do_mult:        cmp.l   D2,D1           ;Multiplikations-Routine
                bhi.s   do_mult1        ;den groesseren Wert
                exg     D1,D2           ;nach D1 vertauschen
do_mult1:       move.l  D2,D0           ;Ist kleinerer Wert
                swap    D0              ;groesser als
                tst.w   D0              ;$10000?
                bne     error7          ;Ja! => ueberlauf
                moveq   #0,D0           ;Lowword von D1
                move.w  D1,D0           ;mit D2
                mulu    D2,D0           ;multiplizieren
                clr.w   D1              ;Highword von D1
                swap    D1              ;mit D2
                mulu    D2,D1           ;multiplizieren
                swap    D1              ;Hat ueberlauf
                tst.w   D1              ;stattgefunden?
                bne     error7          ;Ja! =>
                add.l   D0,D1           ;Summe beider Produkte = Ergebnis
                bcs     error7          ;ueberlauf? Ja! =>
                bra     end_do

do_div:         tst.l   D2              ;Divisions-Routine
                beq     error9          ;Divisor = 0? Ja! => Division durch 0
                move.l  D2,D0           ;Divisor
                swap    D0              ;groesser als
                tst.w   D0              ;$10000?
                bne.s   do_div2         ;Ja! =>
                swap    D1              ;Highword des Dividenten (D1)
                moveq   #0,D0           ;durch
                move.w  D1,D0           ;Divisor (D2)
                divu    D2,D0           ;teilen
                moveq   #0,D4           ;Quotient
                move.w  D0,D4           ;mal $10000
                swap    D4              ;nach D4
                swap    D1              ;Lowword des Dividenten (D1)
                move.w  D1,D0           ;durch Divisor (D2)
                divu    D2,D0           ;teilen
                move.w  D0,D4           ;Quotient zu D4 'addieren'
                move.l  D4,D1           ;Ergebnis nach D1
                bra     end_do

do_div2:        moveq   #0,D0           ;Zaehler fuer das Ergebnis auf 0 setzen
                bra.s   do_div4
do_div3:        addq.l  #1,D0           ;Ergebnis erhoehen
                sub.l   D2,D1           ;Divisor 1* vom Dividenten abziehen
do_div4:        cmp.l   D2,D1           ;Divident noch groesser als Divisor
                bhs.s   do_div3         ;Ja! =>
                move.l  D0,D1           ;Ergenis nach D1
                bra.s   end_do

do_mod:         tst.l   D2
                beq     error9
                move.l  d2,d0
                swap    d0
                tst.w   d0
                bne.s   do_mod2
                swap    d1
                moveq.l #0,d0
                move.w  d1,d0
                divu.w  d2,d0
                swap    d1
                move.w  d1,d0
                divu.w  d2,d0
                swap    d0
                moveq.l #0,d1
                move.w  d0,d1
                bra.s   end_do
do_mod1:        sub.l   d2,d1
do_mod2:        cmp.l   d2,d1
                bcc.s   do_mod1
                bra.s   end_do


do_pot:         tst.l   D2              ;Routine fuer Potenzen
                bne.s   do_pot1         ;Exponent = 0? Nein! =>
                moveq   #1,D1           ;Ergebnis = 1
                bra.s   end_do
do_pot1:        cmp.l   #1,D2           ;Exponent = 1
                beq.s   end_do          ;Ja! => Fertig
                moveq   #1,D4           ;Ergebnis auf 1 setzen
                move.l  D1,D0           ;Highword
                swap    D0              ;der Basis (D1)
                tst.w   D0              ;<> 0?
                bne     error7          ;Ja! => ueberlauf
do_pot3:        moveq   #0,D0           ;Lowword
                move.w  D4,D0           ;des Ergebnisses (D4)
                mulu.w  D1,D0           ;mit Basis (D1) multiplizieren
                clr.w   D4              ;Highword
                swap    D4              ;des Ergebnisses (D4)
                mulu.w  D1,D4           ;mit Basis (D1) multiplizieren
                swap    D4              ;mal $10000
                tst.w   D4              ;ueberlauf bei Multiplikation mit Basis?
                bne     error7          ;Ja! =>
                add.l   D0,D4           ;Summe der Produkte = neues Ergebnis
                subq.l  #1,D2           ;Exponent erniedrigen
                bne.s   do_pot3         ;Exponent schon 0? Nein! => Weiter
                move.l  D4,D1           ;Ergebnis nach D1
                bra     end_do

end_in:
                move.l    d1,d0
                bsr       get_command
                move.w    d1,d3
                move.l    d0,d1

end_do:         move.l  D1,-(SP)        ;Ergebnis und
                move.w  D3,-(SP)        ;2. Kommando wieder auf den Stack

                subq.w  #1,D7           ;Eine Verschachtelung weniger
                bne     getter4a        ;Fertig? Nein! =>
                tst.w   (a7)
                bne     getter6
                addq.l   #2,a7
                move.l  (SP)+,D0        ;Ergebnis und
gettere3:       movem.l (SP)+,D1-A1     ;Register wiederholen
                rts

****************************************
* get_number: Holt Zahl aus Text
* IN  A6.l: Pointer auf Zahl
* OUT D0.l: Fehlerflag
*     D1.l: Zahl

get_number:     movem.l   d2/a0-a1,-(a7)
                bsr     skip_space      ;Zeilenende?
                bne.s     get_num4
                lea.l     upriority(pc),a0
get_num1:
                tst.b     (a0)
                beq.s     get_num4
                movea.l   a6,a1
                moveq.l   #7,d2
get_num2:
                move.b    (a1)+,d0
                beq.s     get_num4
                cmp.b     #'a',d0
                bcs.s     get_num3
                cmp.b     #'z',d0
                bhi.s     get_num3
                and.b     #$DF,d0
get_num3:
                move.b    (a0)+,d1
                beq.s     get_num6
                cmp.b     d0,d1
                bne.s     get_num5
                subq.l    #1,d2
                bpl.s     get_num2
get_num4:
                bsr.s     get_unsigned
                bne       error11
                moveq.l   #0,d1
                movem.l   (a7)+,d2/a0-a1
                rts
get_num5:
                adda.l    d2,a0
                addq.l    #2,a0
                bra.s     get_num1
get_num6:
                subq.l    #1,a1
                movea.l   a1,a6
                adda.l    d2,a0
                moveq.l   #0,d0
                move.w    (a0),d1
                movem.l   (a7)+,d2/a0-a1
                rts

****************************************
* get_unsigned: Zahl aus Text holen
* IN  A6.l: Pointer auf Zahl
* OUT D0.l: 1. Zeichen nach der Zahl
*     D1.l: Zahl
*     D2.l: Fehlerflag

get_unsigned:   movem.l   d1/a0,-(a7)
                bsr     skip_space      ;Zeilenende?
                bne     error0          ;Ja! =>
                cmpi.b  #'~',d0         ;Ist es die Tilde?
                beq.s   get_current     ;Ja! =>
                cmpi.b  #'%',d0
                beq     get_ubin
                cmpi.b  #'.',d0         ;Ist es Dezimalzahl oder Variable?
                bne     get_uhex        ;Nein! =>
                cmpi.b  #'0',1(A6)      ;Ist es eine Dezimalzahl?
                blo.s   get_var         ;Nein! =>
                cmpi.b  #'9',1(A6)
                bls     get_udez        ;Ja! =>

get_var:        bsr     get_vname       ;Variablenname holen
                bsr     read_var        ;Wert der Variable holen
                bne     error13         ;Variable nicht gefunden? Ja! =>
                bra     get_uend

get_ubin:       bsr       get_binbyte
                bra.s     get_u1
get_uhex:       bsr.s     get_hexbyte
                bra.s     get_u1
get_udez:       bsr.s     get_dezbyte
get_u1:         bne.s     get_uerr
                bra.s     get_uend

get_current:    addq.l  #1,A6           ;'#' uebespringen
                move.l  current_adr(pc),D0 ;Aktuelle Adresse holen

get_uend:       moveq   #0,D1
                movem.l (a7)+,d1/a0
                rts
get_uerr:       moveq.l #0,d0
                moveq.l #-1,d1
                movem.l (a7)+,d1/a0
                rts

****************************************
* get_hexbyte: Hexadezimalzahl aus Text holen
* IN  A6.l: Pointer auf Zahl
* OUT D0.l: 1. Zeichen nach der Zahl
*     D1.l: Zahl
*     D2.l: Fehlerflag

get_hexbyte:    movem.l d1/d7,-(a7)
                moveq   #-1,D7          ;'Fehler' setzen
                moveq   #0,D0           ;Zahl auf 0 setzen
gethexb1:       moveq   #0,D1           ;Zeichen
                move.b  (A6)+,D1        ;holen
                eori.b  #'0',D1         ;Ist eine
                cmp.b   #9,D1           ;Hex-Zahl?
                bls.s   gethexb2    ;Ja! =>
                eori.b  #'0',D1
                and.b   #$DF,D1         ;in Grossschrift wandeln
                sub.b   #'A',D1         ;Ist es ein Hex-Zeichen?
                bmi.s   gethexb3    ;Nein! =>
                cmp.b   #5,D1
                bhi.s   gethexb3    ;Nein! =>
                add.b   #10,D1
gethexb2:       lsl.l   #4,D0           ;Zahl *$10
                or.b    D1,D0           ;Ziffer addieren
                moveq   #0,D7           ;'OK' setzen
                bra.s   gethexb1    ;Weiter
gethexb3:       subq.l  #1,a6        ;Pointer korrigieren
                tst.l   D7
                movem.l (a7)+,d1/d7
                rts

****************************************
* get_dezbyte: Dezimalzahl aus Text holen

get_dezbyte:    movem.l d1/d7,-(a7)
                moveq   #-1,D7
                moveq   #0,D0

                cmpi.b  #'.',(A6)+
                bne.s   getdezb3

getdezb1:       moveq   #0,D1
                move.b  (A6)+,D1
                sub.b   #'0',D1
                bmi.s   getdezb3
                cmp.b   #9,D1
                bhi.s   getdezb3

                moveq   #0,D7
                add.l   D0,D0
                bcs.s   getdezb2
                add.l   D0,D1
                bcs.s   getdezb2
                lsl.l   #2,D0
                bcs.s   getdezb2
                add.l   D1,D0
                bcc.s   getdezb1
getdezb2:       moveq   #-1,D7
getdezb3:       subq.l  #1,a6        ;Pointer korrigieren
                tst.l   D7
                movem.l   (a7)+,d1/d7
                rts

****************************************
* get_binbyte: read binary value

get_binbyte:
                movem.l   d1/d7,-(a7)
                moveq.l   #-1,d7
                moveq.l   #0,d0
                cmpi.b    #'%',(a6)+
                bne.s     get_bin3
                moveq.l   #0,d1
get_bin1:       move.b    (a6)+,d1
                sub.b     #'0',d1
                bmi.s     get_bin3
                cmp.b     #1,d1
                bhi.s     get_bin3
                moveq.l   #0,d7
                add.l     d0,d0
                bcs.s     get_bin2
                add.l     d1,d0
                bcc.s     get_bin1
get_bin2:       moveq.l   #-1,d7
get_bin3:       subq.l    #1,a6
                tst.l     d7
                movem.l   (a7)+,d1/d7
                rts

****************************************
* get_command: Holt Kommando und dessen Prioriaet aus Text
* IN  A6.l: Pointer auf Kommando
* OUT D1.w: Prioritaet (High) und Abbruchzeichen (Low)

get_command:    movem.l   d0/d2/a0-a1,-(a7)
                bsr     skip_space      ;Zeilenende?
                bne.s   getcmd5         ;Ja! =>

getcmd1:        lea     priority(pc),A0 ;Tabellenadresse holen

getcmd2:        tst.b  (a0)             ;Schon die ganze Tabelle verglichen?
                beq.s   getcmd5         ;Ja =>
                movea.l A6,A1           ;Textpointer nach A1
                moveq   #8-1,D2         ;Kommandoname ist max. 8 Stellen
getcmd3:        move.b  (A1)+,D0        ;Zeichen holen
                beq.s   getcmd5
                cmp.b   #'a',D0         ;Kleinschrift?
                blo.s   getcmd3a        ;Nein! =>
                cmp.b   #'z',D0
                bhi.s   getcmd3a        ;Nein! =>
                and.b   #$DF,D0         ;Ja! : In Grossschrift wandeln
getcmd3a:       move.b  (A0)+,D1        ;Mit Tabelle vergleichen
                beq.s   getcmd6
                cmp.b   d0,d1
                bne.s   getcmd4         ;Ungleich? Ja! =>
                subq.l  #1,d2
                bpl.s   getcmd3

getcmd5:        moveq   #0,D1           ;0 fuer Abbruch/kein Kommando
                movem.l (a7)+,d0/d2/a0-a1
                rts

getcmd4:        adda.l  D2,A0           ;Naechsten Tabelleneintrag
                addq.l  #2,A0           ;berechnen
                bra.s   getcmd2

getcmd6:        subq.l  #1,a1
                movea.l a1,a6
                adda.l  D2,A0           ;Zeiger auf Prioritaet setzen
getcmd7:        move.w  (A0),D1         ;Prioritaet holen
                movem.l (a7)+,d0/d2/a0-a1
                rts

****************************************
* get_extension: Holt die Erweiterung eines Ausdrucks
* IN  A6.l: Pointer auf Extension
* OUT D2.l: Extension (B/W/L)

get_extension:  move.l  d0,-(SP)        ;Benutzte Register sichern
                moveq.l #1,d1
                bsr     skip_space      ;Zeilenende?
                bne.s   getext1         ;Ja! =>
                cmpi.b  #'.',d0         ;Extension vorhanden?
                bne.s   getext1         ;Nein! =>
getext0:        addq.l  #1,A6           ;'.' ueberspringen
                move.b  (A6)+,D0        ;Wert der Extension holen
                and.b   #$DF,D0         ;Auf Grossbuchstaben wandeln
                cmp.b   #'B',D0         ;Ist es Byte?
                beq.s   getext1         ;Ja! =>
                moveq   #2,D1           ;Word schon mal setzen
                cmp.b   #'W',D0         ;Ist es Word?
                beq.s   getext1         ;Ja! =>
                moveq   #4,D1           ;Long schon mal setzen
                cmp.b   #'L',D0         ;Ist es Long?
                bne     error53         ;Nein! =>
getext1:        move.l  (SP)+,D0
                rts

get_vname:      move.l  d0,-(a7)
                cmpi.b  #'.',(A6)+
                bne       error8
                movea.l   a6,a0
                move.b    (a6),d0
                bsr       getvc
                bne       error8
                move.b    d0,(a6)+
get_vn1:        move.b    (a6),d0
                bsr       getvc
                bmi.s     get_vn2
                move.b    d0,(a6)+
                bra.s     get_vn1
get_vn2:        move.l    (a7)+,d0
                rts

read_var:       movem.l d7/a0-a1,-(a7)
                bsr.s   search_var
                bne.s   readvar1
                move.l  (A1),D0
                moveq.l #0,d7
                movem.l (a7)+,d7/a0-a1
                rts
readvar1:       moveq   #0,D0
                moveq   #-1,D7
                movem.l (a7)+,d7/a0-a1
                rts

write_var:      movem.l   d0-d2/a0-a2,-(a7)
                move.l    d0,d2
                movea.l   a0,a2
                bsr.s     search_var
                beq.s     makev4
make_var:       move.w    #16,d1
                move.b    (a2)+,d0
                bsr       getvc
                bne       error8
                bra.s     makev2
makev1:         move.b    (a2)+,d0
                bsr.s     getvc
                bmi.s     makev3
makev2:         move.b    d0,(a0)+
                subq.w    #1,d1
                bne.s     makev1
                bra.s     makev4
makev3:         clr.b     (a0)+
                subq.w    #1,d1
                bne.s     makev3
makev4:         move.l    d2,(a1)
                movem.l   (a7)+,d0-d2/a0-a2
                rts

search_var:     movem.l   d0-d2/a2-a5,-(a7)
                movea.l   a0,a2
                move.l    #$00000400,d2
                lea.l     varname(pc),a0
                lea.l     varvalue(pc),a1
                suba.l    a4,a4
srchvar1:       move.w    #16,d1
                movea.l   a2,a3
                tst.b     (a0)
                bne.s     srchvar2
                tst.w     (a0)
                beq.s     srchvar6
                movea.l   a0,a4
                movea.l   a1,a5
srchvar2:       move.b    (a3)+,d0
                bsr.s     getvc
                bmi.s     srchvar4
                cmp.b     (a0),d0
                bne.s     srchvar5
                addq.l    #1,a0
                subq.w    #1,d1
                bne.s     srchvar2
srchvar3:       moveq.l   #0,d0
                bra.s     srchvar8
srchvar4:       tst.b     (a0)
                bne.s     srchvar5
                adda.w    d1,a0
                suba.w    #16,a0
                bra.s     srchvar3
srchvar5:       adda.w    d1,a0
                addq.l    #4,a1
                subq.l    #1,d2
                bne.s     srchvar1
                bra       error24
srchvar6:       move.l    a4,d0
                beq.s     srchvar7
                movea.l   a4,a0
                movea.l   a5,a1
srchvar7:       moveq.l   #-1,d0
srchvar8:       movem.l   (a7)+,d0-d2/a2-a5
                rts

getvc:          movem.l   d1,-(a7)
                moveq.l   #1,d1
                cmp.b     #'0',d0
                bcs.s     getvc2
                cmp.b     #'9',d0
                bls.s     getvc1
                moveq.l   #0,d1
                cmp.b     #$5F,d0
                beq.s     getvc1
                and.b     #$DF,d0
                cmp.b     #'A',d0
                bcs.s     getvc2
                cmp.b     #'Z',d0
                bhi.s     getvc2
getvc1:         tst.l     d1
                movem.l   (a7)+,d1
                rts
getvc2:         moveq.l   #-1,d1
                movem.l   (a7)+,d1
                rts


getfilename:
                movem.l   d0-d1,-(a7)
                moveq.l   #0,d0
                lea.l     filename(pc),a0
getfil1:        move.b    (a6)+,d1
                beq.s     getfil2
                cmp.b     #13,d1
                beq.s     getfil2
                cmp.b     #10,d1
                beq.s     getfil2
                cmpi.b    #' ',d1
                beq.s     getfil2
                cmpi.b    #9,d1
                beq.s     getfil2
                cmp.b     #';',d1
                beq.s     getfil2
                move.b    d1,(a0)+
                addq.b    #1,d0
                bpl.s     getfil1
getfil3:        lea.l     filename(pc),a0
                moveq.l   #-1,d0
                movem.l   (a7)+,d0-d1
                rts
getfil2:        clr.b     (a0)
                subq.l    #1,a6
                tst.b     d0
                beq.s     getfil3
                lea.l     filename(pc),a0
                moveq.l   #0,d0
                movem.l   (a7)+,d0-d1
                rts

skip_space:     movem.l d7,-(a7)
skipspa1:       move.b  (A6)+,D0
                beq.s   skipspa2
                cmpi.b  #' ',D0
                beq.s   skipspa1
                cmpi.b  #9,D0
                beq.s   skipspa1
                cmp.b   #';',D0
                beq.s   skipspa2
                cmp.b   #$0D,D0
                beq.s   skipspa2
                cmp.b   #$0A,D0
                beq.s   skipspa2
                subq.l  #1,A6
                moveq   #0,D7
                movem.l (a7)+,d7
                rts
skipspa2:       subq.l  #1,A6
                moveq   #-1,D7
                movem.l (a7)+,d7
                rts


/*
 * get a filename
 */
getfname:       movem.l   d7,-(a7)
getfnam1:       move.b    (a6)+,d0
                beq.s     getfnam2
                cmpi.b    #' ',d0
                beq.s     getfnam1
                subq.l    #1,a6
                moveq.l   #0,d7
                movem.l   (a7)+,d7
                rts
getfnam2:       subq.l    #1,a6
                moveq.l   #-1,d7
                movem.l   (a7)+,d7
                rts

****************************************
* write_file: Schreibt ein File auf Disk
* IN A0.l: Zeiger auf den Filename
*    A1.l: Zeiger auf abzuspeichernde Daten
*    D0.l: Anzahl der zu speichernden Bytes

write_file:     movem.l D1-A6,-(SP)
                bsr.s   write
                cmp.l   D5,D3
                bne     rw_err
                bsr.s   rw_ok
                move.l  D3,D0
                movem.l (SP)+,D1-A6
                rts

****************************************
* read_file: Liest ein File bestimmter von Disk
* IN A0.l: Zeiger auf den Filename
*    A1.l: Zeiger auf Datenpuffer
*    D0.l: Anzahl der zu lesenden Bytes

read_file:      movem.l D0-A6,-(SP)
                bsr.s   read
                cmp.l   D5,D3
                bne.s   rw_err
                bsr.s   rw_ok
                movem.l (SP)+,D0-A6
                rts

****************************************
* write/read: Fcreate/Fwrite/Fclose bzw. Fopen/Fread/Fclose
* IN A0.l: Zeiger auf den Filename
*    A1.l: Zeiger auf Datenpuffer
*    D0.l: Anzahl der zu bearbeitenden Bytes

write:          moveq   #$3C,D3         ;Fcreate
                moveq   #$40,D4         ;Fwrite
                bra.s   rw_file

read:           moveq   #$3D,D3         ;Fopen
                moveq   #$3F,D4         ;Fread

rw_file:        move.l  A1,-(SP)        ;File-Puffer
                move.l  D0,-(SP)        ;Anzahl der zu bearbeitenden Bytes
                move.l  D0,D5           ;sichern

                clr.w   -(SP)           ;keine bes. Attribute
                move.l  A0,-(SP)        ;Adresse des Filenames

                lea     space_text(pc),A0
                bsr     print_line
                movea.l (SP),A0
                bsr     print_line

                move.w  D3,-(SP)        ;Fcreate/Fopen
                trap    #1              ;GEMDOS 60/61
                addq.l  #8,SP

                move.w  D0,D7           ;Handle merken
                bmi.s   rw_err          ;Fehler? Ja! =>

                move.w  D7,-(SP)        ;Handle
                move.w  D4,-(SP)        ;Fwrite/Fread
                trap    #1              ;GEMDOS 64/63
                lea     12(SP),SP

                move.l  D0,D3           ;Anzahl der bearbeiteten Bytes merken
                bmi.s   rw_err1

                move.w  D7,-(SP)        ;Handle
                move.w  #$003E,-(SP)    ;Fclose
                trap    #1              ;GEMDOS 62
                addq.l  #4,SP

                tst.w   D0
                bmi.s   rw_err

                rts

****************************************
* rw_ok/rw_err: Routinen fuer erfolgreichen bzw. fehlerhaften Abschluss

rw_ok:          lea     ok_text(pc),A0
                bra     print_line

rw_err1:        move.w  D7,-(SP)        ;Handle
                move.w  #$003E,-(SP)    ;Fclose
                trap    #1              ;GEMDOS 62
                addq.l  #4,SP

rw_err:         lea     error_text(pc),A0
                bsr     print_line
                move.w  #10,d7
                bra     exit1

****************************************
* read_length: Bestimmt die Laenge eines Files
* IN A0.l: Zeiger auf den Filename

read_length:    movem.l D1-A6,-(SP)     ;Register retten

                clr.w   -(SP)           ;Nur Lesen
                move.l  A0,-(SP)        ;Zeiger auf Filename
                move.w  #$003D,-(SP)    ;Fopen
                trap    #1              ;GEMDOS 61
                addq.l  #8,SP

                move.w  D0,D7           ;Handle merken
                bmi.s   rl_err          ;Fehler? Ja! =>

                clr.w   -(SP)           ;Ab Anfang
                move.w  D7,-(SP)        ;Handle
                clr.l   -(SP)           ;0 Bytes ueberspringen
                move.w  #$0042,-(SP)    ;Fseek
                trap    #1              ;GEMDOS 66
                lea     10(SP),SP

                move.l  D0,D5           ;Dateianfang merken
                bmi.s   rl_err          ;Fehler? Ja! =>

                move.w  #2,-(SP)        ;Ab Ende
                move.w  D7,-(SP)        ;Handle
                clr.l   -(SP)           ;0 Bytes ueberspringen
                move.w  #$0042,-(SP)    ;Fseek
                trap    #1              ;GEMDOS 66
                lea     10(SP),SP

                move.l  D0,D6           ;Dateiende merken
                bmi.s   rl_err          ;Fehler? Ja! =>

                move.w  D7,-(SP)        ;Handle
                move.w  #$003E,-(SP)    ;Fclose
                trap    #1              ;GEMDOS 62
                addq.l  #4,SP

                tst.w   D0              ;Fehler?
                bmi.s   rl_err1         ;Ja! =>

                sub.l   D5,D6           ;Dateilaenge = Dateiende - Dateianfang
                move.l  D6,D0           ;Dateilaenge nach D0

                movem.l (SP)+,D1-A6     ;Register wiederholen
                rts

rl_err:         move.w  D7,-(SP)        ;Handle
                move.w  #$003E,-(SP)    ;Fclose
                trap    #1              ;GEMDOS 62
                addq.l  #4,SP

rl_err1:        lea     space_text(pc),A0
                bsr     print_line
                movem.l (SP)+,D1-A6     ;Register wiederholen
                bsr     print_line      ;Filename ausgeben
                lea     error_text(pc),A0 ;'...Fehler'
                bsr     print_line      ;ausgeben
                move.w  #10,d7
                bra     exit1

****************************************

fcreate:
                movem.l   d1-d7/a0-a6,-(a7)
                movea.l   a0,a1
                lea.l     space_text(pc),a0
                bsr       print_line
                movea.l   a1,a0
                bsr       print_line
                move.w    #0,-(a7)
                pea.l     (a1)
                move.w    #$003C,-(a7)
                trap      #1
                addq.l    #8,a7
                tst.w     d0
                bmi       rw_err
                bsr       rw_ok
                movem.l   (a7)+,d1-d7/a0-a6
                rts

fclose:
                movem.l   d1-d7/a0-a6,-(a7)
                movea.l   a0,a1
                lea.l     space_text(pc),a0
                bsr.s     print_line
                movea.l   a1,a0
                bsr.s     print_line
                move.w    d0,-(a7)
                move.w    #$003E,-(a7)
                trap      #1
                addq.l    #4,a7
                lea.l     ok_text(pc),a0
                tst.w     d0
                bpl.s     fclose1
                lea.l     error_text(pc),a0
fclose1:        bsr.s     print_line
                movem.l   (a7)+,d1-d7/a0-a6
                rts

malloc:
                movem.l   d0-d7/a1-a6,-(a7)
                addq.l    #2,d0
                move.l    d0,-(a7)
                move.w    #$0048,-(a7)
                trap      #1
                addq.l    #6,a7
                moveq.l   #-1,d1
                cmp.l     d0,d1
                beq       error6
                addq.l    #1,d0
                and.b     #$FE,d0
                movea.l   d0,a0
                movem.l   (a7)+,d0-d7/a1-a6
                rts

mfree:
                movem.l   d0-d7/a0-a6,-(a7)
                move.l    a0,-(a7)
                move.w    #$0049,-(a7)
                trap      #1
                addq.l    #6,a7
                movem.l   (a7)+,d0-d7/a0-a6
                rts

****************************************
* print_line: Gibt einen Text aus, der mit einem Nullbyte endet
* IN A0.l: Adresse des Textes

print_line:     movem.l D0-A6,-(SP)
                bsr.s   cconws
                bsr     logline
                bsr.s   prline
                movem.l (a7)+,d0-d7/a0-a6
                rts

cconws:         movem.l   d0-d7/a0-a6,-(a7)
                move.b    quiet(pc),d0
                bne.s     cconws1
                move.l    a0,-(a7)
                move.w    #$0009,-(a7)
                trap      #1
                addq.l    #6,a7
cconws1:        movem.l   (a7)+,d0-d7/a0-a6
                rts

prline:         movem.l   d0-d7/a0-a6,-(a7)

                move.w  #$000B,-(SP)    ;Cconis
                trap    #1              ;GEMDOS 11
                addq.l  #2,SP

                tst.w   D0              ;Ein Zeichen verfuegbar?
                beq.s   prline2         ;Nein! => Zurueck

                move.w  #$0008,-(SP)    ;Cnecin
                trap    #1              ;GEMDOS 8
                addq.l  #2,SP

                cmp.b   #$1B,D0         ;War 'ESC' gedrueckt?
                beq.s   abbruch         ;Ja! => Abbruch

prline1:        move.w  #$000B,-(SP)    ;Cconis
                trap    #1              ;GEMDOS 11
                addq.l  #2,SP

                tst.w   D0              ;Ein Zeichen verfuegbar?
                beq.s   prline1         ;Nein! => weiter auf ein Zeichen warten

                move.w  #$0008,-(SP)    ;Cnecin
                trap    #1              ;GEMDOS 8
                addq.l  #2,SP

                cmp.b   #$1B,D0         ;War 'ESC' gedrueckt?
                bne.s   prline2         ;Nein! => Zurueck

abbruch:        pea     abbruch_text(pc)
                move.w  #9,-(SP)        ;Cconws
                trap    #1              ;GEMDOS 9
                addq.l  #6,SP
                move.w  #2,d7
                bra     exit1           ;Programm abbrechen

prline2:        movem.l (SP)+,D0-A6     ;Zurueck
                rts

****************************************
* print_point: Gibt einen Punkt aus

print_point:    move.l  A0,-(SP)
                lea     point_text(pc),A0
                bsr     print_line
                movea.l (SP)+,A0
                rts

****************************************
* hex_out: Gibt eine hexadezimale Zahl aus
* IN D0.l: Auszugebende Zahl

hex_out2:       movem.l D0/D6-A1,-(SP)
                lea     number_puffer(pc),A0
                movea.l A0,A1
                move.l  #$24303000,(A1)+
                subq.l  #1,A1
                moveq   #1,D7
                bra.s   hex_out1

hex_out:        movem.l D0/D6-A1,-(SP)
                lea     number_puffer(pc),A0
                movea.l A0,A1
                move.l  #$24303030,(A1)+
                move.l  #$30303030,(A1)+
                move.w  #$3000,(A1)+
                subq.l  #1,A1
                moveq   #7,D7
hex_out1:       move.b  D0,D6
                and.b   #$0F,D6
                add.b   D6,-(A1)
                cmp.b   #10,D6
                blo.s   hex_out3
                addq.b  #'A'-('9'+1),(A1)
hex_out3:       lsr.l   #4,D0
                dbra    D7,hex_out1
                bsr     print_line
                movem.l (SP)+,D0/D6-A1
                rts

****************************************
* dez_out: Gibt eine dezimale Zahl aus
* IN D0.l: Auszugebende Zahl

dez_out:        movem.l D0/D6-A2,-(SP)

                lea     number_puffer(pc),A0
                lea     1(A0),A1
                move.l  #$2e300000,(A0)
                lea     dez_tab(pc),A2
dez_out0:       move.l  (A2)+,D7
                beq.s   dez_out5
                cmp.l   D7,D0
                blo.s   dez_out0
                subq.l  #4,a2
dez_out1:       moveq   #'0',D6
                move.l  (A2)+,D7
                beq.s   dez_out4
                cmp.l   D7,D0
                blo.s   dez_out3
dez_out2:       addq.b  #1,D6
                sub.l   D7,D0
                cmp.l   D7,D0
                bhs.s   dez_out2
dez_out3:       move.b  D6,(A1)+
                bra.s   dez_out1
dez_out4:       clr.b   (A1)
dez_out5:       bsr     print_line

                movem.l (SP)+,D0/D6-A2
                rts

bin_out:        movem.l   d0/d6-d7/a0-a1,-(a7)
                lea.l     number_puffer(pc),a0
                movea.l   a0,a1
                move.w    #$2530,(a1)+
                moveq.l   #31,d7
bin_out1:       add.l     d0,d0
                dbcs      d7,bin_out1
                tst.w     d7
                bmi.s     bin_out4
                addq.b    #1,-1(a1)
bin_out2:       subq.w    #1,d7
                bmi.s     bin_out4
                move.b    #$30,d1
                add.l     d0,d0
                bcc.s     bin_out3
                addq.b    #1,d1
bin_out3:       move.b    d1,(a1)+
                bra.s     bin_out2
bin_out4:       clr.b     (a1)
                bsr       print_line
                movem.l   (a7)+,d0/d6-d7/a0-a1
                rts

****************************************
* reloc_it: Reloziert das TOS

reloc_it:       bsr       get_base
                movea.l   a0,a1
                bsr       get_reloc_adr
                cmpa.l    a0,a1
                beq.s     relocite
                move.l    a0,d0

                lea     reloc_text(pc),A0
                bsr     print_line
                bsr     hex_out
                bsr     clradr
                move.b  neednl(pc),d0
                beq.s   reloc_i1
                lea.l   lf_text(pc),a0
                bsr     print_line
reloc_i1:

                bsr.s   optimize
                bsr     reloc
                bsr     forced_reloc

                move.b  neednl(pc),d0
                bne.s   reloc_i2
                lea     lf_text(pc),A0
                bsr     print_line
reloc_i2:       bsr     lognl
relocite:       rts

****************************************
* optimize: Sortiert patch_table

optimize:       lea     ptchtab(pc),A6
                movea.l A6,A0

                tst.l   (A0)+
                beq.s   optim3
optim0:         move.l  (A0),D0
                beq.s   optim3
                movea.l A0,A1
optim1:         cmpa.l  A6,A0
                beq.s   optim2
                move.l  -(A0),D1
                move.l  D1,4(A0)
                cmp.l   D1,D0
                blo.s   optim1
optim2:         move.l  D0,4(A0)
                movea.l A1,A0
                addq.l  #4,A0
                bra.s   optim0

optim3:         lea     ptchtab2(pc),A6
                movea.l A6,A0

                tst.l   (A0)
                beq.s   optim9
                addq.l  #8,A0
optim4:         move.l  (A0),D0
                beq.s   optim9
                move.l  4(A0),D1
                movea.l A0,A1
optim5:         cmpa.l  A6,A0
                beq.s   optim8
                move.l  -(A0),D3
                move.l  -(A0),D2
                move.l  D2,8(A0)
                move.l  D3,12(A0)

                cmp.l   D1,D2           ;D0/D1 < D2/D3
                bhi.s   optim5
                cmp.l   D3,D0           ;D2/D3 < D0/D1
                bhs.s   optim8

del_entry:      movea.l A1,A2           ;Vergleichanfangs-Eintrag loeschen
delent1:        move.l  8(A2),(A2)+     ;(Rest der Tabelle ein Eintrag nach
                move.l  8(A2),(A2)+     ;vorne kopieren)
                tst.l   (A2)
                bne.s   delent1

                cmp.l   D0,D2
                blo.s   optim6
                cmp.l   D1,D3
                bls.s   optim5       ;D0,D2,D3,D1

                move.l  D3,D1           ;D0,D2,D1,D3
                bra.s   optim5

optim6:         cmp.l   D1,D3
                blo.s   optim7
                move.l  D2,D0           ;D2,D0,D1,D3
                move.l  D3,D1
                bra.s   optim5

optim7:         move.l  D2,D0           ;D2,D0,D3,D1
                bra.s   optim5

optim8:         move.l  D0,8(A0)
                move.l  D1,12(A0)
                movea.l A1,A0
                addq.l  #8,A0
                bra.s   optim4

optim9:         rts

****************************************
* reloc: Reloziert das TOS
* IN base.l        : Basisadresse des TOS
*    length.l      : Laenge des TOS
*    reloc_adr.l   : Adresse, an die das TOS reloziert werden soll
*    ptchtab.l : Adresse der Tabelle mit den Relozierausnahmen
*    ptchtab2.l: Adresse der Tabelle mit den Feld-Relozierausnahmen

reloc:          bsr       get_base
                movea.l A0,A1
                bsr       get_length
                adda.l    d0,a1

                move.l  buffer(pc),A2
                movea.l A2,A3
                adda.l  d0,A3

                movea.l A2,A4

                lea     ptchtab(pc),A5
                lea     ptchtab2(pc),A6

                move.w  #$F0FF,D2
                move.w  #$6000,D3
                move.w  #$F0F8,D4
                move.w  #$50C8,D5

                move.l  (A5)+,D6
                move.l  (A6)+,D7

reloc1:         move.w  (A4)+,D1

                cmpa.l  A3,A4
                bcc     reloc9

                move.w  A4,D0
                sub.w   A2,D0
                bne.s   reloc2

                move.b  neednl(pc),d0
                bne.s   reloc2
                bsr     print_point

reloc2:         move.w  D1,D0
                and.w   D2,D0
                cmp.w   D3,D0
                beq.s   reloc3
                and.w   D4,D0
                cmp.w   D5,D0
                beq.s   reloc3
                swap    D1
                move.w  (A4),D1

                cmp.l   a0,d1
                bcs.s   reloc1
                cmp.l   a1,d1
                bcc.s   reloc1

                move.l  a4,d0
                sub.l   A2,D0
                subq.l  #2,d0
reloc2b:
                cmp.l   d6,d0
                bcs.s   reloc6
                beq.s   reloc1

                move.l  (a5)+,d6
                bne.s   reloc2b

                moveq   #-1,D6

reloc6:         cmp.l   D7,D0
                bcs.s   reloc7
                cmp.l   (A6),D0
                bcs.s   reloc1
                addq.l  #4,A6
                move.l  (A6)+,D7
                beq.s   reloc6a
                subq.l  #3,D7
                bra.s   reloc6
reloc6a:        moveq   #-1,D7

reloc7:         sub.l   A0,D1
                move.l  a0,d0
                bsr     get_reloc_adr
                add.l   a0,d1
                movea.l d0,a0
                move.l  D1,-2(A4)
                move.l  a4,d0
                subq.l  #2,d0
                sub.l   buffer(pc),d0
                bsr     logadr

reloc3:         addq.l  #2,A4

                cmpa.l  a3,a4
                bcc.s   reloc9
                move.w  A4,D0
                sub.w   A2,D0
                bne.s   reloc1
                move.b  neednl(pc),d0
                bne     reloc1
                bsr     print_point
                bra     reloc1

reloc9:         rts

****************************************
* forced_reloc: Reloziert einzelne Adressen
* IN base.l        : Basisadresse des TOS
*    reloc_adr.l   : Adresse, an die das TOS reloziert werden soll
*    forced_table.l: Tabelle mit den zu relozierenden Adressen

forced_reloc:   bsr     get_base
                move.l  a0,d1
                bsr     get_reloc_adr
                sub.l   a0,d1
                move.l  buffer(pc),A0
                lea     forced_table(pc),A3

forcer1:        move.l  (A3)+,D0
                beq.s   forcer2
                bsr     logadr
                movea.l d0,a2
                adda.l  a0,a2
                sub.l   d1,(a2)
                bra.s   forcer1
forcer2:        rts


****************************************
* CRC-Checksumme ueber TOS berechnen

crc_checksum:   movem.l   d0-d7/a0-a6,-(a7)
                bsr     get_crc
                tst.l   d0              ;Checksumme berechnen?
                beq     crc11           ;Nein! =>

                bsr     get_width
                move.l  d0,d7
                lsr.l   #2,D7

                bsr     get_length
                move.l  d0,d6
                sub.l   D7,D6

                lea     cksum_text(pc),A0
                bsr     print_line

                bsr     clradrx
                move.b  neednl(pc),d0
                beq.s   crc0
                lea.l   lf_text(pc),a0
                bsr     print_line
crc0:
                lsr.l   #1,D7
                movea.l D7,A3

                move.l  A3,D0           ;D1 = log 2 (A3)
                moveq   #0,D1
crc1:           lsr.w   #1,D0
                beq.s   crc2
                addq.l  #1,D1
                bra.s   crc1

crc2:           lsr.l   D1,D6
                movea.l D6,A4

                move.l  buffer(pc),A6
                movea.l a6,a2
                lea     crctab(pc),A1

                cmpa.w  #1,A3           ;Schrittweite 1?
                bhi.s   crc5            ;Nein! =>

********************
* CRC: einfach

crc3:           movea.l A2,A0
                move.l  A4,D2
                moveq   #0,D0
                moveq   #0,D1

crc4:           move.b  (A0),D3
                adda.l  A3,A0

                eor.b   D3,D1
                add.w   D1,D1
                lea     0(A1,D1.w),A5
                moveq   #0,D1
                move.b  (A5)+,D1
                eor.b   D0,D1
                move.b  (A5),D0

                subq.l  #1,D2
                bne.s   crc4

                move.b  D0,0(A0,A3.l)
                move.b  D1,(A0)

                move.l    a0,d0
                sub.l     a6,d0
                bsr       logcrc
                add.l     a3,d0
                bsr       logcrc
                move.b    neednl(pc),d0
                bne.s     crc4a
                bsr     print_point
crc4a:
                addq.l  #1,A2
                subq.l  #1,D7
                bne.s   crc3

                bra.s   crc9

********************
* CRC: 2 auf einmal

crc5:           subq.l  #2,A3

crc6:           movea.l A2,A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D5
                moveq   #0,D6

                moveq   #2,D4           ;2 Durchgaenge fuer (A4) Bytes

crc7:           move.l  A4,D2

crc8:           move.b  (A0)+,D3
                eor.b   D3,D1
                add.w   D1,D1
                lea     0(A1,D1.w),A5
                moveq   #0,D1
                move.b  (A5)+,D1
                eor.b   D0,D1
                move.b  (A5),D0

                move.b  (A0)+,D3
                eor.b   D3,D6
                add.w   D6,D6
                lea     0(A1,D6.w),A5
                moveq   #0,D6
                move.b  (A5)+,D6
                eor.b   D5,D6
                move.b  (A5),D5

                adda.l  A3,A0

                subq.l  #2,D2           ;2 Durchgaenge fuer (A4) Bytes
                bne.s   crc8

                move.b  neednl(pc),d2
                bne.s   crc8a
                bsr     print_point
crc8a:

                subq.l  #1,D4
                bne.s   crc7

                move.b  D0,2(A0,A3.l)
                move.b  D1,(A0)
                move.l    a0,d0
                sub.l     a6,d0
                bsr       logcrc
                add.l     a3,d0
                addq.l    #2,d0
                bsr       logcrc
                addq.l    #1,a0

                move.b  D5,2(A0,A3.l)
                move.b  D6,(A0)
                move.l    a0,d0
                sub.l     a6,d0
                bsr       logcrc
                add.l     a3,d0
                addq.l    #2,d0
                bsr       logcrc

                addq.l  #2,A2           ;Anfangsadresse um 2 erhoehen, da
                subq.l  #2,D7           ;2 Durchgaenge auf einmal erledigt
                bne.s   crc6

crc9:           
                move.b  neednl(pc),d0
                bne.s   crc10
                lea.l   space_text(pc),a0
                bsr     print_line
                lea.l   oparen_text(pc),a0
                bsr     print_line
                movea.l buffer(pc),a6
                bsr     get_length
                adda.l  d0,a6
                bsr     get_width
                lsr.l   #2,d0
                move.l  d0,d1
                suba.l  d0,a6
crc13:          move.b  (a6)+,d0
                bsr     hex_out2
                subq.l  #1,d1
                beq.s   crc12
                lea.l   comma_text(pc),a0
                bsr     print_line
                bra.s   crc13
crc12:          lea.l   cparen_text(pc),a0
                bsr     print_line
                lea.l   lf_text(pc),a0
                bsr     print_line
crc10:          bsr     lognlx
crc11:          movem.l (a7)+,d0-d7/a0-a6
                rts


uerror:         moveq.l   #0,d6
                moveq.l   #3,d7
                bra       user_error

error0:         moveq   #0,D0
                bra     error_handler
error1:         moveq   #1,D0
                bra     error_handler
error2:         moveq   #2,D0
                bra     error_handler
error3:         moveq   #3,D0
                bra     error_handler
error4:         moveq   #4,D0
                bra     error_handler
error5:         moveq   #5,D0
                bra     error_handler
error6:         moveq   #6,D0
                bra     error_handler
error7:         moveq   #7,D0
                bra     error_handler
error8:         moveq   #8,D0
                bra     error_handler
error9:         moveq   #9,D0
                bra     error_handler
error10:        moveq   #10,D0
                bra     error_handler
error11:        moveq   #11,D0
                bra     error_handler
error12:        moveq   #12,D0
                bra     error_handler
error13:        moveq   #13,D0
                bra     error_handler
error14:        moveq   #14,D0
                bra     error_handler
error15:        moveq   #15,D0
                bra     error_handler
error16:        moveq   #16,D0
                bra     error_handler
error17:        moveq   #17,D0
                bra     error_handler
error18:        moveq   #18,D0
                bra     error_handler
error19:        moveq   #19,D0
                bra     error_handler
error20:        moveq   #20,D0
                bra     error_handler
error21:        moveq   #21,D0
                bra     error_handler
error22:        moveq   #22,D0
                bra     error_handler
error23:        moveq   #23,D0
                bra     error_handler
error24:        moveq   #24,D0
                bra     error_handler
error25:        moveq   #25,D0
                bra.s   error_handler
error26:        moveq   #26,D0
                bra.s   error_handler
error27:        moveq   #27,D0
                bra.s   error_handler
error28:        moveq   #28,D0
                bra.s   error_handler
error29:        moveq   #29,D0
                bra.s   error_handler
error30:        moveq   #30,D0
                bra.s   error_handler
error31:        moveq   #31,D0
                bra.s   error_handler
error32:        moveq   #32,D0
                bra.s   error_handler
error33:        moveq   #33,D0
                bra.s   error_handler
error34:        moveq   #34,D0
                bra.s   error_handler
error35:        moveq   #35,D0
                bra.s   error_handler
error36:        moveq   #36,D0
                bra.s   error_handler
error37:        moveq   #37,D0
                bra.s   error_handler
error38:        moveq   #38,D0
                bra.s   error_handler
error39:        moveq   #39,D0
                bra.s   error_handler
error40:        moveq   #40,D0
                bra.s   error_handler
error41:        moveq   #41,D0
                bra.s   error_handler
error42:        moveq   #42,D0
                bra.s   error_handler
error43:        moveq   #43,D0
                bra.s   error_handler
error44:        moveq   #44,D0
                bra.s   error_handler
error45:        moveq   #45,D0
                bra.s   error_handler
error46:        moveq   #46,D0
                bra.s   error_handler
error47:        moveq   #47,D0
                bra.s   error_handler
error48:        moveq   #48,D0
                bra.s   error_handler
error49:        moveq   #49,D0
                bra.s   error_handler
error50:        moveq   #50,D0
                bra.s   error_handler
error51:        moveq   #51,D0
                bra.s   error_handler
error52:        moveq   #52,D0
                bra.s   error_handler
error53:        moveq   #53,D0
                bra.s   error_handler
error54:        moveq   #54,D0
                bra.s   error_handler
error55:        moveq   #55,D0
                bra.s   error_handler
error56:        moveq   #56,D0
                bra.s   error_handler
error57:        moveq   #57,D0


error_handler:  move.w  d0,d7
                add.w   #100,d7
                lea.l   lf_text(pc),a0
                bsr     print_line
                lsl.w   #2,d0
                lea     error_tab(pc),A0
                movea.l 0(A0,D0.w),A0
                move.b  (A0)+,D6

user_error:
                bsr     print_line
                move.b  d6,d0
                and.b   #1,D0
                bne.s   errorh2
                lea     line_text(pc),A0
                bsr     print_line
                move.l  line(pc),D0
                bsr     dez_out
                moveq.l #0,d0
                move.w  filenr(pc),d0
                beq.s   errorh1
                lea     batch_text(pc),A0
                bsr     print_line
                bsr     dez_out
                lea     batch2_text(pc),A0
                bsr     print_line
errorh1:        lea     point_text(pc),A0
                bsr     print_line
errorh2:        lea     lf_text(pc),A0
                bsr     print_line
                move.b  d6,d0
                and.b   #4,d0
                beq     exit1
                move.b  d6,d0
                and.b   #2,d0
                beq.s   errorh3
                tst.b   allyes
                bne.s   errorh3
                moveq.l #1,d7
                tst.b   quiet
                bne     quit
                lea     key2_text(pc),A0
                bsr     print_line
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                moveq.l #2,d7
                cmp.b   #$1B,D0
                beq     quit
errorh3:        rts

				.even
logmsg:
				movem.l d0-d2/a0-a2,-(a7)
				move.l 28(a7),-(a7)
				move.w #9,-(a7)
				trap   #1
				addq.l #6,a7
				movem.l (a7)+,d0-d2/a0-a2
				move.l  (a7),4(a7)
				addq.l #4,a7
				rts

                DATA

fname:          DC.B 'TOS.'
fname_ext:      DC.B 'IMG',0
logname:        DC.B 'TOS.LOG',0
bfname:         DC.B 'PATCH.FIL',0

init_text:      DC.B $1b,'v',10,$1b,'p TOS-Patch V2.9.8 (11.07.1999) ',$1b,'q',13,10,10
                DC.B $bd,'1990      ',$e4,'-soft, Markus Fritze',13,10
                DC.B $bd,'1992-1999 Markus Heiden',13,10,10,0
path_text:      DC.B 'Setze Pfad auf "',0
path_end_text:  DC.B '"',13,10,0
read_rom_text:  DC.B 'Lese das TOS aus dem ROM',13,10,0
read_1st_text:  DC.B 'Lese Hauptbatchdatei',13,10,0
read_2nd_text:  DC.B 'Lese Unterbatchdatei',13,10,0
batch_end_text: dc.b 'Ende der Unterbatchdatei.',13,10,0
space_text:     DC.B ' ',0
point_text:     DC.B '.',0
comma_text:     DC.B ',',0
colon_text:     DC.B ':',0
oparen_text:    DC.B '(',0
cparen_text:    DC.B ')',0
lf_text:        DC.B 13,10,0
ok_text:        DC.B '...OK',13,10,0
error_text:     DC.B '...Fehler',13,10,0
line_text:      DC.B ' in Zeile ',0
batch_text:     DC.B ' der ',0
batch2_text:    DC.B '. Unterbatchdatei',0
read_tos:       DC.B 'Lese TOS',13,10,0
write_tos:      DC.B 'Schreibe TOS',13,10,0
reloc_text:     DC.B 'Reloziere TOS nach ',0
cksum_text:     DC.B 'Bilde CRC-Pr',$81,'fsumme',0
logopen_txt:    DC.B $99,'ffne LOG-Datei',13,10,0
logclose_txt:   DC.B 'Schlie',$9e,'e LOG-Datei',13,10,0
error_txt:      DC.B 13,10,'Fehler: ',0
abbruch_text:   DC.B 13,10,10,'Abbruch durch <ESC>...',13,10,0
key_text:       DC.B 13,10,'Ende! Taste dr',$81,'cken.',0
key2_text:      DC.B '--> Bitte Taste dr',$81,'cken! ( <ESC>: Abbruch )',13,10,0
log_patch:      DC.B ' PATCH: ',0
log_reloc:      DC.B ' RELOC: ',0
log_crc:        DC.B ' CRC: ',0
log_hyphen:     DC.B ' - ',0


                EVEN

upriority:
                dc.b '(',0,0,0,0,0,0,0
                dc.b $7f,16
                dc.b '-',0,0,0,0,0,0,0
                dc.b $52,17
                dc.b '|',0,0,0,0,0,0,0
                dc.b $20,18
                dc.b '!NOT!',0,0,0
                dc.b $23,20
                dc.b '!N!',0,0,0,0,0
                dc.b $23,20
                dc.b '[',0,0,0,0,0,0,0
                dc.b $ff,0
                dc.w 0

priority:       DC.B ')',0,0,0,0,0,0,0
                DC.B $01,19
                DC.B '<>',0,0,0,0,0,0
                DC.B $10,3
                DC.B '!<>!',0,0,0,0
                DC.B $10,3
                DC.B '<=',0,0,0,0,0,0
                DC.B $10,2
                DC.B '!<=!',0,0,0,0
                DC.B $10,2
                DC.B '<',0,0,0,0,0,0,0
                DC.B $10,1
                DC.B '!<!',0,0,0,0,0
                DC.B $10,1
                DC.B '>=',0,0,0,0,0,0
                DC.B $10,5
                DC.B '!>=!',0,0,0,0
                DC.B $10,5
                DC.B '>',0,0,0,0,0,0,0
                DC.B $10,4
                DC.B '!>!',0,0,0,0,0
                DC.B $10,4
                DC.B '=',0,0,0,0,0,0,0
                DC.B $10,6
                DC.B '!=!',0,0,0,0,0
                DC.B $10,6
                DC.B '!XOR!',0,0,0
                DC.B $20,7
                DC.B '!X!',0,0,0,0,0
                DC.B $20,7
                DC.B '!OR!',0,0,0,0
                DC.B $21,8
                DC.B '!O!',0,0,0,0,0
                DC.B $21,8
                DC.B '!AND!',0,0,0
                DC.B $22,9
                DC.B '!A!',0,0,0,0,0
                DC.B $22,9
                DC.B '+',0,0,0,0,0,0,0
                DC.B $40,10
                DC.B '-',0,0,0,0,0,0,0
                DC.B $40,11
                DC.B '*',0,0,0,0,0,0,0
                DC.B $52,12
                DC.B '/',0,0,0,0,0,0,0
                DC.B $51,13
                DC.B '!MOD!',0,0,0
                DC.B $50,21
                DC.B '!M!',0,0,0,0,0
                DC.B $50,21
                DC.B '^',0,0,0,0,0,0,0
                DC.B $52,14
                DC.B '!IN!',0,0,0,0
                DC.B $30,$8f
				dc.w 0
				
optab:
                dc.w 32
                dc.w -1
                dc.w lower-opfuncs
                dc.w lower_equal-opfuncs
                dc.w unequal-opfuncs
                dc.w greater-opfuncs
                dc.w greater_equal-opfuncs
                dc.w equal-opfuncs
                dc.w do_xor-opfuncs
                dc.w do_or-opfuncs
                dc.w do_and-opfuncs
                dc.w do_add-opfuncs
                dc.w do_sub-opfuncs
                dc.w do_mult-opfuncs
                dc.w do_div-opfuncs
                dc.w do_pot-opfuncs
                dc.w do_in-opfuncs
                dc.w do_push-opfuncs
                dc.w do_uminus-opfuncs
                dc.w do_not-opfuncs
                dc.w do_error-opfuncs
                dc.w do_boolnot-opfuncs
                dc.w do_mod-opfuncs
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1
                dc.w -1

dez_tab:        DC.L 1000000000
                DC.L 100000000
                DC.L 10000000
                DC.L 1000000
                DC.L 100000
                DC.L 10000
                DC.L 1000
                DC.L 100
                DC.L 10
                DC.L 1
                DC.L 0

com_tab:
                DC.B 'IFDEF',0,0,0,0,0,0,0,0,0,0,0
                DC.W 'IF'
                dc.l cmdifdef
                DC.B 'IFNDEF',0,0,0,0,0,0,0,0,0,0
                DC.W 'IF'
                dc.l cmdifndef
                DC.B 'IF',0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 'IF'
                DC.L cmdif
                DC.B 'ELSE',0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 'IF'
                DC.L cmdelse
                DC.B 'ENDIF',0,0,0,0,0,0,0,0,0,0,0
                DC.W 'IF'
                DC.L cmdendif
                DC.B 'SWITCH',0,0,0,0,0,0,0,0,0,0
                DC.W 'SW'
                DC.L cmdswitch
                DC.B 'CASE',0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 'SW'
                DC.L cmdcase
                DC.B 'DEFAULT',0,0,0,0,0,0,0,0,0
                DC.W 'SW'
                DC.L cmddefault
                DC.B 'ENDSWITCH',0,0,0,0,0,0,0
                DC.W 'SW'
                DC.L cmdendswitch
                DC.B 'SELECT',0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmdselect
                DC.B 'ENDSELECT',0,0,0,0,0,0,0
                DC.W 0
                DC.L cmdendselect
                DC.B 'DEFINE',0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmddefine
                DC.B 'UNDEF',0,0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmdundef
                DC.B 'EVEN',0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmdeven
                DC.B 'FILL',0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmdfill
                DC.B 'ERROR',0,0,0,0,0,0,0,0,0,0,0
                DC.W 0
                DC.L cmderror
/* end of command table */
				DC.W 0

datevar:        dc.b 'DATE',0,0,0,0,0,0,0,0,0,0,0,0
dayvar:         dc.b 'DAY',0,0,0,0,0,0,0,0,0,0,0,0,0
monthvar:       dc.b 'MONTH',0,0,0,0,0,0,0,0,0,0,0
yearvar:        dc.b 'YEAR',0,0,0,0,0,0,0,0,0,0,0,0
crcvar:         dc.b 'CRC',0,0,0,0,0,0,0,0,0,0,0,0,0
basevar:        dc.b 'BASE',0,0,0,0,0,0,0,0,0,0,0,0
lengthvar:      dc.b 'LENGTH',0,0,0,0,0,0,0,0,0,0
relocvar:       dc.b 'RELOCADR',0,0,0,0,0,0,0,0
widthvar:       dc.b 'WIDTH',0,0,0,0,0,0,0,0,0,0,0

countries:
                dc.b 'USA',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'FRG',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'FRA',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'UK',0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'SPA',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'ITA',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'SWE',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'SWF',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'SWG',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'TUR',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'FIN',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'NOR',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'DEN',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'SAU',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'HOL',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'CZE',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 'HUN',0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.w 0

crctab:         DC.W $0000,$1021,$2042,$3063
                DC.W $4084,$50A5,$60C6,$70E7
                DC.W $8108,$9129,$A14A,$B16B
                DC.W $C18C,$D1AD,$E1CE,$F1EF
                DC.W $1231,$0210,$3273,$2252
                DC.W $52B5,$4294,$72F7,$62D6
                DC.W $9339,$8318,$B37B,$A35A
                DC.W $D3BD,$C39C,$F3FF,$E3DE
                DC.W $2462,$3443,$0420,$1401
                DC.W $64E6,$74C7,$44A4,$5485
                DC.W $A56A,$B54B,$8528,$9509
                DC.W $E5EE,$F5CF,$C5AC,$D58D
                DC.W $3653,$2672,$1611,$0630
                DC.W $76D7,$66F6,$5695,$46B4
                DC.W $B75B,$A77A,$9719,$8738
                DC.W $F7DF,$E7FE,$D79D,$C7BC
                DC.W $48C4,$58E5,$6886,$78A7
                DC.W $0840,$1861,$2802,$3823
                DC.W $C9CC,$D9ED,$E98E,$F9AF
                DC.W $8948,$9969,$A90A,$B92B
                DC.W $5AF5,$4AD4,$7AB7,$6A96
                DC.W $1A71,$0A50,$3A33,$2A12
                DC.W $DBFD,$CBDC,$FBBF,$EB9E
                DC.W $9B79,$8B58,$BB3B,$AB1A
                DC.W $6CA6,$7C87,$4CE4,$5CC5
                DC.W $2C22,$3C03,$0C60,$1C41
                DC.W $EDAE,$FD8F,$CDEC,$DDCD
                DC.W $AD2A,$BD0B,$8D68,$9D49
                DC.W $7E97,$6EB6,$5ED5,$4EF4
                DC.W $3E13,$2E32,$1E51,$0E70
                DC.W $FF9F,$EFBE,$DFDD,$CFFC
                DC.W $BF1B,$AF3A,$9F59,$8F78
                DC.W $9188,$81A9,$B1CA,$A1EB
                DC.W $D10C,$C12D,$F14E,$E16F
                DC.W $1080,$00A1,$30C2,$20E3
                DC.W $5004,$4025,$7046,$6067
                DC.W $83B9,$9398,$A3FB,$B3DA
                DC.W $C33D,$D31C,$E37F,$F35E
                DC.W $02B1,$1290,$22F3,$32D2
                DC.W $4235,$5214,$6277,$7256
                DC.W $B5EA,$A5CB,$95A8,$8589
                DC.W $F56E,$E54F,$D52C,$C50D
                DC.W $34E2,$24C3,$14A0,$0481
                DC.W $7466,$6447,$5424,$4405
                DC.W $A7DB,$B7FA,$8799,$97B8
                DC.W $E75F,$F77E,$C71D,$D73C
                DC.W $26D3,$36F2,$0691,$16B0
                DC.W $6657,$7676,$4615,$5634
                DC.W $D94C,$C96D,$F90E,$E92F
                DC.W $99C8,$89E9,$B98A,$A9AB
                DC.W $5844,$4865,$7806,$6827
                DC.W $18C0,$08E1,$3882,$28A3
                DC.W $CB7D,$DB5C,$EB3F,$FB1E
                DC.W $8BF9,$9BD8,$ABBB,$BB9A
                DC.W $4A75,$5A54,$6A37,$7A16
                DC.W $0AF1,$1AD0,$2AB3,$3A92
                DC.W $FD2E,$ED0F,$DD6C,$CD4D
                DC.W $BDAA,$AD8B,$9DE8,$8DC9
                DC.W $7C26,$6C07,$5C64,$4C45
                DC.W $3CA2,$2C83,$1CE0,$0CC1
                DC.W $EF1F,$FF3E,$CF5D,$DF7C
                DC.W $AF9B,$BFBA,$8FD9,$9FF8
                DC.W $6E17,$7E36,$4E55,$5E74
                DC.W $2E93,$3EB2,$0ED1,$1EF0

mach_tab:       dc.b 'PAK3',0,0,0,0,0,0,0,0,0,0,0,0
                dc.l 1
                dc.b 0
                even

wx_tab:         DC.L 1,w0_tab,w1_tab
w0_tab:         DC.L w8_ext,w16_ext,w32_ext,w64_ext
w1_tab:         DC.L w8_ext,w16_ext,w32_ext1,w64_ext
w8_ext:         DC.B 'IM',0,0,0
w16_ext:        DC.B 'HI',0,0,'LO',0,0,0
w32_ext:        DC.B 'EE',0,0,'OE',0,0,'EO',0,0,'OO',0,0,0
w32_ext1:       DC.B 'U10',0,'U11',0,'U12',0,'U13',0,0
w64_ext:        DC.B '0_',0,0,'1_',0,0,'2_',0,0,'3_',0,0,'4_',0,0,'5_',0,0,'6_',0,0,'7_',0,0,0
                EVEN

error_tab:      DC.L error0_t,error1_t,error2_t,error3_t
                DC.L error4_t,error5_t,error6_t,error7_t
                DC.L error8_t,error9_t,error10_t,error11_t
                DC.L error12_t,error13_t,error14_t,error15_t
                DC.L error16_t,error17_t,error18_t,error19_t
                DC.L error20_t,error21_t,error22_t,error23_t
                DC.L error24_t,error25_t,error26_t,error27_t
                DC.L error28_t,error29_t,error30_t,error31_t
                DC.L error32_t,error33_t,error34_t,error35_t
                DC.L error36_t,error37_t,error38_t,error39_t
                DC.L error40_t,error41_t,error42_t,error43_t
                DC.L error44_t,error45_t,error46_t,error47_t
                DC.L error48_t,error49_t,error50_t,error51_t
                DC.L error52_t,error53_t,error54_t,error55_t
                DC.L error56_t,error57_t

error0_t:       DC.B 0,'Unerwartetes Zeilen- oder Dateiende',0
error1_t:       DC.B 0,'Illegaler Patchoffset',0
error2_t:       DC.B 0,'Falsches Trennzeichen',0
error3_t:       DC.B 0,'TOS noch nicht geladen',0
error4_t:       DC.B 7,'>>> Das TOS ist k',$81,'rzer als angegeben!',0
error5_t:       DC.B 1,'Das TOS ist l',$84,'nger als der Puffer!',0
error6_t:       DC.B 1,'Speicher voll!',0
error7_t:       DC.B 0,$9a,'berlauf',0
error8_t:       DC.B 0,'Illegale Verkn',$81,'pfung',0
error9_t:       DC.B 0,'Division durch 0',0
error10_t:      DC.B 0,'Klammer auf fehlt',0
error11_t:      DC.B 0,'Wert fehlt',0
error12_t:      DC.B 1,'Zu viele TOS-Dateien zum Splitten!',0
error13_t:      DC.B 0,'Undefinierte Variable',0
error14_t:      DC.B 7,'>>> Falsche TOS-Version!',0
error15_t:      DC.B 0,'Falscher Befehl',0
error16_t:      DC.B 0,'Kein Bool',39,'scher Wert',0
error17_t:      DC.B 0,'ELSE ohne IF',0
error18_t:      DC.B 0,'ENDIF ohne IF',0
error19_t:      DC.B 1,'Nur 256 Unterbatchdateien m',$94,'glich!',0
error20_t:      DC.B 1,'IF ohne ENDIF',0
error21_t:      DC.B 1,'TOS-Breite passt nicht zur Anzahl der TOS-Dateien!',0
error22_t:      DC.B 0,'ERROR-Befehl',0
error23_t:      DC.B 1,'TOS-L',$84,'nge passt nicht zur TOS-Breite!',0
error24_t:      DC.B 0,'Zu viele Variablen',0
error25_t:      DC.B 1,'TOS-Daten (BASE/LENGTH/WIDTH) nicht angegeben!',0
error26_t:      DC.B 0,'Falsches Datumformat',0
error27_t:      DC.B 0,'Patches sind l',$84,'nger als das TOS',0
error28_t:      DC.B 0,'1. Adresse gr',$94,$9e,'er als 2. Adresse',0
error29_t:      DC.B 0,'Falsche Erweiterung der Variable #',0
error30_t:      DC.B 0,'Zu viele Argumente f',$81,'r _FILL',0
error31_t:      DC.B 1,'Illegale Breite',0
error32_t:      DC.B 1,'Interner Variablenspeicher zu klein!',0
error33_t:      DC.B 0,'Menge kann nicht 1. Argument sein',0
error34_t:      DC.B 0,'Kein ',39,':',39,' nach CASE-Wert',0
error35_t:      DC.B 0,'CASE ohne SWITCH',0
error36_t:      DC.B 0,'CASE nach DEFAULT',0
error37_t:      DC.B 0,'DEFAULT ohne SWITCH',0
error38_t:      DC.B 0,'ENDSWITCH ohne SWITCH',0
error39_t:      DC.B 0,'Doppeltes DEFAULT',0
error40_t:      DC.B 1,'SWITCH ohne ENDSWITCH',0
error41_t:      DC.B 0,'Kein ',39,':',39,' nach DEFAULT',0
error42_t:      DC.B 4,'Undokumentierte Verwendung von ',39,':',39,0
error43_t:      DC.B 7,'>>> Falsche TOS-Nationalit',$84,'t',0
error44_t:      DC.B 1,'Ung',$81,'ltiger Schalter!',13,10,10
                DC.B   'TOSPATCH [-qmK] patchfile',13,10
                DC.B   ' -q   Ausgaben unterdr',$81,'cken',13,10
                DC.B   ' -m   nicht Nachfragen',13,10
                DC.B   ' -K   akustisches Signal bei Beendigung',13,10,0
error45_t:      DC.B 0,'ENDSELECT ohne SELECT',0
error46_t:      DC.B 1,'SELECT ohne ENDSELECT',0
error47_t:      DC.B 0,'Verschachtelungsfehler (SELECT)',0
error48_t:      DC.B 0,'Zu gro',$9e,'er Selektor f',$81,'r Zuweisung',0
error49_t:      DC.B 0,'Menge nicht abgeschlossen',0
error50_t:      DC.B 0,'Keine Mengenoperation vor Menge',0
error51_t:      DC.B 0,'Mehrfachzuweisung ohne Selektor',0
error52_t:      DC.B 0,'Kein Argument f',$81,'r Selektor',0
error53_t:      DC.B 0,'Falsche Erweiterung (.B,.W,.L)',0
error54_t:      DC.B 0,'M',$81,'ll am Ende eines Ausdrucks',0
error55_t:      DC.B 0,'Unerlaubter Maschinentyp f',$81,'rs Abspeichern',0
error56_t:      DC.B 1,'Angegebener Maschinentyp unterst',$81,'tzt nur eine Bank!',0
error57_t:      DC.B 0,'Unbekannter Maschinentyp',0

                EVEN

                BSS

btchbuf:        DS.L 1          ;64kB Hauptbatchfilepuffer
filenr:         DS.W 1
buffer:         DS.L 1            ;Platz fuer das TOS
max_length:     DS.L 1
variable:       DS.L 1
line:           DS.L 1
output_format:  DS.L 1
machine_type:   DS.L 1
current_adr:    DS.L 1
                DS.L 1
cond_flag:      DS.W 1
nest_count:     DS.L 1
if_count:       DS.L 1
sw_count:       DS.L 1
sel_count:      DS.L 1
sel_var:        DS.L 1
loghdl:         ds.w 1
rangelo:        ds.l 1
rangehi:        ds.l 1
lastadr:        ds.l 1
quiet:          ds.b 1
allyes:         ds.b 1
soundflg:       ds.b 1
logflg:         ds.b 1
adrflg:         ds.b 1
dolog:          ds.b 1
neednl:         ds.b 1
                even
number_puffer:  DS.B 32
filename:       DS.B 256
ptchtab:        DS.L 1024       ;1024 Reloc-Korrekturen
ptchtab2:       DS.L 256*2	    ; 256 Feld-Reloc-Korrekturen
forced_table:   DS.L 256        ; 256 Forcierte Reloc-Korrekturen
varvalue:       DS.L 1024       ;1024 Variablen
varname:        DS.B 1024*16

                BSS
stack:          DS.B stack_size ;Stack

__ebss: ds.b 0
