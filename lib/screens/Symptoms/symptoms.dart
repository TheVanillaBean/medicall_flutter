import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Symptoms/symptom_detail.dart';
import 'package:Medicall/screens/Symptoms/symptom_list_item.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SymptomsScreen extends StatelessWidget {
  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.symptoms);
  }

  @override
  Widget build(BuildContext context) {
    NonAuthDatabase db = Provider.of<NonAuthDatabase>(context, listen: false);
    User medicallUser;
    try {
      medicallUser = Provider.of<UserProvider>(context).user;
    } catch (e) {}
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "How can we help you today?",
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
      drawer: DrawerMenu(),
      body: StreamBuilder<List<Symptom>>(
        stream: db.symptomsStream(),
        builder: (BuildContext context, AsyncSnapshot<List<Symptom>> snapshot) {
          return Column(
            children: <Widget>[
              buildVisitFeeContainer(),
              Expanded(
                flex: 9,
                child: ListItemsBuilder<Symptom>(
                  snapshot: snapshot,
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
          );
        },
      ),
    );
  }

  Widget buildVisitFeeContainer() {
    return Container(
      padding: EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: Column(
        children: <Widget>[
          Text(
            'Visit Fee \$49',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            ' This is the price for the doctor\'s services. Prescriptions or in person follow-up care not included.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
