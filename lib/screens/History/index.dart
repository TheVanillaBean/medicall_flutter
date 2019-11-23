import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final data;

  const HistoryScreen({Key key, @required this.data}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  //Tokens _tokens = Tokens();
  TabController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 1, vsync: this);
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
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        title: Text(
          'Patients',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        // bottom: medicallUser.type == 'provider'
        //     ? TabBar(
        //         indicatorColor: Colors.white,
        //         tabs: <Tab>[
        //           // Tab(
        //           //   // set icon to the tab
        //           //   text: 'Doctor Consults',
        //           //   icon: Icon(Icons.local_pharmacy),
        //           // ),
        //           Tab(text: '', ),
        //         ],
        //         // setup the controller
        //         controller: controller,
        //       )
        //     : null,
        //new, in progress, finished
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
          : SingleChildScrollView(
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('consults')
                      .where('patient_id', isEqualTo: medicallUser.id)
                      .orderBy('date', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        heightFactor: 40,
                        child: Text("You have no consult history yet.",
                            textAlign: TextAlign.center),
                      );
                    } else {
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        userDocuments[i]
                                                    .data['state']
                                                    .toString() ==
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
                                          userDocuments[i]
                                              .data['state']
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .primaryColor),
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
                        return Column(children: historyList);
                      } else {
                        return Center(
                          heightFactor: 40,
                          child: Text("You have no consult history yet.",
                              textAlign: TextAlign.center),
                        );
                      }
                    }
                  }),
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
  }
}
