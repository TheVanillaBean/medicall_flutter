import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/services/database.dart';
import 'package:Medicall/util/app_util.dart' as AppUtils;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String currTab = 'Search History';
Orientation currentOrientation;
bool userHasConsults = false;
List<String> providers = [];
List<Widget> historyList = [];
MedicallUser medicallUser;
var userDocuments;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _getUserHistory() async {
    final Future<QuerySnapshot> documentReference = Firestore.instance
        .collection('consults')
        .where('provider_id', isEqualTo: medicallUser.uid)
        .orderBy('date', descending: true)
        .getDocuments();
    await documentReference.then((datasnapshot) {
      if (datasnapshot.documents != null) {
        userDocuments = datasnapshot.documents;
      }
    }).catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    currentOrientation = MediaQuery.of(context).orientation;
    medicallUser = Provider.of<Database>(context).currentMedicallUser;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      drawer: DrawerMenu(),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.home),
        ),
        title: Text('History'),
        actions: <Widget>[
          userHasConsults
              ? IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                )
              : SizedBox(
                  width: 60,
                ),
        ],
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: medicallUser.type == 'provider'
          ? _buildTab("patients")
          : _buildTab("consults"),
    );
  }

  _buildTab(questions) {
    if (questions == "consults") {
      return SingleChildScrollView(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('consults')
                .where('patient_id', isEqualTo: medicallUser.uid)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  heightFactor: 35,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                );
              }
              if (snapshot.data.documents.length > 0) {
                var userDocuments = snapshot.data.documents;
                List<Widget> historyList = [];
                for (var i = 0; i < userDocuments.length; i++) {
                  Timestamp timestamp = userDocuments[i].data['date'];
                  historyList.add(FlatButton(
                      padding: EdgeInsets.all(0),
                      splashColor:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                      onPressed: () {
                        Navigator.pushNamed(context, '/historyDetail',
                            arguments: {
                              'documentId': userDocuments[i].documentID,
                              'user': medicallUser,
                              'patient_id': userDocuments[i].data['patient_id'],
                              'provider_id':
                                  userDocuments[i].data['provider_id'],
                              'from': 'patients',
                              'isRouted': false,
                            });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withAlpha(70)))),
                        child: ListTile(
                          dense: true,
                          isThreeLine: true,
                          title: Text(
                            '${userDocuments[i].data['provider'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[0].substring(1)} ${userDocuments[i].data['provider'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[1].substring(1)} ' +
                                userDocuments[i].data['providerTitles'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          subtitle: Text(DateFormat('dd MMM h:mm a')
                                  .format(timestamp.toDate())
                                  .toString() +
                              '\n' +
                              userDocuments[i].data['type'].toString()),
                          trailing: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                userDocuments[i].data['state'].toString() ==
                                        'done'
                                    ? Icon(
                                        Icons.assignment_turned_in,
                                        color: Colors.green,
                                      )
                                    : userDocuments[i]
                                                .data['state']
                                                .toString() ==
                                            'in progress'
                                        ? Icon(
                                            Icons.assignment,
                                            color: Colors.blue,
                                          )
                                        : Icon(
                                            Icons.assignment_ind,
                                            color: Colors.amber,
                                          ),
                                Text(
                                  userDocuments[i].data['state'].toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                            onPressed: () {},
                          ),
                          leading: Icon(
                            Icons.account_circle,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(170),
                            size: 50,
                          ),
                        ),
                      )));
                }
                return Column(children: historyList.toList());
              } else {
                return Container(
                  height: currentOrientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height - 80
                      : MediaQuery.of(context).size.height - 50,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: currentOrientation == Orientation.portrait
                            ? MediaQuery.of(context).size.height - 80
                            : MediaQuery.of(context).size.height - 50,
                        width: MediaQuery.of(context).size.width,
                        child: CustomPaint(
                          foregroundPainter: CurvePainter(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Connect with local doctors now!',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        CustomIcons.MedicallIcons.live_help,
                                        size: 60,
                                        color: Colors.purple.withAlpha(140),
                                      ),
                                      Text('Select medical \nconcern',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ))
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        CustomIcons.MedicallIcons.medkit,
                                        size: 60,
                                        color: Colors.redAccent.withAlpha(200),
                                      ),
                                      Text(
                                        'If needed meds\nare delivered',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        CustomIcons.MedicallIcons.clipboard_1,
                                        size: 60,
                                        color: Colors.green.withAlpha(200),
                                      ),
                                      Text(
                                        'Answer\nquestions',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        CustomIcons.MedicallIcons.stethoscope,
                                        size: 60,
                                        color: Colors.blueAccent.withAlpha(200),
                                      ),
                                      Text(
                                        'Doctor reviews &\n provides diagnosis',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                      currentOrientation == Orientation.portrait
                                          ? SizedBox(
                                              height: 60,
                                            )
                                          : SizedBox(
                                              height: 20,
                                            ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              // _scaffoldKey.currentState
                                              //     .showBottomSheet(
                                              //         (context) => Container(
                                              //               color: Colors.white.withAlpha(200),
                                              //               height: 200,
                                              //             ));
                                              Navigator.pushReplacementNamed(
                                                  context, '/doctors');
                                            },
                                            color: Colors.green,
                                            child: Text('Start'),
                                          ),
                                          Text('  - or -  ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )),
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DoctorSearch()),
                                              );
                                            },
                                            color: Colors.blueAccent,
                                            child: Text('Find Doctor'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      );
    }
    if (questions == "patients") {
      return SingleChildScrollView(
        child: FutureBuilder(
            future: _getUserHistory(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(
                    heightFactor: 35,
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.waiting:
                  return Center(
                    heightFactor: 35,
                    child: CircularProgressIndicator(),
                  );
                default:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else
                    for (var i = 0; i < userDocuments.length; i++) {
                      Timestamp timestamp = userDocuments[i].data['date'];
                      historyList.add(FlatButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(70),
                          onPressed: () {
                            Navigator.pushNamed(context, '/historyDetail',
                                arguments: {
                                  'documentId': userDocuments[i].documentID,
                                  'user': medicallUser,
                                  'patient_id':
                                      userDocuments[i].data['patient_id'],
                                  'provider_id':
                                      userDocuments[i].data['provider_id'],
                                  'from': 'patients',
                                  'isRouted': false,
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withAlpha(70)))),
                            child: ListTile(
                              dense: true,
                              isThreeLine: true,
                              title: Text(
                                userDocuments[i].data['patient'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              subtitle: Text(DateFormat('dd MMM h:mm a')
                                      .format(timestamp.toDate())
                                      .toString() +
                                  '\n' +
                                  userDocuments[i].data['type'].toString()),
                              trailing: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    userDocuments[i].data['state'].toString() ==
                                            'done'
                                        ? Icon(
                                            Icons.assignment_turned_in,
                                            color: Colors.green,
                                          )
                                        : userDocuments[i]
                                                    .data['state']
                                                    .toString() ==
                                                'in progress'
                                            ? Icon(
                                                Icons.assignment,
                                                color: Colors.blue,
                                              )
                                            : Icon(
                                                Icons.assignment_ind,
                                                color: Colors.amber,
                                              ),
                                    Text(
                                      userDocuments[i].data['state'].toString(),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                                onPressed: () {},
                              ),
                              leading: Icon(
                                Icons.account_circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withAlpha(170),
                                size: 50,
                              ),
                            ),
                          )));
                    }
                  return Column(children: historyList.toList());
              }
            }),
      );
    }
  }
}

