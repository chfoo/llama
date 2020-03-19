package llama.test;

import haxe.io.BytesOutput;
import haxe.PosInfos;
import utest.Assert;
import utest.Test;

class TestEncoder extends Test {
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

    public function testEncodeStringMap() {
        final output = new BytesOutput();
        final encoder = new Encoder(output);
        final map:Map<String,Int> = [ "a" => 1 ];

        encoder.encode(map);

        final result = output.getBytes();

        Assert.equals("81a16101", result.toHex());
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
