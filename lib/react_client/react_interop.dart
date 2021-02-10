// ignore_for_file: deprecated_member_use_from_same_package
/// JS interop classes for main React JS APIs and react-dart internals.
///
/// For use in `react_client.dart` and by advanced react-dart users.

// ignore_for_file: deprecated_member_use_from_same_package

@JS()
library react_client.react_interop;

import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';
import 'package:react/hooks.dart';
import 'package:react/react.dart';
import 'package:react/react_client.dart' show ComponentFactory;
import 'package:react/react_client/bridge.dart';
import 'package:react/react_client/js_backed_map.dart';
import 'package:react/react_client/component_factory.dart'
    show ReactDartWrappedComponentFactoryProxy, ReactDartFunctionComponentFactoryProxy, ReactJsComponentFactoryProxy;
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/react_client/zone.dart';
import 'package:react/src/js_interop_util.dart';
import 'package:react/src/react_client/dart2_interop_workaround_bindings.dart';

typedef ReactJsComponentFactory = ReactElement Function(dynamic props, dynamic children);
typedef JsPropValidator = dynamic Function(
    JsMap props, String propName, String componentName, String location, String propFullName, String secret);

// ----------------------------------------------------------------------------
//   Top-level API
// ----------------------------------------------------------------------------

@JS()
abstract class React {
  external static String get version;
  external static ReactElement cloneElement(ReactElement element, [JsMap props, dynamic children]);
  external static ReactContext createContext([
    dynamic defaultValue,
    int Function(dynamic currentValue, dynamic nextValue) calculateChangedBits,
  ]);
  @Deprecated('7.0.0')
  external static ReactClass createClass(ReactClassConfig reactClassConfig);
  @Deprecated('7.0.0')
  external static ReactJsComponentFactory createFactory(type);
  external static ReactElement createElement(dynamic type, props, [dynamic children]);
  external static JsRef createRef();
  external static ReactClass forwardRef(Function(JsMap props, dynamic ref) wrapperFunction);
  external static ReactClass memo(
    dynamic wrapperFunction, [
    bool Function(JsMap prevProps, JsMap nextProps) areEqual,
  ]);

  external static bool isValidElement(dynamic object);

  external static ReactClass get StrictMode;
  external static ReactClass get Fragment;

  external static List<dynamic> useState(dynamic value);
  external static void useEffect(dynamic Function() sideEffect, [List<Object> dependencies]);
  external static List<dynamic> useReducer(Function reducer, dynamic initialState, [Function init]);
  external static Function useCallback(Function callback, List dependencies);
  external static ReactContext useContext(ReactContext context);
  external static JsRef useRef([dynamic initialValue]);
  external static dynamic useMemo(dynamic Function() createFunction, [List<dynamic> dependencies]);
  external static void useLayoutEffect(dynamic Function() sideEffect, [List<Object> dependencies]);
  external static void useImperativeHandle(dynamic ref, dynamic Function() createHandle, [List<dynamic> dependencies]);
  // NOTE: The use of generics on the `useDebugValue` interop will break the hook.
  external static dynamic useDebugValue(dynamic value, [Function format]);
}

/// Creates a [Ref] object that can be attached to a [ReactElement] via the ref prop.
///
/// __Example__:
///
///     class FooComponent extends react.Component2 {
///       final Ref<BarComponent> barRef = createRef();
///       final Ref<InputElement> inputRef = createRef();
///
///       render() => react.div({}, [
///         Bar({'ref': barRef}),
///         react.input({'ref': inputRef}),
///       ]);
///     }
///
/// Learn more: <https://reactjs.org/docs/refs-and-the-dom.html#creating-refs>.
Ref<T> createRef<T>() {
  return Ref<T>();
}

/// When this is provided as the ref prop, a reference to the rendered component
/// will be available via [current].
///
/// See [createRef] for usage examples and more info.
class Ref<T> {
  /// A JavaScript ref object returned by [React.createRef].
  final JsRef jsRef;

