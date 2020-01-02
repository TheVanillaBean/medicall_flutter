import 'dart:convert';
import 'dart:math';

import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

var screenSize;

class SymptomsScreen extends StatefulWidget {
  final data;
  SymptomsScreen({Key key, @required this.data}) : super(key: key);

  _SymptomsScreenState createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  //ConsultData _consult;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    medicallUser = widget.data['user'];
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    void _showDialog(ConsultData _consult) {
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
                color: Theme.of(context).colorScheme.primary,
                child: Text("My Medical History"),
                onPressed: () {
                  GlobalNavigatorKey.key.currentState.pop();
                  GlobalNavigatorKey.key.currentState.push(
                    MaterialPageRoute(
                        builder: (_) => QuestionsScreen(
                              data: {'user': medicallUser, 'consult': _consult},
                            )),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.home),
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
            EntryItem(data[index], _showDialog),
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

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(
          Duration(seconds: 3),
          ColorTween(
              begin: Colors.lightBlue[100],
              end: Colors.lightBlue.shade50.withAlpha(20))),
      Track("color2").add(
          Duration(seconds: 3),
          ColorTween(
              begin: Colors.lightBlue[50].withAlpha(20),
              end: Colors.lightBlue.shade100))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry, this._showDialog);
  final Entry entry;
  static ConsultData _consult;
  final _showDialog;

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  Widget _buildTiles(Entry root) {
    return Stack(
      children: <Widget>[
        root.price.length > 0
            ? Positioned.fill(child: AnimatedBackground())
            : SizedBox(),
        onBottom(AnimatedWave(
          height: 180,
          speed: 0.6,
        )),
        onBottom(AnimatedWave(
          height: 120,
          speed: 0.9,
          offset: pi,
        )),
        onBottom(AnimatedWave(
          height: 220,
          speed: 0.3,
          offset: pi / 2,
        )),
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
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
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
                                  RaisedButton(
                                    onPressed: () async {
                                      _consult = ConsultData();

                                      SharedPreferences _thisConsult =
                                          await SharedPreferences.getInstance();
                                      for (var i = 0; i < data.length; i++) {
                                        if (data[i].title == root.title) {
                                          _consult.price = data[i].price;
                                        }
                                      }
                                      _consult.consultType =
                                          root.title == 'Spot'
                                              ? 'Lesion'
                                              : root.title;
                                      var consultQuestions = await Firestore
                                          .instance
                                          .document(
                                              'services/dermatology/symptoms/' +
                                                  _consult.consultType
                                                      .toLowerCase())
                                          .get();
                                      _consult.screeningQuestions =
                                          consultQuestions
                                              .data["screening_questions"];
                                      _consult.historyQuestions =
                                          consultQuestions.data[
                                              "medical_history_questions"];
                                      _consult.uploadQuestions =
                                          consultQuestions
                                              .data["upload_questions"];
                                      String currentConsultString =
                                          jsonEncode(_consult);
                                      await _thisConsult.setString(
                                          "consult", currentConsultString);
                                      // for (var i = 0;
                                      //     i < _consult.historyQuestions.length;
                                      //     i++) {
                                      //   if (_consult
                                      //           .historyQuestions[i]['answer']
                                      //           .length ==
                                      //       0) {
                                      //     GlobalNavigatorKey.key.currentState
                                      //         .push(
                                      //       MaterialPageRoute(
                                      //           builder: (_) => QuestionsScreen(
                                      //                 data: _consult,
                                      //               )),
                                      //     );
                                      //   }
                                      // }
                                      if (!medicallUser.hasMedicalHistory) {
                                        _showDialog(_consult);
                                      } else {
                                        GlobalNavigatorKey.key.currentState
                                            .push(
                                          MaterialPageRoute(
                                              builder: (_) => QuestionsScreen(
                                                    data: {
                                                      'user': medicallUser,
                                                      'consult': _consult
                                                    },
                                                  )),
                                        );
                                      }
                                    },
                                    child: Text('Start'),
                                  )
                                ],
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: _buildTiles(
        entry,
      ),
    );
  }
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}