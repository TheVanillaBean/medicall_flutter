import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/Consults/ProviderVisits/provider_visits.dart';
import 'package:Medicall/screens/Consults/previous_visits.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User medicallUser =
        Provider.of<UserProvider>(context, listen: false).user;
    final EdgeInsets listContentPadding = EdgeInsets.fromLTRB(15, 5, 0, 5);
    return Container(
      width: 250,
      child: (Drawer(
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
                    // Container(
                    //   transform: Matrix4.translationValues(10.0, 0.0, 0.0),
                    //   child: Text('MEDI',
                    //       style: TextStyle(
                    //           fontSize: 18.0,
                    //           height: 1.08,
                    //           letterSpacing: 2.5,
                    //           fontWeight: FontWeight.w700,
                    //           color: Theme.of(context).colorScheme.primary)),
                    // ),
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Image.asset(
                        'assets/icon/logo_fore.png',
                      ),
                    ),
                    // Container(
                    //   transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
                    //   child: Text('CALL',
                    //       style: TextStyle(
                    //           fontSize: 18.0,
                    //           height: 1.08,
                    //           letterSpacing: 2.5,
                    //           fontWeight: FontWeight.w700,
                    //           color: Theme.of(context).colorScheme.primary)),
                    // )
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    ListTile(
                        contentPadding: listContentPadding,
                        title: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            'Home',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        leading: Icon(
                          Icons.home,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () {
                          if (medicallUser.type == USER_TYPE.PATIENT) {
                            PatientDashboardScreen.show(
                                context: context, pushReplaceNamed: true);
                          } else {
                            ProviderDashboardScreen.show(
                                context: context, pushReplaceNamed: true);
                          }
                        }),
                    medicallUser.type == USER_TYPE.PROVIDER
                        ? Container()
                        : ListTile(
                            contentPadding: listContentPadding,
                            title: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                'New Visit',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            leading: Icon(
                              Icons.local_hospital,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/symptoms',
                                  arguments: {'user': medicallUser});
                            }),
                    medicallUser.type == USER_TYPE.PROVIDER
                        ? ListTile(
                            contentPadding: listContentPadding,
                            title: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                'My Visits',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            leading: Icon(
                              Icons.recent_actors,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              ProviderVisits.show(context: context);
                            })
                        : ListTile(
                            contentPadding: listContentPadding,
                            title: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                'Previous Visits',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            leading: Icon(
                              Icons.recent_actors,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              PreviousVisits.show(context: context);
                            }),
                    ListTile(
                        contentPadding: listContentPadding,
                        title: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            'Account',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        leading: Icon(
                          Icons.account_circle,
                          color: Theme.of(context).colorScheme.primary,
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
                      contentPadding: listContentPadding,
                      title: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          'Sign Out',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      leading: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () => _signOut(context),
                    )
                  ],
                )),
          ],
        ),
      )),
    );
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
