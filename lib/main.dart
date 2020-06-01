import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/LandingPage/auth_widget_builder.dart';
import 'package:Medicall/screens/LandingPage/index.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/theme.dart';
import 'package:Medicall/util/apple_sign_in_available.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(MedicallApp(
    appleSignInAvailable: appleSignInAvailable,
    authServiceBuilder: (_) => Auth(),
    databaseBuilder: (_, uid) => FirestoreDatabase(),
  ));
}

class MedicallApp extends StatelessWidget {
  final AppleSignInAvailable appleSignInAvailable;
  final AuthBase Function(BuildContext context) authServiceBuilder;
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  const MedicallApp(
      {Key key,
      this.appleSignInAvailable,
      this.authServiceBuilder,
      this.databaseBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppleSignInAvailable>.value(
          value: appleSignInAvailable,
        ),
        Provider<AuthBase>(
          create: authServiceBuilder,
        ),
        Provider<ExtImageProvider>(
          create: (_) => ExtendedImageProvider(),
        ),
      ],
      child: AuthWidgetBuilder(
        builder: (context, userSnapshot) {
          return MaterialApp(
            title: 'Medicall',
            debugShowCheckedModeBanner: false,
            theme: myTheme,
            home: LandingPage(userSnapshot: userSnapshot),
            onGenerateRoute: Router.onGenerateRoute,
          );
        },
      ),
    );
  }
}
