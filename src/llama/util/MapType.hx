package llama.util;

import haxe.Constraints.IMap;

/**
 * Type for either IMap or anonymous structures.
 */
abstract MapType(Dynamic) from IMap<Any,Any> to IMap<Any,Any> from Dynamic to Dynamic {
}
