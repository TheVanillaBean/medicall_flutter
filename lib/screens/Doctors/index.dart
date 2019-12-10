import 'dart:convert';

import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

var screenSize;

class DoctorsScreen extends StatefulWidget {
  final data;
  DoctorsScreen({Key key, @required this.data}) : super(key: key);

  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  ConsultData _consult;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        centerTitle: true,
        title: Text(
          'What can a doctor help you with?',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      drawer: DrawerMenu(data: {'user': medicallUser}),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Builder(builder: (BuildContext context) {
      //   return FloatingActionButton(
      //       child: Icon(
      //         CustomIcons.MedicallApp.logo_m,
      //         size: 35.0,
      //       ),
      //       onPressed: () {
      //         Scaffold.of(context).openDrawer();
      //       },
      //       backgroundColor: Theme.of(context).colorScheme.secondary,
      //       foregroundColor: Theme.of(context).colorScheme.onPrimary);
      // }),
      //Content of tabs
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EntryItem(data[index]),
        itemCount: data.length,
      ),
    );
  }
}

class Entry {
  Entry(this.title, this.subtitle, this.price,
      [this.children = const <Entry>[]]);
  final String title;
  final String subtitle;
  final String price;
  final List<Entry> children;
}

// The entire multilevel list displayed by this app.
final List<Entry> data = <Entry>[
  Entry('Hairloss', '9 minutes to complete', '\$39', <Entry>[
    Entry(
        'Most cases of hair loss are hereditary and can be treated with both prescription and non-prescription medications. It takes the providers on Medicall usually 24 hours to make a diagnosis and get you the medications you need at a very low price.',
        '',
        '')
  ]),
  Entry('Spot', '7 minutes to complete', '\$45', <Entry>[
    Entry(
        'Most cases of hair loss are hereditary and can be treated with both prescription and non-prescription medications. It takes the providers on Medicall usually 24 hours to make a diagnosis and get you the medications you need at a very low price.',
        '',
        '')
  ]),
];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);
  final Entry entry;
  static ConsultData _consult;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty)
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          children: <Widget>[
            Text(
              root.title,
              textAlign: TextAlign.left,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    _consult = ConsultData();

                    SharedPreferences _thisConsult =
                        await SharedPreferences.getInstance();
                    _consult.consultType = 'Hairloss';
                    var consultQuestions = await Firestore.instance
                        .document('services/dermatology/symptoms/' +
                            _consult.consultType.toLowerCase())
                        .get();
                    _consult.screeningQuestions =
                        consultQuestions.data["screening_questions"];
                    _consult.historyQuestions =
                        consultQuestions.data["medical_history_questions"];
                    _consult.uploadQuestions =
                        consultQuestions.data["upload_questions"];
                    String currentConsultString = jsonEncode(_consult);
                    await _thisConsult.setString(
                        "consult", currentConsultString);
                    GlobalNavigatorKey.key.currentState.push(
                      MaterialPageRoute(
                          builder: (_) => QuestionsScreen(
                                data: _consult,
                              )),
                    );
                  },
                  child: Text('Start'),
                )
              ],
            )
          ],
        ),
        width: screenSize.width,
      );
    return ExpansionTile(
      backgroundColor: Colors.blue.withAlpha(15),
      trailing: Padding(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Text(
          root.price,
          style: TextStyle(fontSize: 24),
        ),
      ),
      key: PageStorageKey<Entry>(root),
      children: root.children.map<Widget>(_buildTiles).toList(),
      title: Container(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(root.title),
            Text(
              root.subtitle,
              style: TextStyle(
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
