import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/drawer_menu.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptom_detail.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptom_list_item.dart';
import 'package:Medicall/screens/shared/welcome.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CosmeticSymptomsScreen extends StatelessWidget {
  final List<Symptom> symptoms;

  const CosmeticSymptomsScreen({@required this.symptoms});

  static Future<void> show({
    BuildContext context,
    List<Symptom> symptoms,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.cosmeticSymptoms,
      arguments: {
        'symptoms': symptoms,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MedicallUser medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Cosmetic Symptoms",
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
      body: Column(
        children: <Widget>[
          buildVisitFeeContainer(context),
          Expanded(
            child: ListItemsBuilder<Symptom>(
              snapshot: null,
              itemsList: this.symptoms,
              itemBuilder: (context, symptom) => SymptomListItem(
                symptom: symptom,
                onTap: () => SymptomDetailScreen.show(
                  context: context,
                  symptom: symptom,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVisitFeeContainer(context) {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: Column(
        children: <Widget>[
          Text(
            'Visit Fee: \$49',
            style: Theme.of(context).textTheme.headline5,
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
