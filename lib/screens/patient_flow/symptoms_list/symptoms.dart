import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/drawer_menu/drawer_menu.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/cosmetic_symptoms.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptom_detail.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptom_list_item.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms_view_model.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomsScreen extends StatelessWidget {
  final SymptomsViewModel model;

  const SymptomsScreen({@required this.model});

  static Widget create(BuildContext context) {
    NonAuthDatabase db = Provider.of<NonAuthDatabase>(context, listen: false);

    return ChangeNotifierProvider<SymptomsViewModel>(
      create: (context) => SymptomsViewModel(
        database: db,
      ),
      child: Consumer<SymptomsViewModel>(
        builder: (_, model, __) => SymptomsScreen(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(Routes.symptoms);
  }

  @override
  Widget build(BuildContext context) {
    final NonAuthDatabase nonAuthDatabase =
        Provider.of<NonAuthDatabase>(context, listen: false);
    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "How can we help?",
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
                      context: context,
                      pushReplaceNamed: true,
                    );
                  } else {
                    WelcomeScreen.show(context: context);
                  }
                })
          ]),
      drawer: DrawerMenu(),
      body: StreamBuilder<List<Symptom>>(
        stream: model.symptomsStream.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Symptom>> snapshot) {
          return Column(
            children: <Widget>[
              buildVisitFeeContainer(context),
              Expanded(
                child: ListItemsBuilder<Symptom>(
                  snapshot: snapshot,
                  itemBuilder: (context, symptom) => SymptomListItem(
                    symptom: symptom,
                    onTap: symptom.category == "cosmetic"
                        ? () => CosmeticSymptomsScreen.show(
                              context: context,
                              symptoms: model.cosmeticSymptoms,
                            )
                        : () async {
                            symptom.photoUrl =
                                await nonAuthDatabase.getSymptomPhotoURL(
                                    symptom: '${symptom.name}.jpg');
                            return SymptomDetailScreen.show(
                              context: context,
                              symptom: symptom,
                            );
                          },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildVisitFeeContainer(context) {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: Column(
        children: <Widget>[
          Text(
            'Visit Fee: \$65',
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            'No Insurance Needed',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 16),
          Text(
            'This is the price for the provider\'s services. Prescriptions or in person follow-up care not included.',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
