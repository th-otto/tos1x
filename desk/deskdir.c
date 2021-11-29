/*      DESKDIR.C               7/31/89                 Jian Ye         */
/*      Fix the count operation 8/1/89                  D.Mui           */
/*      Change and fix another bug in the count()       8/2/89  J.Ye    */
/*      8/7/89                                                  J.Ye    */
/*      Add the check point in the countrec(). When the Depth of path   */
/*      reach the 9 level, the system stack will over flow              */
/*      Fix at rmfile   8/8/89                  D.Mui                   */
/*      Fix count       8/8/89                                          */
/*      Fix the delete() for root dir           8/9/89                  */
/*      Fix at chkfile, close file after opening it     8/15/89 D.Mui   */
/*      Fix tow bugs in the chkfile() and chkdir() so that they check   */
/*              the second name conflict.               8/17/89 J.Ye    */
/*      Optimize, simplify, compact this function.      8/27/89 J.Ye    */
/*      Modify edname                                   9/6/89  D.Mui   */
/*      Take out wdesk,hdesk    9/7/89                  D.Mui           */
/*      simplify the single flopy disk copy             9/11/89 J.Ye    */
/*      Fix at doact to return error code               9/19/89 D.Mui   */
/*      Add path checking                       9/25/89         D.Mui   */
/*      Clean up rmstarb() and backdir()        9/26/89         D.Mui   */
/*      Modify chkdf(), edname()                9/28/89         D.Mui   */
/*      Check depth of directory at doact       12/19/89        D.Mui   */
/*      Fixed at wrfile for move file in the same place 2/8/90  D.Mui   */
/*      Fix bugs at doright and dofiles         3/21/90         D.Mui   */
/*      Fix at dofiles when there is an abort and make sure to do       */
/*      redraw  4/18/91                                 D.Mui           */
/*      change the move operation at wrfile()   4/19/91 D.Mui           */
/*      Change at chkdf() to do file checking correctly 4/19/91 D.Mui   */
/*      Take out specific error checking code   4/19/91 D.Mui           */
/*      Fix at wrfile for move operation        7/8/91  D.Mui           */
/*      Fix at chkdf for dir rename operation   7/9/91  D.Mui           */
/*      Close file before deleting it when the disk is full 8/31/92 Mui */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"
#include "toserrno.h"


/* "DMA" buffer structure for Fsfirst() and Fsnext().	*/

typedef struct
{
	char d_glob[12];					/* GEMDOS wildcard string from Fsfirst */
	char d_mask;						/* Attribute mask from Fsfirst */
	char d_dirent[4];					/* Offset into directory, MSB first */
	char d_dirid[4];					/* Pointer to directory structure in GEM mem */
	char d_fattr;						/* File attributes */
	long d_tandd;						/* Time and date words */
	long d_fsize;						/* File size */
	char d_fname[14];					/* File name */
} DMABUFFER;

#define OK	1
#define CHECK	-9
#define DTOD	3
#define FILE_LEN 12
#define HOME	'.'

STATIC OBJECT *cpbox;					/* cp or rm or mv dialog box */
STATIC int srclen, dstlen;				/* the size of source and target buffer */
STATIC long numfiles, numdirs;			/* the number of files and dirs show in the dialog box */
STATIC long tolsize;					/* the total size of all files in the path */
STATIC int srcbuf, dstbuf;				/* the size of source and target buffer be define */
int f_level;							/* the current depth of the directory path */
STATIC int f_abort;						/* the flag for the abort button selected */
STATIC int opcode;						/* the operation codes for cp, mv and rm */
int d_display;							/* display copy box or not      */
STATIC int rename;

/* the source and target string pointer */
STATIC char *fixsrc;
STATIC char *fixdst;

STATIC char filestr[NAMELEN];			/* the buffer for the file */

int f_rename;


BOOLEAN doact PROTO((NOTHING));
BOOLEAN count PROTO((const char *s));
BOOLEAN countrec PROTO((NOTHING));
BOOLEAN wrfile PROTO((char *fstr));
int getinfo PROTO((const char *s, const char *d));
int16_t created PROTO((char *dir));
BOOLEAN deleted PROTO((NOTHING));
BOOLEAN mystrcpy PROTO((const char *s0, char *s1));
VOID chkbuf PROTO((int len, int bufsiz, char **src));
VOID addfile PROTO((char *s, const char *obj));
VOID rmstarb PROTO((char *src));
VOID backdir PROTO((char *str));
int chkdf PROTO((char *str, int flag));
int edname PROTO((char *src, int kind, int change));
VOID pack PROTO((char *src, int flag));
VOID getlastpath PROTO((char *buf, char *src));
VOID updatnum PROTO((int obj, long num));
VOID updatname PROTO((int obj, char *str));
VOID updatbox PROTO((char *str));






