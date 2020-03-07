import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/Detail/history_detail_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'buildDetailTab.dart';

class HistoryDetailScreen extends StatefulWidget {
  final DetailedHistoryState model;

  static Widget create(BuildContext context) {
    final Database _db = Provider.of<Database>(context);
    final MedicallUser _medicallUser =
        Provider.of<UserProvider>(context).medicallUser;

    return ChangeNotifierProvider<DetailedHistoryState>(
      create: (context) => DetailedHistoryState(
        db: _db,
        medicallUser: _medicallUser,
      ),
      child: Consumer<DetailedHistoryState>(
        builder: (_, model, __) => HistoryDetailScreen(
          model: model,
        ),
      ),
    );
  }

  HistoryDetailScreen({@required this.model});
  @override
  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    super.dispose();
    widget.model.getTabController.index = 0;
    //detailedHistoryState.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The app's "state".

    widget.model.setControllerTabs(this);
    return FutureBuilder(
      future: widget.model.db
          .getConsultDetail(widget.model), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return returnBody();
      },
    );
  }

  Widget returnBody() {
    //detailedHistoryState.setIsDone(true);
    widget.model.setChoices();
    //detailedHistoryState.getTabController.index = 0;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          widget.model.medicallUser.type == 'provider'
              ? PopupMenuButton<Choice>(
                  onSelected: (val) {
                    widget.model.setConsultStatus(
                        widget.model.db.consultSnapshot,
                        val,
                        widget.model.medicallUser.uid,
                        widget.model.db.updateConsultStatus);
                    if (widget.model.db.consultSnapshot.data['state'] ==
                        'done') {
                      widget.model.updateWith(isDone: true);
                    } else {
                      widget.model.updateWith(isDone: false);
                    }
                    widget.model.setChoices();
                  },
                  initialValue: widget.model.getConsultStatus,
                  itemBuilder: (BuildContext context) {
                    return widget.model.getChoices.map((Choice choice) {
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
            widget.model.db.consultSnapshot != null &&
                    widget.model.db.consultSnapshot.data['provider'] != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.model.medicallUser.type == 'patient'
                            ? '${widget.model.db.consultSnapshot.data['provider'].split(" ")[0][0].toUpperCase()}${widget.model.db.consultSnapshot.data['provider'].split(" ")[0].substring(1)} ${widget.model.db.consultSnapshot.data['provider'].split(" ")[1][0].toUpperCase()}${widget.model.db.consultSnapshot.data['provider'].split(" ")[1].substring(1)} ' +
                                widget.model.db.consultSnapshot
                                    .data['providerTitles']
                            : '${widget.model.db.consultSnapshot.data['patient'].split(" ")[0][0].toUpperCase()}${widget.model.db.consultSnapshot.data['patient'].split(" ")[0].substring(1)} ${widget.model.db.consultSnapshot.data['patient'].split(" ")[1][0].toUpperCase()}${widget.model.db.consultSnapshot.data['patient'].split(" ")[1].substring(1)} ',
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? 17.0
                                  : 20.0,
                        ),
                      ),
                      Text(
                        widget.model.db.consultSnapshot.data['type'] == 'Lesion'
                            ? 'Spot'
                            : widget.model.db.consultSnapshot.data['type'] !=
                                    'Lesion'
                                ? widget.model.db.consultSnapshot.data['type']
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
          tabs: widget.model.medicallUser.type == 'patient'
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
          controller: widget.model.getTabController,
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(context);
          },
        ),
      ),
      body: widget.model.db.consultSnapshot != null
          ? widget.model.medicallUser.type == 'patient' &&
                  widget.model.db.consultSnapshot != null
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
                  controller: widget.model.getTabController,
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
                  controller: widget.model.getTabController,
                )
          : Container(),
    );
  }
}
