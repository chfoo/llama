package llama.test;

import haxe.Int64;
import utest.Assert;
import utest.Test;

@:nullSafety(Off)
class TestAssociativeArray extends Test {
    public function testSetRemove() {
        final map = new AssociativeArray<Int,String>();

        Assert.isFalse(map.exists(123));
        Assert.isNull(map.get(123));

        map.set(123, "hello world");

        Assert.isTrue(map.exists(123));
        Assert.equals("hello world", map.get(123));

        Assert.isFalse(map.exists(456));
        Assert.isNull(map.get(456));

        map.set(456, "abc");

        Assert.isTrue(map.exists(456));
        Assert.equals("abc", map.get(456));

        map.set(123, "def");
        Assert.equals("def", map.get(123));

        map.remove(123);
        map.remove(456);

        Assert.isFalse(map.exists(123));
        Assert.isFalse(map.exists(456));
    }

    public function testIterator() {
        final map = new AssociativeArray<Int,String>();

        map.set(1, "a");
        map.set(2, "b");
        map.set(3, "c");

        final keys = [for (key in map.keys()) key];
        final values = [for (key in map) key];
        final items = [for (key => value in map) {key: key, value: value}];

        Assert.same([1, 2, 3], keys);
        Assert.same(["a", "b", "c"], values);
        Assert.same([
            {key: 1, value: "a"},
            {key: 2, value: "b"},
            {key: 3, value: "c"}],
            items
        );
    }

    public function testInt64() {
        final map = new AssociativeArray<Int64,String>();

        Assert.isFalse(map.exists(Int64.make(123, 0)));
        Assert.isNull(map.get(Int64.make(123, 0)));

        map.set(Int64.make(123, 0), "hello world");

        Assert.isTrue(map.exists(Int64.make(123, 0)));
        Assert.equals("hello world", map.get(Int64.make(123, 0)));
    }
}
