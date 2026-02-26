import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget in a MaterialApp for testing.
Widget buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

/// Creates a standard FlexibleSheet for testing.
Widget buildSheet({
  double maxHeight = 300,
  double minHeight = 50,
  double? initialHeight,
  SheetDirection direction = SheetDirection.topToBottom,
  SheetSnapBehavior snapBehavior = SheetSnapBehavior.snapToEdge,
  FlexibleSheetController? controller,
  bool isDraggable = true,
  ValueChanged<bool>? onStateChanged,
  ValueChanged<double>? onHeightChanged,
  SheetPhysics? physics,
  double? width,
  Alignment? alignment,
}) {
  return buildTestApp(
    FlexibleSheet(
      maxHeight: maxHeight,
      minHeight: minHeight,
      initialHeight: initialHeight,
      direction: direction,
      snapBehavior: snapBehavior,
      controller: controller,
      isDraggable: isDraggable,
      onStateChanged: onStateChanged,
      onHeightChanged: onHeightChanged,
      physics: physics,
      width: width,
      alignment: alignment,
      childBuilder: (height) => Container(
        key: const Key('sheet-content'),
        color: Colors.blue,
        child: Text('Height: ${height.round()}'),
      ),
      handleBuilder: (height) => Container(
        key: const Key('sheet-handle'),
        height: 48,
        color: Colors.grey,
      ),
    ),
  );
}

