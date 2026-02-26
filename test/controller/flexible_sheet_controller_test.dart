import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlexibleSheetController', () {
    late FlexibleSheetController controller;

    setUp(() {
      controller = FlexibleSheetController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is closed', () {
      expect(controller.isOpen, false);
      expect(controller.currentHeight, 0);
    });

    test('initialIsOpen sets initial state to open', () {
      final c = FlexibleSheetController(initialIsOpen: true);
      expect(c.isOpen, true);
      c.dispose();
    });

    test('open() sets isOpen to true and notifies listeners', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.open();

      expect(controller.isOpen, true);
      expect(notified, true);
    });

    test('open() does not notify if already open', () {
      controller.open();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.open();
      expect(notified, false);
    });

    test('close() sets isOpen to false and notifies listeners', () {
      controller.open();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.close();

      expect(controller.isOpen, false);
      expect(notified, true);
    });

    test('close() does not notify if already closed and last action was close',
        () {
      // First close explicitly so lastAction == close
      controller.close();

      var notified = false;
      controller.addListener(() => notified = true);

      // Second close should be a no-op
      controller.close();
      expect(notified, false);
    });

    test('toggle() opens when closed and closes when open', () {
      expect(controller.isOpen, false);

      controller.toggle();
      expect(controller.isOpen, true);

      controller.toggle();
      expect(controller.isOpen, false);
    });

    test('animateTo() sets targetHeight and notifies', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.animateTo(250);

      expect(controller.targetHeight, 250);
      expect(notified, true);
    });

    test('isHandleVisible defaults to true', () {
      expect(controller.isHandleVisible, true);
    });

    test('hideHandle() sets isHandleVisible to false and notifies', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.hideHandle();

      expect(controller.isHandleVisible, false);
      expect(notified, true);
    });

    test('hideHandle() does not notify if already hidden', () {
      controller.hideHandle();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.hideHandle();
      expect(notified, false);
    });

    test('showHandle() sets isHandleVisible to true and notifies', () {
      controller.hideHandle();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.showHandle();

      expect(controller.isHandleVisible, true);
      expect(notified, true);
    });

    test('showHandle() does not notify if already visible', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.showHandle();
      expect(notified, false);
    });
  });
}
