import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homiq_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomiqApp());

    // Basic verification that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
