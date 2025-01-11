/*	WINDOW.H		3/15/89 - 3/30/89	Derek Mui	*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/

#define	SUP		0
#define SDOWN	1
#define SLEFT	2
#define	SRIGHT	3


#define INFOLEN		62

#define	SCREEN	  0	/* related to background */

#define ALLITEMS (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)

#define LEN_ZFNAME 13
#define LEN_ZFPATH (PATHLEN - 6) /* BUG: too short */
#define LEN_ZEXT 4

typedef struct dir
{
	int8_t	 d_junk;
	int8_t	 d_att;		/* attribute */
	uint16_t d_time;	/* time */
	uint16_t d_date;	/* date */
	int32_t	 d_size;	/* size */
	char	 d_name[LEN_ZFNAME + 1]; /* name */
} DIR;

typedef	struct dta
{
	char	reserved[20];	/* reserved area */
	DIR	dirfile;
} DTA;

typedef struct window_save
{
	GRECT	gr_save;
	int16_t	hsl_save;
	int16_t	vsl_save;
	int16_t	obid_save;
	char	pth_save[LEN_ZFPATH];
	/* 136 */
} WSAVE;


typedef struct context_save
{
	int16_t	sitem_save;		/* saved sort item */
	int16_t	vitem_save;		/* view item */
	int16_t	ccopy_save;		/* copy ? */
	int16_t	cdele_save;		/* delete ? */
#if TOSVERSION >= 0x104
	BOOLEAN cbit_save;		/* bitblt */
#endif
	BOOLEAN covwr_save;		/* write ? */
	int16_t pref_save;		/* screen pref */
	WSAVE win_save[NUM_WNODES];	/* window process structure */
} CSAVE;

#define DROOT 1 /* desktop pseudo root */

typedef	struct deskwin DESKWIN;
struct deskwin {
	DESKWIN *w_next;
	int16_t	w_flags;	/* window creation flags */
	int16_t	w_id;		/* window handle id #	*/
	int16_t	w_obid;		/* desktop object id	*/
	int16_t	w_root;		/* pseudo root ob. in gl_screen for this windows objects */
	int16_t	w_cvcol;	/* current virt. col	*/
	int16_t	w_cvrow;	/* current virt. row	*/
	int16_t	w_pncol;	/* physical # of cols	*/
	int16_t	w_pnrow;	/* physical # of rows	*/
	int16_t	w_vncol;	/* virtual # of cols 	*/
	int16_t	w_vnrow;	/* virtual # of rows	*/
	PNODE	*w_path;
	char	w_name[LEN_ZFPATH - 1];
	char	w_info[81];
#if TOSVERSION >= 0x104
	GRECT   w_curr;
#endif
	/* 230 */
};
