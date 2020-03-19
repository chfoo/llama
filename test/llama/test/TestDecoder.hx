package llama.test;

import haxe.DynamicAccess;
import haxe.ds.StringMap;
import haxe.Constraints.IMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.PosInfos;
import utest.Assert;
import utest.Test;

@:nullSafety(Off)
class TestDecoder extends Test {
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

    public function testDecodeIMap() {
        final bytes = Bytes.ofHex("81a16101");
        final decoder = new Decoder(new BytesInput(bytes));
        final result = decoder.decode();

        Assert.is(result, IMap);
        final map = cast(result,IMap<Dynamic,Dynamic>);
        Assert.isTrue(map.exists("a"));
        Assert.equals(1, map.get("a"));
    }

    public function testDecodeStringMap() {
        final bytes = Bytes.ofHex("81a16101");
        final decoder = new Decoder(new BytesInput(bytes));
        decoder.mapFactory = () -> new StringMap<Any>();
        final result = decoder.decode();

        Assert.is(result, IMap);
        final map = cast(result,IMap<Dynamic,Dynamic>);
        Assert.isTrue(map.exists("a"));
        Assert.equals(1, map.get("a"));
    }

    public function testDecodeStruct() {
        final bytes = Bytes.ofHex("81a16101");
        final decoder = new Decoder(new BytesInput(bytes));
        decoder.mapFactory = () -> {};
        final result = decoder.decode();

        Assert.isTrue(Reflect.isObject(result));
        final map:DynamicAccess<Any> = result;
        Assert.isTrue(map.exists("a"));
        Assert.equals(1, map.get("a"));
    }
}
