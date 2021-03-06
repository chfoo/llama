package llama.test;

import llama.util.MapType;
import haxe.Constraints.IMap;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import llama.util.AnonStructMap;
import utest.Assert;
import utest.Test;

@:nullSafety(Off)
class TestDecoder extends Test {
    static final STRING_INT_MAP = "81a16101";
    static final INT_STRING_MAP = "8101a161";

    public function testData() {
        for (testItem in TestData.testItems) {
            if (testItem.section == "50.timestamp.yaml") {
                continue;
            }

            for (bytes in testItem.encoded) {
                final decoder = new Decoder(new BytesInput(bytes));
                decoder.mapFactory = () -> {};

                AssertUtil.equalsAny(
                    testItem.decoded, decoder.decode()
                );
            }
        }
    }

    function stringIntMapDecode(?mapFactory:Void->MapType):Any {
        final bytes = Bytes.ofHex(STRING_INT_MAP);
        final decoder = new Decoder(new BytesInput(bytes));

        if (mapFactory != null) {
            decoder.mapFactory = mapFactory;
        }

        return decoder.decode();
    }

    function validateDecodedStringIntMap(map:IMap<Any,Any>) {
        Assert.isTrue(map.exists("a"));
        Assert.equals(1, map.get("a"));
    }

    function validateDecodedStringIntMap_StringAny(map:IMap<String,Any>) {
        Assert.isTrue(map.exists("a"));
        Assert.equals(1, map.get("a"));
    }

    function intStringMapDecode(?mapFactory:Void->MapType):Any {
        final bytes = Bytes.ofHex(INT_STRING_MAP);
        final decoder = new Decoder(new BytesInput(bytes));

        if (mapFactory != null) {
            decoder.mapFactory = mapFactory;
        }

        return decoder.decode();
    }

    function validateDecodedIntStringMap(map:IMap<Any,Any>) {
        Assert.isTrue(map.exists(1));
        Assert.equals("a", map.get(1));
    }

    function validateDecodedIntStringMap_IntAny(map:IMap<Int,Any>) {
        Assert.isTrue(map.exists(1));
        Assert.equals("a", map.get(1));
    }

    public function testDecodeDefaultMap() {
        validateDecodedStringIntMap(stringIntMapDecode());
        validateDecodedIntStringMap(intStringMapDecode());
    }

    public function testDecodeStruct() {
        final anonStruct = stringIntMapDecode(() -> {});
        validateDecodedStringIntMap_StringAny(new AnonStructMap<Any>(anonStruct));
    }

    #if cs @Ignored("Not supported") #end
    public function testDecodeStringMap_StringInt() {
        final result = stringIntMapDecode(() -> new StringMap<Int>());
        validateDecodedStringIntMap(result);
    }

    public function testDecodeStringMap_StringAny() {
        final result = stringIntMapDecode(() -> new StringMap<Any>());
        validateDecodedStringIntMap_StringAny(result);
    }

    #if cs @Ignored("Not supported") #end
    public function testDecodeIntMap_IntString() {
        final result = intStringMapDecode(() -> new IntMap<String>());
        validateDecodedIntStringMap(result);
    }

    public function testDecodeIntMap_IntAny() {
        final result = intStringMapDecode(() -> new IntMap<Any>());
        validateDecodedIntStringMap_IntAny(result);
    }

    public function testTooBigMap() {
        final bytes = Bytes.ofHex("DF00000065"); // map with size 101
        final decoder = new Decoder(new BytesInput(bytes));
        decoder.maxMapSize = 100;
        Assert.raises(decoder.decode, Exception.DecodeError);
    }

    public function testTooBigArray() {
        final bytes = Bytes.ofHex("DD00000065"); // array with size 101
        final decoder = new Decoder(new BytesInput(bytes));
        decoder.maxArrayLength = 100;
        Assert.raises(decoder.decode, Exception.DecodeError);
    }

    public function testTooBigBytes() {
        final items = [
            "C600000065", // bin with size 101
            "DB00000065", // str
            "C900000065", // ext
        ];

        for (item in items) {
            final bytes = Bytes.ofHex(item);
            final decoder = new Decoder(new BytesInput(bytes));
            decoder.maxBytesLength = 100;
            Assert.raises(decoder.decode, Exception.DecodeError);
        }
    }

    public function testRecursionLimit() {
        final bytes = Bytes.ofHex("9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F"); // fix array 15
        final decoder = new Decoder(new BytesInput(bytes));
        decoder.maxRecursionDepth = 5;
        Assert.raises(decoder.decode, Exception.DecodeError);
    }
}
