import 'dart:html';
import 'dart:math';

import 'package:react/hooks.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

var hookTestFunctionComponent = react.registerFunctionComponent(HookTestComponent, displayName: 'useStateTest');

HookTestComponent(Map props) {
  final count = useState(1);
  final evenOdd = useState('even');

  useEffect(() {
    if (count.value % 2 == 0) {
      print('count changed to ${count.value.toString()}');
      evenOdd.set('even');
    } else {
      print('count changed to ${count.value.toString()}');
      evenOdd.set('odd');
    }
    return () {
      print('count is changing... do some cleanup if you need to');
    };

    /// This dependency prevents the effect from running every time [evenOdd.value] changes.
  }, [count.value]);

  return react.div({}, [
    react.button({'onClick': (_) => count.set(1), 'key': 'ust1'}, ['Reset']),
    react.button({'onClick': (_) => count.setWithUpdater((prev) => prev + 1), 'key': 'ust2'}, ['+']),
    react.br({'key': 'ust3'}),
    react.p({'key': 'ust4'}, ['${count.value} is ${evenOdd.value}']),
  ]);
}

final MemoTestDemoWrapper = react.registerComponent2(() => _MemoTestDemoWrapper());

class _MemoTestDemoWrapper extends react.Component2 {
  @override
  get initialState => {'localCount': 0, 'someKeyThatMemoShouldIgnore': 0};

  @override
  render() {
    return react.div(
      {'key': 'mtdw'},
      MemoTest({
        'localCount': state['localCount'],
        'someKeyThatMemoShouldIgnore': state['someKeyThatMemoShouldIgnore'],
      }),
      react.button({
        'type': 'button',
        'className': 'btn btn-primary',
        'style': {'marginRight': '10px'},
        'onClick': (_) {
          setState({'localCount': state['localCount'] + 1});
        },
      }, 'Update MemoTest props.localCount value (${state['localCount']})'),
      react.button({
        'type': 'button',
        'className': 'btn btn-primary',
        'onClick': (_) {
          setState({'someKeyThatMemoShouldIgnore': state['someKeyThatMemoShouldIgnore'] + 1});
        },
      }, 'Update prop value that MemoTest will ignore (${state['someKeyThatMemoShouldIgnore']})'),
    );
  }
}

final MemoTest = react.memo2(react.registerFunctionComponent((props) {
  final context = useContext(TestNewContext);
  return react.div(
    {},
    react.p(
      {},
      'useContext counter value: ',
      react.strong({}, context['renderCount']),
    ),
    react.p(
      {},
      'props.localCount value: ',
      react.strong({}, props['localCount']),
    ),
    react.p(
      {},
      'props.someKeyThatMemoShouldIgnore value: ',
      react.strong({}, props['someKeyThatMemoShouldIgnore']),
      ' (should never update)',
    ),
  );
}), areEqual: (prevProps, nextProps) {
  return prevProps['localCount'] == nextProps['localCount'];
});

var useReducerTestFunctionComponent =
    react.registerFunctionComponent(UseReducerTestComponent, displayName: 'useReducerTest');

Map initializeCount(int initialValue) {
  return {'count': initialValue};
}

Map reducer(Map state, Map action) {
  switch (action['type']) {
    case 'increment':
      return {...state, 'count': state['count'] + 1};
    case 'decrement':
      return {...state, 'count': state['count'] - 1};
    case 'reset':
      return initializeCount(action['payload']);
    default:
      return state;
  }
}

UseReducerTestComponent(Map props) {
  final state = useReducerLazy<Map, Map, int>(reducer, props['initialCount'], initializeCount);

  return react.Fragment({}, [
    state.state['count'],
    react.button({
      'key': 'urt1',
      'onClick': (_) => state.dispatch({'type': 'increment'})
    }, [
      '+'
    ]),
    react.button({
      'key': 'urt2',
      'onClick': (_) => state.dispatch({'type': 'decrement'})
    }, [
      '-'
    ]),
    react.button({
      'key': 'urt3',
      'onClick': (_) => state.dispatch({
            'type': 'reset',
            'payload': props['initialCount'],
          })
    }, [
      'reset'
    ]),
  ]);
}

