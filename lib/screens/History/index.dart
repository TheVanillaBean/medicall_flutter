import 'dart:convert';

import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'doctorSearch.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _db = Provider.of<Database>(context);

    currentOrientation = MediaQuery.of(context).orientation;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerMenu(),
      appBar: AppBar(
        centerTitle: true,
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
      body: _buildTab("consults", _db, context),
    );
  }

  _buildTab(questions, db, context) {
    List<Widget> _historyList;
    MedicallUser _medicallUser =
        Provider.of<UserProvider>(context).medicallUser;
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    return SingleChildScrollView(
      child: FutureBuilder(
          future: db.getUserHistory(_medicallUser),
          builder: (
            BuildContext context,
            AsyncSnapshot<void> snapshot,
          ) {
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
                else if (db.userHistory.length > 0) {
                  _historyList = [];
                  for (var i = 0; i < db.userHistory.length; i++) {
                    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                        db.userHistory[i].data['date'] * 1000);
                    _historyList.add(FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                        onPressed: () {
                          //clear current snap remove this and previous consult data is displayed in detailed history
                          db.consultSnapshot = null;
                          db.currConsultId = db.userHistory[i].documentID;
                          Navigator.of(context)
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
                              _medicallUser.type == 'patient'
                                  ? '${db.userHistory[i].data['provider'].split(" ")[0][0].toUpperCase()}${db.userHistory[i].data['provider'].split(" ")[0].substring(1)} ${db.userHistory[i].data['provider'].split(" ")[1][0].toUpperCase()}${db.userHistory[i].data['provider'].split(" ")[1].substring(1)} ' +
                                      ' ' +
                                      db.userHistory[i].data['providerTitles']
                                  : '${db.userHistory[i].data['patient'].split(" ")[0][0].toUpperCase()}${db.userHistory[i].data['patient'].split(" ")[0].substring(1)} ${db.userHistory[i].data['patient'].split(" ")[1][0].toUpperCase()}${db.userHistory[i].data['patient'].split(" ")[1].substring(1)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Theme.of(context).primaryColor),
                            ),
                            subtitle: Text(DateFormat('dd MMM h:mm a')
                                    .format(timestamp)
                                    .toString() +
                                '\n' +
                                db.userHistory[i].data['type'].toString()),
                            trailing: FlatButton(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  db.userHistory[i].data['state'].toString() ==
                                          'prescription paid'
                                      ? Icon(
                                          CustomIcons.MedicallIcons.ambulance,
                                          color: Colors.indigo,
                                        )
                                      : db.userHistory[i].data['state']
                                                  .toString() ==
                                              'prescription waiting'
                                          ? Icon(
                                              CustomIcons.MedicallIcons.medkit,
                                              color: Colors.green,
                                            )
                                          : db.userHistory[i].data['state']
                                                      .toString() ==
                                                  'done'
                                              ? Icon(
                                                  Icons.assignment_turned_in,
                                                  color: Colors.green,
                                                )
                                              : db.userHistory[i].data['state']
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
                                      db.userHistory[i].data['state']
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
                            leading: _medicallUser.type == 'patient'
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.withAlpha(100),
                                    child: db.userHistory[i].data.containsKey(
                                                'provider_profile') &&
                                            db.userHistory[i]
                                                    .data['provider_profile'] !=
                                                null
                                        ? ClipOval(
                                            child: _extImageProvider
                                                .returnNetworkImage(
                                                    db.userHistory[i].data[
                                                        'provider_profile'],
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover),
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.withAlpha(100),
                                    child: db.userHistory[i]
                                                .data['patient_profile'] !=
                                            null
                                        ? ClipOval(
                                            child: _extImageProvider
                                                .returnNetworkImage(
                                              db.userHistory[i]
                                                  .data['patient_profile'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.account_circle,
                                            size: 40,
                                            color: Colors.grey,
                                          )),
                          ),
                        )));
                  }
                  return Column(children: _historyList.toList());
                } else {
                  if (_medicallUser.type == 'patient') {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                            CustomIcons
                                                .MedicallIcons.clipboard_1,
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
                                            CustomIcons
                                                .MedicallIcons.stethoscope,
                                            size: 60,
                                            color: Colors.blueAccent
                                                .withAlpha(200),
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
                                                  SharedPreferences
                                                      _thisConsult =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  String currentConsultString =
                                                      jsonEncode(ConsultData());
                                                  await _thisConsult.setString(
                                                      "consult",
                                                      currentConsultString);
                                                  Navigator.of(context)
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
                                                  Navigator.of(context).push(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(
                                    height: 50,
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
                                          Text('Receive patient \nrequests',
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
                                            'Provide\nprescription\nif needed',
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
                                            CustomIcons
                                                .MedicallIcons.clipboard_1,
                                            size: 60,
                                            color: Colors.green.withAlpha(200),
                                          ),
                                          Text(
                                            'View request\ndetails',
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
                                            CustomIcons
                                                .MedicallIcons.stethoscope,
                                            size: 60,
                                            color: Colors.blueAccent
                                                .withAlpha(200),
                                          ),
                                          Text(
                                            'Review &\n provide diagnosis',
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
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Connect with patients now!',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(50),
                                    border: Border.all(
                                        color: Colors.grey.withAlpha(100),
                                        style: BorderStyle.solid,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Text(
                                    'You will now show up in our network when patients request for care. Once a patient selects you, a record of that request will show up here. By tapping on a request once it shows up in "History" you will be able to see detailed answers/photos from the patient, chat directly, and provide a prescription to them if needed.',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }
            }
          }),
    );
  }
}
