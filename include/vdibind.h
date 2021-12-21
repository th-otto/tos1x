/************************************************************************/
/*	VDIBIND.H	VDI External Declarations.			*/
/*		Copyright 1985 Atari Corp.				*/
/************************************************************************/

#ifndef __COMPILER_H__
#include <compiler.h>
#endif

#ifndef __MFDB
#define __MFDB
/* Memory Form Definition Block */
typedef struct memory_form
{
	VOIDPTR fd_addr;
	short 	fd_w;		/**< Form Width in Pixels */
	short 	fd_h; 		/**< Form Height in Pixels */
	short 	fd_wdwidth;	/**< Form Width in shorts(fd_w/sizeof(short) */
	short 	fd_stand;	/**< Form format 0= device spec 1=standard */
	short 	fd_nplanes;	/**< Number of memory planes */
	short 	fd_r1;		/**< Reserved */
	short 	fd_r2;		/**< Reserved */
	short 	fd_r3;		/**< Reserved */
} MFDB;
#endif

#ifndef __VDIPB
#define __VDIPB
typedef struct
{
	short       *control;
	const short *intin;
	const short *ptsin;
	short       *intout;
	short       *ptsout;
} VDIPB;
#endif

/* vsf_interior modes */
#define FIS_HOLLOW		0
#define FIS_SOLID		1
#define FIS_PATTERN		2
#define FIS_HATCH		3
#define FIS_USER		4

VOID v_opnwk PROTO((short *work_in, short *handle, short *work_out));
VOID v_opnvwk PROTO((short *work_in, short *handle, short *work_out));
VOID v_clswk PROTO((short handle));
VOID v_clsvwk PROTO((short handle));
VOID v_clrwk PROTO((short handle));
VOID v_updwk PROTO((short handle));
VOID vq_chcells PROTO((short handle, short *rows, short *columns));
VOID v_exit_cur PROTO((short handle));
VOID v_enter_cur PROTO((short handle));
VOID v_curup PROTO((short handle));
VOID v_curdown PROTO((short handle));
VOID v_curright PROTO((short handle));
VOID v_curleft PROTO((short handle));
VOID v_curhome PROTO((short handle));
VOID v_eeos PROTO((short handle));
VOID v_eeol PROTO((short handle));
VOID vs_curaddress PROTO((short handle, short row, short column));
VOID v_curtext PROTO((short handle, const char *string));
VOID v_rvon PROTO((short handle));
VOID v_rvoff PROTO((short handle));
VOID vq_curaddress PROTO((short handle, short *row, short *column));
short vq_tabstatus PROTO((short handle));
VOID v_hardcopy  PROTO((short handle));
VOID v_dspcur PROTO((short handle, short x, short y));
VOID v_rmcur PROTO((short handle));
VOID v_pline PROTO((short handle, short count, short *xy));
VOID v_pmarker PROTO((short handle, short count, short *xy));
VOID v_gtext PROTO((short handle, short x, short y, const char *string));
VOID v_fillarea PROTO((short handle, short count, short *xy));
VOID v_cellarray PROTO((short handle, short *xy, short row_length, short el_per_row, short num_rows, short wr_mode, short *colors));
VOID v_clear_disp_list PROTO((short handle));
VOID v_form_adv PROTO((short handle));

VOID v_bar PROTO((short handle, short *xy));
VOID v_bit_image PROTO((short handle, const char *filename, short aspect, short xscale, short yscale, short halign, short valign, short *xy));
VOID v_circle PROTO((short handle, short xc, short yc, short rad));
VOID v_arc PROTO((short handle, short xc, short yc, short rad, short sang, short eang));
VOID v_pieslice PROTO((short handle, short xc, short yc, short rad, short sang, short eang));
VOID v_ellipse PROTO((short handle, short xc, short yc, short xrad, short yrad));
VOID v_ellarc PROTO((short handle, short xc, short yc, short xrad, short yrad, short sang, short eang));
VOID v_ellpie PROTO((short handle, short xc, short yc, short xrad, short yrad, short sang, short eang));
VOID v_contourfill PROTO((short handle, short x, short y, short index));
VOID v_rbox PROTO((short handle, short *xy));
VOID v_rfbox PROTO((short handle, short *xy));

short vst_height PROTO((short handle, short height, short *char_width, short *char_height, short *cell_width, short *cell_height));
short vst_rotation PROTO((short handle, short angle));
VOID vs_color PROTO((short handle, short index, short *rgb));
short vsl_type PROTO((short handle, short style));
short vsl_width PROTO((short handle, short width));
short vsl_color PROTO((short handle, short index));
short vsm_type PROTO((short handle, short symbol));
short vsm_height PROTO((short handle, short height));
short vsm_color PROTO((short handle, short index));
short vst_font PROTO((short handle, short font));
short vst_color PROTO((short handle, short index));
short vsf_interior PROTO((short handle, short style));
short vsf_style PROTO((short handle, short index));
short vsf_color PROTO((short handle, short index));
short vq_color PROTO((short handle, short index, short set_flag, short *rgb));

