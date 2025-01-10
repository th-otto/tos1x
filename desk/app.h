typedef struct app
{
	/*  0 */ struct app *a_next;    /* app pointer */
	/*  4 */ int16_t a_apptype;
	/*  6 */ int16_t a_type; 		/* file type */
	/*  8 */ int16_t a_obid;		/* object # in desktop tree */
	/* 10 */ char *a_pappl;         /* filename.ext of ap */
	/* 14 */ char *a_pdata; 		/* wildcards of data file */
	/* 18 */ int16_t a_aicon; 		/* application icon # */
	/* 20 */ int16_t a_dicon;       /* data icon # */
	/* 22 */ int16_t a_char;
	/* 24 */ int16_t a_x;
	/* 26 */ int16_t a_y;
	/* 28 */
} APP;

#define AT_ISFILE   0 /* file                 */
#define AT_ISFOLD   1 /* folder               */
#define AT_ISDISK   2 /* disk or diskette     */
#define AT_ISTRSH   3 /* Trash                */
#define AT_ISCART   4 /* cartridge            */

#define AF_ISCRYS 0x0001			/* is crystal appl.	*/
#define AF_ISGRAF 0x0002			/* is graphic appl.	*/
#define AF_ISDESK 0x0004			/* is placed on desk */
#define AF_ISPARM 0x0008			/* is in need of input */
#define AF_ISFMEM 0x0010			/* is in need of full memory */

APP *app_alloc PROTO((BOOLEAN atend));
