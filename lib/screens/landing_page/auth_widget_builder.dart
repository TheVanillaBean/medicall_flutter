import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Used to create user-dependent objects that need to be accessible by all widgets.
/// This widgets should live above the [MaterialApp].
/// See [LandingPage], a descendant widget that consumes the snapshot generated by this builder.

class AuthWidgetBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<MedicallUser>) builder;
  final List<SingleChildWidget> Function(BuildContext, MedicallUser)
      userProvidersBuilder;

  const AuthWidgetBuilder({
    Key key,
    @required this.builder,
    this.userProvidersBuilder,
  }) : super(key: key);

  Future<void> updateDevTokens(MedicallUser user, NonAuthDatabase db) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token = await _firebaseMessaging.getToken();
    user.devTokens = [token];
    await db.setUser(user);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthBase>(context, listen: false);
    final fcm = Provider.of<FirebaseNotifications>(context, listen: false);
    final NonAuthDatabase nonAuthDatabase =
        Provider.of<NonAuthDatabase>(context, listen: false);
    return StreamBuilder<MedicallUser>(
      stream: authService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<MedicallUser> snapshot) {
        final MedicallUser user = snapshot.data;
        if (user != null) {
          fcm.initFirebaseNotifications();
          updateDevTokens(user, nonAuthDatabase);
          return MultiProvider(
            providers: userProvidersBuilder != null
                ? userProvidersBuilder(context, user)
                : [],
            child: builder(context, snapshot),
          );
        }
        return builder(context, snapshot);
      },
    );
  }
}
