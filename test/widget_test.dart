// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:application2/src/security/authentication/AuthRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:application2/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final auth = _FakeAuthRepository();
    await tester.pumpWidget(MyApp(auth: auth));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

}

// Simple fake AuthRepository for testing
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}
  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {}
  @override
  Future<void> signOut() async {}
  @override
  Stream<User?> authStateChanges() => Stream.value(null);
}
