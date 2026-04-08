<!-- 
commands :

dart doc
dart format .
flutter pub publish --dry-run
-->

# Flexible Sheet

<p align="center">
<img src="https://raw.githubusercontent.com/alheekmahlib/data/refs/heads/main/packages/flexible_sheet/flexible_sheet_banner.png" width="500"/>
</p>

A flexible, persistent sheet widget for Flutter that supports `top-to-bottom` and `bottom-to-top` directions with configurable snap behavior, spring physics, and programmatic control.

<!-- الصف الأول -->
<p align="center">
  <a href="https://pub.dev/packages/flexible_sheet">
    <img alt="pub package" src="https://img.shields.io/pub/v/flexible_sheet.svg?color=2cacbf&labelColor=145261" />
  </a>
  <a href="https://pub.dev/packages/flexible_sheet/score">
    <img alt="pub points" src="https://img.shields.io/pub/points/flexible_sheet?color=2cacbf&labelColor=145261" />
  </a>
  <a href="https://pub.dev/packages/flexible_sheet/score">
    <img alt="likes" src="https://img.shields.io/pub/likes/flexible_sheet?color=2cacbf&labelColor=145261" />
  </a>
  <a href="https://pub.dev/packages/flexible_sheet/score">
    <img alt="Pub Downloads" src="https://img.shields.io/pub/dm/flexible_sheet?color=2cacbf&labelColor=145261" />
  </a>
  <a href="LICENSE">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-2cacbf.svg?labelColor=145261" />
  </a>
</p>

<!-- الصف الثاني -->
<p align="center">
  <a href="https://flutter.dev/">
    <img alt="Web" src="https://img.shields.io/badge/Web-145261?logo=google-chrome&logoColor=white" />
  </a>
  <a href="https://flutter.dev/">
    <img alt="Windows" src="https://img.shields.io/badge/Windows-145261?logo=Windows&logoColor=white" />
  </a>
  <a href="https://flutter.dev/">
    <img alt="macOS" src="https://img.shields.io/badge/macOS-145261?logo=apple&logoColor=white" />
  </a>
  <a href="https://flutter.dev/">
    <img alt="Android" src="https://img.shields.io/badge/Android-145261?logo=android&logoColor=white" />
  </a>
  <a href="https://flutter.dev/">
    <img alt="iOS" src="https://img.shields.io/badge/iOS-145261?logo=ios&logoStyle=bold&logoColor=white" />
  </a>
</p>

---

## Features

- **Bidirectional** — slides from **top** or **bottom** via `SheetDirection.topToBottom` / `SheetDirection.bottomToTop`
- **Snap behavior** — snap to edges or remain at the released position via `SheetSnapBehavior.snapToEdge` / `SheetSnapBehavior.freePosition`
- **Spring physics** — fine-tune mass, stiffness, damping, and velocity through `SheetPhysics`
- **Programmatic control** — `open()`, `close()`, `toggle()`, `animateTo(height)` via `FlexibleSheetController`
- **Handle visibility** — show or hide the drag handle at runtime with `showHandle()` / `hideHandle()`
- **Width & alignment** — optionally constrain the sheet width and align it horizontally within its parent
- **Callbacks** — listen to open/close state changes (`onStateChanged`) and continuous height updates (`onHeightChanged`)
- **Zero dependencies** — built entirely on the Flutter SDK with no external packages

### Demo

<p align="center">
<img src="https://raw.githubusercontent.com/alheekmahlib/data/refs/heads/main/packages/flexible_sheet/demo.gif" width="340"/>
</p>

---

## Getting Started

Add the package to your project:

```
flutter pub add flexible_sheet
```

Import it:

```dart
import 'package:flexible_sheet/flexible_sheet.dart';
```

---

## Usage

### Top-to-Bottom Sheet (default)

```dart
final controller = FlexibleSheetController();

FlexibleSheet(
  maxHeight: 500,
  minHeight: 50,
  controller: controller,
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
  onStateChanged: (isOpen) => debugPrint('isOpen: $isOpen'),
  onHeightChanged: (h) => debugPrint('height: ${h.round()}'),
);

// Programmatic control
controller.open();
controller.close();
controller.toggle();
controller.animateTo(250);
```

### Bottom-to-Top Sheet

```dart
FlexibleSheet(
  maxHeight: 500,
  minHeight: 50,
  direction: SheetDirection.bottomToTop,
  controller: controller,
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
);
```

### Free Position (no snapping)

```dart
FlexibleSheet(
  maxHeight: 500,
  minHeight: 50,
  snapBehavior: SheetSnapBehavior.freePosition,
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
);
```

### Custom Width & Alignment

```dart
FlexibleSheet(
  maxHeight: 400,
  minHeight: 60,
  width: 320,
  alignment: Alignment.centerRight,
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
);
```

### Custom Spring Physics

```dart
FlexibleSheet(
  maxHeight: 500,
  minHeight: 50,
  physics: SheetPhysics(
    spring: SpringDescription(mass: 1, stiffness: 600, damping: 35),
    defaultVelocity: 2000,
  ),
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
);
```

