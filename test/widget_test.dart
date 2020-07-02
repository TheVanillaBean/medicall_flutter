// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:Medicall/main.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Will main build', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final appleSignInAvailable = await AppleSignInAvailable.check();

    await tester.pumpWidget(MedicallApp(
      appleSignInAvailable: appleSignInAvailable,
      authServiceBuilder: (_) => Auth(),
      databaseBuilder: (_) => NonAuthFirestoreDB(),
      tempUserProvider: (_) => TempUserProvider(),
    ));
  });
}
