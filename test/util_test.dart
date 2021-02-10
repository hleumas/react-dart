@TestOn('browser')
library react.util_test;

import 'dart:js';

import 'package:react/react_client.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:test/test.dart';
import 'package:react/react.dart' as react;
import 'util.dart';

// ignore_for_file: deprecated_member_use_from_same_package, invalid_use_of_protected_member

void main() {
  group('util test', () {
    test('ReactDartComponentVersion.fromType', () {
      expect(ReactDartComponentVersion.fromType(react.div({}).type), isNull);
      expect(ReactDartComponentVersion.fromType(JsFoo({}).type), isNull);
      expect(ReactDartComponentVersion.fromType(Foo({}).type), ReactDartComponentVersion.component);
      expect(ReactDartComponentVersion.fromType(Foo2({}).type), ReactDartComponentVersion.component2);
      expect(ReactDartComponentVersion.fromType(FunctionFoo({}).type), ReactDartComponentVersion.component2);
    });

    test('isDartComponent2', () {
      expect(isDartComponent2(react.div({})), isFalse);
      expect(isDartComponent2(JsFoo({})), isFalse);
      expect(isDartComponent2(Foo({})), isFalse);
      expect(isDartComponent2(Foo2({})), isTrue);
      expect(isDartComponent2(FunctionFoo({})), isTrue);
    });

    test('isDartComponent1', () {
      expect(isDartComponent1(react.div({})), isFalse);
      expect(isDartComponent1(JsFoo({})), isFalse);
      expect(isDartComponent1(Foo({})), isTrue);
      expect(isDartComponent1(Foo2({})), isFalse);
      expect(isDartComponent1(FunctionFoo({})), isFalse);
    });

    test('isDartComponent', () {
      expect(isDartComponent(react.div({})), isFalse);
      expect(isDartComponent(JsFoo({})), isFalse);
      expect(isDartComponent(Foo({})), isTrue);
      expect(isDartComponent(Foo2({})), isTrue);
      expect(isDartComponent(FunctionFoo({})), isTrue);
    });
  });
}

final FunctionFoo = react.registerFunctionComponent(_FunctionFoo);

_FunctionFoo(Map props) {
  return react.div({});
}

final Foo = react.registerComponent(() => _Foo());

class _Foo extends react.Component {
  @override
  render() => react.div({});
}

final Foo2 = react.registerComponent2(() => _Foo2());

class _Foo2 extends react.Component2 {
  @override
  render() => react.div({});
}

final JsFoo = ReactJsComponentFactoryProxy(React.createClass(ReactClassConfig(
  displayName: 'JsFoo',
  render: allowInterop(() => react.div({})),
)));
