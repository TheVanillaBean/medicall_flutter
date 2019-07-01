import 'dart:convert';

import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/models/consult_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorsScreen extends StatefulWidget {
  final data;
  DoctorsScreen({Key key, @required this.data}) : super(key: key);

  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  ConsultData _consult;
  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text('', style: TextStyle(color: Colors.black26)),
        centerTitle: true,
        title: Text(
          'Find a Doctor',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      drawer: DrawerMenu(data: {'user': medicallUser}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
            child: Icon(
              CustomIcons.MedicallApp.logo_m,
              size: 35.0,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary);
      }),
      //Content of tabs
      body: Stack(
        children: <Widget>[
          OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              return Container(
                child: GridView.count(
                  crossAxisCount: orientation == Orientation.portrait ? 3 : 6,
                  childAspectRatio: 1.0,
                  padding: orientation == Orientation.portrait
                      ? EdgeInsets.fromLTRB(10, 60, 10, 10)
                      : EdgeInsets.fromLTRB(10, 30, 10, 10),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  // Generate 100 Widgets that display their index in the List
                  children: [
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Acne',
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                        semanticsLabel: 'Acne',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Hair Loss',
                        semanticsLabel: 'Hair Loss',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Cold Sore',
                        semanticsLabel: 'Cold Sore',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Cosmetic',
                        semanticsLabel: 'Cosmetic',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Anti-Aging',
                        semanticsLabel: 'Anti-Aging',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Nail',
                        semanticsLabel: 'Nail',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                        color: Color.fromRGBO(35, 179, 232, 1),
                        child: Text(
                          'Lesion',
                          semanticsLabel: 'Lesion',
                          textScaleFactor:
                              orientation == Orientation.portrait ? 1 : 0.8,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          _consult = ConsultData();
                          _consult.consultType = 'Lesion';
                          _consult.provider = '';
                          _consult.providerId = '';
                          _consult.patientDevTokens = [];
                          _consult.providerDevTokens = [];
                          _consult.screeningQuestions = [];
                          _consult.stringListQuestions = [];
                          _consult.historyQuestions = [];
                          _consult.media = [];

                          SharedPreferences _thisConsult =
                              await SharedPreferences.getInstance();
                          var consultQuestions = await Firestore.instance
                              .document('services/dermatology/symptoms/' +
                                  _consult.consultType.toLowerCase())
                              .get();
                          _consult.screeningQuestions =
                              consultQuestions.data["screening_questions"];
                          _consult.historyQuestions = consultQuestions
                              .data["medical_history_questions"];
                          String currentConsultString = jsonEncode(_consult);
                          await _thisConsult.setString(
                              "consult", currentConsultString);
                          Navigator.pushNamed(
                            context,
                            '/questionsScreening',
                            arguments: {'user': medicallUser},
                          );
                        }),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Rash',
                        semanticsLabel: 'Rash',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    ),
                    RaisedButton(
                      color: Theme.of(context).disabledColor.withAlpha(10),
                      child: Text(
                        'Other',
                        semanticsLabel: 'Other',
                        style: TextStyle(
                            color:
                                Theme.of(context).disabledColor.withAlpha(50)),
                        textScaleFactor:
                            orientation == Orientation.portrait ? 1 : 0.8,
                      ),
                      onPressed: () {
                        // Perform some action
                      },
                    )
                  ],
                ),
              );
            },
          ),
          OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              return Container(
                child: Container(
                    alignment: Alignment.topCenter,
                    height: orientation == Orientation.portrait ? 60 : 20,
                    padding: orientation == Orientation.portrait
                        ? EdgeInsets.fromLTRB(0, 20, 0, 0)
                        : EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      'Please select why you need a doctor,',
                      style: TextStyle(color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    )),
              );
            },
          ),
        ],
      ),
    );
  }
}
