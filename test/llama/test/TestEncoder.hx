package llama.test;

import haxe.io.BytesOutput;
import haxe.PosInfos;
import utest.Assert;
import utest.Test;

class TestEncoder extends Test {
    static final STRING_INT_MAP = "81a16101";
    static final INT_STRING_MAP = "8101a161";

    public function testData() {
        for (testItem in TestData.testItems) {
            if (testItem.section == "50.timestamp.yaml") {
                continue;
            }

            final output = new BytesOutput();
            final encoder = new Encoder(output);
            encoder.encode(testItem.decoded);
            final result = output.getBytes();

            final candidates = [for (bytes in testItem.encoded) bytes.toHex()];

            Assert.contains(result.toHex(), candidates);

            if (candidates.indexOf(result.toHex()) < 0) {
                trace(testItem);
            }
        }
    }

    public function testEncodeDefaultMap() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:AssociativeArray<Any,Any> = new AssociativeArray();
        map.set("a", 1);

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals(STRING_INT_MAP, result.toHex());
    }

    #if cs @Ignored("Not supported") #end
    public function testEncodeStringMap_StringInt() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:Map<String,Int> = [ "a" => 1 ];

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals(STRING_INT_MAP, result.toHex());
    }

    public function testEncodeStringMap_StringAny() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:Map<String,Any> = [ "a" => 1 ];

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals(STRING_INT_MAP, result.toHex());
    }

    #if cs @Ignored("Not supported") #end
    public function testEncodeIntMap_IntString() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:Map<Int,String> = [ 1 => "a" ];

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals(INT_STRING_MAP, result.toHex());
    }

    public function testEncodeIntMap_IntAny() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:Map<Int,Any> = [ 1 => "a" ];

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals(INT_STRING_MAP, result.toHex());
    }

    public function testEncodeStruct() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map = { "a": 1 };

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals("81a16101", result.toHex());
    }
}
