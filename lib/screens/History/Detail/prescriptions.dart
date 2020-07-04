import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:Medicall/screens/History/Detail/buildDetailTab.dart';
import 'package:Medicall/screens/History/Detail/prescription.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrescriptionsScreen extends StatelessWidget {
  final bool isDone;
  const PrescriptionsScreen({Key key, this.isDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Database _db = Provider.of<Database>(context);
    final User medicallUser = Provider.of<UserProvider>(context).user;
    return Scaffold(
        appBar: AppBar(
          title: Text('Prescriptions'),
          centerTitle: true,
          actions: <Widget>[
            medicallUser.type == 'provider'
                ? IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BuildDetailTab(
                                  isDone: this.isDone,
                                  keyStr: 'Create Prescription',
                                )),
                      );
                    },
                  )
                : Container(),
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance
              .collection('consults/' +
                  _db.consultSnapshot.documentID +
                  '/prescriptions')
              .snapshots(),
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
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return Column(children: [
                        FlatButton(
                            padding: EdgeInsets.all(0),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(70),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PrescriptionScreen(
                                          snapshot:
                                              snapshot.data.documents[index],
                                        )),
                              );
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
                                  snapshot.data.documents[index]
                                      .data['medication_name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '\$' +
                                          snapshot.data.documents[index]
                                              .data['price']
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(DateFormat('dd MMM h:mm a')
                                        .format(DateTime
                                            .fromMillisecondsSinceEpoch(snapshot
                                                    .data
                                                    .documents[index]
                                                    .data['date']
                                                    .millisecondsSinceEpoch *
                                                1000))
                                        .toString()),
                                  ],
                                ),
                                trailing: FlatButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      snapshot.data.documents[index]
                                                  .data['state']
                                                  .toString() ==
                                              'prescription paid'
                                          ? Icon(
                                              CustomIcons
                                                  .MedicallIcons.ambulance,
                                              color: Colors.indigo,
                                            )
                                          : snapshot.data.documents[index]
                                                      .data['state']
                                                      .toString() ==
                                                  'prescription waiting'
                                              ? Icon(
                                                  CustomIcons
                                                      .MedicallIcons.medkit,
                                                  color: Colors.green,
                                                )
                                              : snapshot.data.documents[index]
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
                                          snapshot.data.documents[index]
                                              .data['state']
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
                              ),
                            )),
                      ]);
                    });
            }
          },
        ));
  }
}
