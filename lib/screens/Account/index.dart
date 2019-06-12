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
        body: PageView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(70)),
                          bottom: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withAlpha(70)))),
                  child: ListTile(
                    title: Text('Payment Cards'),
                    leading: Icon(Icons.payment),
                    onTap: (){
                      Navigator.pushNamed(context, '/paymentDetail');
                    },
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ),
                )
              ],
            )
          ],
        ),
      );
}
