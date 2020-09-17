package llama;

import haxe.Int64Helper;
import utest.Assert;
import haxe.Int64;
import haxe.PosInfos;

class AssertUtil {
    public static function equalsAny(expected:Any, value:Any, ?msg:String, ?pos:PosInfos) {
        if (Int64.isInt64(expected) || Int64.isInt64(value)) {
            var expectedI64:Int64;
            var valueI64:Int64;

            if (Int64.isInt64(expected)) {
                expectedI64 = cast expected;
            } else {
                expectedI64 = Int64Helper.fromFloat(expected);
            }
            if (Int64.isInt64(value)) {
                valueI64 = cast value;
            } else {
                valueI64 = Int64Helper.fromFloat(value);
            }

            Assert.isTrue(Int64.eq(expectedI64, valueI64), msg, pos);

        } else if (Std.isOfType(expected, Extension) && Std.isOfType(value, Extension)) {
            final expectedExt:Extension = cast expected;
            final valueExt:Extension = cast value;

            Assert.equals(expectedExt.extensionType(), valueExt.extensionType(), pos);
            Assert.same(expectedExt.extensionData(), valueExt.extensionData(), pos);
        } else {
            Assert.same(expected, value, msg, pos);
        }
    }
}
