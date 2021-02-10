@JS()
library hooks;

import 'package:js/js.dart';
import 'package:react/react.dart';
import 'package:react/react_client/react_interop.dart';

/// The return value of [useState].
///
/// The current value of the state is available via [value] and
/// functions to update it are available via [set] and [setWithUpdater].
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// Learn more: <https://reactjs.org/docs/hooks-state.html>.
class StateHook<T> {
  /// The first item of the pair returned by [React.useState].
  T _value;

  /// The second item in the pair returned by [React.useState].
  void Function(dynamic) _setValue;

  StateHook(T initialValue) {
    final result = React.useState(initialValue);
    _value = result[0];
    _setValue = result[1];
  }

  /// Constructor for [useStateLazy], calls lazy version of [React.useState] to
  /// initialize [_value] to the return value of [init].
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#lazy-initial-state>.
  StateHook.lazy(T Function() init) {
    final result = React.useState(allowInterop(init));
    _value = result[0];
    _setValue = result[1];
  }

  /// The current value of the state.
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#usestate>.
  T get value => _value;

  /// Updates [value] to [newValue].
  ///
  /// See: <https://reactjs.org/docs/hooks-state.html#updating-state>.
  void set(T newValue) => _setValue(newValue);

  /// Updates [value] to the return value of [computeNewValue].
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#functional-updates>.
  void setWithUpdater(T Function(T oldValue) computeNewValue) => _setValue(allowInterop(computeNewValue));
}

/// Adds local state to a [DartFunctionComponent]
/// by returning a [StateHook] with [StateHook.value] initialized to [initialValue].
///
/// > __Note:__ If the [initialValue] is expensive to compute, [useStateLazy] should be used instead.
///
/// __Example__:
///
/// ```dart
/// UseStateTestComponent(Map props) {
///   final count = useState(0);
///
///   return react.div({}, [
///     count.value,
///     react.button({'onClick': (_) => count.set(0)}, ['Reset']),
///     react.button({
///       'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
///     }, ['+']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-state.html>.
StateHook<T> useState<T>(T initialValue) => StateHook(initialValue);

/// Adds local state to a [DartFunctionComponent]
/// by returning a [StateHook] with [StateHook.value] initialized to the return value of [init].
///
/// __Example__:
///
/// ```dart
/// UseStateTestComponent(Map props) {
///   final count = useStateLazy(() {
///     var initialState = someExpensiveComputation(props);
///     return initialState;
///   }));
///
///   return react.div({}, [
///     count.value,
///     react.button({'onClick': (_) => count.set(0)}, ['Reset']),
///     react.button({'onClick': (_) => count.set((prev) => prev + 1)}, ['+']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#lazy-initial-state>.
StateHook<T> useStateLazy<T>(T Function() init) => StateHook.lazy(init);

/// Runs [sideEffect] after every completed render of a [DartFunctionComponent].
///
/// If [dependencies] are given, [sideEffect] will only run if one of the [dependencies] have changed.
/// [sideEffect] may return a cleanup function that is run before the component unmounts or re-renders.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// UseEffectTestComponent(Map props) {
///   final count = useState(1);
///   final evenOdd = useState('even');
///
///   useEffect(() {
///     if (count.value % 2 == 0) {
///       evenOdd.set('even');
///     } else {
///       evenOdd.set('odd');
///     }
///     return () {
///       print('count is changing... do some cleanup if you need to');
///     };
///
///     // This dependency prevents the effect from running every time [evenOdd.value] changes.
///   }, [count.value]);
///
///   return react.div({}, [
///     react.p({}, ['${count.value} is ${evenOdd.value}']),
///     react.button({'onClick': (_) => count.set(count.value + 1)}, ['+']),
///   ]);
/// }
/// ```
///
/// See: <https://reactjs.org/docs/hooks-effect.html#tip-optimizing-performance-by-skipping-effects>.
void useEffect(dynamic Function() sideEffect, [List<Object> dependencies]) {
  final wrappedSideEffect = allowInterop(() {
    final result = sideEffect();
    if (result is Function) {
      return allowInterop(result);
    }

    /// When no cleanup function is returned, [sideEffect] returns undefined.
    return jsUndefined;
  });

  return React.useEffect(wrappedSideEffect, dependencies);
}

/// The return value of [useReducer].
///
/// The current state is available via [state] and action dispatcher is available via [dispatch].
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usereducer>.
class ReducerHook<TState, TAction, TInit> {
  /// The first item of the pair returned by [React.useReducer].
  TState _state;

