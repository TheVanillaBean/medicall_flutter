import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'documentation_text_field.dart';
import 'immediate_medical_care_view_model.dart';

class ImmediateMedicalCare extends StatelessWidget {
  const ImmediateMedicalCare({@required this.model});
  final ImmediateMedicalCareViewModel model;

  static Widget create(
    BuildContext context,
    String documentation,
    PatientUser patientUser,
  ) {
    return ChangeNotifierProvider<ImmediateMedicalCareViewModel>(
      create: (context) => ImmediateMedicalCareViewModel(
        documentationText: documentation,
        patientUser: patientUser,
      ),
      child: Consumer<ImmediateMedicalCareViewModel>(
        builder: (_, model, __) => ImmediateMedicalCare(
          model: model,
        ),
      ),
    );
  }

  static Future<String> show({
    BuildContext context,
    String documentation,
    PatientUser patientUser,
  }) async {
    return await Navigator.of(context).pushNamed(
      Routes.immediateMedicalCare,
      arguments: {
        'documentation': documentation,
        "patientUser": patientUser,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(model.documentationText);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Immediate Medical Care",
          theme: Theme.of(context),
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
                Navigator.of(context).pop(model.documentationText);
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
                      'Patient Name: ${model.patientUser.fullName}',
                      style: TextStyle(
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
                        'Patient Number: ${model.patientUser.phoneNumber}',
                        style: TextStyle(
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
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  DocumentationTextField(
                    initialValue: model.documentationText.length == 0
                        ? 'Spoke with ${model.patientUser.fullName} and suggested they go to an Emergency Department for immediate evaluation. I was concerned about the diagnosis and felt the patient needed an inpatient admission, lab monitoring, and hydration. ${model.patientUser.fullName} understood and agreed with the plan.'
                        : model.documentationText,
                    maxLines: 10,
                    onChanged: model.updateDocumentationText,
                  ),
                  SizedBox(height: 30),
                  ReusableRaisedButton(
                    title: 'Continue',
                    onPressed: () {
                      Navigator.of(context).pop(model.documentationText);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
