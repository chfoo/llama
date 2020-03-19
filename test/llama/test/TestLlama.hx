package llama.test;

import utest.Assert;
import haxe.io.Bytes;
import utest.Test;

class TestLlama extends Test {
    @:nullSafety(Off)
    public function test() {
        final mixedMap = new AssociativeArray<Any,Any>();
        mixedMap.set(1, Bytes.ofString("hello world!"));
        mixedMap.set("a", ([123, "abc", 123.456, null, true, false]:Array<Dynamic>));

        final doc = new AssociativeArray<Any,Any>();
        doc.set("r", mixedMap);

        for (count in 0...10) {
            final encodedResult = Llama.encode(doc);
            final decodedResult = Llama.decode(encodedResult);

            Assert.same(doc, decodedResult);
        }
    }
}