  /// The second item in the pair returned by [React.useReducer].
  void Function(TAction) _dispatch;

  ReducerHook(TState Function(TState state, TAction action) reducer, TState initialState) {
    final result = React.useReducer(allowInterop(reducer), initialState);
    _state = result[0];
    _dispatch = result[1];
  }

  /// Constructor for [useReducerLazy], calls lazy version of [React.useReducer] to
  /// initialize [_state] to the return value of [init(initialArg)].
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#lazy-initialization>.
  ReducerHook.lazy(
      TState Function(TState state, TAction action) reducer, TInit initialArg, TState Function(TInit) init) {
    final result = React.useReducer(allowInterop(reducer), initialArg, allowInterop(init));
    _state = result[0];
    _dispatch = result[1];
  }

  /// The current state map of the component.
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#usereducer>.
  TState get state => _state;

  /// Dispatches [action] and triggers stage changes.
  ///
  /// > __Note:__ The dispatch function identity is stable and will not change on re-renders.
  ///
  /// See: <https://reactjs.org/docs/hooks-reference.html#usereducer>.
  void dispatch(TAction action) => _dispatch(action);
}

/// Initializes state of a [DartFunctionComponent] to [initialState] and creates a `dispatch` method.
///
/// __Example__:
///
/// ```dart
/// Map reducer(Map state, Map action) {
///   switch (action['type']) {
///     case 'increment':
///       return {...state, 'count': state['count'] + 1};
///     case 'decrement':
///       return {...state, 'count': state['count'] - 1};
///     default:
///       return state;
///   }
/// }
///
/// UseReducerTestComponent(Map props) {
///   final state = useReducer(reducer, {'count': 0});
///
///   return react.Fragment({}, [
///     state.state['count'],
///     react.button({
///       'onClick': (_) => state.dispatch({'type': 'increment'})
///     }, [
///       '+'
///     ]),
///     react.button({
///       'onClick': (_) => state.dispatch({'type': 'decrement'})
///     }, [
///       '-'
///     ]),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usereducer>.
ReducerHook<TState, TAction, TInit> useReducer<TState, TAction, TInit>(
        TState Function(TState state, TAction action) reducer, TState initialState) =>
    ReducerHook(reducer, initialState);

/// Initializes state of a [DartFunctionComponent] to `init(initialArg)` and creates `dispatch` method.
///
/// __Example__:
///
/// ```dart
/// Map initializeCount(int initialValue) {
///   return {'count': initialValue};
/// }
///
/// Map reducer(Map state, Map action) {
///   switch (action['type']) {
///     case 'increment':
///       return {...state, 'count': state['count'] + 1};
///     case 'decrement':
///       return {...state, 'count': state['count'] - 1};
///     case 'reset':
///       return initializeCount(action['payload']);
///     default:
///       return state;
///   }
/// }
///
/// UseReducerTestComponent(Map props) {
///   final ReducerHook<Map, Map, int> state = useReducerLazy(reducer, props['initialCount'], initializeCount);
///
///   return react.Fragment({}, [
///     state.state['count'],
///     react.button({
///       'onClick': (_) => state.dispatch({'type': 'increment'})
///     }, [
///       '+'
///     ]),
///     react.button({
///       'onClick': (_) => state.dispatch({'type': 'decrement'})
///     }, [
///       '-'
///     ]),
///     react.button({
///       'onClick': (_) => state.dispatch({
///         'type': 'reset',
///         'payload': props['initialCount'],
///       })
///     }, [
///       'reset'
///     ]),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#lazy-initialization>.
ReducerHook<TState, TAction, TInit> useReducerLazy<TState, TAction, TInit>(
        TState Function(TState state, TAction action) reducer, TInit initialArg, TState Function(TInit) init) =>
    ReducerHook.lazy(reducer, initialArg, init);

/// Returns a memoized version of [callback] that only changes if one of the [dependencies] has changed.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// UseCallbackTestComponent(Map props) {
///   final count = useState(0);
///   final delta = useState(1);
///
///   var increment = useCallback((_) {
///     count.setWithUpdater((prev) => prev + delta.value);
///   }, [delta.value]);
///
///   var incrementDelta = useCallback((_) {
///     delta.setWithUpdater((prev) => prev + 1);
///   }, []);
///
///   return react.div({}, [
///     react.div({}, ['Delta is ${delta.value}']),
///     react.div({}, ['Count is ${count.value}']),
///     react.button({'onClick': increment}, ['Increment count']),
///     react.button({'onClick': incrementDelta}, ['Increment delta']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usecallback>.
T useCallback<T extends Function>(T callback, List dependencies) =>
    React.useCallback(allowInterop(callback), dependencies);

