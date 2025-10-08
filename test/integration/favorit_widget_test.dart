import 'package:uuid/uuid.dart';
import 'package:application2/src/component/features/FavoritItemCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:application2/src/component/profile/Favorit.dart';

class FavoritWidgetTest {
  static void runTests() {
    TestWidgetsFlutterBinding.ensureInitialized();

    group('Favorit Widget', () {
      testWidgets('shows empty state when no favorites', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          'favorites': []
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Favorit(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Keine Favoriten gefunden.'), findsOneWidget);
      });

      testWidgets('shows loading then empty', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({
          'favorites': []
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Favorit(),
          ),
        );
        // Should show loading indicator first
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text('Keine Favoriten gefunden.'), findsOneWidget);
      });

      testWidgets('shows 3 favorite items when 3 uuids are added', (WidgetTester tester) async {
        var uuidGen = Uuid();
        final uuidList = [uuidGen.v4(), uuidGen.v4(), uuidGen.v4()];
        SharedPreferences.setMockInitialValues({
          'favorites': uuidList
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Favorit(),
          ),
        );
        await tester.pumpAndSettle();
        // Should show 3 FavoritItemCard widgets
        expect(find.byType(FavoritItemCard), findsNWidgets(3));
      });
    });
  }

  // Convenience function to run all tests
  static void run() => runTests();
}

void main() {
  FavoritWidgetTest.run();
}

