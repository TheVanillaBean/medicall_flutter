import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/empty_visits.dart';
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
                color: Theme.of(context).appBarTheme.iconTheme.color,
              ),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Hello ${model.userProvider.user.firstName}!',
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
          alignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FlatButton(
              onPressed: () => _navigateToVisitScreen(context),
              child: Text(
                'Start \na Visit',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Roboto Thin',
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              width: 0.5,
              height: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            FlatButton(
              onPressed: () => _navigateToPrescriptionDetails(context),
              child: Text(
                'Prescriptions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Roboto Thin',
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              width: 0.5,
              height: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            FlatButton(
              onPressed: () => _navigateToPreviousConsults(context),
              child: Text(
                'Previous \nVisits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Roboto Thin',
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildHeader({BuildContext context}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 30),
              Center(
                child: Text(
                  "Status of active visits:",
                  style: TextStyle(
                    fontFamily: 'Roboto Thin',
                    fontSize: 20.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListItemsBuilder<Consult>(
                  snapshot: null,
                  itemsList: [],
                  emptyContentWidget: EmptyVisits(
                    title: "You do not have any active visits",
                    message: "Start a visit below",
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
