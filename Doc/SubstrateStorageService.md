### SubstrateStorageService example

Bellow is provided an example of how `SubstrateStorageService` can be used to get a storage item.

## Initialization

First of all, we need to create the client. `SubstrateClient`'s initializer takes two parameters.
The first one is the required `URL`, and the second one is settings. It has a static func `default()`
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

After the client is created, we need to create a substrate storage service. It can be done
by calling `storageService(completion:)` method on the client. It's completion closure has
one parameter which ia `SubstrateStorageService` object.

```Swift
client.storageService { storageService in
}
```

## Usage

Now, when we have all the required components, we can start getting storage items. To do that
we should call `fetch(moduleName:itemName:keys:completion)` method on `SubstrateStorageService`.
This method's completion has either a response of optional generic type `T` which conforms to
`Codable` or an optional `RpcError`.

```Swift
let keysExample: [Data] = []
storageService.fetch(
            moduleName: "timestamp",
            itemName: "now",
            keys: keysExample
        ) { (response: T?, error: RpcError?) in
            // Do something with the response or with the error
        }
```

Also, it is possible to fetch the wrapper object (`FindStorageItemResult`) over
runtime module storage item and runtime module storage itself separately to have
a more control over the process.

```Swift
let result = try storageService.find(moduleName: "timestamp", itemName: "now")
```

And after that the fetching method can be called on the service using the data from
the `result` above

```Swift
guard let storage = result?.storage, let resultItem = result?.item else { return }
    do {
        try service.fetch(
            item: resultItem,
            keys: item.keys,
            storage: storage
            ) { (response: T?, error: RpcError?)  in
            // Do something with the response or with the error
        }
    }
```