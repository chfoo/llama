package llama;

import haxe.Int64;
import haxe.Constraints.IMap;

/**
 * A map implementation that can accept arbitrary keys.
 *
 * This class uses two arrays for keys and values. Operations are O(n) time.
 */
class AssociativeArray<K,V> implements IMap<K,V> {
    public final arrayKeys:Array<K>;
    public final arrayValues:Array<V>;
    final allowDuplicates:Bool;

    public function new(?arrayKeys:Array<K>, ?arrayValues:Array<V>, allowDuplicates:Bool = false) {
        this.arrayKeys = arrayKeys != null ? arrayKeys : [];
        this.arrayValues = arrayValues != null ? arrayValues : [];
        this.allowDuplicates = allowDuplicates;
    }

    public function get(k:K):Null<V> {
        final index = indexOf(k);

        if (index >= 0) {
            return arrayValues[index];
        } else {
            return null;
        }
    }

    public function set(k:K, v:V):Void {
        final index = indexOf(k);

        if (index >= 0 && !allowDuplicates) {
            arrayValues[index] = v;
        } else {
            arrayKeys.push(k);
            arrayValues.push(v);
        }
    }

    public function exists(k:K):Bool {
        return indexOf(k) >= 0;
    }

    public function remove(k:K):Bool {
        final index = indexOf(k);

        if (index >= 0) {
            arrayKeys.splice(index, 1);
            arrayValues.splice(index, 1);
            return true;
        } else {
            return false;
        }
    }

    public function keys():Iterator<K> {
        return arrayKeys.iterator();
    }

    public function iterator():Iterator<V> {
        return arrayValues.iterator();
    }

    public function keyValueIterator():KeyValueIterator<K, V> {
        final items = [];

        for (index in 0...arrayKeys.length) {
            items.push({
                key: arrayKeys[index],
                value: arrayValues[index]
            });
        }

        return items.iterator();
    }

    public function copy():IMap<K, V> {
        return new AssociativeArray(arrayKeys, arrayValues);
    }

    public function toString():String {
        final buffer = new StringBuf();
        buffer.add("[\n");

        for (key => value in keyValueIterator()) {
            buffer.add(key);
            buffer.add(" => ");
            buffer.add(value);
            buffer.add("\n");
        }

        buffer.add("]\n");
        return buffer.toString();
    }

    public function clear():Void {
        @:nullSafety(Off) arrayKeys.resize(0);
        @:nullSafety(Off) arrayValues.resize(0);
    }

    function indexOf(k:K):Int {
        if (Int64.isInt64(k)) {
            final keyI64:Int64 = cast k;

            for (index in 0...arrayKeys.length) {
                if (Int64.isInt64(arrayKeys[index]) && Int64.eq(keyI64, cast arrayKeys[index])) {
                    return index;
                }
            }

            return -1;
        } else {
            return arrayKeys.indexOf(k);
        }
    }
}