/// Returns the value of the nearest [Context.Provider] for the provided [context] object every time that context is
/// updated.
///
/// The usage is similar to that of a [Context.Consumer] in that the return type of [useContext] is dependent upon
/// the typing of the value passed into [createContext] and [Context.Provider].
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// Context countContext = createContext(0);
///
/// UseCallbackTestComponent(Map props) {
///   final count = useContext(countContext);
///
///   return react.div({}, [
///     react.div({}, ['The count from context is $count']), // initially renders: 'The count from context is 0'
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usecontext>.
T useContext<T>(Context<T> context) => ContextHelpers.unjsifyNewContext(React.useContext(context.jsThis)) as T;

/// Returns a mutable [Ref] object with [Ref.current] property initialized to [initialValue].
///
/// Changes to the [Ref.current] property do not cause the containing [DartFunctionComponent] to re-render.
///
/// The returned [Ref] object will persist for the full lifetime of the [DartFunctionComponent].
/// Compare to [createRef] which returns a new [Ref] object on each render.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// UseRefTestComponent(Map props) {
///   final inputValue = useState('');
///
///   final inputRef = useRef<InputElement>();
///   final prevInputValueRef = useRef<String>();
///
///   useEffect(() {
///     prevInputValueRef.current = inputValue.value;
///   });
///
///   return react.Fragment({}, [
///     react.p({}, ['Current Input: ${inputValue.value}, Previous Input: ${prevInputValueRef.current}']),
///     react.input({'ref': inputRef}),
///     react.button({'onClick': (_) => inputValue.set(inputRef.current.value)}, ['Update']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#useref>.
Ref<T> useRef<T>([T initialValue]) => Ref.useRefInit(initialValue);

/// Returns a memoized version of the return value of [createFunction].
///
/// If one of the [dependencies] has changed, [createFunction] is run during rendering of the [DartFunctionComponent].
/// This optimization helps to avoid expensive calculations on every render.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// UseMemoTestComponent(Map props) {
///   final count = useState(0);
///
///   final fib = useMemo(
///     () => fibonacci(count.value),
///
///     /// This dependency prevents [fib] from being re-calculated every time the component re-renders.
///     [count.value],
///   );
///
///   return react.Fragment({}, [
///     react.div({}, ['Fibonacci of ${count.value} is $fib']),
///     react.button({'onClick': (_) => count.setWithUpdater((prev) => prev + 1)}, ['+']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usememo>.
T useMemo<T>(T Function() createFunction, [List<dynamic> dependencies]) =>
    React.useMemo(allowInterop(createFunction), dependencies);

/// Runs [sideEffect] synchronously after a [DartFunctionComponent] renders, but before the screen is updated.
///
/// Compare to [useEffect] which runs [sideEffect] after the screen updates.
/// Prefer the standard [useEffect] when possible to avoid blocking visual updates.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// UseLayoutEffectTestComponent(Map props) {
///   final width = useState(0);
///   final height = useState(0);
///
///   Ref textareaRef = useRef();
///
///   useLayoutEffect(() {
///     width.set(textareaRef.current.clientWidth);
///     height.set(textareaRef.current.clientHeight);
///   });
///
///   return react.Fragment({}, [
///     react.div({}, ['textarea width: ${width.value}']),
///     react.div({}, ['textarea height: ${height.value}']),
///     react.textarea({'onClick': (_) => width.set(0), 'ref': textareaRef,}),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#uselayouteffect>.
void useLayoutEffect(dynamic Function() sideEffect, [List<Object> dependencies]) {
  final wrappedSideEffect = allowInterop(() {
    final result = sideEffect();
    if (result is Function) {
      return allowInterop(result);
    }

    /// When no cleanup function is returned, [sideEffect] returns undefined.
    return jsUndefined;
  });

  return React.useLayoutEffect(wrappedSideEffect, dependencies);
}

