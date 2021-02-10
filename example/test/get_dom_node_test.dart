// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

customAssert(text, condition) {
  if (condition) {
    print('$text passed');
  } else {
    throw text;
  }
}

var ChildComponent = react.registerComponent(() => _ChildComponent());

class _ChildComponent extends react.Component {
  var counter = 0;

  @override
  render() => react.div({}, [
        'Test element',
        counter.toString(),
        react.button({
          'type': 'button',
          'key': 'button',
          'className': 'btn btn-primary',
          'onClick': (_) {
            counter++;
            redraw();
          },
        }, 'Increase counter')
      ]);
}

var simpleComponent = react.registerComponent(() => SimpleComponent());

class SimpleComponent extends react.Component {
  var refToSpan;
  var refToElement;

  @override
  componentWillMount() => print('mount');

  @override
  componentWillUnmount() => print('unmount');

  @override
  componentDidMount() {
    customAssert('ref to span return span ', refToSpan.text == 'Test');
    customAssert('findDOMNode works on this', react_dom.findDOMNode(this) != null);
    customAssert('random ref resolves to null', ref('someRandomRef') == null);
  }

  var counter = 0;

  @override
  render() => react.div({}, [
        react.span({
          'key': 'span1',
          'ref': (ref) {
            refToSpan = ref;
          }
        }, 'Test'),
        react.span({'key': 'span2'}, counter),
        react.button({
          'type': 'button',
          'key': 'button1',
          'className': 'btn btn-primary',
          'onClick': (_) => (react_dom.findDOMNode(this) as HtmlElement).children.first.text = (++counter).toString()
        }, 'Increase counter'),
        react.br({'key': 'br'}),
        ChildComponent({
          'key': 'child',
          'ref': (ref) {
            refToElement = ref;
          }
        }),
        react.button({
          'type': 'button',
          'key': 'button2',
          'className': 'btn btn-primary',
          'onClick': (_) => window.alert(refToElement.counter.toString())
        }, 'Show value of child element'),
      ]);
}

var mountedNode = querySelector('#content');

void main() {
  final component = simpleComponent({});
  react_dom.render(component, mountedNode);
}
