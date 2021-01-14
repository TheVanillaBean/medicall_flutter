import 'dart:async';

import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/select_provider/provider_detail.dart';
import 'package:Medicall/screens/patient_flow/select_provider/provider_list_item.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectProviderScreen extends StatelessWidget {
  final Symptom symptom;
  final String state;
  final String insurance;

  const SelectProviderScreen({
    @required this.symptom,
    @required this.state,
    @required this.insurance,
  });

  static Future<void> show({
    BuildContext context,
    Symptom symptom,
    String state,
    String insurance,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.selectProvider,
      arguments: {
        'symptom': symptom,
        'state': state,
        'insurance': insurance,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NonAuthDatabase db = Provider.of<NonAuthDatabase>(context);
    MedicallUser medicallUser;
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
                    PatientDashboardScreen.show(
                        context: context, pushReplaceNamed: true);
                  } else {
                    WelcomeScreen.show(context: context);
                  }
                })
          ]),
      body: StreamBuilder(
        stream: db.getAllProviders(state: state, symptom: this.symptom.name),
        builder:
            (BuildContext context, AsyncSnapshot<List<ProviderUser>> snapshot) {
          List<ProviderUser> inNetworkProviders = [];
          List<ProviderUser> outNetworkProviders = [];
          if (snapshot.hasData) {
            inNetworkProviders = snapshot.data
                .where((provider) =>
                    provider.acceptedInsurances.contains(this.insurance))
                .toList();
            outNetworkProviders = snapshot.data
                .where((provider) =>
                    !provider.acceptedInsurances.contains(this.insurance))
                .toList();
          }
          return Column(
            children: [
              inNetworkProviders.length > 0
                  ? _buildInNetworkList(context, inNetworkProviders)
                  : outNetworkProviders.length > 0
                      ? _buildOutNetworkList(context, outNetworkProviders)
                      : Text("None found, check back at a later date."),
            ],
          );
        },
      ),
    );
  }

  Stack _buildInNetworkList(
      BuildContext context, List<ProviderUser> inNetworkProviders) {
    return Stack(
      children: <Widget>[
        ListItemsBuilder<ProviderUser>(
          snapshot: null,
          itemsList: inNetworkProviders,
          emptyContentWidget: const EmptyContent(
            title: '',
            message:
                'Medicall does not currently have providers who take your insurance',
          ),
          itemBuilder: (context, provider) => ProviderListItem(
            provider: provider,
            inNetwork: true,
            onTap: () => ProviderDetailScreen.show(
              context: context,
              provider: provider,
              symptom: symptom,
              inNetwork: true,
            ),
          ),
        )
      ],
    );
  }

  Stack _buildOutNetworkList(
      BuildContext context, List<ProviderUser> outNetworkProviders) {
    return Stack(
      children: <Widget>[
        ListItemsBuilder<ProviderUser>(
          snapshot: null,
          itemsList: outNetworkProviders,
          emptyContentWidget: const EmptyContent(
            title:
                'Medicall does not currently have providers who do not take your insurance',
            message: '',
          ),
          itemBuilder: (context, provider) => ProviderListItem(
            provider: provider,
            inNetwork: false,
            onTap: () => ProviderDetailScreen.show(
              context: context,
              provider: provider,
              symptom: symptom,
              inNetwork: false,
            ),
          ),
        )
      ],
    );
  }
}
