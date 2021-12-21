/* List of all known TOS-ERRORs */

#define E_OK       0 /* Ok = no error */
#define E_RROR    -1 /* Error: unknown error */
#define E_DRVNR   -2 /* Drive not ready: device timeout */
#define E_UNCMD   -3 /* Unknown command: device access */
#define E_CRC     -4 /* CRC error: sector read */
#define E_BADRQ   -5 /* Bad request: error at device request */
#define E_SEEK    -6 /* Seek error: wrong tracknumber */
#define E_MEDIA   -7 /* Unknown media: bootsector defect or not there */
#define E_SECNF   -8 /* Sector not found: wrong sectornumber */
#define E_PAPER   -9 /* Out of paper: printer not ready */
#define E_WRITF  -10 /* Write fault */
#define E_READF  -11 /* Read fault */
#define E_GENRL  -12 /* General error: reserved for future catastrophes */
#define E_WRPRO  -13 /* Write on write-protected media */
#define E_CHNG   -14 /* Media change detected */
#define E_UNDEV  -15 /* Unknown device */
#define E_BADSF  -16 /* Bad sectors on format */
#define E_OTHER  -17 /* Insert other disk (request) */
#define E_INSERT -18 /* Insert disk: Metados error */
#define E_DVNRSP -19 /* Device not responding: Metados error */

#define E_INVFN  -32 /* Invalid function number: GEMDOS */
#define E_NOSYS  E_INVFN
#define E_FILNF  -33 /* File not found */
#define E_PTHNF  -34 /* Path not found */
#define E_NHNDL  -35 /* Handle pool exhausted */
#define E_ACCDN  -36 /* Access denied */
#define E_IHNDL  -37 /* Invalid handle */
#define E_NSMEM  -39 /* Insufficient memory */
#define E_IMBA   -40 /* Invalid memory block address */
#define E_DRIVE  -46 /* Invalid drive specification */
#define E_NSAME  -48 /* Not the same drive */
#define E_NMFIL  -49 /* No more files: Fsfirst/Fsnext */
#define E_LOCKED -58 /* Record is locked */
#define E_NSLOCK -59 /* Matching lock not found */
#define E_BADARG -64 /* Range error/Bad argument */
#define E_INTRN  -65 /* GEMDOS internal error */
#define E_PLFMT  -66 /* Invalid executable file format */
#define E_GSBF   -67 /* Memory block groth failure */
#define E_BREAK  -68 /* Break by CTRL-C: KAOS/MagiC */
#define E_XCPT   -69 /* Break by Exception: KAOS/MagiC */

#define E_EXIST  -85 /* file exist, try later */
#define E_NAMETOOLONG -86 /* name too long */
#define E_NOTTY	 -87 /* not a tty */
#define E_RANGE	 -88 /* range error */
#define E_DOM	 -89 /* domain error */
#define E_IO     -90 /* I/O error */
#define E_NOSPC  -91 /* disk full */

#define E_MOUNT  -200 /* used by MiNT-kernel */
