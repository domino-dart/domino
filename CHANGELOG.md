# Changelog

## 0.2.1-dev

- Element `Setter` for shortcut certain build patterns.
- Enable `String` and embedded `List`s to set for `Element.classes` and `clazz` setters.
- `View.track` to execute (async) actions that will trigger the invalidation of the `View`.
- `View.escape` to escape the tracker zone for `EventHandler`s that are registered inside the `View`.

## 0.2.0+1

- Fix NPE.

## 0.2.0

**Breaking changes**:

- Removed `Element.text` and `Element.children`, using `Element.content` instead.
- content items that are not `List`, `Component`, `String`, `Node` or `BuildFn` will be converted to `String` (and to `Text`). 

Updates:

- Fix: `BuildContext.ancestors` did not include `Component`s.
- Fix: classes were not updated when the new Element had no class.
- Fix: attributes were not updated when the new Element had no attributes.
- Fix: reduce the non-keyed reuse of DOM Elements that have non-matching style properties. (using `key` reuses them)

## 0.1.1

- Fix: root component was not added to ancestor list.
- Enable multiple (and non-component) children as root for a `View`.
- New node helper (`br`).

## 0.1.0

- Initial version.
