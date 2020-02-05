import 'dart:convert';

import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/screens/History/appbar_state.dart';
import 'package:Medicall/screens/History/user_history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Medicall/util/app_util.dart' as AppUtils;
import 'doctorSearch.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Database _db = Provider.of<Database>(context);
    AppBarState _appBarState = Provider.of<AppBarState>(context);
    UserHistoryState _userHistory = Provider.of<UserHistoryState>(context);
    ScreenUtil.init(context);
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
    return StreamBuilder(
      stream: _userHistoryState.getUserHistorySnapshots(_medicallUser,
          _appBarState.searchInput, _appBarState.sortBy, context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.data.documents.length == 0) {
              return SingleChildScrollView(
                  child: _medicallUser.type == 'patient'
                      ? Stack(
                          children: <Widget>[
                            Container(
                              height: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? ScreenUtil.screenHeightDp -
                                      80 -
                                      ScreenUtil.statusBarHeight
                                  : ScreenUtil.screenHeightDp -
                                      50 -
                                      ScreenUtil.statusBarHeight,
                              width: ScreenUtil.screenWidth,
                              child: CustomPaint(
                                foregroundPainter: CurvePainter(),
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 10
                                  : 0,
                              right: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenWidthDp) / 5
                                  : (ScreenUtil.screenWidthDp - 260) / 2,
                              child: Text(
                                'Connect with local doctors now!',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 6
                                  : 25,
                              right: (ScreenUtil.screenWidthDp - 85) / 2,
                              child: Column(
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
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 2.5
                                  : (ScreenUtil.screenHeightDp - 80) / 2.5,
                              left: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 30
                                  : (ScreenUtil.screenWidthDp) * 0.1,
                              child: Column(
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
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 2.5
                                  : (ScreenUtil.screenHeightDp - 80) / 2.5,
                              right: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 30
                                  : (ScreenUtil.screenWidthDp) * 0.1,
                              child: Column(
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
                                        fontSize: 12, color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 1.5
                                  : (ScreenUtil.screenHeightDp) / 1.8,
                              left: (ScreenUtil.screenWidthDp - 100) / 2,
                              child: Column(
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
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            ScreenUtil.mediaQueryData.orientation ==
                                    Orientation.portrait
                                ? Positioned(
                                    top: ScreenUtil.screenHeightDp / 2.7,
                                    left: ScreenUtil.screenWidthDp / 2.6,
                                    child: Column(
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
                                  )
                                : Positioned(
                                    top: (ScreenUtil.screenHeightDp - 120) / 2,
                                    left: (ScreenUtil.screenWidthDp - 210) / 2,
                                    child: Row(
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
                                  ),
                          ],
                        )
                      : Stack(
                          children: <Widget>[
                            Container(
                              height: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? ScreenUtil.screenHeightDp -
                                      80 -
                                      ScreenUtil.statusBarHeight
                                  : ScreenUtil.screenHeightDp -
                                      50 -
                                      ScreenUtil.statusBarHeight,
                              width: ScreenUtil.screenWidth,
                              child: CustomPaint(
                                foregroundPainter: CurvePainter(),
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 10
                                  : 0,
                              right: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenWidthDp) / 5
                                  : (ScreenUtil.screenWidthDp - 260) / 2,
                              child: Column(
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
                                  Container(
                                    width: ScreenUtil.screenWidth - 20,
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
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 6
                                  : 25,
                              right: (ScreenUtil.screenWidthDp - 85) / 2,
                              child: Column(
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
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 2.5
                                  : (ScreenUtil.screenHeightDp - 80) / 2.5,
                              left: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 30
                                  : (ScreenUtil.screenWidthDp) * 0.1,
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    CustomIcons.MedicallIcons.medkit,
                                    size: 60,
                                    color: Colors.redAccent.withAlpha(200),
                                  ),
                                  Text(
                                    'Provide\nprescription\nif needed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 2.5
                                  : (ScreenUtil.screenHeightDp - 80) / 2.5,
                              right: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? 30
                                  : (ScreenUtil.screenWidthDp) * 0.1,
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    CustomIcons.MedicallIcons.clipboard_1,
                                    size: 60,
                                    color: Colors.green.withAlpha(200),
                                  ),
                                  Text(
                                    'View request\ndetails',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: ScreenUtil.mediaQueryData.orientation ==
                                      Orientation.portrait
                                  ? (ScreenUtil.screenHeightDp) / 1.5
                                  : (ScreenUtil.screenHeightDp) / 1.8,
                              left: (ScreenUtil.screenWidthDp - 100) / 2,
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    CustomIcons.MedicallIcons.stethoscope,
                                    size: 60,
                                    color: Colors.blueAccent.withAlpha(200),
                                  ),
                                  Text(
                                    'Review &\n provide diagnosis',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ));
            }
            var userHistory = [];
            if (snapshot.data.documents != null) {
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                if (!userHistory.contains(snapshot.data.documents[i])) {
                  if (_appBarState.searchInput.length > 0) {
                    if (snapshot.data.documents[i].data['patient']
                            .toLowerCase()
                            .contains(
                              _appBarState.searchInput.toLowerCase(),
                            ) ||
                        snapshot.data.documents[i].data['provider']
                            .toLowerCase()
                            .contains(
                              _appBarState.searchInput.toLowerCase(),
                            ) ||
                        snapshot.data.documents[i].data['state']
                            .toLowerCase()
                            .contains(
                              _appBarState.searchInput.toLowerCase(),
                            ) ||
                        snapshot.data.documents[i].data['type']
                            .toLowerCase()
                            .contains(
                              _appBarState.searchInput.toLowerCase(),
                            )) {
                      userHistory.add(snapshot.data.documents[i]);
                    }
                  } else {
                    userHistory.add(snapshot.data.documents[i]);
                  }
                }
              }
            }
            return SingleChildScrollView(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: ScreenUtil.screenHeight,
                        minHeight: ScreenUtil.screenHeight),
                    child: ListView.builder(
                        itemCount: userHistory.length,
                        itemBuilder: (context, index) {
                          _historyList = [];
                          DateTime timestamp =
                              DateTime.fromMillisecondsSinceEpoch(snapshot
                                  .data
                                  .documents[index]
                                  .data['date']
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
                                    userHistory[index].documentID;
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
                                        ? '${userHistory[index].data['provider'].split(" ")[0][0].toUpperCase()}${userHistory[index].data['provider'].split(" ")[0].substring(1)} ${userHistory[index].data['provider'].split(" ")[1][0].toUpperCase()}${userHistory[index].data['provider'].split(" ")[1].substring(1)} ' +
                                            ' ' +
                                            userHistory[index]
                                                .data['providerTitles']
                                        : '${userHistory[index].data['patient'].split(" ")[0][0].toUpperCase()}${userHistory[index].data['patient'].split(" ")[0].substring(1)} ${userHistory[index].data['patient'].split(" ")[1][0].toUpperCase()}${userHistory[index].data['patient'].split(" ")[1].substring(1)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  subtitle: userHistory[index].data['type'] !=
                                          'Lesion'
                                      ? Text(DateFormat('dd MMM h:mm a')
                                              .format(timestamp)
                                              .toString() +
                                          '\n' +
                                          userHistory[index]
                                              .data['type']
                                              .toString())
                                      : Text(DateFormat('dd MMM h:mm a')
                                              .format(timestamp)
                                              .toString() +
                                          '\n' +
                                          'Spot'),
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
                                        userHistory[index]
                                                    .data['state']
                                                    .toString() ==
                                                'prescription paid'
                                            ? Icon(
                                                CustomIcons
                                                    .MedicallIcons.ambulance,
                                                color: Colors.indigo,
                                              )
                                            : userHistory[index]
                                                        .data['state']
                                                        .toString() ==
                                                    'prescription waiting'
                                                ? Icon(
                                                    CustomIcons
                                                        .MedicallIcons.medkit,
                                                    color: Colors.green,
                                                  )
                                                : userHistory[index]
                                                            .data['state']
                                                            .toString() ==
                                                        'done'
                                                    ? Icon(
                                                        Icons
                                                            .assignment_turned_in,
                                                        color: Colors.green,
                                                      )
                                                    : snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data['state']
                                                                .toString() ==
                                                            'in progress'
                                                        ? Icon(
                                                            Icons.assignment,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .assignment_ind,
                                                            color: Colors.amber,
                                                          ),
                                        Container(
                                          width: 80,
                                          child: Text(
                                            userHistory[index]
                                                .data['state']
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .primaryColor),
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
                                          child: snapshot.data.documents[index]
                                                      .data
                                                      .containsKey(
                                                          'provider_profile') &&
                                                  userHistory[index].data[
                                                          'provider_profile'] !=
                                                      null
                                              ? ClipOval(
                                                  child: _extImageProvider
                                                      .returnNetworkImage(
                                                          snapshot
                                                                  .data
                                                                  .documents[index]
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
                                          child: userHistory[index].data[
                                                          'patient_profile'] !=
                                                      null &&
                                                  snapshot
                                                          .data
                                                          .documents[index]
                                                          .data[
                                                              'patient_profile']
                                                          .length >
                                                      0
                                              ? ClipOval(
                                                  child: _extImageProvider
                                                      .returnNetworkImage(
                                                    userHistory[index].data[
                                                        'patient_profile'],
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
                        })));
        }
      },
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

    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path.moveTo(size.width * 0.6, size.height * 0.25);
      path.relativeCubicTo(10, 0, size.width * 0.26, 0, size.width * 0.25, 120);
    } else {
      path.moveTo(size.width * 0.57, size.height * 0.15);
      path.relativeCubicTo(40, 0, size.width * 0.28, 0, size.width * 0.28, 75);
    }
    path = AppUtils.ArrowPath.make(
      path: path,
      tipLength: 5,
    );
    canvas.drawPath(path, paint..color = Colors.blue.withAlpha(100));

    path1 = Path();
    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path1.moveTo(size.width * 0.85, size.height / 1.55);
      path1.relativeCubicTo(0, 60, 0, 130, -80, 130);
    } else {
      path1.moveTo(size.width * 0.85, size.height / 1.45);
      path1.relativeCubicTo(0, 10, 0, 60, -160, 60);
    }

    path1 = AppUtils.ArrowPath.make(
      path: path1,
      tipLength: 5,
    );
    canvas.drawPath(path1, paint..color = Colors.blue.withAlpha(100));

    path2 = Path();
    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path2.moveTo(size.width * 0.35, size.height / 1.16);
      path2.relativeCubicTo(0, 0, -80, 0, -70, -125);
    } else {
      path2.moveTo(size.width * 0.4, size.height / 1.15);
      path2.relativeCubicTo(-40, 0, -160, 0, -160, -60);
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
