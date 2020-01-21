import 'dart:convert';

import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctorSearch.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;

List<String> providers = [];
List<Widget> historyList = [];
MedicallUser medicallUser;
var userDocuments;

class HistoryScreen extends StatelessWidget {
  final _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: '_historyScaffoldkey');

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
      body: _buildTab("consults"),
    );
  }

  _buildTab(questions) {
    var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
    currentOrientation =
        MediaQuery.of(GlobalNavigatorKey.key.currentContext).orientation;
    return SingleChildScrollView(
      child: FutureBuilder(
          future: auth.getUserHistory(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      heightFactor: 10,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ],
                );
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else if (auth.userHistory.length > 0) {
                  historyList = [];
                  for (var i = 0; i < auth.userHistory.length; i++) {
                    Timestamp timestamp = auth.userHistory[i].data['date'];
                    historyList.add(FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                        onPressed: () {
                          auth.currConsultId = auth.userHistory[i].documentID;
                          GlobalNavigatorKey.key.currentState
                              .pushNamed('/historyDetail', arguments: {
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
                              medicallUser.type == 'patient'
                                  ? auth.userHistory[i].data['provider'] +
                                      ' ' +
                                      auth.userHistory[i].data['providerTitles']
                                  : auth.userHistory[i].data['patient'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Theme.of(context).primaryColor),
                            ),
                            subtitle: Text(DateFormat('dd MMM h:mm a')
                                    .format(timestamp.toDate())
                                    .toString() +
                                '\n' +
                                auth.userHistory[i].data['type'].toString()),
                            trailing: FlatButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  auth.userHistory[i].data['state']
                                              .toString() ==
                                          'prescription paid'
                                      ? Icon(
                                          CustomIcons.MedicallIcons.ambulance,
                                          color: Colors.indigo,
                                        )
                                      : auth.userHistory[i].data['state']
                                                  .toString() ==
                                              'prescription waiting'
                                          ? Icon(
                                              CustomIcons.MedicallIcons.medkit,
                                              color: Colors.green,
                                            )
                                          : auth.userHistory[i].data['state']
                                                      .toString() ==
                                                  'done'
                                              ? Icon(
                                                  Icons.assignment_turned_in,
                                                  color: Colors.green,
                                                )
                                              : auth.userHistory[i]
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
                                  Container(
                                    width: 80,
                                    child: Text(
                                      auth.userHistory[i].data['state']
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  )
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
                                          color:
                                              Colors.redAccent.withAlpha(200),
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
                                          color:
                                              Colors.blueAccent.withAlpha(200),
                                        ),
                                        Text(
                                          'Doctor reviews &\n provides diagnosis',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                        currentOrientation ==
                                                Orientation.portrait
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
                                              onPressed: () async {
                                                SharedPreferences _thisConsult =
                                                    await SharedPreferences
                                                        .getInstance();
                                                String currentConsultString =
                                                    jsonEncode(ConsultData());
                                                await _thisConsult.setString(
                                                    "consult",
                                                    currentConsultString);
                                                GlobalNavigatorKey
                                                    .key.currentState
                                                    .pushReplacementNamed(
                                                        '/symptoms');
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
            }
          }),
    );
  }
}
