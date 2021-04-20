// ignore_for_file: deprecated_member_use_from_same_package
library react_client.event_helpers;

import 'dart:html';

import 'package:js/js_util.dart';
import 'package:react/react_client/js_interop_helpers.dart';
import 'package:react/src/react_client/synthetic_data_transfer.dart';
import 'package:react/src/react_client/synthetic_event_wrappers.dart';

/// Helper util that wraps a native [KeyboardEvent] in a [SyntheticKeyboardEvent].
///
/// Used where a native [KeyboardEvent] is given and a [SyntheticKeyboardEvent] is needed.
SyntheticKeyboardEvent wrapNativeKeyboardEvent(KeyboardEvent nativeEvent) {
  return jsifyAndAllowInterop({
    // SyntheticEvent fields
    'bubbles': nativeEvent.bubbles,
    'cancelable': nativeEvent.cancelable,
    'currentTarget': nativeEvent.currentTarget,
    'defaultPrevented': nativeEvent.defaultPrevented,
    'eventPhase': nativeEvent.eventPhase,
    'isTrusted': nativeEvent.isTrusted,
    'nativeEvent': nativeEvent,
    'target': nativeEvent.target,
    'timeStamp': nativeEvent.timeStamp,
    'type': nativeEvent.type,
    // SyntheticEvent methods
    'stopPropagation': nativeEvent.stopPropagation,
    'preventDefault': nativeEvent.preventDefault,
    'persist': () {},
    'isPersistent': () => true,
    // SyntheticKeyboardEvent fields
    'altKey': nativeEvent.altKey,
    'char': nativeEvent.charCode == null ? null : String.fromCharCode(nativeEvent.charCode),
    'ctrlKey': nativeEvent.ctrlKey,
    'locale': null,
    'location': nativeEvent.location,
    'key': nativeEvent.key,
    'metaKey': nativeEvent.metaKey,
    'repeat': nativeEvent.repeat,
    'shiftKey': nativeEvent.shiftKey,
    'keyCode': nativeEvent.keyCode,
    'charCode': nativeEvent.charCode,
    'detail': nativeEvent.detail,
    'view': nativeEvent.view,
    'getModifierState': nativeEvent.getModifierState,
  }) as SyntheticKeyboardEvent;
}

/// Helper util that wraps a native [MouseEvent] in a [SyntheticMouseEvent].
///
/// Used where a native [MouseEvent] is given and a [SyntheticMouseEvent] is needed.
SyntheticMouseEvent wrapNativeMouseEvent(MouseEvent nativeEvent) {
  return jsifyAndAllowInterop({
    // SyntheticEvent fields
    'bubbles': nativeEvent.bubbles,
    'cancelable': nativeEvent.cancelable,
    'currentTarget': nativeEvent.currentTarget,
    'defaultPrevented': nativeEvent.defaultPrevented,
    'eventPhase': nativeEvent.eventPhase,
    'isTrusted': nativeEvent.isTrusted,
    'nativeEvent': nativeEvent,
    'target': nativeEvent.target,
    'timeStamp': nativeEvent.timeStamp,
    'type': nativeEvent.type,
    // SyntheticEvent methods
    'stopPropagation': nativeEvent.stopPropagation,
    'preventDefault': nativeEvent.preventDefault,
    'persist': () {},
    'isPersistent': () => true,
    // SyntheticMouseEvent fields
    'altKey': nativeEvent.altKey,
    'button': nativeEvent.button,
    'buttons': nativeEvent.buttons,
    'clientX': nativeEvent.client.x,
    'clientY': nativeEvent.client.y,
    'ctrlKey': nativeEvent.ctrlKey,
    'dataTransfer': nativeEvent.dataTransfer,
    'metaKey': nativeEvent.metaKey,
    'pageX': nativeEvent.page.x,
    'pageY': nativeEvent.page.y,
    'relatedTarget': nativeEvent.relatedTarget,
    'screenX': nativeEvent.screen.x,
    'screenY': nativeEvent.screen.y,
    'shiftKey': nativeEvent.shiftKey,
    'detail': nativeEvent.detail,
    'view': nativeEvent.view,
    'getModifierState': nativeEvent.getModifierState,
  }) as SyntheticMouseEvent;
}

