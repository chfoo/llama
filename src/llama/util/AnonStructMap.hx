package llama.util;

import haxe.Constraints.IMap;
import haxe.DynamicAccess;

/**
 * Wraps a DynamicAccess object to a concrete IMap instance.
 */
class AnonStructMap<V> implements IMap<String,V> {
    var doc:DynamicAccess<V>;

    public function new(doc:DynamicAccess<V>) {
        this.doc = doc;
    }

    public function reset(doc:DynamicAccess<V>) {
        this.doc = doc;
    }

    public function get(k:String):Null<V> {
        return doc.get(k);
    }

    public function set(k:String, v:V):Void {
        doc.set(k, v);
    }

    public function exists(k:String):Bool {
        return doc.exists(k);
    }

    public function remove(k:String):Bool {
        return doc.remove(k);
    }

    public function keys():Iterator<String> {
        return doc.keys().iterator();
    }

    public function iterator():Iterator<V> {
        return doc.iterator();
    }

    public function keyValueIterator():KeyValueIterator<String, V> {
        return doc.keyValueIterator();
    }

    @:nullSafety(Off)
    public function copy():IMap<String, V> {
        return new AnonStructMap(doc.copy());
    }

    public function toString():String {
        return Std.string(doc);
    }

    public function clear():Void {
        for (key in doc.keys()) {
            doc.remove(key);
        }
    }
}
