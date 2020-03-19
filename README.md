# Llama: MessagePack library for Haxe

Llama is a MessagePack (MsgPack) encoder/decoder library for Haxe.

Llama is intended to be a modern alternative to the [msgpack-haxe](https://github.com/aaulia/msgpack-haxe) library with better reusability.

## Supported types

| MsgPack type | Haxe type |
|--------------|-----------|
| nil | null |
| false, true | bool |
| uint, int | Int, Int64 |
| float | Float |
| bin | Bytes |
| str | String |
| ext | llama.Extension |
| array | Array |
| map | IMap (llama.AssociativeArray), anon struct |

### Limits

* When encoding `Int`, the library assumes it holds a 32-bit value. It will be truncated otherwise.
* When decoding `uint 32`, the value will be promoted to `Int64` if it does not fit in `Int`.
* When decoding `uint 64`, the value will be interpreted as `Int64`.
* The maximum size of a map or length of an array is the upper limit of `Int` (2147483647).
* On targets without a integer data type, numbers will be encoded as 32-bit integers wherever possible.

### Supported targets

| Target | Supported? |
|--------|------------|
| JS | Yes |
| Lua | No. Error loading tests. |
| SWF | No. Cast error. |
| Neko | No. 31-bit integer limitation. |
| PHP | Yes |
| C++ (CPP) | Yes |
| C# (CS) | No. Cast error. |
| Java | Yes |
| Python | Yes |
| HashLink (HL) | Yes |

## Getting started

Requires Haxe 4.0+

Install it using haxelib:

        haxelib install llama

Or directly from Git repo:

        haxelib git llama https://github.com/chfoo/llama.git

### Simple interface

To quickly decode and encode, use the simplified interface:

```haxe
import llama.Llama;

final myData:Bytes = Llama.encode("hello world!");
final myDoc:String = Llama.decode(myData);
```

### Encoder and decoder interface

The advanced interface provides much better control on the decoding and encoding process.

#### Encoding

The encoder works on a `Output` instance such as `BytesOutput` or `FileOutput`:

```haxe
final output = new BytesOutput();
final encoder = new Encoder(output);

encoder.encode("hello world!");

final myData = output.getBytes();
```

If you have any custom types, you can provide a custom encoder callback:

```haxe
encoder.customEncoder = (encoder, object) -> {
    if (Std.is(object, MyCustomClass)) {
        encoder.encodeString(object.toString());
    }
};
```

If you have any extensions, the class can implement `Extension` which the encoder will use for serialization:

```haxe
class MyCustomExtension implements Extension {
    public function new() {}

    public function extensionType():Int {
        return 123;
    }

    public function extensionData():Bytes {
        return Bytes.ofString("hello world!");
    }
}

encoder.encode(new MyCustomExtension());
```

If there is any object that cannot be encoded, a `String` exception will be thrown.

#### Decoding

The decoder works on a `Input` instance such as `BytesInput` or `FileInput`:

```haxe
final input = new BytesInput(myData);
final decoder = new Decoder(input);

final object = decoder.decode();
```

If there is any decoding errors, a `String` exception will be thrown.

By default, `map` types are decoded to `AssociativeArray` implementing `IMap`. This class works with any type as the keys, but map operations are O(n) time which can be unsuitable for large maps. If you know the type of the map keys, you can provide a map factory to the decoder:

```haxe
// StringMap
decoder = new Decoder(input);
decoder.mapFactory = () -> new Map<String,Any>();

// IntMap
decoder = new Decoder(input);
decoder.mapFactory = () -> new Map<Int,Any>();

// anonymous structure
decoder = new Decoder(input);
decoder.mapFactory = () -> {};
```

To convert any extensions, you can provide a extension handler callback:

```haxe
decoder.extensionDecoder = (decoder, extension) {
    switch extension.extensionType()
        case 123:
            return MyCustomType(extension.extensionData());
        default:
            return extension;
    }
};
```

## Contributing

If you have any issues or fixes, please file a issue or pull request.

## License

See LICENSE file.
