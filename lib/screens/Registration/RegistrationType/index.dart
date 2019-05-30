import 'package:Medicall/models/medicall_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/globals.dart' as globals;

class RegistrationTypeScreen extends StatefulWidget {
  @override
  _RegistrationTypeScreenState createState() => _RegistrationTypeScreenState();
}

class _RegistrationTypeScreenState extends State<RegistrationTypeScreen> {
  void _add(MedicallUser user, String type) {
    final DocumentReference documentReference =
        Firestore.instance.document("users/" + user.id);
    Map<String, String> data = <String, String>{
      "type": type,
    };
    medicallUser.type = type;
    documentReference.updateData(data).whenComplete(() {
      print("Document Added");
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          'Type of Registration',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        leading: Text('', style: TextStyle(color: Colors.black26)),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 60,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              Icon(
                Icons.local_hospital,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ]),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                  'If you are looking to get a consult by a healthcare professional, tap below.'),
            ),
            RaisedButton(
              padding: EdgeInsets.fromLTRB(45, 30, 45, 30),
              child: Text(
                'I\'m a patient looking for care',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              onPressed: () {
                _add(medicallUser, 'patient');
                Navigator.pushNamed(context, '/registration');
              },
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              child: Icon(
                Icons.queue_play_next,
                size: 60,
                color: Theme.of(context).accentColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                  'If you are a healthcare professional looking to give consults, tap below.'),
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
              child: Text(
                'I\'m a doctor looking to provide care',
                style: TextStyle(
                    fontSize: 20.0, color: Theme.of(context).backgroundColor),
              ),
              onPressed: () {
                _add(medicallUser, 'provider');
                Navigator.pushNamed(context, '/registration');
              },
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
