import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User medicallUser = Provider.of<UserProvider>(context).user;
    return (Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    transform: Matrix4.translationValues(10.0, 0.0, 0.0),
                    child: Text('MEDI',
                        style: TextStyle(
                            fontSize: 18.0,
                            height: 1.08,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/icon/logo_fore.png',
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
                    child: Text('CALL',
                        style: TextStyle(
                            fontSize: 18.0,
                            height: 1.08,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary)),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      title: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            child: Icon(
                              Icons.home,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Home',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushReplacementNamed('/dashboard');
                      }),
                  medicallUser.type == USER_TYPE.PROVIDER
                      ? Container()
                      : ListTile(
                          contentPadding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                          title: Stack(
                            alignment: Alignment.center,
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                left: 30,
                                child: Icon(
                                  Icons.local_hospital,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Find A Doctor',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/symptoms',
                                arguments: {'user': medicallUser});
                          }),
                  ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      title: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            child: Icon(
                              Icons.recent_actors,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'History',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/history');
                      }),
                  ListTile(
                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 25),
                      title: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            child: Icon(
                              Icons.account_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 25,
                            ),
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/account',
                            arguments: {'user': medicallUser});
                      }),
                  Divider(
                    height: 0,
                    color: Colors.grey[400],
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    title: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          child: Icon(
                            Icons.exit_to_app,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                    onTap: () => _signOut(context),
                  )
                ],
              )),
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
