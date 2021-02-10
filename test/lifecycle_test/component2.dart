// ignore_for_file: deprecated_member_use_from_same_package
@JS()
library react.lifecycle_test.component2;

import 'package:js/js.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_client/react_interop.dart';

import 'util.dart';

final SetStateTest = react.registerComponent2(() => _SetStateTest(), skipMethods: [null]);
final DefaultSkipMethodsTest = react.registerComponent2(() => _SetStateTest());
final SkipMethodsTest = react.registerComponent2(() => _SetStateTest(), skipMethods: ['getSnapshotBeforeUpdate']);

class _SetStateTest extends react.Component2 with LifecycleTestHelper {
  @override
  get defaultProps => {
        'shouldUpdate': true,
      };

  @override
  get initialState => {
        'counter': 1,
        'shouldThrow': true,
        'errorFromGetDerivedState': '',
        'error': '',
        'info': '',
      };

  @override
  Map getDerivedStateFromProps(_, __) {
    lifecycleCall('getDerivedStateFromProps');
    return {};
  }

  @override
  getSnapshotBeforeUpdate(_, __) {
    lifecycleCall('getSnapshotBeforeUpdate');
  }

  @override
  componentDidUpdate(_, __, [___]) {
    lifecycleCall('componentDidUpdate');
  }

  @override
  shouldComponentUpdate(_, __) {
    lifecycleCall('shouldComponentUpdate');
    return props['shouldUpdate'] as bool;
  }

  @override
  componentDidCatch(dynamic error, ReactErrorInfo info) {
    lifecycleCall('componentDidCatch', arguments: [error, info]);
    setState({'error': error, 'info': info.componentStack});
  }

  @override
  Map getDerivedStateFromError(error) {
    lifecycleCall('getDerivedStateFromError', arguments: [error]);
    return {'shouldThrow': false, 'errorFromGetDerivedState': error};
  }

  Map outerTransactionalSetStateCallback(Map previousState, __) {
    lifecycleCall('outerTransactionalSetStateCallback');
    return {'counter': previousState['counter'] + 1};
  }

  Map innerTransactionalSetStateCallback(Map previousState, __) {
    lifecycleCall('innerTransactionalSetStateCallback');
    return {'counter': previousState['counter'] + 1};
  }

  @override
  render() {
    lifecycleCall('render');

    if (!state['shouldThrow']) {
      return react.div({
        'onClick': (_) {
          setStateWithUpdater(outerTransactionalSetStateCallback, () {
            lifecycleCall('outerSetStateCallback');
          });
        }
      }, [
        react.div({
          'onClick': (_) {
            setStateWithUpdater(innerTransactionalSetStateCallback, () {
              lifecycleCall('innerSetStateCallback');
            });
          },
          'key': 'c1',
        }, state['counter']),
        react.div({'key': 'c2'}, state['error'].toString()),
        react.div({'key': 'c3'}, state['info'].toString()),
        react.div({'key': 'c4'}, state['errorFromGetDerivedState'].toString()),
      ]);
    } else {
      return react.div(
          {
            'onClick': (_) {
              setStateWithUpdater(outerTransactionalSetStateCallback, () {
                lifecycleCall('outerSetStateCallback');
              });
            }
          },
          react.div({
            'onClick': (_) {
              setStateWithUpdater(innerTransactionalSetStateCallback, () {
                lifecycleCall('innerSetStateCallback');
              });
            }
          }, [
            state['shouldThrow'] ? ErrorComponent({'key': 'errorComp'}) : null,
            state['counter']
          ]));
    }
  }
}

_DefaultPropsCachingTest defaultPropsCachingTestComponentFactory() => _DefaultPropsCachingTest();

class _DefaultPropsCachingTest extends react.Component2 implements DefaultPropsCachingTestHelper {
  static int getDefaultPropsCallCount = 0;

  @override
  int get staticGetDefaultPropsCallCount => getDefaultPropsCallCount;

  @override
  set staticGetDefaultPropsCallCount(int value) => getDefaultPropsCallCount = value;

  @override
  get defaultProps {
    getDefaultPropsCallCount++;
    return {'getDefaultPropsCallCount': getDefaultPropsCallCount};
  }

  @override
  render() => null;
}

final DefaultPropsTest = react.registerComponent2(() => _DefaultPropsTest());

class _DefaultPropsTest extends react.Component2 {
  @override
  get defaultProps => const {'defaultProp': 'default'};

  @override
  render() => null;
}

final PropTypesTest = react.registerComponent2(() => PropTypesTestComponent());

class PropTypesTestComponent extends react.Component2 {
  @override
  get propTypes => {
        // ignore: avoid_types_on_closure_parameters
        'intProp': (Map props, info) {
          final propValue = props[info.propName];
          if (propValue is! int) {
            return ArgumentError(
                '${info.propName} should be int. {"props": "$props", "propName": "${info.propName}", "componentName": "${info.componentName}", "location": "${info.location}", "propFullName": "${info.propFullName}"}');
          }
          return null;
        }
      };

