package llama;

enum abstract FormatByte(Int) from Int to Int {
    var Nil = 0xc0;
    var NeverUsed = 0xc1;
    var False = 0xc2;
    var True = 0xc3;
    var Bin8 = 0xc4;
    var Bin16 = 0xc5;
    var Bin32 = 0xc6;
    var Ext8 = 0xc7;
    var Ext16 = 0xc8;
    var Ext32 = 0xc9;
    var Float32 = 0xca;
    var Float64 = 0xcb;
    var Uint8 = 0xcc;
    var Uint16 = 0xcd;
    var Uint32 = 0xce;
    var Uint64 = 0xcf;
    var Int8 = 0xd0;
    var Int16 = 0xd1;
    var Int32 = 0xd2;
    var Int64 = 0xd3;
    var Fixext1 = 0xd4;
    var Fixext2 = 0xd5;
    var Fixext4 = 0xd6;
    var Fixext8 = 0xd7;
    var Fixext16 = 0xd8;
    var Str8 = 0xd9;
    var Str16 = 0xda;
    var Str32 = 0xdb;
    var Array16 = 0xdc;
    var Array32 = 0xdd;
    var Map16 = 0xde;
    var Map32 = 0xdf;
}