/*
 * Main entrance of the file operation function
 * s can be from different partitions
 *there is only one destination
 */
/* 306de: 00e28572 */
BOOLEAN dofiles(P(const char *) s, P(const char *) d, P(int16_t) code, P(int32_t *)ndirs, P(int32_t *)nfiles, P(int32_t *)tsize, P(int16_t) type, P(BOOLEAN) multiple)
PP(const char *s;)
PP(const char *d;)
PP(int16_t code;)
PP(int32_t *ndirs;)
PP(int32_t *nfiles;)
PP(int32_t *tsize;)
PP(int16_t type;)
PP(BOOLEAN multiple;)
{
	BOOLEAN ret;
	int16_t trash;
	char buffer[2];

	UNUSED(trash);
	if (*d == CHAR_FOR_CARTRIDGE)
		return FALSE;

	desk_wait(TRUE);
	/* get the dialog box string */
	cpbox = get_tree(CPBOX);

	f_level = 0;						/* the current depth of the directory path */
	f_abort = 0;						/* No abortion  */
	rename = 0;
	buffer[1] = 0;

	ret = FALSE;

	if ((opcode = code) == OP_COUNT)
	{
		numfiles = 0x0L;				/* the number of files show in the dialog box */
		numdirs = 0x0L;					/* the number of directories */
		tolsize = 0x0L;					/* the total size of all files in the path */
	} else
	{
		numdirs = *ndirs;
		numfiles = *nfiles;
		tolsize = *tsize;
	}

	do
	{
		if (*s == CHAR_FOR_CARTRIDGE)	/* skip cartridge   */
			goto cc_4;

		buffer[0] = *s;

		/* do the counting only */
		if (code == OP_COUNT)
		{
			if (!(ret = count(s)))
				goto clnup;				/* error    */
		} else							/* do the actual operation  */
		{
			if (!ch_undo())				/* check for undo key       */
			{
				f_abort = 1;
				goto clnup;
			}
			/* delete the whole disk    */
			if (type == DISK && code == OP_DELETE)
			{
			}

			if (code == OP_COPY || code == OP_MOVE)
			{
				if (type == FA_DIREC || type == DISK)
				{
					if (!chk_par(s, d))	/* illegal  */
					{
						goto clnup;	/* abort    */
					}
				}
			}

			if (!(ret = getinfo(s, d)))
				goto clnup;

			if (ret == SKIP)
				continue;

			if (!(ret = doright(ret)))
				goto clnup;

			if (ret == SKIP)
				continue;
		}
	cc_3:
		if (code != OP_COUNT)
			x_del();
		/* deselect object  */
		if (code == OP_DELETE || code == OP_MOVE)
			dr[*s - 'A'] = 1;

		if (code == OP_COPY || code == OP_MOVE)
			dr[*d - 'A'] = 1;

	cc_4:
		if (!multiple)				/* do only one device   */
			break;

	} while (x_next(&s, &type));

	*ndirs = numdirs;
	*nfiles = numfiles;
	*tsize = tolsize;

clnup:
	/* deselect object  */
	if (code == OP_DELETE || code == OP_MOVE)
	{
		if (*s != CHAR_FOR_CARTRIDGE)
			dr[*s - 'A'] = 1;
	}

	if (code == OP_COPY || code == OP_MOVE)
		dr[*d - 'A'] = 1; /* assumes we can't get here when trying to copy to cartridge */

	desk_wait(FALSE);

	if (f_abort)
		return TRUE;

	return ret;
}


/*
 * do the rm, cp and mv file job
 */
/* 306de: 00e2883c */
BOOLEAN doright(P(int) flag)
PP(int flag;)
{
	register int ret;
	register BOOLEAN retmsg;
	char *temp;
	char buf[NAMELEN];

	retmsg = TRUE;
#if !BINEXACT
	temp = 0;
#endif
	if (opcode == OP_DELETE)
	{
		temp = fixdst;
		fixdst = fixsrc;
	}

	if (flag == DTOD)
	{
		if (!(retmsg = doact()))
			goto endright;

		if (opcode != OP_COPY)
			retmsg = deleted();			/* rm the first folder */
	} else								/* file to file */
	{
		getlastpath(filestr, fixdst);
		backdir(fixdst);
		getlastpath(buf, fixdst);
		strcat(fixdst, filestr);
		updatname(CPFILE, filestr);
		updatname(CPDIR, buf);
		if (opcode != OP_DELETE)
			if (!(retmsg = wrfile(filestr)) || rename || retmsg == SKIP)
				goto endright;

		if (opcode != OP_COPY)
		{
		redel:
			if ((ret = Fdelete(fixsrc)))
			{							/* seek error or drive not ready */
#if 0
				if (ret == E_SEEK || ret == E_DRVNR)
				{
					retmsg = FALSE;
					goto endright;
				}
#endif
				if ((ret = fill_string(fixsrc, STNOMEM)) == 2)
					goto redel;

				if (ret == 1)			/* skip */
					retmsg = SKIP;
				else
				{
					f_abort = 1;
					retmsg = FALSE;
				}

				goto endright;			/* error    */
			} else
			{
				if (opcode == OP_DELETE)
					updatnum(NUMFILE, --numfiles);
			}
		}

		if (retmsg == TRUE)
		{
#if 0
			if (opcode == OP_MOVE)
				upfdesk(fixsrc, fixdst);
#endif
			if (opcode == OP_DELETE)
				upfdesk(fixsrc, (char *) 0);

		}
	}

endright:
	Mfree(fixsrc);

	if (opcode == OP_DELETE)
		Mfree(temp);
	else
		Mfree(fixdst);

	return retmsg;
}


