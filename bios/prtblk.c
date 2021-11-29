#include "bios.h"
#include "pbdef.h"
#include "tosvars.h"

#define max(x,y)   (((x) > (y)) ? (x) :  (y))
#define min(x,y)   (((x) < (y)) ? (x) :  (y))

/*
 ** Prtblk print parameter values.
 */
#define       MAXOFF    (7)                      /* maximum value of offset */

#define       LOWID     (320)                    /* low clip width */
#define       HIWID     (640)                    /* medium/high clip width */

#define       LOW       (0)                      /* low srcres */
#define       MEDIUM    (1)                      /* medium srcres */
#define       HIGH      (2)                      /* high srcres */
#define       MAXSRC    (2)                      /* maximum value of srcres */

#define       DRAFT     (0)                      /* draft dstres */
#define       FINAL     (1)                      /* final dstres */
#define       MAXDST    (1)                      /* maximum value of dstres */

#define       ATMDM     (0)                      /* Atari mono dot matrix */
#define       ATCDM     (1)                      /* Atari color dot matrix */
#define       ATMDW     (2)                      /* Atari mono daisy wheel */
#define       EPMDM     (3)                      /* Epson mono dot matrix */
#define       MAXTYP    (3)                      /* maximum value of type */

#define       PRNTR     (0)                      /* parallel printer port */
#define       MODEM     (1)                      /* serial modem port */
#define       MAXPOR    (1)                      /* maximum value of port */

/*
 ** Prtblk control character and escape sequence strings.
 */

#define       ABMMO     "\033\131\377"           /* Atari BitMap mode */
#define       EBMMO     "\033\114\377"           /* Epson BitMap mode */

#define       YELLO     "\033\130\006\377"       /* set yellow */
#define       MAGTA     "\033\130\005\377"       /* set magenta */
#define       CYAN      "\033\130\003\377"       /* set cyan */

#define       PIXLS     "\033\063\001\377"       /* pixel line spacing */
#define       RASLS     "\033\061\377"           /* raster line spacing */

#define       RSTLS     "\033\062\377"           /* reset line spacing */
#define       RSTCO     "\033\130\000\377"       /* reset color */

#define       CR        '\015'                   /* carriage return */
#define       LF        '\012'                   /* line feed */

/*
 ** Prtblk get word bit and byte bit macro functions.
 */

#define       WRDBIT(wrd,bit)  ((wrd>>(15-bit))&0x0001)
#define       BYTBIT(byt,bit)  ((byt>>(7-bit))&0x0001)

/*
 ** Prtblk miscellaneous macros.
 */

#define       NOABRT    (1)                      /* prtcnt no abort value */

#define       PBERR     (-1)                     /* prtblk return error */

PBDEF pbpar;

char prtbdev;	/* TRUE when printing to centronics port; was: PR */
char prtblow;	/* TRUE when printing low resolution; was: LO */
char prtbmed;	/* TRUE when printing medium resolution; was: ME */
char prtbmono;	/* TRUE when printing monochrome resolution; was: HI */
char prtbprez;	/* TRUE when printing high quality; was: DR */
char prtbacol;	/* TRUE when printing on Atari color matrix; was: CD */
char prtbamon;	/* TRUE when printing on Atari monochrome; was: DW */
char prtbeps;	/* TRUE when printing on Epson; was: ED */
char prtbdmask; /* TRUE if using default halftone mask; was: TW */
int16_t prtbinvert; /* invert flag for monochrome; was: invid */
int16_t prtbtcol; /* duplicate colpal entry */
int16_t prtbbval; /* blue value */
int16_t prtbgval; /* green value */
int16_t prtbrval; /* red value */
int16_t prtbmaxval[16]; /* intensity palette */
int16_t prtbminval[16]; /* lumin/satur palette */
int16_t prtbval[16]; /* hue palette */
int16_t prtbplanes;
int16_t prtbdots;
int16_t prtblines;
int16_t prtbwords;
int16_t prtbbytes;
int16_t prtboffset;
int16_t prtbbits;
int16_t prtbwidth;
int16_t prtbheight;
char *prtbstrt;
char prtbbol;
char prtbflg;		/* white space flag; was: WS */
char *prtbend;
int16_t *prtbp1;
int16_t *prtbp2;
int16_t prtbpmsk;
int16_t prtbidx;
char prtbilow;
char prtbihigh;
int prtbchunk;
int prtbink;
char prtbodd;
char prtbobuf[8];
int prtboval[4];
int prtbmval[4];
char prtbempty;
char prtboch;
int prtbomask;

/* WTF: these variables are from VDI */
extern short width;
extern short height;


