// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f_app/main.dart';
import 'package:f_app/screens/main_screen.dart'; // Import MainScreen
import 'package:f_app/core/theme/theme_provider.dart'; // Import ThemeProvider
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() {
  testWidgets('MainScreen loads and shows Home tab', (WidgetTester tester) async {
    // Mock SharedPreferences for ThemeProvider initialization
    SharedPreferences.setMockInitialValues({});
    final themeProvider = ThemeProvider();
    await themeProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(F1App(themeProvider: themeProvider));

    // Verify that the MainScreen is present.
    expect(find.byType(MainScreen), findsOneWidget);

    // Verify that the "Home" tab is initially selected and visible.
    // Note: This assumes the BottomNavigationBarItem for Home has the label 'Home'.
    // It also checks for the presence of the HomeScreen content if possible, 
    // or a key widget within HomeScreen.
    expect(find.widgetWithText(BottomNavigationBarItem, 'Home'), findsOneWidget);
    // expect(find.text('Home'), findsWidgets); // This might find multiple instances, be more specific

    // You could also verify the presence of a key widget from HomeScreen if you know one
    // For example, if HomeScreen has a Text widget with 'Welcome to F1 Hub':
    // expect(find.text('Welcome to F1 Hub'), findsOneWidget);

    // Example: Verify that the "Classifica" tab is present
    expect(find.widgetWithText(BottomNavigationBarItem, 'Classifica'), findsOneWidget);

    // Example: Tap the "Classifica" tab and verify navigation
    await tester.tap(find.widgetWithText(BottomNavigationBarItem, 'Classifica'));
    await tester.pumpAndSettle(); // pumpAndSettle to wait for animations/transitions

    // Verify that StandingsScreen is now active (or a key widget within it)
    // This depends on how StandingsScreen indicates its presence.
    // For example, if it has an AppBar with title 'Classifiche':
    expect(find.text('Classifiche'), findsOneWidget);
  });
}
