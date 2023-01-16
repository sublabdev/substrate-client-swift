### SubstrateExtrinsicsService example

Bellow is provided an example of how `SubstrateExtrinsicsService` can be used to get extrinsics.

## Initialization

First of all, we need to create the client. `SubstrateClient`'s initializer takes two parameters.
The first one is the required `URL`, and the second one is settings. It helps to define how the
data should be fetched and how it should be handled after that and on which dispatch queue
the results should be returned. It has a static func `default()`
which provides the settings with a default configuration. In this case the main
thread is used. There is another method called `default(clientQueue:)` where a custom
queue can be created. The settings parameter in`SubstrateClient`'s
initializer is predefined and set to default.

Here is how one could create a client:

```Swift
guard let url = URL(string: network.endpointInfo.url) else { return nil }
let client = SubstrateClient(url: url)
```

or

```
let client = SubstrateClient(url: url, settings: SubstrateClientSettings.default(clientQueue: DispatchQueue(label: "Some queue"))
```

## Usage

Now when we have the client, we can get the extrinsics service.

```Swift
client.extrinsicsService { [weak self] extrinsicsService in
        // Do something with the extrinsics service
    }
```

After getting the extrinsics service, we can get an unsigned extrinsic itself.

```Swift
extrinsicsService.makeUnsigned(
                moduleName: "moduleName",
                callName: "callName",
                callValue: T
            ) { unsigned in
                // Do something with the unsigned extrinsic
            }
```

The method takes a module name and a call name as `String`s and a call value
of a generic type `T` conforming to `Codable`. The last parameter of the method
is a completion closure with an unsigned extrinsic on our specified queue on
the client above.
