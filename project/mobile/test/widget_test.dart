// Basic smoke test: the app boots and lands on the Welcome screen
// (unauthenticated state) without throwing.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:auto_hub/main.dart';

void main() {
  testWidgets('App boots and shows the Welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AutoHubApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('AutoHub'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsOneWidget);
  });
}
