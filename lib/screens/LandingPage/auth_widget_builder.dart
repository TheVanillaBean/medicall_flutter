import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Used to create user-dependent objects that need to be accessible by all widgets.
/// This widgets should live above the [MaterialApp].
/// See [AuthWidget], a descendant widget that consumes the snapshot generated by this builder.

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<MedicallUser>) builder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthBase>(context, listen: false);
    print("");

    return StreamBuilder<MedicallUser>(
      stream: authService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<MedicallUser> snapshot) {
        final MedicallUser user = snapshot.data;
        if (user != null) {
          print("User not null ${snapshot.connectionState}");

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (BuildContext context) {
                  return UserProvider(uid: user.uid);
                },
              ),
              Provider<Database>(
                create: (_) => FirestoreDatabase(),
              ),
              // NOTE: Any other user-bound providers here can be added here
            ],
            child: Consumer<UserProvider>(
              builder:
                  (BuildContext context, UserProvider value, Widget child) {
                return builder(context, snapshot);
              },
            ),
          );
        }

        print("Null User ${snapshot.connectionState}");
        return builder(context, snapshot);
      },
    );
  }
}
