package llama.test;

import haxe.ds.GenericStack;
import haxe.io.Bytes;
import haxe.ds.StringMap;
import haxe.Int64;
import llama.util.TypeUtil;
import llama.util.EncoderDataType;
import utest.Assert;
import utest.Test;


private class MyExtension implements Extension {
    public function new() {}

    public function extensionType():Int {
        return 1;
    }
    public function extensionData():Bytes {
        return Bytes.alloc(1);
    }
}

class TestTypes extends Test {
    public function testTypeUtil() {
        Assert.equals(EncoderDataType.TNull, TypeUtil.typeOf(null));
        Assert.equals(EncoderDataType.TBool, TypeUtil.typeOf(false));
        Assert.equals(EncoderDataType.TBool, TypeUtil.typeOf(true));
        Assert.equals(EncoderDataType.TInt, TypeUtil.typeOf(2147483647));
        Assert.equals(EncoderDataType.TInt, TypeUtil.typeOf(-2147483648));
        Assert.equals(EncoderDataType.TInt64, TypeUtil.typeOf(Int64.make(1, 0)));
        Assert.equals(EncoderDataType.TFloat, TypeUtil.typeOf(2147483647.1));
        Assert.equals(EncoderDataType.TString, TypeUtil.typeOf("abc"));
        Assert.equals(EncoderDataType.TAnonStruct, TypeUtil.typeOf({a: 1}));
        Assert.equals(EncoderDataType.TMap, TypeUtil.typeOf(new StringMap<Int>()));
        Assert.equals(EncoderDataType.TArray, TypeUtil.typeOf([123]));
        Assert.equals(EncoderDataType.TBytes, TypeUtil.typeOf(Bytes.alloc(1)));
        Assert.equals(EncoderDataType.TExtension, TypeUtil.typeOf(new MyExtension()));
        Assert.equals(EncoderDataType.TUnknown, TypeUtil.typeOf(new GenericStack<Int>()));
    }
}
