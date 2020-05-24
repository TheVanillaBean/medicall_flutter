import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Dashboard/dashboard.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/screens/StripeConnect/index.dart';
import 'package:Medicall/secrets.dart';
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
    print("Connection State: ${userSnapshot.connectionState} ");
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        try {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          MyStripeProvider _stripeProvider =
              Provider.of<MyStripeProvider>(context);

          if (userProvider.medicallUser == null) {
            print('In-Progress');
          } else {
            print("Active: ${userProvider.medicallUser.uid}");
            //setting stripe key once user is logged in
            _stripeProvider.setPublishableKey(stripeKey);
            print("Active: stripe key set");
          }

          if (userProvider.medicallUser.phoneNumber == null &&
              userSnapshot.data.phoneNumber == null) {
            return PhoneAuthScreen.create(context);
          }

          if (userProvider.medicallUser != null) {
            if (userProvider.medicallUser.type == "provider" &&
                !userProvider.medicallUser.stripeConnectAuthorized) {
              return StripeConnect.create(context);
            } else {
              return DashboardScreen.create(context);
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
        return LoginPage.create(context);
      }
    }
    print("Waiting: ${userSnapshot.connectionState}");

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
