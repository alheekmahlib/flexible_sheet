import 'package:flutter/foundation.dart';

/// Actions that can be dispatched from the controller to the sheet widget.
///
/// Used internally by the sheet widget to determine which animation to run.
enum SheetAction {
  /// Animate to the maximum height.
  open,

  /// Animate to the minimum height.
  close,

  /// Animate to an arbitrary target height.
  animateTo,
}

/// A controller for [FlexibleSheet] that allows programmatic control
/// of the sheet's state.
///
/// Use [open], [close], [toggle], or [animateTo] to control the sheet.
///
/// The controller also exposes the current state via [isOpen] and
/// [currentHeight].
///
/// Example:
/// ```dart
/// final controller = FlexibleSheetController();
///
/// // Open the sheet
/// controller.open();
///
/// // Close the sheet
/// controller.close();
///
/// // Toggle between open and closed
/// controller.toggle();
///
/// // Animate to a specific height
/// controller.animateTo(300);
/// ```
class FlexibleSheetController extends ChangeNotifier {
  /// Creates a [FlexibleSheetController].
  ///
  /// If [initialIsOpen] is true, the sheet will start in the open state.
  FlexibleSheetController({bool initialIsOpen = false})
      : _isOpen = initialIsOpen;

  bool _isOpen;
  double _currentHeight = 0;
  bool _isHandleVisible = true;
  SheetAction? _lastAction;
  double? _targetHeight;

  /// Whether the sheet is currently open (at max height).
  bool get isOpen => _isOpen;

  /// The current height of the sheet.
  ///
  /// This value is updated by the sheet widget as the height changes.
  double get currentHeight => _currentHeight;

  /// The last action dispatched, used internally by the sheet widget.
  SheetAction? get lastAction => _lastAction;

  /// The target height for [animateTo], used internally by the sheet widget.
  double? get targetHeight => _targetHeight;

  /// Whether the drag handle is currently visible.
  bool get isHandleVisible => _isHandleVisible;

  /// Opens the sheet (animates to max height).
  void open() {
    if (_isOpen && _lastAction == SheetAction.open) return;
    _isOpen = true;
    _lastAction = SheetAction.open;
    _targetHeight = null;
    notifyListeners();
  }

  /// Closes the sheet (animates to min height).
  void close() {
    if (!_isOpen && _lastAction == SheetAction.close) return;
    _isOpen = false;
    _lastAction = SheetAction.close;
    _targetHeight = null;
    notifyListeners();
  }

  /// Toggles the sheet between open and closed.
  void toggle() {
    _isOpen ? close() : open();
  }

  /// Animates the sheet to a specific [height].
  ///
  /// The height will be clamped between the sheet's min and max height.
  void animateTo(double height) {
    _lastAction = SheetAction.animateTo;
    _targetHeight = height;
    notifyListeners();
  }

  /// Updates the current height. Called internally by the sheet widget.
  ///
  /// This is not intended to be called by external consumers.
  @internal
  void updateHeight(double height) {
    _currentHeight = height;
  }

  /// Updates the open state. Called internally by the sheet widget.
  ///
  /// This is not intended to be called by external consumers.
  @internal
  void updateOpenState(bool isOpen) {
    _isOpen = isOpen;
  }

  /// Shows the drag handle.
  ///
  /// If the handle is already visible, this is a no-op.
  void showHandle() {
    if (_isHandleVisible) return;
    _isHandleVisible = true;
    _lastAction = null;
    notifyListeners();
  }

  /// Hides the drag handle.
  ///
  /// If the handle is already hidden, this is a no-op.
  void hideHandle() {
    if (!_isHandleVisible) return;
    _isHandleVisible = false;
    _lastAction = null;
    notifyListeners();
  }
}
