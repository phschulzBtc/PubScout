import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pubscout/app.dart';

void main() {
  testWidgets('PubScout app renders map screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PubScoutApp()),
    );

    expect(find.text('PubScout'), findsOneWidget);
  });
}
