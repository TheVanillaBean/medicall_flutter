import 'dart:convert';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/services/appbar_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String currTab = 'Search History';
Orientation currentOrientation;
bool userHasConsults = false;

class DoctorSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    medicallUser = userProvider.medicallUser;
    var _db = Provider.of<Database>(context, listen: false);
    currentOrientation = MediaQuery.of(context).orientation;
    currTab = "Search Doctors";
    String selectedProvider = '';
    String providerTitles = '';
    String providerProfilePic = '';
    ConsultData _consult = ConsultData();

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
                            padding: EdgeInsets.all(10),
                            width: 120,
                            child: PopupMenuButton(
                              itemBuilder: (context) {
                                var list = List<PopupMenuEntry<Object>>();
                                list.add(
                                  PopupMenuItem(
                                    child: Text("New Request"),
                                    value: 1,
                                  ),
                                );
                                list.add(
                                  PopupMenuDivider(
                                    height: 10,
                                  ),
                                );
                                list.add(
                                  PopupMenuItem(
                                    child: Text("Follow Up"),
                                    value: 1,
                                  ),
                                );
                                return list;
                              },
                              icon: Icon(
                                Icons.more_vert,
                                size: 30,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              offset: Offset.fromDirection(0.0, -20.0),
                              onSelected: (val) {
                                providerTitles =
                                    userDocuments[i].data['titles'];
                                selectedProvider =
                                    userDocuments[i].data['name'];
                                _consult.provider = selectedProvider;
                                _consult.providerProfilePic =
                                    userDocuments[i].data['profile_pic'];
                                setConsult(_consult, selectedProvider,
                                    providerTitles, providerProfilePic);
                                Navigator.of(context).pushNamed('/symptoms');
                              },
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

class CustomSearchDelegate extends SearchDelegate {
  String selectedProvider = '';
  String providerTitles = '';
  String providerProfilePic = '';
  ConsultData _consult = ConsultData();

  @override
  String get searchFieldLabel => currTab;
  @override
  List<Widget> buildActions(BuildContext context) {
    var _appBarState = Provider.of<AppBarState>(context, listen: false);
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          _appBarState.searchInput = '';
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    var _appBarState = Provider.of<AppBarState>(context, listen: false);
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        _appBarState.setShowAppBar(true);
        _appBarState.searchInput = '';
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
    var _db = Provider.of<Database>(context, listen: false);
    var _appBarState = Provider.of<AppBarState>(context, listen: false);
    _appBarState.searchInput = query;
    if (currTab == 'Search History') {
      _appBarState.setShowAppBar(false);
      return HistoryScreen();
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
                                PopupMenuButton(
                                  itemBuilder: (context) {
                                    var list = List<PopupMenuEntry<Object>>();
                                    list.add(
                                      PopupMenuItem(
                                        child: Text("New Request"),
                                        value: 1,
                                      ),
                                    );
                                    list.add(
                                      PopupMenuDivider(
                                        height: 10,
                                      ),
                                    );
                                    list.add(
                                      PopupMenuItem(
                                        child: Text("Follow Up"),
                                        value: 1,
                                      ),
                                    );
                                    return list;
                                  },
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  offset: Offset.fromDirection(0.0, -20.0),
                                  onSelected: (val) {
                                    providerTitles =
                                        userDocuments[i].data['titles'];
                                    selectedProvider =
                                        userDocuments[i].data['name'];
                                    _consult.provider = selectedProvider;
                                    _consult.providerProfilePic =
                                        userDocuments[i].data['profile_pic'];
                                    setConsult(_consult, selectedProvider,
                                        providerTitles, providerProfilePic);
                                    Navigator.of(context)
                                        .pushNamed('/symptoms');
                                  },
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
    final ThemeData theme = Theme.of(context).copyWith(
        brightness: Brightness.light,
        textTheme: TextTheme(title: TextStyle(color: Colors.white)),
        inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
            helperStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white)));
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

setConsult(
    _consult, selectedProvider, providerTitles, providerProfilePic) async {
  SharedPreferences _thisConsult = await SharedPreferences.getInstance();
  _consult.provider = selectedProvider;
  _consult.providerTitles = providerTitles;
  _consult.providerProfilePic = providerProfilePic;
  String currentConsultString = jsonEncode(_consult);
  await _thisConsult.setString("consult", currentConsultString);
}
