import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

import 'confirm_consult.dart';

class TempLinksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Temporary Links',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ConfirmConsult()));
                },
                child: Text(
                  'Confirm Consult',
                ),
                textColor: Colors.blue,
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.immediateMedicalCare);
                },
                child: Text(
                  'Immediate Medical Care',
                ),
                textColor: Colors.blue,
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.completeVisit);
                },
                child: Text(
                  'Complete Visit',
                ),
                textColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}