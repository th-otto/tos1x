/*	JDOS.C		11/12/84 - 04/14/85	Lowell Webster		*/
/*	GEMDOSIF.C 	5/15/85 - 6/4/85	MDF			*/

/*
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "ostruct.h"
#include "toserrno.h"

int16_t DOS_AX;
BOOLEAN DOS_ERR;

#define Pexec(a,b,c,d)  trap(0x4b,a,b,c,d)
#define Fdatime(a,b,c)  trap(0x57,a,b,c)
#define Mshrink(a,b)    trap(0x4a,0,a,b)
#define Cconout(a)      trap(0x2,a)
#define Crawio(a)       trap(0x6,a)
#define Cprnout(a)      trap(0x5,a)
#define Dgetdrv()       trap(0x19)
#define Fsetdta(a)      trap(0x1a,a)
#define Fsfirst(a,b)    trap(0x4e,a,b)
#define Fsnext()        trap(0x4f)
#define Fopen(a,b)      trap(0x3d,a,b)
#define Fclose(a)       trap(0x3e,a)
#define Fread(a,b,c)    trap(0x3f,a,b,c)
#define Fwrite(a,b,c)   trap(0x40,a,b,c)
#define Fseek(a,b,c)    trap(0x42,a,b,c)
#define Dsetpath(a)     trap(0x3b,a)
#define Dgetpath(a,b)   trap(0x47,a,b)
#define Dsetdrv(a)      trap(0x0e,a)
#define Fcreate(a,b)    trap(0x3c,a,b)
#define Dcreate(a)      trap(0x39,a)
#define Fattrib(a,b,c)  trap(0x43,a,b,c)
#define Fdelete(a)      trap(0x41,a)
#define Dfree(a,b)      trap(0x36,a,b)
#define Frename(a,b,c)  trap(0x56,a,b,c)
#define Ddelete(a)      trap(0x3a,a)
#define Malloc(a)       trap(0x48,a)
#define Mfree(a)        trap(0x49,a)

#define Bconout(a,b)    trp13(3,a,b)


int isdrive(NOTHING)
{
	return dos_sdrv(dos_gdrv());
}


int16_t pgmld(P(int16_t) handle, P(const char *) pname, P(intptr_t *) ldaddr)
PP(int16_t handle;)
PP(const char *pname;)
PP(intptr_t *ldaddr;)
{
	intptr_t length;
	intptr_t *temp;

	*ldaddr = Pexec(3, pname, "", NULL);
	if (!DOS_ERR)
	{									/* code+data+bss lengths */
		temp = (intptr_t *)*ldaddr;
		length = temp[3] + temp[5] + temp[7] + 0x100;	/* and base page length */
		Mshrink(*ldaddr, length);
		if (!DOS_ERR)
			return TRUE;
		else
			return -1;
	} else
	{
		return -1;
	}
}


int chrout(P(int) c)
PP(int c;)
{
	return Cconout(c);
}


VOID bellout(NOTHING)
{
	Bconout(2, 7);
}


int rawcon(P(int) c)
PP(int c;)
{
	return (char)Crawio(c); /* BUG: cast */
}


int prt_chr(P(int) c)
PP(int c;)
{
	return Cprnout(c);
}


int dos_gdrv(NOTHING)
{
	return Dgetdrv();
}


int dos_sdta(P(VOIDPTR) dta)
PP(VOIDPTR dta;)
{
	return Fsetdta(dta);
}


BOOLEAN dos_sfirst(P(const char *)name, P(int) attrib)
PP(const char *name;)
PP(int attrib;)
{
	register long err;
	
	err = Fsfirst(name, attrib);
	if (err == 0)
		return TRUE;
	if (err == E_NMFIL || err == E_FILNF)
	{
		DOS_AX = ~E_NMFIL - 30;
		return FALSE;
	} else
	{
		return FALSE;
	}
}


BOOLEAN dos_snext(NOTHING)
{
	register long err;

	err = Fsnext();
	if (err == 0)
		return TRUE;
	if (err == E_NMFIL || err == E_FILNF)
	{
		DOS_AX = ~E_NMFIL - 30;
		return FALSE;
	} else
	{
		return FALSE;
	}
}


int dos_open(P(const char *) name, P(int) mode)
PP(const char *name;)
PP(int mode;)
{
	long err;

	err = Fopen(name, mode);
	if (err == E_FILNF)
		DOS_AX = ~E_FILNF - 30;
	if (DOS_ERR)
		return FALSE;
	else
		return err;
}


int dos_close(P(int) fd)
PP(int fd;)
{
	return Fclose(fd);
}


