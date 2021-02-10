@TestOn('browser')
library react_test_utils_test;

import 'dart:html';
import 'dart:js_util';

import 'package:react/react.dart';
import 'package:react/react_dom.dart' as react_dom;
import 'package:react/react_client.dart';
import 'package:react/react_test_utils.dart';
import 'package:test/test.dart';

import 'react_client/event_helpers_test.dart';
import 'test_components.dart' as component1;
import 'test_components2.dart' as component2;
import 'util.dart';

void main() {
  testUtils(
      isComponent2: false,
      eventComponent: component1.eventComponent,
      sampleComponent: component1.sampleComponent,
      wrapperComponent: component1.wrapperComponent);
  testUtils(
      isComponent2: true,
      eventComponent: component2.eventComponent,
      sampleComponent: component2.sampleComponent,
      wrapperComponent: component2.wrapperComponent);
}

testUtils({isComponent2 = false, dynamic eventComponent, dynamic sampleComponent, dynamic wrapperComponent}) {
  var component;
  Element domNode;

  tearDown(() {
    component = null;
    domNode = null;
  });

  group('Shallow Rendering with a Component${isComponent2 ? "2" : ""}', () {
    ReactElement content;
    ReactShallowRenderer shallowRenderer;

    setUp(() {
      content = sampleComponent({'className': 'test', 'id': 'createRendererTest'});

      shallowRenderer = createRenderer();
    });

    tearDown(() {
      final renderedOutput = shallowRenderer.getRenderOutput();
      final props = getProps(renderedOutput);

      expect(props['className'], 'test');
      expect(props['id'], 'createRendererTest');
    });

    test('without context', () {
      shallowRenderer.render(content);
    });

    test('with context', () {
      shallowRenderer.render(content, {});
    });
  });

  group('Simulate on a Component${isComponent2 ? "2" : ""}', () {
    setUp(() {
      component = renderIntoDocument(eventComponent({}));
      domNode = react_dom.findDOMNode(component);
      expect(domNode.text, equals(''));
    });

    void testEvent(
      void Function(dynamic instanceOrNode, Map eventData) event,
      String eventName,
      void Function(SyntheticEvent e) expectEventType,
    ) {
      final eventHandlerName = 'on${eventName[0].toUpperCase() + eventName.substring(1)}';
      eventName = eventName.toLowerCase();
      Map eventData;
      int fakeTimeStamp;

      setUp(() {
        fakeTimeStamp = eventName.hashCode;
        eventData = {
          'timeStamp': fakeTimeStamp,
        };
      });

      test('with React instance as arg', () {
        event(findRenderedDOMComponentWithTag(component, 'div'), eventData);
        expect(domNode.text, equals('$eventName $fakeTimeStamp'));
      });

      test('with DOM Element as arg', () {
        event(domNode, eventData);
        expect(domNode.text, equals('$eventName $fakeTimeStamp'));
      });

      if (expectEventType != null) {
        test('with correct type', () {
          SyntheticEvent capturedEvent;
          DivElement ref;

          renderIntoDocument(div({
            eventHandlerName: (e) {
              capturedEvent = e;
            },
            'ref': (r) => ref = r,
          }));

          event(ref, eventData);
          expectEventType(capturedEvent);
        });
      }
    }

    group('event', () {
      void Function(SyntheticEvent) _expectEventType(SyntheticEventType type) {
        return (event) {
          expect(event.isClipboardEvent, type == SyntheticEventType.syntheticClipboardEvent);
          expect(event.isKeyboardEvent, type == SyntheticEventType.syntheticKeyboardEvent);
          expect(event.isCompositionEvent, type == SyntheticEventType.syntheticCompositionEvent);
          expect(event.isFocusEvent, type == SyntheticEventType.syntheticFocusEvent);
          expect(event.isMouseEvent, type == SyntheticEventType.syntheticMouseEvent);
          expect(event.isPointerEvent, type == SyntheticEventType.syntheticPointerEvent);
          expect(event.isTouchEvent, type == SyntheticEventType.syntheticTouchEvent);
          expect(event.isTransitionEvent, type == SyntheticEventType.syntheticTransitionEvent);
          expect(event.isAnimationEvent, type == SyntheticEventType.syntheticAnimationEvent);
          expect(event.isUiEvent, type == SyntheticEventType.syntheticUIEvent);
          expect(event.isWheelEvent, type == SyntheticEventType.syntheticWheelEvent);
        };
      }

      final expectClipboardEvent = _expectEventType(SyntheticEventType.syntheticClipboardEvent);
      final expectKeyboardEvent = _expectEventType(SyntheticEventType.syntheticKeyboardEvent);
      final expectCompositionEvent = _expectEventType(SyntheticEventType.syntheticCompositionEvent);
      final expectFocusEvent = _expectEventType(SyntheticEventType.syntheticFocusEvent);
      final expectFormEvent = _expectEventType(SyntheticEventType.syntheticFormEvent);
      final expectMouseEvent = _expectEventType(SyntheticEventType.syntheticMouseEvent);
      final expectPointerEvent = _expectEventType(SyntheticEventType.syntheticPointerEvent);
      final expectTouchEvent = _expectEventType(SyntheticEventType.syntheticTouchEvent);
      final expectTransitionEvent = _expectEventType(SyntheticEventType.syntheticTransitionEvent);
      final expectAnimationEvent = _expectEventType(SyntheticEventType.syntheticAnimationEvent);
      final expectUiEvent = _expectEventType(SyntheticEventType.syntheticUIEvent);
      final expectWheelEvent = _expectEventType(SyntheticEventType.syntheticWheelEvent);

      group('animationEnd', () => testEvent(Simulate.animationEnd, 'animationEnd', expectAnimationEvent));
      group('animationIteration',
          () => testEvent(Simulate.animationIteration, 'animationIteration', expectAnimationEvent));
      group('animationStart', () => testEvent(Simulate.animationStart, 'animationStart', expectAnimationEvent));
      group('blur', () => testEvent(Simulate.blur, 'blur', expectFocusEvent));
      group('change', () => testEvent(Simulate.change, 'change', expectFormEvent));
      group('click', () => testEvent(Simulate.click, 'click', expectMouseEvent));
      group('copy', () => testEvent(Simulate.copy, 'copy', expectClipboardEvent));
      group('compositionEnd', () => testEvent(Simulate.compositionEnd, 'compositionEnd', expectCompositionEvent));
      group('compositionStart', () => testEvent(Simulate.compositionStart, 'compositionStart', expectCompositionEvent));
      group('compositionUpdate',
          () => testEvent(Simulate.compositionUpdate, 'compositionUpdate', expectCompositionEvent));
      group('contextMenu', () => testEvent(Simulate.contextMenu, 'contextMenu', expectMouseEvent));
      group('cut', () => testEvent(Simulate.cut, 'cut', expectClipboardEvent));
      group('doubleClick', () => testEvent(Simulate.doubleClick, 'doubleClick', expectMouseEvent));
      group('drag', () => testEvent(Simulate.drag, 'drag', expectMouseEvent));
      group('dragEnd', () => testEvent(Simulate.dragEnd, 'dragEnd', expectMouseEvent));
      group('dragEnter', () => testEvent(Simulate.dragEnter, 'dragEnter', expectMouseEvent));
      group('dragExit', () => testEvent(Simulate.dragExit, 'dragExit', expectMouseEvent));
      group('dragLeave', () => testEvent(Simulate.dragLeave, 'dragLeave', expectMouseEvent));
      group('dragOver', () => testEvent(Simulate.dragOver, 'dragOver', expectMouseEvent));
      group('dragStart', () => testEvent(Simulate.dragStart, 'dragStart', expectMouseEvent));
      group('drop', () => testEvent(Simulate.drop, 'drop', expectMouseEvent));
      group('focus', () => testEvent(Simulate.focus, 'focus', expectFocusEvent));
      group('gotPointerCapture', () => testEvent(Simulate.gotPointerCapture, 'gotPointerCapture', expectPointerEvent));
      group('input', () => testEvent(Simulate.input, 'input', expectFormEvent));
      group('keyDown', () => testEvent(Simulate.keyDown, 'keyDown', expectKeyboardEvent));
      group('keyPress', () => testEvent(Simulate.keyPress, 'keyPress', expectKeyboardEvent));
      group('keyUp', () => testEvent(Simulate.keyUp, 'keyUp', expectKeyboardEvent));
      group(
          'lostPointerCapture', () => testEvent(Simulate.lostPointerCapture, 'lostPointerCapture', expectPointerEvent));
      group('mouseDown', () => testEvent(Simulate.mouseDown, 'mouseDown', expectMouseEvent));
      group('mouseMove', () => testEvent(Simulate.mouseMove, 'mouseMove', expectMouseEvent));
      group('mouseOut', () => testEvent(Simulate.mouseOut, 'mouseOut', expectMouseEvent));
      group('mouseOver', () => testEvent(Simulate.mouseOver, 'mouseOver', expectMouseEvent));
      group('mouseUp', () => testEvent(Simulate.mouseUp, 'mouseUp', expectMouseEvent));
      group('paste', () => testEvent(Simulate.paste, 'paste', expectClipboardEvent));
      group('pointerCancel', () => testEvent(Simulate.pointerCancel, 'pointerCancel', expectPointerEvent));
      group('pointerDown', () => testEvent(Simulate.pointerDown, 'pointerDown', expectPointerEvent));
      group('pointerEnter', () => testEvent(Simulate.pointerEnter, 'pointerEnter', expectPointerEvent));
      group('pointerLeave', () => testEvent(Simulate.pointerLeave, 'pointerLeave', expectPointerEvent));
      group('pointerMove', () => testEvent(Simulate.pointerMove, 'pointerMove', expectPointerEvent));
      group('pointerOver', () => testEvent(Simulate.pointerOver, 'pointerOver', expectPointerEvent));
      group('pointerOut', () => testEvent(Simulate.pointerOut, 'pointerOut', expectPointerEvent));
      group('pointerUp', () => testEvent(Simulate.pointerUp, 'pointerUp', expectPointerEvent));
      group('scroll', () => testEvent(Simulate.scroll, 'scroll', expectUiEvent));
      group('submit', () => testEvent(Simulate.submit, 'submit', expectFormEvent));
      group('touchCancel', () => testEvent(Simulate.touchCancel, 'touchCancel', expectTouchEvent));
      group('touchEnd', () => testEvent(Simulate.touchEnd, 'touchEnd', expectTouchEvent));
      group('touchMove', () => testEvent(Simulate.touchMove, 'touchMove', expectTouchEvent));
      group('touchStart', () => testEvent(Simulate.touchStart, 'touchStart', expectTouchEvent));
      group('transitionEnd', () => testEvent(Simulate.transitionEnd, 'transitionEnd', expectTransitionEvent));
      group('wheel', () => testEvent(Simulate.wheel, 'wheel', expectWheelEvent));
    });

    test('passes in and jsifies eventData properly', () {
      const testKeyCode = 42;

      String callInfo;
      var wasStopPropagationCalled = false;

      final renderedNode = renderIntoDocument(div({
        // ignore: avoid_types_on_closure_parameters
        'onKeyDown': (SyntheticKeyboardEvent event) {
          event.stopPropagation();
          callInfo = 'onKeyDown ${event.keyCode}';
        }
      }));

      Simulate.keyDown(renderedNode, {
        'keyCode': testKeyCode,
        'stopPropagation': () {
          wasStopPropagationCalled = true;
        }
      });

      expect(callInfo, 'onKeyDown $testKeyCode');
      expect(wasStopPropagationCalled, isTrue, reason: 'should have successfully called Dart function passed in');
    });
  });

  test('findRenderedDOMComponentWithClass on a Component${isComponent2 ? "2" : ""}', () {
    component = renderIntoDocument(sampleComponent({}));
    final spanComponent = findRenderedDOMComponentWithClass(component, 'span1');

    expect(getProperty(spanComponent, 'tagName'), equals('SPAN'));
  });

  test('findRenderedDOMComponentWithTag on a Component${isComponent2 ? "2" : ""}', () {
    component = renderIntoDocument(sampleComponent({}));
    final h1Component = findRenderedDOMComponentWithTag(component, 'h1');

    expect(getProperty(h1Component, 'tagName'), equals('H1'));
  });

  test('findRenderedComponentWithTypeV2 on a Component${isComponent2 ? "2" : ""}', () {
    component = renderIntoDocument(wrapperComponent({}, [sampleComponent({})]));
    final result = findRenderedComponentWithTypeV2(component, sampleComponent);
    expect(isCompositeComponentWithTypeV2(result, sampleComponent), isTrue);
  });

  group('isCompositeComponent on a Component${isComponent2 ? "2" : ""}', () {
    test('returns true when element is a composite component (created with React.createClass())', () {
      component = renderIntoDocument(eventComponent({}));

      expect(isCompositeComponent(component), isTrue);
    });

    test('returns false when element is not a composite component (created with React.createClass())', () {
      component = renderIntoDocument(div({}));

      expect(isCompositeComponent(component), isFalse);
    });
  });

  group('isCompositeComponentWithTypeV2 on a Component${isComponent2 ? "2" : ""}', () {
    final renderedInstance = renderIntoDocument(sampleComponent({}));

    test('returns true when element is a composite component (created with React.createClass()) of the specified type',
        () {
      expect(isCompositeComponentWithTypeV2(renderedInstance, sampleComponent), isTrue);
    });

    test(
        'returns false when element is not a composite component (created with React.createClass()) of the specified type',
        () {
      expect(isCompositeComponentWithTypeV2(renderedInstance, eventComponent), isFalse);
    });
  });

  group('isDOMComponent on a Component${isComponent2 ? "2" : ""}', () {
    test('returns true when argument is a DOM component', () {
      component = renderIntoDocument(sampleComponent({}));
      final h1Element = findRenderedDOMComponentWithTag(component, 'h1');

      expect(isDOMComponent(h1Element), isTrue);
    });

    test('returns false when argument is not a DOM component', () {
      expect(isDOMComponent(h1({})), isFalse);
    });
  });

  group('isElement', () {
    test('returns true argument is an element', () {
      expect(isElement(div({})), isTrue);
    });

    test('returns false argument is not an element', () {
      expect(isElement(newObject()), isFalse);
    });
  });

  group('isElementOfTypeV2', () {
    test('returns true argument is an element of type', () {
      expect(isElementOfTypeV2(div({}), div), isTrue);
    });

    test('returns false argument is not an element of type', () {
      expect(isElementOfTypeV2(div({}), span), isFalse);
    });
  });

  test('scryRenderedComponentsWithTypeV2 on a Component${isComponent2 ? "2" : ""}', () {
    component =
        renderIntoDocument(wrapperComponent({}, [sampleComponent({}), sampleComponent({}), eventComponent({})]));

    final results = scryRenderedComponentsWithTypeV2(component, sampleComponent);

    expect(results.length, 2);
    expect(isCompositeComponentWithTypeV2(results[0], sampleComponent), isTrue);
    expect(isCompositeComponentWithTypeV2(results[1], sampleComponent), isTrue);
  });

  test('scryRenderedDOMComponentsWithClass', () {
    component = renderIntoDocument(wrapperComponent({}, [
      div({'className': 'divClass'}),
      div({'className': 'divClass'}),
      span({})
    ]));

    final results = scryRenderedDOMComponentsWithClass(component, 'divClass');

    expect(results.length, 2);
    expect(getProperty(results[0], 'tagName'), equals('DIV'));
    expect(getProperty(results[1], 'tagName'), equals('DIV'));
  });

  test('scryRenderedDOMComponentsWithTag', () {
    component = renderIntoDocument(wrapperComponent({}, [div({}), div({}), span({})]));

    final results = scryRenderedDOMComponentsWithTag(component, 'div');

    expect(results.length, 3);
    expect(getProperty(results[0], 'tagName'), equals('DIV'));
    expect(getProperty(results[1], 'tagName'), equals('DIV'));
    expect(getProperty(results[2], 'tagName'), equals('DIV'));
  });

  test('renderIntoDocument with a Component${isComponent2 ? "2" : ""}', () {
    final reactComponent = renderIntoDocument(sampleComponent({}));
    final divElements = scryRenderedDOMComponentsWithTag(reactComponent, 'div');
    final h1Elements = scryRenderedDOMComponentsWithTag(reactComponent, 'h1');
    final spanElements = scryRenderedDOMComponentsWithTag(reactComponent, 'span');

    expect(divElements.length, equals(3));
    // First div should be the parent div created by renderIntoDocument()
    expect(react_dom.findDOMNode(divElements[0]).text, equals('A headerFirst divSecond div'));
    expect(react_dom.findDOMNode(divElements[1]).text, equals('First div'));
    expect(react_dom.findDOMNode(divElements[2]).text, equals('Second div'));
    expect(h1Elements.length, equals(1));
    expect(react_dom.findDOMNode(h1Elements[0]).text, equals('A header'));
    expect(spanElements.length, equals(1));
    expect(react_dom.findDOMNode(spanElements[0]).text, equals(''));
  });
}