  Ref() : jsRef = React.createRef();

  /// Constructor for [useRef], calls [React.useRef] to initialize [current] to [initialValue].
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#useref>.
  Ref.useRefInit(T initialValue) : jsRef = React.useRef(initialValue);

  Ref.fromJs(this.jsRef);

  /// A reference to the latest instance of the rendered component.
  ///
  /// See [createRef] for usage examples and more info.
  T get current {
    final jsCurrent = jsRef.current;

    // Note: this ReactComponent check will pass for many types of JS objects,
    // so don't assume for sure that it's a ReactComponent
    if (jsCurrent is! Element && jsCurrent is ReactComponent) {
      final dartCurrent = jsCurrent.dartComponent;

      if (dartCurrent != null) {
        return dartCurrent as T;
      }
    }
    return jsCurrent;
  }

  /// Sets the value of [current].
  ///
  /// See: <https://reactjs.org/docs/hooks-faq.html#is-there-something-like-instance-variables>.
  set current(T value) {
    if (value is Component) {
      jsRef.current = value.jsThis;
    } else {
      jsRef.current = value;
    }
  }
}

/// A JS ref object returned by [React.createRef].
///
/// Dart factories will automatically unwrap [Ref] objects to this JS representation,
/// so using this class directly shouldn't be necessary.
@JS()
@anonymous
class JsRef {
  external dynamic get current;
  external set current(dynamic value);
}

/// Automatically passes a [Ref] through a component to one of its children.
///
/// __Example 1:__ Forwarding refs to DOM components
///
/// _[Analogous JS Demo](https://reactjs.org/docs/forwarding-refs.html#forwarding-refs-to-dom-components)_
///
/// ```dart
/// import 'dart:html';
/// import 'package:react/react.dart' as react;
///
/// // ---------- Component Definition ----------
/// final FancyButton = react.forwardRef2((props, ref) {
///   return react.button({'ref': ref, 'className': 'FancyButton'}, 'Click me!');
/// }, displayName: 'FancyButton');
///
/// // ---------- Component Consumption ----------
/// void main() {
///   final ref = createRef<Element>();
///
///   react_dom.render(FancyButton({'ref': ref}));
///
///   // You can now get a ref directly to the DOM button:
///   final buttonNode = ref.current;
/// }
/// ```
///
/// __Example 2:__ Forwarding refs in higher-order components
///
/// _[Analogous JS Demo](https://reactjs.org/docs/forwarding-refs.html#forwarding-refs-in-higher-order-components)_
///
/// ```dart
/// import 'dart:html';
/// import 'package:react/react.dart' as react;
/// import 'package:react/react_client.dart' show setClientConfiguration, ReactJsComponentFactoryProxy;
/// import 'package:react/react_dom.dart' as react_dom;
///
/// // ---------- Component Definitions ----------
///
/// final FancyButton = react.forwardRef2((props, ref) {
///   return react.button({'ref': ref, 'className': 'FancyButton'}, 'Click me!');
/// }, displayName: 'FancyButton');
///
/// class _LogProps extends react.Component2 {
///   @override
///   void componentDidUpdate(Map prevProps, _, [__]) {
///     print('old props: $prevProps');
///     print('new props: ${this.props}');
///   }
///
///   @override
///   render() {
///     final propsToForward = {...props}..remove('forwardedRef');
///
///     // Assign the custom prop `forwardedRef` as a ref on the component passed in via `props.component`
///     return props['component']({...propsToForward, 'ref': props['forwardedRef']}, props['children']);
///   }
/// }
/// final _logPropsHoc = react.registerComponent2(() => _LogProps());
///
/// final LogProps = react.forwardRef2((props, ref) {
///   // Note the second param "ref" provided by react.forwardRef2.
///   // We can pass it along to LogProps as a regular prop, e.g. "forwardedRef"
///   // And it can then be attached to the Component.
///   return _logPropsHoc({...props, 'forwardedRef': ref});
///   // Optional: Make the displayName more useful for the React dev tools.
///   // See: https://reactjs.org/docs/forwarding-refs.html#displaying-a-custom-name-in-devtools
/// }, displayName: 'LogProps(${_logPropsHoc.type.displayName})');
///
/// // ---------- Component Consumption ----------
/// void main() {
///   setClientConfiguration();
///   final ref = react.createRef<Element>();
///
///   react_dom.render(LogProps({'component': FancyButton, 'ref': ref}),
///       querySelector('#idOfSomeNodeInTheDom'));
///
///   // You can still get a ref directly to the DOM button:
///   final buttonNode = ref.current;
/// }
/// ```
/// See: <https://reactjs.org/docs/forwarding-refs.html>.
ReactComponentFactoryProxy forwardRef2(
  DartForwardRefFunctionComponent wrapperFunction, {
  String displayName,
}) =>
    ReactDartWrappedComponentFactoryProxy.forwardRef(wrapperFunction, displayName: displayName);