/* Attention: size_t is only 16bit on Alcyon */
long dos_read(P(int) fd, P(size_t) size, P(VOIDPTR) buf)
PP(int fd;)
PP(size_t size;)
PP(VOIDPTR buf;)
{
	long ret;
	ret = Fread(fd, (long)size, buf);
	return ret;
}


/* Attention: size_t is only 16bit on Alcyon */
long dos_write(P(int) fd, P(size_t) size, P(VOIDPTR) buf)
PP(int fd;)
PP(size_t size;)
PP(VOIDPTR buf;)
{
	long ret;
	ret = Fwrite(fd, (long)size, buf);
	return ret;
}


long dos_lseek(P(int) fd, P(int) whence, P(long) offset)
PP(int fd;)
PP(int whence;)
PP(long offset;)
{
	return Fseek(offset, fd, whence);
}


long dos_chdir(P(const char *) path)
PP(const char *path;)
{
	long ret;
	ret = Dsetpath(path);
	return ret;
}


int dos_gdir(P(int) drive, P(char *) pdrvpath)
PP(int drive;)
PP(char *pdrvpath;)
{
	return Dgetpath(drive, pdrvpath);
}


int dos_sdrv(P(int) drv)
PP(int drv;)
{
	return Dsetdrv(drv);
}


long dos_create(P(const char *) name, P(int) attr)
PP(const char *name;)
PP(int attr;)
{
	long ret;
	
	ret = Fcreate(name, attr);
	return ret;
}


BOOLEAN dos_mkdir(P(const char *) path)
PP(const char *path;)
{
	long ret;
	
	ret = Dcreate(path);
	if (ret == E_ACCDN)
		DOS_AX = ~E_ACCDN - 30;
	return !DOS_ERR;
}


long dos_chmod(P(const char *) path, P(BOOLEAN) setit, P(int) attr)
PP(const char *path;)
PP(BOOLEAN setit;)
PP(int attr;)
{
	return Fattrib(path, setit, attr);
}


long dos_set(P(int) h, P(uint16_t) time, P(uint16_t) date)
P(int h;)
P(uint16_t time;)
P(uint16_t date;)
{
	_DOSTIME dt;

	dt.time = time;
	dt.date = date;
	return Fdatime(&dt, h, TRUE);
}


BOOLEAN dos_label(P(int) drive, P(const char *) name)
PP(char drive;)
PP(const char *name;)
{
	char buf[50];						/* 44 bytes used    */
	char path[8];
	int ret;

	bfill(sizeof(buf), 0, buf);
	Fsetdta((_DTA *)buf);
	path[0] = drive + 'A' - 1;
	path[1] = ':';
	path[2] = '\\';
	path[3] = '*';
	path[4] = '.';
	path[5] = '*';
	path[6] = '\0';
	ret = Fsfirst(path, FA_LABEL);
	if (ret == 0)
	{
		strcpy(name, &buf[30]);
		return TRUE;
	} else
	{
		DOS_ERR = DOS_AX = TRUE;
		return FALSE;
	}
}


long dos_delete(P(const char *) path)
PP(const char *path;)
{
	return Fdelete(path);
}


BOOLEAN dos_space(P(int) drive, P(int32_t *) total, P(int32_t *) avail)
PP(int drive;)
PP(int32_t *total;)
PP(int32_t *avail;)
{
	_DISKINFO buf;
	uint32_t mult;
	
	Dfree(&buf, drive);
	mult = buf.b_clsiz * buf.b_secsiz;
	*total = mult * buf.b_total;
	*avail = mult * buf.b_free;
	return TRUE;
}


long dos_rename(P(const char *) oldname, P(const char *) newname)
PP(const char *oldname;)
PP(const char *newname;)
{
	return Frename(0, oldname, newname);
}


long dos_rmdir(P(const char *) path)
PP(const char *path;)
{
	long ret;
	
	UNUSED(ret);
	return Ddelete(path);
}


VOIDPTR dos_alloc(P(long) size)
PP(long size;)
{
	intptr_t ret;
	
	if (size & 1)
		size++;
	ret = Malloc(size);
	if (ret == 0)
	{
		DOS_ERR = TRUE; 					/* gemdos() sets it to FALSE    */
		return NULL;
	}
	if (ret & 1)
		ret++;
	return (VOIDPTR)ret;
}


/*
 *	Returns the amount of memory available in bytes
 */
intptr_t dos_avail(NOTHING)
{
	return Malloc(-1L);
}


int dos_free(P(VOIDPTR) ptr)
PP(VOIDPTR ptr;)
{
	Mfree(ptr);
}
