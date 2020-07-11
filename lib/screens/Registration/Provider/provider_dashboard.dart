import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'consult_detail_screen.dart';
import 'consult_list_Item.dart';
import 'package:Medicall/services/database.dart';

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
          'Consults',
        ),
      ),
      drawer: DrawerMenu(),
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
                    itemBuilder: (context, consult) => ConsultListItem(
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
