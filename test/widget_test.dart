import 'package:flutter_test/flutter_test.dart';
import 'package:dhanda_app/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DhandaApp());
    expect(find.byType(DhandaApp), findsOneWidget);
  });
}
