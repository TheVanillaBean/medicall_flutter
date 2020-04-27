import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
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
  ExtImageProvider _extImageProvider;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<UserProvider>(context);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    final MedicallUser medicallUser = _userProvider.medicallUser;
    return Scaffold(
      //App Bar
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.home),
            );
          },
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      drawer: DrawerMenu(),
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
                Text(medicallUser.displayName),
                Text(_userProvider.medicallUser.type),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Container(
                child: ListTile(
                  enabled: false,
                  title: Text(medicallUser.email),
                  leading: Icon(Icons.email),
                  onTap: () {},
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                ),
              ),
              Container(
                child: ListTile(
                  enabled: false,
                  title: Text(medicallUser.phoneNumber != null
                      ? medicallUser.phoneNumber
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
                    bottom: BorderSide(
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
            ],
          ),
        ],
      ),
    );
  }
}
