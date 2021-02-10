import 'dart:html';

import 'package:react/react.dart';
import 'package:react/react_client/bridge.dart';
import 'package:react/react_client/js_backed_map.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_client/component_factory.dart';

import 'package:react/src/react_client/dart_interop_statics.dart';

/// Util used with `registerComponent2` to ensure no important lifecycle
/// events are skipped. This includes `shouldComponentUpdate`,
/// `componentDidUpdate`, and `render` because they utilize
/// `_updatePropsAndStateWithJs`.
///
/// Returns the list of lifecycle events to skip, having removed the
/// important ones. If an important lifecycle event was set for skipping, a
/// warning is issued.
List<String> _filterSkipMethods(Iterable<String> methods) {
  final finalList = List.of(methods);
  var shouldWarn = false;

  if (finalList.contains('shouldComponentUpdate')) {
    finalList.remove('shouldComponentUpdate');
    shouldWarn = true;
  }

  if (finalList.contains('componentDidUpdate')) {
    finalList.remove('componentDidUpdate');
    shouldWarn = true;
  }

  if (finalList.contains('render')) {
    finalList.remove('render');
    shouldWarn = true;
  }

  if (shouldWarn) {
    window.console.warn('WARNING: Crucial lifecycle methods passed into '
        'skipMethods. shouldComponentUpdate, componentDidUpdate, and render '
        'cannot be skipped and will still be added to the new component. Please '
        'remove them from skipMethods.');
  }

  return finalList;
}

/// Creates and returns a new [ReactDartComponentFactoryProxy] from the provided [componentFactory]
/// which produces a new JS `ReactClass` component class.
@Deprecated('7.0.0')
ReactDartComponentFactoryProxy registerComponent(
  ComponentFactory componentFactory, [
  Iterable<String> skipMethods = const ['getDerivedStateFromError', 'componentDidCatch'],
]) {
  try {
    final componentInstance = componentFactory();

    if (componentInstance is Component2) {
      return registerComponent2(componentFactory, skipMethods: skipMethods);
    }

    final componentStatics = ComponentStatics(componentFactory);

    final jsConfig = JsComponentConfig(
      childContextKeys: componentInstance.childContextKeys,
      contextKeys: componentInstance.contextKeys,
    );

    /// Create the JS `ReactClass` component class
    /// with custom JS lifecycle methods.
    final reactComponentClass = createReactDartComponentClass(dartInteropStatics, componentStatics, jsConfig)
      // ignore: invalid_use_of_protected_member
      ..dartComponentVersion = ReactDartComponentVersion.component
      ..displayName = componentFactory().displayName;

    // Cache default props and store them on the ReactClass so they can be used
    // by ReactDartComponentFactoryProxy and externally.
    final defaultProps = Map.unmodifiable(componentInstance.getDefaultProps());
    reactComponentClass.dartDefaultProps = defaultProps;

    return ReactDartComponentFactoryProxy(reactComponentClass);
  } catch (e, stack) {
    print('Error when registering Component: $e\n$stack');
    rethrow;
  }
}

/// Creates and returns a new factory proxy from the provided [componentFactory]
/// which produces a new JS `ReactClass` component class.
ReactDartComponentFactoryProxy2 registerComponent2(
  ComponentFactory<Component2> componentFactory, {
  Iterable<String> skipMethods = const ['getDerivedStateFromError', 'componentDidCatch'],
  Component2BridgeFactory bridgeFactory,
}) {
  var errorPrinted = false;
  try {
    bridgeFactory ??= Component2BridgeImpl.bridgeFactory;

    final componentInstance = componentFactory();
    final componentStatics = ComponentStatics2(
      componentFactory: componentFactory,
      instanceForStaticMethods: componentInstance,
      bridgeFactory: bridgeFactory,
    );
    final filteredSkipMethods = _filterSkipMethods(skipMethods);

    // Cache default props and store them on the ReactClass so they can be used
    // by ReactDartComponentFactoryProxy and externally.
    JsBackedMap defaultProps;
    try {
      defaultProps = JsBackedMap.from(componentInstance.defaultProps);
    } catch (e, stack) {
      print('Error when registering Component2 when getting defaultProps: $e\n$stack');
      errorPrinted = true;
      rethrow;
    }

    JsMap jsPropTypes;
    try {
      // Access `componentInstance.propTypes` within an assert so they get tree-shaken out of dart2js builds.
      assert(() {
        jsPropTypes = bridgeFactory(componentInstance).jsifyPropTypes(componentInstance, componentInstance.propTypes);
        return true;
      }());
    } catch (e, stack) {
      print('Error when registering Component2 when getting propTypes: $e\n$stack');
      errorPrinted = true;
      rethrow;
    }

    final jsConfig2 = JsComponentConfig2(
      defaultProps: defaultProps.jsObject,
      contextType: componentInstance.contextType?.jsThis,
      skipMethods: filteredSkipMethods,
      propTypes: jsPropTypes ?? JsBackedMap().jsObject,
    );

    /// Create the JS `ReactClass` component class
    /// with custom JS lifecycle methods.
    final reactComponentClass =
        createReactDartComponentClass2(ReactDartInteropStatics2.staticsForJs, componentStatics, jsConfig2)
          ..displayName = componentInstance.displayName
          // ignore: invalid_use_of_protected_member
          ..dartComponentVersion = ReactDartComponentVersion.component2;

    return ReactDartComponentFactoryProxy2(reactComponentClass);
  } catch (e, stack) {
    if (!errorPrinted) print('Error when registering Component2: $e\n$stack');
    rethrow;
  }
}

/// Creates and returns a new `ReactDartFunctionComponentFactoryProxy` from the provided [dartFunctionComponent]
/// which produces a new `JsFunctionComponent`.
ReactDartFunctionComponentFactoryProxy registerFunctionComponent(DartFunctionComponent dartFunctionComponent,
        {String displayName}) =>
    ReactDartFunctionComponentFactoryProxy(dartFunctionComponent, displayName: displayName);