@Deprecated('Use forwardRef2')
ReactJsComponentFactoryProxy forwardRef(
  Function(Map props, Ref ref) wrapperFunction, {
  String displayName = 'Anonymous',
}) {
  // ignore: avoid_types_on_closure_parameters
  final wrappedComponent = allowInterop((JsMap props, JsRef ref) => componentZone.run(() {
        final dartProps = JsBackedMap.backedBy(props);
        for (final value in dartProps.values) {
          if (value is Function) {
            // Tag functions that came straight from the JS
            // so that we know to pass them through as-is during prop conversion.
            isRawJsFunctionFromProps[value] = true;
          }
        }

        final dartRef = Ref.fromJs(ref);
        return wrapperFunction(dartProps, dartRef);
      }));
  defineProperty(wrappedComponent, 'displayName', jsify({'value': displayName}));

  final hoc = React.forwardRef(wrappedComponent);
  // ignore: invalid_use_of_protected_member
  setProperty(hoc, 'dartComponentVersion', ReactDartComponentVersion.component2);

  return ReactJsComponentFactoryProxy(hoc, alwaysReturnChildrenAsList: true);
}

/// A [higher order component](https://reactjs.org/docs/higher-order-components.html) for function components
/// that behaves similar to the way [`React.PureComponent`](https://reactjs.org/docs/react-api.html#reactpurecomponent)
/// does for class-based components.
///
/// If your function component renders the same result given the same props, you can wrap it in a call to
/// `memo` for a performance boost in some cases by memoizing the result. This means that React will skip
/// rendering the component, and reuse the last rendered result.
///
/// ```dart
/// import 'package:react/react.dart' as react;
///
/// final MyComponent = react.memo2(react.registerFunctionComponent((props) {
///   /* render using props */
/// }));
/// ```
///
/// `memo2` only affects props changes. If your function component wrapped in `memo2` has a
/// [useState] or [useContext] Hook in its implementation, it will still rerender when `state` or `context` change.
///
/// By default it will only shallowly compare complex objects in the props map.
/// If you want control over the comparison, you can also provide a custom comparison
/// function to the [areEqual] argument as shown in the example below.
///
/// ```dart
/// import 'package:react/react.dart' as react;
///
/// final MyComponent = react.memo2(react.registerFunctionComponent((props) {
///   // render using props
/// }), areEqual: (prevProps, nextProps) {
///   // Do some custom comparison logic to return a bool based on prevProps / nextProps
/// });
/// ```
///
/// > __This method only exists as a performance optimization.__
/// >
/// > Do not rely on it to “prevent” a render, as this can lead to bugs.
///
/// See: <https://reactjs.org/docs/react-api.html#reactmemo>.
ReactComponentFactoryProxy memo2(ReactComponentFactoryProxy factory,
    {bool Function(Map prevProps, Map nextProps) areEqual}) {
  final _areEqual = areEqual == null
      ? null
      // ignore: avoid_types_on_closure_parameters
      : allowInterop((JsMap prevProps, JsMap nextProps) {
          final dartPrevProps = JsBackedMap.backedBy(prevProps);
          final dartNextProps = JsBackedMap.backedBy(nextProps);
          return areEqual(dartPrevProps, dartNextProps);
        });
  final hoc = React.memo(factory.type, _areEqual);
  setProperty(hoc, 'dartComponentVersion', ReactDartComponentVersion.component2);

  return ReactDartWrappedComponentFactoryProxy(hoc);
}

