package llama;

import haxe.io.Bytes;

/**
 * MsgPack extension type.
 */
interface Extension {
    /**
     * Returns the extension type.
     */
    public function extensionType():Int;

    /**
     * Returns the extension data.
     */
    public function extensionData():Bytes;
}