/*
 * recursively cp or mv or rm files or directoies from a given path
 */
/* 306de: 00e289ee */
BOOLEAN doact(NOTHING)
{
	DMABUFFER *saved;
	DMABUFFER *dumb;
	register int ret;
	register BOOLEAN retmsg;
	int error;

	if (f_level >= (COPYMAXDEPTH + 1))
	{
	act_1:
		return FALSE;
	}

	if (!(dumb = (DMABUFFER *) Malloc((int32_t) sizeof(DMABUFFER))))
		goto act_1;

	f_level++;
	retmsg = TRUE;
	saved = (DMABUFFER *) Fgetdta();
	Fsetdta(dumb);
	strcat(fixsrc, getall);

	if (!(error = Fsfirst(fixsrc, FA_ARCH|FA_DIREC|FA_RDONLY|FA_HIDDEN|FA_SYSTEM)))
	{
		do
		{
			if (!ch_undo())				/* user want to abort   */
			{
				f_abort = 1;
				retmsg = FALSE;
				goto mvend;
			}

			if (dumb->d_fname[0] != HOME)
			{
				if (FA_DIREC & dumb->d_fattr)
				{
					chkbuf(srclen, srcbuf, &fixsrc);	/* check buf size */
					addfile(fixsrc, dumb->d_fname);	/* add a dir into the path */
					strcat(fixsrc, bckslsh);
					if (opcode != OP_DELETE)
					{
						chkbuf(dstlen, dstbuf, &fixdst);	/* check buf size */
						strcat(fixdst, dumb->d_fname);
					} else
						goto dorec;

					updatbox(dumb->d_fname);
				rechkd1:				/* update check the dir existing or not */
					switch (chkdf(dumb->d_fname, CPDIR))
					{
					case QUIT:
						f_abort = 1;
						retmsg = FALSE;
						goto mvend;

					case SKIP:
						backdir(fixsrc);
						backdir(fixdst);
						updatnum(NUMDIR, --numdirs);
						srclen -= FILE_LEN;	/* subtract the add lenth */
						dstlen -= FILE_LEN;	/* subtract the add lenth */
						retmsg = TRUE;
						continue;

					case FALSE:
						goto mvend;

					case CHECK:
						goto rechkd1;

					case OK:
					recrtd:
						if (Dcreate(fixdst))
						{
							if (thedesk->write_save)
								goto kk_1;

							switch (fill_string(fixdst, STNOMEM))
							{
							case 1:	/* skip */
								backdir(fixsrc);
								backdir(fixdst);
								updatnum(NUMDIR, --numdirs);
								srclen -= FILE_LEN;	/* subtract the add lenth */
								dstlen -= FILE_LEN;	/* subtract the add lenth */
								continue;

							case 2:	/* retry */
								goto recrtd;

							default:	/* quit */
								f_abort = 1;
								retmsg = FALSE;
								goto mvend;

							}			/* switch */
						}
						/* if recrtd */
						break;
					}
				kk_1:
					updatnum(NUMDIR, --numdirs);
					strcat(fixdst, bckslsh);
				dorec:
					if (!doact())		/* do the recursion */
					{
						retmsg = FALSE;
						goto mvend;
					}

					if (opcode == OP_COPY)
						goto clndir;

					rmstarb(fixsrc);	/* after call, -> c:\d1\ */

					if (opcode == OP_DELETE)
					{
						getlastpath(filestr, fixsrc);
						updatbox(filestr);
					}
				remvd:
					if (Ddelete(fixsrc))
					{					/* delete a dir */
						if ((ret = fill_string(fixsrc, STNOMEM)) == 2)
							goto remvd;	/* retry */

						else if (ret == 3)
						{				/* abort */
							f_abort = 1;
							retmsg = FALSE;
							goto mvend;
						}
					} else				/* No error */
						upfdesk(fixsrc, (char *) 0);

				clndir:
					backdir(fixsrc);	/* back one dir */
					srclen -= FILE_LEN;	/* subtract the add lenth */
					if (opcode == OP_DELETE)
						updatnum(NUMDIR, --numdirs);
					else
					{
						backdir(fixdst);	/* back one dir */
						dstlen -= FILE_LEN;	/* subtract the add lenth */
					}
				} else
				{
					getlastpath(filestr, fixdst);
					updatname(CPDIR, filestr);	/* update the dir */
					updatname(CPFILE, dumb->d_fname);	/* update the file */
					chkbuf(srclen, srcbuf, &fixsrc);	/* check buf size */
					addfile(fixsrc, dumb->d_fname);
					if (opcode != OP_DELETE)
					{
						chkbuf(dstlen, dstbuf, &fixdst);	/* check buf size */
						addfile(fixdst, dumb->d_fname);
						rename = 0;
						if (!(retmsg = wrfile(dumb->d_fname)))
							goto mvend;

						if (rename || retmsg == SKIP)
							goto clnfile;
					}

					if (opcode == OP_COPY)
						goto clnfile;
				remvf:
					if ((ret = Fdelete(fixsrc)))	/* rm the file from source */
					{					/* seek error or drive not ready */
#if 0
						if (ret == E_SEEK || ret == E_DRVNR)
						{
							retmsg = FALSE;
							goto mvend;
						}
#endif
						/* retry */
						if ((ret = fill_string(fixsrc, STNOMEM)) == 2)
							goto remvf;
						else if (ret == 3)
						{				/* abort */
							f_abort = 1;
							retmsg = FALSE;
							goto mvend;
						}
					} else
						upfdesk(fixsrc, (char *) 0);
				clnfile:
					backdir(fixsrc);	/* back one dir */
					srclen -= FILE_LEN;	/* subtract the add lenth */
					if (opcode == OP_DELETE)
						updatnum(NUMFILE, --numfiles);
					else
					{
						backdir(fixdst);	/* back one dir */
						dstlen -= FILE_LEN;	/* subtract the add lenth */
					}
				}
			}
		} while (!Fsnext());
	} else
	{
		if (error != E_FILNF)			/* if not file not found */
			retmsg = FALSE;				/* then return error     */
	}

  mvend:
	Fsetdta(saved);
	f_level--;
	Mfree(dumb);
	return retmsg;
}


