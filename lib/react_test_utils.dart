// Copyright (c) 2016, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@JS()
library react.test_utils;

import 'dart:js_util' show getProperty;

import 'package:js/js.dart';
import 'package:react/react_client.dart';
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/src/react_test_utils/simulate_wrappers.dart' as sw;

// Notes
// ---------------------------------------------------------------------------
//
// 1.  This is of type `dynamic` out of necessity, since the actual type,
//     `ReactComponent | Element`, cannot be expressed in Dart's type system.
//
//     React 0.14 augments DOM nodes with its own properties and uses them as
//     DOM component instances. To Dart's JS interop, those instances look
//     like DOM nodes, so they get converted to the corresponding DOM node
//     interceptors, and thus cannot be used with a custom `@JS()` class.
//
//     So, React composite component instances will be of type
//     `ReactComponent`, whereas DOM component instance will be of type
//     `Element`.
//
// 2.  Only Elements corresponding to DOM components rendered by React
//     should be passed in here.
//     This is dynamic since DOM components previously could be typed as ReactComponents.

/// Returns the [ReactComponentFactoryProxy.type] of a given [componentFactory].
///
/// * For DOM components, this with return the String corresponding to its tagName ('div', 'a', etc.).
/// * For custom composite components React.createClass()-based components, this will return the [ReactClass].
dynamic getComponentTypeV2(ReactComponentFactoryProxy componentFactory) => componentFactory.type;

typedef ComponentTestFunction = bool Function(/* [1] */ dynamic component);

dynamic _jsifyEventData(Map eventData) => jsifyAndAllowInterop(eventData ?? const {});

