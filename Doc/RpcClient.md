### RpcClient Example

Bellow is provided an example of RPC client that handles sending requests using several different ways.

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

After creating the client, we can send requests. There are 2 ways to do that.

The first option is to use `RpcRequest` object. It's a wrapper object that encapsulates all the
necessary data for RPC requests. Here is how it looks like:

```Swift
struct RpcRequest<T: Codable>: Codable {
    var jsonrpc = "2.0"
    let id: Int64
    let method: String
    var params: T
}
```

As you can see, it has four properties. The first one is the `JSON RPC` version, which is
by default set to `2.0`. The second one is the request's `id`. The third one is the `method`
for which we want to get a response. The last one is a generic parameter called `params` which can
be any type conforming to `Codable`.

Also, there is an "empty" object `None` that conforms to `Codable` which can be used for cases
when there is no parameter is required for the request.

Here is how one could create the request:
```Swift
let method = "state_getMetadata"
let id: Int64 = 0
let request = RpcRequest(
            id: id,
            method: method,
            params: Nothing()
        )
```

After we have the `request`, we can send it using the `client`'s `send` method. It has two parameters
the first of which the `request` itself, and the second on is the completion with either the request's optional result or `RpcError`.
The result contains a response of type `RpcResponse`. It like the `request` has four parameters.

```Swift
struct RpcResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int64
    var result: T? = nil
    var error: RpcResponseError? = nil
}
```
The first one is the `JSON RPC` version. The second one is the response's `id`. The third on
is the `result` which is of a generic type, which conforms to `Codable`. And the last one
is an optional `RpcResponseError`.

Here is how the request is made by using `RpcRequest` object defined earlier.

```Swift
client.send(request) { (response: RpcResponse<String>?, error: RpcError?) in
    // Do something with the response or the error
 }
```

Another way of making a request is to use the `client`'s `sendRequest` method. It receives two
parameters. The first one is the method for which we want to get a response, and the second one
is the completion with a generic optional `Result`, conforming to `Codable` or optional `RpcError`.

```Swift
client.sendRequest(method: method) { (response: String?, error: RpcError?) in
    // Do something with the result or error
}
```