/*
 * set the right drive and call the recursive routine to do the counting
 */
/* 306de: 00e28f22 */
BOOLEAN count(P(const char *) s)
PP(const char *s;)
{
	const char *tmp;

	tmp = s;
	while (*tmp++)
		;

	if (*(tmp - 2) == '*')				/* a dir */
	{
		if (set_dir(s))					/* set the path     */
			return countrec();			/* recursive count  */
		else
			return FALSE;
	}
	numfiles++;
	return TRUE;
}


/*
 * count the file and directory recursivly
 */
/* 306de: 00e28f6c */
BOOLEAN countrec(NOTHING)
{
	DMABUFFER *saved;
	DMABUFFER *dumb;

	register int retmsg;

	dumb = (DMABUFFER *)Malloc((int32_t) sizeof(DMABUFFER));
	if (!dumb)
	{
		do1_alert(STNOMEM);
		return FALSE;
	}

	retmsg = TRUE;
	saved = (DMABUFFER *) Fgetdta();	/* save the current dta */
	Fsetdta(dumb);

	if (!Fsfirst(curall, FA_ARCH|FA_DIREC|FA_RDONLY|FA_HIDDEN|FA_SYSTEM))
	{
		do
		{
			if (dumb->d_fname[0] != HOME)
			{
				if (FA_DIREC & dumb->d_fattr)
				{						/* setpath to one more down */
					if (Dsetpath(dumb->d_fname))
					{
						retmsg = FALSE;
						goto endrec;
					}

					numdirs++;

					if (++f_level > COPYMAXDEPTH)
					{
						do1_alert(STNOMEM);
						retmsg = FALSE;
						goto endrec;
					}

					if (!countrec())	/* to the recursion setpath to one back */
					{
						retmsg = FALSE;
						goto endrec;
					}
					f_level--;
					if (Dsetpath(baklvl))
					{
						retmsg = FALSE;
						goto endrec;
					}
				} else
				{
					numfiles++;			/* add up the file count and size   */
					tolsize += dumb->d_fsize;
				}
			}
		} while (!Fsnext());
	}

  endrec:
	Fsetdta(saved);						/* reset the dta    */
	Mfree(dumb);
	return retmsg;
}


