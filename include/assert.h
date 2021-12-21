#undef assert
#ifndef NDEBUG
# define assert(ex) {if (!(ex)){fprintf(stderr,"Assertion failed: file %s, line %d\n", __FILE__, __LINE__);exit(1);}}
#else
# define assert(ex) ;
#endif
