// ignore_for_file: deprecated_member_use_from_same_package
@TestOn('browser')
@JS()
library react_test_utils_test;

import 'dart:html' show DivElement;

import 'package:js/js.dart';
import 'package:react/react.dart';
import 'package:test/test.dart';

import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:react/react_client/component_factory.dart';
import 'package:react/react_client/react_interop.dart' show React, ReactComponent;
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/src/react_client/event_prop_key_to_event_factory.dart';

main() {
  group('unconvertJsProps', () {
    const testChildren = ['child1', 'child2'];
    const testStyle = <String, dynamic>{'background': 'white'};

    test('returns props for a composite JS component ReactElement', () {
      final ReactElement instance = testJsComponentFactory({
        'jsProp': 'js',
        'style': testStyle,
      }, testChildren);

      expect(
        unconvertJsProps(instance),
        equals({
          'jsProp': 'js',
          'style': testStyle,
          'children': testChildren,
        }),
      );
      expect(unconvertJsProps(instance)['style'], isA<Map<String, dynamic>>());
    });

    test('throws when a Dart component (Component2) is passed in', () {
      final instance = DartComponent2({
        'jsProp': 'js',
        'style': testStyle,
      }, testChildren);

      expect(() => unconvertJsProps(instance), throwsArgumentError);
    });

    test('throws when a Dart component is passed in', () {
      final instance = DartComponent({
        'jsProp': 'js',
        'style': testStyle,
      }, testChildren);

      expect(() => unconvertJsProps(instance), throwsArgumentError);
    });

    test('returns props for a composite JS ReactComponent', () {
      final mountNode = DivElement();
      final ReactComponent renderedInstance = react_dom.render(
          testJsComponentFactory({
            'jsProp': 'js',
            'style': testStyle,
          }, testChildren),
          mountNode);

      expect(
        unconvertJsProps(renderedInstance),
        equals({
          'jsProp': 'js',
          'style': testStyle,
          'children': testChildren,
        }),
      );
    });

    test('returns props for a composite JS ReactComponent, even when the props change', () {
      final mountNode = DivElement();
      ReactComponent renderedInstance = react_dom.render(
          testJsComponentFactory({
            'jsProp': 'js',
            'style': testStyle,
          }, testChildren),
          mountNode);

      expect(
        unconvertJsProps(renderedInstance),
        equals({
          'jsProp': 'js',
          'style': testStyle,
          'children': testChildren,
        }),
      );

      renderedInstance = react_dom.render(
          testJsComponentFactory({
            'jsProp': 'other js',
            'style': testStyle,
          }, testChildren),
          mountNode);

      expect(
          unconvertJsProps(renderedInstance),
          equals({
            'jsProp': 'other js',
            'style': testStyle,
            'children': testChildren,
          }));
    });

    test('returns props for a DOM component ReactElement', () {
      final ReactElement instance = react.div({
        'domProp': 'dom',
        'style': testStyle,
      }, testChildren);

      expect(
          unconvertJsProps(instance),
          equals({
            'domProp': 'dom',
            'style': testStyle,
            'children': testChildren,
          }));
    });

    group('should unconvert JS event handlers', () {
      Function createHandler(eventKey) => (_) {
            print(eventKey);
          };
      Map<String, Function> originalHandlers;
      Map props;

      setUp(() {
        originalHandlers = {};
        props = {};

        for (final key in knownEventKeys) {
          props[key] = originalHandlers[key] = createHandler(key);
        }
      });

      test('for a DOM element', () {
        final component = react.div(props);
        final jsProps = unconvertJsProps(component);
        for (final key in knownEventKeys) {
          expect(jsProps[key], isNotNull, reason: 'JS event handler prop should not be null');
          expect(jsProps[key], anyOf(same(originalHandlers[key]), same(allowInterop(originalHandlers[key]))),
              reason: 'JS event handler should be the original or original wrapped in allowInterop');
        }
      });

      test(', except for a JS composite component (handlers should already be unconverted)', () {
        final component = testJsComponentFactory(props);
        final jsProps = unconvertJsProps(component);
        for (final key in knownEventKeys) {
          expect(jsProps[key], isNotNull, reason: 'JS event handler prop should not be null');
          expect(jsProps[key], same(allowInterop(originalHandlers[key])),
              reason: 'JS event handler prop was unexpectedly modified');
        }
      });
    });
  });

  group('registerComponent', () {
    test('throws with printed error', () {
      expect(() => react.registerComponent(() => ThrowsInDefaultPropsComponent()), throwsStateError);
      expect(() {
        try {
          react.registerComponent(() => ThrowsInDefaultPropsComponent());
        } catch (_) {}
      }, prints(contains('Error when registering Component:')));
    });
  });

  group('registerComponent2', () {
    test('throws with specific error when defaultProps throws', () {
      expect(() => react.registerComponent2(() => ThrowsInDefaultPropsComponent2()), throwsStateError);
      expect(() {
        try {
          react.registerComponent2(() => ThrowsInDefaultPropsComponent2());
        } catch (_) {}
      }, prints(contains('Error when registering Component2 when getting defaultProps')));
    });

    test('throws with specific error when propTypes throws', () {
      expect(() => react.registerComponent2(() => ThrowsInPropTypesComponent2()), throwsStateError);
      expect(() {
        try {
          react.registerComponent2(() => ThrowsInPropTypesComponent2());
        } catch (_) {}
      }, prints(contains('Error when registering Component2 when getting propTypes')));
    }, tags: 'no-dart2js');

    test('throws with generic error when something else throws', () {
      expect(() => react.registerComponent2(() => throw StateError('bad component')), throwsStateError);
      expect(() {
        try {
          react.registerComponent2(() => throw StateError('bad component'));
        } catch (_) {}
      }, prints(contains('Error when registering Component2:')));
    });
  });
}

@JS()
external Function compositeComponent();

/// A factory for a JS composite component, for use in testing.
final Function testJsComponentFactory = (() {
  final type = compositeComponent();
  return ([props = const {}, children]) {
    return React.createElement(type, jsifyAndAllowInterop(props), listifyChildren(children));
  };
})();

class ThrowsInDefaultPropsComponent extends Component {
  @override
  Map getDefaultProps() => throw StateError('bad default props');

  @override
  render() {
    return null;
  }
}

class ThrowsInDefaultPropsComponent2 extends Component2 {
  @override
  get defaultProps => throw StateError('bad default props');

  @override
  render() {
    return null;
  }
}

class ThrowsInPropTypesComponent2 extends Component2 {
  @override
  get propTypes => throw StateError('bad prop types');

  @override
  render() {
    return null;
  }
}

class DartComponent2Component extends Component2 {
  @override
  render() {
    return null;
  }
}

final DartComponent2 = react.registerComponent2(() => DartComponent2Component());

class DartComponentComponent extends Component {
  @override
  render() {
    return null;
  }
}

ReactDartComponentFactoryProxy DartComponent = react.registerComponent(() => DartComponentComponent());
