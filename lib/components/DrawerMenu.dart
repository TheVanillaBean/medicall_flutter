import 'package:Medicall/models/medicall_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/animation.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/screens/Login/index.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DrawerMenu extends StatefulWidget {
  final data;
  DrawerMenu({Key key, @required this.data}) : super(key: key);

  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    medicallUser = widget.data['user'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Drawer(
        child: Stack(
      children: <Widget>[
        Container(
          height: 108.0,
          child: DrawerHeader(
              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryVariant,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Icon(CustomIcons.MedicallApp.logo,
                        size: 40.0,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(21, 0, 0, 0),
                        child: Text(
                          'MEDICALL',
                          style: TextStyle(
                            fontSize: 18.0,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ))
                ],
              )),
        ),
        ListView(
          children: <Widget>[
            ListTile(
                dense: true,
                contentPadding: EdgeInsets.fromLTRB(16, 80, 0, 0),
                leading: Icon(
                  Icons.local_hospital,
                  color: Theme.of(context).colorScheme.primaryVariant,
                ),
                title: Text(
                  medicallUser.type == 'provider'
                      ? 'Patients'
                      : 'Find A Doctor',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  medicallUser.type == 'provider'
                      ? Navigator.of(context).pushNamed('/history',
                          arguments: {'user': medicallUser})
                      : Navigator.of(context).pushNamed('/doctors',
                          arguments: {'user': medicallUser});
                }),
            ListTile(
                leading: Icon(
                  Icons.chat,
                  color: Theme.of(context).disabledColor,
                ),
                title: Text(
                  'Chat',
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                onTap: () {
                  // Navigator.pop(context);
                  // Navigator.of(context).pushNamed('/chat');
                }),
            medicallUser.type == 'patient'
                ? ListTile(
                    leading: Icon(
                      Icons.folder_shared,
                      color: Theme.of(context).colorScheme.primaryVariant,
                    ),
                    title: Text(
                      'History',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/history',
                          arguments: {'user': medicallUser});
                    })
                : SizedBox(),
            ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  'Account',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/account');
                }),
            Divider(
              height: 0,
              color: Colors.grey[400],
            ),
            ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onTap: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }),
          ],
        )
      ],
    )));
  }
}