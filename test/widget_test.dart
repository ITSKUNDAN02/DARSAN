import 'package:flutter_test/flutter_test.dart';
import 'package:darsan_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Home screen renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Where do you want to go?'), findsOneWidget);
    expect(find.text('Popular Destination'), findsOneWidget);
    expect(find.text('Explore Nepal again'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
