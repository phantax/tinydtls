/* prng.h -- Pseudo Random Numbers
 *
 * Copyright (C) 2010--2012 Olaf Bergmann <bergmann@tzi.org>
 *
 * This file is part of the library tinydtls. Please see
 * README for terms of use. 
 */

/** 
 * @file prng.h
 * @brief Pseudo Random Numbers
 */

#ifndef _DTLS_PRNG_H_
#define _DTLS_PRNG_H_

#include "config.h"

/** 
 * @defgroup prng Pseudo Random Numbers
 * @{
 */

#ifndef WITH_CONTIKI
#include <stdlib.h>

/**
 * Fills \p buf with \p len random bytes. This is the default
 * implementation for prng().  You might want to change prng() to use
 * a better PRNG on your specific platform.
 */
static inline int
dtls_prng_impl(unsigned char *buf, size_t len) {
  while (len--)
    *buf++ = rand() & 0xFF;
  return 1;
}
#else /* WITH_CONTIKI */
#include <string.h>

#ifdef HAVE_PRNG
extern int contiki_prng_impl(unsigned char *buf, size_t len);
#else
/**
 * Fills \p buf with \p len random bytes. This is the default
 * implementation for prng().  You might want to change prng() to use
 * a better PRNG on your specific platform.
 */
static inline int
contiki_prng_impl(unsigned char *buf, size_t len) {
  unsigned short v = random_rand();
  while (len > sizeof(v)) {
    memcpy(buf, &v, sizeof(v));
    len -= sizeof(v);
    buf += sizeof(v);
    v = random_rand();
  }

  memcpy(buf, &v, len);
  return 1;
}
#endif /* HAVE_PRNG */

#define prng(Buf,Length) contiki_prng_impl((Buf), (Length))
#ifndef CONTIKI_TARGET_CC2538DK
#define prng_init(Value) random_init((unsigned short)(Value))
#else
#define prng_init(Value)
#endif
#endif /* WITH_CONTIKI */

#ifndef prng
/** 
 * Fills \p Buf with \p Length bytes of random data. 
 * 
 * @hideinitializer
 */
#define prng(Buf,Length) dtls_prng_impl((Buf), (Length))
#endif

#ifndef prng_init
/** 
 * Called to set the PRNG seed. You may want to re-define this to
 * allow for a better PRNG.
 *
 * @hideinitializer
 */
#define prng_init(Value) srand((unsigned long)(Value))
#endif

/** @} */

#endif /* _DTLS_PRNG_H_ */
