package llama;

import haxe.Constraints.IMap;
import haxe.DynamicAccess;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.Encoding;
import haxe.io.FPHelper;
import haxe.io.Output;
import llama.util.TypeUtil;

/**
 * MsgPack format encoder.
 */
class Encoder {
    /**
     * Current output instance.
     */
    public var output(default, null):Output;

    /**
     * Whether to check if Float can fit within 32-bits.
     *
     * Set to false to reduce a few CPU cycles at the cost of slightly larger
     * output size.
     */
    public var compactFloat:Bool = true;

    /**
     * @param output Instance to write the encoded MsgPack data.
     * Property `bigEndian` will be set true.
     */
    public function new(output:Output) {
        this.output = output;
        output.bigEndian = true;
    }

    /**
     * Reset the encoder for reuse.
     */
    public function reset(output:Output) {
        this.output = output;
        output.bigEndian = true;
    }

    /**
     * A callback which will be called when an object cannot be encoded by
     * the encoder itself.
     */
    public dynamic function customEncoder(encoder:Encoder, object:Any) {
        throw new Exception.EncodeError('Unsupported value $object for encoding.');
    }

    /**
     * Recursively encode the given object.
     */
    public function encode(value:Any) {
        // the individual encoder functions are based on msgpack-javascript

        switch TypeUtil.typeOf(value) {
            case TNull: encodeNull();
            case TInt: encodeInt(value);
            case TInt64: encodeInt64(value);
            case TFloat: encodeFloat(value);
            case TBool: encodeBool(value);
            case TAnonStruct: @:nullSafety(Off) encodeAnonStruct(value);
            case TExtension:
                final extension:Extension = cast value;
                encodeExtension(extension.extensionType(), extension.extensionData());
            case TMap:
                #if (cs || llama_checked_map_cast)
                checkedMapEncode(value);
                #else
                encodeMap(value);
                #end
            case TString: encodeString(value);
            case TBytes: encodeBytes(value);
            case TArray: encodeArray(value);
            case TUnknown: customEncoder(this, value);
        }
    }

    #if (!llama_no_inline) inline #end
    public function encodeNull() {
        output.writeByte(FormatByte.Nil);
    }

    #if (!llama_no_inline) inline #end
    public function encodeBool(value:Bool) {
        if (value) {
            output.writeByte(FormatByte.True);
        } else {
            output.writeByte(FormatByte.False);
        }
    }

    public function encodeInt(value:Int) {
        if (value >= 0) {
            if (value < 0x80) {
                output.writeByte(value);
            } else if (value < 0x100) {
                output.writeByte(FormatByte.Uint8);
                output.writeByte(value);
            } else if (value < 0x10000) {
                output.writeByte(FormatByte.Uint16);
                output.writeUInt16(value);
            } else {
                output.writeByte(FormatByte.Uint32);
                output.writeInt32(value);
            }
        } else {
            if (value >= -0x20) {
                output.writeByte(VariableFormatByte.NegativeFixint | (value + 0x20));
            } else if (value >= -0x80) {
                output.writeByte(FormatByte.Int8);
                output.writeInt8(value);
            } else if (value >= -0x8000) {
                output.writeByte(FormatByte.Int16);
                output.writeInt16(value);
            } else {
                output.writeByte(FormatByte.Int32);
                output.writeInt32(value);
            }
        }
    }

    public function encodeInt64(value:Int64) {
        if (value.high == value.low >> 31) {
            return encodeInt(value.low);
        }

        if (value >= 0) {
            if (value < Int64.make(1, 0)) {
                output.writeByte(FormatByte.Uint32);
                output.writeInt32(value.low);
            } else {
                output.writeByte(FormatByte.Uint64);
                output.writeInt32(value.high);
                output.writeInt32(value.low);
            }
        } else {
            if (value >= Int64.make(-1, 0x80000000)) {
                output.writeByte(FormatByte.Int32);
                output.writeInt32(value.low);
            } else {
                output.writeByte(FormatByte.Int64);
                output.writeInt32(value.high);
                output.writeInt32(value.low);
            }
        }
    }

    #if (!llama_no_inline) inline #end
    public function encodeFloat(value:Float) {
        if (compactFloat && FPHelper.i32ToFloat(FPHelper.floatToI32(value)) == value) {
            output.writeByte(FormatByte.Float32);
            output.writeFloat(value);
        } else {
            output.writeByte(FormatByte.Float64);
            output.writeDouble(value);
        }
    }