var useCallbackTestFunctionComponent =
    react.registerFunctionComponent(UseCallbackTestComponent, displayName: 'useCallbackTest');

UseCallbackTestComponent(Map props) {
  final count = useState(0);
  final delta = useState(1);

  final increment = useCallback((_) {
    count.setWithUpdater((prev) => prev + delta.value);
  }, [delta.value]);

  final incrementDelta = useCallback((_) {
    delta.setWithUpdater((prev) => prev + 1);
  }, []);

  return react.div({}, [
    react.div({'key': 'ucbt1'}, ['Delta is ${delta.value}']),
    react.div({'key': 'ucbt2'}, ['Count is ${count.value}']),
    react.button({'onClick': increment, 'key': 'ucbt3'}, ['Increment count']),
    react.button({'onClick': incrementDelta, 'key': 'ucbt4'}, ['Increment delta']),
  ]);
}

var useContextTestFunctionComponent =
    react.registerFunctionComponent(UseContextTestComponent, displayName: 'useContextTest');

UseContextTestComponent(Map props) {
  final context = useContext(TestNewContext);
  return react.div({
    'key': 'uct1'
  }, [
    react.div({'key': 'uct2'}, ['useContext counter value is ${context['renderCount']}']),
  ]);
}

int calculateChangedBits(currentValue, nextValue) {
  var result = 1 << 1;
  if (nextValue['renderCount'] % 2 == 0) {
    result |= 1 << 2;
  }
  return result;
}

var TestNewContext = react.createContext<Map>({'renderCount': 0}, calculateChangedBits);

var newContextProviderComponent = react.registerComponent2(() => _NewContextProviderComponent());

class _NewContextProviderComponent extends react.Component2 {
  @override
  get initialState => {'renderCount': 0, 'complexMap': false};

  @override
  render() {
    final provideMap = {'renderCount': state['renderCount']};

    return react.div({
      'key': 'ulasda',
      'style': {
        'marginTop': 20,
      }
    }, [
      react.button({
        'type': 'button',
        'key': 'button',
        'className': 'btn btn-primary',
        'onClick': _onButtonClick,
      }, 'Redraw'),
      react.br({'key': 'break1'}),
      'TestContext.Provider props.value: $provideMap',
      react.br({'key': 'break2'}),
      react.br({'key': 'break3'}),
      TestNewContext.Provider(
        {'key': 'tcp', 'value': provideMap},
        props['children'],
      ),
    ]);
  }

  _onButtonClick(event) {
    setState({'renderCount': state['renderCount'] + 1, 'complexMap': false});
  }
}

var useRefTestFunctionComponent = react.registerFunctionComponent(UseRefTestComponent, displayName: 'useRefTest');

UseRefTestComponent(Map props) {
  final inputValue = useState('');

  final inputRef = useRef<InputElement>();
  final prevInputValueRef = useRef<String>();

  useEffect(() {
    prevInputValueRef.current = inputValue.value;
  });

  return react.Fragment({}, [
    react.p({'key': 'urtKey1'}, ['Current Input: ${inputValue.value}, Previous Input: ${prevInputValueRef.current}']),
    react.input({'key': 'urtKey2', 'ref': inputRef}),
    react.button({'key': 'urtKey3', 'onClick': (_) => inputValue.set(inputRef.current.value)}, ['Update']),
  ]);
}

int fibonacci(int n) {
  if (n <= 1) {
    return 1;
  }
  return fibonacci(n - 1) + fibonacci(n - 2);
}

final useMemoTestFunctionComponent = react.registerFunctionComponent(UseMemoTestComponent, displayName: 'useMemoTest');