/* 
 * Copy the file from the s to d
 */
/* This was apparently ported from a BASIC program... */
/* 306de: 00e290bc */
BOOLEAN wrfile(P(char *) fstr)
PP(char *fstr;)
{
	register int ret, retmsg;
	int inhand, outhand;
	int time[2];
	DMABUFFER *mydta;
	char *buffer;
	DMABUFFER *saved;
	long copysiz, bufsiz, wrsiz, tmpsiz;
	int crted, sttime;
	char buf[2];

	crted = 0;
	sttime = 1;
	retmsg = TRUE;
	rename = 0;
#if !BINEXACT
	outhand = 0;
#endif
  open:								/* open the source file */
	if ((inhand = Fopen(fixsrc, 0)) < 0)
	{									/* seek error or drive not ready */
#if 0
		if (inhand == E_SEEK || inhand == E_DRVNR)
			return FALSE;
#endif
		/* skip */
		if ((ret = fill_string(fixsrc, STNOMEM)) == 1)
		{
			updatnum(NUMFILE, --numfiles);
			return SKIP;
		} else if (ret == 2)			/* retry */
			goto open;
		else							/* abort */
			goto ww_3;
	}

	if (!ch_undo())						/* user want to stop */
	{
		Fclose(inhand);
	ww_3:
		f_abort = 1;
		return FALSE;
	}

	saved = (DMABUFFER *) Fgetdta();
	Fsetdta(mydta = (DMABUFFER *) Malloc((long) sizeof(DMABUFFER)));

	if (Fsfirst(fixsrc, FA_ARCH|FA_DIREC|FA_RDONLY|FA_HIDDEN|FA_SYSTEM))
	{
		retmsg = SKIP;
		if (do1_alert(STNOMEM) == 2)	/* abort */
		{
			f_abort = 1;
			retmsg = FALSE;
		}
		goto y2;
	}

	bufsiz = (long) Malloc(-1L);
	buffer = (char *) Malloc(bufsiz);
	copysiz = mydta->d_fsize;
	Fdatime(&time, inhand, 0);			/* read the time and date */


  rechkd:
	switch (chkdf(fstr, CPFILE))
	{
	case CHECK:
		goto rechkd;

	case SKIP:
		retmsg = SKIP;
		goto y1;

	case QUIT:
		f_abort = 1;
		retmsg = FALSE;
		goto y1;

	case FALSE:
		retmsg = FALSE;
		goto y1;
	}


	/* if it is move operation, then try rename first   */

	if (opcode == OP_MOVE)
	{									/* if same name and path, don't do it */
		if (streq(fixsrc, fixdst))
			goto y22;

		Fclose(inhand);

		if (Frename(0, fixsrc, fixdst) >= 0)
		{
			inhand = Fopen(fixdst, 0);
			if (!p_timedate)			/* get the new time and date */
			{
				time[0] = Tgettime();
				time[1] = Tgetdate();
				Fdatime(&time, inhand, 1);
			}
		y22:
			rename = 1;
			goto y1;
		} else
		{
			inhand = Fopen(fixsrc, 0);
		}
	}


	while (copysiz >= 0)				/* let it passes through for zero file */
	{
		tmpsiz = copysiz > bufsiz ? bufsiz : copysiz;
		if (Fread(inhand, tmpsiz, buffer) < 0)
		{
			retmsg = SKIP;
			if (crted)
			{
#if !BINEXACT
				/* BUG: missing  */
				Fclose(outhand);
#endif
				Fdelete(fixdst);
			}
			
			if (do1_alert(STNOMEM) == 2)
			{							/* abort */
				f_abort = 1;
				retmsg = FALSE;
			}
			goto y1;					/* skip */
		}


	create:
		if (sttime)
		{
			sttime = 0;

			if ((outhand = Fcreate(fixdst, mydta->d_fattr & 7)) < 0)
			{
				if ((ret = fill_string(fixdst, STNOMEM)) == 2)
					goto create;

				else if (ret == 3)		/* abort */
				{
					f_abort = 1;
					retmsg = FALSE;
				} else
				{
					retmsg = SKIP;
				}
				
				goto y1;
			}

			crted = 1;
		}

		if ((wrsiz = Fwrite(outhand, tmpsiz, buffer)) < 0)
		{
			retmsg = SKIP;
#if (TOSVERSION >= 0x400) | !BINEXACT
			/* BUG: in 3.x: Fdelete() on open file */
			Fclose(outhand);
#endif
			Fdelete(fixdst);

			if (do1_alert(STNOMEM) == 2)
			{							/* abort */
				f_abort = 1;
				retmsg = FALSE;
			}

#if (TOSVERSION < 0x400) & BINEXACT
			goto y0;
#else
			goto y1;
#endif
		}
		/* check if there are sufficent memory */
		if (wrsiz != tmpsiz)
		{								/* not sufficent memory ?? */
			f_abort = 1;
			retmsg = FALSE;
#if (TOSVERSION >= 0x400) | !BINEXACT
			/* BUG: in 3.x: Fdelete() on open file */
			Fclose(outhand);
#endif
			Fdelete(fixdst);
			buf[0] = *fixdst;
			buf[1] = 0;
			fill_string(buf, STDISKFULL);
#if (TOSVERSION < 0x400) & BINEXACT
			goto y0;
#else
			goto y1;
#endif
		}

		copysiz -= tmpsiz;
		if (!copysiz)
			break;
	}

	if (p_timedate)
		Fdatime(&time, outhand, 1);

#if (TOSVERSION < 0x400) & BINEXACT
y0:
#endif
	Fclose(outhand);
y1:
	Mfree(buffer);
y2:
	updatnum(NUMFILE, --numfiles);
	Fsetdta(saved);

	Fclose(inhand);
	Mfree(mydta);

	if (opcode == OP_MOVE && retmsg == TRUE)
		upfdesk(fixsrc, fixdst);

	return retmsg;
}


