import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
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

          print("Active: ${userSnapshot.connectionState} ");

          if (userProvider.medicallUser == null) {
            print('In-Progress');
          } else {
            print("Active: ${userProvider.medicallUser.uid}");
          }

          if (userProvider.medicallUser.phoneNumber == null) {
            return PhoneAuthScreen.create(context);
          }

          return userProvider.medicallUser != null
              ? HistoryScreen()
              : Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
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

//    final AuthBase auth = Provider.of<AuthBase>(context);
//    final FirestoreDatabase database = Provider.of<Database>(context);
//
//    return StreamBuilder<MedicallUser>(
//      stream: auth.onAuthStateChanged,
//      builder: (context, snapshot) {
//        if (snapshot.connectionState == ConnectionState.active) {
//          if (snapshot.hasData) {
//            MedicallUser user = snapshot.data;
//            if (user == null) {
//              return LoginPage.create(context);
//            } else if (user.phoneNumber == null) {
//              return PhoneAuthScreen.create(context);
//            }
//          }else{
//            return LoginPage.create(context);
//          }
//
//          return FutureBuilder<MedicallUser>(
//              future: auth.currentMedicallUser(),
//              builder: (context, snapshot) {
//                if (snapshot.connectionState == ConnectionState.done) {
//                  if (snapshot.hasData) {
//                    final MedicallUser user = snapshot.data;
//                    auth.medicallUser = user;
//                    database.uid = user.uid;
//                    return HistoryScreen();
//                  } else {
//                    return LoginPage.create(context);
//                  }
//
////                  return Provider<MedicallUser>.value(
////                    value: user,
////                    child: Provider<Database>(
////                      create: (_) => FirestoreDatabase(uid: user.uid),
////                      child: HistoryScreen(),
////                    ),
////                  );
//                }
//                if (snapshot.connectionState == ConnectionState.waiting) {
//                  return Container(
//                    color: Colors.white,
//                    child: Center(
//                      heightFactor: 35,
//                      child: CircularProgressIndicator(),
//                    ),
//                  );
//                } else {
//                  return Scaffold(
//                    body: Center(
//                      child: Text('There was an error retrieving user data.'),
//                    ),
//                    backgroundColor: Colors.white,
//                  );
//                }
//              });
//        } else {
//          return Scaffold(
//            body: Center(
//              child: CircularProgressIndicator(),
//            ),
//            backgroundColor: Colors.lightBlueAccent,
//          );
//        }
//      },
//    );
  }
}
