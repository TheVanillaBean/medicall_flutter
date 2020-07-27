import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_text_field.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrescriptionDetails extends StatelessWidget {
  const PrescriptionDetails({this.model});
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
                Icons.arrow_back,
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
                  controller: model.medicationNameController,
                  focusNode: model.medicationNameFocusNode,
                  labelText: 'Medication Name',
                  hint: 'Betamethasone 0.05% cream',
                  onChanged: model.updateMedicationName,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: PrescriptionDetailsTextField(
                          controller: model.quantityController,
                          focusNode: model.quantityFocusNode,
                          labelText: 'Quantity',
                          hint: '60 grams',
                          onChanged: model.updateQuantity,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: PrescriptionDetailsTextField(
                          controller: model.refillsController,
                          focusNode: model.refillsFocusNode,
                          labelText: 'Refills',
                          hint: '1',
                          onChanged: model.updateRefills,
                        ),
                      ),
                    )
                  ],
                ),
                PrescriptionDetailsTextField(
                  controller: model.formController,
                  focusNode: model.formFocusNode,
                  labelText: 'Form',
                  hint: 'Cream',
                  onChanged: model.updateForm,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: PrescriptionDetailsTextField(
                          controller: model.doseController,
                          focusNode: model.doseFocusNode,
                          labelText: 'Dose',
                          hint: 'Thin layer',
                          onChanged: model.updateDose,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: PrescriptionDetailsTextField(
                          controller: model.frequencyController,
                          focusNode: model.frequencyFocusNode,
                          labelText: 'Frequency',
                          hint: '2 times daily',
                          onChanged: model.updateFrequency,
                        ),
                      ),
                    )
                  ],
                ),
                PrescriptionDetailsTextField(
                  controller: model.instructionsController,
                  focusNode: model.instructionsFocusNode,
                  maxLines: 8,
                  labelText: 'Instructions',
                  hint:
                      'Apply thin layer of ointment to cover the affected area. Do not use for more than 14 days per month.',
                  onChanged: model.updateInstructions,
                ),
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ReusableRaisedButton(
                    title: 'Done',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget create(BuildContext context) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<PrescriptionDetailsViewModel>(
      create: (context) => PrescriptionDetailsViewModel(
        database: database,
        userProvider: provider,
        auth: auth,
      ),
      child: Consumer<PrescriptionDetailsViewModel>(
        builder: (_, model, __) => PrescriptionDetails(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushNamed(Routes.prescriptionDetails);
  }
}
