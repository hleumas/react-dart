// Copyright (c) 2013-2016, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package, unnecessary_getters_setters

/// A Dart library for building UI using ReactJS.
library react;

import 'package:meta/meta.dart';
import 'package:react/react_client/bridge.dart';
import 'package:react/react_client/js_backed_map.dart';
import 'package:react/src/prop_validator.dart';
import 'package:react/src/typedefs.dart';
import 'package:react/react_client.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_client/component_factory.dart';
import 'package:react/src/context.dart';
import 'package:react/src/react_client/component_registration.dart' as registration_utils;
import 'package:react/src/react_client/private_utils.dart' show validateJsApiThenReturn;

export 'package:react/src/context.dart';
export 'package:react/src/prop_validator.dart';
export 'package:react/src/react_client/event_helpers.dart';
export 'package:react/react_client/react_interop.dart' show forwardRef, forwardRef2, createRef, memo, memo2;
export 'package:react/src/react_client/synthetic_event_wrappers.dart' hide NonNativeDataTransfer;
export 'package:react/src/react_client/synthetic_data_transfer.dart' show SyntheticDataTransfer;
export 'package:react/src/react_client/event_helpers.dart';

typedef PropValidator<TProps> = Error Function(TProps props, PropValidatorInfo info);

/// A React component declared using a function that takes in [props] and returns rendered output.
///
/// See <https://reactjs.org/docs/components-and-props.html#function-and-class-components>.
///
/// [props] is typed as [JsBackedMap] so that dart2js can optimize props accesses.
typedef DartFunctionComponent = dynamic Function(JsBackedMap props);

/// The callback to a React forwardRef component. See [forwardRef2] for more details.
///
/// [props] is typed as [JsBackedMap] so that dart2js can optimize props accesses.
///
/// In the current JS implementation, the ref argument to [React.forwardRef] is usually a JsRef object no matter the input ref type,
/// but according to React the ref argument can be any ref type: https://github.com/facebook/flow/blob/master@%7B2020-09-08%7D/lib/react.js#L305
/// and not just a ref object, so we type [ref] as dynamic here.
typedef DartForwardRefFunctionComponent = dynamic Function(JsBackedMap props, dynamic ref);

typedef ComponentFactory<T extends Component> = T Function();

typedef ComponentRegistrar = ReactComponentFactoryProxy Function(ComponentFactory componentFactory,
    [Iterable<String> skipMethods]);

typedef ComponentRegistrar2 = ReactDartComponentFactoryProxy2 Function(
  ComponentFactory<Component2> componentFactory, {
  Iterable<String> skipMethods,
  Component2BridgeFactory bridgeFactory,
});

typedef FunctionComponentRegistrar = ReactDartFunctionComponentFactoryProxy
    Function(DartFunctionComponent componentFactory, {String displayName});

/// Fragment component that allows the wrapping of children without the necessity of using
/// an element that adds an additional layer to the DOM (div, span, etc).
///
/// See: <https://reactjs.org/docs/fragments.html>
var Fragment = ReactJsComponentFactoryProxy(React.Fragment);

/// StrictMode is a tool for highlighting potential problems in an application.
///
/// StrictMode does not render any visible UI. It activates additional checks and warnings for its descendants.
///
/// See: <https://reactjs.org/docs/strict-mode.html>
var StrictMode = ReactJsComponentFactoryProxy(React.StrictMode);

/// Top-level ReactJS [Component class](https://reactjs.org/docs/react-component.html)
/// which provides the [ReactJS Component API](https://reactjs.org/docs/react-component.html#reference)
///
/// __Deprecated. Use [Component2] instead.__
@Deprecated('7.0.0')
abstract class Component {
  Map _context;

  /// A private field that backs [props], which is exposed via getter/setter so
  /// it can be overridden in strong mode.
  ///
  /// Necessary since the `@virtual` annotation within the meta package
  /// [doesn't work for overriding fields](https://github.com/dart-lang/sdk/issues/27452).
  ///
  /// TODO: Switch back to a plain field once this issue is fixed.
  Map _props;

  /// A private field that backs [state], which is exposed via getter/setter so
  /// it can be overridden in strong mode.
  ///
  /// Necessary since the `@virtual` annotation within the meta package
  /// [doesn't work for overriding fields](https://github.com/dart-lang/sdk/issues/27452).
  ///
  /// TODO: Switch back to a plain field once this issue is fixed.
  Map _state = {};

  /// A private field that backs [ref], which is exposed via getter/setter so
  /// it can be overridden in strong mode.
  ///
  /// Necessary since the `@virtual` annotation within the meta package
  /// [doesn't work for overriding fields](https://github.com/dart-lang/sdk/issues/27452).
  ///
  /// TODO: Switch back to a plain field once this issue is fixed.
  RefMethod _ref;

  /// The React context map of this component, passed down from its ancestors' [getChildContext] value.
  ///
  /// Only keys declared in this component's [contextKeys] will be present.
  ///
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > It is strongly recommended that you migrate to [Component2] and use [Component2.context] instead.
  @experimental
  dynamic get context => _context;

  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > It is strongly recommended that you migrate to [Component2] and use [Component2.context] instead.
  @experimental
  set context(dynamic value) => _context = value;

  /// ReactJS [Component] props.
  ///
  /// Related: [state]
  Map get props => _props;
  set props(Map value) => _props = value;

  /// ReactJS [Component] state.
  ///
  /// Related: [props]
  Map get state => _state;
  set state(Map value) => _state = value;

  /// __DEPRECATED.__
  ///
  /// Support for String `ref`s will be removed in the `7.0.0` release when `Component` is removed.
  ///
  /// There are new and improved ways to use / set refs within [Component2].
  /// Until then, use a callback ref instead.
  ///
  /// FIXME 3.1.0-wip: Add better description of how to utilize [Component2] refs.
  @Deprecated('7.0.0')
  RefMethod get ref => _ref;

  /// __DEPRECATED.__
  ///
  /// Support for String `ref`s will be removed in the `7.0.0` release when `Component` is removed.
  ///
  /// There are new and improved ways to use / set refs within [Component2].
  /// Until then, use a callback ref instead.
  ///
  /// FIXME 3.1.0-wip: Add better description of how to utilize [Component2] refs.
  @Deprecated('7.0.0')
  set ref(RefMethod value) => _ref = value;

  dynamic _jsRedraw;

  dynamic _jsThis;

  final List<SetStateCallback> _setStateCallbacks = [];

  final List<StateUpdaterCallback> _transactionalSetStateCallbacks = [];

  /// The List of callbacks to be called after the component has been updated from a call to [setState].
  List get setStateCallbacks => _setStateCallbacks;

  /// The List of transactional `setState` callbacks to be called before the component updates.
  List get transactionalSetStateCallbacks => _transactionalSetStateCallbacks;

  /// The JavaScript [`ReactComponent`](https://reactjs.org/docs/react-api.html#reactdom.render)
  /// instance of this `Component` returned by [render].
  dynamic get jsThis => _jsThis;

  /// Allows the [ReactJS `displayName` property](https://reactjs.org/docs/react-component.html#displayname)
  /// to be set for debugging purposes.
  String get displayName => runtimeType.toString();

  initComponentInternal(props, _jsRedraw, [RefMethod ref, _jsThis, context]) {
    this._jsRedraw = _jsRedraw;
    this.ref = ref;
    this._jsThis = _jsThis;
    _initContext(context);
    _initProps(props);
  }

  /// Initializes context
  _initContext(context) {
    /// [context]s typing was loosened from Map to dynamic to support the new context API in [Component2]
    /// which extends from [Component]. Only "legacy" context APIs are supported in [Component] - which means
    /// it will still be expected to be a Map.
    this.context = Map.from(context ?? const {});

    /// [nextContext]s typing was loosened from Map to dynamic to support the new context API in [Component2]
    /// which extends from [Component]. Only "legacy" context APIs are supported in [Component] - which means
    /// it will still be expected to be a Map.
    nextContext = Map.from(this.context ?? const {});
  }

  _initProps(props) {
    this.props = Map.from(props);
    nextProps = this.props;
  }

  initStateInternal() {
    state = Map.from(getInitialState());

    // Call `transferComponentState` to get state also to `_prevState`
    transferComponentState();
  }

  /// Private reference to the value of [context] for the upcoming render cycle.
  ///
  /// Useful for ReactJS lifecycle methods [shouldComponentUpdateWithContext] and [componentWillUpdateWithContext].
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  Map nextContext;