/// Event simulation interface.
///
/// Provides methods for each type of event that can be handled by a React
/// component.  All methods are used in the same way:
///
///   Simulate.{eventName}(Element node, [Map] eventData)
///
/// This should include all events documented at:
/// https://reactjs.org/docs/events.html
class Simulate {
  static void animationEnd(/* [1] */ node, [Map eventData]) =>
      sw.Simulate.animationEnd(node, _jsifyEventData(eventData));
  static void animationIteration(/* [1] */ node, [Map eventData]) =>
      sw.Simulate.animationIteration(node, _jsifyEventData(eventData));
  static void animationStart(/* [1] */ node, [Map eventData]) =>
      sw.Simulate.animationStart(node, _jsifyEventData(eventData));
  static void blur(/*[1]*/ node, [Map eventData]) => sw.Simulate.blur(node, _jsifyEventData(eventData));
  static void change(/*[1]*/ node, [Map eventData]) => sw.Simulate.change(node, _jsifyEventData(eventData));
  static void click(/*[1]*/ node, [Map eventData]) => sw.Simulate.click(node, _jsifyEventData(eventData));
  static void contextMenu(/*[1]*/ node, [Map eventData]) => sw.Simulate.contextMenu(node, _jsifyEventData(eventData));
  static void copy(/*[1]*/ node, [Map eventData]) => sw.Simulate.copy(node, _jsifyEventData(eventData));
  static void compositionEnd(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.compositionEnd(node, _jsifyEventData(eventData));
  static void compositionStart(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.compositionStart(node, _jsifyEventData(eventData));
  static void compositionUpdate(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.compositionUpdate(node, _jsifyEventData(eventData));
  static void cut(/*[1]*/ node, [Map eventData]) => sw.Simulate.cut(node, _jsifyEventData(eventData));
  static void doubleClick(/*[1]*/ node, [Map eventData]) => sw.Simulate.doubleClick(node, _jsifyEventData(eventData));
  static void drag(/*[1]*/ node, [Map eventData]) => sw.Simulate.drag(node, _jsifyEventData(eventData));
  static void dragEnd(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragEnd(node, _jsifyEventData(eventData));
  static void dragEnter(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragEnter(node, _jsifyEventData(eventData));
  static void dragExit(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragExit(node, _jsifyEventData(eventData));
  static void dragLeave(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragLeave(node, _jsifyEventData(eventData));
  static void dragOver(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragOver(node, _jsifyEventData(eventData));
  static void dragStart(/*[1]*/ node, [Map eventData]) => sw.Simulate.dragStart(node, _jsifyEventData(eventData));
  static void drop(/*[1]*/ node, [Map eventData]) => sw.Simulate.drop(node, _jsifyEventData(eventData));
  static void focus(/*[1]*/ node, [Map eventData]) => sw.Simulate.focus(node, _jsifyEventData(eventData));
  static void gotPointerCapture(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.gotPointerCapture(node, _jsifyEventData(eventData));
  static void input(/*[1]*/ node, [Map eventData]) => sw.Simulate.input(node, _jsifyEventData(eventData));
  static void keyDown(/*[1]*/ node, [Map eventData]) => sw.Simulate.keyDown(node, _jsifyEventData(eventData));
  static void keyPress(/*[1]*/ node, [Map eventData]) => sw.Simulate.keyPress(node, _jsifyEventData(eventData));
  static void keyUp(/*[1]*/ node, [Map eventData]) => sw.Simulate.keyUp(node, _jsifyEventData(eventData));
  static void lostPointerCapture(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.lostPointerCapture(node, _jsifyEventData(eventData));
  static void mouseDown(/*[1]*/ node, [Map eventData]) => sw.Simulate.mouseDown(node, _jsifyEventData(eventData));
  static void mouseMove(/*[1]*/ node, [Map eventData]) => sw.Simulate.mouseMove(node, _jsifyEventData(eventData));
  static void mouseOut(/*[1]*/ node, [Map eventData]) => sw.Simulate.mouseOut(node, _jsifyEventData(eventData));
  static void mouseOver(/*[1]*/ node, [Map eventData]) => sw.Simulate.mouseOver(node, _jsifyEventData(eventData));
  static void mouseUp(/*[1]*/ node, [Map eventData]) => sw.Simulate.mouseUp(node, _jsifyEventData(eventData));
  static void pointerCancel(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.pointerCancel(node, _jsifyEventData(eventData));
  static void pointerDown(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerDown(node, _jsifyEventData(eventData));
  static void pointerEnter(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerEnter(node, _jsifyEventData(eventData));
  static void pointerLeave(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerLeave(node, _jsifyEventData(eventData));
  static void pointerMove(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerMove(node, _jsifyEventData(eventData));
  static void pointerOut(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerOut(node, _jsifyEventData(eventData));
  static void pointerOver(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerOver(node, _jsifyEventData(eventData));
  static void pointerUp(/*[1]*/ node, [Map eventData]) => sw.Simulate.pointerUp(node, _jsifyEventData(eventData));
  static void paste(/*[1]*/ node, [Map eventData]) => sw.Simulate.paste(node, _jsifyEventData(eventData));
  static void scroll(/*[1]*/ node, [Map eventData]) => sw.Simulate.scroll(node, _jsifyEventData(eventData));
  static void submit(/*[1]*/ node, [Map eventData]) => sw.Simulate.submit(node, _jsifyEventData(eventData));
  static void touchCancel(/*[1]*/ node, [Map eventData]) => sw.Simulate.touchCancel(node, _jsifyEventData(eventData));
  static void touchEnd(/*[1]*/ node, [Map eventData]) => sw.Simulate.touchEnd(node, _jsifyEventData(eventData));
  static void touchMove(/*[1]*/ node, [Map eventData]) => sw.Simulate.touchMove(node, _jsifyEventData(eventData));
  static void touchStart(/*[1]*/ node, [Map eventData]) => sw.Simulate.touchStart(node, _jsifyEventData(eventData));
  static void transitionEnd(/*[1]*/ node, [Map eventData]) =>
      sw.Simulate.transitionEnd(node, _jsifyEventData(eventData));
  static void wheel(/*[1]*/ node, [Map eventData]) => sw.Simulate.wheel(node, _jsifyEventData(eventData));
}

/// Traverse all components in tree and accumulate all components where
/// test(component) is true. This is not that useful on its own, but it's
/// used as a primitive for other test utils
///
/// Included in Dart for completeness
@JS('React.addons.TestUtils.findAllInRenderedTree')
external List<dynamic> findAllInRenderedTree(
    /* [1] */ tree,
    ComponentTestFunction test);

/// Like scryRenderedDOMComponentsWithClass() but expects there to be one
/// result, and returns that one result, or throws exception if there is
/// any other number of matches besides one.
@JS('React.addons.TestUtils.findRenderedDOMComponentWithClass')
external dynamic /* [1] */ findRenderedDOMComponentWithClass(
    /* [1] */ tree,
    String className);

/// Like scryRenderedDOMComponentsWithTag() but expects there to be one result,
/// and returns that one result, or throws exception if there is any other
/// number of matches besides one.
@JS('React.addons.TestUtils.findRenderedDOMComponentWithTag')
external dynamic /* [1] */ findRenderedDOMComponentWithTag(
    /* [1] */ tree,
    String tag);

@JS('React.addons.TestUtils.findRenderedComponentWithType')
external dynamic /* [1] */ _findRenderedComponentWithType(
    /* [1] */ tree,
    dynamic type);

/// Same as [scryRenderedComponentsWithTypeV2] but expects there to be one result
/// and returns that one result, or throws exception if there is any other
/// number of matches besides one.
/* [1] */ findRenderedComponentWithTypeV2(
    /* [1] */ tree,
    ReactComponentFactoryProxy componentFactory) {
  return _findRenderedComponentWithType(tree, getComponentTypeV2(componentFactory));
}

@JS('React.addons.TestUtils.isCompositeComponent')
external bool _isCompositeComponent(/* [1] */ instance);

/// Returns true if element is a composite component.
/// (created with React.createClass()).
bool isCompositeComponent(/* [1] */ instance) {
  return _isCompositeComponent(instance)
      // Workaround for DOM components being detected as composite: https://github.com/facebook/react/pull/3839
      &&
      getProperty(instance, 'tagName') == null;
}

@JS('React.addons.TestUtils.isCompositeComponentWithType')
external bool _isCompositeComponentWithType(/* [1] */ instance, dynamic type);

/// Returns `true` if instance is a custom composite component created using `React.createClass()`
/// that is of the [ReactComponentFactoryProxy.type] of the provided [componentFactory].
bool isCompositeComponentWithTypeV2(
    /* [1] */ instance,
    ReactComponentFactoryProxy componentFactory) {
  return _isCompositeComponentWithType(instance, getComponentTypeV2(componentFactory));
}

/// Returns true if instance is a DOM component (such as a <div> or <span>).
@JS('React.addons.TestUtils.isDOMComponent')
external bool isDOMComponent(/* [1] */ instance);

/// Returns true if [object] is a valid React component.
@JS('React.addons.TestUtils.isElement')
external bool isElement(dynamic object);

@JS('React.addons.TestUtils.isElementOfType')
external bool _isElementOfType(dynamic element, dynamic componentClass);

/// Returns `true` if [element] is a [ReactElement]
/// that is of the [ReactComponentFactoryProxy.type] of the provided [componentFactory].
bool isElementOfTypeV2(dynamic element, ReactComponentFactoryProxy componentFactory) {
  return _isElementOfType(element, getComponentTypeV2(componentFactory));
}

@JS('React.addons.TestUtils.scryRenderedComponentsWithType')
external List<dynamic> /* [1] */ _scryRenderedComponentsWithType(
    /* [1] */ tree,
    dynamic type);

/// Finds all instances within the provided [tree]
/// that are of the [ReactComponentFactoryProxy.type] of the provided [componentFactory].
List<dynamic> /* [1] */ scryRenderedComponentsWithTypeV2(
    /* [1] */ tree,
    ReactComponentFactoryProxy componentFactory) {
  return _scryRenderedComponentsWithType(tree, getComponentTypeV2(componentFactory));
}

@JS('React.addons.TestUtils.scryRenderedDOMComponentsWithClass')

/// Finds all instances of components in the rendered tree that are DOM
/// components with the class name matching className.
external List<dynamic> scryRenderedDOMComponentsWithClass(
    /* [1] */ tree,
    String className);

@JS('React.addons.TestUtils.scryRenderedDOMComponentsWithTag')

/// Finds all instances of components in the rendered tree that are DOM
/// components with the tag name matching tagName.
external List<dynamic> scryRenderedDOMComponentsWithTag(
    /* [1] */ tree,
    String tagName);

/// Render a Component into a detached DOM node in the document.
@JS('React.addons.TestUtils.renderIntoDocument')
external /* [1] */ renderIntoDocument(ReactElement instance);

/// Pass a mocked component module to this method to augment it with useful
/// methods that allow it to be used as a dummy React component. Instead of
/// rendering as usual, the component will become a simple <div> (or other tag
/// if mockTagName is provided) containing any provided children.
@JS('React.addons.TestUtils.mockComponent')
external ReactClass mockComponent(ReactClass componentClass, String mockTagName);

/// Returns a ReactShallowRenderer instance
///
/// More info on using shallow rendering: https://reactjs.org/docs/test-renderer.html
@JS('React.addons.TestUtils.createRenderer')
external ReactShallowRenderer createRenderer();

/// ReactShallowRenderer wrapper
///
/// Usage:
/// ```
/// ReactShallowRenderer shallowRenderer = createRenderer();
/// shallowRenderer.render(div({'className': 'active'}));
///
/// ReactElement renderedOutput = shallowRenderer.getRenderOutput();
/// Map props = getProps(renderedOutput);
/// expect(props['className'], 'active');
/// ```
///
/// See react_with_addons.js#ReactShallowRenderer
@JS()
@anonymous
class ReactShallowRenderer {
  /// Get the rendered output. [render] must be called first
  external ReactElement getRenderOutput();
  external void render(ReactElement element, [context]);
  external void unmount();
}
