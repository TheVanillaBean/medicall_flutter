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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: <Widget>[
              //       Row(
              //         children: <Widget>[
              //           Icon(
              //             Icons.person,
              //             size: 40,
              //             color: Theme.of(context).primaryColor,
              //           ),
              //           Icon(
              //             Icons.local_hospital,
              //             size: 40,
              //             color: Theme.of(context).primaryColor,
              //           ),
              //         ],
              //       ),
              //       Icon(
              //         Icons.queue_play_next,
              //         size: 40,
              //         color: Theme.of(context).accentColor,
              //       ),
              //     ]),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: Padding(
              //         padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
              //         child: Text(
              //             'If you are looking to get a consult by a healthcare professional, tap below.'),
              //       ),
              //     ),
              //     Expanded(
              //       child: Padding(
              //         padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
              //         child: Text(
              //             'If you are a healthcare professional looking to give consults, tap below.'),
              //       ),
              //     )
              //   ],
              // ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: RaisedButton(
              //         padding: EdgeInsets.fromLTRB(45, 30, 45, 30),
              //         child: Text(
              //           'Patient',
              //           style: TextStyle(fontSize: 18.0, color: Colors.white),
              //         ),
              //         onPressed: () {
              //           _add(medicallUser, 'patient');
              //           Navigator.pushNamed(context, '/registration',
              //               arguments: widget.data);
              //         },
              //       ),
              //     ),
              //     Expanded(
              //       child: RaisedButton(
              //         color: Theme.of(context).accentColor,
              //         padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
              //         child: Text(
              //           'Doctor',
              //           style: TextStyle(
              //               fontSize: 18.0,
              //               color: Theme.of(context).backgroundColor),
              //         ),
              //         onPressed: () {
              //           _add(medicallUser, 'provider');
              //           Navigator.pushNamed(context, '/registration',
              //               arguments: widget.data);
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                size: 40,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Patient',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).backgroundColor),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'If you are looking to get a consult by a healthcare professional, tap below.',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Theme.of(context).backgroundColor)),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      onPressed: () {
                        _add(medicallUser, 'patient');
                        Navigator.pushNamed(context, '/registration',
                            arguments: widget.data);
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 1,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      padding: EdgeInsets.fromLTRB(15, 30, 15, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.local_hospital,
                                size: 40,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Doctor',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).backgroundColor),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              'If you are a healthcare professional looking to give consults, tap below.',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: Theme.of(context).backgroundColor)),
                          SizedBox(
                            height: 10,
                          ),
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
              )
            ],
          ),
        ));
  }
}
