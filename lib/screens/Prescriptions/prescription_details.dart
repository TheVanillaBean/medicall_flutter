import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_text_field.dart';
import 'package:Medicall/screens/Prescriptions/prescription_details_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class PrescriptionDetails extends StatelessWidget {
  const PrescriptionDetails({
    @required this.model,
  });

  final PrescriptionDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.treatmentStep],
    ).value;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Prescription Details",
        theme: Theme.of(context),
        onPressed: () async {
          if (model.treatmentUpdated) {
            final didPressYes = await PlatformAlertDialog(
              title: "Update Treatment?",
              content:
                  "Would you like to save the changes you made to this treatment option?",
              defaultActionText: "Yes",
              cancelActionText: "No, don't update",
            ).show(context);
            if (didPressYes) {
              visitReviewViewModel.updateTreatmentStepWith(
                selectedTreatment: model.treatmentOptions,
              );
            }
          }
          Navigator.of(context).pop();
        },
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
                    enabled: false,
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
                  ReusableRaisedButton(
                    title: 'Continue',
                    onPressed: () {
                      visitReviewViewModel.updateTreatmentStepWith(
                        selectedTreatment: model.treatmentOptions,
                      );
                      Navigator.of(context).pop();
                    },
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
    VisitReviewViewModel visitReviewViewModel,
  ) {
    final FirestoreDatabase database = Provider.of<FirestoreDatabase>(context);
    final UserProvider provider = Provider.of<UserProvider>(context);
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return PropertyChangeProvider(
      value: visitReviewViewModel,
      child: ChangeNotifierProvider<PrescriptionDetailsViewModel>(
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
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    TreatmentOptions treatmentOptions,
    VisitReviewViewModel visitReviewViewModel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.prescriptionDetails,
      arguments: {
        'treatmentOptions': treatmentOptions,
        'visitReviewViewModel': visitReviewViewModel,
      },
    );
  }
}
