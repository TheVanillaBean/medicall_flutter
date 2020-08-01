import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Consults/previous_visits_list_item.dart';
import 'package:Medicall/screens/Consults/previous_visits_view_model.dart';
import 'package:Medicall/screens/VisitDetails/visit_details_overview.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviousVisits extends StatelessWidget {
  final PreviousVisitsViewModel model;
  const PreviousVisits({@required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Previous Visits",
        theme: Theme.of(context),
      ),
      body: _buildChildren(),
    );
  }

  Widget _buildChildren({BuildContext context, double height}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 12),
            ListItemsBuilder<Consult>(
              snapshot: consultSnapshot,
              itemBuilder: (context, consult) => PreviousVisitsListItem(
                consult: consult,
                onTap: () => VisitDetailsOverview.show(
                    context: context, consult: consult),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<PreviousVisitsViewModel>(
      create: (context) => PreviousVisitsViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PreviousVisitsViewModel>(
        builder: (_, model, __) => PreviousVisits(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.previousConsults,
    );
  }
}
