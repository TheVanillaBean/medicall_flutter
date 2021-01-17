import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/verify_insurance/verify_insurance_state_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class VerifyInsurance extends StatefulWidget {
  final VerifyInsuranceStateModel model;

  const VerifyInsurance({@required this.model});

  static Widget create(BuildContext context, Consult consult) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<VerifyInsuranceStateModel>(
      create: (context) => VerifyInsuranceStateModel(
        auth: auth,
        userProvider: userProvider,
        consult: consult,
      ),
      child: Consumer<VerifyInsuranceStateModel>(
        builder: (_, model, __) => VerifyInsurance(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.verifyInsurance,
      arguments: {
        'consult': consult,
      },
    );
  }

  @override
  _VerifyInsuranceState createState() => _VerifyInsuranceState();
}

class _VerifyInsuranceState extends State<VerifyInsurance> {
  VerifyInsuranceStateModel get model => widget.model;

  Future<void> _submit() async {
    try {
      await model.calculateCostWithInsurance();
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Your Cost With Insurance",
        theme: Theme.of(context),
      ),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildChildren(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    return <Widget>[
      SizedBox(
        height: 60,
      ),
      Center(
        child: Text(
          "Enter your Member ID",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(height: 8),
      _buildMemberIDForm(),
      SizedBox(height: 16),
      _buildCalculateButton(),
      if (model.showCostLabel) ..._buildCostLabel(),
      if (model.isLoading)
        Center(
          child: CircularProgressIndicator(),
        ),
    ];
  }

  Widget _buildMemberIDForm() {
    return TextField(
      minLines: 1,
      keyboardType: TextInputType.text,
      readOnly: false,
      onChanged: model.updateMemberID,
      onSubmitted: (state) {
        _submit();
      },
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.grey.withAlpha(20),
        labelText: 'Member ID',
        labelStyle: TextStyle(color: Colors.black45),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: _submit,
    );
  }

  List<Widget> _buildCostLabel() {
    return [
      SizedBox(
        height: 24,
      ),
      Center(
        child: Text(
          "Your real time cost estimate:",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Center(
        child: Text(
          "\$${model.estimatedCost}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 8),
    ];
  }
}
