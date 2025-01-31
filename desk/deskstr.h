#if (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_SF)
#define S_CARTNAME  "CARTOUCHE"
#define S_PRINT     "EN COURS D'IMPRESSION "
#define S_MORE      "-SUITE-"
#define S_EOF       "-FIN DE FICHIER-"
#define S_FMTERR    "[3][Erreur durant formatage|ou copie - le disque d'arriv\202e|est peut etre endommag\202.][ OK ]"
#define S_NOTSAME   "[3][Le disque source n'est pas du|m\210me type que le disque|d'arriv\202e.][ OK ]"
#define S_FREESPACE "[1][Ce disque a %L octets|disponibles.][ OK ]"
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG)
#define S_CARTNAME  "ROMMODUL"
#define S_PRINT     "DRUCKE: "
#define S_MORE      "-MEHR-"
#define S_EOF       "-ENDE DER DATEI-"
#define S_FMTERR    "[3][Fehler beim Formatieren|oder Kopieren! Zieldisk k\224nnte|defekt sein.][ OK ]"
#define S_NOTSAME   "[3][Disketten haben nicht das|gleiche Format!][ OK ]"
#define S_FREESPACE "[1][Disk hat %L Bytes|freien Speicherplatz.][ OK ]"
#endif

#if (OS_COUNTRY == CTRY_US) | (OS_COUNTRY == CTRY_UK)
#define S_CARTNAME  "Cartridge"
#define S_PRINT     "PRINTING  "
#define S_MORE      "--MORE--"
#define S_EOF       "---END OF FILE---"
#define S_FMTERR    "[3][An error has occurred during|format or copy. Target disk|may be unusable.][ OK ]"
#define S_NOTSAME   "[3][The source disk is not|the same type as the|destination disk.][ OK ]"
#define S_FREESPACE "[1][This disk has %L bytes|available to user.][ OK ]"
#endif

#if (OS_COUNTRY == CTRY_DK)
#define S_CARTNAME  "kapsel\0\0"
#define S_PRINT     " PRINT: "
#define S_MORE      "-MERE-"
#define S_EOF       "-SLUT P\217 FILEN- "
#define S_FMTERR    "[3][En fejl opstod under formate-|ring eller kopiering.  |           ][  OK  ]"
#define S_NOTSAME   "[3][Disketterne har ikke samme|format!       ][ OK ]"
#define S_FREESPACE "[1][Disketten har %L|Bytes fri.          ][  OK  ]"
#endif

