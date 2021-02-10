/// Keys for React DOM event handlers.
final Set<String> knownEventKeys = (() {
  final _knownEventKeys = {
    // SyntheticClipboardEvent
    'onCopy',
    'onCut',
    'onPaste',

    // SyntheticKeyboardEvent
    'onKeyDown',
    'onKeyPress',
    'onKeyUp',

    // SyntheticCompositionEvent
    'onCompositionStart',
    'onCompositionUpdate',
    'onCompositionEnd',

    // SyntheticFocusEvent
    'onFocus',
    'onBlur',

    // SyntheticFormEvent
    'onChange',
    'onInput',
    'onSubmit',
    'onReset',

    // SyntheticMouseEvent
    'onClick',
    'onContextMenu',
    'onDoubleClick',
    'onDrag',
    'onDragEnd',
    'onDragEnter',
    'onDragExit',
    'onDragLeave',
    'onDragOver',
    'onDragStart',
    'onDrop',
    'onMouseDown',
    'onMouseEnter',
    'onMouseLeave',
    'onMouseMove',
    'onMouseOut',
    'onMouseOver',
    'onMouseUp',

    // SyntheticPointerEvent
    'onGotPointerCapture',
    'onLostPointerCapture',
    'onPointerCancel',
    'onPointerDown',
    'onPointerEnter',
    'onPointerLeave',
    'onPointerMove',
    'onPointerOver',
    'onPointerOut',
    'onPointerUp',

    // SyntheticTouchEvent
    'onTouchCancel',
    'onTouchEnd',
    'onTouchMove',
    'onTouchStart',

    // SyntheticTransitionEvent
    'onTransitionEnd',

    // SyntheticAnimationEvent
    'onAnimationEnd',
    'onAnimationIteration',
    'onAnimationStart',

    // SyntheticUIEvent
    'onScroll',

    // SyntheticWheelEvent
    'onWheel',
  };

  // Add support for capturing variants; e.g., onClick/onClickCapture
  for (final key in _knownEventKeys.toList()) {
    _knownEventKeys.add('${key}Capture');
  }

  return _knownEventKeys;
})();
