import 'package:Medicall/models/medicall_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:Medicall/globals.dart' as globals;

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
            medicallUser.type == 'provider' ? 'Patients' : 'History',
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
              stream: Firestore.instance
                  .collection('users')
                  .document(medicallUser.id)
                  .collection('consults')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: null,
                    ),
                  );
                }
                var userDocuments = snapshot.data.documents;
                List<Widget> historyList = [];
                for (var i = 0; i < userDocuments.length; i++) {
                  historyList.add(ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, '/historyDetail',
                          arguments: userDocuments[i].documentID);
                    },
                    title: Text(medicallUser.type == 'provider'
                        ? userDocuments[i].data['patient'].toString()
                        : userDocuments[i].data['provider'].toString()),
                    subtitle: Text(userDocuments[i].data['date'].toString() +
                        '\n' +
                        userDocuments[i].data['type'].toString()),
                    trailing: IconButton(
                      icon: Icon(Icons.input),
                      onPressed: () {},
                    ),
                    leading: Icon(
                      Icons.account_circle,
                      size: 50,
                    ),
                  ));
                }
                return Column(children: historyList.reversed.toList());
              }),
        ));
  }
}
