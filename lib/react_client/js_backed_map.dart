@JS()
library js_map;

import 'dart:collection';
import 'dart:core';
import 'dart:js_util' as js_util;

import 'package:js/js.dart';

/// A view into a JavaScript object ([jsObject]) that conforms to the Dart [Map] interface.
///
/// The keys are all enumerable properties of the [jsObject], though non-enumerable properties may also be accessed.
/// For this reason, it is recommended to use plain, simple JavaScript objects.
///
/// Keys should be of primitive types (String, num, bool, null), as any non-primitive Dart objects will be
/// canonicalized to their JavaScript string representations upon read/write.
/// For performance reasons, keys are not validated.
///
/// `null` is allowed as a key.
///
/// Iteration order is arbitrary, and is based on the current browser's implementation.
///
/// Two JsBackedMap instances are considered equal if they are backed by the same [jsObject].
class JsBackedMap extends MapBase<dynamic, dynamic> {
  final JsMap jsObject;

  /// Creates a JsBackedMap instance backed by a new [jsObject].
  JsBackedMap() : jsObject = JsMap();

  /// Creates a JsBackedMap instance backed by [jsObject].
  JsBackedMap.backedBy(this.jsObject);

  /// Creates a JsBackedMap instance that contains all key/value pairs of [other].
  factory JsBackedMap.from(Map other) => JsBackedMap()..addAll(other);

  /// Creates a JsBackedMap instance that contains all key/value pairs of the JS object [jsOther].
  factory JsBackedMap.fromJs(JsMap jsOther) => JsBackedMap()..addAllFromJs(jsOther);

  // Private helpers with narrower typing than we want to expose, for use in other methods
  List<dynamic> get _keys => _Object.keys(jsObject);
  // Use keys to access the value instead oof `Object.values` since MSIE 11 doesn't support it
  List<dynamic> get _values => _keys.map((key) => this[key]).toList();

  /// Adds all key/value pairs of the JS object [jsOther] to this map.
  ///
  /// If a key of [jsOther] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key and associated value in [jsOther].
  ///
  /// This is similar to [addAll], but for a JsMap instead of a JsBackedMap/Map.
  void addAllFromJs(JsMap jsOther) {
    _Object.assign(jsObject, jsOther);
  }

  // ----------------------------------
  // MapBase implementations
  // ----------------------------------

  @override
  dynamic operator [](Object key) {
    return js_util.getProperty(jsObject, key);
  }

  @override
  void operator []=(dynamic key, dynamic value) {
    js_util.setProperty(jsObject, key, value);
  }

  @override
  Iterable<dynamic> get keys => _keys;

  @override
  dynamic remove(Object key) {
    final value = this[key];
    _Reflect.deleteProperty(jsObject, key);
    return value;
  }

  @override
  void clear() {
    for (final key in _keys) {
      _Reflect.deleteProperty(jsObject, key);
    }
  }

  // ----------------------------------
  // Optimized MapBase overrides
  // ----------------------------------

  @override
  void addAll(Map other) {
    if (other is JsBackedMap) {
      // Object.assign is more efficient than iterating through and setting properties in Dart.
      addAllFromJs(other.jsObject);
    } else {
      super.addAll(other);
    }
  }

  @override
  bool containsKey(Object key) => js_util.hasProperty(jsObject, key);

  @override
  Iterable<dynamic> get values => _values;

  // todo figure out if this is faster than default implementation
  @override
  bool containsValue(Object value) => _values.contains(value);

  @override
  bool operator ==(other) => other is JsBackedMap && other.jsObject == jsObject;

  @override
  int get hashCode {
    // Work around DDC throwing when accessing hashCode on frozen JS objects:
    // https://github.com/dart-lang/sdk/issues/36354
    try {
      return jsObject.hashCode;
    } catch (_) {}

    // While constant hashCode like this one are not high-quality and may cause
    // hashCode collisions more often, they are completely valid.
    // For more information, see the `Object.hashCode` doc comment.
    return 0;
  }
}

/// A utility interop class for a plain JS "object"/"map"/"dictionary".
///
/// This class provides no functionality, and exists solely as a placeholder
/// type for use in [JsBackedMap] and other related utilities.
@JS()
@anonymous
class JsMap {
  external factory JsMap();
}

/// Returns a JsMap version of [map], which will be either:
///
/// - the backing JsMap if [map] is a [JsBackedMap]
/// - a JsMap copy of [map]
///
/// This method is useful when the map needs to be passed to a JS function
/// and you want to avoid copying it when possible.
///
/// If a copy is always needed, use [JsBackedMap.from] instead.
JsMap jsBackingMapOrJsCopy(Map map) {
  // todo is it faster to just always do .from?
  if (map is JsBackedMap) {
    return map.jsObject;
  } else {
    return JsBackedMap.from(map).jsObject;
  }
}

@JS('Object')
abstract class _Object {
  external static void assign(JsMap to, JsMap from);
  external static List<dynamic> keys(JsMap object);
  // ignore: unused_element
  external static List<dynamic> values(JsMap object);
}

@JS('Reflect')
abstract class _Reflect {
  external static bool deleteProperty(JsMap target, dynamic propertyKey);
}
