import 'package:Medicall/models/consult_status_modal.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/Detail/detailsLanding.dart';
import 'package:Medicall/screens/History/Detail/history_detail_state.dart';
import 'package:Medicall/screens/Questions/questionsScreen.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryDetailScreen extends StatefulWidget {
  final DetailedHistoryState model;

  static Widget create(BuildContext context) {
    final Database _db = Provider.of<Database>(context);
    final User _medicallUser = Provider.of<UserProvider>(context).user;

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
  int currentDetailsIndex = 0;
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
          title: Container(
            margin: EdgeInsets.only(right: 55),
            child: Row(
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
                                ? widget.model.db.consultSnapshot.data['provider']
                                        .split(' ')[0][0]
                                        .toUpperCase() +
                                    widget.model.db.consultSnapshot
                                        .data['provider']
                                        .split(' ')[0]
                                        .substring(1) +
                                    ' ' +
                                    widget.model.db.consultSnapshot
                                        .data['provider']
                                        .split(' ')[1][0]
                                        .toUpperCase() +
                                    widget.model.db.consultSnapshot
                                        .data['provider']
                                        .split(' ')[1]
                                        .substring(1) +
                                    ' ' +
                                    widget.model.db.consultSnapshot
                                        .data['providerTitles']
                                : widget.model.db.consultSnapshot.data['patient']
                                        .split(' ')[0][0]
                                        .toUpperCase() +
                                    widget.model.db.consultSnapshot.data['patient']
                                        .split(' ')[0]
                                        .substring(1) +
                                    ' ' +
                                    widget.model.db.consultSnapshot.data['patient']
                                        .split(' ')[1][0]
                                        .toUpperCase() +
                                    widget.model.db.consultSnapshot.data['patient']
                                        .split(' ')[1]
                                        .substring(1),
                            style: TextStyle(
                              fontSize: Theme.of(context).platform ==
                                      TargetPlatform.iOS
                                  ? 17.0
                                  : 20.0,
                            ),
                          ),
                          Text(
                            widget.model.db.consultSnapshot.data['type'] ==
                                    'Lesion'
                                ? 'Spot'
                                : widget.model.db.consultSnapshot
                                            .data['type'] !=
                                        'Lesion'
                                    ? widget
                                        .model.db.consultSnapshot.data['type']
                                    : '',
                            style: TextStyle(
                              fontSize: Theme.of(context).platform ==
                                      TargetPlatform.iOS
                                  ? 12.0
                                  : 14.0,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          // bottom: TabBar(
          //   indicatorColor: Theme.of(context).primaryColor,
          //   indicatorWeight: 3,
          //   labelStyle: TextStyle(fontSize: 12),
          //   tabs: widget.model.medicallUser.type == 'patient'
          //       ? <Tab>[
          //           Tab(
          //             // set icon to the tab
          //             text: 'Treatment',
          //             icon: Icon(Icons.local_hospital),
          //           ),
          //           Tab(
          //             // set icon to the tab
          //             text: 'Chat',
          //             icon: Icon(Icons.chat_bubble_outline),
          //           ),
          //           Tab(
          //             // set icon to the tab
          //             text: 'Review',
          //             icon: Icon(Icons.assignment),
          //           ),
          //         ]
          //       : <Tab>[
          //           Tab(
          //             // set icon to the tab
          //             text: 'Details',
          //             icon: Icon(Icons.assignment),
          //           ),
          //           Tab(
          //             // set icon to the tab
          //             text: 'Chat',
          //             icon: Icon(Icons.chat_bubble_outline),
          //           ),
          //           Tab(
          //             // set icon to the tab
          //             text: 'Prescription',
          //             icon: Icon(Icons.local_hospital),
          //           ),
          //         ],
          //   // setup the controller
          //   controller: widget.model.getTabController,
          // ),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop(context);
            },
          ),
        ),
        bottomNavigationBar: widget.model.medicallUser.type == 'provider'
            ? Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: Container(
                    height: 50,
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                              color: Colors.green,
                            )),
                        onPressed: () async {
                          await widget.model.db.getDiagnosisQuestions(
                              widget.model.db.consultSnapshot.data['type']);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => QuestionsScreenOld(
                                      data: 'diagnosis',
                                    )),
                          );
                        },
                        child: Text(
                          'Complete',
                          style: TextStyle(color: Colors.green),
                        )),
                  )),
                  Expanded(
                    child: Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(
                                  color: widget.model.db.consultSnapshot
                                              .data['state'] !=
                                          'done'
                                      ? Colors.red
                                      : Colors.purple,
                                )),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: Text("Confirm Consult"),
                                    content: Text(widget
                                                .model
                                                .db
                                                .consultSnapshot
                                                .data['state'] !=
                                            'done'
                                        ? "Please confirm closure of consult, this will mark this consult as done disabling further interaction with the patient."
                                        : "Please confirm that you want to reopen this consult."),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      widget.model.db.consultSnapshot
                                                  .data['state'] !=
                                              'done'
                                          ? FlatButton(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              child: Text("Close Consult"),
                                              onPressed: () async {
                                                widget.model.setConsultStatus(
                                                    widget.model.db
                                                        .consultSnapshot,
                                                    Choice(
                                                        title: 'Done',
                                                        icon: Icon(
                                                            Icons.check_box,
                                                            color:
                                                                Colors.green)),
                                                    widget
                                                        .model.medicallUser.uid,
                                                    widget.model.db
                                                        .updateConsultStatus);
                                                if (widget
                                                        .model
                                                        .db
                                                        .consultSnapshot
                                                        .data['state'] ==
                                                    'done') {
                                                  widget.model
                                                      .updateWith(isDone: true);
                                                } else {
                                                  widget.model.updateWith(
                                                      isDone: false);
                                                }
                                                widget.model.setChoices();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            )
                                          : FlatButton(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              child: Text("Reopen Consult"),
                                              onPressed: () async {
                                                widget.model.setConsultStatus(
                                                    widget.model.db
                                                        .consultSnapshot,
                                                    Choice(
                                                        title: 'Active',
                                                        icon: Icon(
                                                            Icons.check_box,
                                                            color:
                                                                Colors.green)),
                                                    widget
                                                        .model.medicallUser.uid,
                                                    widget.model.db
                                                        .updateConsultStatus);
                                                if (widget
                                                        .model
                                                        .db
                                                        .consultSnapshot
                                                        .data['state'] ==
                                                    'done') {
                                                  widget.model
                                                      .updateWith(isDone: true);
                                                } else {
                                                  widget.model.updateWith(
                                                      isDone: false);
                                                }
                                                widget.model.setChoices();
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              widget.model.db.consultSnapshot.data['state'] !=
                                      'done'
                                  ? 'Close'
                                  : 'Reopen Consult',
                              style: TextStyle(
                                  color: widget.model.db.consultSnapshot
                                              .data['state'] !=
                                          'done'
                                      ? Colors.red
                                      : Colors.purple),
                            ))),
                  )
                ],
              )
            : SizedBox(),
        body: DetailsLandingScreen(
          isDone: widget.model.isDone,
        ));
  }
}
