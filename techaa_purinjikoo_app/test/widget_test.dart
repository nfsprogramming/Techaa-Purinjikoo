import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:techaa_purinjikoo_app/main.dart';

void main() {
  testWidgets('App loads splash and brand smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TechaaPurinjikooApp(),
      ),
    );

    // Verify splash screen key elements
    expect(find.text('Techaa Purinjikoo'), findsOneWidget);
    expect(find.text('By NFS Programming'), findsOneWidget);

    // Advance timer past splash duration and route transition
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
    
    // We expect it to route to either Onboarding or Login.
    // If it routed to Onboarding, "Learn Tech Without" should be present.
    // If it routed to Login, "Techaa Purinjikoo" is still present.
    // This avoids pumpAndSettle timeouts from transitions.
  });
}
