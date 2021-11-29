#include "tosvars.inc"

/* 306de: 00e05f48 */
/* 104de: 00fc1e84 */
		xdef _plststat
_plststat:
        movem.l   d3-d7/a3-a6,-(a7)
        suba.l    a5,a5
        movea.l   _prt_stat(a5),a0
        jsr       (a0)
        movem.l   (a7)+,d3-d7/a3-a6
        rts

/* 306de: 00e05f5a */
/* 104de: 00fc1e96 */
		xdef _prtlst
_prtlst:
        move.w    6(a7),d0
        movem.l   d3-d7/a3-a6,-(a7)
        move.w    d0,-(a7)
        move.w    d0,-(a7)
        suba.l    a5,a5
        movea.l   _prt_vec(a5),a0
        jsr       (a0)
        addq.w    #4,a7
        movem.l   (a7)+,d3-d7/a3-a6
        rts

/* 306de: 00e05f76 */
/* 104de: 00fc1eb2 */
		xdef _pauxstat
_pauxstat:
        movem.l   d3-d7/a3-a6,-(a7)
        suba.l    a5,a5
        movea.l   _aux_stat(a5),a0
        jsr       (a0)
        movem.l   (a7)+,d3-d7/a3-a6
        rts

/* 306de: 00e05f88 */
/* 104de: 00fc1ec4 */
		xdef _prtaux
_prtaux:
        move.w    6(a7),d0
        movem.l   d3-d7/a3-a6,-(a7)
        move.w    d0,-(a7)
        move.w    d0,-(a7)
        suba.l    a5,a5
        movea.l   _aux_vec(a5),a0
        jsr       (a0)
        addq.w    #4,a7
        movem.l   (a7)+,d3-d7/a3-a6
        rts
