#if (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_SF)
#define S_CARTNAME "CARTOUCHE"
#define S_PRINT    "EN COURS D'IMPRESSION "
#define S_MORE     "-SUITE-"
#define S_EOF      "-FIN DE FICHIER-"
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SG)
#define S_CARTNAME "ROMMODUL"
#define S_PRINT    "DRUCKE: "
#define S_MORE     "-MEHR-"
#define S_EOF      "-ENDE DER DATEI-"
#endif

#if (OS_COUNTRY == CTRY_US) | (OS_COUNTRY == CTRY_UK)
#define S_CARTNAME "Cartridge"
#define S_PRINT    "PRINTING  "
#define S_MORE     "--MORE--"
#define S_EOF      "---END OF FILE---"
#endif

