import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Medicall/globals.dart' as globals;

class RegistrationTypeScreen extends StatefulWidget {
  @override
  _RegistrationTypeScreenState createState() => _RegistrationTypeScreenState();
}

class _RegistrationTypeScreenState extends State<RegistrationTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: Text('Type of Registration'),
        leading: new Text('', style: TextStyle(color: Colors.black26)),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                  'If you are looking to get a consult by a healthcare professional, tap below.'),
            ),
            new RaisedButton(
              splashColor: Colors.pinkAccent,
              color: Color.fromRGBO(35, 179, 232, 1),
              padding: EdgeInsets.fromLTRB(45, 30, 45, 30),
              child: new Text(
                "I'm a patient looking for care",
                style: new TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/registrationPatient');
              },
            ),
            new Expanded(
              child: Container(),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                  'If you are a healthcare professional looking to give consults, tap below.'),
            ),
            new RaisedButton(
              splashColor: Colors.pinkAccent,
              color: Color.fromRGBO(35, 179, 232, 0.5),
              padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: new Text(
                "I'm a doctor looking to provide care",
                style: new TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/registrationProvider');
              },
            ),
            new Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
