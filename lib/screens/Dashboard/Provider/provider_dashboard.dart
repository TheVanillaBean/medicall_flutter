import 'package:Medicall/common_widgets/empty_visits.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/visit_overview.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_view_model.dart';
import 'package:Medicall/screens/StripeConnect/index.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ProviderDashboardScreen extends StatelessWidget {
  final ProviderDashboardViewModel model;

  const ProviderDashboardScreen({this.model});

  static Widget create(BuildContext context) {
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider provider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<ProviderDashboardViewModel>(
      create: (context) => ProviderDashboardViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<ProviderDashboardViewModel>(
        builder: (_, model, __) => ProviderDashboardScreen(
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
        Routes.providerDashboard,
      );
    } else {
      await Navigator.of(context).pushNamed(
        Routes.providerDashboard,
      );
    }
  }

  void consultItemPressed(BuildContext context, Consult consult) {
    if (!(model.userProvider.user as ProviderUser).stripeConnectAuthorized) {
      StripeConnect.show(context: context, pushReplaceNamed: true);
    } else {
      VisitOverview.show(context: context, consult: consult);
    }
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
                  "Current pending visits for you:",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListItemsBuilder<Consult>(
                  snapshot: consultSnapshot,
                  emptyContentWidget: EmptyVisits(
                    title: "",
                    message: "You do not have any pending visits to review",
                  ),
                  itemBuilder: (context, consult) => ProviderDashboardListItem(
                    consult: consult,
                    onTap: () => consultItemPressed(context, consult),
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