@Deprecated('Use memo2')
ReactJsComponentFactoryProxy memo(ReactDartFunctionComponentFactoryProxy factory,
    {bool Function(Map prevProps, Map nextProps) areEqual}) {
  final _areEqual = areEqual == null
      ? null
      // ignore: avoid_types_on_closure_parameters
      : allowInterop((JsMap prevProps, JsMap nextProps) {
          final dartPrevProps = JsBackedMap.backedBy(prevProps);
          final dartNextProps = JsBackedMap.backedBy(nextProps);
          return areEqual(dartPrevProps, dartNextProps);
        });
  final hoc = React.memo(factory.type, _areEqual);
  setProperty(hoc, 'dartComponentVersion', ReactDartComponentVersion.component2);

  return ReactJsComponentFactoryProxy(hoc, alwaysReturnChildrenAsList: true);
}

abstract class ReactDom {
  static Element findDOMNode(object) => ReactDOM.findDOMNode(object);
  static ReactComponent render(ReactElement component, Element element) => ReactDOM.render(component, element);
  static bool unmountComponentAtNode(Element element) => ReactDOM.unmountComponentAtNode(element);

  /// Returns a a portal that renders [children] into a [container].
  ///
  /// Portals provide a first-class way to render children into a DOM node that exists outside the DOM hierarchy of the parent component.
  ///
  /// [children] can be any renderable React child, such as a [ReactElement], [String], or fragment.
  ///
  /// See: <https://reactjs.org/docs/portals.html>
  static ReactPortal createPortal(dynamic children, Element container) => ReactDOM.createPortal(children, container);
}

@JS('ReactDOMServer')
abstract class ReactDomServer {
  external static String renderToString(ReactElement component);
  external static String renderToStaticMarkup(ReactElement component);
}

/// Runtime type checking for React props and similar objects.
///
/// See: <https://reactjs.org/docs/typechecking-with-proptypes.html>
/// See: <https://www.npmjs.com/package/prop-types>
@JS('React.PropTypes')
abstract class PropTypes {
  /// PropTypes.checkPropTypes(...) only console.error(...)s a given message once.
  /// To reset the cache while testing call PropTypes.resetWarningCache()
  ///
  /// See: <https://www.npmjs.com/package/prop-types#proptypesresetwarningcache>
  external static resetWarningCache();
}

// ----------------------------------------------------------------------------
//   Types and data structures
// ----------------------------------------------------------------------------

/// A React class specification returned by `React.createClass`.
///
/// To be used as the value of [ReactElement.type], which is set upon initialization
/// by a component factory or by [React.createElement].
///
/// See: <https://reactjs.org/docs/react-api.html#components>
@JS()
@anonymous
class ReactClass {
  /// The cached, unmodifiable copy of [Component2.defaultProps] computed in
  /// [registerComponent2].
  ///
  /// For use in `ReactDartComponentFactoryProxy2` when creating new [ReactElement]s,
  /// or for external use involving inspection of Dart prop defaults.
  external JsMap get defaultProps;
  external set defaultProps(JsMap value);

  /// The `displayName` string is used in debugging messages.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#displayname>
  external String get displayName;
  external set displayName(String value);

