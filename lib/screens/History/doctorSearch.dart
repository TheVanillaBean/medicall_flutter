import 'dart:convert';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/util/app_util.dart' as AppUtils;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currTab = 'Search History';
Orientation currentOrientation;
bool userHasConsults = false;

class DoctorSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    medicallUser = userProvider.medicallUser;
    var _db = Provider.of<Database>(context);
    currentOrientation = MediaQuery.of(context).orientation;
    currTab = "Search Doctors";
    String selectedProvider = '';
    String providerTitles = '';
    String providerProfilePic = '';
    ConsultData _consult = ConsultData();

    setConsult() async {
      SharedPreferences _thisConsult = await SharedPreferences.getInstance();
      _consult.provider = selectedProvider;
      _consult.providerTitles = providerTitles;
      _consult.providerProfilePic = providerProfilePic;
      String currentConsultString = jsonEncode(_consult);
      await _thisConsult.setString("consult", currentConsultString);
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
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
            stream: _db.getAllUsers(),
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
                              child: DropdownButton(
                                isExpanded: true,
                                icon: Icon(Icons.more_vert),
                                items: [
                                  DropdownMenuItem(
                                    value: 'New Request',
                                    child: GestureDetector(
                                      onTap: () {
                                        providerTitles =
                                            userDocuments[i].data['titles'];
                                        selectedProvider =
                                            userDocuments[i].data['name'];
                                        _consult.provider = selectedProvider;
                                        _consult.providerTitles =
                                            providerTitles;
                                        _consult.providerProfilePic =
                                            userDocuments[i]
                                                .data['profile_pic'];
                                        setConsult();
                                        Navigator.of(context)
                                            .pushNamed('/symptoms');
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
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
                                  ),
                                  DropdownMenuItem(
                                    value: 'Follow Up',
                                    child: GestureDetector(
                                      onTap: () {
                                        providerTitles =
                                            userDocuments[i].data['titles'];
                                        selectedProvider =
                                            userDocuments[i].data['name'];
                                        _consult.provider = selectedProvider;
                                        _consult.providerProfilePic =
                                            userDocuments[i]
                                                .data['profile_pic'];
                                        setConsult();
                                        Navigator.of(context)
                                            .pushNamed('/symptoms');
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
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
                                  ),
                                ],
                                onChanged: (String newVal) {},
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
      path1.moveTo(size.width * 0.78, size.height / 1.78);
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
    var _db = Provider.of<Database>(context);
    if (currTab == 'Search History') {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: FutureBuilder(
              future: _db.getUserHistory(medicallUser),
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
                      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                          userDocuments[i].data['date'].millisecondsSinceEpoch);
                      historyList.add(FlatButton(
                          padding: EdgeInsets.all(0),
                          splashColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(70),
                          onPressed: () {
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
                                '${userDocuments[i].data['provider'].split(" ")[0][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[0].substring(1)} ${userDocuments[i].data['provider'].split(" ")[1][0].toUpperCase()}${userDocuments[i].data['provider'].split(" ")[1].substring(1)} ' +
                                    userDocuments[i].data['providerTitles'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: Theme.of(context).primaryColor),
                              ),
                              subtitle: Text(DateFormat('dd MMM h:mm a')
                                      .format(timestamp)
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
              stream: _db.getAllUsers(),
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
                                  color: Theme.of(context).primaryColor,
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
