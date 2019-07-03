import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrationTypeScreen extends StatefulWidget {
  final data;

  const RegistrationTypeScreen({Key key, this.data}) : super(key: key);
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
  void initState() {
    medicallUser = widget.data['user'];
    super.initState();
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
        body: Flex(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
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
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ],
                    ),
                    Text(
                      'Patient',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).backgroundColor),
                    ),
                    Text(
                        'If you are looking to get a consult by a healthcare professional, tap below.',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context).backgroundColor),
                        textAlign: TextAlign.center),
                  ],
                ),
                onPressed: () {
                  _add(medicallUser, 'patient');
                  Navigator.pushNamed(context, '/registration',
                      arguments: widget.data);
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
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
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ],
                    ),
                    Text(
                      'Doctor',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context).backgroundColor),
                    ),
                    Text(
                        'If you are a healthcare professional looking to give consults, tap below.',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Theme.of(context).backgroundColor),
                        textAlign: TextAlign.center),
                  ],
                ),
                onPressed: () {
                  _add(medicallUser, 'provider');
                  Navigator.pushNamed(context, '/registration',
                      arguments: widget.data);
                },
              ),
            )
          ],
        ));
  }
}
