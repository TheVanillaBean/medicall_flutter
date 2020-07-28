import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/ConsultReview/visit_review_view_model.dart';
import 'package:Medicall/screens/Questions/ImmediateMedicalCare/documentation_text_field.dart';
import 'package:Medicall/screens/Questions/ImmediateMedicalCare/immediate_medical_care_view_model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:provider/provider.dart';

class ImmediateMedicalCare extends StatelessWidget {
  const ImmediateMedicalCare({@required this.model});
  final ImmediateMedicalCareViewModel model;

  static Widget create(
    BuildContext context,
    String documentation,
    VisitReviewViewModel visitReviewViewModel,
  ) {
    return PropertyChangeProvider(
      value: visitReviewViewModel,
      child: ChangeNotifierProvider<ImmediateMedicalCareViewModel>(
        create: (context) =>
            ImmediateMedicalCareViewModel(documentationText: documentation),
        child: Consumer<ImmediateMedicalCareViewModel>(
          builder: (_, model, __) => ImmediateMedicalCare(
            model: model,
          ),
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    String documentation,
    VisitReviewViewModel visitReviewViewModel,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.immediateMedicalCare,
      arguments: {
        'documentation': documentation,
        'visitReviewViewModel': visitReviewViewModel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final VisitReviewViewModel visitReviewViewModel =
        PropertyChangeProvider.of<VisitReviewViewModel>(
      context,
      properties: [VisitReviewVMProperties.followUpStep],
    ).value;
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Immediate Medical Care",
        onPressed: () async {
          if (model.documentationUpdated) {
            final didPressYes = await PlatformAlertDialog(
              title: "Update Documentation?",
              content:
                  "Would you like to save the changes you made to the documentation?",
              defaultActionText: "Yes",
              cancelActionText: "No, don't save",
            ).show(context);
            if (didPressYes) {
              visitReviewViewModel.updateFollowUpStepWith(
                documentation: model.documentationText,
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    'We highly recommend that you call the patient and discuss your recommendations. We suggest you document the conversation below.',
                    style: TextStyle(
                      height: 1.5,
                      fontFamily: 'Roboto Regular',
                      fontSize: 14.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Patient Name: ${visitReviewViewModel.consult.patientUser.fullName}',
                    style: TextStyle(
                      fontFamily: 'Roboto Regular',
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Patient Number: ${visitReviewViewModel.consult.patientUser.phoneNumber}',
                      style: TextStyle(
                        fontFamily: 'Roboto Regular',
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DOCUMENTATION:',
                    style: TextStyle(
                      fontFamily: 'Roboto Thin',
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                DocumentationTextField(
                  initialValue: model.documentationText.length == 0
                      ? 'Spoke with ${visitReviewViewModel.consult.patientUser.fullName} and suggested they go to an Emergency Department for immediate evaluation. I was concerned about the diagnosis and felt the patient needed an inpatient admission, lab monitoring, and hydration. ${visitReviewViewModel.consult.patientUser.fullName} understood and agreed with the plan.'
                      : model.documentationText,
                  maxLines: 10,
                  onChanged: model.updateDocumentationText,
                ),
                SizedBox(height: 30),
                ReusableRaisedButton(
                  title: 'Continue',
                  onPressed: () {
                    visitReviewViewModel.updateFollowUpStepWith(
                      documentation: model.documentationText,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
