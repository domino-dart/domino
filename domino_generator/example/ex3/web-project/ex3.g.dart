import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import './components/named-div/button.g.dart' as _i1 show renderButton;
import './components/named-div/library.dart' as _i2
    show renderBlueBox, renderRedBox;

void renderEx3(_i0.DomContext $d) {
  $d.open('button');
  {
    String tc49a9a67$TheBestButton() =>
        (_$strings[r'tc49a9a67$TheBestButton'].containsKey($d.globals.locale)
                ? _$strings[r'tc49a9a67$TheBestButton'][$d.globals.locale]
                : _$strings[r'tc49a9a67$TheBestButton'][''])
            .toString();
    $d.text(tc49a9a67$TheBestButton());
  }
  $d.close();
  _i1.renderButton($d);
  _i2.renderRedBox($d);
  _i2.renderBlueBox($d, slot: (_i0.DomContext $d) {
    {
      String t20be9e0a$HereIsAnInputField() =>
          (_$strings[r't20be9e0a$HereIsAnInputField']
                      .containsKey($d.globals.locale)
                  ? _$strings[r't20be9e0a$HereIsAnInputField']
                      [$d.globals.locale]
                  : _$strings[r't20be9e0a$HereIsAnInputField'][''])
              .toString();
      $d.text(t20be9e0a$HereIsAnInputField());
    }
    $d.open('input');
    $d.close();
    {
      String t846efa2d$AndAButtonComponentFrom() =>
          (_$strings[r't846efa2d$AndAButtonComponentFrom']
                      .containsKey($d.globals.locale)
                  ? _$strings[r't846efa2d$AndAButtonComponentFrom']
                      [$d.globals.locale]
                  : _$strings[r't846efa2d$AndAButtonComponentFrom'][''])
              .toString();
      $d.text(t846efa2d$AndAButtonComponentFrom());
    }
    $d.open('d.button');
    $d.close();
  });
}

const _$strings = {
  r'tc49a9a67$TheBestButton': {
    '_params': r'{}',
    '': r'The best button',
  },
  r't20be9e0a$HereIsAnInputField': {
    '_params': r'{}',
    '': r'Here is an input field:',
  },
  r't846efa2d$AndAButtonComponentFrom': {
    '_params': r'{}',
    '': r'And a button component from somewhere',
  },
};
