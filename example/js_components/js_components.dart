@JS()
library js_components;

import 'dart:html';

import 'package:js/js.dart';
import 'package:react/react.dart' as react;
import 'package:react/react_client.dart';
import 'package:react/react_client/react_interop.dart';
import 'package:react/react_dom.dart' as react_dom;

main() {
  final content = IndexComponent({});

  react_dom.render(content, querySelector('#content'));
}

var IndexComponent = react.registerComponent2(() => _IndexComponent());

class _IndexComponent extends react.Component2 {
  SimpleCustomComponent simpleRef;

  @override
  get initialState => {
        'open': false,
      };

  handleClose(_) {
    setState({
      'open': false,
    });
  }

  handleClick(_) {
    setState({
      'open': true,
    });
    print(simpleRef.getFoo());
  }

  @override
  render() {
    return MuiThemeProvider(
      {
        'theme': theme,
      },
      SimpleCustom({
        'foo': 'Foo Prop from dart... IN A JAVASCRIPT COMPONENT!',
        'ref': (ref) {
          simpleRef = ref;
        }
      }),
      CssBaseline({}),
      Dialog(
          {
            'open': state['open'],
            'onClose': handleClose,
          },
          DialogTitle({}, 'Super Secret Password'),
          DialogContent(
            {},
            DialogContentText({}, '1-2-3-4-5'),
          ),
          DialogActions(
            {},
            Button({
              'color': 'primary',
              'onClick': handleClose,
            }, 'OK'),
          )),
      Typography({
        'variant': 'h4',
        'gutterBottom': true,
      }, 'Material-UI'),
      Typography({
        'variant': 'subtitle1',
        'gutterBottom': true,
      }, 'example project'),
      Button({
        'variant': 'contained',
        'color': 'secondary',
        'onClick': handleClick,
      }, Icon({}, 'fingerprint'), 'Super Secret Password'),
    );
  }
}

/// The JS component class.
///
/// Private since [SimpleCustomComponent] will be used instead.
///
/// Accessible via `SimpleCustomComponent.type`.
@JS()
external ReactClass get _SimpleCustomComponent;

/// A factory for the "_SimpleJsModalContent" JS components class that allows it
/// to be used via Dart code.
///
/// Use this to render instances of the component from within Dart code.
///
/// This converts the Dart props [Map] passed into it in the
/// the same way props are converted for DOM components.
final SimpleCustom = ReactJsComponentFactoryProxy(_SimpleCustomComponent);

/// JS interop wrapper class for the component,
/// allowing us to interact with component instances
/// made available via refs or [react_dom.render] calls.
///
/// This is optional, as you won't always need to access the component's API.
@JS('_SimpleCustomComponent')
class SimpleCustomComponent {
  external String getFoo();
}

/// JS interop wrapper class for Material UI
/// getting us access to the react classes
@JS()
class MaterialUI {
  external static ReactClass get Button;
  external static ReactClass get CssBaseline;
  external static ReactClass get Dialog;
  external static ReactClass get DialogActions;
  external static ReactClass get DialogContent;
  external static ReactClass get DialogContentText;
  external static ReactClass get DialogTitle;
  external static ReactClass get Icon;
  external static ReactClass get MuiThemeProvider;
  external static ReactClass get Typography;
}

/// JS Interop to get theme config we setup in JS
@JS()
external Map get theme;

// All the Material UI components converted to dart Components
final Button = ReactJsComponentFactoryProxy(MaterialUI.Button);
final CssBaseline = ReactJsComponentFactoryProxy(MaterialUI.CssBaseline);
final Dialog = ReactJsComponentFactoryProxy(MaterialUI.Dialog);
final DialogActions = ReactJsComponentFactoryProxy(MaterialUI.DialogActions);
final DialogContent = ReactJsComponentFactoryProxy(MaterialUI.DialogContent);
final DialogContentText = ReactJsComponentFactoryProxy(MaterialUI.DialogContentText);
final DialogTitle = ReactJsComponentFactoryProxy(MaterialUI.DialogTitle);
final Icon = ReactJsComponentFactoryProxy(MaterialUI.Icon);
final MuiThemeProvider = ReactJsComponentFactoryProxy(MaterialUI.MuiThemeProvider);
final Typography = ReactJsComponentFactoryProxy(MaterialUI.Typography);
