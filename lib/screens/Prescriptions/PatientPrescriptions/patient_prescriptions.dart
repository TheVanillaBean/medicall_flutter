import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/empty_content.dart';
import 'package:Medicall/common_widgets/list_items_builder.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Prescriptions/PatientPrescriptions/patient_prescriptions_list_tem.dart';
import 'package:Medicall/screens/Prescriptions/PatientPrescriptions/patient_prescriptions_view_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientPrescriptions extends StatelessWidget {
  final PatientPrescriptionsViewModel model;

  const PatientPrescriptions({@required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "My Prescriptions",
        theme: Theme.of(context),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: StreamBuilder<Object>(
              stream: model.treatmentOptionsStream.stream,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    ListItemsBuilder<TreatmentOptions>(
                      scrollable: false,
                      snapshot: null,
                      itemsList: snapshot.data,
                      emptyContentWidget: EmptyContent(
                        title: "You do not have any prescriptions",
                        message: "",
                      ),
                      itemBuilder: (context, treatment) =>
                          PatientPrescriptionsListItem(
                        treatment: treatment,
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  static Widget create(BuildContext context) {
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final UserProvider provider =
        Provider.of<UserProvider>(context, listen: false);

    return ChangeNotifierProvider<PatientPrescriptionsViewModel>(
      create: (context) => PatientPrescriptionsViewModel(
        database: database,
        userProvider: provider,
      ),
      child: Consumer<PatientPrescriptionsViewModel>(
        builder: (_, model, __) => PatientPrescriptions(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.patientPrescriptions,
    );
  }
}
