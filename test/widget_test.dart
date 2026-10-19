import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyideas/app/app.dart';

void main() {
  testWidgets('App smoke test: loads splash screen and navigates to language selection', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MoneyIdeasApp(),
      ),
    );

    // Initial frame displays app branding
    expect(find.text('أفكار المال'), findsOneWidget);

    // Advance past the splash timer and settle navigation
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Now on language screen for new unauthenticated visitor
    expect(find.text('اختر لغة التطبيق'), findsWidgets);
  });
}
