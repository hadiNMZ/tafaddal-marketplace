import 'package:flutter_test/flutter_test.dart';
import 'package:tafaddal_marketplace/main.dart';

void main() {
  testWidgets('TafaddalApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TafaddalApp());

    // Verify that 'تفضّل' brand logo is displayed.
    expect(find.text('تفضّل'), findsWidgets);
  });
}