  /// Private reference to the value of [state] for the upcoming render cycle.
  ///
  /// Useful for ReactJS lifecycle methods [shouldComponentUpdate], [componentWillUpdate] and [componentDidUpdate].
  Map _nextState;

  /// Reference to the value of [context] from the previous render cycle, used internally for proxying
  /// the ReactJS lifecycle method.
  ///
  /// __DO NOT set__ from anywhere outside react-dart lifecycle internals.
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  Map prevContext;

  /// Reference to the value of [state] from the previous render cycle, used internally for proxying
  /// the ReactJS lifecycle method and [componentDidUpdate].
  ///
  /// Not available after [componentDidUpdate] is called.
  ///
  /// __DO NOT set__ from anywhere outside react-dart lifecycle internals.
  Map prevState;

  /// Public getter for [_nextState].
  ///
  /// If `null`, then [_nextState] is equal to [state] - which is the value that will be returned.
  Map get nextState => _nextState ?? state;

  /// Reference to the value of [props] for the upcoming render cycle.
  ///
  /// Used internally for proxying ReactJS lifecycle methods [shouldComponentUpdate], [componentWillReceiveProps], and
  /// [componentWillUpdate] as well as the context-specific variants.
  ///
  /// __DO NOT set__ from anywhere outside react-dart lifecycle internals.
  Map nextProps;

  /// Transfers `Component` [_nextState] to [state], and [state] to [prevState].
  ///
  /// > __DEPRECATED.__
  /// >
  /// > This was never designed for public consumption, and there will be no replacement implementation in `Component2`.
  /// >
  /// > Will be removed in `7.0.0` along with `Component`.
  @Deprecated('7.0.0')
  void transferComponentState() {
    prevState = state;
    if (_nextState != null) {
      state = _nextState;
    }
    _nextState = Map.from(state);
  }

  /// Force a call to [render] by calling [setState], which effectively "redraws" the `Component`.
  ///
  /// Optionally accepts a [callback] that gets called after the component updates.
  void redraw([Function() callback]) {
    setState({}, callback);
  }

  /// Triggers a rerender with new state obtained by shallow-merging [newState] into the current [state].
  ///
  /// Optionally accepts a [callback] that gets called after the component updates.
  ///
  /// Also allows [newState] to be used as a transactional `setState` callback.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#setstate>
  void setState(covariant dynamic newState, [Function() callback]) {
    if (newState is Map) {
      _nextState.addAll(newState);
    } else if (newState is StateUpdaterCallback) {
      _transactionalSetStateCallbacks.add(newState);
    } else if (newState != null) {
      throw ArgumentError(
          'setState expects its first parameter to either be a Map or a `TransactionalSetStateCallback`.');
    }

    if (callback != null) _setStateCallbacks.add(callback);

    _jsRedraw();
  }

  /// Set [_nextState] to provided [newState] value and force a re-render.
  ///
  /// Optionally accepts a callback that gets called after the component updates.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#setstate>
  ///
  /// > __DEPRECATED.__
  /// >
  /// > Use [setState] instead.
  @Deprecated('7.0.0')
  void replaceState(Map newState, [Function() callback]) {
    final nextState = newState == null ? {} : Map.from(newState);
    _nextState = nextState;
    if (callback != null) _setStateCallbacks.add(callback);

    _jsRedraw();
  }

  /// ReactJS lifecycle method that is invoked once, both on the client and server, immediately before the initial
  /// rendering occurs.
  ///
  /// If you call [setState] within this method, [render] will see the updated state and will be executed only once
  /// despite the [state] value change.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#mounting-componentwillmount>
  void componentWillMount() {}

  /// ReactJS lifecycle method that is invoked once, only on the client _(not on the server)_, immediately after the
  /// initial rendering occurs.
  ///
  /// At this point in the lifecycle, you can access any [ref]s to the children of the root node.
  ///
  /// The [componentDidMount] method of child `Component`s is invoked _before_ that of parent `Component`.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#mounting-componentdidmount>
  void componentDidMount() {}

  /// ReactJS lifecycle method that is invoked when a `Component` is receiving [newProps].
  ///
  /// This method is not called for the initial [render].
  ///
  /// Use this as an opportunity to react to a prop transition before [render] is called by updating the [state] using
  /// [setState]. The old props can be accessed via [props].
  ///
  /// Calling [setState] within this function will not trigger an additional [render].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#updating-componentwillreceiveprops>
  /// > __UNSUPPORTED IN COMPONENT2__
  /// >
  /// > This will be removed once 7.0.0 releases; switching to [Component2.getDerivedStateFromProps] is the path forward.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  void componentWillReceiveProps(Map newProps) {}

  /// > __UNSUPPORTED IN COMPONENT2__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  void componentWillReceivePropsWithContext(Map newProps, dynamic nextContext) {}

  /// ReactJS lifecycle method that is invoked before rendering when [nextProps] or [nextState] are being received.
  ///
  /// Use this as an opportunity to return `false` when you're certain that the transition to the new props and state
  /// will not require a component update.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#updating-shouldcomponentupdate>
  bool shouldComponentUpdate(Map nextProps, Map nextState) => true;

  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  // ignore: avoid_returning_null
  bool shouldComponentUpdateWithContext(Map nextProps, Map nextState, Map nextContext) => null;

  /// ReactJS lifecycle method that is invoked immediately before rendering when [nextProps] or [nextState] are being
  /// received.
  ///
  /// This method is not called for the initial [render].
  ///
  /// Use this as an opportunity to perform preparation before an update occurs.
  ///
  /// __Note__: Choose either this method or [componentWillUpdateWithContext]. They are both called at the same time so
  /// using both provides no added benefit.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#updating-componentwillupdate>
  ///
  /// > __UNSUPPORTED IN COMPONENT2__
  /// >
  /// > Due to the release of getSnapshotBeforeUpdate in ReactJS 16,
  /// > componentWillUpdate is no longer the method used to check the state
  /// > and props before a re-render. Both the Component class and
  /// > componentWillUpdate will be removed in the react.dart 7.0.0 release.
  /// > Use Component2 and Component2.getSnapshotBeforeUpdate instead.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  void componentWillUpdate(Map nextProps, Map nextState) {}

  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  void componentWillUpdateWithContext(Map nextProps, Map nextState, Map nextContext) {}

  /// ReactJS lifecycle method that is invoked immediately after the `Component`'s updates are flushed to the DOM.
  ///
  /// This method is not called for the initial [render].
  ///
  /// Use this as an opportunity to operate on the root node (DOM) when the `Component` has been updated as a result
  /// of the values of [prevProps] / [prevState].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#updating-componentdidupdate>
  void componentDidUpdate(Map prevProps, Map prevState) {}

  /// ReactJS lifecycle method that is invoked immediately before a `Component` is unmounted from the DOM.
  ///
  /// Perform any necessary cleanup in this method, such as invalidating timers or cleaning up any DOM `Element`s that
  /// were created in [componentDidMount].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#unmounting-componentwillunmount>
  void componentWillUnmount() {}

  /// Returns a Map of context to be passed to descendant components.
  ///
  /// Only keys present in [childContextKeys] will be used; all others will be ignored.
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  Map<String, dynamic> getChildContext() => const {};

  /// The keys this component uses in its child context map (returned by [getChildContext]).
  ///
  /// __This method is called only once, upon component registration.__
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  Iterable<String> get childContextKeys => const [];

  /// The keys of context used by this component.
  ///
  /// __This method is called only once, upon component registration.__
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
  /// > in ReactJS 16 that is exposed via the [Component2] class.
  /// >
  /// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
  @Deprecated('7.0.0')
  Iterable<String> get contextKeys => const [];

  /// Invoked once before the `Component` is mounted. The return value will be used as the initial value of [state].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#getinitialstate>
  Map getInitialState() => {};

  /// Invoked once and cached when [registerComponent] is called. Values in the mapping will be set on [props]
  /// if that prop is not specified by the parent component.
  ///
  /// This method is invoked before any instances are created and thus cannot rely on [props]. In addition, be aware
  /// that any complex objects returned by `getDefaultProps` will be shared across instances, not copied.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#getdefaultprops>
  Map getDefaultProps() => {};

  /// __Required.__
  ///
  /// When called, it should examine [props] and [state] and return a single child `Element`. This child `Element` can
  /// be either a virtual representation of a native DOM component (such as `DivElement`) or another composite
  /// `Component` that you've defined yourself.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#render>
  dynamic render();
}

