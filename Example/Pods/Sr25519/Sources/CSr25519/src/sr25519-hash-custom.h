/*
    a custom hash must have a 512bit digest and implement:

    struct sr25519_hash_context;

    void sr25519_hash_init(sr25519_hash_context *ctx);
    void sr25519_hash_update(sr25519_hash_context *ctx, const uint8_t *in, size_t inlen);
    void sr25519_hash_final(sr25519_hash_context *ctx, uint8_t *hash);
    void sr25519_hash(uint8_t *hash, const uint8_t *in, size_t inlen);
*/

#if __has_include(<CUncommonCrypto/sha2.h>)
#include <CUncommonCrypto/sha2.h>
#elif __has_include(<UncommonCrypto/sha2.h>)
#include <UncommonCrypto/sha2.h>
#else
#include <sha2.h>
#endif

typedef SHA512_CTX sr25519_hash_context;

static void
sr25519_hash_init(sr25519_hash_context *ctx) {
    sha512_Init(ctx);
}

static void
sr25519_hash_update(sr25519_hash_context *ctx, const uint8_t *in, size_t inlen) {
    sha512_Update(ctx, in, inlen);
}

static void
sr25519_hash_final(sr25519_hash_context *ctx, uint8_t *hash) {
    sha512_Final(ctx, hash);
}

static void
sr25519_hash(uint8_t *hash, const uint8_t *in, size_t inlen) {
    sha512_Raw(in, inlen, hash);
}
