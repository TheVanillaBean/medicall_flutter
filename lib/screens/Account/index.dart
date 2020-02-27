import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserProvider _userProvider;
  AuthBase _authProvider;
  ExtImageProvider _extImageProvider;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _userProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    _authProvider = Provider.of<AuthBase>(context);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    return Scaffold(
      //Content of tabs
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(100.0),
                    child:
                        medicallUser != null && medicallUser.profilePic != null
                            ? _extImageProvider.returnNetworkImage(
                                _userProvider.medicallUser.profilePic,
                                fit: BoxFit.cover,
                                height: 100.0,
                                width: 100.0,
                                cache: true)
                            : Icon(
                                Icons.account_circle,
                                size: 100,
                              ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(_userProvider.medicallUser.displayName),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(_userProvider.medicallUser.email),
                  leading: Icon(Icons.email),
                  onTap: () {},
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(_userProvider.medicallUser.phoneNumber != null
                      ? _userProvider.medicallUser.phoneNumber
                      : ''),
                  leading: Icon(Icons.phone),
                  onTap: () {},
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text('Patient'),
                  leading: Icon(Icons.person),
                  onTap: () {},
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text('Payment Cards'),
                  leading: Icon(Icons.payment),
                  onTap: () {
                    Navigator.of(context).pushNamed('/paymentDetail');
                  },
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text('Sign Out'),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () {
                    _authProvider.signOut();
                  },
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
