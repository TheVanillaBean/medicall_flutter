import 'dart:async';

import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/symptoms.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/SelectProvider/provider_list_item.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/util/app_util.dart';
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Doctors in your area'),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Text(
                'Great news! We are in your area. Check out the dermatologist who can help you today.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            StreamBuilder(
              stream: db.getAllProviders(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<MedicallUser>> snapshot) {
                return Expanded(
                  child: ListItemsBuilder<MedicallUser>(
                    snapshot: snapshot,
                    itemBuilder: (context, provider) => ProviderListItem(
                      provider: provider,
                      onTap: null,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

//  Future _selectProvider(provider, titles) async {
//    selectedProvider = provider;
//    providerTitles = titles;
//    db.newConsult.provider = selectedProvider;
//    db.newConsult.providerTitles = providerTitles;
//    //await setConsult();
//  }

  void _showMessageDialog(BuildContext context) {
    AppUtil().showFlushBar(
        'Please select one of the providers in order to continue', context);
  }
}
