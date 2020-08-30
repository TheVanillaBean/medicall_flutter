import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/screens/History/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HistoryTiles extends StatelessWidget {
  final HistoryState model;
  final String searchInput;
  const HistoryTiles({Key key, @required this.model, this.searchInput})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            height: ScreenUtil.screenHeightDp - 80,
            child: ListView.builder(
                itemCount: model.historySnapshot.data.documents.length,
                itemBuilder: (context, index) {
                  List<Widget> _historyWidgetList = [];
                  if (model
                          .historySnapshot.data.documents[index].data['patient']
                          .toLowerCase()
                          .contains(
                            searchInput.toLowerCase(),
                          ) ||
                      model.historySnapshot.data.documents[index]
                          .data['provider']
                          .toLowerCase()
                          .contains(
                            searchInput.toLowerCase(),
                          ) ||
                      model.historySnapshot.data.documents[index].data['state']
                          .toLowerCase()
                          .contains(
                            searchInput.toLowerCase(),
                          ) ||
                      model.historySnapshot.data.documents[index].data['type']
                          .toLowerCase()
                          .contains(
                            searchInput.toLowerCase(),
                          )) {
                    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                        model.historySnapshot.data.documents[index].data['date']
                            .millisecondsSinceEpoch);
                    _historyWidgetList.add(FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(70),
                        onPressed: () {
                          model.db.consultSnapshot =
                              model.historySnapshot.data.documents[index];
                          model.db.consultQuestions = model.historySnapshot.data
                              .documents[index].data['screening_questions'];
                          Navigator.of(context)
                              .pushNamed('/historyDetail', arguments: {
                            'isRouted': false,
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: ListTile(
                            dense: true,
                            isThreeLine: true,
                            title: Text(
                              model.medicallUser.type == USER_TYPE.PATIENT
                                  ? '${model.historySnapshot.data.documents[index].data['provider']} ${model.historySnapshot.data.documents[index].data['providerTitles']}'
                                  : '${model.historySnapshot.data.documents[index].data['patient'].split(" ")[0][0].toUpperCase()}${model.historySnapshot.data.documents[index].data['patient'].split(" ")[0].substring(1)} ${model.historySnapshot.data.documents[index].data['patient'].split(" ")[1][0].toUpperCase()}${model.historySnapshot.data.documents[index].data['patient'].split(" ")[1].substring(1)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            subtitle: model.historySnapshot.data
                                        .documents[index].data['type'] !=
                                    'Lesion'
                                ? Text(DateFormat('dd MMM h:mm a')
                                        .format(timestamp)
                                        .toString() +
                                    '\n' +
                                    model.historySnapshot.data.documents[index]
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  model.historySnapshot.data.documents[index]
                                              .data['state']
                                              .toString() ==
                                          'prescription paid'
                                      ? Icon(
                                          CustomIcons.MedicallIcons.ambulance,
                                          color: Colors.indigo,
                                        )
                                      : model
                                                  .historySnapshot
                                                  .data
                                                  .documents[index]
                                                  .data['state']
                                                  .toString() ==
                                              'prescription waiting'
                                          ? Icon(
                                              CustomIcons.MedicallIcons.medkit,
                                              color: Colors.green,
                                            )
                                          : model
                                                      .historySnapshot
                                                      .data
                                                      .documents[index]
                                                      .data['state']
                                                      .toString() ==
                                                  'done'
                                              ? Icon(
                                                  Icons.assignment_turned_in,
                                                  color: Colors.green,
                                                )
                                              : model
                                                          .historySnapshot
                                                          .data
                                                          .documents[index]
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
                                      model.historySnapshot.data
                                          .documents[index].data['state']
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  )
                                ],
                              ),
                              onPressed: () {},
                            ),
                            leading: model.medicallUser.type ==
                                    USER_TYPE.PATIENT
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey.withAlpha(100),
                                    child: model.historySnapshot.data
                                                .documents[index].data
                                                .containsKey(
                                                    'provider_profile') &&
                                            model
                                                    .historySnapshot
                                                    .data
                                                    .documents[index]
                                                    .data['provider_profile'] !=
                                                null
                                        ? ClipOval(
                                            child: model.extendedImageProvider
                                                .returnNetworkImage(
                                                    model
                                                            .historySnapshot
                                                            .data
                                                            .documents[index]
                                                            .data[
                                                        'provider_profile'],
                                                    width: 100.0,
                                                    height: 100.0,
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
                                    backgroundColor: Colors.grey.withAlpha(100),
                                    child: model
                                                    .historySnapshot
                                                    .data
                                                    .documents[index]
                                                    .data['patient_profile'] !=
                                                null &&
                                            model
                                                    .historySnapshot
                                                    .data
                                                    .documents[index]
                                                    .data['patient_profile']
                                                    .length >
                                                0
                                        ? ClipOval(
                                            child: model.extendedImageProvider
                                                .returnNetworkImage(
                                              model
                                                  .historySnapshot
                                                  .data
                                                  .documents[index]
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
                  }
                  return Column(children: _historyWidgetList.toList());
                })));
  }
}
