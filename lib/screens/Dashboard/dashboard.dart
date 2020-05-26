import 'package:Medicall/common_widgets/flat_button.dart';
import 'package:Medicall/screens/Dashboard/dashboard_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardStateModel model;

  static Widget create(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<DashboardStateModel>(
      create: (context) => DashboardStateModel(
        auth: auth,
        userProvider: provider,
      ),
      child: Consumer<DashboardStateModel>(
        builder: (_, model, __) => DashboardScreen(
          model: model,
        ),
      ),
    );
  }

  const DashboardScreen({@required this.model});

  void _navigateToVisitScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/symptoms');
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
        height: height * 0.15,
      ),
      Text(
        "No current consults...",
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: height * 0.05,
      ),
      CustomFlatButton(
        text: "Start a visit",
        icon: Icons.home,
        onPressed: () => _navigateToVisitScreen(context),
      ),
      CustomFlatButton(
        text: "Prescriptions",
        icon: Icons.home,
        onPressed: () => _navigateToPrescriptionsScreen(context),
      ),
      CustomFlatButton(
        text: "Previous Visits",
        icon: Icons.home,
        onPressed: () => _navigateToHistory(context),
      )
    ];
  }

  Widget _buildHeader() {
    return Text(
      "Hello ${this.model.userProvider.medicallUser.displayName}!",
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 18,
      ),
    );
  }

  Widget _buildActiveVisitStatusWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        children: <Widget>[
          Text(
            "No current consults.",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
