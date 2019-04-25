import 'package:flutter/material.dart';
//import 'package:flutter/animation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/screens/Login/index.dart';

class DrawerMenu extends StatelessWidget {
  // Animation<double> containerGrowAnimation;
  // AnimationController _screenController;
  // AnimationController _buttonController;
  // Animation<double> buttonGrowAnimation;
  // Animation<double> listTileWidth;
  // Animation<Alignment> listSlideAnimation;
  // Animation<Alignment> buttonSwingAnimation;
  // Animation<EdgeInsets> listSlidePosition;
  // Animation<Color> fadeScreenAnimation;
  //var animateStatus = 0;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
    
  }

  @override
  Widget build(BuildContext context) {
    return (new Drawer(
        child: new Stack(
      children: <Widget>[
        new Container(
          height: 88.0,
          child: new DrawerHeader(
              padding: new EdgeInsets.fromLTRB(0, 0, 50, 0),
              decoration: new BoxDecoration(
                color: Color.fromRGBO(35, 179, 232, 1),
              ),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Icon(CustomIcons.MedicallApp.logo,
                        size: 40.0, color: Colors.white),
                  ),
                  new Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(21, 0, 0, 0),
                        child: new Text(
                          'MEDICALL',
                          style: TextStyle(
                            fontSize: 18.0,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ))
                ],
              )),
        ),
        new ListView(
          
          children: <Widget>[
            new ListTile(
              dense: true,
              contentPadding: EdgeInsets.fromLTRB(16, 60, 0, 0),
                leading: new Icon(
                  Icons.local_hospital,
                  color: Color.fromRGBO(35, 179, 232, 1),
                ),
                title: new Text(
                  'Find A Doctor',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/doctors');
                }),
            new ListTile(
                leading: new Icon(
                  Icons.chat,
                  color: Color.fromRGBO(35, 179, 232, 1),
                ),
                title: new Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/chat');
                }),
            new ListTile(
                leading: new Icon(
                  Icons.folder_shared,
                  color: Color.fromRGBO(35, 179, 232, 1),
                ),
                title: new Text(
                  'History',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/history');
                }),
            new ListTile(
                leading: new Icon(
                  Icons.settings_applications,
                  color: Color.fromRGBO(35, 179, 232, 1),
                ),
                title: new Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/settings');
                }),
            new Divider(
              height: 0,
              color: Colors.grey[400],
            ),
            new ListTile(
              
                leading: new Icon(
                  Icons.exit_to_app,
                  color: Color.fromRGBO(241, 100, 119, 1),
                ),
                title: new Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color.fromRGBO(241, 100, 119, 1),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  _handleSignOut();
                }),
          ],
        )
      ],
    )));
  }
}
