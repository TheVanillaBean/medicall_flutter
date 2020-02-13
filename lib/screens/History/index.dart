import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/buildActions.dart';
import 'package:Medicall/screens/History/buildHistoryTiles.dart';
import 'package:Medicall/screens/History/buildNewUserPlaceholder.dart';
import 'package:Medicall/screens/History/history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Database _db = Provider.of<Database>(context);
    HistoryState _userHistoryState = Provider.of<HistoryState>(context);
    ScreenUtil.init(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: DrawerMenu(),
      appBar: _userHistoryState.getShowAppBar()
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
              title: Text('History'),
              actions: buildActions(context, _userHistoryState, _db),
            )
          : null,
      body: _buildBody("consults", context, _userHistoryState, _db),
    );
  }

  StreamBuilder _buildBody(questions, context, HistoryState _userHistory, _db) {
    List<Widget> _historyWidgetList;
    MedicallUser _medicallUser =
        Provider.of<UserProvider>(context).medicallUser;
    ExtImageProvider _extImageProvider = Provider.of<ExtImageProvider>(context);
    HistoryState _userHistoryState = Provider.of<HistoryState>(context);
    return StreamBuilder(
      stream: _userHistoryState.getUserHistorySnapshot(_medicallUser,
          _userHistoryState.searchInput, _userHistoryState.sortBy, context),
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
              return buildNewUserPlaceholder(context, _medicallUser);
            }
            return buildHistoryTiles(snapshot, _historyWidgetList,
                _medicallUser, _extImageProvider, _db);
        }
      },
    );
  }
}
