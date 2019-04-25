import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Scaffold(
        //App Bar
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(
            'Settings',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        //Content of tabs
        body: new PageView(
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    width: 190.0,
                    height: 190.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: globals.currentUser != null
                            ? new DecorationImage(
                                fit: BoxFit.fill,
                                image: globals.currentUser.photoUrl != null
                                    ? new NetworkImage(
                                        globals.currentUser.photoUrl)
                                    : null)
                            : null)),
                new Text(globals.medicallUser.firstName,
                    textScaleFactor: 1.5)
              ],
            )
          ],
        ),
      );
}
