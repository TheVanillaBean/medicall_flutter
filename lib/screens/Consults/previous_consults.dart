import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Consults/previous_consults_list_item.dart';
import 'package:Medicall/screens/Consults/previous_consults_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviousConsults extends StatelessWidget {
  final PreviousConsultsViewModel model;
  const PreviousConsults({@required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Previous Consults",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
          child: Column(
            children: <Widget>[
              _buildChildren(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildren({BuildContext context, double height}) {
    return StreamBuilder<List<Consult>>(
      stream: model.consultStream.stream,
      builder:
          (BuildContext context, AsyncSnapshot<List<Consult>> consultSnapshot) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 12),
              Expanded(
                child: ListItemsBuilder<Consult>(
                  snapshot: consultSnapshot,
                  itemBuilder: (context, consult) => PreviousConsultsListItem(
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

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    return ChangeNotifierProvider<PreviousConsultsViewModel>(
      create: (context) => PreviousConsultsViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PreviousConsultsViewModel>(
        builder: (_, model, __) => PreviousConsults(
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