UseMemoTestComponent(Map props) {
  final reRender = useState(0);
  final count = useState(35);

  final fib = useMemo(
    () {
      print('calculating fibonacci...');
      return fibonacci(count.value);
    },

    /// This dependency prevents [fib] from being re-calculated every time the component re-renders.
    [count.value],
  );

  return react.Fragment({}, [
    react.div({'key': 'div'}, ['Fibonacci of ${count.value} is $fib']),
    react.button({'key': 'button1', 'onClick': (_) => count.setWithUpdater((prev) => prev + 1)}, ['+']),
    react.button({'key': 'button2', 'onClick': (_) => reRender.setWithUpdater((prev) => prev + 1)}, ['re-render']),
  ]);
}

final useMemoTestFunctionComponent2 =
    react.registerFunctionComponent(UseMemoTestComponent2, displayName: 'useMemoTest2');

UseMemoTestComponent2(Map props) {
  final reRender = useState(0);
  final count = useState(35);

  print('calculating fibonacci...');
  final fib = fibonacci(count.value);

  return react.Fragment({}, [
    react.div({'key': 'div'}, ['Fibonacci of ${count.value} is $fib']),
    react.button({'key': 'button1', 'onClick': (_) => count.setWithUpdater((prev) => prev + 1)}, ['+']),
    react.button({'key': 'button2', 'onClick': (_) => reRender.setWithUpdater((prev) => prev + 1)}, ['re-render']),
  ]);
}

final random = Random();

final randomUseLayoutEffectTestComponent =
    react.registerFunctionComponent(RandomUseLayoutEffectTestComponent, displayName: 'randomUseLayoutEffectTest');

RandomUseLayoutEffectTestComponent(Map props) {
  final value = useState<double>(0);

  useLayoutEffect(() {
    if (value.value == 0) {
      value.set(10 + random.nextDouble() * 200);
    }
  });

  return react.Fragment({}, [
    react.h5({'key': 'randomUseLayout1'}, ['Example using useLayoutEffect:']),
    react.div({'key': 'randomUseLayout2'}, ['value: ${value.value}']),
    react.button({'key': 'randomUseLayout3', 'onClick': (_) => value.set(0)}, ['Change Value']),
    react.br({'key': 'randomUseLayout4'}),
  ]);
}

final randomUseEffectTestComponent =
    react.registerFunctionComponent(RandomUseEffectTestComponent, displayName: 'randomUseEffectTest');

RandomUseEffectTestComponent(Map props) {
  final value = useState<double>(0);

  useEffect(() {
    if (value.value == 0) {
      value.set(10 + random.nextDouble() * 200);
    }
  });

  return react.Fragment({}, [
    react.h5({'key': 'random1'}, ['Example using useEffect (notice flicker):']),
    react.div({'key': 'random2'}, ['value: ${value.value}']),
    react.button({'key': 'random3', 'onClick': (_) => value.set(0)}, ['Change Value']),
  ]);
}

class FancyInputApi {
  final void Function() focus;
  FancyInputApi(this.focus);
}

final FancyInput = react.forwardRef2((props, ref) {
  final inputRef = useRef();

  useImperativeHandle(
    ref,
    () {
      print('FancyInput: useImperativeHandle re-assigns ref.current');
      return FancyInputApi(() => inputRef.current.focus());
    },

    /// Because the return value of createHandle never changes, it is not necessary for ref.current
    /// to be re-set on each render so this dependency list is empty.
    [],
  );

  return react.input({
    'ref': inputRef,
    'value': props['value'],
    'onChange': (e) => props['update'](e.target.value),
    'placeholder': props['placeholder'],
    'style': {'borderColor': props['hasError'] ? 'crimson' : '#999'},
  });
});

final useImperativeHandleTestFunctionComponent =
    react.registerFunctionComponent(UseImperativeHandleTestComponent, displayName: 'useImperativeHandleTest');

