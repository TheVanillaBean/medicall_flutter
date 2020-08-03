import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/index.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String currTab = 'Search History';
Orientation currentOrientation;
bool userHasConsults = false;

class DoctorSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    User medicallUser = userProvider.user;
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
                delegate: CustomSearchDelegate(medicallUser: medicallUser),
              );
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: _db.getAllProviders(),
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
                  if (medicallUser.fullName != userDocuments[i].data['name']) {
                    historyList.add(ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      title: Text(
                        StringUtils.getFormattedProviderName(
                          firstName: userDocuments[i].data['first_name'],
                          lastName: userDocuments[i].data['last_name'],
                          titles: userDocuments[i].data['titles'],
                        ),
                      ),
                      subtitle:
                          Text(userDocuments[i].data['address'].toString()),
                      leading: Icon(
                        Icons.account_circle,
                        size: 50,
                      ),
                      trailing: PopupMenuButton(
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
                          providerTitles = userDocuments[i].data['titles'];
                          selectedProvider = userDocuments[i].data['name'];
                          _consult.provider = selectedProvider;
                          _consult.providerProfilePic =
                              userDocuments[i].data['profile_pic'];
                          setConsult(_consult, selectedProvider, providerTitles,
                              providerProfilePic);
                          Navigator.of(context).pushNamed('/symptoms');
                        },
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

  User medicallUser = PatientUser();

  CustomSearchDelegate({this.medicallUser});

  @override
  String get searchFieldLabel => currTab;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          //_userHistoryState.searchInput = '';
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //var _userHistoryState = Provider.of<HistoryState>(context, listen: false);
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // _userHistoryState.setShowAppBar(true);
        // _userHistoryState.searchInput = '';
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
    // var _userHistoryState = Provider.of<HistoryState>(context, listen: false);
    //_userHistoryState.searchInput = query;
    if (currTab == 'Search History') {
      //_userHistoryState.setShowAppBar(false);
      return HistoryScreen.create(context, false, query);
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
                        medicallUser.fullName !=
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
                            onPressed: () {},
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
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Column();
  }
}

setConsult(
    _consult, selectedProvider, providerTitles, providerProfilePic) async {
  _consult.provider = selectedProvider;
  _consult.providerTitles = providerTitles;
  _consult.providerProfilePic = providerProfilePic;
}