/// Top-level ReactJS [Component class](https://reactjs.org/docs/react-component.html)
/// which provides the [ReactJS Component API](https://reactjs.org/docs/react-component.html#reference).
///
/// Differences from the deprecated [Component]:
///
/// 1. "JS-backed maps" - uses the JS React component's props / state objects maps under the hood
///    instead of copying them into Dart Maps. Benefits:
///     - Improved performance
///     - Props/state key-value pairs are visible to React, and show up in the Dev Tools
///     - Easier to maintain the JS-Dart interop and add new features
///     - Easier to interop with JS libraries like react-redux
///
/// 2. Supports the new lifecycle methods introduced in React 16
///    (See method doc comments for more info)
///     - [getDerivedStateFromProps]
///     - [getSnapshotBeforeUpdate]
///     - [componentDidCatch]
///     - [getDerivedStateFromError]
///
/// 3. Drops support for "unsafe" lifecycle methods deprecated in React 16
///    (See method doc comments for migration instructions)
///     - [componentWillMount]
///     - [componentWillReceiveProps]
///     - [componentWillUpdate]
///
/// 4. Supports React 16 [context]
abstract class Component2 implements Component {
  /// Accessed once and cached when instance is created. The [contextType] property on a class can be assigned
  /// a [ReactContext] object created by [React.createContext]. This lets you consume the nearest current value of
  /// that Context using [context].
  ///
  /// __Example__:
  ///
  ///     var MyContext = createContext('test');
  ///
  ///     class MyClass extends react.Component2 {
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
  /// See: <https://reactjs.org/docs/context.html#classcontexttype>
  Context get contextType => null;

  /// Invoked once and cached when [registerComponent] is called. Values in the mapping will be set on [props]
  /// if that prop is not specified by the parent component.
  ///
  /// This method is invoked before any instances are created and thus cannot rely on [props]. In addition, be aware
  /// that any complex objects returned by `defaultProps` will be shared across instances, not copied.
  ///
  /// __Example__:
  ///
  ///     // ES6 component
  ///     Component.defaultProps = {
  ///       count: 0
  ///     };
  ///
  ///     // Dart component
  ///     @override
  ///     get defaultProps => {'count': 0};
  ///
  /// See: <https://reactjs.org/docs/react-without-es6.html#declaring-default-props>
  /// See: <https://reactjs.org/docs/react-component.html#defaultprops>
  Map get defaultProps => const {};

  /// Invoked once before the `Component` is mounted. The return value will be used as the initial value of [state].
  ///
  /// __Example__:
  ///
  ///     // ES6 component
  ///     constructor() {
  ///       this.state = {count: 0};
  ///     }
  ///
  ///     // Dart component
  ///     @override
  ///     get initialState => {'count': 0};
  ///
  /// See: <https://reactjs.org/docs/react-without-es6.html#setting-the-initial-state>
  /// See: <https://reactjs.org/docs/react-component.html#constructor>
  Map get initialState => const {};

  /// The context value from the [contextType] assigned to this component.
  /// The value is passed down from the provider of the same [contextType].
  /// You can reference [context] in any of the lifecycle methods including the render function.
  ///
  /// If you need multiple context values, consider using multiple consumers instead.
  /// Read more: https://reactjs.org/docs/context.html#consuming-multiple-contexts
  ///
  /// This only has a value when [contextType] is set.
  ///
  /// __Example__:
  ///
  ///     var MyContext = createContext('test');
  ///
  ///     class MyClass extends react.Component2 {
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
  /// See: <https://reactjs.org/docs/context.html#classcontexttype>
  @override
  dynamic context;

  @override
  Map props;

  @override
  Map state;

  @override
  @Deprecated('7.0.0')
  get _jsThis => throw _unsupportedError('_jsThis');
  @override
  @Deprecated('7.0.0')
  set _jsThis(_) => throw _unsupportedError('_jsThis');

  /// The JavaScript [`ReactComponent`](https://reactjs.org/docs/react-api.html#reactdom.render)
  /// instance of this `Component` returned by [render].
  @override
  ReactComponent jsThis;

  /// Allows the [ReactJS `displayName` property](https://reactjs.org/docs/react-component.html#displayname)
  /// to be set for debugging purposes.
  ///
  /// In DDC, this will be the class name, but in dart2js it will be null unless
  /// overridden, since using runtimeType can lead to larger dart2js output.
  ///
  /// This will result in the dart2js name being `ReactDartComponent2` (the
  /// name of the proxying JS component defined in _dart_helpers.js).
  @override
  String get displayName {
    var value;
    assert(() {
      value = runtimeType.toString();
      return true;
    }());
    return value;
  }

  Component2Bridge get _bridge => Component2Bridge.forComponent(this);

  /// Triggers a rerender with new state obtained by shallow-merging [newState] into the current [state].
  ///
  /// Optionally accepts a [callback] that gets called after the component updates.
  ///
  /// To use a transactional `setState` callback, check out [setStateWithUpdater].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#setstate>
  @override
  void setState(Map newState, [SetStateCallback callback]) {
    _bridge.setState(this, newState, callback);
  }

  /// Triggers a rerender with new state obtained by shallow-merging
  /// the return value of [updater] into the current [state].
  ///
  /// Optionally accepts a [callback] that gets called after the component updates.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#setstate>
  void setStateWithUpdater(StateUpdaterCallback updater, [SetStateCallback callback]) {
    _bridge.setStateWithUpdater(this, updater, callback);
  }

  /// Causes [render] to be called, skipping [shouldComponentUpdate].
  ///
  /// > See: <https://reactjs.org/docs/react-component.html#forceupdate>
  void forceUpdate([SetStateCallback callback]) {
    _bridge.forceUpdate(this, callback);
  }

  /// ReactJS lifecycle method that is invoked once, only on the client _(not on the server)_, immediately after the
  /// initial rendering occurs.
  ///
  /// At this point in the lifecycle, you can access any [ref]s to the children of the root node.
  ///
  /// The [componentDidMount] method of child `Component`s is invoked _before_ that of parent `Component`.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#mounting-componentdidmount>
  @override
  void componentDidMount() {}

  /// ReactJS lifecycle method that is invoked before rendering when new props ([nextProps]) are received.
  ///
  /// It should return a new `Map` that will be merged into the existing component [state],
  /// or `null` to do nothing.
  ///
  /// __Important Caveats:__
  ///
  /// * __Unlike [componentWillReceiveProps], this method is called before first mount, and re-renders.__
  ///
  /// * __[prevState] will be `null`__ when this lifecycle method is called before first mount.
  ///   If you need to make use of [prevState], be sure to make your logic null-aware to avoid runtime exceptions.
  ///
  /// * __This method is effectively `static`__ _(since it is static in the JS layer)_,
  ///   so using instance members like [props], [state] or `ref` __will not work.__
  ///
  ///   This is different than the [componentWillReceiveProps] method that it effectively replaces.
  ///
  ///   If your logic requires access to instance members - consider using [getSnapshotBeforeUpdate] instead.
  ///
  /// __Example__:
  ///
  ///     @override
  ///     getDerivedStateFromProps(Map nextProps, Map prevState) {
  ///       if (prevState['someMirroredValue'] != nextProps['someValue']) {
  ///         return {
  ///           someMirroredValue: nextProps.someValue
  ///         };
  ///       }
  ///       return null;
  ///     }
  ///
  /// > Deriving state from props should be used with caution since it can lead to more verbose implementations
  ///   that are less approachable by others.
  /// >
  /// > [Consider recommended alternative solutions first!](https://reactjs.org/blog/2018/06/07/you-probably-dont-need-derived-state.html#preferred-solutions)
  ///
  /// See: <https://reactjs.org/docs/react-component.html#static-getderivedstatefromprops>
  Map getDerivedStateFromProps(Map nextProps, Map prevState) => null;

  /// ReactJS lifecycle method that is invoked before rendering when [nextProps] and/or [nextState] are being received.
  ///
  /// Use this as an opportunity to return `false` when you're certain that the transition to the new props and state
  /// will not require a component update.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#shouldcomponentupdate>
  @override
  bool shouldComponentUpdate(Map nextProps, Map nextState) => true;

