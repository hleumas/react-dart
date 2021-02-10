import 'dart:html';

import 'package:react/react.dart' as react;
import 'package:react/react_dom.dart' as react_dom;

import 'react_test_components.dart';

void main() {
  react_dom.render(
      react.div({}, [
        react.h1({}, ['React Legacy Context API']),
        legacyContextComponent({}, [
          legacyContextConsumerComponent({
            'key': 'consumerComponent'
          }, [
            grandchildLegacyContextConsumerComponent({'key': 'legacyConsumerGrandchildComponent'})
          ]),
        ]),
        react.h1({'key': 'h1'}, ['React New Context API']),
        newContextProviderComponent({
          'key': 'newProviderComponent'
        }, [
          newContextConsumerComponent({
            'key': 'newConsumerComponent',
          }),
          newContextConsumerObservedBitsComponent({
            'key': 'newConsumerObservedBitsComponent',
            'unstable_observedBits': 1 << 2,
          }),
          newContextTypeConsumerComponentComponent({'key': 'newContextTypeConsumerComponent'}, []),
        ]),
      ]),
      querySelector('#content'));
}
