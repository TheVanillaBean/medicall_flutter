import 'dart:convert';

import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/services/appbar_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_history_state.dart';
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
    var _appBarState = Provider.of<AppBarState>(context);

    UserHistoryState _userHistory = Provider.of<UserHistoryState>(context);
    currentOrientation = MediaQuery.of(context).orientation;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerMenu(),
      appBar: _appBarState.getShowAppBar()
          ? AppBar(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      DropdownButtonHideUnderline(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          PopupMenuButton(
                            offset: Offset(0.0, 80.0),
                            icon: Icon(Icons.sort),
                            onSelected: (val) {
                              _appBarState.sortBy = val;
                              _userHistory.setUserHistory(_db.userHistory);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                child: Text(
                                  "Newest",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text(
                                  "Alphabetical",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 2
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Text(
                                  "New Status",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 3
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                              PopupMenuItem(
                                value: 4,
                                child: Text(
                                  "In Progress",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 4
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                              PopupMenuItem(
                                value: 5,
                                child: Text(
                                  "Needs Payment",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 5
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                              PopupMenuItem(
                                value: 6,
                                child: Text(
                                  "Done Status",
                                  style: TextStyle(
                                      color: _appBarState.sortBy == 6
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
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
                  ),
                ),
                userHasConsults
                    ? showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(),
                      )
                    : SizedBox(
                        width: 0,
                      ),
              ],
              elevation:
                  Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
            )
          : null,
      body: _buildTab("consults", _db, context),
    );
  }

  _buildTab(questions, db, context) {
    List<Widget> _historyList;
    MedicallUser _medicallUser =
        Provider.of<UserProvider>(context).medicallUser;
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    AppBarState _appBarState = Provider.of<AppBarState>(context);
    UserHistoryState _userHistoryState = Provider.of<UserHistoryState>(context);
    //_userHistory.setUserHistory(db.userHistory);
    return FutureBuilder(
      future: _userHistoryState.getUserHistory(_medicallUser,
          _appBarState.searchInput, _appBarState.sortBy, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //_userHistory.setUserHistory(snapshot.data);
          //_userHistory.setUserHistory(snapshot.data);
          return SingleChildScrollView(
            child: Container(
              height: 800,
              child: ListView.builder(
                  itemCount: _userHistoryState.userHistory.length,
                  itemBuilder: (context, index) {
                    if (_userHistoryState.userHistory.length > 0) {
                      _historyList = [];
                      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                          _userHistoryState.userHistory[index].data['date']
                              .millisecondsSinceEpoch);
                      _historyList.add(FlatButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(70),
                          onPressed: () {
                            //clear current snap remove this and previous consult data is displayed in detailed history
                            db.consultSnapshot = null;
                            db.currConsultId =
                                _userHistoryState.userHistory[index].documentID;
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
                                    ? '${_userHistoryState.userHistory[index].data['provider'].split(" ")[0][0].toUpperCase()}${_userHistoryState.userHistory[index].data['provider'].split(" ")[0].substring(1)} ${_userHistoryState.userHistory[index].data['provider'].split(" ")[1][0].toUpperCase()}${_userHistoryState.userHistory[index].data['provider'].split(" ")[1].substring(1)} ' +
                                        ' ' +
                                        _userHistoryState.userHistory[index]
                                            .data['providerTitles']
                                    : '${_userHistoryState.userHistory[index].data['patient'].split(" ")[0][0].toUpperCase()}${_userHistoryState.userHistory[index].data['patient'].split(" ")[0].substring(1)} ${_userHistoryState.userHistory[index].data['patient'].split(" ")[1][0].toUpperCase()}${_userHistoryState.userHistory[index].data['patient'].split(" ")[1].substring(1)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: Theme.of(context).primaryColor),
                              ),
                              subtitle: Text(DateFormat('dd MMM h:mm a')
                                      .format(timestamp)
                                      .toString() +
                                  '\n' +
                                  _userHistoryState
                                      .userHistory[index].data['type']
                                      .toString()),
                              trailing: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _userHistoryState.userHistory[index]
                                                .data['state']
                                                .toString() ==
                                            'prescription paid'
                                        ? Icon(
                                            CustomIcons.MedicallIcons.ambulance,
                                            color: Colors.indigo,
                                          )
                                        : _userHistoryState.userHistory[index]
                                                    .data['state']
                                                    .toString() ==
                                                'prescription waiting'
                                            ? Icon(
                                                CustomIcons
                                                    .MedicallIcons.medkit,
                                                color: Colors.green,
                                              )
                                            : _userHistoryState
                                                        .userHistory[index]
                                                        .data['state']
                                                        .toString() ==
                                                    'done'
                                                ? Icon(
                                                    Icons.assignment_turned_in,
                                                    color: Colors.green,
                                                  )
                                                : _userHistoryState
                                                            .userHistory[index]
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
                                        _userHistoryState
                                            .userHistory[index].data['state']
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
                                      backgroundColor:
                                          Colors.grey.withAlpha(100),
                                      child: _userHistoryState
                                                  .userHistory[index].data
                                                  .containsKey(
                                                      'provider_profile') &&
                                              _userHistoryState
                                                          .userHistory[index]
                                                          .data[
                                                      'provider_profile'] !=
                                                  null
                                          ? ClipOval(
                                              child: _extImageProvider
                                                  .returnNetworkImage(
                                                      _userHistoryState
                                                              .userHistory[index]
                                                              .data[
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
                                      backgroundColor:
                                          Colors.grey.withAlpha(100),
                                      child: _userHistoryState
                                                  .userHistory[index]
                                                  .data['patient_profile'] !=
                                              null
                                          ? ClipOval(
                                              child: _extImageProvider
                                                  .returnNetworkImage(
                                                _userHistoryState
                                                    .userHistory[index]
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
                                height: currentOrientation ==
                                        Orientation.portrait
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Icon(
                                                CustomIcons
                                                    .MedicallIcons.live_help,
                                                size: 60,
                                                color: Colors.purple
                                                    .withAlpha(140),
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
                                                CustomIcons
                                                    .MedicallIcons.medkit,
                                                size: 60,
                                                color: Colors.redAccent
                                                    .withAlpha(200),
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
                                                color:
                                                    Colors.green.withAlpha(200),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                      String
                                                          currentConsultString =
                                                          jsonEncode(
                                                              ConsultData());
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
                                                          color:
                                                              Theme.of(context)
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
                                                      Navigator.of(context)
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
                                                          color:
                                                              Theme.of(context)
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
                                height: currentOrientation ==
                                        Orientation.portrait
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Icon(
                                                CustomIcons
                                                    .MedicallIcons.live_help,
                                                size: 60,
                                                color: Colors.purple
                                                    .withAlpha(140),
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
                                                CustomIcons
                                                    .MedicallIcons.medkit,
                                                size: 60,
                                                color: Colors.redAccent
                                                    .withAlpha(200),
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
                                                color:
                                                    Colors.green.withAlpha(200),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      margin:
                                          EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withAlpha(50),
                                        border: Border.all(
                                            color: Colors.grey.withAlpha(100),
                                            style: BorderStyle.solid,
                                            width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      child: Text(
                                        'You will now show up in our network when patients request for care. Once a patient selects you, a record of that request will show up here. By tapping on a request once it shows up in "History" you will be able to see detailed answers/photos from the patient, chat directly, and provide a prescription to them if needed.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
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
                  }),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