static char const pbt_mask[] = {
	0x0f, 0x0f, 0x0d, 0x06, 0x09, 0x06, 0x08, 0x06,
	0x08, 0x02, 0x08, 0x00, 0x08, 0x00, 0x08, 0x00,
	0x00, 0x00
};

static int prtchar PROTO((char c));
static int prtstr PROTO((const char *s));

#define RETERR dumpflg = -1; return -1

#define PRTSTR(s) \
	if (prtstr(s) != 0) \
	{ \
		RETERR; \
	}
#define PRTCHAR(c) \
	if (prtchar(c) != 0) \
	{ \
		RETERR; \
	}


/*
 * XBIOS #36 - Prtblk - Hardcopy print-out 
 */
/* 306de: 00e045d8 */
/* 206de: 00e041e6 */
/* 104de: 00fc215c */
int16_t prtblk(P(const PBDEF *) par)
PP(const PBDEF *par;)
{
	register int i;
	register int j;
	register const char *src;
	register char *dst;
	
	/* copy prtblk arguments */
	for (src = (const char *)par, dst = (char *)&pbpar, i = sizeof(*par); i > 0; i--)
		*dst++ = *src++;
	
	/* determine output port */
	if (pbpar.pb_prport > MAXPOR)
	{
		RETERR;
	}
	
	/* determine output port */
	prtbdev = pbpar.pb_prport != 0 ? 0 : 1;
	
	/* check for text string */
	if (pbpar.pb_height == 0)
	{
		while (pbpar.pb_width-- != 0)
		{
			/* check global print count for abort */
			if (dumpflg != NOABRT)
				break;
			PRTCHAR(*pbpar.pb_scrptr++);
		}
		dumpflg = -1;
		return 0;
	}
	
	/* check print parameters (some for debug) */
	if (pbpar.pb_prtype > MAXTYP)
	{
		RETERR;
	}
	
	if (pbpar.pb_prrez > MAXDST)
	{
		RETERR;
	}
	
	if (pbpar.pb_screz > MAXSRC)
	{
		RETERR;
	}
	
	if (pbpar.pb_offset > MAXOFF)
	{
		RETERR;
	}
	
	prtblow = pbpar.pb_screz == LOW;
	prtbmed = pbpar.pb_screz == MEDIUM;
	prtbmono = pbpar.pb_screz == HIGH;
	prtbprez = pbpar.pb_prrez == DRAFT;
	prtbacol = pbpar.pb_prtype == ATCDM;
	prtbamon = pbpar.pb_prtype == ATMDW;
	prtbeps = pbpar.pb_prtype == EPMDM;
	
	if (prtbamon)								/* BitMap on daisy wheel */
	{
		RETERR;
	}
	
	prtbprez = prtbeps && !prtbprez ? TRUE : prtbprez;		/* force draft on Epson */
	
	if (prtblow && pbpar.pb_width > LOWID)					/* clip width to low */
	{
		pbpar.pb_right += pbpar.pb_width - LOWID;
		pbpar.pb_width = LOWID;
	} else if (pbpar.pb_width > HIWID)						/* clip width to high */
	{
		pbpar.pb_right += pbpar.pb_width - HIWID;
		pbpar.pb_width = HIWID;
	}
	
	/* determine halftone masks and trailing white truncation */
	if (pbpar.pb_mask == NULL)
	{
		pbpar.pb_mask = pbt_mask;
		prtbdmask = TRUE;
	} else
	{
		prtbdmask = FALSE;
	}
	
	/* build luminance or hue/saturation/intensity palettes */
	if (prtbmono)
	{
		prtbinvert = pbpar.pb_colptr[0] & 1;
	} else
	{
		for (i = 0; i < 16; i++)
		{
			prtbtcol = *pbpar.pb_colptr++ & 0x777;
			if (prtbtcol != 0x777)
			{
				prtbbval = prtbtcol & 0x07;
				prtbgval = (prtbtcol >> 4) & 0x07;
				prtbrval = (prtbtcol >> 8) & 0x07;
				if (prtbacol)										/* color hue/satur/inten */
				{
					prtbmaxval[i] = prtbrval;
					prtbmaxval[i] = max(prtbgval, prtbmaxval[i]);
					prtbmaxval[i] = max(prtbbval, prtbmaxval[i]);
					++prtbmaxval[i];
					prtbminval[i] = prtbrval;
					prtbminval[i] = min(prtbgval, prtbminval[i]);
					prtbminval[i] = min(prtbbval, prtbminval[i]);
					prtbrval = (prtbrval - (prtbminval[i] + 1)) <= 0 ? 0 : 1;
					prtbgval = (prtbgval - (prtbminval[i] + 1)) <= 0 ? 0 : 1;
					prtbbval = (prtbbval - (prtbminval[i] + 1)) <= 0 ? 0 : 1;
					prtbval[i] = (prtbrval << 2) + (prtbgval << 1) + prtbbval;
				} else												/* monochrome luminance */
				{
					prtbminval[i] = (prtbrval * 30 + prtbgval * 59 + prtbbval * 11) / 100;	/* NTSC RGB summation */
					prtbval[i] = 7;
					prtbmaxval[i] = 8;
				}
			} else
			{
				prtbminval[i] = 8;
				prtbval[i] = 7;
				prtbmaxval[i] = 8;
			}
		}
	}
	
	/* determine pixel mapping parameters */
	if (prtblow)
	{
		prtbplanes = prtblines = prtbdots = 4;
	} else if (prtbmed)
	{
		prtbplanes = prtbdots = 2;
		prtblines = 4;
	} else
	{
		prtbplanes = 1;
		prtblines = 8;
		prtbdots = 2;
	}
	
	prtbdots /= (prtbeps ? 2 : 1);
	
	prtbwords = ((pbpar.pb_left + pbpar.pb_width + pbpar.pb_right) * prtbplanes) >> 4;
	prtbbytes = prtbwords * prtblines;
	/* normalize BitMap block pointer */
	/* NB -- all bits are addressed left to right */
	prtbstrt = (char *)((intptr_t)pbpar.pb_scrptr & ~1);
	prtboffset = pbpar.pb_scrptr == prtbstrt ? pbpar.pb_offset : pbpar.pb_offset + 8;
	
	/* map pixels and print */
	prtbbol = 1;
	height = 0;
	
	while (height < pbpar.pb_height)
	{
		if (dumpflg != NOABRT)
			break;
		
		if (prtbdmask)
		{
			prtbflg = 1;
			prtbend = prtbstrt + ((((pbpar.pb_width * prtbplanes) >> 4) - prtbplanes) << 1);
			prtbbits = 15 - (pbpar.pb_width & 0x0f);
			for (prtbwidth = pbpar.pb_width; prtbwidth > 0; prtbwidth--)
			{
				prtbheight = ((pbpar.pb_height - height) / prtblines) != 0 ? prtblines : (pbpar.pb_height - height);
				prtbp1 = (int16_t *) prtbend;
				for (i = 0; i < prtbheight; i++)
				{
					prtbidx = 0;
					prtbpmsk = 1;
					prtbp2 = prtbp1;
					for (j = 0; j < prtbplanes; j++)
					{
						prtbidx += ((*prtbp2 >> (15 - prtbbits)) & 1) * prtbpmsk;
						prtbp2++;
						prtbpmsk <<= 1;
					}
					if (prtbmono)
					{
						if ((prtbidx ^ prtbinvert) == 0)
						{
							prtbflg = 0;
							break;
						}
					} else
					{
						if (prtbminval[prtbidx] != 8)
						{
							prtbflg = 0;
							break;
						}
					}
					
					prtbp1 += prtbwords;
				}
				
				if (!prtbflg)
					break;
				
				--prtbbits;
				if (prtbbits < 0)
				{
					prtbend -= prtbplanes << 1;
					prtbbits = 15;
				}
			}
		} else
		{
			prtbwidth = pbpar.pb_width;
		}
		
		i = prtbwidth * prtbdots;
		i += prtbeps ? (i / 2) : 0;
		prtbilow = i % 256;
		prtbihigh = i / 256;
		
		for (prtbchunk = 0; prtbchunk < (prtbprez ? 1 : 2); prtbchunk++)
		{
			for (prtbink = 0; prtbink < (prtbacol && !prtbmono ? 3 : 1); prtbink++)
			{
				if (prtbacol && !prtbmono)
				{
					if (prtbink == 0)
					{
						PRTSTR(YELLO);
					} else if (prtbink == 1)
					{
						PRTSTR(MAGTA);
					} else
					{
						PRTSTR(CYAN);
					}
				}
				
				/* select 120 dpi graphics */
				PRTSTR(prtbeps ? EBMMO : ABMMO);
				
				PRTCHAR(prtbilow);
				PRTCHAR(prtbihigh);
				
				prtbodd = 1;
				prtbend = prtbstrt;
				prtbbits = prtboffset;
				for (width = 0; width < prtbwidth; width++)
				{
					for (i = 0; i < 8; i++)
						prtbobuf[i] = 0;
					for (i = 0; i < 4; i++)
					{
						prtboval[i] = 7;
						prtbmval[i] = 8;
					}
					
					/* build pixel block */
					prtbheight = ((pbpar.pb_height - height) / prtblines) != 0 ? prtblines : (pbpar.pb_height - height);
					if (((pbpar.pb_height - height) / prtblines) != 0)
					{
						prtbheight = prtblines;
					} else
					{
						prtbheight = pbpar.pb_height - height;
						prtbbol = 0;
					}
					prtbp1 = (int16_t *)prtbend;
					for (i = 0; i < prtbheight; i++)
					{
						prtbidx = 0;
						prtbpmsk = 1;
						prtbp2 = prtbp1;
						for (j = 0; j < prtbplanes; j++)
						{
							prtbidx += ((*prtbp2 >> (15 - prtbbits)) & 1) * prtbpmsk;
							prtbp2++;
							prtbpmsk <<= 1;
						}
						
						if (prtbmono)
						{
							prtbobuf[i] = (prtbidx ^ prtbinvert) == 0 ? *pbpar.pb_mask : 0;
						} else
						{
							prtbobuf[i * 2] = pbpar.pb_mask[prtbminval[prtbidx] * 2];
							prtbobuf[i * 2 + 1] = pbpar.pb_mask[prtbminval[prtbidx] * 2 + 1];
							prtboval[i] = prtbval[prtbidx];
							prtbmval[i] = prtbmaxval[prtbidx];
						}
						
						prtbp1 += prtbwords;
					}
					
					/* adjust pixel block for ymc color and intensity and brown */
					if (prtbacol && !prtbmono)
					{
						for (i = 0; i < prtbheight; i++)
						{
							prtbempty = 0;
							if (prtbink == 0)
							{
								if ((prtboval[i] % 2) != 0)
									prtbempty = 1;
							} else if (prtbink == 1)
							{
								if (prtboval[i] == 6 && prtbmval[i] < 8)
								{
									prtbobuf[i * 2] &= 1;
									prtbobuf[i * 2 + 1] &= 4;
								} else if (prtboval[i] == 2 || prtboval[i] == 3 || prtboval[i] == 6 || prtboval[i] == 7)
								{
									prtbempty = 1;
								}
							} else
							{
								if (prtboval[i] == 6 && prtbmval[i] < 8)
								{
									prtbobuf[i * 2] &= 4;
									prtbobuf[i * 2 + 1] &= 1;
								} else if (prtboval[i] > 3)
								{
									prtbempty = 1;
								}
							}
							
							if (prtbempty)
							{
								prtbobuf[i * 2] = 0;
								prtbobuf[i * 2 + 1] = 0;
							}
							
							prtbobuf[i * 2] |= pbpar.pb_mask[prtbmval[i] * 2];
							prtbobuf[i * 2 + 1] |= pbpar.pb_mask[prtbmval[i] * 2 + 1];
						}
					}
					
					/* print pixel block */
					for (i = 4; i < (prtbdots + 4); i++)
					{
						prtboch = 0;
						prtbomask = 0x80;
						for (j = 0; j < 8; j++)
						{
							prtboch += ((prtbobuf[j] >> (7 - i)) & 1) * prtbomask;
							prtbomask = prtbomask / 2;
						}
						PRTCHAR(prtboch);
						prtbodd = prtbodd ? 0 : 1;
					}
					
					if (prtbeps && prtbodd)
					{
						PRTCHAR(prtboch);
					}
					
					++prtbbits;
					if (prtbbits > 15)
					{
						prtbend += prtbplanes << 1;
						prtbbits = 0;
					}
				}
				
				PRTCHAR(CR);
			}
			
			/* set 1/216 inch line spacing */
			PRTSTR(PIXLS);
			PRTCHAR(LF);
		}
		
		if (prtbprez)
		{
			for (i = 0; i < (prtbeps ? 2 : 1); i++)
			{
				/* set 1/216 inch line spacing */
				PRTSTR(PIXLS);
				PRTCHAR(LF);
			}
		}
		
		if (prtbbol)
		{
			/* Select 7/72-inch line spacing */
			PRTSTR(RASLS);
			PRTCHAR(LF);
		} else
		{
			for (i = 0; i < (prtbeps ? (prtbheight * 6 - 3) : ((prtbheight << 2) - 2)); i++)
			{
				/* set 1/216 inch line spacing */
				PRTSTR(PIXLS);
				PRTCHAR(LF);
			}
		}
		
		prtbstrt += prtbbytes << 1;
		height += prtblines;
	}
	
	/* set 1/6 inch line spacing */
	prtstr(RSTLS);
	if (prtbacol && !prtbmono)
	{
		prtstr(RSTCO);
	}
	
	dumpflg = -1;
	return 0;
}


static int prtchar(P(char) c)
PP(char c;)
{
	if (prtbdev != 0)
	{
		if (prtlst(c, c) == 0)
			return PBERR;
	} else
	{
		prtaux(c, c);
	}
	return 0;
}


static int prtstr(P(const char *) s)
PP(const char *s;)
{
	while (*s != 0xff)
	{
		if (prtchar(*s++) != 0)
			return PBERR;
	}
	return 0;
}
