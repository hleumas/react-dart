// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

class _Item extends react.Component {
  @override
  componentWillReceiveProps(newProps) {
    print('Old props: $props');
    print('New props: $newProps');
  }

  @override
  shouldComponentUpdate(nextProps, nextState) {
    return false;
  }

  @override
  render() {
    return react.li({}, [props['text']]);
  }
}

var item = react.registerComponent(() => _Item());

class _List extends react.Component {
  var items = ['item1', 'item2', 'item3'];

  remove() {
    items.removeAt(0);
    redraw();
  }

  @override
  render() {
    return react.ul({'onClick': (e) => remove()}, items.map((text) => item({'text': text, 'key': text})));
  }
}

var list = react.registerComponent(() => _List());

void main() {
  react_dom.render(list({}), querySelector('#content'));
}
