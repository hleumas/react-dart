@TestOn('browser')
library react.react_memo_test;

import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_test_utils.dart' as rtu;
import 'package:test/test.dart';

import 'factory/common_factory_tests.dart';

main() {
  group('memo', () {
    // ignore: deprecated_member_use_from_same_package
    sharedMemoTests(react.memo);

    group('- common factory behavior -', () {
      // ignore: deprecated_member_use_from_same_package
      final MemoTest = react.memo(react.registerFunctionComponent((props) {
        props['onDartRender']?.call(props);
        return react.div({...props});
      }));

      commonFactoryTests(
        MemoTest,
        // ignore: invalid_use_of_protected_member
        dartComponentVersion: ReactDartComponentVersion.component2,
        // Dart props passed to memo get converted when they shouldn't, so these tests fail.
        // This is part of why memo is deprecated.
        skipPropValuesTest: true,
      );
    });
  });

  group('memo2', () {
    sharedMemoTests(react.memo2);

    test('can be passed a forwardRef component (regression test)', () {
      ReactComponentFactoryProxy factory;
      expect(() => factory = react.memo2(react.forwardRef2((props, ref) => 'foo')), returnsNormally);
      expect(() => rtu.renderIntoDocument(factory({})), returnsNormally);
    });

    group('- common factory behavior -', () {
      final Memo2Test = react.memo2(react.registerFunctionComponent((props) {
        props['onDartRender']?.call(props);
        return react.div({...props});
      }));

      commonFactoryTests(
        Memo2Test,
        // ignore: invalid_use_of_protected_member
        dartComponentVersion: ReactDartComponentVersion.component2,
      );
    });
  });
}

typedef MemoFunction = react.ReactComponentFactoryProxy Function(ReactDartFunctionComponentFactoryProxy,
    {bool Function(Map, Map) areEqual});

void sharedMemoTests(MemoFunction memoFunction) {
  Ref<_MemoTestWrapperComponent> memoTestWrapperComponentRef;
  Ref<Element> localCountDisplayRef;
  Ref<Element> valueMemoShouldIgnoreViaAreEqualDisplayRef;
  int childMemoRenderCount;

  void renderMemoTest({
    bool testAreEqual = false,
  }) {
    expect(memoTestWrapperComponentRef, isNotNull, reason: 'test setup sanity check');
    expect(localCountDisplayRef, isNotNull, reason: 'test setup sanity check');
    expect(valueMemoShouldIgnoreViaAreEqualDisplayRef, isNotNull, reason: 'test setup sanity check');

    final customAreEqualFn = !testAreEqual
        ? null
        : (prevProps, nextProps) {
            return prevProps['localCount'] == nextProps['localCount'];
          };

    final MemoTest = memoFunction(react.registerFunctionComponent((props) {
      childMemoRenderCount++;
      return react.div(
        {},
        react.p(
          {'ref': localCountDisplayRef},
          props['localCount'],
        ),
        react.p(
          {'ref': valueMemoShouldIgnoreViaAreEqualDisplayRef},
          props['valueMemoShouldIgnoreViaAreEqual'],
        ),
      );
    }), areEqual: customAreEqualFn);

    rtu.renderIntoDocument(MemoTestWrapper({
      'ref': memoTestWrapperComponentRef,
      'memoComponentFactory': MemoTest,
    }));

    expect(localCountDisplayRef.current, isNotNull, reason: 'test setup sanity check');
    expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current, isNotNull, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.redrawCount, 0, reason: 'test setup sanity check');
    expect(childMemoRenderCount, 1, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['localCount'], 0, reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 0,
        reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.state['valueMemoShouldNotKnowAbout'], 0,
        reason: 'test setup sanity check');
  }

  setUp(() {
    memoTestWrapperComponentRef = react.createRef<_MemoTestWrapperComponent>();
    localCountDisplayRef = react.createRef<Element>();
    valueMemoShouldIgnoreViaAreEqualDisplayRef = react.createRef<Element>();
    childMemoRenderCount = 0;
  });

  tearDown(() {
    memoTestWrapperComponentRef = null;
    localCountDisplayRef = null;
    valueMemoShouldIgnoreViaAreEqualDisplayRef = null;
  });

  group('renders its child component when props change', () {
    test('', () {
      renderMemoTest();

      memoTestWrapperComponentRef.current.increaseLocalCount();
      expect(memoTestWrapperComponentRef.current.state['localCount'], 1, reason: 'test setup sanity check');
      expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

      expect(childMemoRenderCount, 2);
      expect(localCountDisplayRef.current.text, '1');

      memoTestWrapperComponentRef.current.increaseValueMemoShouldIgnoreViaAreEqual();
      expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 1,
          reason: 'test setup sanity check');
      expect(memoTestWrapperComponentRef.current.redrawCount, 2, reason: 'test setup sanity check');

      expect(childMemoRenderCount, 3);
      expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current.text, '1');
    });

    test('unless the areEqual argument is set to a function that customizes when re-renders occur', () {
      renderMemoTest(testAreEqual: true);

      memoTestWrapperComponentRef.current.increaseValueMemoShouldIgnoreViaAreEqual();
      expect(memoTestWrapperComponentRef.current.state['valueMemoShouldIgnoreViaAreEqual'], 1,
          reason: 'test setup sanity check');
      expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

      expect(childMemoRenderCount, 1);
      expect(valueMemoShouldIgnoreViaAreEqualDisplayRef.current.text, '0');
    });
  });

  test('does not re-render its child component when parent updates and props remain the same', () {
    renderMemoTest();

    memoTestWrapperComponentRef.current.increaseValueMemoShouldNotKnowAbout();
    expect(memoTestWrapperComponentRef.current.state['valueMemoShouldNotKnowAbout'], 1,
        reason: 'test setup sanity check');
    expect(memoTestWrapperComponentRef.current.redrawCount, 1, reason: 'test setup sanity check');

    expect(childMemoRenderCount, 1);
  });
}

final MemoTestWrapper = react.registerComponent2(() => _MemoTestWrapperComponent());

class _MemoTestWrapperComponent extends react.Component2 {
  int redrawCount = 0;

  @override
  get initialState => const {
        'localCount': 0,
        'valueMemoShouldIgnoreViaAreEqual': 0,
        'valueMemoShouldNotKnowAbout': 0,
      };

  @override
  void componentDidUpdate(Map prevProps, Map prevState, [dynamic snapshot]) {
    redrawCount++;
  }

  void increaseLocalCount() {
    setState({'localCount': state['localCount'] + 1});
  }

  void increaseValueMemoShouldIgnoreViaAreEqual() {
    setState({'valueMemoShouldIgnoreViaAreEqual': state['valueMemoShouldIgnoreViaAreEqual'] + 1});
  }

  void increaseValueMemoShouldNotKnowAbout() {
    setState({'valueMemoShouldNotKnowAbout': state['valueMemoShouldNotKnowAbout'] + 1});
  }

  @override
  render() {
    return react.div(
      const {},
      props['memoComponentFactory']({
        'localCount': state['localCount'],
        'valueMemoShouldIgnoreViaAreEqual': state['valueMemoShouldIgnoreViaAreEqual'],
      }),
    );
  }
}
