package llama;

import haxe.io.Bytes;

/**
 * MsgPack extension type.
 */
interface Extension {
    public function extensionType():Int;
    public function extensionData():Bytes;
}
