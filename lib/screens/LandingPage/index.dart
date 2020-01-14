import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/screens/Login/index.dart';
import 'package:Medicall/screens/PhoneAuth/index.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    final FirestoreDatabase database = Provider.of<Database>(context);

    return StreamBuilder<MedicallUser>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          MedicallUser user = snapshot.data;
          if (user == null) {
            return LoginPage.create(context);
          } else if (user.phoneNumber == null) {
            return AuthScreen.create(context);
          }
          return FutureBuilder<MedicallUser>(
              future: auth.currentMedicallUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final MedicallUser user = snapshot.data;
                  auth.medicallUser = user;
                  database.uid = user.uid;
                  return HistoryScreen();

//                  return Provider<MedicallUser>.value(
//                    value: user,
//                    child: Provider<Database>(
//                      create: (_) => FirestoreDatabase(uid: user.uid),
//                      child: HistoryScreen(),
//                    ),
//                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      heightFactor: 35,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Scaffold(
                    body: Center(
                      child: Text('There was an error retrieving user data.'),
                    ),
                    backgroundColor: Colors.white,
                  );
                }
              });
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
            backgroundColor: Colors.lightBlueAccent,
          );
        }
      },
    );
  }
}
