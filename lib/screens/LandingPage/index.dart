import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.

class LandingPage extends StatelessWidget {
  final AsyncSnapshot<User> userSnapshot;
  final WidgetBuilder nonSignedInBuilder;
  final WidgetBuilder signedInBuilder;
  final WidgetBuilder startVisitBuilder;
  final WidgetBuilder providerPhotoBuilder;

  const LandingPage({
    Key key,
    @required this.userSnapshot,
    this.nonSignedInBuilder,
    this.signedInBuilder,
    this.startVisitBuilder,
    this.providerPhotoBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        if (tempUserProvider.consult != null) {
          return startVisitBuilder(context);
        } else if (userSnapshot.data.type == USER_TYPE.PROVIDER &&
            userSnapshot.data.profilePic.length == 0) {
          return providerPhotoBuilder(context);
        } else {
          return signedInBuilder(context);
        }
      } else {
        return nonSignedInBuilder(context);
      }
    }
    return Scaffold(
      body: const CircularProgressIndicator(),
    );
  }
}