  /// The cached, unmodifiable copy of [Component.getDefaultProps] computed in
  /// [registerComponent].
  ///
  /// For use in `ReactDartComponentFactoryProxy` when creating new [ReactElement]s,
  /// or for external use involving inspection of Dart prop defaults.
  @Deprecated('7.0.0`')
  external Map get dartDefaultProps;
  @Deprecated('7.0.0`')
  external set dartDefaultProps(Map value);

  /// A string to distinguish between different Dart component implementations / base classes.
  ///
  /// See [ReactDartComponentVersion] for values.
  ///
  /// __For internal use only.__
  @protected
  external String get dartComponentVersion;
  @protected
  external set dartComponentVersion(String value);
}

/// Constants for use with [ReactClass.dartComponentVersion] to distinguish
/// different versions of Dart component implementations / base classes.
///
/// __For internal use only.__
@protected
@sealed
abstract class ReactDartComponentVersion {
  /// A [Component]-based component.
  @protected
  static const String component = '1';

  /// A [Component2]-based component.
  @protected
  static const String component2 = '2';

  /// Returns [ReactClass.dartComponentVersion] if [type] is the [ReactClass] for a Dart component
  /// (a react-dart [ReactElement] or [ReactComponent]), and null otherwise.
  @protected
  static String fromType(dynamic type) {
    // This check doesn't do much since ReactClass is an anonymous JS object,
    // but it lets us safely cast to ReactClass.
    if (type is ReactClass) {
      return type.dartComponentVersion;
    }
    if (type is Function) {
      return getProperty(type, 'dartComponentVersion');
    }

    return null;
  }
}

/// A JS interop class used as an argument to [React.createClass].
///
/// See: <https://reactjs.org/docs/react-api.html#components>.
///
/// > __DEPRECATED.__
/// >
/// > Will be removed alongside [React.createClass] in the `7.0.0` release.
@Deprecated('7.0.0')
@JS()
@anonymous
class ReactClassConfig {
  external factory ReactClassConfig({
    String displayName,
    List mixins,
    Function componentWillMount,
    Function componentDidMount,
    Function componentWillReceiveProps,
    Function shouldComponentUpdate,
    Function componentWillUpdate,
    Function componentDidUpdate,
    Function componentWillUnmount,
    Function getChildContext,
    Map<String, dynamic> childContextTypes,
    Function getDefaultProps,
    Function getInitialState,
    Function render,
  });

  /// The `displayName` string is used in debugging messages.
  ///
  /// See: <https://reactjs.org/docs/react-component.html#displayname>
  external String get displayName;
  external set displayName(String value);
}

/// Interop class for the data structure at `ReactElement._store`.
///
/// Used to validate variadic children before they get to [React.createElement].
@JS()
@anonymous
class ReactElementStore {
  external bool get validated;
  external set validated(bool value);
}

/// A virtual DOM element representing an instance of a DOM element,
/// React component, or fragment.
///
/// React elements are the building blocks of React applications.
/// One might confuse elements with a more widely known concept of "components".
/// An element describes what you want to see on the screen. React elements are immutable.
///
/// Typically, elements are not used directly, but get returned from components.
///
/// These can be created directly by [React.createElement], or by invoking
/// React element DOM/component factories.
///
///     react.h1({}, 'Content here');
///     MaterialButton({}, 'Click me');
///
/// See <https://reactjs.org/docs/glossary.html#elements>
/// and <https://reactjs.org/docs/glossary.html#components>.
@JS()
@anonymous
class ReactElement {
  external ReactElementStore get _store; // ignore: unused_element

  /// The type of this element.
  ///
  /// For DOM components, this will be a [String] tagName (e.g., `'div'`, `'a'`).
  ///
  /// For composite components (react-dart or pure JS), this will be a [ReactClass].
  external dynamic get type;

  /// The props this element was created with.
  external InteropProps get props;

