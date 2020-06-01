import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/GetStarted/index.dart';
import 'package:Medicall/screens/GetStarted/startVisit.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/StripeConnect/index.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/stripe_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.

class LandingPage extends StatelessWidget {
  const LandingPage({Key key, @required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<MedicallUser> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        try {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          final db = Provider.of<Database>(context, listen: false);
          StripeProvider _stripeProvider = Provider.of<StripeProvider>(context);

          if (userProvider.medicallUser != null) {
            _stripeProvider.setPublishableKey(stripeKey);
          }

          if (userProvider.medicallUser.phoneNumber == null &&
              userSnapshot.data.phoneNumber == null) {
            return PhoneAuthScreen.create(context, null);
          }

          if (userProvider.medicallUser != null) {
            if (userProvider.medicallUser.type == "provider" &&
                !userProvider.medicallUser.stripeConnectAuthorized) {
              return StripeConnect.create(context);
            } else {
              if (db.newConsult != null) {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return StartVisitScreen();
                  },
                ));
              } else {
                return DashboardScreen.create(context);
              }
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        } catch (e) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      } else {
        return GetStartedScreen();
      }
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