  /// ReactJS lifecycle method that is invoked immediately after re-rendering
  /// when new props and/or state values are committed.
  ///
  /// This method is not called for the initial [render].
  ///
  /// Use this as an opportunity to perform preparation before an update occurs.
  ///
  /// __Example__:
  ///
  ///     @override
  ///     getSnapshotBeforeUpdate(Map prevProps, Map prevState) {
  ///       // Previous props / state can be analyzed and compared to this.props or
  ///       // this.state, allowing the opportunity perform decision logic.
  ///       // Are we adding new items to the list?
  ///       // Capture the scroll position so we can adjust scroll later.
  ///
  ///       if (prevProps.list.length < props.list.length) {
  ///         // The return value from getSnapshotBeforeUpdate is passed into
  ///         // componentDidUpdate's third parameter (which is new to React 16).
  ///
  ///         final list = _listRef;
  ///         return list.scrollHeight - list.scrollTop;
  ///       }
  ///
  ///       return null;
  ///     }
  ///
  ///     @override
  ///     componentDidUpdate(Map prevProps, Map prevState, dynamic snapshot) {
  ///       // If we have a snapshot value, we've just added new items.
  ///       // Adjust scroll so these new items don't push the old ones out of view.
  ///       //
  ///       // (snapshot here is the value returned from getSnapshotBeforeUpdate)
  ///       if (snapshot !== null) {
  ///         final list = _listRef;
  ///         list.scrollTop = list.scrollHeight - snapshot;
  ///       }
  ///     }
  ///
  /// See: <https://reactjs.org/docs/react-component.html#getsnapshotbeforeupdate>
  dynamic getSnapshotBeforeUpdate(Map prevProps, Map prevState) {}

  /// ReactJS lifecycle method that is invoked immediately after the `Component`'s updates are flushed to the DOM.
  ///
  /// This method is not called for the initial [render].
  ///
  /// Use this as an opportunity to operate on the root node (DOM) when the `Component` has been updated as a result
  /// of the values of [prevProps] / [prevState].
  ///
  /// __Note__: React 16 added a third parameter to `componentDidUpdate`, which
  /// is a custom value returned from [getSnapshotBeforeUpdate]. If a
  /// value is not returned from [getSnapshotBeforeUpdate], the [snapshot]
  /// parameter in `componentDidUpdate` will be null.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#componentdidupdate>
  @override
  void componentDidUpdate(Map prevProps, Map prevState, [dynamic snapshot]) {}

  /// ReactJS lifecycle method that is invoked immediately before a `Component` is unmounted from the DOM.
  ///
  /// Perform any necessary cleanup in this method, such as invalidating timers or cleaning up any DOM `Element`s that
  /// were created in [componentDidMount].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#componentwillunmount>
  @override
  void componentWillUnmount() {}

  /// ReactJS lifecycle method that is invoked after an [error] is thrown by a descendant.
  ///
  /// Use this method primarily for logging errors, but because it takes
  /// place after the commit phase side-effects are permitted.
  ///
  /// __Note__: This method, along with [getDerivedStateFromError] will only
  /// be called if `skipMethods` in [registerComponent2] is overridden with
  /// a list that includes the names of these methods. Otherwise, in order to prevent every
  /// component from being an "error boundary", [componentDidCatch] and
  /// [getDerivedStateFromError] will be ignored.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#componentdidcatch>
  void componentDidCatch(dynamic error, ReactErrorInfo info) {}

  /// ReactJS lifecycle method that is invoked after an [error] is thrown by a descendant.
  ///
  /// Use this method to capture the [error] and update component [state] accordingly by
  /// returning a new `Map` value that will be merged into the current [state].
  ///
  /// __This method is effectively `static`__ _(since it is static in the JS layer)_,
  /// so using instance members like [props], [state] or `ref` __will not work.__
  ///
  /// __Note__: This method, along with [componentDidCatch] will only
  /// be called if `skipMethods` in [registerComponent2] is overridden with
  /// a list that includes the names of these methods. Otherwise, in order to prevent every
  /// component from being an error boundary, [componentDidCatch] and
  /// [getDerivedStateFromError] will be ignored.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#static-getderivedstatefromerror>
  Map getDerivedStateFromError(dynamic error) => null;

  /// Allows usage of PropValidator functions to check the validity of a prop within the props passed to it.
  ///
  /// The second argument (`info`) contains metadata about the prop specified by the key.
  /// `propName`, `componentName`, `location` and `propFullName` are available.
  ///
  /// When an invalid value is provided for a prop, a warning will be shown in the JavaScript console.
  ///
  /// For performance reasons, propTypes is only checked in development mode.
  ///
  /// Simple Example:
  ///
  /// ```
  /// @override
  /// get propTypes => {
  ///   'name': (Map props, info) {
  ///     if (props['name'].length > 20) {
  ///       return ArgumentError('(${props['name']}) is too long. 'name' has a max length of 20 characters.');
  ///     }
  ///   },
  /// };
  /// ```
  ///
  /// Example of 2 props being dependent:
  ///
  /// ```
  /// @override
  /// get propTypes => {
  ///   'someProp': (Map props, info) {
  ///     if (props[info.propName] == true && props['anotherProp'] == null) {
  ///       return ArgumentError('If (${props[info.propName]}) is true. You must have a value for "anotherProp".');
  ///     }
  ///   },
  ///   'anotherProp': (Map props, info) {
  ///     if (props[info.propName] != null && props['someProp'] != true) {
  ///       return ArgumentError('You must set "someProp" to true to use $[info.propName].');
  ///     }
  ///   },
  /// };
  /// ```
  ///
  /// See: <https://reactjs.org/docs/typechecking-with-proptypes.html#proptypes>
  Map<String, PropValidator<Null>> get propTypes => {}; // ignore: prefer_void_to_null

  /// Examines [props] and [state] and returns one of the following types:
  ///
  /// * [ReactElement] (renders a single DOM `Element`)
  /// * [Fragment] (renders multiple elements)
  /// * [ReactPortal] (renders children into a different DOM subtree)
  /// * `String` / `num` (renders text nodes in the DOM)
  /// * `bool` / `null` (renders nothing)
  ///
  /// This method is __required__ for class components.
  ///
  /// The function should be _pure_, meaning that it should not modify component [state],
  /// it returns the same result each time it is invoked, and it does not directly interact
  /// with browser / DOM apis.
  ///
  /// If you need to interact with the browser / DOM apis, perform your work in [componentDidMount]
  /// or the other lifecycle methods instead. Keeping `render` pure makes components easier to think about.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#render>
  @override
  dynamic render();

  // ******************************************************************************************************************
  //
  // Deprecated members
  //
  // ******************************************************************************************************************

  /// Deprecated. Will be removed when [Component] is removed in the `7.0.0` release.
  ///
  /// Replace calls to this method with either:
  ///
  /// - [forceUpdate] (preferred) - forces rerender and bypasses [shouldComponentUpdate]
  /// - `setState({})` - same behavior as this method: causes rerender but goes through [shouldComponentUpdate]
  ///
  /// See: <https://reactjs.org/docs/react-component.html#forceupdate>
  @override
  @Deprecated('7.0.0')
  void redraw([SetStateCallback callback]) {
    setState({}, callback);
  }

  // ******************************************************************************************************************
  //
  // Deprecated and unsupported lifecycle methods
  //
  //   These should all throw and be annotated with @mustCallSuper so that any consumer overrides don't silently fail.
  //
  // ******************************************************************************************************************

  UnsupportedError _unsupportedLifecycleError(String memberName) =>
      UnsupportedError('Component2 drops support for the lifecycle method $memberName.'
          ' See doc comment on Component2.$memberName for migration instructions.');

  /// Invoked once before the `Component` is mounted. The return value will be used as the initial value of [state].
  ///
  /// See: <https://reactjs.org/docs/react-component.html#getinitialstate>
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > Use the [initialState] getter instead.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  Map getInitialState() => throw _unsupportedLifecycleError('getInitialState');

  /// Invoked once and cached when [registerComponent] is called. Values in the mapping will be set on [props]
  /// if that prop is not specified by the parent component.
  ///
  /// This method is invoked before any instances are created and thus cannot rely on [props]. In addition, be aware
  /// that any complex objects returned by `getDefaultProps` will be shared across instances, not copied.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#getdefaultprops>
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > Use the [defaultProps] getter instead.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  Map getDefaultProps() => throw _unsupportedLifecycleError('getDefaultProps');

  /// ReactJS lifecycle method that is invoked once immediately before the initial rendering occurs.
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > Use [componentDidMount] instead
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  void componentWillMount() => throw _unsupportedLifecycleError('componentWillMount');

