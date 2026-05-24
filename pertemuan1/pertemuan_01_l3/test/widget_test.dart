// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pertemuan_01_l3/main.dart' as app;

void main() {
  testWidgets('Latihan 3 Row Column Test', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();

    expect(find.text('Hello Flutter!'), findsOneWidget);
    expect(find.text('Hallo namaku Murod Fikri F'), findsOneWidget);

    expect(find.byIcon(Icons.star), findsNWidgets(3));

    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
