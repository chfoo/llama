package llama;

import llama.Exception.DecodeError;
import haxe.Exception;
import haxe.Constraints.IMap;
import haxe.DynamicAccess;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.Encoding;
import haxe.io.Input;
import llama.util.MapType;

/**
 * MsgPack format decoder.
 */
class Decoder {
    /**
     * Current Input instance.
     */
    public var input(default, null):Input;

    /**
     * Maximum number of keys in a map.
     *
     * If the decoder encounters a size too big, it will throw `DecodeError`.
     */
    public var maxMapSize:Int = 2147483647;

    /**
     * Maximum number of elements in an array.
     *
     * If the decoder encounters a size too big, it will throw `DecodeError`.
     */
    public var maxArrayLength:Int = 2147483647;

    /**
     * Maximum length of `Bytes` object.
     *
     * If the decoder encounters a size too big, it will throw `DecodeError`.
     */
    public var maxBytesLength:Int = 2147483647;

    /**
     * Maximum recursive depth of the decoder.
     *
     * If the decoder recurses beyond the specified depth, it will throw `DecodeError`.
     */
    public var maxRecursionDepth = 2147483647;

    var currentRecursionDepth = 0;

    /**
     * @param input Encoded MsgPack data to be decoded.
     * Property `bigEndian` will be set true.
     */
    public function new(input:Input) {
        this.input = input;
        input.bigEndian = true;
    }

    /**
     * Reset the decoder for reuse.
     */
    public function reset(input:Input) {
        this.input = input;
        input.bigEndian = true;
    }

    /**
     * A callback that will be called whenever an extension type is encountered.
     */
    public dynamic function extensionDecoder(decoder:Decoder, extension:Extension):Any {
        return extension;
    }

    /**
     * A callback that will be called to create a map instance whenever a map
     * needs to be decoded.
     *
     * The default map is `AssociativeArray`.
     */
    public dynamic function mapFactory():MapType {
        return new AssociativeArray<Any,Any>();
    }

    /**
     * A callback that will be called when the decoder encounters an unknown
     * format byte.
     */
    public dynamic function customDecoder(decoder:Decoder, formatByte:Int):Any {
        throw new Exception.DecodeError('format $formatByte not supported');
    }

    /**
     * Recursive decode and return the object.
     */
    public function decode():Any {
         // the individual decoder functions are based on msgpack-javascript

        currentRecursionDepth += 1;

        if (currentRecursionDepth >= maxRecursionDepth) {
            throw new Exception.DecodeError("maximum recursion depth");
        }

        final formatByte = input.readByte();
        var object:Null<Any>;

        if (formatByte >= 0xe0) {
            object = decodeNegativeFixint(formatByte);
        } else if (formatByte < 0xc0) {
            if (formatByte < 0x80) {
                object = decodePositiveFixint(formatByte);
            } else if (formatByte < 0x90) {
                object = decodeFixmap(formatByte);
            } else if (formatByte <  0xa0) {
                object = decodeFixarray(formatByte);
            } else {
                object = decodeFixstring(formatByte);
            }
        } else {
            switch (formatByte:FormatByte) {
                case Nil:
                    object = null;
                case False:
                    object = false;
                case True:
                    object = true;
                case Float32:
                    object = input.readFloat();
                case Float64:
                    object = input.readDouble();
                case Uint8:
                    object = input.readByte();
                case Uint16:
                    object = input.readUInt16();
                case Uint32:
                    object = decodeUint32();
                case Uint64:
                    object = decodeInt64();
                case Int8:
                    object = input.readInt8();
                case Int16:
                    object = input.readInt16();
                case Int32:
                    object = input.readInt32();
                case Int64:
                    object = decodeInt64();
                case Str8:
                    object = decodeString(input.readByte());
                case Str16:
                    object = decodeString(input.readUInt16());
                case Str32:
                    object = decodeString(input.readInt32());
                case Array16:
                    object = decodeArray(input.readUInt16());
                case Array32:
                    object = decodeArray(input.readInt32());
                case Map16:
                    object = decodeMap(input.readUInt16());
                case Map32:
                    object = decodeMap(input.readInt32());
                case Bin8:
                    object = decodeBin(input.readByte());
                case Bin16:
                    object = decodeBin(input.readUInt16());
                case Bin32:
                    object = decodeBin(input.readInt32());
                case Fixext1:
                    object = processExtension(decodeExt(1));
                case Fixext2:
                    object = processExtension(decodeExt(2));
                case Fixext4:
                    object = processExtension(decodeExt(4));
                case Fixext8:
                    object = processExtension(decodeExt(8));
                case Fixext16:
                    object = processExtension(decodeExt(16));
                case Ext8:
                    object = processExtension(decodeExt(input.readByte()));
                case Ext16:
                    object = processExtension(decodeExt(input.readUInt16()));
                case Ext32:
                    object = processExtension(decodeExt(input.readInt32()));
                case NeverUsed:
                    throw new Exception.DecodeError("found never used byte");
                default:
                    object = customDecoder(this, formatByte);
            }
        }

        currentRecursionDepth -= 1;

        return object;
    }

