import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.

class LandingPage extends StatelessWidget {
  final AsyncSnapshot<MedicallUser> userSnapshot;
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;
  final WidgetBuilder stripeConnectBuilder;
  final WidgetBuilder startVisitBuilder;

  const LandingPage({
    Key key,
    @required this.userSnapshot,
    this.nonSignedInBuilder,
    this.signedInBuilder,
    this.stripeConnectBuilder,
    this.startVisitBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        MedicallUser medicallUser = userSnapshot.data;
        if (medicallUser.type == "provider" &&
            !medicallUser.stripeConnectAuthorized) {
          return stripeConnectBuilder(context);
        } else {
          if (tempUserProvider.newConsult != null) {
            return startVisitBuilder(context);
          } else {
            return signedInBuilder(context);
          }
        }
      } else {
        return nonSignedInBuilder(context);
      }
    }
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