/// If the consumer specifies a callback like `onChange` on one of our custom form components that are not *actually*
/// form elements - we still need a valid [SyntheticFormEvent] to pass as the expected parameter to that callback.
///
/// This helper method generates a "fake" [SyntheticFormEvent], with nothing but the `target` set to [element],
/// `type` set to [type] and `timeStamp` set to the current time. All other arguments are `noop`, `false` or `null`.
SyntheticFormEvent fakeSyntheticFormEvent(Element element, String type) {
  return jsifyAndAllowInterop({
    // SyntheticEvent fields
    'bubbles': false,
    'cancelable': false,
    'currentTarget': element,
    'defaultPrevented': false,
    'eventPhase': Event.AT_TARGET,
    'isTrusted': false,
    'nativeEvent': null,
    'target': element,
    'timeStamp': DateTime.now().millisecondsSinceEpoch,
    'type': type,
    // SyntheticEvent methods
    'stopPropagation': () {},
    'preventDefault': () {},
    'persist': () {},
    'isPersistent': () => true,
  }) as SyntheticFormEvent;
}

Map<String, dynamic> _wrapBaseEventPropertiesInMap({
  SyntheticEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
}) {
  return {
    'bubbles': bubbles ?? baseEvent?.bubbles ?? false,
    'cancelable': cancelable ?? baseEvent?.cancelable ?? true,
    'currentTarget': currentTarget ?? baseEvent?.currentTarget,
    'defaultPrevented': defaultPrevented ?? baseEvent?.defaultPrevented ?? false,
    'preventDefault': preventDefault ?? baseEvent?.preventDefault ?? () {},
    'stopPropagation': stopPropagation ?? baseEvent?.stopPropagation ?? () {},
    'eventPhase': eventPhase ?? baseEvent?.eventPhase,
    'isTrusted': isTrusted ?? baseEvent?.isTrusted ?? false,
    'nativeEvent': nativeEvent ?? baseEvent?.nativeEvent,
    'target': target ?? baseEvent?.target,
    'timeStamp': timeStamp ?? baseEvent?.timeStamp ?? 0,
    'type': type ?? baseEvent?.type ?? 'empty event',
  };
}

/// Returns a newly constructed [SyntheticEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticEvent createSyntheticEvent({
  SyntheticEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
}) {
  return jsifyAndAllowInterop(_wrapBaseEventPropertiesInMap(
    baseEvent: baseEvent,
    bubbles: bubbles,
    cancelable: cancelable,
    currentTarget: currentTarget,
    defaultPrevented: defaultPrevented,
    preventDefault: preventDefault,
    stopPropagation: stopPropagation,
    eventPhase: eventPhase,
    isTrusted: isTrusted,
    nativeEvent: nativeEvent,
    target: target,
    timeStamp: timeStamp,
    type: type,
  )) as SyntheticEvent;
}

/// Returns a newly constructed [SyntheticClipboardEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticClipboardEvent createSyntheticClipboardEvent({
  SyntheticClipboardEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  dynamic clipboardData,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'clipboardData': clipboardData ?? baseEvent?.clipboardData,
  }) as SyntheticClipboardEvent;
}

