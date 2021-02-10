@TestOn('browser')
library react.forward_ref_test;

// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:js_util';

import 'package:react/react.dart' as react;
import 'package:react/react_client/react_interop.dart';
import 'package:test/test.dart';

import 'factory/common_factory_tests.dart';

main() {
  group('forwardRef', () {
    group('- common factory behavior -', () {
      // ignore: deprecated_member_use_from_same_package
      final ForwardRefTest = react.forwardRef((props, ref) {
        props['onDartRender']?.call(props);
        return react.div({...props, 'ref': ref});
      });

      commonFactoryTests(
        ForwardRefTest,
        // ignore: invalid_use_of_protected_member
        dartComponentVersion: ReactDartComponentVersion.component2,
        // Dart props passed to forwardRef get converted when they shouldn't, so these tests fail.
        // This is part of why forwardRef is deprecated.
        skipPropValuesTest: true,
      );
    });

    // Ref behavior is tested functionally for all factory types in commonFactoryTests

    group('sets displayName on the rendered component as expected', () {
      test('falling back to "Anonymous" when the displayName argument is not passed to forwardRef', () {
        final ForwardRefTestComponent = forwardRef((props, ref) {});
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'displayName'), 'Anonymous');
      });

      test('when displayName argument is passed to forwardRef', () {
        const name = 'ForwardRefTestComponent';
        final ForwardRefTestComponent = forwardRef((props, ref) {}, displayName: name);
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'displayName'), name);
      });
    });
  });

  group('forwardRef2', () {
    group('- common factory behavior -', () {
      final ForwardRef2Test = react.forwardRef2((props, ref) {
        props['onDartRender']?.call(props);
        props['onDartRenderWithRef']?.call(props, ref);
        return react.div({...props, 'ref': ref});
      });

      commonFactoryTests(
        ForwardRef2Test,
        // ignore: invalid_use_of_protected_member
        dartComponentVersion: ReactDartComponentVersion.component2,
      );
    });

    // Ref behavior is tested functionally for all factory types in commonFactoryTests

    group('sets name on the rendered component as expected', () {
      test('unless the displayName argument is not passed to forwardRef2', () {
        final ForwardRefTestComponent = forwardRef2((props, ref) {});
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'name'), anyOf('', isNull));
      });

      test('when displayName argument is passed to forwardRef2', () {
        const name = 'ForwardRefTestComponent';
        final ForwardRefTestComponent = forwardRef2((props, ref) {}, displayName: name);
        expect(getProperty(getProperty(ForwardRefTestComponent.type, 'render'), 'name'), name);
      });
    });
  });
}