  /// This element's `key`, which is used to uniquely identify it among its siblings.
  ///
  /// Not needed when children are passed variadically
  /// (as arguments to a factory, as opposed to items within a list/iterable).
  ///
  /// See: <https://reactjs.org/docs/reconciliation.html#keys>.
  external String get key;

  /// This element's `ref`, which can be used to access the associated
  /// [Component]/[ReactComponent]/[Element] after it has been rendered.
  ///
  /// See: <https://reactjs.org/docs/refs-and-the-dom.html>.
  external dynamic get ref;
}

/// A virtual DOM node representing a React Portal, returned by [ReactDom.createPortal].
///
/// Portals provide a first-class way to render children into a DOM node that exists outside the DOM hierarchy of the parent component.
///
/// Children can be any renderable React child, such as an element, string, or fragment.
///
/// While closely related, portals are not [ReactElement]s.
///
/// See: <https://reactjs.org/docs/portals.html>
@JS()
@anonymous
class ReactPortal {
  external dynamic /* ReactNodeList */ get children;
  external dynamic get containerInfo;
}

/// The JavaScript component instance, which backs each react-dart [Component].
///
/// See: <https://reactjs.org/docs/glossary.html#react-components>
@JS()
@anonymous
class ReactComponent {
  // TODO: Cast as Component2 in 7.0.0
  external Component get dartComponent;
  // TODO how to make this JsMap without breaking stuff?
  external InteropProps get props;
  external dynamic get context;
  external JsMap get state;
  external set state(JsMap value);
  external get refs;
  external void setState(state, [callback]);
  external void forceUpdate([callback]);
}

// ----------------------------------------------------------------------------
//   Interop internals
// ----------------------------------------------------------------------------

/// A JavaScript interop class representing a value in a React JS `context` object.
///
/// Used for storing/accessing Dart [ReactDartContextInternal] objects in `context`
/// in a way that's opaque to the JS, and avoids the need to use dart2js interceptors.
///
/// __For internal/advanced use only.__
///
/// > __DEPRECATED - DO NOT USE__
/// >
/// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
/// > in ReactJS 16 that is exposed via the [Component2] class.
/// >
/// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
@Deprecated('7.0.0')
@JS()
@anonymous
class InteropContextValue {
  external factory InteropContextValue();
}

/// A JavaScript interop class representing the return value of `createContext`.
///
/// Used for accessing Dart [Context.Provider] & [Context.Consumer] components.
///
/// __For internal/advanced use only.__
@JS()
@anonymous
class ReactContext {
  external ReactClass get Provider;
  external ReactClass get Consumer;
}

/// A JavaScript interop class representing a React JS `props` object.
///
/// Used for storing/accessing [ReactDartComponentInternal] objects in
/// react-dart [ReactElement]s and [ReactComponent]s, as well as for preparing
/// reserved props (`key` and `ref`) for consumption by ReactJS.
///
/// __For internal/advanced use only.__
@JS()
@anonymous
class InteropProps implements JsMap {
  /// __Deprecated.__
  ///
  /// This has been deprecated along with `Component` since its
  /// replacement - `Component2` utilizes JS Maps for props,
  /// making `internal` obsolete.
  ///
  /// Will be removed alongside `Component` in the `7.0.0` release.
  @Deprecated('7.0.0')
  external ReactDartComponentInternal get internal;
  external dynamic get key;
  external dynamic get ref;

  external set key(dynamic value);
  external set ref(dynamic value);

  /// __Deprecated.__
  ///
  /// This has been deprecated along with `Component` since its
  /// replacement - `Component2` utilizes JS Maps for props,
  /// making `InteropProps` obsolete.
  ///
  /// Will be removed alongside `Component` in the `7.0.0` release.
  @Deprecated('7.0.0')
  external factory InteropProps({
    ReactDartComponentInternal internal,
    String key,
    dynamic ref,
  });
}

