@TestOn('browser')
@JS()
library hooks_test;

import 'dart:html';

import 'package:js/js.dart';
import 'package:react/hooks.dart';
import 'package:react/react.dart' as react;
import 'package:react/react.dart';
import 'package:react/react_client.dart';
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_test_utils.dart' as react_test_utils;
import 'package:test/test.dart';

import 'factory/common_factory_tests.dart';

main() {
  group('React Hooks: ', () {
    group('useState -', () {
      ReactDartFunctionComponentFactoryProxy UseStateTest;
      DivElement textRef;
      DivElement countRef;
      ButtonElement setButtonRef;
      ButtonElement setWithUpdaterButtonRef;

      setUpAll(() {
        final mountNode = DivElement();

        UseStateTest = react.registerFunctionComponent((props) {
          final text = useStateLazy(() {
            return 'initialValue';
          });
          final count = useState(0);

          return react.div({}, [
            react.div({
              'ref': (ref) {
                textRef = ref;
              },
            }, [
              text.value
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              count.value
            ]),
            react.button({
              'onClick': (_) => text.set('newValue'),
              'ref': (ref) {
                setButtonRef = ref;
              },
            }, [
              'Set'
            ]),
            react.button({
              'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
              'ref': (ref) {
                setWithUpdaterButtonRef = ref;
              },
            }, [
              '+'
            ]),
          ]);
        });

        react_dom.render(UseStateTest({}), mountNode);
      });

      test('initializes state correctly', () {
        expect(countRef.text, '0');
      });

      test('Lazy initializes state correctly', () {
        expect(textRef.text, 'initialValue');
      });

      test('StateHook.set updates state correctly', () {
        react_test_utils.Simulate.click(setButtonRef);
        expect(textRef.text, 'newValue');
      });

      test('StateHook.setWithUpdater updates state correctly', () {
        react_test_utils.Simulate.click(setWithUpdaterButtonRef);
        expect(countRef.text, '1');
      });
    });

    group('useEffect -', () {
      testEffectHook(useEffect);
    });

    group('useReducer -', () {
      ReactDartFunctionComponentFactoryProxy UseReducerTest;
      DivElement textRef;
      DivElement countRef;
      ButtonElement addButtonRef;
      ButtonElement subtractButtonRef;
      ButtonElement textButtonRef;

      Map reducer(Map state, Map action) {
        switch (action['type']) {
          case 'increment':
            return {...state, 'count': state['count'] + 1};
          case 'decrement':
            return {...state, 'count': state['count'] - 1};
          case 'changeText':
            return {...state, 'text': action['newText']};
          default:
            return state;
        }
      }

      setUpAll(() {
        final mountNode = DivElement();

        UseReducerTest = react.registerFunctionComponent((props) {
          final state = useReducer(reducer, {
            'text': 'initialValue',
            'count': 0,
          });

          return react.div({}, [
            react.div({
              'ref': (ref) {
                textRef = ref;
              },
            }, [
              state.state['text']
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              state.state['count']
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'changeText', 'newText': 'newValue'}),
              'ref': (ref) {
                textButtonRef = ref;
              },
            }, [
              'Set'
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'increment'}),
              'ref': (ref) {
                addButtonRef = ref;
              },
            }, [
              '+'
            ]),
            react.button({
              'onClick': (_) => state.dispatch({'type': 'decrement'}),
              'ref': (ref) {
                subtractButtonRef = ref;
              },
            }, [
              '-'
            ]),
          ]);
        });

        react_dom.render(UseReducerTest({}), mountNode);
      });

      tearDownAll(() {
        UseReducerTest = null;
      });

      test('initializes state correctly', () {
        expect(countRef.text, '0');
        expect(textRef.text, 'initialValue');
      });

      test('dispatch updates states correctly', () {
        react_test_utils.Simulate.click(textButtonRef);
        expect(textRef.text, 'newValue');

        react_test_utils.Simulate.click(addButtonRef);
        expect(countRef.text, '1');

        react_test_utils.Simulate.click(subtractButtonRef);
        expect(countRef.text, '0');
      });

      group('useReducerLazy', () {
        ButtonElement resetButtonRef;

        Map initializeCount(int initialValue) {
          return {'count': initialValue};
        }

        Map reducer2(Map state, Map action) {
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

        setUpAll(() {
          final mountNode = DivElement();

          UseReducerTest = react.registerFunctionComponent((props) {
            final state = useReducerLazy<Map, Map, int>(reducer2, props['initialCount'], initializeCount);

            return react.div({}, [
              react.div({
                'ref': (ref) {
                  countRef = ref;
                },
              }, [
                state.state['count']
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'reset', 'payload': props['initialCount']}),
                'ref': (ref) {
                  resetButtonRef = ref;
                },
              }, [
                'reset'
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'increment'}),
                'ref': (ref) {
                  addButtonRef = ref;
                },
              }, [
                '+'
              ]),
              react.button({
                'onClick': (_) => state.dispatch({'type': 'decrement'}),
                'ref': (ref) {
                  subtractButtonRef = ref;
                },
              }, [
                '-'
              ]),
            ]);
          });

          react_dom.render(UseReducerTest({'initialCount': 10}), mountNode);
        });

        tearDownAll(() {
          UseReducerTest = null;
        });

        test('initializes state correctly', () {
          expect(countRef.text, '10');
        });

        test('dispatch updates states correctly', () {
          react_test_utils.Simulate.click(addButtonRef);
          expect(countRef.text, '11');

          react_test_utils.Simulate.click(resetButtonRef);
          expect(countRef.text, '10');

          react_test_utils.Simulate.click(subtractButtonRef);
          expect(countRef.text, '9');
        });
      });
    });

    group('useCallback -', () {
      ReactDartFunctionComponentFactoryProxy UseCallbackTest;
      DivElement deltaRef;
      DivElement countRef;
      ButtonElement incrementWithDepButtonRef;
      ButtonElement incrementNoDepButtonRef;
      ButtonElement incrementDeltaButtonRef;

      setUpAll(() {
        final mountNode = DivElement();

        UseCallbackTest = react.registerFunctionComponent((props) {
          final count = useState(0);
          final delta = useState(1);

          final incrementNoDep = useCallback((_) {
            count.setWithUpdater((prev) => prev + delta.value);
          }, []);

          final incrementWithDep = useCallback((_) {
            count.setWithUpdater((prev) => prev + delta.value);
          }, [delta.value]);

          final incrementDelta = useCallback((_) {
            delta.setWithUpdater((prev) => prev + 1);
          }, []);

          return react.div({}, [
            react.div({
              'ref': (ref) {
                deltaRef = ref;
              },
            }, [
              delta.value
            ]),
            react.div({
              'ref': (ref) {
                countRef = ref;
              },
            }, [
              count.value
            ]),
            react.button({
              'onClick': incrementNoDep,
              'ref': (ref) {
                incrementNoDepButtonRef = ref;
              },
            }, [
              'Increment count no dep'
            ]),
            react.button({
              'onClick': incrementWithDep,
              'ref': (ref) {
                incrementWithDepButtonRef = ref;
              },
            }, [
              'Increment count'
            ]),
            react.button({
              'onClick': incrementDelta,
              'ref': (ref) {
                incrementDeltaButtonRef = ref;
              },
            }, [
              'Increment delta'
            ]),
          ]);
        });

        react_dom.render(UseCallbackTest({}), mountNode);
      });

      test('callback is called correctly', () {
        expect(countRef.text, '0');
        expect(deltaRef.text, '1');

        react_test_utils.Simulate.click(incrementNoDepButtonRef);
        expect(countRef.text, '1');

        react_test_utils.Simulate.click(incrementWithDepButtonRef);
        expect(countRef.text, '2');
      });

      group('after depending state changes,', () {
        setUpAll(() {
          react_test_utils.Simulate.click(incrementDeltaButtonRef);
        });

        test('callback stays the same if state not in dependency list', () {
          react_test_utils.Simulate.click(incrementNoDepButtonRef);
          expect(countRef.text, '3', reason: 'still increments by 1 because delta not in dependency list');
        });

        test('callback updates if state is in dependency list', () {
          react_test_utils.Simulate.click(incrementWithDepButtonRef);
          expect(countRef.text, '5', reason: 'increments by 2 because delta updated');
        });
      });
    });

    group('useContext -', () {
      DivElement mountNode;
      _ContextProviderWrapper providerRef;
      var currentCount = 0;
      Context<int> testContext;
      Function useContextTestFunctionComponent;

      setUp(() {
        mountNode = DivElement();

        UseContextTestComponent(Map props) {
          final context = useContext(testContext);
          currentCount = context;
          return react.div({
            'key': 'uct1'
          }, [
            react.div({'key': 'uct2'}, ['useContext counter value is $context']),
          ]);
        }

        testContext = react.createContext(1);
        useContextTestFunctionComponent =
            react.registerFunctionComponent(UseContextTestComponent, displayName: 'useContextTest');

        react_dom.render(
            ContextProviderWrapper({
              'contextToUse': testContext,
              'mode': 'increment',
              'ref': (ref) {
                providerRef = ref;
              }
            }, [
              useContextTestFunctionComponent({'key': 't1'}, []),
            ]),
            mountNode);
      });

      tearDown(() {
        react_dom.unmountComponentAtNode(mountNode);
        mountNode = null;
        currentCount = 0;
        testContext = null;
        useContextTestFunctionComponent = null;
        providerRef = null;
      });

      group('updates with the correct values', () {
        test('on first render', () {
          expect(currentCount, 1);
        });

        test('on value updates', () {
          providerRef.increment();
          expect(currentCount, 2);
          providerRef.increment();
          expect(currentCount, 3);
          providerRef.increment();
          expect(currentCount, 4);
        });
      });
    });

    group('useRef -', () {
      final mountNode = DivElement();
      ReactDartFunctionComponentFactoryProxy UseRefTest;
      ButtonElement reRenderButton;
      var noInitRef;
      var initRef;
      var domElementRef;
      StateHook<int> renderIndex;
      var refFromUseRef;
      var refFromCreateRef;

      setUpAll(() {
        UseRefTest = react.registerFunctionComponent((props) {
          noInitRef = useRef();
          initRef = useRef(mountNode);
          domElementRef = useRef();

          renderIndex = useState(1);
          refFromUseRef = useRef();
          refFromCreateRef = react.createRef();

          refFromUseRef.current ??= renderIndex.value;

          refFromCreateRef.current ??= renderIndex.value;

          return react.Fragment({}, [
            react.input({'ref': domElementRef}),
            react.p({}, [renderIndex.value]),
            react.p({}, [refFromUseRef.current]),
            react.p({}, [refFromCreateRef.current]),
            react.button({
              'ref': (ref) => reRenderButton = ref,
              'onClick': (_) => renderIndex.setWithUpdater((prev) => prev + 1)
            }, [
              're-render'
            ]),
          ]);
        });

        react_dom.render(UseRefTest({}), mountNode);
      });

      group('correctly initializes a Ref object', () {
        test('with current property set to null if no initial value given', () {
          expect(noInitRef, isA<Ref>());
          expect(noInitRef.current, null);
        });

        test('with current property set to the initial value given', () {
          expect(initRef, isA<Ref>());
          expect(initRef.current, mountNode);
        });
      });

      group('the returned Ref', () {
        test('can be attached to elements via the ref attribute', () {
          expect(domElementRef.current, isA<InputElement>());
        });

        test('will persist even after the component re-renders', () {
          expect(renderIndex.value, 1);
          expect(refFromUseRef.current, 1, reason: 'Ref object initially created on first render');
          expect(refFromCreateRef.current, 1);

          react_test_utils.Simulate.click(reRenderButton);

          expect(renderIndex.value, 2);
          expect(refFromUseRef.current, 1,
              reason: 'useRef returns the same Ref object on every render for the full lifetime of the component');
          expect(refFromCreateRef.current, 2,
              reason: 'compare to createRef which creates a new Ref object on every render');
        });
      });
    });

    group('useMemo -', () {
      ReactDartFunctionComponentFactoryProxy UseMemoTest;
      StateHook<int> count;
      ButtonElement reRenderButtonRef;
      ButtonElement incrementButtonRef;

      // Count how many times createFunction() is called for each variation of dependencies.
      var createFunctionCallCountWithDeps = 0;
      var createFunctionCallCountNoDeps = 0;
      var createFunctionCallCountEmptyDeps = 0;

      // Keeps track of return value of useMemo() for each variation of dependencies.
      int returnValueWithDeps;
      int returnValueNoDeps;
      int returnValueEmptyDeps;

      int fibonacci(int n) {
        if (n <= 1) {
          return 1;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
      }

      setUpAll(() {
        final mountNode = DivElement();

        UseMemoTest = react.registerFunctionComponent((props) {
          final reRender = useState(0);
          count = useState(5);

          returnValueWithDeps = useMemo(
            () {
              createFunctionCallCountWithDeps++;
              return fibonacci(count.value);
            },
            [count.value],
          );

          returnValueNoDeps = useMemo(
            () {
              createFunctionCallCountNoDeps++;
              return fibonacci(count.value);
            },
          );

          returnValueEmptyDeps = useMemo(
            () {
              createFunctionCallCountEmptyDeps++;
              return fibonacci(count.value);
            },
            [],
          );

          return react.Fragment({}, [
            react.button(
                {'ref': (ref) => incrementButtonRef = ref, 'onClick': (_) => count.setWithUpdater((prev) => prev + 1)},
                ['+']),
            react.button({
              'ref': (ref) => reRenderButtonRef = ref,
              'onClick': (_) => reRender.setWithUpdater((prev) => prev + 1)
            }, [
              're-render'
            ]),
          ]);
        });

        react_dom.render(UseMemoTest({}), mountNode);
      });

      test('correctly initializes memoized value', () {
        expect(count.value, 5);

        expect(returnValueWithDeps, 8);
        expect(returnValueNoDeps, 8);
        expect(returnValueEmptyDeps, 8);

        expect(createFunctionCallCountWithDeps, 1);
        expect(createFunctionCallCountNoDeps, 1);
        expect(createFunctionCallCountEmptyDeps, 1);
      });

      group('after depending state changes,', () {
        setUpAll(() {
          react_test_utils.Simulate.click(incrementButtonRef);
        });

        test('createFunction does not run if state not in dependency list', () {
          expect(returnValueEmptyDeps, 8);

          expect(createFunctionCallCountEmptyDeps, 1, reason: 'count.value is not in dependency list');
        });

        test('createFunction re-runs if state is in dependency list or if there is no dependency list', () {
          expect(returnValueWithDeps, 13);
          expect(returnValueNoDeps, 13);

          expect(createFunctionCallCountWithDeps, 2, reason: 'count.value is in dependency list');
          expect(createFunctionCallCountNoDeps, 2,
              reason: 'createFunction runs on every render because there is no dependency list');
        });
      });

      group('after component re-renders,', () {
        setUpAll(() {
          react_test_utils.Simulate.click(reRenderButtonRef);
        });

        test('createFunction re-runs if there is no dependency list', () {
          expect(returnValueNoDeps, 13, reason: 'count.value stayed the same so the same value is returned');

          expect(createFunctionCallCountNoDeps, 3,
              reason: 'createFunction runs on every render because there is no dependency list');
        });

        test('createFunction does not run if there is a dependency list', () {
          expect(returnValueEmptyDeps, 8);
          expect(returnValueWithDeps, 13);

          expect(createFunctionCallCountEmptyDeps, 1, reason: 'no dependency changed');
          expect(createFunctionCallCountWithDeps, 2, reason: 'no dependency changed');
        });
      });
    });

    group('useLayoutEffect -', () {
      testEffectHook(useLayoutEffect);
    });

    group('useImperativeHandle -', () {
      group('updates `ref.current` to the return value of `createHandle()`', () {
        final mountNode = DivElement();
        ReactDartFunctionComponentFactoryProxy UseImperativeHandleTest;
        ButtonElement incrementButton;
        ButtonElement reRenderButtonRef1;
        ButtonElement reRenderButtonRef2;
        Ref noDepsRef;
        Ref emptyDepsRef;
        Ref depsRef;
        StateHook<int> count;

        setUpAll(() {
          final NoDepsComponent = react.forwardRef2((props, ref) {
            count = useState(0);

            useImperativeHandle(
              ref,
              () => {'increment': () => count.setWithUpdater((prev) => prev + 1)},
            );

            return react.div({'ref': ref}, count.value);
          });

          final EmptyDepsComponent = react.forwardRef2((props, ref) {
            final count = useState(0);

            useImperativeHandle(ref, () => count.value, []);

            return react.Fragment({}, [
              react.div({'ref': ref}, count.value),
              react.button({
                'ref': (ref) => reRenderButtonRef1 = ref,
                'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
              }, []),
            ]);
          });

          final DepsComponent = react.forwardRef2((props, ref) {
            final count = useState(0);

            useImperativeHandle(ref, () => count.value, [count.value]);

            return react.Fragment({}, [
              react.div({'ref': ref}, count.value),
              react.button({
                'ref': (ref) => reRenderButtonRef2 = ref,
                'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
              }, []),
            ]);
          });

          final NullRefComponent = react.registerFunctionComponent((props) {
            final count = useState(0);
            final Ref someRefThatIsNotSet = props['someRefThatIsNotSet'];

            useImperativeHandle(someRefThatIsNotSet, () => count.value, [count.value]);

            return react.Fragment({}, [
              react.div({'ref': someRefThatIsNotSet}, count.value),
              react.button({
                'ref': (ref) => reRenderButtonRef2 = ref,
                'onClick': (_) => count.setWithUpdater((prev) => prev + 1),
              }, []),
            ]);
          });

          expect(() => react_dom.render(NullRefComponent({}, []), mountNode), returnsNormally,
              reason: 'Hook should not throw if the ref is null');
          react_dom.unmountComponentAtNode(mountNode);

          UseImperativeHandleTest = react.registerFunctionComponent((props) {
            noDepsRef = useRef();
            emptyDepsRef = useRef();
            depsRef = useRef();

            return react.Fragment({}, [
              NoDepsComponent({'ref': noDepsRef}, []),
              react.button({
                'ref': (ref) => incrementButton = ref,
                'onClick': (_) => noDepsRef.current['increment'](),
              }, [
                '+'
              ]),
              EmptyDepsComponent({'ref': emptyDepsRef}),
              DepsComponent({'ref': depsRef}),
            ]);
          });

          react_dom.render(UseImperativeHandleTest({}), mountNode);
        });

        test('(with no dependency list)', () {
          expect(noDepsRef.current, isA<Map>(), reason: 'useImperativeHandle overrides the existing ref.current value');
          expect(noDepsRef.current['increment'], isA<Function>());
          expect(count.value, 0);

          react_test_utils.Simulate.click(incrementButton);
          expect(count.value, 1);
        });

        test('(with empty dependency list)', () {
          expect(emptyDepsRef.current, isA<int>(),
              reason: 'useImperativeHandle overrides the existing ref.current value');
          expect(emptyDepsRef.current, 0);

          react_test_utils.Simulate.click(reRenderButtonRef1);
          expect(emptyDepsRef.current, 0,
              reason: 'current value does not update because count.value is not in dependency list');
        });

        test('(with non-empty dependency list)', () {
          expect(depsRef.current, isA<int>(), reason: 'useImperativeHandle overrides the existing ref.current value');
          expect(depsRef.current, 0);

          react_test_utils.Simulate.click(reRenderButtonRef2);
          expect(depsRef.current, 1, reason: 'current value updates because count.value is in dependency list');
        });
      });

      group('works with all types of consumer refs -', () {
        const customRefValue = {'Am I a ref?': true};
        final factory = react.forwardRef2((props, ref) {
          useImperativeHandle(ref, () => customRefValue);
          return react.div({});
        });

        refTests<Map>(factory, verifyRefValue: (refValue) {
          expect(refValue, same(customRefValue));
        });
      });
    });

    group('useDebugValue -', () {
      ReactDartFunctionComponentFactoryProxy UseDebugValueTest1;
      ReactDartFunctionComponentFactoryProxy UseDebugValueTest2;
      StateHook<bool> isOnline1;
      StateHook<bool> isOnline2;

      StateHook useFriendStatus() {
        final isOnline = useState(false);

        useDebugValue(isOnline.value ? 'Online' : 'Not Online');

        return isOnline;
      }

      StateHook useFriendStatusWithFormatFunction() {
        final isOnline = useState(true);

        useDebugValue(isOnline.value, (value) => value ? 'Online' : 'Not Online');

        return isOnline;
      }

      setUpAll(() {
        final mountNode = DivElement();

        UseDebugValueTest1 = react.registerFunctionComponent((props) {
          isOnline1 = useFriendStatus();

          return react.li({
            'style': {'color': isOnline1.value ? 'green' : 'black'}
          }, [
            props['friend']['name']
          ]);
        });

        UseDebugValueTest2 = react.registerFunctionComponent((props) {
          isOnline2 = useFriendStatusWithFormatFunction();

          return react.li({
            'style': {'color': isOnline2.value ? 'green' : 'black'}
          }, [
            props['friend']['name']
          ]);
        });

        react_dom.render(
            react.Fragment({}, [
              UseDebugValueTest1({
                'key': 'friend1',
                'friend': {'id': 1, 'name': 'user 1'},
              }),
              UseDebugValueTest2({
                'key': 'friend2',
                'friend': {'id': 2, 'name': 'user 2'},
              }),
            ]),
            mountNode);
      });

      test('does not cause errors when used', () {
        expect(isOnline1.value, false);
        expect(useFriendStatus, isA<Function>());
      });

      test('with format function does not cause errors when used', () {
        expect(isOnline2.value, true);
        expect(useFriendStatusWithFormatFunction, isA<Function>());
      });
    });
  });
}

