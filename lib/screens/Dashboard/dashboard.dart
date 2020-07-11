import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/dashboard_list_item.dart';
import 'package:Medicall/screens/Dashboard/dashboard_state_model.dart';
import 'package:Medicall/screens/Symptoms/symptoms.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardStateModel model;

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<DashboardStateModel>(
      create: (context) => DashboardStateModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<DashboardStateModel>(
        builder: (_, model, __) => DashboardScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed,
  }) async {
    if (pushReplaceNamed) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.dashboard,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.dashboard,
      );
    }
  }

  const DashboardScreen({@required this.model});

  void _navigateToVisitScreen(BuildContext context) {
    SymptomsScreen.show(context: context);
  }

  void _navigateToPrescriptionsScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/prescriptions');
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.of(context).pushNamed('/history');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(
                Icons.home,
              ),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Hello ${model.userProvider.user.firstName}!',
        ),
      ),
      drawer: DrawerMenu(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: Container(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * .1),
              child: Column(
                children: _buildChildren(context: context, height: height),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({BuildContext context, double height}) {
    return [
      _buildHeader(),
      SizedBox(
        height: height * 0.1,
      ),
      CustomFlatButton(
        text: "Start a visit",
        icon: Icons.assignment_ind,
        onPressed: () => _navigateToVisitScreen(context),
      ),
      CustomFlatButton(
        text: "Prescriptions",
        icon: Icons.local_pharmacy,
        onPressed: () => _navigateToPrescriptionsScreen(context),
      ),
      CustomFlatButton(
        text: "Previous Visits",
        icon: Icons.view_list,
        onPressed: () => _navigateToHistory(context),
      )
    ];
  }

  Widget _buildHeader({BuildContext context, double height}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Status of active visits:"),
              SizedBox(height: 12),
              Expanded(
                child: ListItemsBuilder<Consult>(
                  snapshot: consultSnapshot,
                  itemBuilder: (context, consult) => DashboardListItem(
                    consult: consult,
                    onTap: null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
