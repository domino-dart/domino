import 'domino.dart';

Element div([content]) => new Element('div', content);

Element button(content, {EventHandler onClick}) =>
    new Element('button', [content, on('click', onClick)]);
