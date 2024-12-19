import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/screens/homeScreen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Login flow integration test", (WidgetTester tester) async {
    // Initialize Firebase
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Launch the app
    await tester.pumpWidget(const MyApp());

    // Wait for the initial page to appear
    await tester.pumpAndSettle();
    print("open the app");

    // Simulate pressing the "Get Started" button
   // await tester.pump(const Duration(seconds: 6));

    final getStartedButton = find.text("Get started");
    await tester.tap(getStartedButton);
    print("press get started");

    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    // Find widgets
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).at(1);
    final loginButton = find.text("Login");

    // Input email and password
    await tester.enterText(emailField, "farahzayed@email.com");
    await tester.enterText(passwordField, "123456");
    print("enter the credentials");

    // Tap the login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    print("pressed login");

    // Wait for the app to process
    await tester.pumpAndSettle();

    // Simulate time passing (e.g., 6 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 20));

    // Verify success (adjust this to your success condition, e.g., navigating to '/home')
    // expect(find.ty("Hedieaty"), findsOneWidget);
    print(find.byType(HomeScreen).evaluate().toList());


    expect(find.byWidgetPredicate(
            (widget) => widget is HomeScreen && widget.onThemeToggle is ValueChanged<ThemeMode>
    ), findsOneWidget);
  });

}
