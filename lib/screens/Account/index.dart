import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _scaffoldKey1 = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    medicallUser = Provider.of<AuthBase>(context).medicallUser;
    return Scaffold(
      //App Bar
      key: _scaffoldKey1,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey1.currentState.openDrawer();
          },
          icon: Icon(Icons.home),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
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
                    child: medicallUser.profilePic != null
                        ? CachedNetworkImage(
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            imageUrl: medicallUser.profilePic,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )
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
                  title: Text(medicallUser.email),
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
                    GlobalNavigatorKey.key.currentState
                        .pushNamed('/paymentDetail');
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
