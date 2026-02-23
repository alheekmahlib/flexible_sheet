import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SheetDirection', () {
    test('has exactly two values', () {
      expect(SheetDirection.values.length, 2);
    });

    test('contains topToBottom', () {
      expect(SheetDirection.values, contains(SheetDirection.topToBottom));
    });

    test('contains bottomToTop', () {
      expect(SheetDirection.values, contains(SheetDirection.bottomToTop));
    });
  });

  group('SheetSnapBehavior', () {
    test('has exactly two values', () {
      expect(SheetSnapBehavior.values.length, 2);
    });

    test('contains snapToEdge', () {
      expect(SheetSnapBehavior.values, contains(SheetSnapBehavior.snapToEdge));
    });

    test('contains freePosition', () {
      expect(
          SheetSnapBehavior.values, contains(SheetSnapBehavior.freePosition));
    });
  });
}
