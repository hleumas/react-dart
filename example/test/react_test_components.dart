// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';
import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

class _HelloComponent extends react.Component2 {
  @override
  get propTypes => {
        // ignore: avoid_types_on_closure_parameters
        'name': (Map props, info) {
          final String propValue = props[info.propName];
          if (propValue.length > 20) {
            return ArgumentError('($propValue) is too long. $propValue has a max length of 20 characters.');
          }
          return null;
        },
      };

  @override
  render() {
    return react.span({}, ["Hello ${props['name']}!"]);
  }
}

var helloComponent = react.registerComponent(() => _HelloComponent());

class _HelloGreeter extends react.Component {
  var myInput;
  @override
  getInitialState() => {'name': 'World'};

  onInputChange(e) {
    final InputElement input = react_dom.findDOMNode(myInput);
    print(input.borderEdge);
    setState({'name': e.target.value});
  }

  @override
  render() {
    return react.div({}, [
      react.input({
        'key': 'input',
        'className': 'form-control',
        'ref': (ref) => myInput = ref,
        'value': state['name'],
        'onChange': onInputChange,
      }),
      helloComponent({'key': 'hello', 'name': state['name']})
    ]);
  }
}

var helloGreeter = react.registerComponent(() => _HelloGreeter());

class _CheckBoxComponent extends react.Component {
  @override
  getInitialState() => {'checked': false};

  _handleChange(e) {
    setState({'checked': e.target.checked});
  }

  @override
  render() {
    return react.div({
      'className': 'form-check'
    }, [
      react.input({
        'id': 'doTheDishes',
        'key': 'input',
        'className': 'form-check-input',
        'type': 'checkbox',
        'checked': state['checked'],
        'onChange': _handleChange,
      }),
      react.label({
        'htmlFor': 'doTheDishes',
        'key': 'label',
        'className': 'form-check-label ${state['checked'] ? 'striked' : 'not-striked'}'
      }, 'do the dishes'),
    ]);
  }
}

var checkBoxComponent = react.registerComponent(() => _CheckBoxComponent());

class _ClockComponent extends react.Component {
  Timer timer;

  @override
  getInitialState() => {'secondsElapsed': 0};

  @override
  getDefaultProps() => {'refreshRate': 1000};

  @override
  void componentWillMount() {
    timer = Timer.periodic(Duration(milliseconds: props['refreshRate']), tick);
  }

  @override
  void componentWillUnmount() {
    timer.cancel();
  }

  @override
  void componentDidMount() {
    final Element rootNode = react_dom.findDOMNode(this);
    rootNode.style.backgroundColor = '#FFAAAA';
  }

  @override
  bool shouldComponentUpdate(nextProps, nextState) {
    //print("Next state: $nextState, props: $nextProps");
    //print("Old state: $state, props: $props");
    return nextState['secondsElapsed'] % 2 == 1;
  }

  @override
  void componentWillReceiveProps(nextProps) {
    print('Received props: $nextProps');
  }

  tick(Timer timer) {
    setState({'secondsElapsed': state['secondsElapsed'] + 1});
  }

  @override
  render() {
    return react.span({'onClick': (event) => print('Hello World!')},
//        { 'onClick': (event, [domid = null]) => print("Hello World!") },
        ['Seconds elapsed: ', "${state['secondsElapsed']}"]);
  }
}

var clockComponent = react.registerComponent(() => _ClockComponent());

class _ListComponent extends react.Component {
  @override
  getInitialState() {
    return {
      'items': List.from([0, 1, 2, 3])
    };
  }

  @override
  void componentWillUpdate(nextProps, nextState) {
    if (nextState['items'].length > state['items'].length) {
      print('Adding ${nextState["items"].last.toString()}');
    }
  }

  @override
  void componentDidUpdate(prevProps, prevState) {
    if (prevState['items'].length > state['items'].length) {
      print("Removed ${prevState['items'].first.toString()}");
    }
  }

  int iterator = 3;

  void addItem(event) {
    final items = List.from(state['items'])..add(++iterator);
    setState({'items': items});
  }

  @override
  render() {
    final items = [];
    for (final item in state['items']) {
      items.add(react.li({'key': item}, '$item'));
    }

    return react.div({}, [
      react.button({
        'type': 'button',
        'key': 'button',
        'className': 'btn btn-primary',
        'onClick': addItem,
      }, 'addItem'),
      react.ul({'key': 'list'}, items),
    ]);
  }
}

var listComponent = react.registerComponent(() => _ListComponent());

class _MainComponent extends react.Component {
  @override
  render() {
    return react.div({}, props['children']);
  }
}

var mainComponent = react.registerComponent(() => _MainComponent());

/////
// REACT OLD CONTEXT COMPONENTS
/////
class _LegacyContextComponent extends react.Component {
  @override
  Iterable<String> get childContextKeys => const ['foo', 'bar', 'renderCount'];

  @override
  Map<String, dynamic> getChildContext() => {
        'foo': {'object': 'with value'},
        'bar': true,
        'renderCount': state['renderCount']
      };

