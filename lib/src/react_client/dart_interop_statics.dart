import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:js';
import 'dart:js_util';

import 'package:js/js.dart';
import 'package:react/react.dart';
import 'package:react/react_client/bridge.dart';
import 'package:react/react_client/js_backed_map.dart';
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_client/zone.dart';

import 'package:react/src/context.dart';
import 'package:react/src/react_client/private_utils.dart';
import 'package:react/src/typedefs.dart';

/// The static methods that proxy JS component lifecycle methods to Dart components.
@Deprecated('7.0.0')
final ReactDartInteropStatics dartInteropStatics = (() {
  final zone = Zone.current;

  /// Wrapper for [Component.getInitialState].
  Component initComponent(ReactComponent jsThis, ReactDartComponentInternal internal, InteropContextValue context,
          ComponentStatics componentStatics) =>
      zone.run(() {
        void jsRedraw() {
          jsThis.setState(newObject());
        }

        // ignore: omit_local_variable_types, prefer_function_declarations_over_variables
        final RefMethod getRef = (name) {
          final ref = getProperty(jsThis.refs, name);
          if (ref == null) return null;
          if (ref is Element) return ref;
          if (ref is ReactComponent) return ref.dartComponent ?? ref;

          return ref;
        };

        final component = componentStatics.componentFactory()
          ..initComponentInternal(internal.props, jsRedraw, getRef, jsThis, unjsifyContext(context))
          ..initStateInternal();

        // Return the component so that the JS proxying component can store it,
        // avoiding an interceptor lookup.
        return component;
      });

  InteropContextValue handleGetChildContext(Component component) => zone.run(() {
        return jsifyContext(component.getChildContext());
      });

  /// Wrapper for [Component.componentWillMount].
  void handleComponentWillMount(Component component) => zone.run(() {
        component
          ..componentWillMount()
          ..transferComponentState();
      });

  /// Wrapper for [Component.componentDidMount].
  void handleComponentDidMount(Component component) => zone.run(() {
        component.componentDidMount();
      });

  Map _getNextProps(Component component, ReactDartComponentInternal nextInternal) {
    final newProps = nextInternal.props;
    return newProps != null ? Map.from(newProps) : {};
  }

  /// 1. Update [Component.props] using the value stored to [Component.nextProps]
  ///    in `componentWillReceiveProps`.
  /// 2. Update [Component.context] using the value stored to [Component.nextContext]
  ///    in `componentWillReceivePropsWithContext`.
  /// 3. Update [Component.state] by calling [Component.transferComponentState]
  void _afterPropsChange(Component component, InteropContextValue nextContext) {
    component
      ..props = component.nextProps // [1]
      ..context = component.nextContext // [2]
      ..transferComponentState(); // [3]
  }

  void _clearPrevState(Component component) {
    component.prevState = null;
  }

  void _callSetStateCallbacks(Component component) {
    final callbacks = component.setStateCallbacks.toList();
    // Prevent concurrent modification during iteration
    component.setStateCallbacks.clear();
    for (final callback in callbacks) {
      callback();
    }
  }

  void _callSetStateTransactionalCallbacks(Component component) {
    final nextState = component.nextState;
    final props = UnmodifiableMapView(component.props);

    for (final callback in component.transactionalSetStateCallbacks) {
      final stateUpdates = callback(nextState, props);
      if (stateUpdates != null) nextState.addAll(stateUpdates);
    }
    component.transactionalSetStateCallbacks.clear();
  }

  /// Wrapper for [Component.componentWillReceiveProps].
  void handleComponentWillReceiveProps(
          Component component, ReactDartComponentInternal nextInternal, InteropContextValue nextContext) =>
      zone.run(() {
        final nextProps = _getNextProps(component, nextInternal);
        final newContext = unjsifyContext(nextContext);

        component
          ..nextProps = nextProps
          ..nextContext = newContext
          ..componentWillReceiveProps(nextProps)
          ..componentWillReceivePropsWithContext(nextProps, newContext);
      });

  /// Wrapper for [Component.shouldComponentUpdate].
  bool handleShouldComponentUpdate(Component component, InteropContextValue nextContext) => zone.run(() {
        _callSetStateTransactionalCallbacks(component);

        // If shouldComponentUpdateWithContext returns a valid bool (default implementation returns null),
        // then don't bother calling `shouldComponentUpdate` and have it trump.
        var shouldUpdate =
            component.shouldComponentUpdateWithContext(component.nextProps, component.nextState, component.nextContext);

        shouldUpdate ??= component.shouldComponentUpdate(component.nextProps, component.nextState);

        if (shouldUpdate) {
          return true;
        } else {
          // If component should not update, update props / transfer state because componentWillUpdate will not be called.
          _afterPropsChange(component, nextContext);
          _callSetStateCallbacks(component);
          // Clear out prevState after it's done being used so it's not retained
          _clearPrevState(component);
          return false;
        }
      });

  /// Wrapper for [Component.componentWillUpdate].
  void handleComponentWillUpdate(Component component, InteropContextValue nextContext) => zone.run(() {
        /// Call `componentWillUpdate` and the context variant
        component
          ..componentWillUpdate(component.nextProps, component.nextState)
          ..componentWillUpdateWithContext(component.nextProps, component.nextState, component.nextContext);

        _afterPropsChange(component, nextContext);
      });

  /// Wrapper for [Component.componentDidUpdate].
  ///
  /// Uses [prevState] which was transferred from [Component.nextState] in [componentWillUpdate].
  void handleComponentDidUpdate(Component component, ReactDartComponentInternal prevInternal) => zone.run(() {
        final prevInternalProps = prevInternal.props;

        /// Call `componentDidUpdate` and the context variant
        component.componentDidUpdate(prevInternalProps, component.prevState);

        _callSetStateCallbacks(component);
        // Clear out prevState after it's done being used so it's not retained
        _clearPrevState(component);
      });

  /// Wrapper for [Component.componentWillUnmount].
  void handleComponentWillUnmount(Component component) => zone.run(() {
        component.componentWillUnmount();
        // Clear these callbacks in case they retain anything;
        // they definitely won't be called after this point.
        component.setStateCallbacks.clear();
        component.transactionalSetStateCallbacks.clear();
      });

  /// Wrapper for [Component.render].
  dynamic handleRender(Component component) => zone.run(() {
        return component.render();
      });

  return ReactDartInteropStatics(
      initComponent: allowInterop(initComponent),
      handleGetChildContext: allowInterop(handleGetChildContext),
      handleComponentWillMount: allowInterop(handleComponentWillMount),
      handleComponentDidMount: allowInterop(handleComponentDidMount),
      handleComponentWillReceiveProps: allowInterop(handleComponentWillReceiveProps),
      handleShouldComponentUpdate: allowInterop(handleShouldComponentUpdate),
      handleComponentWillUpdate: allowInterop(handleComponentWillUpdate),
      handleComponentDidUpdate: allowInterop(handleComponentDidUpdate),
      handleComponentWillUnmount: allowInterop(handleComponentWillUnmount),
      handleRender: allowInterop(handleRender));
})();

