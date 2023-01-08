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

#import "sr25519.h"
#import "sr25519-randombytes-custom.h"
#import "sr25519-randombytes-default.h"
#import "sr25519-randombytes.h"
#import "ed25519.h"

FOUNDATION_EXPORT double Sr25519VersionNumber;
FOUNDATION_EXPORT const unsigned char Sr25519VersionString[];

