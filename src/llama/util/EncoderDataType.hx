package llama.util;

/**
 * Encoder object data type.
 */
enum EncoderDataType {
    TNull;
    TInt;
    TInt64;
    TFloat;
    TBool;
    TAnonStruct;
    TExtension;
    TMap;
    TString;
    TBytes;
    TArray;
    TUnknown;
}
