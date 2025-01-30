GEM_MUPB_MAGIC equ $87654321

		xref _endgembss
		xref _gemstart

/* in TOS versions <= 1.02, this is always located at the end of the rom */
        data
        xdef _ui_mupb
_ui_mupb: /* equ $2fff4 */
        dc.l GEM_MUPB_MAGIC
        dc.l _endgembss
        dc.l _gemstart