abstract class ReactDartInteropStatics2 {
  static void _updatePropsAndStateWithJs(Component2 component, JsMap props, JsMap state) {
    component
      ..props = JsBackedMap.backedBy(props)
      ..state = JsBackedMap.backedBy(state);
  }

  static void _updateContextWithJs(Component2 component, dynamic jsContext) {
    component.context = ContextHelpers.unjsifyNewContext(jsContext);
  }

  static Component2 initComponent(ReactComponent jsThis, ComponentStatics2 componentStatics) => // dartfmt
      componentZone.run(() {
        final component = componentStatics.componentFactory()
          // Return the component so that the JS proxying component can store it,
          // avoiding an interceptor lookup.
          ..jsThis = jsThis
          ..props = JsBackedMap.backedBy(jsThis.props)
          ..context = ContextHelpers.unjsifyNewContext(jsThis.context);

        jsThis.state = jsBackingMapOrJsCopy(component.initialState);

        component.state = JsBackedMap.backedBy(jsThis.state);

        // ignore: invalid_use_of_protected_member
        Component2Bridge.bridgeForComponent[component] = componentStatics.bridgeFactory(component);
        return component;
      });

  static void handleComponentDidMount(Component2 component) => // dartfmt
      componentZone.run(() {
        component.componentDidMount();
      });