ReactDartComponentFactoryProxy2 ContextProviderWrapper = react.registerComponent2(() => _ContextProviderWrapper());

class _ContextProviderWrapper extends react.Component2 {
  @override
  get initialState {
    return {'counter': 1};
  }

  increment() {
    setState({'counter': state['counter'] + 1});
  }

  @override
  render() {
    return react.div({}, [
      (props['contextToUse'] as Context)
          .Provider({'value': props['mode'] == 'increment' ? state['counter'] : props['value']}, props['children'])
    ]);
  }
}

void testEffectHook(Function effectHook) {
  ReactDartFunctionComponentFactoryProxy UseEffectTest;
  ButtonElement countButtonRef;
  DivElement countRef;
  DivElement mountNode;
  int useEffectCallCount;
  int useEffectCleanupCallCount;
  int useEffectWithDepsCallCount;
  int useEffectCleanupWithDepsCallCount;
  int useEffectWithDepsCallCount2;
  int useEffectCleanupWithDepsCallCount2;
  int useEffectWithEmptyDepsCallCount;
  int useEffectCleanupWithEmptyDepsCallCount;

  setUpAll(() {
    mountNode = DivElement();
    useEffectCallCount = 0;
    useEffectCleanupCallCount = 0;
    useEffectWithDepsCallCount = 0;
    useEffectCleanupWithDepsCallCount = 0;
    useEffectWithDepsCallCount2 = 0;
    useEffectCleanupWithDepsCallCount2 = 0;
    useEffectWithEmptyDepsCallCount = 0;
    useEffectCleanupWithEmptyDepsCallCount = 0;

    UseEffectTest = react.registerFunctionComponent((props) {
      final count = useState(0);
      final countDown = useState(0);

      effectHook(() {
        useEffectCallCount++;
        return () {
          useEffectCleanupCallCount++;
        };
      });

      effectHook(() {
        useEffectWithDepsCallCount++;
        return () {
          useEffectCleanupWithDepsCallCount++;
        };
      }, [count.value]);

      effectHook(() {
        useEffectWithDepsCallCount2++;
        return () {
          useEffectCleanupWithDepsCallCount2++;
        };
      }, [countDown.value]);

      effectHook(() {
        useEffectWithEmptyDepsCallCount++;
        return () {
          useEffectCleanupWithEmptyDepsCallCount++;
        };
      }, []);

      return react.div({}, [
        react.div({
          'ref': (ref) {
            countRef = ref;
          },
        }, [
          count.value
        ]),
        react.button({
          'onClick': (_) {
            count.set(count.value + 1);
          },
          'ref': (ref) {
            countButtonRef = ref;
          },
        }, [
          '+'
        ]),
      ]);
    });

    react_dom.render(UseEffectTest({}), mountNode);
  });

  test('side effect (no dependency list) is called after the first render', () {
    expect(countRef.text, '0');

    expect(useEffectCallCount, 1);
    expect(useEffectCleanupCallCount, 0, reason: 'component has not been unmounted or re-rendered');
  });

  test('side effect (with dependency list) is called after the first render', () {
    expect(useEffectWithDepsCallCount, 1);
    expect(useEffectCleanupWithDepsCallCount, 0, reason: 'component has not been unmounted or re-rendered');

    expect(useEffectWithDepsCallCount2, 1);
    expect(useEffectCleanupWithDepsCallCount2, 0, reason: 'component has not been unmounted or re-rendered');
  });

  test('side effect (with empty dependency list) is called after the first render', () {
    expect(useEffectWithEmptyDepsCallCount, 1);
    expect(useEffectCleanupWithEmptyDepsCallCount, 0, reason: 'component has not been unmounted or re-rendered');
  });

  group('after state change,', () {
    setUpAll(() {
      react_test_utils.Simulate.click(countButtonRef);
    });

    test('side effect (no dependency list) is called again', () {
      expect(countRef.text, '1');

      expect(useEffectCallCount, 2);
      expect(useEffectCleanupCallCount, 1, reason: 'cleanup called before re-render');
    });

    test('side effect (with dependency list) is called again if one of its dependencies changed', () {
      expect(useEffectWithDepsCallCount, 2, reason: 'count.value changed');
      expect(useEffectCleanupWithDepsCallCount, 1, reason: 'cleanup called before re-render');
    });

    test('side effect (with dependency list) is not called again if none of its dependencies changed', () {
      expect(useEffectWithDepsCallCount2, 1, reason: 'countDown.value did not change');
      expect(useEffectCleanupWithDepsCallCount2, 0,
          reason: 'cleanup not called because countDown.value did not change');
    });

    test('side effect (with empty dependency list) is not called again', () {
      expect(useEffectWithEmptyDepsCallCount, 1, reason: 'side effect is only called once for empty dependency list');
      expect(useEffectCleanupWithEmptyDepsCallCount, 0, reason: 'component has not been unmounted');
    });
  });

  group('after component is unmounted,', () {
    setUpAll(() {
      react_dom.unmountComponentAtNode(mountNode);
    });

    test('cleanup (no dependency list) is called', () {
      expect(useEffectCallCount, 2, reason: 'side effect not called on unmount');
      expect(useEffectCleanupCallCount, 2);
    });

    test('cleanup (with dependency list) is called', () {
      expect(useEffectWithDepsCallCount, 2, reason: 'side effect not called on unmount');
      expect(useEffectCleanupWithDepsCallCount, 2);

      expect(useEffectWithDepsCallCount2, 1, reason: 'side effect not called on unmount');
      expect(useEffectCleanupWithDepsCallCount2, 1);
    });

    test('cleanup (with empty dependency list) is called', () {
      expect(useEffectWithEmptyDepsCallCount, 1, reason: 'side effect not called on unmount');
      expect(useEffectCleanupWithEmptyDepsCallCount, 1);
    });
  });
}
