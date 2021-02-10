@JS()
@TestOn('browser')
library react.js_factory_test;

import 'dart:html';

import 'package:js/js.dart';
import 'package:react/react_client.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_test_utils.dart';
import 'package:test/test.dart';

import 'common_factory_tests.dart';

main() {
  group('ReactJsComponentFactoryProxy', () {
    group('(class component)', () {
      group('- common factory behavior -', () {
        commonFactoryTests(JsFoo);
      });

      group('- dom event handler wrapping -', () {
        domEventHandlerWrappingTests(JsFoo);
      });

      group('- refs -', () {
        refTests<ReactComponent>(JsFoo, verifyRefValue: (ref) {
          expect(isCompositeComponentWithTypeV2(ref, JsFoo), isTrue);
        });
      });

      test('has a type corresponding to the backing JS class', () {
        expect(JsFoo.type, equals(_JsFoo));
      });
    });

    group('(function component)', () {
      group('- common factory behavior -', () {
        commonFactoryTests(JsFooFunction);
      });

      group('- dom event handler wrapping -', () {
        domEventHandlerWrappingTests(JsFooFunction);
      });

      group('- refs -', () {
        // This function component forwards the ref to DOM node
        refTests<Element>(JsFooFunction, verifyRefValue: (ref) {
          expect(ref, isA<Element>());
        });
      });

      test('has a type corresponding to the backing JS class', () {
        expect(JsFooFunction.type, equals(_JsFooFunction));
      });
    });
  });
}

@JS()
external ReactClass get _JsFoo;
final JsFoo = ReactJsComponentFactoryProxy(_JsFoo);

@JS()
external ReactClass get _JsFooFunction;
final JsFooFunction = ReactJsComponentFactoryProxy(_JsFooFunction);