  @override
  render() {
    return react.ul({
      'key': 'ul'
    }, [
      react.button({'key': 'button', 'className': 'btn btn-primary', 'onClick': _onButtonClick}, 'Redraw'),
      react.br({'key': 'break1'}),
      'LegacyContextComponent.getChildContext(): ',
      getChildContext().toString(),
      react.br({'key': 'break2'}),
      react.br({'key': 'break3'}),
      props['children'],
    ]);
  }

  _onButtonClick(event) {
    setState({'renderCount': (state['renderCount'] ?? 0) + 1});
  }
}

var legacyContextComponent = react.registerComponent(() => _LegacyContextComponent());

class _LegacyContextConsumerComponent extends react.Component {
  @override
  Iterable<String> get contextKeys => const ['foo'];

  @override
  render() {
    return react.ul({
      'key': 'ul'
    }, [
      'LegacyContextConsumerComponent.context: ',
      context.toString(),
      react.br({'key': 'break1'}),
      react.br({'key': 'break2'}),
      props['children'],
    ]);
  }
}

var legacyContextConsumerComponent = react.registerComponent(() => _LegacyContextConsumerComponent());

class _GrandchildLegacyContextConsumerComponent extends react.Component {
  @override
  Iterable<String> get contextKeys => const ['renderCount'];

  @override
  render() {
    return react.ul({
      'key': 'ul'
    }, [
      'LegacyGrandchildContextConsumerComponent.context: ',
      context.toString(),
    ]);
  }
}

var grandchildLegacyContextConsumerComponent =
    react.registerComponent(() => _GrandchildLegacyContextConsumerComponent());

////
// REACT NEW CONTEXT COMPONENTS
////
class _NewContextRefComponent extends react.Component2 {
  @override
  render() {
    return react.div({}, props['children']);
  }

  test() {
    print('test');
  }
}

var newContextRefComponent = react.registerComponent(() => _NewContextRefComponent());

int calculateChangedBits(currentValue, nextValue) {
  var result = 1 << 1;
  if (nextValue['renderCount'] % 2 == 0) {
    result |= 1 << 2;
  }
  return result;
}

var TestNewContext = react.createContext<Map>({'renderCount': 0}, calculateChangedBits);

class _NewContextProviderComponent extends react.Component2 {
  _NewContextRefComponent componentRef;

  @override
  get initialState => {'renderCount': 0, 'complexMap': false};

  printMe() {
    print('printMe!');
  }

  @override
  render() {
    final provideMap = {'renderCount': state['renderCount']};

    final complexValues = {
      'callback': printMe,
      'dartComponent': newContextRefComponent,
      'map': {
        'bool': true,
        'anotherDartComponent': newContextRefComponent,
      },
      'componentRef': componentRef,
    };

    if (state['complexMap']) {
      provideMap.addAll(complexValues);
    }

    final newContextRefComponentProps = {
      'key': 'ref2',
      'ref': (ref) {
        componentRef = ref;
      }
    };

    return react.ul({
      'key': 'ulasda',
    }, [
      newContextRefComponent(newContextRefComponentProps, []),
      react.button({
        'type': 'button',
        'key': 'button',
        'className': 'btn btn-primary',
        'onClick': _onButtonClick,
      }, 'Redraw'),
      react.button({
        'type': 'button',
        'key': 'button_complex',
        'className': 'btn btn-primary',
        'onClick': _onComplexClick,
      }, 'Redraw With Complex Value'),
      react.br({'key': 'break1'}),
      'TestContext.Provider props.value: $provideMap',
      react.br({'key': 'break2'}),
      react.br({'key': 'break3'}),
      TestNewContext.Provider(
        {'key': 'tcp', 'value': provideMap},
        props['children'],
      ),
    ]);
  }

  _onComplexClick(event) {
    setState({'complexMap': true, 'renderCount': state['renderCount'] + 1});
  }

  _onButtonClick(event) {
    setState({'renderCount': state['renderCount'] + 1, 'complexMap': false});
  }
}

var newContextProviderComponent = react.registerComponent(() => _NewContextProviderComponent());

class _NewContextConsumerComponent extends react.Component2 {
  @override
  render() {
    return TestNewContext.Consumer({'unstable_observedBits': props['unstable_observedBits']}, (value) {
      return react.ul({
        'key': 'ul1'
      }, [
        'TestContext.Consumer: value = $value',
        react.br({'key': 'break12'}),
        react.br({'key': 'break22'}),
        props['children'],
      ]);
    });
  }
}

var newContextConsumerComponent = react.registerComponent(() => _NewContextConsumerComponent());

class _NewContextConsumerObservedBitsComponent extends react.Component2 {
  @override
  render() {
    return TestNewContext.Consumer({'unstable_observedBits': props['unstable_observedBits']}, (value) {
      return react.ul({
        'key': 'ul2'
      }, [
        'TestContext.Consumer (with unstable_observedBits set to trigger when `renderCount % 2 == 0`): value = $value',
        react.br({'key': 'break13'}),
        react.br({'key': 'break23'}),
        props['children'],
      ]);
    });
  }
}

