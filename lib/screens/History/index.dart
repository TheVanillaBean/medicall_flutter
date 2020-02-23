import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/historyTiles.dart';
import 'package:Medicall/screens/History/history_state.dart';
import 'package:Medicall/screens/History/newUserPlaceholder.dart';
import 'package:Medicall/screens/History/trailingActions.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryScreen extends StatelessWidget {
  final HistoryState model;
  final bool showAppBar;
  final String query;

  const HistoryScreen(
      {Key key, @required this.model, this.showAppBar, this.query})
      : super(key: key);

  static Widget create(BuildContext context, bool showAppBar, String query) {
    MedicallUser _medicallUser =
        Provider.of<UserProvider>(context).medicallUser;
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
              title: Text('History'),
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