class DoctorSearch extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    currTab = "Search Doctors";
    final MedicallUser medicallUser = Provider.of<MedicallUser>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text('Find your doctor'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  heightFactor: 35,
                  child: Text("You have no patient requests yet.",
                      textAlign: TextAlign.center),
                );
              }
              if (snapshot.data.documents.length > 0) {
                var userDocuments = snapshot.data.documents;
                List<Widget> historyList = [];
                for (var i = 0; i < userDocuments.length; i++) {
                  if (userDocuments[i].data['type'] == 'provider' &&
                      medicallUser.displayName !=
                          userDocuments[i].data['name']) {
                    historyList.add(Container(
                      height: 75,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        fit: StackFit.loose,
                        children: <Widget>[
                          ListTile(
                            dense: true,
                            title: Text(
                                '${userDocuments[i].data['name'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[0].substring(1)} ${userDocuments[i].data['name'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[1].substring(1)}' +
                                    " " +
                                    userDocuments[i].data['titles']),
                            subtitle: Text(
                                userDocuments[i].data['address'].toString()),
                            leading: Icon(
                              Icons.account_circle,
                              size: 50,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            width: 120,
                            child: DropdownButtonHideUnderline(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.blue[50],
                                ),
                                child: DropdownButton(
                                  isExpanded: true,
                                  icon: Icon(Icons.more_vert),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'New Request',
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black26,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'New Request',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Follow Up',
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        child: Text(
                                          'Follow Up',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (String newVal) {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
                  }
                }
                return Column(children: historyList.toList());
              } else {
                return Center(
                  heightFactor: 35,
                  child: Text("You have no patient requests yet.",
                      textAlign: TextAlign.center),
                );
              }
            }),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path;
    Path path1;
    Path path2;
    //Path path3;

    // The arrows usually looks better with rounded caps.
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    /// Draw a single arrow.

    path = Path();

    if (currentOrientation == Orientation.portrait) {
      path.moveTo(size.width * 0.6, size.height * 0.25);
      path.relativeCubicTo(10, 0, size.width * 0.19, 0, size.width * 0.165, 85);
    } else {
      path.moveTo(size.width * 0.57, size.height * 0.15);
      path.relativeCubicTo(10, 0, size.width * 0.16, 0, size.width * 0.18, 55);
    }
    path = AppUtils.ArrowPath.make(
      path: path,
      tipLength: 5,
    );
    canvas.drawPath(path, paint..color = Colors.blue.withAlpha(100));

    path1 = Path();
    if (currentOrientation == Orientation.portrait) {
      path1.moveTo(size.width * 0.78, size.height / 1.70);
      path1.relativeCubicTo(0, 60, 0, 110, -60, 110);
    } else {
      path1.moveTo(size.width * 0.76, size.height / 1.75);
      path1.relativeCubicTo(0, 40, 0, 60, -120, 60);
    }

    path1 = AppUtils.ArrowPath.make(
      path: path1,
      tipLength: 5,
    );
    canvas.drawPath(path1, paint..color = Colors.blue.withAlpha(100));

    path2 = Path();
    if (currentOrientation == Orientation.portrait) {
      path2.moveTo(size.width * 0.36, size.height / 1.35);
      path2.relativeCubicTo(0, 0, -70, 0, -55, -110);
    } else {
      path2.moveTo(size.width * 0.41, size.height / 1.36);
      path2.relativeCubicTo(-40, 0, -100, 0, -100, -50);
    }

    path2 = AppUtils.ArrowPath.make(
      path: path2,
      tipLength: 5,
    );
    canvas.drawPath(path2, paint..color = Colors.blue.withAlpha(100));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => currTab;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    //Add the search term to the searchBloc.
    //The Bloc will then handle the searching and add the results to the searchResults stream.
    //This is the equivalent of submitting the search term to whatever search service you are using
    //InheritedBlocs.of(context).searchBloc.searchTerm.add(query);

    if (currTab == 'Search History') {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('consults')
                  .where('patient_id', isEqualTo: medicallUser.uid)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    heightFactor: 35,
                    child: Text("You have no doctor consult history yet.",
                        textAlign: TextAlign.center),
                  );
                }
                if (snapshot.data.documents.length > 0) {
                  userHasConsults = true;
                  var userDocuments = snapshot.data.documents;
                  List<Widget> historyList = [];
                  for (var i = 0; i < userDocuments.length; i++) {
                    if (userDocuments[i]
                        .data['provider']
                        .toLowerCase()
                        .contains(
                          query.toLowerCase(),
                        )) {
                      Timestamp timestamp = userDocuments[i].data['date'];
                      historyList.add(FlatButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(70),
                          onPressed: () {
                            Navigator.pushNamed(context, '/historyDetail',
                                arguments: {
                                  'documentId': userDocuments[i].documentID,
                                  'user': medicallUser,
                                  'patient_id':
                                      userDocuments[i].data['patient_id'],
                                  'provider_id':
                                      userDocuments[i].data['provider_id'],
                                  'from': 'patients',
                                  'isRouted': false,
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withAlpha(70)))),
                            child: ListTile(
                              dense: true,
                              isThreeLine: true,
                              title: Text(
                                '${userDocuments[i].data['provider'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[0].substring(1)} ${userDocuments[i].data['provider'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[1].substring(1)} ' +
                                    userDocuments[i].data['providerTitles'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              subtitle: Text(DateFormat('dd MMM h:mm a')
                                      .format(timestamp.toDate())
                                      .toString() +
                                  '\n' +
                                  userDocuments[i].data['type'].toString()),
                              trailing: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    userDocuments[i].data['state'].toString() ==
                                            'done'
                                        ? Icon(
                                            Icons.assignment_turned_in,
                                            color: Colors.green,
                                          )
                                        : userDocuments[i]
                                                    .data['state']
                                                    .toString() ==
                                                'in progress'
                                            ? Icon(
                                                Icons.assignment,
                                                color: Colors.blue,
                                              )
                                            : Icon(
                                                Icons.assignment_ind,
                                                color: Colors.amber,
                                              ),
                                    Text(
                                      userDocuments[i].data['state'].toString(),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                                onPressed: () {},
                              ),
                              leading: Icon(
                                Icons.account_circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withAlpha(170),
                                size: 50,
                              ),
                            ),
                          )));
                    }
                  }
                  return Column(children: historyList.toList());
                } else {
                  return Center(
                    heightFactor: 35,
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: Firestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    heightFactor: 35,
                    child: Text("You have no patient requests yet.",
                        textAlign: TextAlign.center),
                  );
                }
                if (snapshot.data.documents.length > 0) {
                  var userDocuments = snapshot.data.documents;
                  List<Widget> historyList = [];
                  for (var i = 0; i < userDocuments.length; i++) {
                    if (userDocuments[i].data['type'] == 'provider' &&
                        medicallUser.displayName !=
                            userDocuments[i].data['name'] &&
                        userDocuments[i].data['name'].toLowerCase().contains(
                              query.toLowerCase(),
                            )) {
                      //providers.add(userDocuments[i].data['name']);
                      historyList.add(Container(
                        height: 75,
                        child: ListTile(
                          dense: true,
                          title: Text(
                              '${userDocuments[i].data['name'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[0].substring(1)} ${userDocuments[i].data['name'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['name'].split(" ")[1].substring(1)}' +
                                  " " +
                                  userDocuments[i].data['titles']),
                          subtitle:
                              Text(userDocuments[i].data['address'].toString()),
                          trailing: FlatButton(
                            onPressed: () {
                              // setState(() {
                              //   _consult.provider =
                              //       userDocuments[i].data['name'];
                              //   _consult.providerTitles =
                              //       userDocuments[i].data['titles'];
                              //   _consult.providerDevTokens =
                              //       userDocuments[i].data['dev_tokens'];
                              //   _consult.providerId =
                              //       userDocuments[i].documentID;
                              //   _selectProvider(
                              //       userDocuments[i].data['name'],
                              //       userDocuments[i].data['titles']);
                              // });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.more_vert,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          leading: Icon(
                            Icons.account_circle,
                            size: 50,
                          ),
                        ),
                      ));
                    }
                  }
                  return Column(children: historyList.toList());
                } else {
                  return Center(
                    heightFactor: 35,
                    child: Text("You have no patient requests yet.",
                        textAlign: TextAlign.center),
                  );
                }
              }),
        ),
      );
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}
