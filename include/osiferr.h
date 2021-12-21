/* OSIF Error handling */
extern int errno;			/* error place for assigning	    */
#define RETERR(val,err) {errno=(err);return(val);}

