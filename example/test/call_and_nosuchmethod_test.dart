// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:html';

import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react.dart' as react;

class _CustomComponent extends react.Component {
  @override
  render() {
    return react.div({}, props['children']);
  }
}

var customComponent = react.registerComponent(() => _CustomComponent());

void main() {
  react_dom.render(
      react.div({}, [
        react.div({'key': 'noChildren'}),
        react.div({'key': 'emptyList'}, []),
        react.div({'key': 'singleItemInList'}, [react.div({})]), // This should produce a key warning
        react.div({'key': 'twoItemsInList'}, [react.div({}), react.div({})]), // This should produce a key warning
        react.div({'key': 'oneVariadicChild'}, react.div({})),

        // These tests of variadic children won't pass in the ddc until https://github.com/dart-lang/sdk/issues/29904
        // is resolved.
        // react.div({'key': 'twoVariadicChildren'}, react.div({}), react.div({})),
        // react.div({'key': 'fiveVariadicChildren'}, '', react.div({}), '', react.div({}), ''),

        customComponent({'key': 'noChildren2'}),
        customComponent({'key': 'emptyList2'}, []),
        customComponent({'key': 'singleItemInList2'}, [customComponent({})]), // This should produce a key warning
        customComponent({'key': 'twoItemsInList2'},
            [customComponent({}), customComponent({})]), // This should produce a key warning
        customComponent({'key': 'oneVariadicChild2'}, customComponent({'key': '1'})),

        // These tests of variadic children won't pass in the ddc until https://github.com/dart-lang/sdk/issues/29904
        // is resolved.
        // customComponent({'key': 'twoVariadicChildren2'}, customComponent({}), customComponent({})),
        // customComponent({'key': 'fiveVariadicChildren2'}, '', customComponent({}), '', customComponent({}), ''),
      ]),
      querySelector('#content'));
}