    #if (!llama_no_inline) inline #end
    public function decodeNegativeFixint(value:Int):Int {
        return value - 0x100;
    }

    #if (!llama_no_inline) inline #end
    public function decodePositiveFixint(value:Int):Int {
        return value;
    }

    #if (!llama_no_inline) inline #end
    public function decodeFixmap(value:Int):Any {
        final mapSize = value - 0x80;
        return decodeMap(mapSize);
    }

    #if (!llama_no_inline) inline #end
    public function decodeUint32():Any {
        final value = input.readInt32();

        if (value >= 0) {
             return value;
        } else {
            return Int64.make(0, value);
        }
    }

    #if (!llama_no_inline) inline #end
    public function decodeInt64():Any {
        final int64 = Int64.make(input.readInt32(), input.readInt32());

        if (int64.high != int64.low >> 31) {
            return int64;
        } else {
            return int64.low;
        }
    }

    public function decodeMap(mapSize:Int):Any {
        if (mapSize < 0 || mapSize > maxMapSize) {
            throw new Exception.DecodeError("map size too big");
        }

        final mapType = mapFactory();

        if (Std.isOfType(mapType, IMap)) {
            #if (cs || llama_checked_map_cast)
            checkedDecodeMap(mapSize, mapType);
            #else
            final map:IMap<Any,Any> = mapType;

            for (index in 0...mapSize) {
                final key = decode();
                final value = decode();
                map.set(key, value);
            }
            #end
        } else {
            final anonStruct:DynamicAccess<Any> = cast mapType;
            for (index in 0...mapSize) {
                final key = decode();
                final value = decode();
                anonStruct.set(key, value);
            }
        }

        return mapType;
    }

    function checkedDecodeMap(mapSize:Int, mapType:Any) {
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

                for (index in 0...mapSize) {
                    final key = decode();
                    final value = decode();
                    intMap.set(key, value);
                }

                return;
            }

            for (index in 0...mapSize) {
                final key = decode();
                final value = decode();
                stringMap.set(key, value);
            }

            return;
        }

        for (index in 0...mapSize) {
            final key = decode();
            final value = decode();
            map.set(key, value);
        }
    }

    #if (!llama_no_inline) inline #end
    public function decodeFixarray(value:Int):Array<Any> {
        final arrayLength = value - 0x90;
        return decodeArray(arrayLength);
    }

    public function decodeArray(arrayLength:Int):Array<Any> {
        if (arrayLength < 0 || arrayLength > maxArrayLength) {
            throw new Exception.DecodeError("array length too big");
        }

        final array:Array<Any> = [];
        @:nullSafety(Off) array.resize(arrayLength);

        for (index in 0...arrayLength) {
            array[index] = decode();
        }

        return array;
    }

    #if (!llama_no_inline) inline #end
    public function decodeFixstring(value:Int):String {
        final byteLength = value - 0xa0;
        return decodeString(byteLength);
    }

    #if (!llama_no_inline) inline #end
    public function decodeString(byteLength:Int):String {
        if (byteLength < 0 || byteLength > maxBytesLength) {
            throw new Exception.DecodeError("byte length too big");
        }

        return input.readString(byteLength, Encoding.UTF8);
    }

    #if (!llama_no_inline) inline #end
    public function decodeBin(byteLength:Int):Bytes {
        if (byteLength < 0 || byteLength > maxBytesLength) {
            throw new Exception.DecodeError("byte length too big");
        }

        return input.read(byteLength);
    }

    #if (!llama_no_inline) inline #end
    public function decodeExt(byteLength:Int):Extension {
        if (byteLength < 0 || byteLength > maxBytesLength) {
            throw new Exception.DecodeError("byte length too big");
        }

        return new ExtensionImpl(
            input.readInt8(),
            input.read(byteLength)
        );
    }

    #if (!llama_no_inline) inline #end
    function processExtension(object:Extension):Any {
        return extensionDecoder(this, object);
    }
}


private class ExtensionImpl implements Extension {
    final type:Int;
    final data:Bytes;

    public function new(type:Int, data:Bytes) {
        this.type = type;
        this.data = data;
    }

    public function extensionType():Int {
        return type;
    }

    public function extensionData():Bytes {
        return data;
    }
}
