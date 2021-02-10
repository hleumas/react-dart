@JS()
library react_client_private_utils;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/src/js_interop_util.dart';

/// A flag used to cache whether React is accessible.
///
/// This is used when setting environment variables to ensure they can be set properly.
bool _isJsApiValid = false;

@Deprecated('7.0.0')
InteropContextValue jsifyContext(Map<String, dynamic> context) {
  final interopContext = InteropContextValue();
  context.forEach((key, value) {
    // ignore: argument_type_not_assignable
    setProperty(interopContext, key, ReactDartContextInternal(value));
  });

  return interopContext;
}

/// Validates that React is available (see [validateJsApi]) before returning the result of [computeReturn]).
T validateJsApiThenReturn<T>(T Function() computeReturn) {
  validateJsApi();
  return computeReturn();
}

@Deprecated('7.0.0')
Map<String, dynamic> unjsifyContext(InteropContextValue interopContext) {
  // TODO consider using `contextKeys` for this if perf of objectKeys is bad.
  return Map.fromIterable(objectKeys(interopContext), value: (key) {
    // ignore: argument_type_not_assignable
    final ReactDartContextInternal internal = getProperty(interopContext, key);
    return internal?.value;
  });
}

/// Validates that React JS has been loaded and its APIs made available on the window,
/// throwing an exception otherwise.
void validateJsApi() {
  if (_isJsApiValid) return;

  try {
    // Attempt to invoke JS interop methods, which will throw if the
    // corresponding JS functions are not available.
    React.isValidElement(null);
    ReactDom.findDOMNode(null);
    // ignore: deprecated_member_use_from_same_package
    createReactDartComponentClass(null, null, null);
    createReactDartComponentClass2(null, null, null);
    _isJsApiValid = true;
  } on NoSuchMethodError catch (_) {
    throw Exception('react.js and react_dom.js must be loaded.');
  } catch (_) {
    throw Exception('Loaded react.js must include react-dart JS interop helpers.');
  }
}
