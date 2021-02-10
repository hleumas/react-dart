// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:html';
import 'dart:async';

import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

Stopwatch stopwatch = Stopwatch()..start();
timeprint(message) {
  print('$message ${stopwatch.elapsedMilliseconds}');
  stopwatch.reset();
}

class _Div extends react.Component {
  @override
  shouldComponentUpdate(nProps, nState) {
    return nProps['key'] != props['key'];
  }

  @override
  render() {
    return react.div(props, props['children']);
  }
}

var Div = react.registerComponent(() => _Div());

class _Span extends react.Component {
  @override
  shouldComponentUpdate(nProps, nState) {
    return nProps['children'][0] != props['children'][0];
  }

  @override
  render() {
    return react.span(props, props['children']);
  }
}

var Span = react.registerComponent(() => _Span());

class _Hello extends react.Component {
  @override
  componentWillMount() {
    Future.delayed(Duration(seconds: 5), () {
      stopwatch.reset();
      timeprint('before redraw call');
      redraw();
      timeprint('after redraw call');
    });
  }

  @override
  render() {
    timeprint('rendering start');
    final data = props['data'];
    final children = [];
    for (final elem in data) {
      children.add(react.div({
        'key': elem[0]
      }, [
        react.span({'key': 'span1'}, elem[0]),
        ' ',
        react.span({'key': 'span2'}, elem[1])
      ]));
    }
//    data.forEach((elem) => children.add(
//        react.div({'key': elem[0]},[
//          react.span({}, elem[0]),
//          " ",
//          react.span({}, elem[1])
//        ]))
//    );
    timeprint('rendering almost ends');
    final res = react.div({}, children);
    timeprint('rendering ends');
    return res;
  }
}

var Hello = react.registerComponent(() => _Hello());

void main() {
  final data = [];
  for (num i = 0; i < 1000; i++) {
    data.add(['name_$i', 'value_$i']);
  }
  react_dom.render(Hello({'data': data}, []), querySelector('#content'));
}