void main() {
  group('FlexibleSheet — rendering', () {
    testWidgets('renders with default parameters', (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      expect(find.byType(FlexibleSheet), findsOneWidget);
      expect(find.byKey(const Key('sheet-content')), findsOneWidget);
      expect(find.byKey(const Key('sheet-handle')), findsOneWidget);
    });

    testWidgets('displays initial height text', (tester) async {
      await tester.pumpWidget(buildSheet(minHeight: 50, initialHeight: 50));
      await tester.pumpAndSettle();

      expect(find.text('Height: 50'), findsOneWidget);
    });

    testWidgets('uses initialHeight when provided', (tester) async {
      await tester.pumpWidget(buildSheet(
        minHeight: 50,
        maxHeight: 300,
        initialHeight: 150,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Height: 150'), findsOneWidget);
    });

    testWidgets('uses minHeight when initialHeight is null', (tester) async {
      await tester.pumpWidget(buildSheet(minHeight: 80));
      await tester.pumpAndSettle();

      expect(find.text('Height: 80'), findsOneWidget);
    });
  });

  group('FlexibleSheet — direction', () {
    testWidgets('topToBottom: content before handle in Column', (tester) async {
      await tester.pumpWidget(buildSheet(
        direction: SheetDirection.topToBottom,
      ));
      await tester.pumpAndSettle();

      // The content should be above the handle
      final contentY =
          tester.getTopLeft(find.byKey(const Key('sheet-content'))).dy;
      final handleY =
          tester.getTopLeft(find.byKey(const Key('sheet-handle'))).dy;
      expect(contentY, lessThan(handleY));
    });

    testWidgets('bottomToTop: handle before content in Column', (tester) async {
      await tester.pumpWidget(buildSheet(
        direction: SheetDirection.bottomToTop,
      ));
      await tester.pumpAndSettle();

      // The handle should be above the content
      final contentY =
          tester.getTopLeft(find.byKey(const Key('sheet-content'))).dy;
      final handleY =
          tester.getTopLeft(find.byKey(const Key('sheet-handle'))).dy;
      expect(handleY, lessThan(contentY));
    });
  });

  group('FlexibleSheet — controller', () {
    testWidgets('controller.open() expands to maxHeight', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Height: 50'), findsOneWidget);

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Height: 300'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('controller.close() collapses to minHeight', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        maxHeight: 300,
        minHeight: 50,
      ));

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('Height: 300'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Height: 50'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('controller.toggle() toggles state', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Height: 50'), findsOneWidget);

      controller.toggle();
      await tester.pumpAndSettle();
      expect(find.text('Height: 300'), findsOneWidget);

      controller.toggle();
      await tester.pumpAndSettle();
      expect(find.text('Height: 50'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('controller.animateTo() animates to target height',
        (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();

      controller.animateTo(200);
      await tester.pumpAndSettle();

      expect(find.text('Height: 200'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('controller.animateTo() clamps to maxHeight', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();

      controller.animateTo(500);
      await tester.pumpAndSettle();

      expect(find.text('Height: 300'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('works without external controller', (tester) async {
      // Should not throw — creates an internal controller
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      expect(find.byType(FlexibleSheet), findsOneWidget);
    });
  });

  group('FlexibleSheet — callbacks', () {
    testWidgets('onStateChanged fires on open/close', (tester) async {
      final controller = FlexibleSheetController();
      final states = <bool>[];

      await tester.pumpWidget(buildSheet(
        controller: controller,
        onStateChanged: (s) => states.add(s),
      ));
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();

      controller.close();
      await tester.pumpAndSettle();

      expect(states, [true, false]);
      controller.dispose();
    });

    testWidgets('onHeightChanged fires during animation', (tester) async {
      final controller = FlexibleSheetController();
      final heights = <double>[];

      await tester.pumpWidget(buildSheet(
        controller: controller,
        onHeightChanged: (h) => heights.add(h),
      ));
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();

      // Should have received multiple height updates during animation
      expect(heights.length, greaterThan(1));
      // Last height should be very close to maxHeight (spring may not land exactly)
      expect(heights.last, closeTo(300, 0.1));
      controller.dispose();
    });
  });

  group('FlexibleSheet — isDraggable', () {
    testWidgets('isDraggable=false does not wrap handle in GestureDetector',
        (tester) async {
      await tester.pumpWidget(buildSheet(isDraggable: false));
      await tester.pumpAndSettle();

      // The handle should still render.
      expect(find.byKey(const Key('sheet-handle')), findsOneWidget);
      // But no GestureDetector wrapping the handle.
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('isDraggable=true wraps handle in GestureDetector',
        (tester) async {
      await tester.pumpWidget(buildSheet(isDraggable: true));
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('FlexibleSheet — drag interaction (topToBottom, snapToEdge)', () {
    testWidgets('drag down opens the sheet', (tester) async {
      await tester.pumpWidget(buildSheet(
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();

      // Find the handle and drag it down
      final handle = find.byKey(const Key('sheet-handle'));
      await tester.drag(handle, const Offset(0, 200));
      await tester.pumpAndSettle();

      // Should snap to maxHeight
      expect(find.text('Height: 300'), findsOneWidget);
    });

    testWidgets('small drag down then release snaps to closest edge',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        maxHeight: 300,
        minHeight: 50,
      ));
      await tester.pumpAndSettle();

      // Small drag — stays below midpoint (175), should snap to min
      final handle = find.byKey(const Key('sheet-handle'));
      await tester.drag(handle, const Offset(0, 50));
      await tester.pumpAndSettle();

      expect(find.text('Height: 50'), findsOneWidget);
    });
  });

  group('FlexibleSheet — drag interaction (bottomToTop, snapToEdge)', () {
    testWidgets('drag up opens the sheet (bottomToTop)', (tester) async {
      await tester.pumpWidget(buildSheet(
        maxHeight: 300,
        minHeight: 50,
        direction: SheetDirection.bottomToTop,
      ));
      await tester.pumpAndSettle();

      final handle = find.byKey(const Key('sheet-handle'));
      // Drag UP to open (bottomToTop inverts direction)
      await tester.drag(handle, const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('Height: 300'), findsOneWidget);
    });
  });

  group('FlexibleSheet — freePosition snap behavior', () {
    testWidgets('sheet stays at dragged position when freePosition',
        (tester) async {
      await tester.pumpWidget(buildSheet(
        maxHeight: 300,
        minHeight: 50,
        snapBehavior: SheetSnapBehavior.freePosition,
      ));
      await tester.pumpAndSettle();

      // The sheet starts at minHeight = 50
      expect(find.text('Height: 50'), findsOneWidget);

      final handle = find.byKey(const Key('sheet-handle'));

      // Perform a slow drag (fling with low velocity)
      // Manual gesture to control velocity
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Should stay roughly at 50 + 100 = 150
      expect(find.text('Height: 150'), findsOneWidget);
    });
  });

  group('FlexibleSheet — assertions', () {
    test('asserts minHeight >= 0', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 300,
          minHeight: -1,
          childBuilder: (_) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('asserts maxHeight >= minHeight', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 30,
          minHeight: 50,
          childBuilder: (_) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('asserts initialHeight within bounds', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 300,
          minHeight: 50,
          initialHeight: 400,
          childBuilder: (_) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('no assertion when parameters are valid', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 300,
          minHeight: 50,
          initialHeight: 150,
          childBuilder: (_) => const SizedBox(),
        ),
        returnsNormally,
      );
    });
  });

  group('FlexibleSheet — SheetPhysics', () {
    testWidgets('custom physics is used', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(
        controller: controller,
        physics: const SheetPhysics(
          defaultVelocity: 3000,
        ),
      ));
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Height: 300'), findsOneWidget);
      controller.dispose();
    });
  });

  group('FlexibleSheet — width', () {
    testWidgets('sheet takes full width when width is null', (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.pumpAndSettle();

      // No Align widget should be present within FlexibleSheet
      expect(
        find.descendant(
          of: find.byType(FlexibleSheet),
          matching: find.byType(Align),
        ),
        findsNothing,
      );
    });

    testWidgets('sheet is constrained to given width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 400,
              child: FlexibleSheet(
                maxHeight: 300,
                minHeight: 50,
                width: 200,
                childBuilder: (h) => Container(
                  key: const Key('content'),
                  color: Colors.blue,
                ),
                handleBuilder: (h) => const SizedBox(height: 48),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final content = find.byKey(const Key('content'));
      final size = tester.getSize(content);
      expect(size.width, 200);
    });

    testWidgets('sheet with width is centered by default', (tester) async {
      await tester.pumpWidget(buildSheet(width: 200));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(
        find.descendant(
          of: find.byType(FlexibleSheet),
          matching: find.byType(Align),
        ),
      );
      expect(align.alignment, Alignment.center);
    });
  });

  group('FlexibleSheet — alignment', () {
    testWidgets('sheet aligns to the left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 400,
              child: FlexibleSheet(
                maxHeight: 300,
                minHeight: 50,
                width: 200,
                alignment: Alignment.centerLeft,
                childBuilder: (h) => Container(
                  key: const Key('content'),
                  color: Colors.blue,
                ),
                handleBuilder: (h) => const SizedBox(height: 48),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final content = find.byKey(const Key('content'));
      final topLeft = tester.getTopLeft(content);
      // Should be at x = 0 (left edge of the 400px container)
      expect(topLeft.dx, 0);
    });

    testWidgets('sheet aligns to the right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 400,
              child: FlexibleSheet(
                maxHeight: 300,
                minHeight: 50,
                width: 200,
                alignment: Alignment.centerRight,
                childBuilder: (h) => Container(
                  key: const Key('content'),
                  color: Colors.blue,
                ),
                handleBuilder: (h) => const SizedBox(height: 48),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final content = find.byKey(const Key('content'));
      final topLeft = tester.getTopLeft(content);
      // Sheet is 200px wide, aligned right in 400px container → starts at 200
      expect(topLeft.dx, 200);
    });

    testWidgets('alignment without width wraps in Align', (tester) async {
      await tester.pumpWidget(buildSheet(
        alignment: Alignment.centerLeft,
      ));
      await tester.pumpAndSettle();

      final align = tester.widget<Align>(
        find.descendant(
          of: find.byType(FlexibleSheet),
          matching: find.byType(Align),
        ),
      );
      expect(align.alignment, Alignment.centerLeft);
    });
  });

  group('FlexibleSheet — width assertions', () {
    test('asserts width > 0', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 300,
          minHeight: 50,
          width: 0,
          childBuilder: (_) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('asserts negative width fails', () {
      expect(
        () => FlexibleSheet(
          maxHeight: 300,
          minHeight: 50,
          width: -10,
          childBuilder: (_) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('FlexibleSheet — handle visibility', () {
    testWidgets('handle is visible by default', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sheet-handle')), findsOneWidget);
      controller.dispose();
    });

    testWidgets('hideHandle() removes the handle', (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(controller: controller));
      await tester.pumpAndSettle();

      controller.hideHandle();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sheet-handle')), findsNothing);
      controller.dispose();
    });

    testWidgets('showHandle() restores the handle after hiding',
        (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(controller: controller));
      await tester.pumpAndSettle();

      controller.hideHandle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-handle')), findsNothing);

      controller.showHandle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-handle')), findsOneWidget);
      controller.dispose();
    });

    testWidgets(
        'showHandle() works after open() then hideHandle()',
        (tester) async {
      final controller = FlexibleSheetController();
      await tester.pumpWidget(buildSheet(controller: controller));
      await tester.pumpAndSettle();

      // Open the sheet first (sets lastAction to open)
      controller.open();
      await tester.pumpAndSettle();

      // Hide the handle
      controller.hideHandle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-handle')), findsNothing);

      // Show the handle — this should work regardless of previous actions
      controller.showHandle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-handle')), findsOneWidget);
      controller.dispose();
    });

    testWidgets(
        'hideHandle/showHandle does not replay previous action',
        (tester) async {
      final controller = FlexibleSheetController();
      final states = <bool>[];
      await tester.pumpWidget(buildSheet(
        controller: controller,
        onStateChanged: (s) => states.add(s),
      ));
      await tester.pumpAndSettle();

      controller.open();
      await tester.pumpAndSettle();
      states.clear(); // Clear the open notification

      // hideHandle should NOT fire onStateChanged again
      controller.hideHandle();
      await tester.pumpAndSettle();
      expect(states, isEmpty);

      // showHandle should NOT fire onStateChanged again
      controller.showHandle();
      await tester.pumpAndSettle();
      expect(states, isEmpty);

      controller.dispose();
    });
  });
}