UseImperativeHandleTestComponent(Map props) {
  final city = useState('');
  final state = useState('');
  final error = useState('');
  final message = useState('');

  final cityRef = useRef<FancyInputApi>();
  final stateRef = useRef<FancyInputApi>();

  validate(_) {
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(city.value)) {
      message.set('Invalid form!');
      error.set('city');
      cityRef.current.focus();
      return;
    }

    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(state.value)) {
      message.set('Invalid form!');
      error.set('state');
      stateRef.current.focus();
      return;
    }

    error.set('');
    message.set('Valid form!');
  }

  return react.Fragment({}, [
    FancyInput({
      'key': 'fancyInput1',
      'hasError': error.value == 'city',
      'placeholder': 'City',
      'value': city.value,
      'update': city.set,
      'ref': cityRef,
    }, []),
    FancyInput({
      'key': 'fancyInput2',
      'hasError': error.value == 'state',
      'placeholder': 'State',
      'value': state.value,
      'update': state.set,
      'ref': stateRef,
    }, []),
    react.button({'key': 'button1', 'onClick': validate}, ['Validate Form']),
    react.p({'key': 'p1'}, [message.value]),
  ]);
}

final FancyCounter = react.forwardRef2((props, ref) {
  final count = useState(0);

  useImperativeHandle(
    ref,
    () {
      print('FancyCounter: useImperativeHandle re-assigns ref.current');
      return {
        'increment': () => count.setWithUpdater((prev) => prev + props['diff']),
        'decrement': () => count.setWithUpdater((prev) => prev - props['diff']),
      };
    },

    /// This dependency prevents unnecessary calls of createHandle, by only re-assigning
    /// ref.current when `props['diff']` changes.
    [props['diff']],
  );

  return react.div({}, count.value);
});

final useImperativeHandleTestFunctionComponent2 =
    react.registerFunctionComponent(UseImperativeHandleTestComponent2, displayName: 'useImperativeHandleTest2');

UseImperativeHandleTestComponent2(Map props) {
  final diff = useState(1);

  final fancyCounterRef = useRef<Map>();

  return react.Fragment({}, [
    FancyCounter({
      'key': 'fancyCounter1',
      'diff': diff.value,
      'ref': fancyCounterRef,
    }, []),
    react.button({
      'key': 'button1',
      'onClick': (_) => fancyCounterRef.current['increment'](),
    }, [
      'Increment by ${diff.value}'
    ]),
    react.button({
      'key': 'button2',
      'onClick': (_) => fancyCounterRef.current['decrement'](),
    }, [
      'Decrement by ${diff.value}'
    ]),
    react.button({'key': 'button3', 'onClick': (_) => diff.setWithUpdater((prev) => prev + 1)}, ['+']),
  ]);
}

class ChatAPI {
  static void subscribeToFriendStatus(int id, Function handleStatusChange) =>
      handleStatusChange({'isOnline': id % 2 == 0});

  static void unsubscribeFromFriendStatus(int id, Function handleStatusChange) =>
      handleStatusChange({'isOnline': false});
}

// Custom Hook
StateHook<bool> useFriendStatus(int friendID) {
  final isOnline = useState(false);

  void handleStatusChange(Map status) {
    isOnline.set(status['isOnline']);
  }

  useEffect(() {
    ChatAPI.subscribeToFriendStatus(friendID, handleStatusChange);
    return () {
      ChatAPI.unsubscribeFromFriendStatus(friendID, handleStatusChange);
    };
  });

  // Use format function to avoid unnecessarily formatting `isOnline` when the hooks aren't inspected in React DevTools.
  useDebugValue<bool>(isOnline.value, (isOnline) => isOnline ? 'Online' : 'Not Online');

  return isOnline;
}

