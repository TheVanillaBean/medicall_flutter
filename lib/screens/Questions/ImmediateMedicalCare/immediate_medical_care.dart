import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/ImmediateMedicalCare/documentation_text_field.dart';
import 'package:Medicall/screens/Questions/ImmediateMedicalCare/immediate_medical_care_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImmediateMedicalCare extends StatelessWidget {
  const ImmediateMedicalCare({@required this.consult, @required this.model});
  final Consult consult;
  final ImmediateMedicalCareViewModel model;

  static Future<void> show({
    BuildContext context,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.immediateMedicalCare,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        centerTitle: true,
        title: Text('Immediate Medical Care',
            style: TextStyle(
              fontFamily: 'Roboto Thin',
              fontSize: 18,
              color: Colors.blue,
            )),
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
                    'Patient Name: Omar Badri',
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
                      'Patient Number: 480-861-0816',
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
                  hint:
                      'Spoke with Mr. Patient and suggested he go to an Emergency Department for immediate evaluation. I was concerned about the diffuse blistering and felt he needed an inpatient admission, lab monitoring, and hydration. He understood and agreed with the plan. ',
                  maxLines: 10,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  child: CustomRaisedButton(
                    color: Colors.blue,
                    borderRadius: 14,
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Roboto Medium',
                        fontSize: 14,
                      ),
                    ),
                    onPressed: null,
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
    return ChangeNotifierProvider<ImmediateMedicalCareViewModel>(
      create: (context) => ImmediateMedicalCareViewModel(
        database: database,
        userProvider: provider,
        auth: auth,
      ),
      child: Consumer<ImmediateMedicalCareViewModel>(
        builder: (_, model, __) =>
            ImmediateMedicalCare(model: model, consult: null),
      ),
    );
  }
}
