#define CMD_BAT    0xFA
#define CMD_COPY   0xFB
#define CMD_FORMAT 0xFC
#define CMD_PRINT  0xFD
#define CMD_TYPE   0xFE

VOID sh_type PROTO((const char *fname));
VOID sh_print PROTO((const char *fname));
VOID sh_format PROTO((char *fname, char *cmd));
VOID sh_copy PROTO((char *fname, char *cmd));
