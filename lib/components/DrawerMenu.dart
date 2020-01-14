import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    medicallUser = Provider.of<AuthBase>(context).medicallUser;
    return (Drawer(
        child: Stack(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              medicallUser.type == 'provider'
                  ? SizedBox(
                      height: 80,
                    )
                  : ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.fromLTRB(16, 80, 0, 0),
                      leading: Icon(
                        Icons.local_hospital,
                        color: Theme.of(context).colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    'History',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    GlobalNavigatorKey.key.currentState
                        .pushReplacementNamed('/history');
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
                    Navigator.of(context).pushNamed('/account',
                        arguments: {'user': medicallUser});
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
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ),
        Container(
          height: 108.0,
          child: DrawerHeader(
              padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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

  Future<void> _signOut(BuildContext context) async {
    try {
      Navigator.pop(context);
      final auth = Provider.of<AuthBase>(context);
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
