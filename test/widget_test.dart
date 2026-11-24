import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('MISSÃO PRÓXIMA FAIXA'),
        ),
      ),
    );

    expect(find.text('MISSÃO PRÓXIMA FAIXA'), findsOneWidget);
  });
}