### Handle Visibility Control

```dart
final controller = FlexibleSheetController();

// Hide the drag handle programmatically
controller.hideHandle();

// Show it again
controller.showHandle();

// Check current state
print(controller.isHandleVisible); // true or false
```

### Start in Open State

```dart
final controller = FlexibleSheetController(initialIsOpen: true);

FlexibleSheet(
  maxHeight: 500,
  minHeight: 50,
  initialHeight: 500,
  controller: controller,
  childBuilder: (height) => MyContent(height: height),
  handleBuilder: (height) => const MyHandle(),
);
```

---

## API Reference

### `FlexibleSheet` Widget

| Parameter | Type | Default | Description |
|---|---|---|---|
| `maxHeight` | `double` | **required** | Maximum height the sheet can expand to |
| `minHeight` | `double` | **required** | Minimum height the sheet collapses to |
| `childBuilder` | `Widget Function(double)` | **required** | Builder for the sheet content; receives the current height |
| `handleBuilder` | `Widget Function(double)?` | `null` | Builder for the drag handle; receives the current height |
| `controller` | `FlexibleSheetController?` | `null` | Controller for programmatic open, close, toggle, and animation |
| `direction` | `SheetDirection` | `topToBottom` | Slide direction: `topToBottom` or `bottomToTop` |
| `snapBehavior` | `SheetSnapBehavior` | `snapToEdge` | Snap behavior on release: `snapToEdge` or `freePosition` |
| `physics` | `SheetPhysics?` | default | Spring animation configuration (mass, stiffness, damping, velocity) |
| `initialHeight` | `double?` | `minHeight` | Starting height; must be between `minHeight` and `maxHeight` |
| `width` | `double?` | `null` | Optional fixed width; if `null`, the sheet fills its parent width |
| `alignment` | `AlignmentGeometry?` | `null` | Horizontal alignment when `width` is set; defaults to center |
| `isDraggable` | `bool` | `true` | Whether the user can drag the handle to resize |
| `onStateChanged` | `ValueChanged<bool>?` | `null` | Called when the sheet opens (`true`) or closes (`false`) |
| `onHeightChanged` | `ValueChanged<double>?` | `null` | Called on every height change (drag or animation) |
| `clipBehavior` | `Clip` | `Clip.hardEdge` | Clipping behavior for the sheet content |

### `FlexibleSheetController`

#### Constructor

```dart
FlexibleSheetController({bool initialIsOpen = false})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `initialIsOpen` | `bool` | `false` | Whether the sheet starts in the open state |

#### Methods

| Method | Description |
|---|---|
| `open()` | Animate the sheet to `maxHeight` |
| `close()` | Animate the sheet to `minHeight` |
| `toggle()` | Toggle between open and closed states |
| `animateTo(double height)` | Animate to a specific height (clamped to min/max) |
| `showHandle()` | Make the drag handle visible |
| `hideHandle()` | Hide the drag handle |

#### Properties

| Property | Type | Description |
|---|---|---|
| `isOpen` | `bool` | Whether the sheet is currently at `maxHeight` |
| `currentHeight` | `double` | The current height of the sheet |
| `isHandleVisible` | `bool` | Whether the drag handle is currently visible |

### `SheetPhysics`

```dart
const SheetPhysics({
  SpringDescription spring = const SpringDescription(mass: 1, stiffness: 500, damping: 30),
  double defaultVelocity = 1500,
})
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `spring` | `SpringDescription` | mass: 1, stiffness: 500, damping: 30 | Spring configuration for animations |
| `defaultVelocity` | `double` | `1500` | Default animation velocity in px/s for programmatic actions |

### Enums

#### `SheetDirection`

| Value | Description |
|---|---|
| `topToBottom` | Content on top, handle below — dragging down expands the sheet |
| `bottomToTop` | Handle on top, content below — dragging up expands the sheet |

#### `SheetSnapBehavior`

| Value | Description |
|---|---|
| `snapToEdge` | Snaps to fully open or fully closed based on velocity and position |
| `freePosition` | Stays at the exact height where the user released the drag |

---

## Migration from 1.x

```dart
// Before (1.x)
import 'package:persistent_top_sheet/persistent_top_sheet.dart';
final controller = PersistentTopSheetController();
PersistentTopSheet(
  maxHeight: 500, minHeight: 50,
  animationSpeed: 2000,
  controller: controller,
  childBuilder: (h) => ...,
  handleBuilder: (h) => ...,
);

// After (2.0)
import 'package:flexible_sheet/flexible_sheet.dart';
final controller = FlexibleSheetController();
FlexibleSheet(
  maxHeight: 500, minHeight: 50,
  physics: SheetPhysics(defaultVelocity: 2000),
  controller: controller,
  childBuilder: (h) => ...,
  handleBuilder: (h) => ...,
);
```

---

## Additional Information

A complete working example is available in the [`/example`](example/) folder.

Feel free to [open an issue](https://github.com/alheekmahlib/flexible_sheet/issues), contribute, or request features on [GitHub](https://github.com/alheekmahlib/flexible_sheet)!