import 'package:Medicall/models/medicall_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/globals.dart' as globals;
import 'package:flutter/painting.dart';

class HistoryScreen extends StatefulWidget {
  final globals.ConsultData data;

  const HistoryScreen({Key key, @required this.data}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            medicallUser.type == 'provider' ? 'Patients' : 'Consult History',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          leading: Text('', style: TextStyle(color: Colors.black26)),
        ),
        drawer: DrawerMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(
              CustomIcons.MedicallApp.logo_m,
              size: 35.0,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            backgroundColor: Color.fromRGBO(241, 100, 119, 0.8),
            foregroundColor: Colors.white,
          );
        }),
        body: SingleChildScrollView(
          child: StreamBuilder(
              stream: medicallUser.type == 'patient'
                  ? Firestore.instance
                      .collection('consults')
                      .where('patient_id', isEqualTo: medicallUser.id)
                      .snapshots()
                  : Firestore.instance
                      .collection('consults')
                      .where('provider_id', isEqualTo: medicallUser.id)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.85,
                      ),
                      Container(
                        height: 50,
                        alignment: Alignment.center,
                        width: 50,
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      )
                    ],
                  );
                }
                var userDocuments = snapshot.data.documents;
                List<Widget> historyList = [];
                for (var i = 0; i < userDocuments.length; i++) {
                  historyList.add(FlatButton(
                      padding: EdgeInsets.all(0),
                      splashColor:
                          Theme.of(context).colorScheme.secondary.withAlpha(70),
                      onPressed: () {
                        Navigator.pushNamed(context, '/historyDetail',
                            arguments: userDocuments[i].documentID);
                      },
                      child: Container(
                        decoration: new BoxDecoration(
                            border: new Border(
                                bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withAlpha(70)))),
                        child: ListTile(
                          dense: true,
                          isThreeLine: true,
                          title: Text(
                            medicallUser.type == 'provider'
                                ? userDocuments[i].data['patient'].toString()
                                : userDocuments[i].data['provider'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          subtitle: Text(
                              userDocuments[i].data['date'].toString() +
                                  '\n' +
                                  userDocuments[i].data['type'].toString()),
                          trailing: IconButton(
                            icon: Icon(Icons.input),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(150),
                            onPressed: () {},
                          ),
                          leading: Icon(
                            Icons.account_circle,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(170),
                            size: 50,
                          ),
                        ),
                      )));
                }
                return Column(children: historyList.reversed.toList());
              }),
        ));
  }
}
