// Copyright (c) 2013-2016, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@JS()
library react_dart_context;

import 'dart:js_util';

import 'package:js/js.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_client/component_factory.dart' show ReactJsContextComponentFactoryProxy;

/// The return type of [createContext], Wraps [ReactContext] for use in Dart.
/// Allows access to [Provider] and [Consumer] Components.
///
/// __Should not be instantiated without using [createContext]__
///
/// __Example__:
///
///     Context MyContext = createContext('test');
///
///     class MyContextTypeClass extends react.Component2 {
///       @override
///       final contextType = MyContext;
///
///       render() {
///         return react.span({}, [
///           '${this.context}', // Outputs: 'test'
///         ]);
///       }
///     }
///
/// // OR
///
///     Context MyContext = createContext();
///
///     class MyClass extends react.Component2 {
///       render() {
///         return MyContext.Provider({'value': 'new context value'}, [
///           MyContext.Consumer({}, (value) {
///             return react.span({}, [
///               '$value', // Outputs: 'new context value'
///             ]),
///           });
///         ]);
///       }
///     }
///
/// Learn more at: https://reactjs.org/docs/context.html
class Context<T> {
  Context(this.Provider, this.Consumer, this._jsThis);
  final ReactContext _jsThis;

  /// Every [Context] object comes with a Provider component that allows consuming components to subscribe
  /// to context changes.
  ///
  /// Accepts a `value` prop to be passed to consuming components that are descendants of this [Provider].
  final ReactJsContextComponentFactoryProxy Provider;

  /// A React component that subscribes to context changes.
  /// Requires a function as a child. The function receives the current context value and returns a React node.
  final ReactJsContextComponentFactoryProxy Consumer;
  ReactContext get jsThis => _jsThis;
}

/// Creates a [Context] object. When React renders a component that subscribes to this [Context]
/// object it will read the current context value from the closest matching Provider above it in the tree.
///
/// The `defaultValue` argument is only used when a component does not have a matching [Context.Provider]
/// above it in the tree. This can be helpful for testing components in isolation without wrapping them.
///
/// __Example__:
///
///     react.Context MyContext = react.createContext('test');
///
///     class MyContextTypeClass extends react.Component2 {
///       @override
///       final contextType = MyContext;
///
///       render() {
///         return react.span({}, [
///           '${this.context}', // Outputs: 'test'
///         ]);
///       }
///     }
///
/// ___ OR ___
///
///     react.Context MyContext = react.createContext();
///
///     class MyClass extends react.Component2 {
///       render() {
///         return MyContext.Provider({'value': 'new context value'}, [
///           MyContext.Consumer({}, (value) {
///             return react.span({}, [
///               '$value', // Outputs: 'new context value'
///             ]),
///           });
///         ]);
///       }
///     }
///
/// Learn more: https://reactjs.org/docs/context.html#reactcreatecontext
Context<TValue> createContext<TValue>([
  TValue defaultValue,
  int Function(TValue currentValue, TValue nextValue) calculateChangedBits,
]) {
  int jsifyCalculateChangedBitsArgs(currentValue, nextValue) {
    return calculateChangedBits(
        ContextHelpers.unjsifyNewContext(currentValue), ContextHelpers.unjsifyNewContext(nextValue));
  }

  final JSContext = React.createContext(ContextHelpers.jsifyNewContext(defaultValue),
      calculateChangedBits != null ? allowInterop(jsifyCalculateChangedBitsArgs) : null);
  return Context(
    ReactJsContextComponentFactoryProxy(JSContext.Provider, isProvider: true),
    ReactJsContextComponentFactoryProxy(JSContext.Consumer, isConsumer: true),
    JSContext,
  );
}

// A JavaScript symbol that we use as the key in a JS Object to wrap the Dart.
@JS()
external get _reactDartContextSymbol;

/// A context utility for assisting with common needs of ReactDartContext.
///
/// __For internal/advanced use only.__
abstract class ContextHelpers {
  // Wraps context value in a JS Object for use on the JS side.
  // It is wrapped so that the same Dart value can be retrieved from Dart with [_unjsifyNewContext].
  static dynamic jsifyNewContext(dynamic context) {
    final jsContextHolder = newObject();
    setProperty(jsContextHolder, _reactDartContextSymbol, context);
    return jsContextHolder;
  }

  // Unwraps context value from a JS Object for use on the Dart side.
  // The value is unwrapped so that the same Dart value can be passed through js and retrived by Dart
  // when used with [_jsifyNewContext].
  static dynamic unjsifyNewContext(dynamic interopContext) {
    if (interopContext != null && hasProperty(interopContext, _reactDartContextSymbol)) {
      return getProperty(interopContext, _reactDartContextSymbol);
    }
    return interopContext;
  }
}
