@TestOn('browser')
@JS()
library react_test_utils_test;

import 'dart:html';

import 'package:js/js.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;
import 'package:test/test.dart';

main() {
  group('StrictMode', () {
    test('renders nothing but its children', () {
      var wrappingDivRef;

      react_dom.render(
        react.div({
          'ref': (ref) {
            wrappingDivRef = ref;
          }
        }, [
          react.StrictMode({}, [
            react.div({}),
            react.div({}),
            react.div({}),
            react.div({}),
          ])
        ]),
        Element.div(),
      );

      expect(wrappingDivRef.children, hasLength(4));
    });
  });
}
