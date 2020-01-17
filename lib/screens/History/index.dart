import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'doctorSearch.dart';

List<String> providers = [];
List<Widget> historyList = [];
MedicallUser medicallUser;
var userDocuments;

class HistoryScreen extends StatelessWidget {
  final _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: '_historyScaffoldkey');
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
    medicallUser = Provider.of<AuthBase>(context).medicallUser;

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
                  heightFactor: 16,
                  child: CircularProgressIndicator(),
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
                        GlobalNavigatorKey.key.currentState
                            .pushNamed('/historyDetail', arguments: {
                          'documentId': userDocuments[i].documentID,
                          'user': medicallUser,
                          'patient_id': userDocuments[i].data['patient_id'],
                          'provider_id': userDocuments[i].data['provider_id'],
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
                                color: Theme.of(context).primaryColor),
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
                            color:
                                Theme.of(context).primaryColor.withAlpha(170),
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
                                              GlobalNavigatorKey
                                                  .key.currentState
                                                  .pushReplacementNamed(
                                                      '/doctors');
                                            },
                                            color: Colors.green,
                                            child: Text(
                                              'Start',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                          ),
                                          Text('  - or -  ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )),
                                          FlatButton(
                                            onPressed: () {
                                              GlobalNavigatorKey
                                                  .key.currentState
                                                  .push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DoctorSearch()),
                                              );
                                            },
                                            color: Colors.blueAccent,
                                            child: Text(
                                              'Find Doctor',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
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
                            GlobalNavigatorKey.key.currentState
                                .pushNamed('/historyDetail', arguments: {
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
                                userDocuments[i].data['patient'].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: Theme.of(context).primaryColor),
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
                                    .primaryColor
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
