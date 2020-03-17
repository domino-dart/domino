import 'package:domino/src/experimental/idom.dart' as _i0 show DomContext;
import 'package:meta/meta.dart' as _i2 show required;
import 'ex1_model.dart' as _i1 show Example;

void Ex1(_i0.DomContext $d
, {
/// Go recursive
bool extra,
@_i2.required _i1.Example obj,
Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
extra ??= false;
$dSlots ??= {};
    $d.open('div' , key: 'key1');
    $d.attr('title', 'Some help ${obj.name}.');
    $d.text('Some ${obj.text} and ${obj.number}.');
    $d.close();
if (obj.cond1) {
    $d.open('span' , key: obj.number.toString());
    $d.text('cond1');
    $d.close();
}
else if (obj.cond2 && extra) {
    $d.open('span' );
    $d.text('cond2');
    $d.close();
}
else {
    $d.open('span' );
    $d.text('cond3');
    $d.close();
}
    $d.open('ul' );
for (final item in obj.items) {
if (item.visible) {
    $d.open('li' );
    $d.text('${item.label} ${obj.name}');
    $d.close();
}
}
    $d.close();
if (extra) {
$dSlots[]=
    void (_i0.DomContext $d){
};
Ex1($d, obj: obj, extra: false, $dSlots: $dSlots
);
}
$dSlots[]=
    void (_i0.DomContext $d){
};
Ex2($d, $dSlots: $dSlots
);
}
void Ex2(_i0.DomContext $d
, {Map<String, void Function(_i0.DomContext)> $dSlots,
}) {
$dSlots ??= {};
    $d.open('div' );
    $d.text('X');
    $d.close();
}