var newContextConsumerObservedBitsComponent = react.registerComponent(() => _NewContextConsumerObservedBitsComponent());

class _NewContextTypeConsumerComponent extends react.Component2 {
  @override
  final contextType = TestNewContext;

  @override
  render() {
    context['componentRef']?.test();
    return react.ul({
      'key': 'ul3'
    }, [
      'Using Component.contextType: this.context = $context',
    ]);
  }
}

class _Component2TestComponent extends react.Component2 with react.TypedSnapshot<String> {
  @override
  get defaultProps => {'defaultProp': true};

  @override
  get initialState => {'defaultState': true, 'items': []};

  @override
  getDerivedStateFromProps(nextProps, prevState) {
    final prevItems = prevState['items'];
    if (prevItems.isEmpty || prevItems[0] != 3) {
      return {
        'items': List.from([3, 1, 2, 0])
      };
    }
    return null;
  }

  @override
  String getSnapshotBeforeUpdate(nextProps, prevState) {
    if (prevState['items'].length > state['items'].length) {
      return "removed ${prevState['items'].last.toString()}";
    } else {
      return "added ${state['items'].last.toString()}";
    }
  }

  @override
  void componentDidUpdate(prevProps, prevState, [String snapshot]) {
    if (snapshot != null) {
      print('Updated DOM and $snapshot');
      return;
    }
    print('No Snapshot');
  }

  void removeItem(event) {
    final items = List.from(state['items']);
    items.removeAt(items.length - 1);
    setState({'items': items});
  }

  void addItem(event) {
    final items = List.from(state['items']);
    items.add(items.length);
    setState({'items': items});
  }

  @override
  render() {
    // Used to generate unique keys even when the list contains duplicate items
    final itemCounts = <dynamic, int>{};
    final items = [];
    for (final item in state['items']) {
      final count = itemCounts[item] = (itemCounts[item] ?? 0) + 1;
      items.add(react.li({'key': 'c2-$item-$count'}, '$item'));
    }

    return react.div({}, [
      react.button({
        'type': 'button',
        'key': 'c2-r-button',
        'className': 'btn btn-primary',
        'onClick': removeItem,
      }, 'Remove Item'),
      react.button({
        'type': 'button',
        'key': 'c2-a-button',
        'className': 'btn btn-primary',
        'onClick': addItem,
      }, 'Add Item'),
      react.ul({'key': 'c2-list'}, items),
    ]);
  }
}

var newContextTypeConsumerComponentComponent = react.registerComponent(() => _NewContextTypeConsumerComponent());
var component2TestComponent = react.registerComponent(() => _Component2TestComponent());

class _ErrorComponent extends react.Component2 {
  @override
  void componentDidMount() {
    if (!props['errored']) {
      throw _CustomException('It broke!', 2);
    }
  }

  @override
  render() {
    return react.div(
        {'key': 'eb-d1-e'},
        'Oh no, I\'m an error! Check your '
        'console.');
  }
}

var ErrorComponent = react.registerComponent(() => _ErrorComponent());

class _CustomException implements Exception {
  int code;
  String message;
  String randomMessage;

  _CustomException(this.message, this.code) {
    switch (code) {
      case 1:
        randomMessage = 'The code is a 1';
        break;
      case 2:
        randomMessage = 'The Code is a 2';
        break;
      default:
        randomMessage = 'Default Error Code';
    }
  }
}

class _Component2ErrorTestComponent extends react.Component2 {
  @override
  get initialState => {
        'clicked': false,
        'errored': false,
        'error': null,
      };

  @override
  void componentDidCatch(error, info) {
    if (error is _CustomException) {
      print(info.dartStackTrace);
      setState({'error': error.randomMessage});
    } else {
      setState({'error': 'We can capture the error, store it in state and display it here.'});
    }
  }

  @override
  getDerivedStateFromError(error) {
    return {'errored': true};
  }

  void error(event) {
    setState({'clicked': true});
  }

  void clearError(event) {
    setState({'clicked': false, 'error': null, 'errored': false});
  }

  @override
  render() {
    final errorMessage = state['error'] ?? 'No error yet';

    return react.div({
      'key': 'e-cont'
    }, [
      react.h3({'key': 'e-header'}, 'Error Boundary Test'),
      state['clicked'] ? ErrorComponent({'key': 'ec-1', 'errored': state['errored']}) : null,
      errorMessage != null ? react.div({'key': 'ec-m-1'}, '$errorMessage') : null,
      !state['errored']
          ? react.button({
              'type': 'button',
              'key': 'c3-r-button',
              'className': 'btn btn-primary',
              'onClick': error,
            }, 'Trigger Error')
          : null,
      state['errored']
          ? react.button({
              'type': 'button',
              'key': 'c3-c-button',
              'className': 'btn btn-primary',
              'onClick': clearError,
            }, 'Clear Error')
          : null,
      react.hr({'key': 'e-hr'}),
    ]);
  }
}

var component2ErrorTestComponent = react.registerComponent(() => _Component2ErrorTestComponent(), ['render']);
