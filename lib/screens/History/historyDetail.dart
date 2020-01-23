import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'buildDetailTab.dart';

class HistoryDetailScreen extends StatefulWidget {
  HistoryDetailScreen({Key key}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;
  int _currentIndex = 0;

  Choice _selectedChoice;
  bool isConsultOpen = false;

  String documentId;

  var consultSnapshot;
  var db = Provider.of<Database>(GlobalNavigatorKey.key.currentContext);
  MedicallUser medicallUser =
      Provider.of<UserProvider>(GlobalNavigatorKey.key.currentContext)
          .medicallUser;
  @override
  initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = controller.index;
    });
  }

  void _updateConsultStatus(Choice choice) {
    // Causes the app to rebuild with the new _selectedChoice.
    setState(() {
      _selectedChoice = choice;
      final DocumentReference documentReference =
          Firestore.instance.collection('consults').document(documentId);
      documentReference.get().then((snap) {
        if (snap.documentID == documentId &&
            snap.data['provider_id'] == medicallUser.uid) {
          Map<String, dynamic> consultStateData;
          if (_selectedChoice.title == 'Done') {
            _selectedChoice.icon = Icon(Icons.check_box, color: Colors.green);
            consultStateData = {'state': 'done'};
          } else {
            _selectedChoice.icon = Icon(
              Icons.check_box_outline_blank,
              color: Colors.blue,
            );
            consultStateData = {'state': 'in progress'};
          }
          // if (snap.data['state'] == 'done') {
          //   consultStateData = {'state': 'in progress'};
          // }
          //Navigator.pop(context);
          documentReference.updateData(consultStateData).whenComplete(() {
            setState(() {
              if (consultStateData['state'] == 'done') {
                isDone = true;
                if (_currentIndex != 0) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    controller.index = 0;
                  });
                }
              } else {
                isDone = false;
                if (_currentIndex != 0) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    controller.index = 0;
                  });
                } else {
                  //controller.index = 3;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    controller.index = 0;
                  });
                }
              }
            });
            print("Consult Status Updated");
          }).catchError((e) => print(e));
        }
      });
    });
  }

  Widget returnBody() {
    List<Choice> choices = <Choice>[
      Choice(
          title: 'Done',
          icon: isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
      Choice(
          title: 'Active',
          icon: !isDone
              ? Icon(Icons.check_box, color: Colors.green)
              : Icon(
                  Icons.check_box_outline_blank,
                  color: Colors.blue,
                )),
    ];
    if (db.consultSnapshot != null) {
      consultSnapshot = db.consultSnapshot.data;
    } else {
      consultSnapshot = {'type': ''};
    }
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          medicallUser.type == 'provider'
              ? PopupMenuButton<Choice>(
                  onSelected: _updateConsultStatus,
                  initialValue: _selectedChoice,
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Container(
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[Text(choice.title), choice.icon],
                          ),
                        ),
                      );
                    }).toList();
                  },
                )
              : SizedBox(
                  width: 60,
                ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            consultSnapshot != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        medicallUser.type == 'patient'
                            ? '${consultSnapshot['provider'].split(" ")[0][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[0].substring(1)} ${consultSnapshot['provider'].split(" ")[1][0].toUpperCase()}${consultSnapshot['provider'].split(" ")[1].substring(1)} ' +
                                consultSnapshot['providerTitles']
                            : '${consultSnapshot['patient'].split(" ")[0][0].toUpperCase()}${consultSnapshot['patient'].split(" ")[0].substring(1)} ${consultSnapshot['patient'].split(" ")[1][0].toUpperCase()}${consultSnapshot['patient'].split(" ")[1].substring(1)} ',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? 17.0
                                  : 20.0,
                        ),
                      ),
                      Text(
                        consultSnapshot['type'] == 'Lesion'
                            ? 'Spot'
                            : consultSnapshot['type'] != 'Lesion'
                                ? consultSnapshot['type']
                                : '',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? 12.0
                                  : 14.0,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
        bottom: TabBar(
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: 12),
          tabs: medicallUser.type == 'patient'
              ? <Tab>[
                  Tab(
                    // set icon to the tab
                    text: 'Prescription',
                    icon: Icon(Icons.local_hospital),
                  ),
                  Tab(
                    // set icon to the tab
                    text: 'Chat',
                    icon: Icon(Icons.chat_bubble_outline),
                  ),
                  Tab(
                    // set icon to the tab
                    text: 'Details',
                    icon: Icon(Icons.assignment),
                  ),
                ]
              : <Tab>[
                  Tab(
                    // set icon to the tab
                    text: 'Details',
                    icon: Icon(Icons.assignment),
                  ),
                  Tab(
                    // set icon to the tab
                    text: 'Chat',
                    icon: Icon(Icons.chat_bubble_outline),
                  ),
                  Tab(
                    // set icon to the tab
                    text: 'Prescription',
                    icon: Icon(Icons.local_hospital),
                  ),
                ],
          // setup the controller
          controller: controller,
        ),
        leading: BackButton(
          onPressed: () {
            GlobalNavigatorKey.key.currentState.pop(context);
          },
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: db.consultSnapshot != null
          ? medicallUser.type == 'patient' && consultSnapshot != null
              ? TabBarView(
                  // Add tabs as widgets
                  children: <Widget>[
                    BuildDetailTab(
                      keyStr: 'prescription',
                      indx: 0,
                    ),
                    BuildDetailTab(
                      keyStr: 'chat',
                      indx: 1,
                    ),
                    BuildDetailTab(
                      keyStr: 'details',
                      indx: 2,
                    )
                  ],
                  // set the controller
                  controller: controller,
                )
              : TabBarView(
                  children: <Widget>[
                    BuildDetailTab(
                      keyStr: 'details',
                      indx: 0,
                    ),
                    BuildDetailTab(
                      keyStr: 'chat',
                      indx: 1,
                    ),
                    BuildDetailTab(
                      keyStr: 'prescription',
                      indx: 2,
                    )
                  ],
                  controller: controller,
                )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The app's "state".
    return FutureBuilder<void>(
      future: db.getConsultDetail(), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return returnBody();
        }
        return returnBody();
      },
    );
  }
}

class Choice {
  Choice({this.title, this.icon});

  final String title;
  Icon icon;
}
