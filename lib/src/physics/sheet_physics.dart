import 'package:flutter/physics.dart';

/// Configures the spring physics used for sheet animations.
///
/// Provides sensible defaults that produce a smooth, natural-feeling
/// spring animation. You can customize the [spring] description and
/// [defaultVelocity] to tune the animation feel.
///
/// Example:
/// ```dart
/// FlexibleSheet(
///   physics: SheetPhysics(
///     spring: SpringDescription(mass: 1, stiffness: 600, damping: 35),
///     defaultVelocity: 1500,
///   ),
///   // ...
/// )
/// ```
class SheetPhysics {
  /// Creates sheet physics with the given spring and velocity configuration.
  const SheetPhysics({
    this.spring = const SpringDescription(
      mass: 1,
      stiffness: 500,
      damping: 30,
    ),
    this.defaultVelocity = 1500,
  }) : assert(defaultVelocity > 0, 'defaultVelocity must be positive');

  /// The spring description that controls the animation curve.
  ///
  /// Defaults to `SpringDescription(mass: 1, stiffness: 500, damping: 30)`
  /// which produces a slightly underdamped (bouncy) but fast spring.
  final SpringDescription spring;

  /// The default velocity (in pixels per second) used when the sheet is
  /// opened or closed programmatically (e.g., via the controller).
  ///
  /// A higher value results in a faster animation.
  /// Defaults to `1500`.
  final double defaultVelocity;

  /// Default physics with sensible values.
  static const SheetPhysics defaultPhysics = SheetPhysics();
}