/// Returns a newly constructed [SyntheticKeyboardEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticKeyboardEvent createSyntheticKeyboardEvent({
  SyntheticKeyboardEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  bool altKey,
  String char,
  bool ctrlKey,
  String locale,
  num location,
  String key,
  bool metaKey,
  bool repeat,
  bool shiftKey,
  num keyCode,
  num charCode,
  num detail,
  /*DOMAbstractView*/ dynamic view,
  bool Function(String key) getModifierState,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'altKey': altKey ?? baseEvent?.altKey ?? false,
    'char': char ?? baseEvent?.char,
    'charCode': charCode ?? baseEvent?.charCode,
    'ctrlKey': ctrlKey ?? baseEvent?.ctrlKey ?? false,
    'locale': locale ?? baseEvent?.locale,
    'location': location ?? baseEvent?.location,
    'key': key ?? baseEvent?.key,
    'keyCode': keyCode ?? baseEvent?.keyCode,
    'metaKey': metaKey ?? baseEvent?.metaKey ?? false,
    'repeat': repeat ?? baseEvent?.repeat,
    'shiftKey': shiftKey ?? baseEvent?.shiftKey ?? false,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
    'getModifierState': getModifierState ??
        baseEvent?.getModifierState ??
        (_) {
          return false;
        },
  }) as SyntheticKeyboardEvent;
}

/// Returns a newly constructed [SyntheticCompositionEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticCompositionEvent createSyntheticCompositionEvent({
  SyntheticCompositionEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  String data,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'data': data ?? baseEvent?.data,
  }) as SyntheticCompositionEvent;
}

/// Returns a newly constructed [SyntheticFocusEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticFocusEvent createSyntheticFocusEvent({
  SyntheticFocusEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  /*DOMEventTarget*/ dynamic relatedTarget,
  num detail,
  /*DOMAbstractView*/ dynamic view,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'relatedTarget': relatedTarget ?? baseEvent?.relatedTarget,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
  }) as SyntheticFocusEvent;
}

/// Returns a newly constructed [SyntheticFormEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticFormEvent createSyntheticFormEvent({
  SyntheticFormEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
  }) as SyntheticFormEvent;
}

/// Returns a newly constructed [SyntheticMouseEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticMouseEvent createSyntheticMouseEvent({
  SyntheticMouseEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  bool altKey,
  num button,
  num buttons,
  num clientX,
  num clientY,
  bool ctrlKey,
  dynamic dataTransfer,
  bool metaKey,
  num movementX,
  num movementY,
  num pageX,
  num pageY,
  /*DOMEventTarget*/ dynamic relatedTarget,
  num screenX,
  num screenY,
  bool shiftKey,
  num detail,
  /*DOMAbstractView*/ dynamic view,
  bool Function(String key) getModifierState,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'altKey': altKey ?? baseEvent?.altKey ?? false,
    'button': button ?? baseEvent?.button,
    'buttons': buttons ?? baseEvent?.buttons,
    'clientX': clientX ?? baseEvent?.clientX,
    'clientY': clientY ?? baseEvent?.clientY,
    'ctrlKey': ctrlKey ?? baseEvent?.ctrlKey ?? false,
    'dataTransfer': dataTransfer ?? baseEvent?.dataTransfer,
    'metaKey': metaKey ?? baseEvent?.metaKey ?? false,
    'movementX': movementX ?? baseEvent?.movementX,
    'movementY': movementY ?? baseEvent?.movementY,
    'pageX': pageX ?? baseEvent?.pageX,
    'pageY': pageY ?? baseEvent?.pageY,
    'relatedTarget': relatedTarget ?? baseEvent?.relatedTarget,
    'screenX': screenX ?? baseEvent?.screenX,
    'screenY': screenY ?? baseEvent?.screenY,
    'shiftKey': shiftKey ?? baseEvent?.shiftKey ?? false,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
    'getModifierState': getModifierState ??
        baseEvent?.getModifierState ??
        (_) {
          return false;
        },
  }) as SyntheticMouseEvent;
}

