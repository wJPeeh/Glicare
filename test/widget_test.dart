import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glicare/main.dart';

void main() {
  testWidgets('App boots and renders the dev index', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GlicareApp()));
    await tester.pump();

    expect(find.text('Glicare • Dev Index'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
