import 'dart:async';

import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/SelectProvider/provider_detail.dart';
import 'package:Medicall/screens/SelectProvider/provider_list_item.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProviderScreen extends StatelessWidget {
  final Symptom symptom;

  const SelectProviderScreen({@required this.symptom});

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.selectProvider,
      arguments: {
        'symptom': symptom,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NonAuthDatabase db = Provider.of<NonAuthDatabase>(context);
    User medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Doctors in your area",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (medicallUser != null) {
                    Navigator.of(context).pushNamed('/dashboard');
                  } else {
                    Navigator.of(context).pushNamed('/welcome');
                  }
                })
          ]),
      body: StreamBuilder(
        stream: db.getAllProviders(),
        builder:
            (BuildContext context, AsyncSnapshot<List<ProviderUser>> snapshot) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
                child: Text(
                  'Great news! We are in your area. Check out the dermatologist who can help you today.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: ListItemsBuilder<ProviderUser>(
                  snapshot: snapshot,
                  itemBuilder: (context, provider) => ProviderListItem(
                    provider: provider,
                    onTap: () => ProviderDetailScreen.show(
                      context: context,
                      provider: provider,
                      symptom: symptom,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