VOID vrq_locator PROTO((short handle, short initx, short inity, short *xout, short *yout, short *term));
short vsm_locator PROTO((short handle, short initx, short inity, short *xout, short *yout, short *term));
VOID vrq_valuator PROTO((short handle, short val_in, short *val_out, short *term));
VOID vsm_valuator PROTO((short handle, short val_in, short *val_out, short *term, short *status));
VOID vrq_choice PROTO((short handle, short in_choice, short *out_choice));
short vsm_choice PROTO((short handle, short *choice));
VOID vrq_string PROTO((short handle, short length, short echo_mode, short *echo_xy, char *string));
short vsm_string PROTO((short handle, short length, short echo_mode, short *echo_xy, char *string));
short vswr_mode PROTO((short handle, short mode));
short vsin_mode PROTO((short handle, short dev_type, short mode));

short vsf_perimeter PROTO((short handle, short per_vis));

VOID vr_trnfm PROTO((short handle, MFDB *srcMFDB, MFDB *desMFDB));
VOID vsc_form PROTO((short handle, short *cur_form));
VOID vsf_udpat PROTO((short handle, short *fill_pat, short planes));
VOID vsl_udsty PROTO((short handle, short pattern));
VOID vr_recfl PROTO((short handle, short *xy));
VOID v_show_c PROTO((short handle, short reset));
VOID v_hide_c PROTO((short handle));
VOID vq_mouse PROTO((short handle, short *status, short *px, short *py));
VOID vex_butv PROTO((short handle, VOIDPTR usercode, VOIDPTR *savecode));
VOID vex_motv PROTO((short handle, VOIDPTR usercode, VOIDPTR *savecode));
VOID vex_curv PROTO((short handle, VOIDPTR usercode, VOIDPTR *savecode));
VOID vex_timv PROTO((short handle, VOIDPTR usercode, VOIDPTR *savecode, short *timconv));
VOID vq_key_s PROTO((short handle, short *status));

VOID v_get_pixel PROTO((short handle, short x, short y, short *pel, short *index));
VOID v_justified PROTO((short handle, short x, short y, const char *string, short length, short word_space, short char_space));
VOID v_meta_extents PROTO((short handle, short min_x, short min_y, short max_x, short max_y));
VOID vm_filename PROTO((short handle, const char *filename));
VOID v_output_window PROTO((short handle, short *xy));
VOID vq_cellarray PROTO((short handle, short *xy, short row_len, short num_rows, short *el_used, short *rows_used, short *stat, short *colors));
VOID vq_extnd PROTO((short handle, short owflag, short *work_out));
VOID vqf_attributes PROTO((short handle, short *attributes));
VOID vqin_mode PROTO((short handle, short dev_type, short *mode));
VOID vql_attributes PROTO((short handle, short *attributes));
VOID vqm_attributes PROTO((short handle, short *attributes));
short vqp_films PROTO((short handle, char *name));
VOID vsp_film PROTO((short handle, short index, short exposure));
short vqp_filmname PROTO((short handle, short index, char *name));
VOID vqt_attributes PROTO((short handle, short *attributes));
VOID vqt_extent PROTO((short handle, const char *string, short *extent));
VOID vqt_font_info PROTO((short handle, short *minADE, short *maxADE, short *distances, short *maxwidth, short *effects));
short vqt_name PROTO((short handle, short element_num, char *name));
short vqt_width PROTO((short handle, short character, short *cell_width, short *left_delta, short *right_delta));
VOID vro_cpyfm PROTO((short handle, short wr_mode, short *xy, MFDB *srcMFDB, MFDB *desMFDB));
VOID vrt_cpyfm PROTO((short handle, short wr_mode, short *xy, MFDB *srcMFDB, MFDB *desMFDB, short *index));
VOID vs_clip PROTO((short handle, short clip_flag, short *xy));
VOID vsl_ends PROTO((short handle, short beg_style, short end_style));
short vs_palette PROTO((short handle, short palette));
VOID vst_alignment PROTO((short handle, short hor_in, short vert_in, short *hor_out, short *vert_out));
short vst_effects PROTO((short handle, short effect));
short vst_load_fonts PROTO((short handle, short select));
short vst_point PROTO((short handle, short point, short *char_width, short *char_height, short *cell_width, short *cell_height));
VOID vst_unload_fonts PROTO((short handle, short select));
VOID v_write_meta PROTO((short handle, short num_ints, short *ints, short num_pts, short *pts));
VOID vq_scan PROTO((short handle, short *g_height, short *g_slice, short *a_height, short *a_slice, short *factor));
VOID v_alpha_text PROTO((short handle, const char *string));
VOID v_sound PROTO((short handle, short frequency, short duration));
short vs_mute PROTO((short handle, short action));
short vqp_error PROTO((short handle));
VOID vqp_state PROTO((short handle, short *port, short *film, short *lightness, short *interlace, short *planes, short *indexes));
VOID vsp_state PROTO((short handle, short port, short film, short lightness, short interlace, short planes, short *indexes));
VOID vsp_save  PROTO((short handle));
VOID vsp_message  PROTO((short handle));