/// Customizes the [ref] value that is exposed to parent components when using [forwardRef2] by setting `ref.current`
/// to the return value of [createHandle].
///
/// In most cases, imperative code using refs should be avoided.
/// For more information, see <https://reactjs.org/docs/refs-and-the-dom.html#when-to-use-refs>.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// class FancyInputApi {
///   final void Function() focus;
///   FancyInputApi(this.focus);
/// }
///
/// final FancyInput = react.forwardRef2((props, ref) {
///   final inputRef = useRef<InputElement>();
///
///   useImperativeHandle(
///     ref,
///     () => FancyInputApi(() => inputRef.current.focus()),
///
///     /// Because the return value of [createHandle] never changes, it is not necessary for [ref.current]
///     /// to be re-set on each render so this dependency list is empty.
///     [],
///   );
///
///   return react.input({
///     'ref': inputRef,
///     'value': props['value'],
///     'onChange': (e) => props['update'](e.target.value),
///   });
/// });
///
/// UseImperativeHandleTestComponent(Map props) {
///   final inputValue = useState('');
///   final fancyInputRef = useRef<FancyInputApi>();
///
///   return react.Fragment({}, [
///     FancyInput({
///       'value': inputValue.value,
///       'update': inputValue.set,
///       'ref': fancyInputRef,
///     }, []),
///     react.button({'onClick': (_) => fancyInputRef.current.focus()}, ['Focus Input']),
///   ]);
/// }
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#useimperativehandle>.
void useImperativeHandle(dynamic ref, dynamic Function() createHandle, [List<dynamic> dependencies]) =>
    // ref will be a JsRef in forwardRef2, or a Ref in forwardRef. (Or null if no ref is provided)
    //
    // For some reason the ref argument to React.forwardRef is usually a JsRef object no matter the input ref type,
    // but according to React the ref argument to useImperativeHandle and React.forwardRef can be any ref type...
    // - https://github.com/facebook/flow/blob/master@%7B2020-09-08%7D/lib/react.js#L373
    // - https://github.com/facebook/flow/blob/master@%7B2020-09-08%7D/lib/react.js#L305
    // and not just a ref object, so we type it as dynamic here.
    React.useImperativeHandle(ref is Ref ? ref.jsRef : ref, allowInterop(createHandle), dependencies);

/// Displays [value] as a label for a custom hook in React DevTools.
///
/// To [defer formatting](https://reactjs.org/docs/hooks-reference.html#defer-formatting-debug-values) [value] until
/// the hooks are inspected, use optional [format] function.
///
/// > __Note:__ there are two [rules for using Hooks](https://reactjs.org/docs/hooks-rules.html):
/// >
/// > * Only call Hooks at the top level.
/// > * Only call Hooks from inside a [DartFunctionComponent].
///
/// __Example__:
///
/// ```dart
/// class ChatAPI {
///   static void subscribeToFriendStatus(int id, Function handleStatusChange) =>
///       handleStatusChange({'isOnline': id % 2 == 0 ? true : false});
///
///   static void unsubscribeFromFriendStatus(int id, Function handleStatusChange) =>
///       handleStatusChange({'isOnline': false});
/// }
///
/// // Custom Hook
/// StateHook useFriendStatus(int friendID) {
///   final isOnline = useState(false);
///
///   void handleStatusChange(Map status) {
///     isOnline.set(status['isOnline']);
///   }
///
///   useEffect(() {
///     ChatAPI.subscribeToFriendStatus(friendID, handleStatusChange);
///     return () {
///       ChatAPI.unsubscribeFromFriendStatus(friendID, handleStatusChange);
///     };
///   });
///
///   // Use format function to avoid unnecessarily formatting `isOnline` when the hooks aren't inspected in React DevTools.
///   useDebugValue<bool>(isOnline.value, (isOnline) => isOnline ? 'Online' : 'Not Online');
///
///   return isOnline;
/// }
///
/// final FriendListItem = react.registerFunctionComponent((props) {
///   final isOnline = useFriendStatus(props['friend']['id']);
///
///   return react.li({
///     'style': {'color': isOnline.value ? 'green' : 'black'}
///   }, [
///     props['friend']['name']
///   ]);
/// }, displayName: 'FriendListItem');
///
/// final UseDebugValueTestComponent = react.registerFunctionComponent(
///     (Map props) => react.Fragment({}, [
///           FriendListItem({
///             'friend': {'id': 1, 'name': 'user 1'}
///           }, []),
///           FriendListItem({
///             'friend': {'id': 2, 'name': 'user 2'}
///           }, []),
///           FriendListItem({
///             'friend': {'id': 3, 'name': 'user 3'}
///           }, []),
///           FriendListItem({
///             'friend': {'id': 4, 'name': 'user 4'}
///           }, []),
///         ]),
///     displayName: 'useDebugValueTest');
/// ```
///
/// Learn more: <https://reactjs.org/docs/hooks-reference.html#usedebugvalue>.
dynamic useDebugValue<T>(T value, [dynamic Function(T) format]) {
  if (format == null) {
    return React.useDebugValue(value);
  }
  return React.useDebugValue(value, allowInterop(format));
}