  @override
  render() => null;
}

react.Context LifecycleTestContext = react.createContext();

final ContextConsumerWrapper = react.registerComponent2(() => _ContextConsumerWrapper());

class _ContextConsumerWrapper extends react.Component2 with LifecycleTestHelper {
  @override
  render() {
    return LifecycleTestContext.Consumer({}, props['children'].first);
  }
}

final ContextWrapper = react.registerComponent2(() => _ContextWrapper());

class _ContextWrapper extends react.Component2 with LifecycleTestHelper {
  @override
  render() {
    return LifecycleTestContext.Provider(
      {
        'value': {'foo': props['foo']}
      },
      props['children'],
    );
  }
}

final LifecycleTestWithContext = react.registerComponent2(() => _LifecycleTestWithContext());

class _LifecycleTestWithContext extends _LifecycleTest {
  @override
  get contextType => LifecycleTestContext;
}

final ErrorComponent = react.registerComponent2(() => _ErrorComponent());

class TestDartException implements Exception {
  int code;
  String message;

  TestDartException(this.message, this.code);

  @override
  toString() {
    return message;
  }
}

class _ErrorComponent extends react.Component2 {
  void _throwError() {
    throw TestDartException('It crashed!', 100);
  }

  @override
  render() {
    _throwError();
    return react.div({'key': 'defaultMessage'}, 'Error');
  }
}

final ErrorLifecycleTest = react.registerComponent2(() => _LifecycleTest(), skipMethods: []);
final LifecycleTest = react.registerComponent2(() => _LifecycleTest());

class _LifecycleTest extends react.Component2 with LifecycleTestHelper {
  @override
  void componentDidMount() => lifecycleCall('componentDidMount');
  @override
  void componentWillUnmount() => lifecycleCall('componentWillUnmount');

  @override
  Map getDerivedStateFromProps(nextProps, prevState) => lifecycleCall('getDerivedStateFromProps',
      arguments: [Map.from(nextProps), Map.from(prevState)], staticProps: nextProps);

  @override
  dynamic getSnapshotBeforeUpdate(prevProps, prevState) =>
      lifecycleCall('getSnapshotBeforeUpdate', arguments: [Map.from(prevProps), Map.from(prevState)]);

  @override
  void componentDidUpdate(prevProps, prevState, [snapshot]) =>
      lifecycleCall('componentDidUpdate', arguments: [Map.from(prevProps), Map.from(prevState), snapshot]);

  @override
  void componentDidCatch(error, info) => lifecycleCall('componentDidCatch', arguments: [error, info]);

  @override
  getDerivedStateFromError(error) => lifecycleCall('getDerivedStateFromError', arguments: [error]);

  @override
  bool shouldComponentUpdate(nextProps, nextState) => lifecycleCall('shouldComponentUpdate',
      arguments: [Map.from(nextProps), Map.from(nextState)], defaultReturnValue: () => true);

  @override
  render() => lifecycleCall('render', defaultReturnValue: () => react.div({}));

  @override
  get initialState => lifecycleCall('initialState', defaultReturnValue: () => {});

  @override
  get defaultProps => lifecycleCall('defaultProps', defaultReturnValue: () => {'defaultProp': 'default'});
}

final NoGetDerivedStateFromErrorLifecycleTest =
    react.registerComponent2(() => _NoGetDerivedStateFromErrorLifecycleTest(), skipMethods: []);

class _NoGetDerivedStateFromErrorLifecycleTest extends react.Component2 with LifecycleTestHelper {
  @override
  void componentDidMount() => lifecycleCall('componentDidMount');
  @override
  void componentWillUnmount() => lifecycleCall('componentWillUnmount');

  @override
  getDerivedStateFromProps(nextProps, prevState) => lifecycleCall('getDerivedStateFromProps',
      arguments: [Map.from(nextProps), Map.from(prevState)], staticProps: nextProps);

  @override
  dynamic getSnapshotBeforeUpdate(prevProps, prevState) =>
      lifecycleCall('getSnapshotBeforeUpdate', arguments: [Map.from(prevProps), Map.from(prevState)]);

  @override
  void componentDidUpdate(prevProps, prevState, [snapshot]) =>
      lifecycleCall('componentDidUpdate', arguments: [Map.from(prevProps), Map.from(prevState), snapshot]);

  @override
  void componentDidCatch(error, info) => lifecycleCall('componentDidCatch', arguments: [error, info]);

  @override
  bool shouldComponentUpdate(nextProps, nextState) => lifecycleCall('shouldComponentUpdate',
      arguments: [Map.from(nextProps), Map.from(nextState)], defaultReturnValue: () => true);

  @override
  render() => lifecycleCall('render', defaultReturnValue: () => react.div({}));

  @override
  get initialState => lifecycleCall('initialState', defaultReturnValue: () => {});

  @override
  get defaultProps => lifecycleCall('defaultProps', defaultReturnValue: () => {'defaultProp': 'default'});
}
