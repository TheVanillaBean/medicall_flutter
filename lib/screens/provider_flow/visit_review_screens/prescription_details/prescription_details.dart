import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult-review/treatment_options.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_details_text_field.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/prescription_details/prescription_details_view_model.dart';
import 'package:Medicall/screens/provider_flow/visit_review_screens/visit_review/visit_review_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class PrescriptionDetails extends StatelessWidget {
  const PrescriptionDetails({
    @required this.model,
  });

  final PrescriptionDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!model.allFieldsValidated) {
          Navigator.of(context).pop(null);
          return false;
        } else {
          if (model.treatmentUpdated) {
            final didPressYes = await PlatformAlertDialog(
              title: "Update Treatment?",
              content:
                  "Would you like to save the changes you made to this treatment option?",
              defaultActionText: "Yes",
              cancelActionText: "No, don't update",
            ).show(context);
            if (!didPressYes) {
              Navigator.of(context).pop(null);
              return false;
            } else {
              Navigator.of(context).pop(model.treatmentOptions);
              return false;
            }
          } else {
            Navigator.of(context).pop(null);
            return false;
          }
        }
      },
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Prescription Details",
          theme: Theme.of(context),
        ),
        body: KeyboardDismisser(
          child: SingleChildScrollView(
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
                        initialValue:
                            this.model.treatmentOptions.medicationName,
                        onChanged: model.updateMedicationName,
                        enabled: this.model.isCurrentTreatmentOther,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: PrescriptionDetailsTextField(
                                focusNode: model.quantityFocusNode,
                                labelText: 'Quantity',
                                initialValue:
                                    this.model.treatmentOptions.quantity,
                                onChanged: model.updateQuantity,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: PrescriptionDetailsTextField(
                                focusNode: model.refillsFocusNode,
                                labelText: 'Refills',
                                initialValue:
                                    this.model.treatmentOptions.refills,
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
                                initialValue:
                                    this.model.treatmentOptions.frequency,
                                onChanged: model.updateFrequency,
                              ),
                            ),
                          )
                        ],
                      ),
                      PrescriptionDetailsTextField(
                        keyboardType: TextInputType.multiline,
                        focusNode: model.instructionsFocusNode,
                        maxLines: null,
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
                          if (!model.allFieldsValidated) {
                            AppUtil().showFlushBar(
                                "Please fill out all fields", context);
                          } else {
                            Navigator.of(context).pop(model.treatmentOptions);
                          }
                        },
                      ),
                    ],
                  ),
                )),
          ),
        ),
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

  static Future<List<TreatmentOptions>> show({
    BuildContext context,
    TreatmentOptions treatmentOptions,
    VisitReviewViewModel visitReviewViewModel,
  }) async {
    final List<TreatmentOptions> returnedTreatmentOptions =
        await Navigator.of(context).pushNamed<List<TreatmentOptions>>(
      Routes.prescriptionDetails,
      arguments: {
        'treatmentOptions': treatmentOptions,
        'visitReviewViewModel': visitReviewViewModel,
      },
    );
    return returnedTreatmentOptions;
  }
}
