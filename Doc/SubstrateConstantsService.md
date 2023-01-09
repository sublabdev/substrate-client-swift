### SubstrateConstantsService example

Bellow is provided an example of how `SubstrateConstantsService` can be used to get runtime module
constant and/or it's value bytes decoded to a specified generic type `T` conforming to `Codable`.

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

```Swift
let client = SubstrateClient(url: url, settings: SubstrateClientSettings.default(clientQueue: DispatchQueue(label: "Some queue"))
```

The client has a property called `module` from where we can get access to an interface for getting
`RuntimeMetadata` and fetching `StorageItems`.

Next we need to get `SubstrateConstantsService`. To do that we can call
`constantsService(completion:)` method on the client. It will return a ready service to be used:

```Swift
client.constantsService { constantService in
    // Do something with the service
}
```
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
we should call `fetch(moduleName:constantName:completion:)` method on `SubstrateConstantsService`.
This method finds a runtime module constant by the constant's name in a specified module
and in its completion it returns the module's value bytes decoded into a specified type.

```Swift
try constantService.fetch(
            moduleName: constant.module,
            constantName: constant.constant
        ) { (storageItem: T?) in
          // Do something with the storage item
        }
```

Also, it's possible to get `RuntimeModuleConstant` object itself, to access
it's other properties.

```Swift
try constantService.find(
            moduleName: constant.module,
            constantName: constant.constant
        ) { runtimeModuleConstant in
          // Do something with the runtime module constant
        }
```

After that, the module constant can be used to get a decoded object of a
generic type `T` from it's `valueBytes` property.

```Swift
let fetchedValue = try service.fetch(T.self, constant: runtimeModuleConstant)
```