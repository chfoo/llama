package llama;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Bytes;

/**
 * Simple interface to encoding/decoding MessagePack format.
 */
class Llama {
    static var encoder:Null<Encoder>;
    static var decoder:Null<Decoder>;

    /**
     * Encode the given object to MessagePack formatted bytes.
     *
     * @see `Encoder` for full encoder interface.
     */
    public static function encode(value:Any):Bytes {
        final output = new BytesOutput();

        if (encoder == null) {
            encoder = new Encoder(output);
        }
        encoder.reset(output);
        encoder.encode(value);
        return output.getBytes();
    }

    /**
     * Decode the MessagePack formatted bytes to an object.
     *
     * @see `Decoder` for full decoder interface.
     */
    public static function decode(data:Bytes):Any {
        final input = new BytesInput(data);

        if (decoder == null) {
            decoder = new Decoder(input);
        }
        decoder.reset(input);
        return decoder.decode();
    }
}
