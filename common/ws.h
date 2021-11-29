#ifndef WS_H
#define WS_H 1

typedef struct wsstr
{
	/* [ 0] */ int16_t		ws_xres;
	/* [ 1] */ int16_t		ws_yres;
	/* [ 2] */ int16_t		ws_noscale;
	/* [ 3] */ int16_t		ws_wpixel;
	/* [ 4] */ int16_t		ws_hpixel;
	/* [ 5] */ int16_t		ws_ncheights;
	/* [ 6] */ int16_t		ws_nlntypes;
	/* [ 7] */ int16_t		ws_nlnwidths;
	/* [ 8] */ int16_t		ws_nmktypes;
	/* [ 9] */ int16_t		ws_nmksizes;
	/* [10] */ int16_t		ws_nfaces;
	/* [11] */ int16_t		ws_npatts;
	/* [12] */ int16_t		ws_nhatchs;
	/* [13] */ int16_t		ws_ncolors;
	/* [14] */ int16_t		ws_ngdps;
	/* [15] */ int16_t		ws_supgdps[10];
	/* [25] */ int16_t		ws_attgdps[10];
	/* [35] */ int16_t		ws_color;
	/* [36] */ int16_t		ws_rotate;
	/* [37] */ int16_t		ws_fill;
	/* [38] */ int16_t		ws_cell;
	/* [39] */ int16_t		ws_npals;
	/* [40] */ int16_t		ws_nloc;
	/* [41] */ int16_t		ws_nval;
	/* [42] */ int16_t		ws_nchoice;
	/* [43] */ int16_t		ws_nstring;
	/* [44] */ int16_t		ws_type;
	/* [45] */ int16_t		ws_pts0;
	/* [46] */ int16_t		ws_chminh;
	/* [47] */ int16_t		ws_pts2;
	/* [48] */ int16_t		ws_chmaxh;
	/* [49] */ int16_t		ws_lnminw;
	/* [50] */ int16_t		ws_pts5;
	/* [51] */ int16_t		ws_lnmaxw;
	/* [52] */ int16_t		ws_pts7;
	/* [53] */ int16_t		ws_pts8;
	/* [54] */ int16_t		ws_mkminw;
	/* [55] */ int16_t		ws_pts10;
	/* [56] */ int16_t		ws_mkmaxw;
} WS;

extern WS gl_ws;

#endif
