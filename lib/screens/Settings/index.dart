import 'package:Medicall/models/medicall_user.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        //App Bar
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        //Content of tabs
        body: PageView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: globals.currentUser != null
                            ? DecorationImage(
                                fit: BoxFit.fill,
                                image: globals.currentUser.photoUrl != null
                                    ? NetworkImage(
                                        globals.currentUser.photoUrl)
                                    : null)
                            : null)),
                Text(medicallUser.firstName,
                    textScaleFactor: 1.5)
              ],
            )
          ],
        ),
      );
}
