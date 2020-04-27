import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/doctorSearch.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/screens/Symptoms/medical_history_state.dart';
import 'package:Medicall/services/animation_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Database db = Provider.of<Database>(context);
    MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
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
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.home),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'How can doctors help?',
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
                  Expanded(
                    flex: 9,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) =>
                          EntryItem(data[index], _showDialog, context),
                      itemCount: data.length,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              'If you already know who your doctor is, tap below'),
                          FlatButton(
                            color: Theme.of(context).colorScheme.secondary,
                            colorBrightness: Brightness.dark,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => DoctorSearch()),
                              );
                            },
                            child: Text('Find my doctor'),
                          ),
                        ],
                      ),
                    ),
                  )
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
    MyAnimationProvider _animationProvider =
        Provider.of<MyAnimationProvider>(context);
    Database db = Provider.of<Database>(context);
    MedicallUser medicallUser = Provider.of<UserProvider>(context).medicallUser;
    MedicalHistoryState _newMedicalHistory =
        Provider.of<MedicalHistoryState>(context);
    //_newMedicalHistory.setnewMedicalHistory(false);
    return Stack(
      children: <Widget>[
        root.price != '' && root.title == 'Hairloss'
            ? Positioned.fill(
                child: _animationProvider.returnAnimation(
                    tween: _animationProvider.returnMultiTrackTween([
                      Colors.blueAccent.withAlpha(20),
                      Colors.cyanAccent.withAlpha(50),
                      Colors.cyanAccent.withAlpha(50),
                      Colors.blueAccent.withAlpha(20)
                    ]),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    radius: BorderRadius.all(Radius.circular(10))))
            : root.price != ''
                ? Positioned.fill(
                    child: _animationProvider.returnAnimation(
                        tween: _animationProvider.returnMultiTrackTween([
                          Colors.greenAccent.withAlpha(50),
                          Colors.blueAccent.withAlpha(20),
                          Colors.blueAccent.withAlpha(20),
                          Colors.greenAccent.withAlpha(50)
                        ]),
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        radius: BorderRadius.all(Radius.circular(10))))
                : Container(),
        Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: root.children.isEmpty
                ? BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                  )
                : BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent.withAlpha(150),
                    ),
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
                  child: ExpansionTile(
                    backgroundColor: root.children.isEmpty
                        ? Colors.transparent
                        : Colors.blue.withAlpha(15),
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
                          root.children.isEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    medicallUser.hasMedicalHistory
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 0, 35, 0),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  top: BorderSide(
                                                      color: Colors.grey
                                                          .withAlpha(100))),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  'Change in medical history?',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'No',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    Switch(
                                                      value: _newMedicalHistory
                                                          .getnewMedicalHistory(),
                                                      onChanged: (value) {
                                                        _newMedicalHistory =
                                                            _newMedicalHistory
                                                                .setnewMedicalHistory(
                                                                    value);
                                                      },
                                                      activeTrackColor:
                                                          Colors.white,
                                                      activeColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary,
                                                    ),
                                                    Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ))
                                        : Container(
                                            // width:
                                            //     ScreenUtil.screenWidthDp / 1.8,
                                            // padding:
                                            //     EdgeInsets.fromLTRB(0, 0, 0, 0),
                                            // child: Text(
                                            //   'You currently have no medical history on file, we will redirect you to your medical history before taking you to the ' +
                                            //       root.title +
                                            //       ' questions',
                                            //   style: TextStyle(
                                            //       fontSize: 10,
                                            //       color: Colors.black45),
                                            // ),
                                            ),
                                    RaisedButton(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      onPressed: () async {
                                        if (db.newConsult == null ||
                                            db.newConsult.provider == null) {
                                          db.newConsult = ConsultData();
                                        }

                                        db.newConsult.price = this.entry.price;
                                        db.newConsult.consultType =
                                            "${root.title[0].toUpperCase()}${root.title.substring(1)}" ==
                                                    'Spot'
                                                ? 'Lesion'
                                                : "${root.title[0].toUpperCase()}${root.title.substring(1)}";
                                        await db
                                            .getConsultQuestions(medicallUser);
                                        if (!medicallUser.hasMedicalHistory ||
                                            _newMedicalHistory
                                                .getnewMedicalHistory()) {
                                          var medicalHistoryQuestions = await db
                                              .getMedicalHistoryQuestions();
                                          db.newConsult.historyQuestions =
                                              medicalHistoryQuestions.data[
                                                  "medical_history_questions"];
                                        }

                                        db.newConsult.screeningQuestions = db
                                            .consultQuestions
                                            .data["screening_questions"];

                                        db.newConsult.uploadQuestions = db
                                            .consultQuestions
                                            .data["upload_questions"];
                                        if (!medicallUser.hasMedicalHistory) {
                                          _showDialog();
                                        } else {
                                          if (_newMedicalHistory
                                              .getnewMedicalHistory()) {
                                            _newMedicalHistory
                                                .setnewMedicalHistory(true);
                                            Navigator.of(context)
                                                .pushNamed('/questionsScreen');
                                          } else {
                                            _newMedicalHistory
                                                .setnewMedicalHistory(false);
                                            Navigator.of(context)
                                                .pushNamed('/questionsScreen');
                                          }
                                          //_showMedDialog();
                                        }
                                      },
                                      child: Text(
                                        'Start',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
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
