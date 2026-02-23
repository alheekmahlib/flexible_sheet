/// Defines the direction from which the sheet slides in.
enum SheetDirection {
  /// The sheet slides from the top towards the bottom.
  ///
  /// The content area is at the top, and the handle is below it.
  /// Dragging down expands (opens) the sheet.
  topToBottom,

  /// The sheet slides from the bottom towards the top.
  ///
  /// The handle is at the top, and the content area is below it.
  /// Dragging up expands (opens) the sheet.
  bottomToTop,
}