  static bool handleShouldComponentUpdate(Component2 component, JsMap jsNextProps, JsMap jsNextState) => // dartfmt
      componentZone.run(() {
        final value = component.shouldComponentUpdate(
          JsBackedMap.backedBy(jsNextProps),
          JsBackedMap.backedBy(jsNextState),
        );

        if (!value) {
          _updatePropsAndStateWithJs(component, jsNextProps, jsNextState);
        }

        return value;
      });

  static JsMap handleGetDerivedStateFromProps(
          ComponentStatics2 componentStatics, JsMap jsNextProps, JsMap jsPrevState) => // dartfmt
      componentZone.run(() {
        final derivedState = componentStatics.instanceForStaticMethods
            .getDerivedStateFromProps(JsBackedMap.backedBy(jsNextProps), JsBackedMap.backedBy(jsPrevState));
        if (derivedState != null) {
          return jsBackingMapOrJsCopy(derivedState);
        }
        return null;
      });

  static dynamic handleGetSnapshotBeforeUpdate(Component2 component, JsMap jsPrevProps, JsMap jsPrevState) => // dartfmt
      componentZone.run(() {
        final snapshotValue = component.getSnapshotBeforeUpdate(
          JsBackedMap.backedBy(jsPrevProps),
          JsBackedMap.backedBy(jsPrevState),
        );

        return snapshotValue;
      });

  static void handleComponentDidUpdate(
          Component2 component, ReactComponent jsThis, JsMap jsPrevProps, JsMap jsPrevState,
          [dynamic snapshot]) => // dartfmt
      componentZone.run(() {
        component.componentDidUpdate(
          JsBackedMap.backedBy(jsPrevProps),
          JsBackedMap.backedBy(jsPrevState),
          snapshot,
        );
      });

  static void handleComponentWillUnmount(Component2 component) => // dartfmt
      componentZone.run(() {
        component.componentWillUnmount();
      });

  static void handleComponentDidCatch(Component2 component, dynamic error, ReactErrorInfo info) => // dartfmt
      componentZone.run(() {
        // Due to the error object being passed in from ReactJS it is a javascript object that does not get dartified.
        // To fix this we throw the error again from Dart to the JS side and catch it Dart side which re-dartifies it.
        try {
          throwErrorFromJS(error);
        } catch (e, stack) {
          info.dartStackTrace = stack;
          // The Dart stack track gets lost so we manually add it to the info object for reference.
          component.componentDidCatch(e, info);
        }
      });

  static JsMap handleGetDerivedStateFromError(ComponentStatics2 componentStatics, dynamic error) => // dartfmt
      componentZone.run(() {
        // Due to the error object being passed in from ReactJS it is a javascript object that does not get dartified.
        // To fix this we throw the error again from Dart to the JS side and catch it Dart side which re-dartifies it.
        try {
          throwErrorFromJS(error);
        } catch (e) {
          final result = componentStatics.instanceForStaticMethods.getDerivedStateFromError(e);
          if (result != null) return jsBackingMapOrJsCopy(result);
          return null;
        }
      });

  static dynamic handleRender(Component2 component, JsMap jsProps, JsMap jsState, dynamic jsContext) => // dartfmt
      componentZone.run(() {
        _updatePropsAndStateWithJs(component, jsProps, jsState);
        _updateContextWithJs(component, jsContext);
        return component.render();
      });

  static final JsMap staticsForJs = jsifyAndAllowInterop({
    'initComponent': initComponent,
    'handleComponentDidMount': handleComponentDidMount,
    'handleGetDerivedStateFromProps': handleGetDerivedStateFromProps,
    'handleShouldComponentUpdate': handleShouldComponentUpdate,
    'handleGetSnapshotBeforeUpdate': handleGetSnapshotBeforeUpdate,
    'handleComponentDidUpdate': handleComponentDidUpdate,
    'handleComponentWillUnmount': handleComponentWillUnmount,
    'handleComponentDidCatch': handleComponentDidCatch,
    'handleGetDerivedStateFromError': handleGetDerivedStateFromError,
    'handleRender': handleRender,
  });
}