    public function encodeString(value:String) {
        final utf8Bytes = Bytes.ofString(value, Encoding.UTF8);
        final byteLength = utf8Bytes.length;

        if (byteLength < 32) {
            output.writeByte(VariableFormatByte.Fixstr + byteLength);
        } else if (byteLength < 0x100) {
            output.writeByte(FormatByte.Str8);
            output.writeByte(byteLength);
        } else if (byteLength < 0x100) {
            output.writeByte(FormatByte.Str16);
            output.writeUInt16(byteLength);
        } else {
            output.writeByte(FormatByte.Str32);
            output.writeInt32(byteLength);
        }

        output.writeFullBytes(utf8Bytes, 0, byteLength);
    }

    public function encodeBytes(value:Bytes, pos:Int = 0, ?length:Int) {
        final byteLength = length != null ? length : value.length;

        if (byteLength < 0x100) {
            output.writeByte(FormatByte.Bin8);
            output.writeByte(byteLength);
        } else if (byteLength < 0x100) {
            output.writeByte(FormatByte.Bin16);
            output.writeUInt16(byteLength);
        } else {
            output.writeByte(FormatByte.Bin32);
            output.writeInt32(byteLength);
        }

        output.writeFullBytes(value, pos, byteLength);
    }

    public function encodeArray(value:Array<Any>) {
        final arrayLength = value.length;

        if (arrayLength < 16) {
            output.writeByte(VariableFormatByte.Fixarray + arrayLength);
        } else if (arrayLength < 0x10000) {
            output.writeByte(FormatByte.Array16);
            output.writeUInt16(arrayLength);
        } else {
            output.writeByte(FormatByte.Array32);
            output.writeInt32(arrayLength);
        }

        for (item in value) {
            encode(item);
        }
    }

    @:nullSafety(Off)
    #if (!llama_no_inline) inline #end
    public function encodeAnonStruct(doc:DynamicAccess<Any>) {
        final keys:Array<String> = [];
        final values:Array<Any> = [];

        for (key => value in doc) {
            keys.push(key);
            values.push(value);
        }

        encodeMapArrays(keys, values);
    }

    public function encodeMap<K,V>(map:IMap<K,V>) {
        final keys:Array<K> = [];
        final values:Array<V> = [];

        for (key => value in map) {
            keys.push(key);
            values.push(value);
        }

        encodeMapArrays(keys, values);
    }

    function checkedMapEncode(mapType:Any) {
        var map:IMap<Any,Any>;

        try {
            map = mapType;
        } catch (exception:Any) {
            var stringMap:IMap<String,Any>;

            try {
                stringMap = mapType;
            } catch (exception:Any) {
                var intMap:IMap<Int,Any>;

                intMap = mapType;

                final keys:Array<Int> = [];
                final values:Array<Any> = [];

                for (key => value in intMap) {
                    keys.push(key);
                    values.push(value);
                }

                encodeMapArrays(keys, values);

                return;
            }

            final keys:Array<String> = [];
            final values:Array<Any> = [];

            for (key => value in stringMap) {
                keys.push(key);
                values.push(value);
            }

            encodeMapArrays(keys, values);


            return;
        }

        final keys:Array<Any> = [];
        final values:Array<Any> = [];

        for (key => value in map) {
            keys.push(key);
            values.push(value);
        }

        encodeMapArrays(keys, values);

    }

    public function encodeMapArrays<K,V>(keys:Array<K>, values:Array<V>) {
        final mapSize = keys.length;

        if (mapSize < 0x20) {
            output.writeByte(VariableFormatByte.Fixmap + mapSize);
        } else if (mapSize < 0x10000) {
            output.writeByte(FormatByte.Map16);
            output.writeUInt16(mapSize);
        } else {
            output.writeByte(FormatByte.Map32);
            output.writeInt32(mapSize);
        }

        for (index in 0...mapSize) {
            encode(keys[index]);
            encode(values[index]);
        }
    }

    public function encodeExtension(type:Int, value:Bytes, pos:Int = 0, ?length:Int) {
        final byteLength = length != null ? length : value.length;

        if (byteLength == 1) {
            output.writeByte(FormatByte.Fixext1);
        } else if (byteLength == 2) {
            output.writeByte(FormatByte.Fixext2);
        } else if (byteLength == 4) {
            output.writeByte(FormatByte.Fixext4);
        } else if (byteLength == 8) {
            output.writeByte(FormatByte.Fixext8);
        } else if (byteLength == 16) {
            output.writeByte(FormatByte.Fixext16);
        } else if (byteLength < 0x100) {
            output.writeByte(FormatByte.Ext8);
            output.writeByte(byteLength);
        } else if (byteLength < 0x10000) {
            output.writeByte(FormatByte.Ext16);
            output.writeUInt16(byteLength);
        } else {
            output.writeByte(FormatByte.Ext32);
            output.writeInt32(byteLength);
        }

        output.writeInt8(type);
        output.writeFullBytes(value, pos, byteLength);
    }
}