/// Returns a newly constructed [SyntheticPointerEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticPointerEvent createSyntheticPointerEvent({
  SyntheticPointerEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  num pointerId,
  num width,
  num height,
  num pressure,
  num tangentialPressure,
  num tiltX,
  num tiltY,
  num twist,
  String pointerType,
  bool isPrimary,
  num detail,
  /*DOMAbstractView*/ dynamic view,
  bool Function(String key) getModifierState,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'pointerId': pointerId ?? baseEvent?.pointerId,
    'width': width ?? baseEvent?.width,
    'height': height ?? baseEvent?.height,
    'pressure': pressure ?? baseEvent?.pressure,
    'tangentialPressure': tangentialPressure ?? baseEvent?.tangentialPressure,
    'tiltX': tiltX ?? baseEvent?.tiltX,
    'tiltY': tiltY ?? baseEvent?.tiltY,
    'twist': twist ?? baseEvent?.twist,
    'pointerType': pointerType ?? baseEvent?.pointerType,
    'isPrimary': isPrimary ?? baseEvent?.isPrimary,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
    'getModifierState': getModifierState ??
        baseEvent?.getModifierState ??
        (_) {
          return false;
        },
  }) as SyntheticPointerEvent;
}

/// Returns a newly constructed [SyntheticTouchEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticTouchEvent createSyntheticTouchEvent({
  SyntheticTouchEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  bool altKey,
  /*DOMTouchList*/ dynamic changedTouches,
  bool ctrlKey,
  bool metaKey,
  bool shiftKey,
  /*DOMTouchList*/ dynamic targetTouches,
  /*DOMTouchList*/ dynamic touches,
  num detail,
  /*DOMAbstractView*/ dynamic view,
  bool Function(String key) getModifierState,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'altKey': altKey ?? baseEvent?.altKey ?? false,
    'changedTouches': changedTouches ?? baseEvent?.changedTouches,
    'ctrlKey': ctrlKey ?? baseEvent?.ctrlKey ?? false,
    'metaKey': metaKey ?? baseEvent?.metaKey ?? false,
    'shiftKey': shiftKey ?? baseEvent?.shiftKey ?? false,
    'targetTouches': targetTouches ?? baseEvent?.targetTouches,
    'touches': touches ?? baseEvent?.touches,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
    'getModifierState': getModifierState ??
        baseEvent?.getModifierState ??
        (_) {
          return false;
        },
  }) as SyntheticTouchEvent;
}

/// Returns a newly constructed [SyntheticTransitionEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticTransitionEvent createSyntheticTransitionEvent({
  SyntheticTransitionEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  String propertyName,
  num elapsedTime,
  String pseudoElement,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'propertyName': propertyName ?? baseEvent?.propertyName,
    'elapsedTime': elapsedTime ?? baseEvent?.elapsedTime,
    'pseudoElement': pseudoElement ?? baseEvent?.pseudoElement,
  }) as SyntheticTransitionEvent;
}

/// Returns a newly constructed [SyntheticAnimationEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticAnimationEvent createSyntheticAnimationEvent({
  SyntheticAnimationEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  String animationName,
  num elapsedTime,
  String pseudoElement,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'animationName': animationName ?? baseEvent?.animationName,
    'elapsedTime': elapsedTime ?? baseEvent?.elapsedTime,
    'pseudoElement': pseudoElement ?? baseEvent?.pseudoElement,
  }) as SyntheticAnimationEvent;
}

/// Returns a newly constructed [SyntheticUIEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticUIEvent createSyntheticUIEvent({
  SyntheticUIEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  num detail,
  /*DOMAbstractView*/ dynamic view,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
  }) as SyntheticUIEvent;
}

