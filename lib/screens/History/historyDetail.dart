import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/history_detail_state.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'buildDetailTab.dart';

class HistoryDetailScreen extends StatefulWidget {
  HistoryDetailScreen({Key key}) : super(key: key);

  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  Database db;
  MedicallUser medicallUser;
  DetailedHistoryState detailedHistoryState;

  @override
  void dispose() {
    super.dispose();
    detailedHistoryState.getTabController.index = 0;
    //detailedHistoryState.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The app's "state".
    db = Provider.of<Database>(context);
    medicallUser = Provider.of<UserProvider>(context).medicallUser;
    detailedHistoryState = Provider.of<DetailedHistoryState>(context);
    detailedHistoryState.setControllerTabs(this);
    return FutureBuilder(
      future:
          db.getConsultDetail(detailedHistoryState), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return returnBody();
      },
    );
  }

  Widget returnBody() {
    //detailedHistoryState.setIsDone(true);
    detailedHistoryState.setChoices();
    //detailedHistoryState.getTabController.index = 0;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          medicallUser.type == 'provider'
              ? PopupMenuButton<Choice>(
                  onSelected: (val) {
                    detailedHistoryState.setConsultStatus(db.consultSnapshot,
                        val, medicallUser.uid, db.updateConsultStatus);
                    if (db.consultSnapshot.data['state'] == 'done') {
                      detailedHistoryState.setIsDone(true);
                    } else {
                      detailedHistoryState.setIsDone(false);
                    }
                    detailedHistoryState.setChoices();
                  },
                  initialValue: detailedHistoryState.getConsultStatus,
                  itemBuilder: (BuildContext context) {
                    return detailedHistoryState.getChoices.map((Choice choice) {
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
            db.consultSnapshot != null &&
                    db.consultSnapshot.data['provider'] != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        medicallUser.type == 'patient'
                            ? '${db.consultSnapshot.data['provider'].split(" ")[0][0].toUpperCase()}${db.consultSnapshot.data['provider'].split(" ")[0].substring(1)} ${db.consultSnapshot.data['provider'].split(" ")[1][0].toUpperCase()}${db.consultSnapshot.data['provider'].split(" ")[1].substring(1)} ' +
                                db.consultSnapshot.data['providerTitles']
                            : '${db.consultSnapshot.data['patient'].split(" ")[0][0].toUpperCase()}${db.consultSnapshot.data['patient'].split(" ")[0].substring(1)} ${db.consultSnapshot.data['patient'].split(" ")[1][0].toUpperCase()}${db.consultSnapshot.data['patient'].split(" ")[1].substring(1)} ',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? 17.0
                                  : 20.0,
                        ),
                      ),
                      Text(
                        db.consultSnapshot.data['type'] == 'Lesion'
                            ? 'Spot'
                            : db.consultSnapshot.data['type'] != 'Lesion'
                                ? db.consultSnapshot.data['type']
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
          controller: detailedHistoryState.getTabController,
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: db.consultSnapshot != null
          ? medicallUser.type == 'patient' && db.consultSnapshot != null
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
                  controller: detailedHistoryState.getTabController,
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
                  controller: detailedHistoryState.getTabController,
                )
          : Container(),
    );
  }
}
