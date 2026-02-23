/// Defines how the sheet behaves when the user releases a drag gesture.
enum SheetSnapBehavior {
  /// The sheet snaps to the nearest edge (fully open or fully closed)
  /// based on the drag velocity or current position.
  ///
  /// This is the default behavior. If the user drags fast enough in one
  /// direction, the sheet will animate to that edge. If the drag is slow,
  /// the sheet snaps to the closest edge based on whether the current
  /// height is above or below the midpoint.
  snapToEdge,

  /// The sheet stays at the position where the user released it.
  ///
  /// No automatic snapping occurs. The sheet remains at the exact height
  /// where the drag gesture ended.
  freePosition,
}
