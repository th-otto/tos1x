/* strcz.h */

#ifdef NEED_STRINGS

/* 206cz: e367c2-e36a02 (576 bytes) */
char const czstr[] = "\
-D\240le-\0\
-Konec souboru-\0\
ROM modul\0\
Kop\241rovat soubor(y)\0\
Mazat soubor(y)\0\
Informace o souboru\0\
Informace o po\251ada\207i\0\
P\251en\202st soubor(y)\0\
-Chyba \207ten\241-\0\
Nelze otev\251\241t\0\
Nen\241 voln\240 pam\210\237\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\
  Cache                   [ ]\0\
  Blitter                 [ ]\0\
Jm\202no ji\221 existuje!\0\
P\251ejmenovat c\241lov\230 objekt\0\
Kop\241rovat a p\251ejmenovat objekt(y)\0\
P\251en\202st a p\251ejmenovat objekt(y)\0\
 %L bajt\226 v %W objektu.\0\
 %L bajt\226 v %W vybran\230ch objektech.\0\
 %L bajt\226 v %W vybran\202m objektu.\0\
 %L bajt\226 v %W objektech.\0\
Za\251\241zen\241\0\
Vyber .INF soubor\0\
Hledej objekt\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\
";

#else

extern char const czstr[];

#define More czstr+0
#define Endfile czstr+7
#define Cart czstr+23
#define Cpystr czstr+33
#define Delstr czstr+53
#define Fileinfo czstr+69
#define Foldinfo czstr+89
#define Movestr czstr+110
#define Readerror czstr+128
#define Cantopen czstr+142
#define Nomem czstr+156
#define Cachetxt czstr+208
#define Blttxt czstr+238
#define Nconflict czstr+268
#define Rname czstr+288
#define Crenstr czstr+314
#define Mrenstr czstr+348
#define Istr czstr+380
#define Isels czstr+404
#define Isel czstr+440
#define Istrs czstr+473
#define Device czstr+499
#define Sinf czstr+508
#define Litem czstr+526

#endif
