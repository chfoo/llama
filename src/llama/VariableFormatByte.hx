package llama;

/**
 * Fix-N format first byte.
 */
enum abstract VariableFormatByte(Int) from Int to Int {
    var PositiveFixint = 0x00;
    var Fixmap = 0x80;
    var Fixarray = 0x90;
    var Fixstr = 0xa0;
    var NegativeFixint = 0xe0;
}
