#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "hmac.h"
#import "options.h"
#import "pbkdf2.h"
#import "sha2.h"
#import "sha3.h"

FOUNDATION_EXPORT double UncommonCryptoVersionNumber;
FOUNDATION_EXPORT const unsigned char UncommonCryptoVersionString[];

