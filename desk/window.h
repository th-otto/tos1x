/*	WINDOW.H		3/15/89 - 3/30/89	Derek Mui	*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/

#define	SUP		0
#define SDOWN	1
#define SLEFT	2
#define	SRIGHT	3


#define INFOLEN		62

#define	SCREEN	  0	/* related to background */

#define ALLITEMS (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)

typedef struct dir
{
	int16_t	 d_att;		/* attribute */
	uint16_t d_time;	/* time */
	uint16_t d_date;	/* date */
	int32_t	 d_size;	/* size */
	char	 d_name[14]; /* name */
	int16_t	 d_state;	/* selected */
	int16_t	 d_order;	/* file's order */
} DIR;

typedef	struct dta
{
	char	reserved[20];	/* reserved area */
	DIR	dirfile;
} DTA;

typedef	struct deskwin
{
	/*   0 */ GRECT	w_sizes;			/* window current size and pos */
	/*   8 */ int16_t w_coli;			/* the horizontal column index */
	/*  10 */ int16_t w_rowi;			/* the vertical row index */
	/*  12 */ int16_t w_icon;			/* disk icon that owns this window */
	/*  14 */ char w_path[82];			/* window path name */
#define w_buf w_path /* tmp hack until desktop source has been completed */
	/*  96 */ int16_t w_id;				/* window handle */
#define w_srtitem w_id /* tmp hack until desktop source has been completed */
	/*  98 */ char w_info[14];			/* info line */
	/* 110 */ int16_t w_items;			/* max number of file items */
	/* 112 */ int16_t w_maxicons;		/* max # of icons allocated in window */
	/* 118 */ TEDINFO *w_ted;
	/* 122 */ ICONBLK *w_iblk;			/* starting address of iconblk */
	/* 126 */ char *w_text;				/* starting address of text */
#define w_memory w_text /* tmp hack until desktop source has been completed */
#define w_obj w_text /* tmp hack until desktop source has been completed */
	/* 132 */ int16_t w_hvicons;		/* number of invisible icon per row */
	/* 136 */ int16_t w_vvicons;		/* number of invisible icon per col */
	/* 138 */ int16_t w_xcol;			/* number of visible column of icon */
	/* 140 */ int16_t w_xrow;			/* number of visible row of icon */
	/* 142 */ 
} DESKWIN;	


typedef struct myblk
{
	GRECT	*mygrect;
	char	*myptr;
} MYBLK;
