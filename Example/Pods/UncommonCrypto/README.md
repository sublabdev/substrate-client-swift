# UncommonCrypto.swift

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](LICENSE)
[![Build Status](https://github.com/tesseract-one/UncommonCrypto.swift/workflows/Build%20&%20Tests/badge.svg?branch=main)](https://github.com/tesseract-one/UncommonCrypto.swift/actions/workflows/build.yml?query=branch%3Amain)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/UncommonCrypto.swift.svg)](https://github.com/tesseract-one/UncommonCrypto.swift/releases)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods version](https://img.shields.io/cocoapods/v/UncommonCrypto.swift.svg)](https://cocoapods.org/pods/UncommonCrypto)
![Platform macOS | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

Wrapper over CommonCrypto with alternative C implementation for Linux.

Alternative C implementations copied from [trezor-crypto repository](https://github.com/trezor/trezor-crypto).

## Installation

UncommonCrypto.swift deploys to macOS, iOS, tvOS, watchOS and Linux. It has been tested on the latest OS releases only however, as the module uses very few platform-provided APIs, there should be very few issues with earlier versions.

UncommonCrypto.swift can be ported to more platforms. If OS has built-in crypto APIs they can be used instead of provided C versions. On Apple plaforms library uses CommonCrypto framework. Secure random generator should be ported too.

Setup instructions:

- **Swift Package Manager:**
  Add this to the dependency section of your `Package.swift` manifest:

    ```Swift
    .package(url: "https://github.com/tesseract-one/UncommonCrypto.swift.git", from: "0.1.0")
    ```

- **CocoaPods:** Put this in your `Podfile`:

    ```Ruby
    pod 'UncommonCrypto', '~> 0.1'
    ```

## Usage Examples

### SHA1
```Swift
import UncommonCrypto

// Some data
let data = Data()

// Simple call API
let hash1 = SHA1.hash(data: data)

// Streaming api
var sha1 = SHA1()
sha1.update(data)
let hash2 = sha1.finalize()

assert(hash1 == hash2)
```

### SHA2
```Swift
import UncommonCrypto

// Some data
let data = Data()

// Simple call API. SHA256 and SHA512 are supported
let hash1 = SHA2.hash(type: .sha256, data: data)

// Streaming api
var sha2 = SHA2(type: .sha256)
sha2.update(data)
let hash2 = sha2.finalize()

assert(hash1 == hash2)
```

### SHA3
```Swift
import UncommonCrypto

// Some data
let data = Data()

// Simple call API. Different Keccak and SHA3 variants supported.
let hash1 = SHA3.hash(type: .sha256, data: data)

// Streaming api
var sha3 = SHA3(type: .sha256)
sha3.update(data)
let hash2 = sha3.finalize()

assert(hash1 == hash2)
```

### HMAC
```Swift
import UncommonCrypto

// Some data
let data = Data()

// Some key
let key = [UInt8]()

// Simple call API. SHA256 and SHA512 are supported
let sign1 = HMAC.authenticate(type: .sha256, key: key, data: data)

// Streaming api
var hmac = HMAC(type: .sha256, key: key)
hmac.update(data)
let sign2 = hmac.finalize()

assert(sign1 == sign2)
```

### PBKDF2
```Swift
import UncommonCrypto

let salt = [UInt8]()
let password = [UInt8]()

// SHA512 or SHA256 HMAC can be used
let derived = try! PBKDF2.derive(type: .sha512, password: password, salt: salt) 

print("Derived: ", derived)
```

## License

UncommonCrypto.swift can be used, distributed and modified under [the Apache 2.0 license](LICENSE).

