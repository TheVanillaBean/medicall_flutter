import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/screens/Symptoms/symptomDetail.dart';
import 'package:Medicall/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Database db = Provider.of<Database>(context);
    MedicallUser medicallUser = MedicallUser();
    void _showDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Your Medical History"),
            content: Text(
                "We noticed you have no medical history filled out, tap below to fillout the information needed and we will save it to your account for future use."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                color: Theme.of(context).primaryColor,
                child: Text("My Medical History"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => QuestionsScreen()),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'How can we help you today?',
        ),
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder(
          future: db.getSymptoms(medicallUser),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (db.userMedicalRecord != null &&
                  db.userMedicalRecord.data != null) {
                medicallUser.hasMedicalHistory = true;
              }
              final List<Entry> data = <Entry>[];
              if (snapshot.data.documents.length > 0) {
                for (var i = 0; i < snapshot.data.documents.length; i++) {
                  data.add(Entry(
                      "${snapshot.data.documents[i].documentID[0].toUpperCase()}${snapshot.data.documents[i].documentID.substring(1)}",
                      snapshot.data.documents[i].data['duration'],
                      ('\$' +
                          snapshot.data.documents[i].data['price'].toString()),
                      <Entry>[
                        Entry(snapshot.data.documents[i].documentID,
                            snapshot.data.documents[i].data['description'], '')
                      ]));
                }
              }
              return Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Visit Fee \$49',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          ' This is the price for the doctor\'s services. Prescriptions or in person follow-up care not included.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) =>
                          EntryItem(data[index], _showDialog, context),
                      itemCount: data.length,
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          }),
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
final List<Entry> data = <Entry>[];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry, this._showDialog, this.context);
  final Entry entry;
  final _showDialog;
  final context;

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  Widget _buildTiles(Entry root) {
    Database db = Provider.of<Database>(context);
    //MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
    //MedicalHistoryState _newMedicalHistory =
    //Provider.of<MedicalHistoryState>(context, listen: false);
    //_newMedicalHistory.setnewMedicalHistory(true);
    return Stack(
      children: <Widget>[
        root.price != '' && root.title == 'Hairloss'
            ? Positioned.fill(child: Container())
            : root.price != '' ? Container() : Container(),
        Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: root.children.isEmpty
                ? BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                  )
                : BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
            child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(10),
                child: Theme(
                  data: ThemeData(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      toggleableActiveColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      accentColor: Colors.black,
                      highlightColor: Colors.transparent),
                  child: ListTile(
                    key: PageStorageKey<Entry>(root),
                    onTap: () async {
                      if (db.newConsult == null ||
                          db.newConsult.provider == null) {
                        db.newConsult = ConsultData();
                      }
                      db.newConsult.desc = this.entry.children[0].subtitle;
                      db.newConsult.price = this.entry.price;
                      db.newConsult.consultType =
                          "${root.title[0].toUpperCase()}${root.title.substring(1)}" ==
                                  'Spot'
                              ? 'Lesion'
                              : "${root.title[0].toUpperCase()}${root.title.substring(1)}";
                      await db.getConsultQuestions();
                      var medicalHistoryQuestions =
                          await db.getMedicalHistoryQuestions();
                      db.newConsult.historyQuestions = medicalHistoryQuestions
                          .data["medical_history_questions"];

                      db.newConsult.screeningQuestions =
                          db.consultQuestions.data["screening_questions"];

                      db.newConsult.uploadQuestions =
                          db.consultQuestions.data["upload_questions"];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => SymptomDetailScreen()),
                      );
                    },
                    //children: root.children.map<Widget>(_buildTiles).toList(),
                    title: Container(
                      padding: root.children.isEmpty
                          ? EdgeInsets.fromLTRB(0, 0, 0, 0)
                          : EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          root.children.isEmpty ? SizedBox() : Text(root.title),
                          root.children.isEmpty
                              ? Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  child: Text(
                                    root.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : Text(
                                  root.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                )))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: _buildTiles(entry),
    );
  }
}
