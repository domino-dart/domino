import 'domino.dart';

Element div([dynamic content]) => Element('div', content);
Element span([dynamic content]) => Element('span', content);

Element button(dynamic content, {Function onClick}) =>
    Element('button', [content, on('click', onClick)]);

Setter background(String value) => style('background', value);
