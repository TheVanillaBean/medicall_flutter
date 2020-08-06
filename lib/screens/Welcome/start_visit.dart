import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/Questions/questions_screen.dart';
import 'package:Medicall/services/user_provider.dart';
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
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  PatientDashboardScreen.show(
                    context: context,
                    pushReplaceNamed: true,
                  );
                })
          ]),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 0, 40, 15),
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
                        "We will ask a few questions, starting with general medical history if your's has changed since your last visit and after we will focus on specific visit questions.",
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
                flex: 2,
                child: FormBuilder(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FormBuilderCheckbox(
                          attribute: 'medical_history',
                          label: Text(
                              'I have no recent changes in my medical history since last using Medicall'),
                          initialValue: false,
                        )
                      ],
                    )),
              ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: ReusableRaisedButton(
                  title: 'Start Visit',
                  onPressed: () async {
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
}
