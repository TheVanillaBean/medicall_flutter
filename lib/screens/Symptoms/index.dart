import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
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
          'What can a doctor help you with?',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      drawer: DrawerMenu(),
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
      body: FutureBuilder(
          future: db.getUserMedicalHistory(medicallUser),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (db.userMedicalRecord != null &&
                  db.userMedicalRecord.data != null) {
                medicallUser.hasMedicalHistory = true;
              }
              return ListView.builder(
                itemBuilder: (BuildContext context, int index) =>
                    EntryItem(data[index], _showDialog, context),
                itemCount: data.length,
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
final List<Entry> data = <Entry>[
  Entry('Hairloss', '9 minutes to complete', '\$39', <Entry>[
    Entry(
        'Hairloss',
        'Most cases of hair loss are hereditary and can be treated with both prescription and non-prescription medications. It takes the providers on Medicall usually 24 hours to make a diagnosis. Medications not included in the consultation fee. However, we offer some of the lowest prices in the nation with 90 day supply of Finasteride/Propecia costing \$12.99 with free shipping.',
        '')
  ]),
  Entry('Spot', '7 minutes to complete', '\$35', <Entry>[
    Entry(
        'Spot',
        'The provider will evaluate the photographs and information you provide to make a diagnosis within 24 hours. Most spots are not dangerous and do not require treatment. In some cases, such as in the case of skin cancer, the provider may need to see you in person to confirm the diagnosis (e.g. biopsy) or to provide treatment. These are additional services not included in the consultation fee.',
        '')
  ]),
];

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
                      Colors.blueAccent.withAlpha(100),
                      Colors.cyanAccent.withAlpha(50),
                      Colors.cyanAccent.withAlpha(50),
                      Colors.blueAccent.withAlpha(100)
                    ]),
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    radius: BorderRadius.all(Radius.circular(10))))
            : root.price != ''
                ? Positioned.fill(
                    child: _animationProvider.returnAnimation(
                        tween: _animationProvider.returnMultiTrackTween([
                          Colors.purpleAccent.withAlpha(50),
                          Colors.blueAccent.withAlpha(50),
                          Colors.blueAccent.withAlpha(50),
                          Colors.purpleAccent.withAlpha(50)
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
                                                0, 0, 60, 0),
                                            width: 160,
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
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
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

                                        for (var i = 0; i < data.length; i++) {
                                          if (data[i].title == root.title) {
                                            db.newConsult.price = data[i].price;
                                          }
                                        }
                                        db.newConsult.consultType =
                                            root.title == 'Spot'
                                                ? 'Lesion'
                                                : root.title;
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
                                            medicallUser.hasMedicalHistory =
                                                false;
                                            _newMedicalHistory
                                                .setnewMedicalHistory(false);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      QuestionsScreen()),
                                            );
                                          } else {
                                            _newMedicalHistory
                                                .setnewMedicalHistory(false);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      QuestionsScreen()),
                                            );
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
