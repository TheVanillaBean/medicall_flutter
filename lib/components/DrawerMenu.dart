import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/util/firebase_anonymously_util.dart';
import 'package:Medicall/util/firebase_google_util.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/screens/Login/index.dart';

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
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.fromLTRB(16, 80, 0, 0),
                  leading: Icon(
                    Icons.local_hospital,
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                  title: Text(
                    'Find A Doctor',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/doctors',
                        arguments: {'user': medicallUser});
                  }),
              ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.recent_actors,
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
                  }),
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
                    FirebaseAnonymouslyUtil().signOut();
                    FirebaseGoogleUtil().signOutWithGoogle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
            ],
          ),
        ),
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
      ],
    )));
  }
}
