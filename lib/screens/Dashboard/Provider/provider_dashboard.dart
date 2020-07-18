import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/visit_overview.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDashboardScreen extends StatelessWidget {
  final ProviderDashboardViewModel model;

  const ProviderDashboardScreen({this.model});

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Visits',
        ),
      ),
      body: StreamBuilder<List<Consult>>(
        stream: model.consultStream.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Consult>> snapshot) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListItemsBuilder<Consult>(
                  snapshot: snapshot,
                  itemBuilder: (context, consult) => ProviderDashboardListItem(
                    consult: consult,
                    onTap: () => VisitOverview.show(
                      context: context,
                      consult: consult,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
