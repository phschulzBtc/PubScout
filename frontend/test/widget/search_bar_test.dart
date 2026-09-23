import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pubscout/widgets/search_bar_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({
    void Function(double, double, String)? onSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SearchBarWidget(
          onLocationSelected: onSelected ?? (_, _, _) {},
        ),
      ),
    );
  }

  testWidgets('renders search field with hint text', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Ort oder Adresse suchen...'), findsOneWidget);
  });

  testWidgets('shows clear button when text entered', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Berlin');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('clear button removes text', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Berlin');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '');
  });

  testWidgets('has search icon', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
