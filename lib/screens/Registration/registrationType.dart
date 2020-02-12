import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tempUserProvider = Provider.of<TempUserProvider>(context);
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (auth.isGoogleUser) {
                auth.signOut();
              }else{
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Create New Account',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withRed(240)
                    .withGreen(250)
                    .withBlue(255),
                padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    Text(
                      'Patient',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).primaryColor),
                    ),
                    Text(
                        'If you are looking to get a consult by a healthcare professional, tap here.',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center),
                  ],
                ),
                onPressed: () {
                  tempUserProvider.updateWith(userType: 'patient');
                  Navigator.of(context).pushNamed('/registration');
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withBlue(250)
                    .withGreen(250)
                    .withRed(255),
                padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.local_hospital,
                          size: 40,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                    Text(
                      'Doctor',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    Text(
                        'If you are a healthcare professional looking to give consults, tap here.',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context).colorScheme.secondary),
                        textAlign: TextAlign.center),
                  ],
                ),
                onPressed: () {
                  tempUserProvider.updateWith(userType: 'provider');
                  Navigator.of(context).pushNamed('/registration');
                },
              ),
            )
          ],
        ));
  }
}