/// __Deprecated.__
///
/// This has been deprecated along with `Component` since its
/// replacement - `Component2` utilizes JS Maps for props,
/// making `InteropProps` obsolete.
///
/// Will be removed alongside `Component` in the `7.0.0` release.
///
/// > Internal react-dart information used to proxy React JS lifecycle to Dart
/// > [Component] instances.
/// >
/// > __For internal/advanced use only.__
@Deprecated('7.0.0')
class ReactDartComponentInternal {
  /// For a `ReactElement`, this is the initial props with defaults merged.
  ///
  /// For a `ReactComponent`, this is the props the component was last rendered with,
  /// and is used within props-related lifecycle internals.
  Map props;
}

/// Internal react-dart information used to proxy React JS lifecycle to Dart
/// [Component] instances.
///
/// __For internal/advanced use only.__
///
/// > __DEPRECATED - DO NOT USE__
/// >
/// > This API was never stable in any version of ReactJS, and was replaced with a new, incompatible context API
/// > in ReactJS 16 that is exposed via the [Component2] class.
/// >
/// > This will be completely removed when the JS side of it is slated for removal (ReactJS 18 / react.dart 7.0.0)
@Deprecated('7.0.0')
class ReactDartContextInternal {
  final dynamic value;

  ReactDartContextInternal(this.value);
}

/// Creates a new JS Error object with the provided message.
@JS('Error')
class JsError {
  external JsError(message);
}

/// A JS variable that can be used with Dart interop in order to force returning a JavaScript `null`.
/// Use this if dart2js is possibly converting Dart `null` into `undefined`.
@JS('_jsNull')
external get jsNull;

/// A JS variable that can be used with Dart interop in order to force returning a JavaScript `undefined`.
/// Use this if dart2js is possibly converting Dart `undefined` into `null`.
@JS('_jsUndefined')
external get jsUndefined;

/// Throws the error passed to it from Javascript.
/// This allows us to catch the error in dart which re-dartifies the js errors/exceptions.
@alwaysThrows
@JS('_throwErrorFromJS')
external void throwErrorFromJS(error);

/// Marks [child] as validated, as if it were passed into [React.createElement]
/// as a variadic child.
///
/// Offloaded to the JS to avoid dart2js interceptor lookup.
@JS('_markChildValidated')
external void markChildValidated(child);

/// Mark each child in [children] as validated so that React doesn't emit key warnings.
///
/// ___Only for use with variadic children.___
void markChildrenValidated(List<dynamic> children) {
  for (final child in children) {
    // Use `isValidElement` since `is ReactElement` doesn't behave as expected.
    if (React.isValidElement(child)) {
      markChildValidated(child);
    }
  }
}

/// Returns a new JS [ReactClass] for a component that uses
/// [dartInteropStatics] and [componentStatics] internally to proxy between
/// the JS and Dart component instances.
///
/// > __DEPRECATED.__
/// >
/// > Will be removed in `7.0.0` alongside [Component].
@JS('_createReactDartComponentClass')
@Deprecated('7.0.0')
external ReactClass createReactDartComponentClass(
    ReactDartInteropStatics dartInteropStatics, ComponentStatics componentStatics,
    [JsComponentConfig jsConfig]);

/// Returns a new JS [ReactClass] for a component that uses
/// [dartInteropStatics] and [componentStatics] internally to proxy between
/// the JS and Dart component instances.
///
/// See `_ReactDartInteropStatics2.staticsForJs`]` for an example implementation.
@JS('_createReactDartComponentClass2')
external ReactClass createReactDartComponentClass2(JsMap dartInteropStatics, ComponentStatics2 componentStatics,
    [JsComponentConfig2 jsConfig]);

@JS('React.__isDevelopment')
external bool get _inReactDevMode;

/// Whether the "dev" build of react.js is being used.
///
/// Useful for creating conditional logic based on whether your application is being served in a production environment.
///
///     if (inReactDevMode) {
///       print('Debug info that only developers should see.');
///     }
///
/// > This value will be `true` if your HTML page includes `react.js` or `react_with_addons.js`,
///   and `false` if your HTML page includes `react_prod.js` or `react_with_react_dom_prod.js`.
bool get inReactDevMode => _inReactDevMode;

