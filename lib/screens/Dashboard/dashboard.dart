import 'package:Medicall/common_widgets/custom_raised_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        sized: false,
        child: Container(
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _buildChildren(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      _buildHeader(this.model.userProvider.medicallUser.displayName),
      CustomRaisedButton()
    ];
  }

  Widget _buildHeader(String name) {
    return Text(
      "Hello $name!",
      style: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 18,
      ),
    );
  }

  Widget _buildActiveVisitStatusWidget(BuildContext context) {}

  Widget _buildNavigationButton(BuildContext context) {}
}
