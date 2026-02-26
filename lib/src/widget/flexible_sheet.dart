import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../controller/flexible_sheet_controller.dart';
import '../enums/sheet_direction.dart';
import '../enums/sheet_snap_behavior.dart';
import '../physics/sheet_physics.dart';

/// A persistent, draggable sheet widget that can slide from the top or bottom.
///
/// The sheet supports two directions ([SheetDirection.topToBottom] and
/// [SheetDirection.bottomToTop]) and two snap behaviors
/// ([SheetSnapBehavior.snapToEdge] and [SheetSnapBehavior.freePosition]).
///
/// Use a [FlexibleSheetController] to programmatically open, close, toggle,
/// or animate the sheet to a specific height.
///
/// Example:
/// ```dart
/// final controller = FlexibleSheetController();
///
/// FlexibleSheet(
///   maxHeight: 500,
///   minHeight: 50,
///   direction: SheetDirection.topToBottom,
///   snapBehavior: SheetSnapBehavior.snapToEdge,
///   controller: controller,
///   childBuilder: (height) => MyContent(height: height),
///   handleBuilder: (height) => MyHandle(),
/// )
/// ```
class FlexibleSheet extends StatefulWidget {
  /// Creates a [FlexibleSheet].
  const FlexibleSheet({
    super.key,
    required this.maxHeight,
    required this.minHeight,
    required this.childBuilder,
    this.handleBuilder,
    this.controller,
    this.direction = SheetDirection.topToBottom,
    this.snapBehavior = SheetSnapBehavior.snapToEdge,
    this.physics,
    this.initialHeight,
    this.width,
    this.alignment,
    this.isDraggable = true,
    this.onStateChanged,
    this.onHeightChanged,
    this.clipBehavior = Clip.hardEdge,
  })  : assert(minHeight >= 0, 'minHeight must be non-negative'),
        assert(
          maxHeight >= minHeight,
          'maxHeight ($maxHeight) must be >= minHeight ($minHeight)',
        ),
        assert(
          initialHeight == null ||
              (initialHeight >= minHeight && initialHeight <= maxHeight),
          'initialHeight ($initialHeight) must be between '
          'minHeight ($minHeight) and maxHeight ($maxHeight)',
        ),
        assert(
          width == null || width > 0,
          'width ($width) must be positive',
        );

  /// The direction the sheet slides.
  ///
  /// - [SheetDirection.topToBottom]: content on top, handle below (default).
  /// - [SheetDirection.bottomToTop]: handle on top, content below.
  final SheetDirection direction;

  /// How the sheet behaves when a drag gesture ends.
  ///
  /// - [SheetSnapBehavior.snapToEdge]: snaps to fully open or closed (default).
  /// - [SheetSnapBehavior.freePosition]: stays where the user released it.
  final SheetSnapBehavior snapBehavior;

  /// Optional physics configuration for the spring animation.
  ///
  /// If null, [SheetPhysics.defaultPhysics] is used.
  final SheetPhysics? physics;

  /// An optional controller, used to open, close, toggle, or animate the sheet.
  final FlexibleSheetController? controller;

  /// The maximum height the sheet can expand to.
  final double maxHeight;

  /// The minimum height the sheet collapses to.
  final double minHeight;

  /// The starting height of the sheet. Defaults to [minHeight].
  final double? initialHeight;

  /// Builds the sheet's main content area.
  ///
  /// The current height is passed as an argument so the content can
  /// adapt to size changes.
  final Widget Function(double height) childBuilder;

  /// Builds the drag handle widget.
  ///
  /// The current height is passed as an argument. If null and
  /// [isDraggable] is true, a zero-size [SizedBox] is used (you should
  /// provide a visible handle for a good UX).
  final Widget Function(double height)? handleBuilder;

  /// Whether the sheet can be dragged via the handle. Defaults to `true`.
  final bool isDraggable;

  /// Called when the sheet's open/close state changes.
  ///
  /// `true` means the sheet just opened, `false` means it just closed.
  final ValueChanged<bool>? onStateChanged;

  /// Called whenever the sheet height changes (during drag or animation).
  final ValueChanged<double>? onHeightChanged;

  /// The width of the sheet.
  ///
  /// If null, the sheet takes the full available width from its parent.
  /// If provided, the sheet will be constrained to this width and
  /// positioned according to [alignment].
  final double? width;

  /// The horizontal alignment of the sheet when [width] is set.
  ///
  /// Use [Alignment.center], [Alignment.centerLeft], [Alignment.centerRight],
  /// etc. Only the horizontal component is used.
  ///
  /// Defaults to [Alignment.center] when [width] is provided.
  /// Has no effect when [width] is null (the sheet fills the parent width).
  final Alignment? alignment;

  /// The clip behavior for the sheet content area. Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  State<FlexibleSheet> createState() => _FlexibleSheetState();
}

