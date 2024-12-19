import 'package:cloud_firestore/cloud_firestore.dart';
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
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // Verify success (adjust this to your success condition, e.g., navigating to '/home')
    // expect(find.ty("Hedieaty"), findsOneWidget);
    print(find.byType(HomeScreen).evaluate().toList());


    expect(find.byWidgetPredicate(
            (widget) => widget is HomeScreen && widget.onThemeToggle is ValueChanged<ThemeMode>
    ), findsOneWidget);


    print("Navigated to Home Screen");

    // Simulate creating a new event
    final createEventButton = find.text("Create Event");
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();
    print("Navigated to Create Event page");
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Fill out event details
    final nameField = find.widgetWithText(TextField, "Event Name");
    final categoryField = find.widgetWithText(TextField, "Category");
   // final statusField = find.widgetWithText(TextField, "Status");
    final dateField = find.widgetWithText(TextField, "Date");
    final locationField = find.widgetWithText(TextField, "Location");
    final descriptionField = find.widgetWithText(TextField, "Description");

    await tester.enterText(nameField, "Test Event");
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.enterText(categoryField, "Birthday");
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // await tester.enterText(statusField, "Upcoming");
    // await tester.pumpAndSettle(const Duration(seconds: 1));

    // Simulate selecting a date
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    final okButton = find.text("OK");
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    // print("Entered date: ${dateField.toString()}");

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.enterText(locationField, "Test Location");
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.enterText(descriptionField, "This is a test event.");
    print("Filled out event details");

    // Save the event
    final saveButton = find.text("Add Event");
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    print("Event saved and navigated back to Home");

    // Verify event is added in Firestore
    final events = await FirebaseFirestore.instance.collection('event').get();
    expect(events.docs.any((doc) => doc['name'] == "Test Event"), true);
    print("Event verified in Firestore");
    await tester.pumpAndSettle(const Duration(seconds: 6));
    // Ensure user is back on the Home page
    expect(
        find.byWidgetPredicate(
                (widget) => widget is HomeScreen && widget.onThemeToggle is ValueChanged<ThemeMode>),
        findsOneWidget);
    print("Returned to Home Screen after creating event");
  });





}
