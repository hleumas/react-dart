import 'dart:html';

import 'package:react/src/react_client/synthetic_event_wrappers.dart' as events;

/// Used to wrap `SyntheticMouseEvent.dataTransfer`'s interop value in order to avoid known errors.
///
/// See <https://github.com/cleandart/react-dart/pull/220> for more context.
///
/// Related: [syntheticDataTransferFactory]
class SyntheticDataTransfer {
  /// Gets the type of drag-and-drop operation currently selected or sets the operation to a new type.
  ///
  /// The value must be `none`, `copy`, `link` or `move`.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/dropEffect>
  final String dropEffect;

  /// Provides all of the types of operations that are possible.
  ///
  /// Must be one of `none`, `copy`, `copyLink`, `copyMove`, `link`, `linkMove`, `move`, `all` or `uninitialized`.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/effectAllowed>
  final String effectAllowed;

  /// Contains a list of all the local files available on the data transfer.
  ///
  /// If the drag operation doesn't involve dragging files, this property is an empty list.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/files>
  final List files;

  /// Gives the formats that were set in the `dragstart` event.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/DataTransfer/types>
  final List<String> types;

  SyntheticDataTransfer(this.dropEffect, this.effectAllowed, this.files, this.types);
}

/// Wrapper for [SyntheticDataTransfer].
///
/// [dt] is typed as Object instead of [dynamic] to avoid dynamic calls in the method body,
/// ensuring the code is statically sound.
SyntheticDataTransfer syntheticDataTransferFactory(Object dt) {
  if (dt == null) return null;

  // `SyntheticDataTransfer` is possible because `createSyntheticMouseEvent` can take in an event that already
  // exists and save its `dataTransfer` property to the new event object. When that happens, `dataTransfer` is
  // already a `SyntheticDataTransfer` event and should just be returned.
  if (dt is SyntheticDataTransfer) return dt;

  List rawFiles;
  List rawTypes;

  String effectAllowed;
  String dropEffect;

  // Handle `dt` being either a native DOM DataTransfer object or a JS object that looks like it (events.NonNativeDataTransfer).
  // Casting a JS object to DataTransfer fails intermittently in dart2js, and vice-versa fails intermittently in either DDC or dart2js.
  // TODO figure out when NonNativeDataTransfer is used.
  //
  // Some logic here is duplicated to ensure statically-sound access of same-named members.
  if (dt is DataTransfer) {
    rawFiles = dt.files;
    rawTypes = dt.types;

    try {
      // Works around a bug in IE where dragging from outside the browser fails.
      // Trying to access this property throws the error "Unexpected call to method or property access.".
      effectAllowed = dt.effectAllowed;
    } catch (_) {
      effectAllowed = 'uninitialized';
    }
    try {
      // For certain types of drag events in IE (anything but ondragenter, ondragover, and ondrop), this fails.
      // Trying to access this property throws the error "Unexpected call to method or property access.".
      dropEffect = dt.dropEffect;
    } catch (_) {
      dropEffect = 'none';
    }
  } else {
    // Assume it's a NonNativeDataTransfer otherwise.
    // Perform a cast inside `else` instead of an `else if (dt is ...)` since is-checks for
    // anonymous JS objects have undefined behavior.
    final castedDt = dt as events.NonNativeDataTransfer;

    rawFiles = castedDt.files;
    rawTypes = castedDt.types;

    try {
      // Works around a bug in IE where dragging from outside the browser fails.
      // Trying to access this property throws the error "Unexpected call to method or property access.".
      effectAllowed = castedDt.effectAllowed;
    } catch (_) {
      effectAllowed = 'uninitialized';
    }
    try {
      // For certain types of drag events in IE (anything but ondragenter, ondragover, and ondrop), this fails.
      // Trying to access this property throws the error "Unexpected call to method or property access.".
      dropEffect = castedDt.dropEffect;
    } catch (_) {
      dropEffect = 'none';
    }
  }

  // Copy these lists and ensure they're typed properly.
  final files = <File>[...?rawFiles];
  final types = <String>[...?rawTypes];

  return SyntheticDataTransfer(dropEffect, effectAllowed, files, types);
}
