# Sr25519.swift

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](LICENSE)
[![Build Status](https://github.com/tesseract-one/sr25519.swift/workflows/Build%20&%20Tests/badge.svg?branch=main)](https://github.com/tesseract-one/sr25519.swift/actions/workflows/build.yml?query=branch%3Amain)
[![GitHub release](https://img.shields.io/github/release/tesseract-one/sr25519.swift.svg)](https://github.com/tesseract-one/sr25519.swift/releases)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Sr25519.svg)](https://cocoapods.org/pods/Sr25519)
![Platform macOS | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

Swift wrapper for [shnorrkel](https://github.com/w3f/schnorrkel) [C library](https://github.com/TerenceGe/sr25519-donna).

## Installation

Sr25519.swift deploys to macOS, iOS, tvOS, watchOS and Linux. It has been tested on the latest OS releases only however, as the module uses very few platform-provided APIs, there should be very few issues with earlier versions.

Setup instructions:

- **Swift Package Manager:**
  Add this to the dependency section of your `Package.swift` manifest:

    ```Swift
    .package(url: "https://github.com/tesseract-one/Sr25519.swift.git", from: "0.1.0")
    ```

- **CocoaPods:** Put this in your `Podfile`:

    ```Ruby
    pod 'Sr25519', '~> 0.1'
    ```
  
- **CocoaPods with Ed25519:**
  
  If you want to build Ed25519 part from sources add this in your `Podfile`:
    ```Ruby
    pod 'Sr25519/Sr25519', '~> 0.1'
    pod 'Sr25519/Ed25519', '~> 0.1'
    ```

## Usage Examples

Following are some examples to demonstrate usage of the library.

### Sign and Validate with key pair

```Swift
import Sr25519

// Creating new KeyPair from random seed
let keypair = Sr25519KeyPair(seed: Sr25519Seed())
// Our message Data
let message = "Hello, World!".data(using: .utf8)!

// Signing
let signature = keypair.sign(message: message)
print("Signature:" signature)

// Validating signature
let valid = keypair.validate(message: message, signature: signature)
print("Is valid:", valid)
```

#### Validate with public key

```Swift
import Sr25519

// Creating PublicKey from Data
let pkey = try! Sr25519PublicKey(data: Data(repeating: 0, count: Sr25519PublicKey.size))
// Our message Data
let message = "Hello, World!".data(using: .utf8)!
// Signature
let signature = try! Sr25519Signature(data: Data(repeating: 0, count: Sr25519Signature.size))

// Validating
let valid = pkey.verify(message: message, signature: signature)
print("Is valid:", valid)
```

#### Key derivation

```Swift
import Sr25519

// Creating new KeyPair from random seed
let keypair = Sr25519KeyPair(seed: Sr25519Seed())
// It's PublicKey
let pkey = keypair.publicKey

// Creating ChainCode for derivation from Data
let chaincode = try! Sr25519ChainCode(code: Data(repeating: 0, count: Sr25519ChainCode.size))

// Derive
let derived = keypair.derive(chainCode: chaincode, hard: true)
print("Hard derived PublicKey", derived.publicKey)

// Also soft derivation can be performed on PrivateKey directly
let pderived = pkey.derive(chainCode: chaincode)
print("Soft derived PublicKey", pderived)
```

#### Verifiable random function

```Swift
import Sr25519

// Creating new KeyPair from random seed
let keypair = Sr25519KeyPair(seed: Sr25519Seed())
// Our message Data
let message = "Hello, World!".data(using: .utf8)!

// Default 0xFF filled threshold
let limit = Sr25519VrfThreshold()

// Signing
let (signature, isLess) = try! keypair.vrfSign(message: message, ifLessThan: limit)
print("Signature:", signature, "is less:", isLess)

// Verification
let valid = keypair.vrfVerify(message: message, signature: signature, threshold: limit)
print("Is valid:", valid)
```

## License

Sr25519.swift can be used, distributed and modified under [the Apache 2.0 license](LICENSE).
