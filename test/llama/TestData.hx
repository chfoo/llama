package llama;

import llama.util.TypeUtil;
import haxe.io.FPHelper;
import haxe.Int64;
import haxe.Int64Helper;
import haxe.DynamicAccess;
import haxe.io.Bytes;
import haxe.Resource;
import haxe.Json;

using StringTools;

typedef TestDataItem = {
    decoded:Any,
    encoded:Array<Bytes>,
    section:String,
    itemIndex:Int
};

private typedef DocSection = Array<DynamicAccess<Any>>;

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

@:nullSafety(Off)
class TestData {
    static final data:DynamicAccess<DocSection> = Json.parse(Resource.getString("test_data.json"));
    public static final testItems:Array<TestDataItem> = processTestItems();

    static function processTestItems():Array<TestDataItem> {
        final testItems:Array<TestDataItem> = [];

        for (sectionName => sectionItems in data) {
            if (sectionName == "50.timestamp.yaml") {
                continue;
            }

            for (index in 0...sectionItems.length) {
                final sectionItem = sectionItems[index];
                final bytesArray = parseEscapedStrings(sectionItem.get("msgpack"));
                var value:Any;

                try {
                    value = getValue(sectionItem);
                } catch (exception:String) {
                    if (exception.startsWith("NumberFormatError")) {
                        trace('unable to handle int64: $sectionName: $exception');
                        continue;
                    } else {
                        trace('$sectionName: $exception');
                        continue;
                    }
                }

                testItems.push({
                    section: sectionName,
                    itemIndex: index,
                    encoded: bytesArray,
                    decoded: value,
                });
            }
        }

        return testItems;
    }

    static function parseEscapedStrings(content:Array<String>):Array<Bytes> {
        final bytesArray = [];

        for (line in content) {
            bytesArray.push(parseEscapedBinary(line));
        }

        return bytesArray;
    }

    static function parseEscapedBinary(text:String):Bytes {
        return Bytes.ofHex(text.replace("-", ""));
    }

    static function getValue(item:DynamicAccess<Any>) {
        if (item.exists("nil")) {
            return getValueByType(item, "null");
        } else if (item.exists("bool")) {
            return getValueByType(item, "bool");
        } else if (item.exists("binary")) {
            return getValueByType(item, "bytes");
        } else if (item.exists("number") && Math.ffloor(item.get("number")) != item.get("number")) {
            return getValueByType(item, "float");
        } else if (item.exists("number") || item.exists("bignum")) {
            return getValueByType(item, "integer");
        } else if (item.exists("string")) {
            return getValueByType(item, "string");
        } else if (item.exists("array")) {
            return getValueByType(item, "array");
        } else if (item.exists("map")) {
            return getValueByType(item, "map");
        } else if (item.exists("ext")) {
            return getValueByType(item, "ext");
        } else {
            throw "unknown type";
        }
    }

    static function getValueByType(item:DynamicAccess<Any>, type:String):Any {
        switch type {
            case "null":
                return item.get("nil");
            case "bool":
                return item.get("bool");
            case "bytes":
                return parseEscapedBinary(item.get("binary"));
            case "integer":
                var int64:Int64;

                if (item.exists("bignum")) {
                    int64 = Int64Helper.parseString(item.get("bignum"));
                } else {
                    int64 = Int64Helper.fromFloat(item.get("number"));
                }
                try {
                    return Int64.toInt(int64);
                } catch (exception:String) {
                    return int64;
                }
            case "float":
                return item.get("number");
            case "string":
                return item.get("string");
            case "array":
                return item.get("array");
            case "map":
                return item.get("map");
            case "ext":
                final array:Array<Any> = item.get("ext");
                return new ExtensionImpl(array[0], parseEscapedBinary(array[1]));
            default:
                throw "unknown type";
        }
    }
}
