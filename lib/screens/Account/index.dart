import 'package:Medicall/models/medicall_user_model.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        //App Bar
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Account',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        //Content of tabs
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    size: 100,
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
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
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
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(medicallUser.phoneNumber),
                    leading: Icon(Icons.phone),
                    onTap: () {},
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text('User Type: Patient'),
                    leading: Icon(Icons.person),
                    onTap: () {},
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text('Payment Cards'),
                    leading: Icon(Icons.payment),
                    onTap: () {
                      Navigator.pushNamed(context, '/paymentDetail');
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
