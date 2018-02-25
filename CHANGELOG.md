# Changelog

## 0.3.1

- Fix readme's example.
- New implementation for `StatefulComponent`.
- Conditional content structure with `addIf`.
- **Breaking change**: matching `clazzIf` with `addIf` signature.

## 0.3.0

**Breaking changes**: full API rewrite:
- Building `Element`s become simpler.
- `Setter` become first-class build pattern.
- `#symbols` become first-class patterns (replace previous `key`). `Event.getNodeBySymbol` may
  access referenced `Element`s within the scope of the current `Component`.
- Removed `StatefulComponent` (still working on a better state handling).
- Misc API simplification (e.g. `Event.domElement` => `Event.element`).

Updates:
- Fixed attribute update issues.

## 0.2.1

- Element `Setter` for shortcut certain build patterns.
- Enable `String` and embedded `List`s to set for `Element.classes` and `clazz` setters.
- `View.track` to execute (async) actions that will trigger the invalidation of the `View`.
- `View.escape` to escape the tracker zone for `EventHandler`s that are registered inside the `View`.
- Expose `View` in `BuildContext`.
- Experimental `SubView`.
- Experimental `StatefulComponent` (moved to `experimental.dart`).

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
