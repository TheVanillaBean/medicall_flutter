import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/screens/Dashboard/Provider/provider_dashboard_list_item.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Registration/Provider/consult_detail_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final db = Provider.of<FirestoreDatabase>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Visits',
        ),
      ),
      body: StreamBuilder<List<Consult>>(
          stream: db.getConsultsForProvider(userProvider.user.uid),
          builder:
              (BuildContext context, AsyncSnapshot<List<Consult>> snapshot) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListItemsBuilder<Consult>(
                    snapshot: snapshot,
                    itemBuilder: (context, consult) =>
                        ProviderDashboardDashboardListItem(
                      consult: consult,
                      onTap: () => ConsultDetailScreen.show(
                        context: context,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
