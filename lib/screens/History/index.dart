import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:flutter/painting.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/util/app_util.dart' as AppUtils;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final data;

  const HistoryScreen({Key key, @required this.data}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

String currTab = 'Search History';

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  //Tokens _tokens = Tokens();
  TabController controller;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> providers = [];
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    //_tokens.currentContext = context;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        title: TabBar(
          tabs: [
            Tab(
              text: 'History',
            ),
            Tab(
              text: 'Doctors',
            ),
          ],
          indicatorColor: Colors.white,
          labelStyle: TextStyle(
              fontSize: 16, letterSpacing: 1, fontWeight: FontWeight.w600),
          indicatorPadding: EdgeInsets.all(0),
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.blue.shade100,
          indicatorWeight: 1,
          labelPadding: EdgeInsets.all(0),
          onTap: (val) {
            if (val == 0) {
              currTab = 'Search History';
            } else {
              currTab = 'Search Doctors';
            }
          },
          controller: controller,
        ),
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
      drawer: DrawerMenu(
        data: {'user': medicallUser},
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Builder(builder: (BuildContext context) {
      //   return FloatingActionButton(
      //     child: Icon(
      //       CustomIcons.MedicallApp.logo_m,
      //       size: 35.0,
      //     ),
      //     onPressed: () {
      //       Scaffold.of(context).openDrawer();
      //     },
      //     backgroundColor: Color.fromRGBO(241, 100, 119, 0.8),
      //     foregroundColor: Colors.white,
      //   );
      // }),
      body: medicallUser.type == 'provider'
          ? TabBarView(
              // Add tabs as widgets
              children: <Widget>[
                //_buildTab("consults"),
                _buildTab("patients"),
              ],
              // set the controller
              controller: controller,
            )
          : TabBarView(
              controller: controller,
              children: <Widget>[
                _buildTab("consults"),
                _buildTab("doctors"),
              ],
            ),
    );
  }

  _buildTab(questions) {
    if (questions == "consults") {
      return Scaffold(
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('consults')
                  .where('patient_id', isEqualTo: medicallUser.id)
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
                  var userDocuments = snapshot.data.documents;
                  List<Widget> historyList = [];
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
                                'from': 'consults',
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
                  return Center(
                    heightFactor: 35,
                    child: Text("You have no doctor consult history yet.",
                        textAlign: TextAlign.center),
                  );
                }
              }),
        ),
      );
    }
    if (questions == "patients") {
      return Scaffold(
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('consults')
                  .where('provider_id', isEqualTo: medicallUser.id)
                  .orderBy('date', descending: true)
                  .snapshots(),
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
    if (questions == "doctors") {
      return Scaffold(
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
                      providers.add(userDocuments[i].data['name']);
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
    path.moveTo(size.width * 0.60, size.height * 0.09);
    path.relativeCubicTo(15, 0, size.width * 0.19, 10, size.width * 0.19, 70);
    path = AppUtils.ArrowPath.make(
      path: path,
      tipLength: 5,
    );
    canvas.drawPath(path, paint..color = Colors.blue.withAlpha(100));

    path1 = Path();
    path1.moveTo(size.width * 0.79, size.height / 1.5);
    path1.relativeCubicTo(0, 10, 0, 60, -60, 60);
    path1 = AppUtils.ArrowPath.make(
      path: path1,
      tipLength: 5,
    );
    canvas.drawPath(path1, paint..color = Colors.blue.withAlpha(100));

    path2 = Path();
    path2.moveTo(size.width * 0.39, size.height / 1.15);
    path2.relativeCubicTo(0, 0, -60, 0, -55, -62);
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
                  .where('patient_id', isEqualTo: medicallUser.id)
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
                                  'from': 'consults',
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
                    child: Text("You have no doctor consult history yet.",
                        textAlign: TextAlign.center),
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
