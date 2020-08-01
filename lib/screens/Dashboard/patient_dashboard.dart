import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard_list_item.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard_view_model.dart';
import 'package:Medicall/screens/Symptoms/symptoms.dart';
import 'package:Medicall/screens/VisitDetails/visit_details_overview.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PatientDashboardScreen extends StatelessWidget {
  final PatientDashboardViewModel model;

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<PatientDashboardViewModel>(
      create: (context) => PatientDashboardViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PatientDashboardViewModel>(
        builder: (_, model, __) => PatientDashboardScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
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

  const PatientDashboardScreen({@required this.model});

  void _navigateToVisitScreen(BuildContext context) {
    SymptomsScreen.show(context: context);
  }

  void _navigateToPrescriptionDetails(BuildContext context) {
    Navigator.of(context).pushNamed('/prescription-details');
  }

  void _navigateToPreviousConsults(BuildContext context) {
    Navigator.of(context).pushNamed('/previous-consults');
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
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
      body: Container(
        child: SafeArea(
          child: Column(
            children: _buildChildren(context: context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({BuildContext context}) {
    return [
      _buildHeader(),
      Divider(
        thickness: 2,
        height: 2,
      ),
      CustomFlatButton(
        text: "Start a Visit",
        padding: EdgeInsets.fromLTRB(35, 20, 35, 20),
        textColor: Theme.of(context).colorScheme.primary,
        leadingIcon: Icons.assignment_ind,
        onPressed: () => _navigateToVisitScreen(context),
      ),
      Divider(
        thickness: 1,
        height: 1,
      ),
      CustomFlatButton(
        text: "Prescriptions",
        padding: EdgeInsets.fromLTRB(35, 20, 35, 20),
        textColor: Theme.of(context).colorScheme.primary,
        leadingIcon: Icons.local_pharmacy,
        onPressed: () => _navigateToPrescriptionDetails(context),
      ),
      Divider(
        thickness: 1,
        height: 1,
      ),
      CustomFlatButton(
        text: "Previous Visits",
        padding: EdgeInsets.fromLTRB(35, 20, 35, 20),
        textColor: Theme.of(context).colorScheme.primary,
        leadingIcon: Icons.view_list,
        onPressed: () => _navigateToPreviousConsults(context),
      ),
    ];
  }

  Widget _buildHeader({BuildContext context}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(35, 5, 35, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Status of active visits:"),
                SizedBox(height: 12),
                Expanded(
                  child: ListItemsBuilder<Consult>(
                    snapshot: consultSnapshot,
                    emptyContentWidget: EmptyContent(
                      title: "",
                      message: "You do not have any active visits",
                    ),
                    itemBuilder: (context, consult) => PatientDashboardListItem(
                      consult: consult,
                      onTap: () => VisitDetailsOverview.show(
                          context: context, consult: consult),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