  /// ReactJS lifecycle method that is invoked when a `Component` is receiving new props ([nextProps]).
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This will be removed along with [Component] in the `7.0.0` release.
  /// >
  /// > Depending on your use-case, you should use [getDerivedStateFromProps] or [getSnapshotBeforeUpdate] instead.
  /// > _(See the examples below if you're not sure which one to use)_
  ///
  /// __If you used `componentWillReceiveProps` to update instance [state], use [getDerivedStateFromProps]__
  ///
  ///     // Before
  ///     @override
  ///     componentWillReceiveProps(Map nextProps) {
  ///       if (nextProps['someValueUsedToDeriveState'] != props['someValueUsedToDeriveState']) {
  ///         setState({'someDerivedState': nextProps['someValueUsedToDeriveState']});
  ///       }
  ///     }
  ///
  ///     // After
  ///     @override
  ///     getDerivedStateFromProps(Map nextProps, Map prevState) {
  ///       // NOTE: Accessing `props` is not allowed here. Change the comparison to utilize `prevState` instead.
  ///       if (nextProps['someValueUsedToDeriveState'] != prevState['someDerivedState']) {
  ///         // Return a new Map instead of calling `setState` directly.
  ///         return {'someDerivedState': nextProps['someValueUsedToDeriveState']};
  ///       }
  ///       return null;
  ///     }
  ///
  ///
  /// __If you did not use `componentWillReceiveProps` to update instance [state], use [getSnapshotBeforeUpdate]__
  ///
  ///     // Before
  ///     @override
  ///     componentWillReceiveProps(Map nextProps) {
  ///       if (nextProps['someValue'] > props['someValue']) {
  ///         _someInstanceField = deriveNewValueFromNewProps(nextProps['someValue']);
  ///       }
  ///     }
  ///
  ///     // After
  ///     @override
  ///     getSnapshotBeforeUpdate(Map prevProps, Map prevState) {
  ///       // NOTE: Unlike `getDerivedStateFromProps`, accessing `props` is allowed here.
  ///       // * The reference to `nextProps` from `componentWillReceiveProps` should be updated to `props` here
  ///       // * The reference to `props` from `componentWillReceiveProps` should be updated to `prevProps`.
  ///       if (props['someValue'] > prevProps['someValue']) {
  ///         _someInstanceField = deriveNewValueFromNewProps(props['someValue']);
  ///       }
  ///
  ///       // NOTE: You could also return a `snapshot` value from this method for later use in `componentDidUpdate`.
  ///     }
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  void componentWillReceiveProps(Map nextProps) => throw _unsupportedLifecycleError('componentWillReceiveProps');

  /// ReactJS lifecycle method that is invoked when a `Component` is receiving
  /// new props ([nextProps]) and/or state ([nextState]).
  ///
  /// > __DEPRECATED - DO NOT USE__
  /// >
  /// > This will be removed along with [Component] in the `7.0.0` release.
  /// >
  /// > Use [getSnapshotBeforeUpdate] instead as shown in the example below.
  ///
  ///     // Before
  ///     @override
  ///     componentWillUpdate(Map nextProps, Map nextState) {
  ///       if (nextProps['someValue'] > props['someValue']) {
  ///         _someInstanceField = deriveNewValueFromNewProps(nextProps['someValue']);
  ///       }
  ///
  ///       if (nextState['someStateValue'] != state['someStateValue']) {
  ///         triggerSomeOtherActionOutsideOfThisComponent(nextState['someStateValue']);
  ///       }
  ///     }
  ///
  ///     // After
  ///     @override
  ///     getSnapshotBeforeUpdate(Map prevProps, Map prevState) {
  ///       // * The reference to `nextProps` from `componentWillUpdate` should be updated to `props` here
  ///       // * The reference to `props` from `componentWillUpdate` should be updated to `prevProps`.
  ///       if (props['someValue'] > prevProps['someValue']) {
  ///         _someInstanceField = deriveNewValueFromNewProps(props['someValue']);
  ///       }
  ///
  ///       // * The reference to `nextState` from `componentWillUpdate` should be updated to `state` here
  ///       // * The reference to `state` from `componentWillUpdate` should be updated to `prevState`.
  ///       if (state['someStateValue'] != prevState['someStateValue']) {
  ///         triggerSomeOtherActionOutsideOfThisComponent(state['someStateValue']);
  ///       }
  ///
  ///       // NOTE: You could also return a `snapshot` value from this method for later use in `componentDidUpdate`.
  ///     }
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  void componentWillUpdate(Map nextProps, Map nextState) => throw _unsupportedLifecycleError('componentWillUpdate');

  /// Do not use; this is part of the legacy context API.
  ///
  /// See [createContext] for instructions on using the new context API.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  Map<String, dynamic> getChildContext() => throw _unsupportedLifecycleError('getChildContext');

  /// Do not use; this is part of the legacy context API.
  ///
  /// See [createContext] for instructions on using the new context API.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  bool shouldComponentUpdateWithContext(Map nextProps, Map nextState, dynamic nextContext) =>
      throw _unsupportedLifecycleError('shouldComponentUpdateWithContext');

  /// Do not use; this is part of the legacy context API.
  ///
  /// See [createContext] for instructions on using the new context API.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  void componentWillUpdateWithContext(Map nextProps, Map nextState, dynamic nextContext) =>
      throw _unsupportedLifecycleError('componentWillUpdateWithContext');

  /// Do not use; this is part of the legacy context API.
  ///
  /// See [createContext] for instructions on using the new context API.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @mustCallSuper
  @Deprecated('7.0.0')
  void componentWillReceivePropsWithContext(Map newProps, dynamic nextContext) =>
      throw _unsupportedLifecycleError('componentWillReceivePropsWithContext');

  // ******************************************************************************************************************
  // Other deprecated and unsupported members
  // ******************************************************************************************************************

  UnsupportedError _unsupportedError(String memberName) => UnsupportedError('Component2 drops support for $memberName');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  void replaceState(Map newState, [SetStateCallback callback]) => throw _unsupportedError('replaceState');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  Iterable<String> get childContextKeys => throw _unsupportedError('"Legacy" Context [childContextKeys]');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  Iterable<String> get contextKeys => throw _unsupportedError('"Legacy" Context [contextKeys]');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  initComponentInternal(props, _jsRedraw, [RefMethod ref, _jsThis, context]) =>
      throw _unsupportedError('initComponentInternal');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  initStateInternal() => throw _unsupportedError('initStateInternal');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  get nextContext => throw _unsupportedError('"Legacy" Context [nextContext]');
  @override
  @Deprecated('7.0.0')
  set nextContext(_) => throw _unsupportedError('"Legacy" Context [nextContext]');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  get prevContext => throw _unsupportedError('"Legacy" Context [prevContext]');
  @override
  @Deprecated('7.0.0')
  set prevContext(_) => throw _unsupportedError('"Legacy" Context [prevContext]');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  Map get prevState => throw _unsupportedError('"Legacy" Context [prevContext]');
  @override
  set prevState(_) => throw _unsupportedError('"Legacy" Context [prevContext]');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  Map get nextState => throw _unsupportedError('nextState');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  Map get nextProps => throw _unsupportedError('nextProps');
  @override
  set nextProps(_) => throw _unsupportedError('nextProps');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  void transferComponentState() => throw _unsupportedError('transferComponentState');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  RefMethod get ref => throw _unsupportedError('ref');
  @override
  set ref(_) => throw _unsupportedError('ref');

  /// Do not use.
  ///
  /// Will be removed when [Component] is removed in the `7.0.0` release.
  @override
  @Deprecated('7.0.0')
  List<SetStateCallback> get setStateCallbacks => throw _unsupportedError('setStateCallbacks');

  @override
  @Deprecated('7.0.0')
  List<StateUpdaterCallback> get transactionalSetStateCallbacks =>
      throw _unsupportedError('transactionalSetStateCallbacks');

  // ******************************************************************************************************************
  // Private unsupported members (no need to throw since they're internal)
  // ******************************************************************************************************************

  @override
  @Deprecated('7.0.0')
  Map _context;

  @override
  @Deprecated('7.0.0')
  var _jsRedraw;

  @override
  @Deprecated('7.0.0')
  Map _nextState;

  @override
  @Deprecated('7.0.0')
  Map _props;

  @override
  @Deprecated('7.0.0')
  RefMethod _ref;

  @override
  @Deprecated('7.0.0')
  List<SetStateCallback> _setStateCallbacks;

  @override
  @Deprecated('7.0.0')
  Map _state;

