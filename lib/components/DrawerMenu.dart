import 'dart:convert';

import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    medicallUser = Provider.of<UserProvider>(context).medicallUser;
    return (Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          Container(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(CustomIcons.MedicallApp.logo,
                        size: 40.0,
                        color: Theme.of(context).colorScheme.onPrimary),
                    SizedBox(width: 15),
                    Text(
                      'MEDICALL',
                      style: TextStyle(
                        fontSize: 18.0,
                        letterSpacing: 1.5,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              )),
          medicallUser.type == 'provider'
              ? Container()
              : ListTile(
                  contentPadding: EdgeInsets.fromLTRB(16, 10, 0, 10),
                  leading: Icon(
                    Icons.local_hospital,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Find A Doctor',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onTap: () async {
                    SharedPreferences _thisConsult =
                        await SharedPreferences.getInstance();
                    String currentConsultString = jsonEncode(ConsultData());
                    await _thisConsult.setString(
                        "consult", currentConsultString);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/symptoms',
                        arguments: {'user': medicallUser});
                  }),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 10, 0, 10),
              dense: true,
              leading: Icon(
                Icons.recent_actors,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'History',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/history');
              }),
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 10, 0, 10),
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
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushNamed('/account', arguments: {'user': medicallUser});
              }),
          Divider(
            height: 0,
            color: Colors.grey[400],
          ),
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 10, 0, 10),
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: () => _signOut(context),
          )
        ],
      ),
    ));
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      Navigator.of(context).pop(context);
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }
}
