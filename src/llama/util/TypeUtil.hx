package llama.util;

import haxe.io.Bytes;
import haxe.Constraints.IMap;
import haxe.Int64;

/**
 * Runtime type utility.
 */
class TypeUtil {
    /**
     * Returns the runtime type of the object for encoding.
     */
    @:nullSafety(Off)
    public static function typeOf(value:Null<Any>):EncoderDataType {
        switch Type.typeof(value) {
            case TNull: return TNull;
            case TBool: return TBool;
            case TObject: return TAnonStruct;

            // targets with integer support (exclude java which Type.typeof does not work on Int64)
            #if (cpp || cs || neko || flash || hl || llama_has_int)
            case TInt:
                if (Int64.isInt64(value) && !isIntegerAInt32(value)) {
                    return TInt64;
                } else {
                    return TInt;
                }
            case TFloat:
                return TFloat;
            #end

            case TClass(c):
                if (Int64.isInt64(value)) {
                    return TInt64;
                } else if (Std.isOfType(value, Extension)) {
                    return TExtension;
                } else if (Std.isOfType(value, IMap)) {
                    return TMap;
                } else if (Std.isOfType(value, String)) {
                    return TString;
                } else if (Std.isOfType(value, Bytes)) {
                    return TBytes;
                } else if (Std.isOfType(value, Array)) {
                    return TArray;
                } else {
                    return TUnknown;
                }

            default:
                #if java
                if (Int64.isInt64(value)) {
                    return TInt64;
                } else if (Std.isOfType(value, Int)) {
                    return TInt;
                } else if (Std.isOfType(value, Float)) {
                    return TFloat;
                }
                #else

                if (Std.isOfType(value, Float) || Std.isOfType(value, Int)) {
                    if (isNumberAInt32(value)) {
                        return TInt;
                    } else {
                        return TFloat;
                    }
                }

                #end

                return TUnknown;
        }
    }

    public static function isNumberAInt32(value:NumberType):Bool {
        return Std.int(value) == value && (value:Float) >= -2147483648 && (value:Float) <= 2147483647;
    }

    public static function isNumberNotAnInteger(value:Float):Bool {
        return Math.ffloor(value) != value;
    }

    public static function isIntegerAInt32(value:Int):Bool {
        return value >= -2147483648 && value <= 2147483647;
    }
}
