// ignore_for_file: deprecated_member_use_from_same_package
@TestOn('browser')

import 'package:react/react.dart';
import 'package:test/test.dart';

main() {
  group('Component2', () {
    Component2 component;

    setUpAll(() {
      component = MyComponent();
    });

    group('throws when unsupported lifecycle methods are called (e.g., via super-calls)', () {
      test('getInitialState', () {
        expect(() => component.getInitialState(), throwsUnsupportedError);
      });
      test('getDefaultProps', () {
        expect(() => component.getDefaultProps(), throwsUnsupportedError);
      });
      test('componentWillMount', () {
        expect(() => component.componentWillMount(), throwsUnsupportedError);
      });
      test('componentWillReceiveProps', () {
        expect(() => component.componentWillReceiveProps(null), throwsUnsupportedError);
      });
      test('componentWillUpdate', () {
        expect(() => component.componentWillUpdate(null, null), throwsUnsupportedError);
      });
      test('getChildContext', () {
        expect(() => component.getChildContext(), throwsUnsupportedError);
      });
      test('shouldComponentUpdateWithContext', () {
        expect(() => component.shouldComponentUpdateWithContext(null, null, null), throwsUnsupportedError);
      });
      test('componentWillUpdateWithContext', () {
        expect(() => component.componentWillUpdateWithContext(null, null, null), throwsUnsupportedError);
      });
      test('componentWillReceivePropsWithContext', () {
        expect(() => component.componentWillReceivePropsWithContext(null, null), throwsUnsupportedError);
      });
    });

    group('throws when unsupported members inherited from Component are used', () {
      test('replaceState', () {
        expect(() => component.replaceState(null), throwsUnsupportedError);
      });
      test('childContextKeys getter', () {
        expect(() => component.childContextKeys, throwsUnsupportedError);
      });
      test('contextKeys getter', () {
        expect(() => component.contextKeys, throwsUnsupportedError);
      });
      test('initComponentInternal', () {
        expect(() => component.initComponentInternal(null, null), throwsUnsupportedError);
      });
      test('initStateInternal', () {
        expect(() => component.initStateInternal(), throwsUnsupportedError);
      });
      test('nextContext getter', () {
        expect(() => component.nextContext, throwsUnsupportedError);
      });
      test('nextContext setter', () {
        expect(() => component.nextContext = null, throwsUnsupportedError);
      });
      test('prevContext getter', () {
        expect(() => component.prevContext, throwsUnsupportedError);
      });
      test('prevContext setter', () {
        expect(() => component.prevContext = null, throwsUnsupportedError);
      });
      test('prevState getter', () {
        expect(() => component.prevState, throwsUnsupportedError);
      });
      test('nextState getter', () {
        expect(() => component.nextState, throwsUnsupportedError);
      });
      test('nextProps getter', () {
        expect(() => component.nextProps, throwsUnsupportedError);
      });
      test('transferComponentState', () {
        expect(() => component.transferComponentState(), throwsUnsupportedError);
      });
      test('ref getter', () {
        expect(() => component.ref, throwsUnsupportedError);
      });
      test('setStateCallbacks getter', () {
        expect(() => component.setStateCallbacks, throwsUnsupportedError);
      });
      test('transactionalSetStateCallbacks getter', () {
        expect(() => component.transactionalSetStateCallbacks, throwsUnsupportedError);
      });
    });
  });
}

class MyComponent extends Component2 {
  @override
  render() => null;
}