/*
 * Copy s and d into fixsrc and fixdst. Also check it is one file
 * copy or files and directories copy
 */
/* 306de: 00e29560 */
int getinfo(P(const char *) s, P(const char *) d)
PP(const char *s;)
PP(const char *d;)
{
	int sdir, ddir;
	int ret;

	srclen = strlen(s) + 5;				/* 1 byte for null and 4 byte for \*.* */
	dstlen = strlen(d) + 17;			/* 1 for null, 4 for \*.* and 13 for folder */
	srcbuf = 500;						/* initialize the buffer */
	dstbuf = 500;

	while (srclen > srcbuf)
		srcbuf *= 2;

	while (dstlen > dstbuf)
		dstbuf *= 2;

	fixsrc = (char *) Malloc((long) srcbuf);
	fixdst = (char *) Malloc((long) dstbuf);
	sdir = mystrcpy(s, fixsrc);

	if (opcode == OP_DELETE)			/* do directories or files rm */
		return sdir ? DTOD : OK;
	else								/* do directories or files cp or mv */
	{
		getlastpath(filestr, fixsrc);
		if ((ddir = mystrcpy(d, fixdst)) && sdir)
		{								/* dir to dir */
			if (*filestr)
			{							/* folder cp */
				chkbuf(dstlen, dstbuf, &fixdst);	/* check buf size */
				addfile(fixdst, filestr);	/* add the folder to dst */

				ret = created(filestr);	/* create the 1st folder */
				if (!ret || ret == SKIP)
				{
					Mfree(fixsrc);
					Mfree(fixdst);
					return ret;
				}
				strcat(fixdst, bckslsh);
			}
			return DTOD;
		}
		if (ddir)
		{								/* one file to dir */
			chkbuf(dstlen, dstbuf, &fixdst);	/* check buf size */
			strcat(fixdst, filestr);
		}
		return OK;
	}
}


/* 306de: 00e29726 */
int16_t created(P(char *)dir)
PP(char *dir;)
{
	int ret;
	char *ptr;

	updatbox(dir);
  rechkd2:								/* update check the dir existing or not */
	switch (chkdf(dir, CPDIR))
	{
	case QUIT:
		f_abort = 1;
		return FALSE;
	case SKIP:
		return SKIP;
	case FALSE:
		return FALSE;
	case CHECK:
		goto rechkd2;
	case OK:
	repeat:
		if (Dcreate(fixdst))
		{
			if (thedesk->write_save)
				goto ll_1;
			/* retry */
			if ((ret = fill_string(fixdst, STNOMEM)) == 2)
				goto repeat;
			else if (ret == 3)			/* abort */
			{
				f_abort = 1;
				return FALSE;
			}
		}

		if (opcode == OP_MOVE)
		{								/* fixsrc -> C:\XXX\ */
			ptr = r_slash(fixsrc);
			*ptr = 0;
			upfdesk(fixsrc, fixdst);
			*ptr = '\\';
		}

		break;							/* default */
	}
  ll_1:								/* update the number of dir */
	updatnum(NUMDIR, --numdirs);
	return TRUE;
}


/* 306de: 00e29826 */
BOOLEAN deleted(NOTHING)
{
	int ret;
	char buffer[NAMELEN];

	rmstarb(fixsrc);					/* remove back slash    */

	if (!fixsrc[2])						/* at the root ?    */
		return TRUE;

	getlastpath(buffer, fixsrc);
	updatbox(buffer);
  domore:
	if (Ddelete(fixsrc))
	{									/* retry    */
		if ((ret = fill_string(fixsrc, STNOMEM)) == 2)
			goto domore;
		else if (ret == 3)				/* abort */
		{
			f_abort = 1;
			return FALSE;
		}
	} else
		upfdesk(fixsrc, (char *) 0);

	if (opcode == OP_DELETE)
		updatnum(NUMDIR, --numdirs);

	return TRUE;
}


