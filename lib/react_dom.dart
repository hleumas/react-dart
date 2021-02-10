// Copyright (c) 2016, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library react_dom;

// ignore: deprecated_member_use_from_same_package
import 'package:react/react.dart' show Component;
import 'package:react/react_client/react_interop.dart' show ReactDom;
import 'package:react/src/react_client/private_utils.dart' show validateJsApiThenReturn;

/// Renders a `ReactElement` into the DOM in the supplied `container` and returns a reference to the component
/// (or returns null for stateless components).
///
/// If the `ReactElement` was previously rendered into the `container`, this will perform an update on it and only
/// mutate the DOM as necessary to reflect the latest React component.
///
/// TODO: Is there any reason to omit the `ReactElement` type for `component` or the `Element` type for `container`?
Function render = validateJsApiThenReturn(() => ReactDom.render);

/// Removes a mounted React component from the DOM and cleans up its event handlers and state.
///
/// > Returns `false` if no component was mounted in the container specified via [render], otherwise returns `true`.
Function unmountComponentAtNode = validateJsApiThenReturn(() => ReactDom.unmountComponentAtNode);

/// If the component has been mounted into the DOM, this returns the corresponding native browser DOM `Element`.
Function findDOMNode = validateJsApiThenReturn(() => _findDomNode);

dynamic _findDomNode(component) {
  // ignore: deprecated_member_use_from_same_package
  return ReactDom.findDOMNode(component is Component ? component.jsThis : component);
}