final FriendListItem = react.registerFunctionComponent((props) {
  final isOnline = useFriendStatus(props['friend']['id']);

  return react.li({
    'style': {'color': isOnline.value ? 'green' : 'black'}
  }, [
    props['friend']['name']
  ]);
}, displayName: 'FriendListItem');

final UseDebugValueTestComponent = react.registerFunctionComponent(
    (props) => react.Fragment({}, [
          FriendListItem({
            'key': 'friend1',
            'friend': {'id': 1, 'name': 'user 1'},
          }, []),
          FriendListItem({
            'key': 'friend2',
            'friend': {'id': 2, 'name': 'user 2'},
          }, []),
          FriendListItem({
            'key': 'friend3',
            'friend': {'id': 3, 'name': 'user 3'},
          }, []),
          FriendListItem({
            'key': 'friend4',
            'friend': {'id': 4, 'name': 'user 4'},
          }, []),
        ]),
    displayName: 'useDebugValueTest');

void main() {
  render() {
    react_dom.render(
        react.Fragment({}, [
          react.h1({'key': 'functionComponentTestLabel'}, ['Function Component Tests']),
          react.h2({'key': 'useStateTestLabel'}, ['useState & useEffect Hook Test']),
          hookTestFunctionComponent({
            'key': 'useStateTest',
          }, []),
          react.br({'key': 'br1'}),
          react.h2({'key': 'useCallbackTestLabel'}, ['useCallback Hook Test']),
          useCallbackTestFunctionComponent({
            'key': 'useCallbackTest',
          }, []),
          react.br({'key': 'br2'}),
          react.h2({'key': 'useContextTestLabel'}, ['useContext Hook Test']),
          newContextProviderComponent({
            'key': 'provider',
          }, [
            useContextTestFunctionComponent({
              'key': 'useContextTest',
            }, []),
          ]),
          react.br({'key': 'br3'}),
          react.h2({'key': 'useReducerTestLabel'}, ['useReducer Hook Test']),
          useReducerTestFunctionComponent({
            'key': 'useReducerTest',
            'initialCount': 10,
          }, []),
          react.h2({'key': 'useRefTestLabel'}, ['useRef Hook Test']),
          useRefTestFunctionComponent({
            'key': 'useRefTest',
          }, []),
          react.h2({'key': 'memoTestLabel'}, ['memo Test']),
          newContextProviderComponent(
            {
              'key': 'memoContextProvider',
            },
            MemoTestDemoWrapper({}),
          ),
          react.h2({'key': 'useMemoTestLabel'}, ['useMemo Hook Test']),
          react.h6({'key': 'h61'}, ['With useMemo:']),
          useMemoTestFunctionComponent({
            'key': 'useMemoTest',
          }, []),
          react.br({'key': 'br4'}),
          react.br({'key': 'br5'}),
          react.h6({'key': 'h62'}, ['Without useMemo (notice calculation done on every render):']),
          useMemoTestFunctionComponent2({
            'key': 'useMemoTest2',
          }, []),
          react.h2({'key': 'useLayoutEffectTestLabel'}, ['useLayoutEffect Hook Test']),
          randomUseLayoutEffectTestComponent({
            'key': 'useLayoutEffectTest',
          }, []),
          react.br({'key': 'br6'}),
          randomUseEffectTestComponent({
            'key': 'useLayoutEffectTest2',
          }, []),
          react.h2({'key': 'useImperativeHandleTestLabel'}, ['useImperativeHandle Hook Test']),
          useImperativeHandleTestFunctionComponent({
            'key': 'useImperativeHandleTest',
          }, []),
          useImperativeHandleTestFunctionComponent2({
            'key': 'useImperativeHandleTest2',
          }, []),
          react.br({'key': 'br7'}),
          react.h2({'key': 'useDebugValueTestLabel'}, ['useDebugValue Hook Test']),
          UseDebugValueTestComponent({
            'key': 'useDebugValueTest',
          }, []),
        ]),
        querySelector('#content'));
  }

  render();
}