/*
 * this call will copy the string inside the s to 
 * the fixs. For example,
 * if s0 -> c:\d1\d2\*.* or c:\d1\d2\f, after the call,
 * s1 -> c:\d1\d2\  or c:\d1\d2\f ;
 */
/* 306de: 00e298e2 */
BOOLEAN mystrcpy(P(const char *) s0, P(char *) s1)
PP(const char *s0;)
PP(char *s1;)
{
	register const char *ptr;

	ptr = s0;
	while (*ptr && *ptr != '*')
		*s1++ = *ptr++;

	*s1 = '\0';
	return *ptr == '*' ? TRUE : FALSE;
}


/*
 * check the size of source buffer
 */
/* 306de: 00e29920 */
VOID chkbuf(P(int) len, P(int) bufsiz, P(char **) src)
PP(int len;)
PP(int bufsiz;)
PP(char **src;)
{
	char *ptr;

	if ((len + FILE_LEN) > bufsiz)
	{
		bufsiz *= 2;
		ptr = *src;
		*src = (char *) Malloc((long) bufsiz);
		strcpy(*src, ptr);
		Mfree(ptr);
	}
	len += FILE_LEN;
}


/*
 * s -> c:\d1\d2\*.* or c:\d1\d2\, obj -> f; after the call
 * s -> c:\d1\d2\f
 */
/* 306de: 00e29984 */
VOID addfile(P(char *) s, P(const char *) obj)
PP(char *s;)
PP(const char *obj;)
{
	register char *ptr;

	ptr = s;

	while (*ptr++)
		;

	if (*(ptr - 2) == '*')
		*(ptr - 4) = '\0';

	strcat(s, obj);
}


/*
 * src -> c:\d1\d2\*.* or -> c:\d3\d5\, after the call,
 * src -> c:\d1\d2 or -> c:\d3\d5
 */
/* 306de: 00e299ba */
VOID rmstarb(P(char *) src)
PP(register char *src;)
{
	while (*src++) ;

	if (*(src - 2) == '\\')				/* src -> c:\d3\d5\ */
		*(src - 2) = '\0';
	else								/* src -> c:\d3\d5\*.*  */
		*(src - 5) = '\0';
}


/*
 * str -> c:\d1\d2\ or c:\d1\d2\*.* or c:\d2\d4 or c:\; after the call,
 * str -> c:\d1\  or c:\d2\ or c:\
 */
/* 306de: 00e299e6 */
VOID backdir(P(char *) str)
PP(register char *str;)
{
	while (*str++) ;

	str -= 2;

	if (*(str - 1) == ':')				/* str -> c:\ */
		return;

	if (*str == '*')					/* c:\d1\d2\*.* */
		str -= 3;
	while (*--str != '\\') ;			/* str -> c:\d1\d2 or c:\d1\d2\ */

	*(str + 1) = '\0';
}


/*
 * check the directory or file is exist or not
 */
/* 306de: 00e29a1c */
int chkdf(P(char *)str, P(int) flag)
PP(char *str;)
PP(int flag;)
{
	register int ret;
	BOOLEAN first, change;
	int ret1;

	first = TRUE;
	change = f_rename;

	if (flag == CPFILE)
	{
		if (f_rename)
			goto cc_3;

		if (thedesk->write_save)					/* overwrite existing file  */
			return OK;

	cc_1:
		if ((ret = Fopen(fixdst, 0)) >= 0)
		{								/* file exist */
			Fclose(ret);
		cc_3:
			ret = edname(str, CPFILE, change);
			if (ret == CHECK)
			{
				if (f_rename)			/* do rename    */
				{
					/* first = FALSE; */
					change = FALSE;
					goto cc_1;
				}
			}

			return ret;
		}
	} else
	{
		if (f_rename)					/* if rename then show box first    */
			goto cc_5;

	cc_6:
		Dsetdrv(*fixdst - 'A');

		if (!(ret = Dsetpath(fixdst + 2)))	/* direcory exist */
		{
		cc_5:
			ret1 = edname(str, CPDIR, change);
												/* update name conflict box */
			change = FALSE;

			if (ret1 == CHECK ||		/* user enter new name  */
				(ret1 == COPY && f_rename && first))
			{
				first = FALSE;
				goto cc_6;
			}

			return ret1;
		}
	}

	/* 0xFFDE: path not found. 0xFFDF: file not found. */

	return ret == E_FILNF || ret == E_PTHNF ? OK : FALSE;
}


