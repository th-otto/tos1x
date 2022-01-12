/*****************************************************************************
 * S_ENDIAN.H
 *****************************************************************************/

#ifndef __S_ENDIAN_H__
#define __S_ENDIAN_H__

#ifdef HAVE_BYTESWAP_H
# include <byteswap.h>
#endif
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif


#define BYTE_ORDER_BIG_ENDIAN    4321
#define BYTE_ORDER_LITTLE_ENDIAN 1234
#define BYTE_ORDER_PDP_ENDIAN    3412

#ifndef HOST_BYTE_ORDER
#  ifdef BYTE_ORDER
#    define HOST_BYTE_ORDER BYTE_ORDER
#  else
#    ifdef __BYTE_ORDER
#      define HOST_BYTE_ORDER __BYTE_ORDER
#    else
#      ifdef _BYTE_ORDER
#        define HOST_BYTE_ORDER _BYTE_ORDER
#      endif
#    endif
#  endif
#endif

#ifndef HOST_BYTE_ORDER

#  ifdef __mc68000__
#    define HOST_BYTE_ORDER BYTE_ORDER_BIG_ENDIAN
#  endif
#  ifdef __mc68k__
#    define HOST_BYTE_ORDER BYTE_ORDER_BIG_ENDIAN
#  endif
#  ifdef m68k
#    define HOST_BYTE_ORDER BYTE_ORDER_BIG_ENDIAN
#  endif

#  ifdef __i386__
#    define HOST_BYTE_ORDER BYTE_ORDER_LITTLE_ENDIAN
#  endif
#  ifdef __i486__
#    define HOST_BYTE_ORDER BYTE_ORDER_LITTLE_ENDIAN
#  endif
#  ifdef __i586__
#    define HOST_BYTE_ORDER BYTE_ORDER_LITTLE_ENDIAN
#  endif
#  ifdef __x86_64__
#    define HOST_BYTE_ORDER BYTE_ORDER_LITTLE_ENDIAN
#  endif

#endif

#ifndef HAVE_BSWAP_32
#undef bswap_32
#ifdef HAVE___BUILTIN_BSWAP32
static __inline uint32_t bswap_32(uint32_t v) { return __builtin_bswap32(v); }
#define HAVE_BSWAP_32 1
#elif defined(__GNUC__) && (defined __i386 || defined(__x86_64__))
static __inline uint32_t bswap_32(uint32_t v) { __asm__("bswap %0" : "=r" (v) : "0" (v) : "cc"); return v; }
#define HAVE_BSWAP_32 1
#elif defined(__GNUC__) && (defined(__mc68000__) && !defined(__mcoldfire__))
static __inline uint32_t bswap_32(uint32_t x)
{
	__asm__("rorw #8,%0\n\tswap %0\n\trorw #8,%0" : "=d" (x) :  "0" (x) : "cc");
	return x;
}
#define HAVE_BSWAP_32 1
#elif defined(__PUREC__) && (defined(__mc68000__) && !defined(__mcoldfire__) && !defined(__AHCC__))
static __inline uint32_t __bswap_32_0(uint32_t x) 0xe058; /* ror.w d0 */
static __inline uint32_t __bswap_32_1(uint32_t x) 0x4840; /* swap d0 */
static __inline uint32_t __bswap_32_2(uint32_t x) 0xe058; /* ror.w d0 */
#define bswap_32(v) __bswap_32_2(__bswap_32_1(__bswap_32_0(v)))
#define HAVE_BSWAP_32 1
#endif
#endif

#ifndef HAVE_BSWAP_32
static __inline uint32_t bswap_32(uint32_t v)
{
   return (((v >> 24) & 0xffu) | ((v >> 8) & 0xff00u) | ((v & 0xffu) << 24) | ((v & 0xff00u) << 8));
}
#endif

#ifndef HAVE_BSWAP_16
#undef bswap_16
#if defined HAVE___BUILTIN_BSWAP16
static __inline uint16_t bswap_16(uint16_t v) { return __builtin_bswap16(v); }
#define HAVE_BSWAP_16 1
#elif defined(__GNUC__) && (defined(__mc68000__) && !defined(__mcoldfire__))
static __inline__ uint16_t bswap_16(uint16_t x)
{
	__asm__("rorw #8,%0" : "=d" (x) :  "0" (x) : "cc");
	return x;
}
#define HAVE_BSWAP_16 1
#elif defined(__PUREC__) && (defined(__mc68000__) && !defined(__mcoldfire__) && !defined(__AHCC__))
static __inline uint16_t bswap_16(uint16_t x) 0xe058; /* ror.w d0 */
#define HAVE_BSWAP_16 1
#elif defined HAVE___BUILTIN_BSWAP32
static __inline uint16_t bswap_16(uint16_t v) { return __builtin_bswap32((uint32_t)v << 16); }
#define HAVE_BSWAP_16 1
#elif defined(__GNUC__) && (defined __i386 || defined(__x86_64__))
static __inline uint16_t bswap_16(uint16_t v) { uint32_t r=v; __asm__ ("bswapl %0" : "=&r" (r) : "0" (r << 16) : "cc"); return r; }
#define HAVE_BSWAP_16 1
#endif
#endif

#ifndef HAVE_BSWAP_16
static __inline uint16_t bswap_16(uint16_t v)
{
    return ((((v) >> 8) & 0xffu) | (((v) & 0xffu) << 8));
}
#endif


#ifndef HOST_BYTE_ORDER
#  error "host byte order unknown"
#else
#  if HOST_BYTE_ORDER == BYTE_ORDER_BIG_ENDIAN
#    define cpu_to_be32(x) x
#    define be32_to_cpu(x) x
#    define cpu_to_be16(x) x
#    define be16_to_cpu(x) x
#  elif HOST_BYTE_ORDER == BYTE_ORDER_LITTLE_ENDIAN
#    define cpu_to_be32(x) bswap_32(x)
#    define be32_to_cpu(x) bswap_32(x)
#    define cpu_to_be16(x) bswap_16(x)
#    define be16_to_cpu(x) bswap_16(x)
#  endif
#endif


#ifdef __cplusplus
}
#endif

#endif /* __S_ENDIAN_H__ */