  @override
  @Deprecated('7.0.0')
  List<StateUpdaterCallback> _transactionalSetStateCallbacks;

  @override
  @Deprecated('7.0.0')
  _initContext(context) {}

  @override
  @Deprecated('7.0.0')
  _initProps(props) {}
}

/// Mixin that enforces consistent typing of the `snapshot` parameter
/// returned by [Component2.getSnapshotBeforeUpdate]
/// and passed into [Component2.componentDidUpdate].
///
/// __EXAMPLE__:
///
///     class _ParentComponent extends react.Component2
///         with react.TypedSnapshot<bool> {
///
///       // Note that the return value is specified as an bool, matching the mixin
///       // type.
///       bool getShapshotBeforeUpdate(prevProps, prevState) {
///         if (prevProps["foo"]) {
///           return true;
///         }
///         return null;
///       }
///
///       // Note that the snapshot parameter is consistently typed with the return
///       // value of getSnapshotBeforeUpdate.
///       void componentDidUpdate(prevProps, prevState, [bool snapshot]) {
///         if (snapshot == true) {
///           // Do something
///         }
///       }
///
///       /* Include other standard component logic */
///
///     }
///
/// This mixin should only be used with `Component2` or `UiComponent2`. This is not
/// enforced via the `on` keyword because of an issue with the Dart SDK.
///
/// See: <https://github.com/dart-lang/sdk/issues/38098>
mixin TypedSnapshot<TSnapshot> {
  TSnapshot getSnapshotBeforeUpdate(Map prevProps, Map prevState);

  void componentDidUpdate(Map prevProps, Map prevState, [covariant TSnapshot snapshot]);
}

/// Creates a ReactJS virtual DOM instance ([ReactElement] on the client).
abstract class ReactComponentFactoryProxy implements Function {
  /// The type of component created by this factory.
  get type;

  /// Returns a new rendered component instance with the specified [props] and [childrenArgs].
  ///
  /// Necessary to work around DDC `dart.dcall` issues in <https://github.com/dart-lang/sdk/issues/29904>,
  /// since invoking the function directly doesn't work.
  dynamic /*ReactElement*/ build(Map props, [List childrenArgs]);

  /// Returns a new rendered component instance with the specified [props] and `children` ([c1], [c2], et. al.).
  ///
  /// > The additional children arguments (c2, c3, et. al.) are a workaround for <https://github.com/dart-lang/sdk/issues/16030>.
  dynamic /*ReactElement*/ call(Map props,
      [c1 = _notSpecified,
      c2 = _notSpecified,
      c3 = _notSpecified,
      c4 = _notSpecified,
      c5 = _notSpecified,
      c6 = _notSpecified,
      c7 = _notSpecified,
      c8 = _notSpecified,
      c9 = _notSpecified,
      c10 = _notSpecified,
      c11 = _notSpecified,
      c12 = _notSpecified,
      c13 = _notSpecified,
      c14 = _notSpecified,
      c15 = _notSpecified,
      c16 = _notSpecified,
      c17 = _notSpecified,
      c18 = _notSpecified,
      c19 = _notSpecified,
      c20 = _notSpecified,
      c21 = _notSpecified,
      c22 = _notSpecified,
      c23 = _notSpecified,
      c24 = _notSpecified,
      c25 = _notSpecified,
      c26 = _notSpecified,
      c27 = _notSpecified,
      c28 = _notSpecified,
      c29 = _notSpecified,
      c30 = _notSpecified,
      c31 = _notSpecified,
      c32 = _notSpecified,
      c33 = _notSpecified,
      c34 = _notSpecified,
      c35 = _notSpecified,
      c36 = _notSpecified,
      c37 = _notSpecified,
      c38 = _notSpecified,
      c39 = _notSpecified,
      c40 = _notSpecified]) {
    List childArguments;
    // Use `identical` since it compiles down to `===` in dart2js instead of calling equality helper functions,
    // and we don't want to allow any object overriding `operator==` to claim it's equal to `_notSpecified`.
    if (identical(c1, _notSpecified)) {
      // Use a const list so that empty children prop values are always identical
      // in the JS props, resulting in JS libraries (e.g., react-redux) and Dart code alike
      // not marking props as having changed as a result of rerendering the ReactElement with a new list.
      childArguments = const [];
    } else if (identical(c2, _notSpecified)) {
      childArguments = [c1];
    } else if (identical(c3, _notSpecified)) {
      childArguments = [c1, c2];
    } else if (identical(c4, _notSpecified)) {
      childArguments = [c1, c2, c3];
    } else if (identical(c5, _notSpecified)) {
      childArguments = [c1, c2, c3, c4];
    } else if (identical(c6, _notSpecified)) {
      childArguments = [c1, c2, c3, c4, c5];
    } else if (identical(c7, _notSpecified)) {
      childArguments = [c1, c2, c3, c4, c5, c6];
    } else {
      childArguments = [
        c1,
        c2,
        c3,
        c4,
        c5,
        c6,
        c7,
        c8,
        c9,
        c10,
        c11,
        c12,
        c13,
        c14,
        c15,
        c16,
        c17,
        c18,
        c19,
        c20,
        c21,
        c22,
        c23,
        c24,
        c25,
        c26,
        c27,
        c28,
        c29,
        c30,
        c31,
        c32,
        c33,
        c34,
        c35,
        c36,
        c37,
        c38,
        c39,
        c40
      ].takeWhile((child) => !identical(child, _notSpecified)).toList();
    }

    return build(props, childArguments);
  }
}

const _notSpecified = NotSpecified();

class NotSpecified {
  const NotSpecified();
}

/// Registers a component factory on both client and server.
@Deprecated('Use registerComponent2 after migrating your components from Component to Component2.')
/*ComponentRegistrar*/ Function registerComponent = validateJsApiThenReturn(() => registration_utils.registerComponent);

/// Registers a component factory on both client and server.
ComponentRegistrar2 registerComponent2 = validateJsApiThenReturn(() => registration_utils.registerComponent2);

/// Registers a function component on the client.
///
/// Example:
/// ```
/// var myFunctionComponent = registerFunctionComponent((props) {
///   return ['I am a function component', ...props.children];
/// });
/// ```
///
/// Example with display name:
/// ```
/// var myFunctionComponent = registerFunctionComponent((props) {
///   return ['I am a function component', ...props.children];
/// }, displayName: 'myFunctionComponent');
/// ```
/// or with an inferred name from the Dart function
/// ```
/// myDartFunctionComponent(Map props) {
///   return ['I am a function component', ...props.children];
/// }
/// var myFunctionComponent = registerFunctionComponent(myDartFunctionComponent);
/// ```
FunctionComponentRegistrar registerFunctionComponent =
    validateJsApiThenReturn(() => registration_utils.registerFunctionComponent);

/// The HTML `<a>` `AnchorElement`.
dynamic a = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('a'));

/// The HTML `<abbr>` `Element`.
dynamic abbr = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('abbr'));

/// The HTML `<address>` `Element`.
dynamic address = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('address'));

/// The HTML `<area>` `AreaElement`.
dynamic area = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('area'));

/// The HTML `<article>` `Element`.
dynamic article = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('article'));

/// The HTML `<aside>` `Element`.
dynamic aside = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('aside'));

/// The HTML `<audio>` `AudioElement`.
dynamic audio = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('audio'));

/// The HTML `<b>` `Element`.
dynamic b = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('b'));

/// The HTML `<base>` `BaseElement`.
dynamic base = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('base'));

/// The HTML `<bdi>` `Element`.
dynamic bdi = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('bdi'));

/// The HTML `<bdo>` `Element`.
dynamic bdo = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('bdo'));

/// The HTML `<big>` `Element`.
dynamic big = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('big'));

/// The HTML `<blockquote>` `Element`.
dynamic blockquote = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('blockquote'));

/// The HTML `<body>` `BodyElement`.
dynamic body = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('body'));

/// The HTML `<br>` `BRElement`.
dynamic br = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('br'));

/// The HTML `<button>` `ButtonElement`.
dynamic button = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('button'));

/// The HTML `<canvas>` `CanvasElement`.
dynamic canvas = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('canvas'));

/// The HTML `<caption>` `Element`.
dynamic caption = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('caption'));

/// The HTML `<cite>` `Element`.
dynamic cite = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('cite'));

/// The HTML `<code>` `Element`.
dynamic code = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('code'));

/// The HTML `<col>` `Element`.
dynamic col = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('col'));

