### WebSocketClient Example

Bellow is provided an example of `WebSocketClient`'s creation and usage. To create the client you need to provide a host's `URL`; optional port, path and required settings. The settings are of
type `WebSocketClientSettings`. The object contains a policy for web socket. Basically there are
three types of policies: `none`; `firstSubscriber` and `allSubscribers`. Here is what each of them means.

- `none` - No subscriber receives data
- `firstSubscriber` - Only the first subscriber receives data
- `allSubscribers` - All subscribers receive data

## Initialization

This is how `WebSocketClientSettings` is created:
```Swift
let settings = WebSocketClientSettings(policy: .none)
```

After creating settings now we can initialize the client.

```Swift
guard let exampleHost = URL(string: "ws://echo.ws.example") else { return }
let examplePort = 0000
let client = WebSocketClient(
            host: exampleHost,
            port: examplePort,
            settings: settings
        )
```

## Usage

Now that we have a ready client, we can send messages to it and subscribe for receiving the responses.

The messages can be sent via the client's `send` method. It takes two parameters. The first one is
the message to be sent which is of type `URLSessionWebSocketTask.Message`. The second parameter
is a completion with an optional error.

```Swift
client.sendMessage(.string(testMessage)) { error in
    guard error == nil else { return }
}
```
To subscribe to responses, one should call `subscribe` method on the client. This method
has one parameter called `subscription` which takes a closure with optional message received
of type `URLSessionWebSocketTask.Message`.

```Swift
client.subscribe { message in
    // Do something with the message
}
```

The closure will be called upon getting responses periodically for the subscribers that were signed
for those responses (or for a subscriber if the selected police is `.firstSubscriber`).

**Note:** That the closure will never be called if the selected police is `.none`.
