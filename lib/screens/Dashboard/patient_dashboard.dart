import 'package:Medicall/common_widgets/empty_visits.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Consults/previous_visits.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard_list_item.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard_view_model.dart';
import 'package:Medicall/screens/MakePayment/make_payment.dart';
import 'package:Medicall/screens/Symptoms/symptoms.dart';
import 'package:Medicall/screens/VisitDetails/visit_details_overview.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    PreviousVisits.show(context: context);
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
                Icons.menu,
                color: Theme.of(context).appBarTheme.iconTheme.color,
              ),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Hello, ${model.userProvider.user.firstName}!',
          style: Theme.of(context).appBarTheme.textTheme.headline6,
        ),
      ),
      drawer: DrawerMenu(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: Container(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(width * .05),
              child: Column(
                children: _buildChildren(
                  context: context,
                  height: height,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({
    BuildContext context,
    double height,
  }) {
    return [
      _buildHeader(),
      SizedBox(height: 20),
      Align(
        alignment: FractionalOffset.bottomCenter,
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                alignment: Alignment.center,
                width: 80,
                child: Text(
                  "Start \na Visit",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () => _navigateToVisitScreen(context),
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                alignment: Alignment.center,
                width: 80,
                child: Text(
                  "Prescriptions",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () => _navigateToPrescriptionDetails(context),
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                alignment: Alignment.center,
                width: 80,
                child: Text(
                  "Previous \nVisits",
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
              onPressed: () => _navigateToPreviousConsults(context),
            ),
          ],
        ),
      ),
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
              Center(
                child: Text(
                  "Status of active visits:",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  child: ListItemsBuilder<Consult>(
                    snapshot: consultSnapshot,
                    emptyContentWidget: EmptyVisits(
                      title: "You do not have any active visits",
                      message: "Start a visit below",
                    ),
                    itemBuilder: (context, consult) => PatientDashboardListItem(
                      consult: consult,
                      onTap: () => consult.state == ConsultStatus.PendingPayment
                          ? MakePayment.show(context: context, consult: consult)
                          : VisitDetailsOverview.show(
                              context: context,
                              consult: consult,
                            ),
                    ),
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
