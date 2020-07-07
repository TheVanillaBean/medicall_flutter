import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tempUserProvider = Provider.of<TempUserProvider>(context);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Create New Account',
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
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    Text(
                      'Patient',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Text(
                        'If you are looking to get a consult by a healthcare professional, tap here.',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center),
                  ],
                ),
                onPressed: () {
                  tempUserProvider.setUser(userType: USER_TYPE.PATIENT);
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
                  tempUserProvider.getMalpracticeQuestions();
                  tempUserProvider.setUser(userType: USER_TYPE.PROVIDER);
                  Navigator.of(context).pushNamed('/registration');
                },
              ),
            )
          ],
        ));
  }
}