/// An object that stores static methods used by all Dart components.
///
/// __Deprecated.__
///
/// Will be removed when [Component] is removed in the `7.0.0` release.
@JS()
@anonymous
@Deprecated('7.0.0')
class ReactDartInteropStatics {
  external factory ReactDartInteropStatics({
    Component Function(
      ReactComponent jsThis,
      ReactDartComponentInternal internal,
      InteropContextValue context,
      ComponentStatics componentStatics,
    )
        initComponent,
    InteropContextValue Function(Component component) handleGetChildContext,
    void Function(Component component) handleComponentWillMount,
    void Function(Component component) handleComponentDidMount,
    void Function(
      Component component,
      ReactDartComponentInternal nextInternal,
      InteropContextValue nextContext,
    )
        handleComponentWillReceiveProps,
    bool Function(Component component, InteropContextValue nextContext) handleShouldComponentUpdate,
    void Function(Component component, InteropContextValue nextContext) handleComponentWillUpdate,
    void Function(Component component, ReactDartComponentInternal prevInternal) handleComponentDidUpdate,
    void Function(Component component) handleComponentWillUnmount,
    dynamic Function(Component component) handleRender,
  });
}

/// An object that stores static methods and information for a specific component class.
///
/// This object is made accessible to a component's JS ReactClass config, which
/// passes it to certain methods in [ReactDartInteropStatics].
///
/// See [ReactDartInteropStatics], [createReactDartComponentClass].
class ComponentStatics {
  final ComponentFactory<Component> componentFactory;
  ComponentStatics(this.componentFactory);
}

/// An object that stores static methods and information for a specific component class.
///
/// This object is made accessible to a component's JS ReactClass config, which
/// passes it to certain methods in `ReactDartInteropStatics2`.
///
/// See `ReactDartInteropStatics2`, [createReactDartComponentClass2].
class ComponentStatics2 {
  final ComponentFactory<Component2> componentFactory;
  final Component2 instanceForStaticMethods;
  final Component2BridgeFactory bridgeFactory;

  ComponentStatics2({
    @required this.componentFactory,
    @required this.instanceForStaticMethods,
    @required this.bridgeFactory,
  });
}

/// Additional configuration passed to [createReactDartComponentClass]
/// that needs to be directly accessible by that JS code.
///
/// > __DEPRECATED - DO NOT USE__
/// >
/// > The `context` API that this supports was never stable in any version of ReactJS,
/// > and was replaced with a new, incompatible context API in ReactJS 16 that is exposed
/// > via the [Component2] class and is supported by [JsComponentConfig2].
/// >
/// > This will be completely removed when the JS side of `context` it is slated for
/// > removal (ReactJS 18 / react.dart 7.0.0)
@Deprecated('7.0.0')
@JS()
@anonymous
class JsComponentConfig {
  external factory JsComponentConfig({
    Iterable<String> childContextKeys,
    Iterable<String> contextKeys,
  });
}

/// Additional configuration passed to [createReactDartComponentClass2]
/// that needs to be directly accessible by that JS code.
@JS()
@anonymous
class JsComponentConfig2 {
  external factory JsComponentConfig2({
    dynamic contextType,
    JsMap defaultProps,
    JsMap propTypes,
    @required List<String> skipMethods,
  });
}

/// Information on an error caught by `componentDidCatch`.
@JS()
@anonymous
class ReactErrorInfo {
  /// The component stack trace associated with this error.
  ///
  /// See: https://reactjs.org/docs/error-boundaries.html#component-stack-traces
  external String get componentStack;
  external set componentStack(String value);

  /// The dart stack trace associated with this error.
  external StackTrace get dartStackTrace;
  external set dartStackTrace(StackTrace stackTrace);
}