/// The HTML `<colgroup>` `Element`.
dynamic colgroup = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('colgroup'));

/// The HTML `<data>` `Element`.
dynamic data = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('data'));

/// The HTML `<datalist>` `DataListElement`.
dynamic datalist = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('datalist'));

/// The HTML `<dd>` `Element`.
dynamic dd = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('dd'));

/// The HTML `<del>` `Element`.
dynamic del = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('del'));

/// The HTML `<details>` `DetailsElement`.
dynamic details = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('details'));

/// The HTML `<dfn>` `Element`.
dynamic dfn = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('dfn'));

/// The HTML `<dialog>` `DialogElement`.
dynamic dialog = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('dialog'));

/// The HTML `<div>` `DivElement`.
dynamic div = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('div'));

/// The HTML `<dl>` `DListElement`.
dynamic dl = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('dl'));

/// The HTML `<dt>` `Element`.
dynamic dt = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('dt'));

/// The HTML `<em>` `Element`.
dynamic em = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('em'));

/// The HTML `<embed>` `EmbedElement`.
dynamic embed = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('embed'));

/// The HTML `<fieldset>` `FieldSetElement`.
dynamic fieldset = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('fieldset'));

/// The HTML `<figcaption>` `Element`.
dynamic figcaption = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('figcaption'));

/// The HTML `<figure>` `Element`.
dynamic figure = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('figure'));

/// The HTML `<footer>` `Element`.
dynamic footer = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('footer'));

/// The HTML `<form>` `FormElement`.
dynamic form = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('form'));

/// The HTML `<h1>` `HeadingElement`.
dynamic h1 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h1'));

/// The HTML `<h2>` `HeadingElement`.
dynamic h2 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h2'));

/// The HTML `<h3>` `HeadingElement`.
dynamic h3 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h3'));

/// The HTML `<h4>` `HeadingElement`.
dynamic h4 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h4'));

/// The HTML `<h5>` `HeadingElement`.
dynamic h5 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h5'));

/// The HTML `<h6>` `HeadingElement`.
dynamic h6 = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('h6'));

/// The HTML `<head>` `HeadElement`.
dynamic head = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('head'));

/// The HTML `<header>` `Element`.
dynamic header = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('header'));

/// The HTML `<hr>` `HRElement`.
dynamic hr = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('hr'));

/// The HTML `<html>` `HtmlHtmlElement`.
dynamic html = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('html'));

/// The HTML `<i>` `Element`.
dynamic i = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('i'));

/// The HTML `<iframe>` `IFrameElement`.
dynamic iframe = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('iframe'));

/// The HTML `<img>` `ImageElement`.
dynamic img = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('img'));

/// The HTML `<input>` `InputElement`.
dynamic input = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('input'));

/// The HTML `<ins>` `Element`.
dynamic ins = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('ins'));

/// The HTML `<kbd>` `Element`.
dynamic kbd = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('kbd'));

/// The HTML `<keygen>` `KeygenElement`.
dynamic keygen = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('keygen'));

/// The HTML `<label>` `LabelElement`.
dynamic label = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('label'));

/// The HTML `<legend>` `LegendElement`.
dynamic legend = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('legend'));

/// The HTML `<li>` `LIElement`.
dynamic li = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('li'));

/// The HTML `<link>` `LinkElement`.
dynamic link = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('link'));

/// The HTML `<main>` `Element`.
dynamic main = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('main'));

/// The HTML `<map>` `MapElement`.
dynamic map = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('map'));

/// The HTML `<mark>` `Element`.
dynamic mark = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('mark'));

/// The HTML `<menu>` `MenuElement`.
dynamic menu = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('menu'));

/// The HTML `<menuitem>` `MenuItemElement`.
dynamic menuitem = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('menuitem'));

/// The HTML `<meta>` `MetaElement`.
dynamic meta = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('meta'));

/// The HTML `<meter>` `MeterElement`.
dynamic meter = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('meter'));

/// The HTML `<nav>` `Element`.
dynamic nav = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('nav'));

/// The HTML `<noscript>` `Element`.
dynamic noscript = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('noscript'));

/// The HTML `<object>` `ObjectElement`.
dynamic object = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('object'));

/// The HTML `<ol>` `OListElement`.
dynamic ol = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('ol'));

/// The HTML `<optgroup>` `OptGroupElement`.
dynamic optgroup = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('optgroup'));

/// The HTML `<option>` `OptionElement`.
dynamic option = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('option'));

/// The HTML `<output>` `OutputElement`.
dynamic output = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('output'));

/// The HTML `<p>` `ParagraphElement`.
dynamic p = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('p'));

/// The HTML `<param>` `ParamElement`.
dynamic param = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('param'));

/// The HTML `<picture>` `PictureElement`.
dynamic picture = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('picture'));

/// The HTML `<pre>` `PreElement`.
dynamic pre = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('pre'));

/// The HTML `<progress>` `ProgressElement`.
dynamic progress = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('progress'));

/// The HTML `<q>` `QuoteElement`.
dynamic q = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('q'));

/// The HTML `<rp>` `Element`.
dynamic rp = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('rp'));

/// The HTML `<rt>` `Element`.
dynamic rt = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('rt'));

/// The HTML `<ruby>` `Element`.
dynamic ruby = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('ruby'));

/// The HTML `<s>` `Element`.
dynamic s = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('s'));

/// The HTML `<samp>` `Element`.
dynamic samp = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('samp'));

/// The HTML `<script>` `ScriptElement`.
dynamic script = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('script'));

/// The HTML `<section>` `Element`.
dynamic section = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('section'));

/// The HTML `<select>` `SelectElement`.
dynamic select = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('select'));

/// The HTML `<small>` `Element`.
dynamic small = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('small'));

/// The HTML `<source>` `SourceElement`.
dynamic source = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('source'));

/// The HTML `<span>` `SpanElement`.
dynamic span = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('span'));

/// The HTML `<strong>` `Element`.
dynamic strong = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('strong'));

/// The HTML `<style>` `StyleElement`.
dynamic style = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('style'));

/// The HTML `<sub>` `Element`.
dynamic sub = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('sub'));

/// The HTML `<summary>` `Element`.
dynamic summary = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('summary'));

/// The HTML `<sup>` `Element`.
dynamic sup = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('sup'));

/// The HTML `<table>` `TableElement`.
dynamic table = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('table'));

/// The HTML `<tbody>` `TableSectionElement`.
dynamic tbody = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('tbody'));

/// The HTML `<td>` `TableCellElement`.
dynamic td = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('td'));

/// The HTML `<textarea>` `TextAreaElement`.
dynamic textarea = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('textarea'));

/// The HTML `<tfoot>` `TableSectionElement`.
dynamic tfoot = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('tfoot'));

/// The HTML `<th>` `TableCellElement`.
dynamic th = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('th'));

/// The HTML `<thead>` `TableSectionElement`.
dynamic thead = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('thead'));

/// The HTML `<time>` `TimeInputElement`.
dynamic time = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('time'));

/// The HTML `<title>` `TitleElement`.
dynamic title = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('title'));

/// The HTML `<tr>` `TableRowElement`.
dynamic tr = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('tr'));

/// The HTML `<track>` `TrackElement`.
dynamic track = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('track'));

/// The HTML `<u>` `Element`.
dynamic u = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('u'));

/// The HTML `<ul>` `UListElement`.
dynamic ul = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('ul'));

/// The HTML `<var>` `Element`.
///
/// _Named variable because `var` is a reserved word in Dart._
dynamic variable = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('var'));

/// The HTML `<video>` `VideoElement`.
dynamic video = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('video'));

/// The HTML `<wbr>` `Element`.
dynamic wbr = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('wbr'));

/// The SVG `<altGlyph>` `AltGlyphElement`.
dynamic altGlyph = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('altGlyph'));

/// The SVG `<altGlyphDef>` `AltGlyphDefElement`.
dynamic altGlyphDef = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('altGlyphDef'));

/// The SVG `<altGlyphItem>` `AltGlyphItemElement`.
dynamic altGlyphItem = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('altGlyphItem'));

/// The SVG `<animate>` `AnimateElement`.
dynamic animate = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('animate'));

/// The SVG `<animateColor>` `AnimateColorElement`.
dynamic animateColor = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('animateColor'));

/// The SVG `<animateMotion>` `AnimateMotionElement`.
dynamic animateMotion = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('animateMotion'));

/// The SVG `<animateTransform>` `AnimateTransformElement`.
dynamic animateTransform = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('animateTransform'));