/* 306de: 00e29b42 */
int edname(P(char *)src, P(int) kind, P(int) change)
PP(char *src;)
PP(int kind;)
PP(int change;)
{
	int but;
	register OBJECT *obj;

	obj = get_tree(SAMENAME);

	pack(src, 0);
	strcpy(((TEDINFO *) (obj[FNAME].ob_spec))->te_ptext, src);
	strcpy(((TEDINFO *) (obj[EDFNAME].ob_spec))->te_ptext, src);
#if 0
	obj[COPY].ob_state = NORMAL;
	obj[SKIP].ob_state = NORMAL;
	obj[QUIT].ob_state = NORMAL;
#endif
	((TEDINFO *) (obj[SNAME].ob_spec))->te_ptext = NO_CONST(change ? Rname : Nconflict);

	desk_wait(FALSE);
	fm_draw(SAMENAME);

	switch (but = xform_do(obj, 0))
	{
	case COPY:
		if (!streq(((TEDINFO *) (obj[EDFNAME].ob_spec))->te_ptext, src))
		{								/* user edit the new name */
			strcpy(src, ((TEDINFO *) (obj[EDFNAME].ob_spec))->te_ptext);
			strcpy(((TEDINFO *) (cpbox[kind].ob_spec))->te_ptext, src);
			pack(src, 1);
			backdir(fixdst);
			strcat(fixdst, src);
			but = CHECK;
		} else
		{								/* check if the source and destination are the same */
			if (kind == CPDIR)
				rmstarb(fixsrc);
			if (streq(fixsrc, fixdst))	/* they are the same */
				but = SKIP;
			if (kind == CPDIR)
				strcat(fixsrc, bckslsh);
		}
		break;

	case SKIP:
	case QUIT:
		break;
	}

	desk_wait(TRUE);

	if (d_display)
		fm_draw(CPBOX);
#if 0
	else
		namecon = TRUE;
#endif
	if (but != CHECK)
		pack(src, 1);

	return but;
}


/*
 * pack	 : src -> file    rsc, after the call; src -> file.rsc
 * unpack: buf -> unpack.rsc, after the call, buf -> unpack  rsc.
 */
/* 306de: 00e29ce4 */
VOID pack(P(char *)src, P(int) flag)
PP(char *src;)
PP(int flag;)
{
	char temp[NAMELEN];

	if (flag)
		unfmt_str(src, temp);			/* pack */
	else
		fmt_str(src, temp);				/* unpack */

	strcpy(src, temp);
}


/*
 * src -> c:\f or c:\d1\f or c:\f\, or c:\f\*.*, after the call,
 * buf -> f. But if src ->c:\, then buf -> Null
 */
/* 306de: 00e29d30 */
VOID getlastpath(P(char *)buf, P(char *)src)
PP(register char *buf;)
PP(register char *src;)
{
	register char *tmp;

	tmp = src;
	*buf = '\0';

	while (*tmp++)
		;

	tmp -= 2;
	if (*tmp == '*')					/* src -> c:\f\*.* */
		tmp -= 3;
	if (*(tmp - 1) == ':')				/* src -> c:\ */
#if BINEXACT
		return OK; /** ??? OK is a resource index */
#else
		return;
#endif

	while (*--tmp != '\\')
		;			/* back one more path */

	while ((*buf = *++tmp) != '\\')
		if (!*buf++)
		{
#if BINEXACT
			return OK;
#else
			return;
#endif
		}
	*buf = '\0';
}


/*
 * up date the number of file or directory in the dialog box
 */
/* 306de: 00e29d88 */
VOID updatnum(P(int) obj, P(long) num)
PP(int obj;)
PP(long num;)
{
	if (d_display)
	{
		f_str(cpbox, obj, num);
		drawfld(cpbox, obj);
	}
}


/*
 * update the file or directory in the dialog box
 */
/* 306de: 00e29dc0 */
VOID updatname(P(int) obj, P(char *)str)
PP(int obj;)
PP(char *str;)
{
	if (d_display)
	{
		pack(str, 0);
		strcpy(((TEDINFO *) (cpbox[obj].ob_spec))->te_ptext, str);
		pack(str, 1);
		drawfld(cpbox, obj);
	}
}


/* 306de: 00e29e1c */
VOID updatbox(P(char *)str)
PP(char *str;)
{
	if (d_display)
	{
		pack(str, 0);
		strcpy(((TEDINFO *) (cpbox[CPDIR].ob_spec))->te_ptext, str);
		pack(str, 1);
		strcpy(((TEDINFO *) (cpbox[CPFILE].ob_spec))->te_ptext, "_");
	}
}
