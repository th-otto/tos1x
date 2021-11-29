struct _pbdef
{
   /*  0 */ char *   pb_scrptr;  /* Pointer to start of screen memory */
   /*  4 */ uint16_t pb_offset;  /* Offset to be added to this        */
   /*  6 */ uint16_t pb_width;   /* Screen width in dots              */
   /*  8 */ uint16_t pb_height;  /* Screen height in dots             */
   /* 10 */ uint16_t pb_left;    /* Left margin in dots               */
   /* 12 */ uint16_t pb_right;   /* Right margin in dots              */
   /* 14 */ uint16_t pb_screz;   /* Resolution                        */
   /* 16 */ uint16_t pb_prrez;   /* Printer type (Atari/Epson)        */
   /* 18 */ const int16_t *pb_colptr;  /* Pointer to color palette    */
   /* 22 */ uint16_t pb_prtype;  /* 0: Atari matrix monochrome
                           1: Atari matrix color
                           2: Atari daisywheel monochrome
                           3: Epson matrix monochrome        */
   /* 24 */ uint16_t pb_prport;  /* Centronics/RS-232 port            */
   /* 26 */ const char *pb_mask; /* Pointer to halftone mask          */
   /* 30 */ 
};
