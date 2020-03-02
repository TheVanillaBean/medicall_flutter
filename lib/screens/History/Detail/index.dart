import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/Detail/history_detail_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    ScreenUtil.init(context);
    widget.model.db.getPatientMedicalHistory(medicallUser);
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
      body: widget.model.db.consultSnapshot != null
          ? widget.model.medicallUser.type == 'patient' &&
                  widget.model.db.consultSnapshot != null
              ? Column(
                  children: <Widget>[
                    Container(
                        height: 60,
                        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        color: Theme.of(context).canvasColor,
                        width: ScreenUtil.screenWidthDp,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: -13,
                              child: BackButton(
                                color: Colors.black54,
                                onPressed: () {
                                  Navigator.of(context).pop(context);
                                },
                              ),
                            ),
                            widget.model.db.consultSnapshot != null &&
                                    widget.model.db.consultSnapshot
                                            .data['provider'] !=
                                        null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        widget.model.db.consultSnapshot
                                                    .data['type'] ==
                                                'Lesion'
                                            ? 'Spot care with '
                                            : widget.model.db.consultSnapshot
                                                        .data['type'] !=
                                                    'Lesion'
                                                ? widget
                                                    .model
                                                    .db
                                                    .consultSnapshot
                                                    .data['type']
                                                : '',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Text(
                                        widget.model.medicallUser.type ==
                                                'patient'
                                            ? '${widget.model.db.consultSnapshot.data['provider'].split(" ")[0][0].toUpperCase()}${widget.model.db.consultSnapshot.data['provider'].split(" ")[0].substring(1)} ${widget.model.db.consultSnapshot.data['provider'].split(" ")[1][0].toUpperCase()}${widget.model.db.consultSnapshot.data['provider'].split(" ")[1].substring(1)} ' +
                                                widget.model.db.consultSnapshot
                                                    .data['providerTitles']
                                            : '${widget.model.db.consultSnapshot.data['patient'].split(" ")[0][0].toUpperCase()}${widget.model.db.consultSnapshot.data['patient'].split(" ")[0].substring(1)} ${widget.model.db.consultSnapshot.data['patient'].split(" ")[1][0].toUpperCase()}${widget.model.db.consultSnapshot.data['patient'].split(" ")[1].substring(1)} ' +
                                                        widget
                                                            .model
                                                            .db
                                                            .consultSnapshot
                                                            .data['type'] ==
                                                    'Lesion'
                                                ? 'Spot'
                                                : widget
                                                            .model
                                                            .db
                                                            .consultSnapshot
                                                            .data['type'] !=
                                                        'Lesion'
                                                    ? widget
                                                        .model
                                                        .db
                                                        .consultSnapshot
                                                        .data['type']
                                                    : '',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            widget.model.medicallUser.type == 'provider'
                                ? Positioned(
                                    right: 0,
                                    top: -13,
                                    child: PopupMenuButton<Choice>(
                                      onSelected: (val) {
                                        widget.model.setConsultStatus(
                                            widget.model.db.consultSnapshot,
                                            val,
                                            widget.model.medicallUser.uid,
                                            widget
                                                .model.db.updateConsultStatus);
                                        if (widget.model.db.consultSnapshot
                                                .data['state'] ==
                                            'done') {
                                          widget.model.updateWith(isDone: true);
                                        } else {
                                          widget.model
                                              .updateWith(isDone: false);
                                        }
                                        widget.model.setChoices();
                                      },
                                      initialValue:
                                          widget.model.getConsultStatus,
                                      itemBuilder: (BuildContext context) {
                                        return widget.model.getChoices
                                            .map((Choice choice) {
                                          return PopupMenuItem<Choice>(
                                            value: choice,
                                            child: Container(
                                              height: 70,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(choice.title),
                                                  choice.icon
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  )
                                : SizedBox(
                                    width: 60,
                                  ),
                          ],
                        )),
                    Container(
                        height: 80,
                        padding: EdgeInsets.all(0),
                        color: Theme.of(context).canvasColor,
                        width: ScreenUtil.screenWidthDp,
                        child: NavigationToolbar(
                          middle: TabBar(
                            indicatorColor:
                                Theme.of(context).colorScheme.secondary,
                            indicatorWeight: 3,
                            labelColor: Theme.of(context).colorScheme.secondary,
                            unselectedLabelColor: Colors.grey.withAlpha(200),
                            labelStyle: TextStyle(
                              fontSize: 12,
                            ),
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
                        )),
                    Expanded(
                      child: TabBarView(
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
                      ),
                    )
                  ],
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
