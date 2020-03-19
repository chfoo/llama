package llama;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Bytes;

class Llama {
    /**
     * Simplified interface for encoding objects to MsgPack format.
     *
     * @see `Encoder` for full encoder interface.
     */
    public static function encode(value:Any):Bytes {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        encoder.encode(value);
        return output.getBytes();
    }

    /**
     * Simplified interface for decoding MsgPack format.
     *
     * @see `Decoder` for full decoder interface.
     */
    public static function decode(data:Bytes):Any {
        final input = new BytesInput(data);
        final decoder = new Decoder(input);
        return decoder.decode();
    }
}
