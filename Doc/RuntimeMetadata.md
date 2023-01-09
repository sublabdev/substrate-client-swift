### RuntimeMetadata example

Bellow is provided an example of how RPC client can be used to fetch runtime metadata.

*NOTE:* `CommonSwift` library can be found [here](https://github.com/sublabdev/common-swift).
The `hex` extension for `String` is defined in `CommonSwift` library.
`ScaleCodecSwift` library can be found [here](https://github.com/sublabdev/scale-codec-swift). `ScaleCoder` is defined in `ScaleCodecSwift` library.

## Initialization

First of all, we need to create the client. `RpcClient`'s initializer takes two parameters. The
first one is the required `URL`, and the second one is a `URLSession` which is predefined and
can be omitted during the initialization (the `shared` session is used, by default).
Here is how the client can be created:
```Swift
guard let url = URL(string: "https://www.example.com") else { return }
let client = RpcClient(url: url)
```

## Usage

After getting the client, we can send requests. For that we will use the `client`'s `sendRequest` method.
It receives two parameters. The first one is the method for which we want to get a response, and the second one
is the completion with a generic optional `Result`, conforming to `Codable` or optional `RpcError`.
If we have a response, we try to get a metadata from it.

```Swift
client.sendRequest(method: method) { [weak self] (response: String?, error: RpcError?) in
    guard let string = response else { return }

        do {
          guard let hexData = string.hex.decode() else { return }

          let codec = ScaleCoder.defaultCoder()
          let runtimeMetadata = codec.decoder.decode(RuntimeMetadata.self, from: hexData)

          // Do something with the metadata
        } catch let error {
          // Do something with the error
    }
}
```

To get a metadata from the response first we try to decode the hex-encoded string (result from the request above).
After doing that we decode the decoded data to `RuntimeMetadata` object.
`RuntimeMetadata` holds all the necessary information for the metadata. It has a magic number,
version, runtime lookup, an array of runtime modules and a runtime extrinsic.
