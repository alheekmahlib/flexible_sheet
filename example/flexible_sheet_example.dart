import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ExampleTabs(),
    );
  }
}

/// Tab view showing both directions and snap behaviors.
class ExampleTabs extends StatelessWidget {
  const ExampleTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flexible Sheet Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Top ↓'),
              Tab(text: 'Bottom ↑'),
              Tab(text: 'Free'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            TopToBottomExample(),
            BottomToTopExample(),
            FreePositionExample(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top-to-bottom sheet (snap to edge)
// ---------------------------------------------------------------------------

class TopToBottomExample extends StatefulWidget {
  const TopToBottomExample({super.key});

  @override
  State<TopToBottomExample> createState() => _TopToBottomExampleState();
}

class _TopToBottomExampleState extends State<TopToBottomExample> {
  final controller = FlexibleSheetController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return FlexibleSheet(
              maxHeight: constraints.maxHeight - 48,
              minHeight: 50,
              direction: SheetDirection.topToBottom,
              snapBehavior: SheetSnapBehavior.snapToEdge,
              controller: controller,
              childBuilder: (height) => SheetBody(currentHeight: height),
              handleBuilder: (height) => const DragHandle(),
              onStateChanged: (open) => debugPrint('isOpen: $open'),
              // onHeightChanged: (h) => debugPrint('height: ${h.round()}'),
            );
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: controller.toggle,
            child: const Text('Toggle'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom-to-top sheet (snap to edge)
// ---------------------------------------------------------------------------

class BottomToTopExample extends StatefulWidget {
  const BottomToTopExample({super.key});

  @override
  State<BottomToTopExample> createState() => _BottomToTopExampleState();
}

class _BottomToTopExampleState extends State<BottomToTopExample> {
  final controller = FlexibleSheetController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSheet(
                  maxHeight: 500,
                  minHeight: 50,
                  direction: SheetDirection.bottomToTop,
                  snapBehavior: SheetSnapBehavior.snapToEdge,
                  controller: controller,
                  childBuilder: (height) => SheetBody(
                    currentHeight: height,
                    color: Colors.teal.shade100,
                  ),
                  handleBuilder: (height) => const DragHandle(isTop: true),
                  onStateChanged: (open) => debugPrint('isOpen: $open'),
                );
              },
            ),
          ],
        ),
        Center(
          child: ElevatedButton(
            onPressed: controller.toggle,
            child: const Text('Toggle'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Free position (no snapping)
// ---------------------------------------------------------------------------

class FreePositionExample extends StatefulWidget {
  const FreePositionExample({super.key});

  @override
  State<FreePositionExample> createState() => _FreePositionExampleState();
}

class _FreePositionExampleState extends State<FreePositionExample> {
  final controller = FlexibleSheetController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FlexibleSheet(
          maxHeight: constraints.maxHeight - 48,
          minHeight: 50,
          direction: SheetDirection.topToBottom,
          snapBehavior: SheetSnapBehavior.freePosition,
          controller: controller,
          childBuilder: (height) => SheetBody(
            currentHeight: height,
            color: Colors.deepPurple.shade100,
          ),
          handleBuilder: (height) => const DragHandle(),
          onStateChanged: (open) => debugPrint('isOpen: $open'),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared UI components
// ---------------------------------------------------------------------------

class SheetBody extends StatelessWidget {
  const SheetBody({
    super.key,
    required this.currentHeight,
    this.color,
  });

  final double currentHeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.amber,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text('height: ${currentHeight.round()}'),
        ),
      ),
    );
  }
}

class DragHandle extends StatelessWidget {
  const DragHandle({super.key, this.isTop = false});

  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kMinInteractiveDimension,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(24) : Radius.zero,
          bottom: isTop ? Radius.zero : const Radius.circular(24),
        ),
      ),
      child: Center(
        child: Container(
          height: 4,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
    );
  }
}