class _FlexibleSheetState extends State<FlexibleSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<double> _anim = const AlwaysStoppedAnimation(0);
  late FlexibleSheetController _controller;
  bool _ownsController = false;

  late double _currentHeight;

  SheetPhysics get _physics => widget.physics ?? SheetPhysics.defaultPhysics;

  @override
  void initState() {
    super.initState();

    _currentHeight = widget.initialHeight ?? widget.minHeight;

    _initController();

    _animController = AnimationController(vsync: this)
      ..addListener(_onAnimationTick);
  }

  @override
  void didUpdateWidget(covariant FlexibleSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (widget.controller != oldWidget.controller) {
      _disposeController();
      _initController();
    }

    // Clamp current height if bounds changed
    if (widget.minHeight != oldWidget.minHeight ||
        widget.maxHeight != oldWidget.maxHeight) {
      final clamped = _currentHeight.clamp(widget.minHeight, widget.maxHeight);
      if (clamped != _currentHeight) {
        _setHeight(clamped);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _disposeController();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Controller management
  // ---------------------------------------------------------------------------

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = FlexibleSheetController();
      _ownsController = true;
    }
    _controller.updateHeight(_currentHeight);
    _controller.addListener(_onControllerChanged);
  }

  void _disposeController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Controller listener
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    switch (_controller.lastAction) {
      case SheetAction.open:
        _animateToHeight(widget.maxHeight);
        widget.onStateChanged?.call(true);
      case SheetAction.close:
        _animateToHeight(widget.minHeight);
        widget.onStateChanged?.call(false);
      case SheetAction.animateTo:
        final target = (_controller.targetHeight ?? _currentHeight)
            .clamp(widget.minHeight, widget.maxHeight);
        _animateToHeight(target);
      case null:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  void _onAnimationTick() {
    _setHeight(_anim.value);
  }

  void _setHeight(double newHeight) {
    final clamped = newHeight.clamp(widget.minHeight, widget.maxHeight);
    if (clamped == _currentHeight) return;

    setState(() {
      _currentHeight = clamped;
    });
    _controller.updateHeight(_currentHeight);
    widget.onHeightChanged?.call(_currentHeight);
  }

  Future<void> _animateToHeight(
    double targetHeight, {
    double? velocity,
  }) async {
    final effectiveVelocity = velocity ?? _physics.defaultVelocity;

    _anim = _animController.drive(
      Tween<double>(begin: _currentHeight, end: targetHeight),
    );

    final unitVelocity = effectiveVelocity /
        (widget.maxHeight - widget.minHeight).clamp(1, double.infinity);

    final simulation = SpringSimulation(
      _physics.spring,
      0,
      1,
      targetHeight > _currentHeight ? unitVelocity : -unitVelocity,
    );

    await _animController.animateWith(simulation);
  }

  // ---------------------------------------------------------------------------
  // Drag logic
  // ---------------------------------------------------------------------------

  void _onDragStart(DragStartDetails details) {
    _animController.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = widget.direction == SheetDirection.topToBottom
        ? details.delta.dy
        : -details.delta.dy;
    _setHeight(_currentHeight + delta);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocityDy = details.velocity.pixelsPerSecond.dy;

    // For bottomToTop, invert the velocity direction
    final effectiveVelocity = widget.direction == SheetDirection.topToBottom
        ? velocityDy
        : -velocityDy;

    switch (widget.snapBehavior) {
      case SheetSnapBehavior.snapToEdge:
        _handleSnapToEdge(effectiveVelocity);
      case SheetSnapBehavior.freePosition:
        // Stay at the current position — no animation needed.
        _updateOpenState();
    }
  }

  void _handleSnapToEdge(double velocity) {
    final velocityThreshold = _physics.defaultVelocity / 2;
    final midpoint = (widget.maxHeight + widget.minHeight) / 2;

    if (velocity.abs() > velocityThreshold) {
      // Fast drag — snap based on direction
      if (velocity > 0) {
        _open(velocity: velocity.abs());
      } else {
        _close(velocity: velocity.abs());
      }
    } else {
      // Slow drag — snap to closest edge
      if (_currentHeight > midpoint) {
        _open();
      } else {
        _close();
      }
    }
  }

  Future<void> _open({double? velocity}) async {
    _controller.updateOpenState(true);
    widget.onStateChanged?.call(true);
    await _animateToHeight(widget.maxHeight, velocity: velocity);
  }

  Future<void> _close({double? velocity}) async {
    _controller.updateOpenState(false);
    widget.onStateChanged?.call(false);
    await _animateToHeight(widget.minHeight, velocity: velocity);
  }

  void _updateOpenState() {
    final midpoint = (widget.maxHeight + widget.minHeight) / 2;
    final isNowOpen = _currentHeight > midpoint;
    if (isNowOpen != _controller.isOpen) {
      _controller.updateOpenState(isNowOpen);
      widget.onStateChanged?.call(isNowOpen);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final content = ClipRect(
      clipBehavior: widget.clipBehavior,
      child: SizedBox(
        height: _currentHeight,
        child: RepaintBoundary(
          child: widget.childBuilder(_currentHeight),
        ),
      ),
    );

    final handle = _buildHandle();

    final children = widget.direction == SheetDirection.topToBottom
        ? [content, handle]
        : [handle, content];

    Widget sheet = Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    // Apply width constraint
    if (widget.width != null) {
      sheet = SizedBox(
        width: widget.width,
        child: sheet,
      );
    }

    // Apply alignment
    if (widget.width != null || widget.alignment != null) {
      sheet = Align(
        alignment: widget.alignment ?? Alignment.center,
        child: sheet,
      );
    }

    return sheet;
  }

  Widget _buildHandle() {
    final handleChild =
        widget.handleBuilder?.call(_currentHeight) ?? const SizedBox.shrink();

    if (!widget.isDraggable) return handleChild;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: handleChild,
    );
  }
}