/// Returns a newly constructed [SyntheticWheelEvent] instance.
///
/// In addition to creating empty instances (by invoking without any parameters) or completely custom instances
/// by using the named parameters, this function will merge previously existing [baseEvent]s with the named parameters provided.
/// The named parameters takes precedence, and therefore can be used to override specific fields on the [baseEvent].
SyntheticWheelEvent createSyntheticWheelEvent({
  SyntheticWheelEvent baseEvent,
  bool bubbles,
  bool cancelable,
  dynamic currentTarget,
  bool defaultPrevented,
  void Function() preventDefault,
  void Function() stopPropagation,
  num eventPhase,
  bool isTrusted,
  dynamic nativeEvent,
  dynamic target,
  num timeStamp,
  String type,
  num deltaX,
  num deltaMode,
  num deltaY,
  num deltaZ,
  num detail,
  /*DOMAbstractView*/ dynamic view,
  bool Function(String key) getModifierState,
}) {
  return jsifyAndAllowInterop({
    ..._wrapBaseEventPropertiesInMap(
      baseEvent: baseEvent,
      bubbles: bubbles,
      cancelable: cancelable,
      currentTarget: currentTarget,
      defaultPrevented: defaultPrevented,
      preventDefault: preventDefault,
      stopPropagation: stopPropagation,
      eventPhase: eventPhase,
      isTrusted: isTrusted,
      nativeEvent: nativeEvent,
      target: target,
      timeStamp: timeStamp,
      type: type,
    ),
    'deltaX': deltaX ?? baseEvent?.deltaX,
    'deltaMode': deltaMode ?? baseEvent?.deltaMode,
    'deltaY': deltaY ?? baseEvent?.deltaY,
    'deltaZ': deltaZ ?? baseEvent?.deltaZ,
    'detail': detail ?? baseEvent?.detail,
    'view': view ?? baseEvent?.view,
    'getModifierState': getModifierState ??
        baseEvent?.getModifierState ??
        (_) {
          return false;
        },
  }) as SyntheticWheelEvent;
}

extension SyntheticEventTypeHelpers on SyntheticEvent {
  bool _checkEventType(List<String> types) => this != null && type != null && types.any((t) => type.contains(t));
  bool _hasProperty(String propertyName) => this != null && hasProperty(this, propertyName);

  /// Whether the event instance has been removed from the ReactJS event pool.
  ///
  /// > See: [persist]
  @Deprecated('The modern event system does not use pooling. This always returns true, and will be removed in 7.0.0.')
  bool get isPersistent => true;

  /// Uses Duck Typing to detect if the event instance is a [SyntheticClipboardEvent].
  bool get isClipboardEvent => _hasProperty('clipboardData') || _checkEventType(const ['copy', 'paste', 'cut']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticKeyboardEvent].
  bool get isKeyboardEvent => _hasProperty('key') || _checkEventType(const ['key']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticCompositionEvent].
  bool get isCompositionEvent => _hasProperty('data') || _checkEventType(const ['composition']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticFocusEvent].
  bool get isFocusEvent =>
      (_hasProperty('relatedTarget') && !_hasProperty('button')) || _checkEventType(const ['focus', 'blur']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticMouseEvent].
  bool get isMouseEvent =>
      _hasProperty('button') || _checkEventType(const ['mouse', 'click', 'drag', 'drop', 'contextmenu']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticPointerEvent].
  bool get isPointerEvent => _hasProperty('pointerId') || _checkEventType(const ['pointer']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticTouchEvent].
  bool get isTouchEvent => _hasProperty('targetTouches') || _checkEventType(const ['touch']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticTransitionEvent].
  bool get isTransitionEvent => _hasProperty('propertyName') || _checkEventType(const ['transition']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticAnimationEvent].
  bool get isAnimationEvent => _hasProperty('animationName') || _checkEventType(const ['animation']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticUIEvent].
  bool get isUiEvent => _hasProperty('detail') || _checkEventType(const ['scroll']);

  /// Uses Duck Typing to detect if the event instance is a [SyntheticWheelEvent].
  bool get isWheelEvent => _hasProperty('deltaX') || _checkEventType(const ['wheel']);
}

extension DataTransferHelper on SyntheticMouseEvent {
  /// The data that is transferred during a drag and drop interaction.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/dataTransfer>
  SyntheticDataTransfer get dataTransfer => syntheticDataTransferFactory(getProperty(this, 'dataTransfer'));
}
