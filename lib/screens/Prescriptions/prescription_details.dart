import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_text_field.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrescriptionDetails extends StatelessWidget {
  const PrescriptionDetails({
    @required this.model,
  });

  final PrescriptionDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
        title: Text(
          'Prescription Details',
          style: TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PrescriptionDetailsTextField(
                    focusNode: model.medicationNameFocusNode,
                    labelText: 'Medication Name',
                    initialValue: this.model.treatmentOptions.medicationName,
                    onChanged: model.updateMedicationName,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: PrescriptionDetailsTextField(
                            focusNode: model.quantityFocusNode,
                            labelText: 'Quantity',
                            initialValue: this.model.treatmentOptions.quantity,
                            onChanged: model.updateQuantity,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: PrescriptionDetailsTextField(
                            focusNode: model.refillsFocusNode,
                            labelText: 'Refills',
                            initialValue: this.model.treatmentOptions.refills,
                            onChanged: model.updateRefills,
                          ),
                        ),
                      )
                    ],
                  ),
                  PrescriptionDetailsTextField(
                    focusNode: model.formFocusNode,
                    labelText: 'Form',
                    initialValue: this.model.treatmentOptions.form,
                    onChanged: model.updateForm,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: PrescriptionDetailsTextField(
                            focusNode: model.doseFocusNode,
                            labelText: 'Dose',
                            initialValue: this.model.treatmentOptions.dose,
                            onChanged: model.updateDose,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: PrescriptionDetailsTextField(
                            focusNode: model.frequencyFocusNode,
                            labelText: 'Frequency',
                            initialValue: this.model.treatmentOptions.frequency,
                            onChanged: model.updateFrequency,
                          ),
                        ),
                      )
                    ],
                  ),
                  PrescriptionDetailsTextField(
                    focusNode: model.instructionsFocusNode,
                    maxLines: 8,
                    labelText: 'Instructions',
                    initialValue: this.model.treatmentOptions.instructions,
                    onChanged: model.updateInstructions,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: RaisedButton(
                      onPressed: () {},
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text('Done'),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )),
      ),
    );
  }

  static Widget create(
    BuildContext context,
    TreatmentOptions treatmentOptions,
  ) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<PrescriptionDetailsViewModel>(
      create: (context) => PrescriptionDetailsViewModel(
        database: database,
        userProvider: provider,
        auth: auth,
        treatmentOptions: treatmentOptions,
      ),
      child: Consumer<PrescriptionDetailsViewModel>(
        builder: (_, model, __) => PrescriptionDetails(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    TreatmentOptions treatmentOptions,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.prescriptionDetails,
      arguments: {
        'treatmentOptions': treatmentOptions,
      },
    );
  }
}
