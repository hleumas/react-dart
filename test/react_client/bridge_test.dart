@TestOn('browser')
library react.bridge_test;

import 'package:react/react.dart' as react;
import 'package:react/react_client/bridge.dart';
import 'package:test/test.dart';

import '../util.dart';

main() {
  // Test behavior that isn't functionally tested via component lifecycle tests.
  group('Component2Bridge', () {
    group('.forComponent returns the bridge used by that mounted component, which', () {
      test('by default is a const instance of Component2BridgeImpl', () {
        final instance = getDartComponent<_Foo>(render(Foo({})));
        expect(Component2Bridge.forComponent(instance), same(const Component2BridgeImpl()));
      });

      test('can be a custom bridge specified via registerComponent2', () {
        customBridgeCalls = [];
        addTearDown(() => customBridgeCalls = null);

        final instance = getDartComponent<_BridgeTest>(render(BridgeTest({})));
        final bridge = Component2Bridge.forComponent(instance);
        expect(bridge, isNotNull);
        expect(
          customBridgeCalls,
          // Use `contains` since the static component instance and its bridge also get instantiated,
          // adding entries to customBridgeCalls.
          // `equals` is needed otherwise deep matching with matchers won't work
          contains(equals({
            'component': same(instance),
            'returnedBridge': same(bridge),
          })),
        );
      });
    });

    group('- Component2BridgeImpl', () {
      test('.bridgeFactory returns a const instance of Component2BridgeImpl', () {
        expect(Component2BridgeImpl.bridgeFactory(_Foo()), same(const Component2BridgeImpl()));
      });
    });
  });
}

final Foo = react.registerComponent2(() => _Foo());

class _Foo extends react.Component2 {
  @override
  render() => react.div({});
}

List<Map> customBridgeCalls;

final BridgeTest = react.registerComponent2(() => _BridgeTest(), bridgeFactory: (component) {
  final returnedBridge = CustomComponent2Bridge();
  customBridgeCalls?.add({
    'component': component,
    'returnedBridge': returnedBridge,
  });
  return returnedBridge;
});

class _BridgeTest extends react.Component2 {
  @override
  render() => react.div({});
}

class CustomComponent2Bridge extends Component2BridgeImpl {}
