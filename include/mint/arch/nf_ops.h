#ifndef __ARCH_NF_OPS_H__
#define __ARCH_NF_OPS_H__

#ifndef	__COMPILER_H__
# include <compiler.h>
#endif

#include <stdarg.h>

/*
 * Interface for calling native function in emulators.
 * See http://wiki.aranym.org/natfeats/proposal
 * for a complete description.
 */

struct nf_ops
{
	long __CDECL (*get_id)  PROTO((const char *));
	long __CDECL (*call) PROTO((long id, ...));
	long res[3];
};

#ifdef __linux__
#include <asm/io.h>
#else
#define virt_to_phys(a) a
#endif

#define NF_GET_ID(ops, feature) ((*(ops)->get_id)((const char *)virt_to_phys(feature)))


#define NF_ID_NAME      "NF_NAME"
#define NF_ID_VERSION   "NF_VERSION"
#define NF_ID_STDERR    "NF_STDERR"
#define NF_ID_SHUTDOWN  "NF_SHUTDOWN"
#define NF_ID_DEBUG     "DEBUGPRINTF"
#define NF_ID_ETHERNET  "ETHERNET"
#define NF_ID_HOSTFS    "HOSTFS"
#define NF_ID_AUDIO     "AUDIO"
#define NF_ID_BOOTSTRAP "BOOTSTRAP"
#define NF_ID_CDROM     "CDROM"
#define NF_ID_CLIPBRD   "CLIPBRD"
#define NF_ID_JPEG      "JPEG"
#define NF_ID_OSMESA    "OSMESA"
#define NF_ID_PCI       "PCI"
#define NF_ID_FVDI      "fVDI"
#define NF_ID_USBHOST   "USBHOST"
#define NF_ID_XHDI      "XHDI"

#ifdef __SHORT_EXTERNAL_NAMES
#define nf_init nf_i
#define nf_get_id nf_gi
#define nf_version nf_v
#define nf_get_name nf_gn
#define nf_get_fullname nf_gfn
#define nf_debug nf_dbg
#define nf_shutdown nf_sd
#define nf_dbgprintf nf_dpr
#define nf_dbgvprintf nf_vpr
#endif


/**
 * Use this function to initialize Native Features.
 *
 * return the pointer to 'struct nf_ops' or NULL when
 *         not available.
 **/
struct nf_ops *nf_init PROTO((NOTHING));

/* basic set native feature functions */

/**
 * return the NF id to use for feature_name,
 *  or zeroe when not available.
 **/
long nf_get_id PROTO((const char *feature_name));

/**
 * return the version of the NatFeat implementation,
 *  or zero when not available.
 **/
long nf_version PROTO((NOTHING));

/**
 * return the name of the NatFeat implementor,
 *  or NULL when not available.
 **/
const char *nf_get_name PROTO((char *buf, size_t bufsize));

/**
 * return the full name of the NatFeat implementor,
 *  or NULL when not available.
 **/
const char *nf_get_fullname PROTO((char *buf, size_t bufsize));

/**
 * Write a string to the host's terminal.
 * returns TRUE when available, FALSE otherwise.
 **/
int nf_debug PROTO((const char *msg));

/**
 * Shutdown the emulator.
 * May only be called from Supervisor.
 **/
VOID nf_shutdown PROTO((NOTHING));

/**
 * Write a formatted string to the host's terminal.
 * Returns the number of characters printed,
 * or -1 if NatFeats are not available.
 * This implementation does NOT make use of the DEBUGPRINTF
 * NatFeat, where the format may use only a limited subset of
 * printf-like control characters (no field widths etc, no doubles),
 * and all arguments must be passed as 32-bit-integer values.
 * It uses the MiNTLibs implementation of sprintf instead,
 * and the NF_STDERR NatFeat.
 **/
int nf_dbgprintf PROTO((const char *fmt, ...)) __attribute__((__format__(__printf__, 1, 2)));
int nf_dbgvprintf PROTO((const char *fmt, va_list args));

#endif /* __ARCH_NF_OPS_H__ */
