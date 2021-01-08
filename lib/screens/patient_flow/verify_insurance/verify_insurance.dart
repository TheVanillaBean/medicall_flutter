import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/form_submit_button.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/verify_insurance/verify_insurance_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyInsurance extends StatelessWidget {
  final Symptom symptom;
  final VerifyInsuranceStateModel model;

  const VerifyInsurance({@required this.model, @required this.symptom});

  static Widget create(BuildContext context, Symptom symptom) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<VerifyInsuranceStateModel>(
      create: (context) => VerifyInsuranceStateModel(
        auth: auth,
      ),
      child: Consumer<VerifyInsuranceStateModel>(
        builder: (_, model, __) => VerifyInsurance(
          model: model,
          symptom: symptom,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Symptom symptom,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.verifyInsurance,
      arguments: {
        'symptom': symptom,
      },
    );
  }

  Future<void> _submit(BuildContext context) async {
    await _navigateToInsuranceURL();
    // SelectProviderScreen.show(
    //   context: context,
    //   symptom: symptom,
    //   state: model.userProvider.user.mailingState,
    // );
  }

  Future<void> _navigateToInsuranceURL() async {
    String url = await model.getURL();
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true);
    } else {
      throw 'Could not launch url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Close,
        title: "Verify Insurance",
        theme: Theme.of(context),
      ),
      body: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Before you can select a doctor, we must verify you insurance first.",
            style: TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          FormSubmitButton(
              text: "Continue",
              onPressed: () async {
                await _submit(context);
              }),
          SizedBox(height: 16),
          if (model.isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