/// The SVG `<circle>` `CircleElement`.
dynamic circle = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('circle'));

/// The SVG `<clipPath>` `ClipPathElement`.
dynamic clipPath = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('clipPath'));

/// The SVG `<color-profile>` `ColorProfileElement`.
dynamic colorProfile = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('color-profile'));

/// The SVG `<cursor>` `CursorElement`.
dynamic cursor = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('cursor'));

/// The SVG `<defs>` `DefsElement`.
dynamic defs = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('defs'));

/// The SVG `<desc>` `DescElement`.
dynamic desc = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('desc'));

/// The SVG `<discard>` `DiscardElement`.
dynamic discard = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('discard'));

/// The SVG `<ellipse>` `EllipseElement`.
dynamic ellipse = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('ellipse'));

/// The SVG `<feBlend>` `FeBlendElement`.
dynamic feBlend = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feBlend'));

/// The SVG `<feColorMatrix>` `FeColorMatrixElement`.
dynamic feColorMatrix = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feColorMatrix'));

/// The SVG `<feComponentTransfer>` `FeComponentTransferElement`.
dynamic feComponentTransfer = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feComponentTransfer'));

/// The SVG `<feComposite>` `FeCompositeElement`.
dynamic feComposite = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feComposite'));

/// The SVG `<feConvolveMatrix>` `FeConvolveMatrixElement`.
dynamic feConvolveMatrix = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feConvolveMatrix'));

/// The SVG `<feDiffuseLighting>` `FeDiffuseLightingElement`.
dynamic feDiffuseLighting = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feDiffuseLighting'));

/// The SVG `<feDisplacementMap>` `FeDisplacementMapElement`.
dynamic feDisplacementMap = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feDisplacementMap'));

/// The SVG `<feDistantLight>` `FeDistantLightElement`.
dynamic feDistantLight = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feDistantLight'));

/// The SVG `<feDropShadow>` `FeDropShadowElement`.
dynamic feDropShadow = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feDropShadow'));

/// The SVG `<feFlood>` `FeFloodElement`.
dynamic feFlood = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feFlood'));

/// The SVG `<feFuncA>` `FeFuncAElement`.
dynamic feFuncA = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feFuncA'));

/// The SVG `<feFuncB>` `FeFuncBElement`.
dynamic feFuncB = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feFuncB'));

/// The SVG `<feFuncG>` `FeFuncGElement`.
dynamic feFuncG = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feFuncG'));

/// The SVG `<feFuncR>` `FeFuncRElement`.
dynamic feFuncR = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feFuncR'));

/// The SVG `<feGaussianBlur>` `FeGaussianBlurElement`.
dynamic feGaussianBlur = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feGaussianBlur'));

/// The SVG `<feImage>` `FeImageElement`.
dynamic feImage = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feImage'));

/// The SVG `<feMerge>` `FeMergeElement`.
dynamic feMerge = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feMerge'));

/// The SVG `<feMergeNode>` `FeMergeNodeElement`.
dynamic feMergeNode = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feMergeNode'));

/// The SVG `<feMorphology>` `FeMorphologyElement`.
dynamic feMorphology = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feMorphology'));

/// The SVG `<feOffset>` `FeOffsetElement`.
dynamic feOffset = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feOffset'));

/// The SVG `<fePointLight>` `FePointLightElement`.
dynamic fePointLight = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('fePointLight'));

/// The SVG `<feSpecularLighting>` `FeSpecularLightingElement`.
dynamic feSpecularLighting = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feSpecularLighting'));

/// The SVG `<feSpotLight>` `FeSpotLightElement`.
dynamic feSpotLight = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feSpotLight'));

/// The SVG `<feTile>` `FeTileElement`.
dynamic feTile = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feTile'));

/// The SVG `<feTurbulence>` `FeTurbulenceElement`.
dynamic feTurbulence = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('feTurbulence'));

/// The SVG `<filter>` `FilterElement`.
dynamic filter = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('filter'));

/// The SVG `<font>` `FontElement`.
dynamic font = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font'));

/// The SVG `<font-face>` `FontFaceElement`.
dynamic fontFace = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font-face'));

/// The SVG `<font-face-format>` `FontFaceFormatElement`.
dynamic fontFaceFormat = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font-face-format'));

/// The SVG `<font-face-name>` `FontFaceNameElement`.
dynamic fontFaceName = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font-face-name'));

/// The SVG `<font-face-src>` `FontFaceSrcElement`.
dynamic fontFaceSrc = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font-face-src'));

/// The SVG `<font-face-uri>` `FontFaceUriElement`.
dynamic fontFaceUri = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('font-face-uri'));

/// The SVG `<foreignObject>` `ForeignObjectElement`.
dynamic foreignObject = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('foreignObject'));

/// The SVG `<g>` `GElement`.
dynamic g = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('g'));

/// The SVG `<glyph>` `GlyphElement`.
dynamic glyph = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('glyph'));

/// The SVG `<glyphRef>` `GlyphRefElement`.
dynamic glyphRef = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('glyphRef'));

/// The SVG `<hatch>` `HatchElement`.
dynamic hatch = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('hatch'));

/// The SVG `<hatchpath>` `HatchpathElement`.
dynamic hatchpath = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('hatchpath'));

/// The SVG `<hkern>` `HkernElement`.
dynamic hkern = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('hkern'));

/// The SVG `<image>` `ImageElement`.
dynamic image = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('image'));

/// The SVG `<line>` `LineElement`.
dynamic line = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('line'));

/// The SVG `<linearGradient>` `LinearGradientElement`.
dynamic linearGradient = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('linearGradient'));

/// The SVG `<marker>` `MarkerElement`.
dynamic marker = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('marker'));

/// The SVG `<mask>` `MaskElement`.
dynamic mask = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('mask'));

/// The SVG `<mesh>` `MeshElement`.
dynamic mesh = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('mesh'));

/// The SVG `<meshgradient>` `MeshgradientElement`.
dynamic meshgradient = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('meshgradient'));

/// The SVG `<meshpatch>` `MeshpatchElement`.
dynamic meshpatch = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('meshpatch'));

/// The SVG `<meshrow>` `MeshrowElement`.
dynamic meshrow = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('meshrow'));

/// The SVG `<metadata>` `MetadataElement`.
dynamic metadata = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('metadata'));

/// The SVG `<missing-glyph>` `MissingGlyphElement`.
dynamic missingGlyph = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('missing-glyph'));

/// The SVG `<mpath>` `MpathElement`.
dynamic mpath = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('mpath'));

/// The SVG `<path>` `PathElement`.
dynamic path = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('path'));

/// The SVG `<pattern>` `PatternElement`.
dynamic pattern = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('pattern'));

/// The SVG `<polygon>` `PolygonElement`.
dynamic polygon = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('polygon'));

/// The SVG `<polyline>` `PolylineElement`.
dynamic polyline = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('polyline'));

/// The SVG `<radialGradient>` `RadialGradientElement`.
dynamic radialGradient = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('radialGradient'));

/// The SVG `<rect>` `RectElement`.
dynamic rect = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('rect'));

/// The SVG `<set>` `SetElement`.
dynamic svgSet = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('set'));

/// The SVG `<solidcolor>` `SolidcolorElement`.
dynamic solidcolor = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('solidcolor'));

/// The SVG `<stop>` `StopElement`.
dynamic stop = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('stop'));

/// The SVG `<svg>` `SvgSvgElement`.
dynamic svg = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('svg'));

/// The SVG `<switch>` `SwitchElement`.
dynamic svgSwitch = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('switch'));

/// The SVG `<symbol>` `SymbolElement`.
dynamic symbol = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('symbol'));

/// The SVG `<text>` `TextElement`.
dynamic text = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('text'));

/// The SVG `<textPath>` `TextPathElement`.
dynamic textPath = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('textPath'));

/// The SVG `<tref>` `TrefElement`.
dynamic tref = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('tref'));

/// The SVG `<tspan>` `TSpanElement`.
dynamic tspan = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('tspan'));

/// The SVG `<unknown>` `UnknownElement`.
dynamic unknown = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('unknown'));

/// The SVG `<use>` `UseElement`.
dynamic use = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('use'));

/// The SVG `<view>` `ViewElement`.
dynamic view = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('view'));

/// The SVG `<vkern>` `VkernElement`.
dynamic vkern = validateJsApiThenReturn(() => ReactDomComponentFactoryProxy('vkern'));
