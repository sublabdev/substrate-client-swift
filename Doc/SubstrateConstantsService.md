### SubstrateConstantsService example

Bellow is provided an example of how `SubstrateConstantsService` can be used to get runtime module
constant and/or it's value bytes decoded to a specified generic type `T` conforming to `Codable`.

## Initialization

First of all, we need to create the client. `SubstrateClient`'s initializer takes two parameters.
The first one is the required `URL`, and the second one is settings. It helps to define how the
data should be fetched and how it should be handled after that. It has a static func `default()`
which provides the settings with a default configuration. The settings parameter in
`SubstrateClient`'s initializer is predefined and set to default.

Here is how one could create a client:

```Swift
guard let url = URL(string: network.endpointInfo.url) else { return nil }
let client = SubstrateClient(url: url)
```

The client has a property called `module` from where we can get access to an interface for getting
`RuntimeMetadata` and fetching `StorageItems`.

Here we have two options of how to get `SubstrateConstantsService`. We can let the library give us one,
or create the service manually. If we want a ready one then we can call
`constantsService(completion:)` method on the client. It will return a ready service to be used:

```Swift
client.constantsService { constantService in
    // Do something with the service
}
```

If we want to create a substrate constants service manually, then we need to create
a substrate lookup service. It can be done by calling `lookupService(_ onUpdate:)`
method on the client. It takes one parameter which is a closure with `SubstrateLookupService` object.

```Swift
client.lookupService { lookupService in
}
```

When we have a `SubstrateLookupService` object, `SubstrateConstantsService` can be created which
is used to fetch runtime module constants:

```Swift
let constantService = SubstrateConstantsService(codec: ScaleCoder.defaultCoder(), lookup: lookupService)
```

The initializer of the service has two properties. The first one is `ScaleCoder`
(which can be found [here](https://github.com/sublabdev/scale-codec-swift)),
and the second one is the lookup service.

Before taking a look how to use the service, it's worth mentioning that runtime
module constant is defined by the following object:
```Swift
public class RuntimeModuleConstant: Codable {
    let name: String
    let type: BigUInt
    let valueBytes: [UInt8]
    let docs: [String]

    init(name: String, type: BigUInt, valueBytes: [UInt8], docs: [String]) {
        self.name = name
        self.type = type
        self.valueBytes = valueBytes
        self.docs = docs
    }
}
```
It's `valueBytes` property is decoded into a specified generic `T` type.

## Usage

Now, when we have all the required components, we can start getting the constants. To do that
we should call `fetch(moduleName:constantName:)` method on `SubstrateConstantsService`.
This method finds a runtime module constant by the constant's name in a specified module
and returns its value bytes decoded into a specified type.

```Swift
let storageItem: T? = try constantService.fetch(
            moduleName: constant.module,
            constantName: constant.constant
        )
```

Also, it's possible to get `RuntimeModuleConstant` object itself, to access
it's other properties.

```Swift
let runtimeModuleConstant = try constantService.find(
            moduleName: constant.module,
            constantName: constant.constant
        )
```

After that, the module constant can be used to get a decoded object of a
generic type `T` from it's `valueBytes` property.

```Swift
let fetchedValue = try service.fetch(T.self, constant: runtimeModuleConstant)
```