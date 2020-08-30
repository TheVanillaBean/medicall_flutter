import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/screens/History/doctorSearch.dart';
import 'package:Medicall/screens/History/historyTiles.dart';
import 'package:Medicall/screens/History/history_state.dart';
import 'package:Medicall/screens/History/newUserPlaceholder.dart';
import 'package:Medicall/screens/History/trailingActions.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/firebase_notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryState model;
  final bool showAppBar;
  final String query;

  const HistoryScreen(
      {Key key, @required this.model, this.showAppBar, this.query})
      : super(key: key);

  static Widget create(BuildContext context, bool showAppBar, String query) {
    User _medicallUser = Provider.of<UserProvider>(context).user;
    FirebaseNotifications().setUpFirebase(medicallUser: _medicallUser);
    Database _db = Provider.of<Database>(context);
    ExtImageProvider _extendedImageProvider =
        Provider.of<ExtImageProvider>(context);
    return ChangeNotifierProvider<HistoryState>(
      create: (context) => HistoryState(
          medicallUser: _medicallUser,
          extendedImageProvider: _extendedImageProvider,
          db: _db),
      child: Consumer<HistoryState>(
        builder: (_, model, __) => HistoryScreen(
          model: model,
          showAppBar: showAppBar,
          query: query,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerMenu(),
      bottomNavigationBar: model.medicallUser.type == USER_TYPE.PATIENT
          ? StreamBuilder(
              stream: model.getUserHistorySnapshot(
                  model.medicallUser, this.query, model.sortBy),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Container();
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    if (snapshot.data.documents.length == 0) {
                      return BottomAppBar(
                        color: Colors.transparent,
                        child: Container(
                          height: 70,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: FlatButton(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        onPressed: () async {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  '/symptoms');
                                        },
                                        color: Colors.purple.withAlpha(30),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0))),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              'Get Care',
                                              style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'I have a health issue \nthat I need care for',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  color: Colors.deepPurple
                                                      .withAlpha(200)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )),
                                  ),
                                  Expanded(
                                    child: FlatButton(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DoctorSearch()),
                                          );
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0))),
                                        color: Colors.blueAccent.withAlpha(30),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              'Find Doctor',
                                              style: TextStyle(
                                                  color: Colors.indigo,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'I know what doctor\n I want to connect with',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  color: Colors.indigo
                                                      .withOpacity(0.7)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                }
              },
            )
          : SizedBox(),
      appBar: this.showAppBar
          ? AppBar(
              centerTitle: true,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(Icons.home),
                  );
                },
              ),
              title: Text('My Visits'),
              actions: buildActions(context, model),
            )
          : null,
      body: _buildBody(),
    );
  }

  StreamBuilder _buildBody() {
    return StreamBuilder(
      stream: model.getUserHistorySnapshot(
          model.medicallUser, this.query, model.sortBy),
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
            if (snapshot.data.documents.length == 0) {
              return NewUserPlaceHolder(medicallUser: model.medicallUser);
            }
            model.historySnapshot = snapshot;
            return HistoryTiles(
              model: model,
              searchInput: this.query,
            );
        }
      },
    );
  }
}
