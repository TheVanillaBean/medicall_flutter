import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/questionnaire/questions_screen.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class StartVisitScreen extends StatelessWidget {
  final Consult consult;

  const StartVisitScreen({@required this.consult});

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.startVisit,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Visit Questions",
          theme: Theme.of(context),
          onPressed: () {
            TempUserProvider tempUserProvider = Provider.of<TempUserProvider>(
              context,
              listen: false,
            );
            if (tempUserProvider.consult != null) {
              tempUserProvider.consult = null;
              PatientDashboardScreen.show(
                context: context,
                pushReplaceNamed: true,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  TempUserProvider tempUserProvider =
                      Provider.of<TempUserProvider>(
                    context,
                    listen: false,
                  );
                  if (tempUserProvider.consult != null) {
                    tempUserProvider.consult = null;
                  }
                  PatientDashboardScreen.show(
                    context: context,
                    pushReplaceNamed: true,
                  );
                })
          ]),
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if ((userProvider.user as PatientUser).hasMedicalHistory)
                      Text(
                        "We will ask a few questions, starting with general medical history if yours has changed since your last visit and after we will focus on specific visit questions.",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    if (!(userProvider.user as PatientUser).hasMedicalHistory)
                      Text(
                        "We will ask a few questions, starting with general medical history and after we will focus on specific visit questions.",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    Text(
                      "It is important you answer the questions carefully and provide complete information.",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                )),
            if ((userProvider.user as PatientUser).hasMedicalHistory)
              Expanded(
                flex: 1,
                child: FormBuilder(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FormBuilderCheckbox(
                          activeColor: Theme.of(context).colorScheme.primary,
                          attribute: 'medical_history',
                          label: Text(
                            'I have no recent changes in my medical history since last using Medicall',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          initialValue: false,
                        )
                      ],
                    )),
              ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ReusableRaisedButton(
                  title: 'Start Questions',
                  onPressed: () async {
                    await _buildSeenDoctorAlertDialog(context);
                    if (!(userProvider.user as PatientUser).hasMedicalHistory) {
                      QuestionsScreen.show(
                        context: context,
                        displayMedHistory: true,
                        consult: consult,
                      );
                    } else {
                      if (formKey.currentState.saveAndValidate()) {
                        QuestionsScreen.show(
                          context: context,
                          displayMedHistory:
                              !formKey.currentState.value["medical_history"],
                          consult: consult,
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _buildSeenDoctorAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      child: CupertinoAlertDialog(
        title: Text(
          "Have you seen Dr. ${this.consult.providerUser.fullName} in the past years?",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("Yes"),
            textStyle: Theme.of(context).textTheme.bodyText1,
            isDefaultAction: false,
            onPressed: () {
              this.consult.seenDoctorInPastThreeYears = true;
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text("No"),
            textStyle: Theme.of(context).textTheme.bodyText1,
            isDefaultAction: false,
            onPressed: () {
              this.consult.seenDoctorInPastThreeYears = false;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
