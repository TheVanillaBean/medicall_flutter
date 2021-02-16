import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/cost_estimate/cost_estimate.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/enter_member_id/enter_member_id_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

class EnterMemberId extends StatefulWidget {
  final EnterMemberIdViewModel model;

  const EnterMemberId({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    String insurance,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<EnterMemberIdViewModel>(
      create: (context) => EnterMemberIdViewModel(
        auth: auth,
        userProvider: userProvider,
        consult: consult,
        insurance: insurance,
      ),
      child: Consumer<EnterMemberIdViewModel>(
        builder: (_, model, __) => EnterMemberId(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
    String insurance,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.verifyInsurance,
      arguments: {
        'consult': consult,
        'insurance': insurance,
      },
    );
  }

  @override
  _EnterMemberIdState createState() => _EnterMemberIdState();
}

class _EnterMemberIdState extends State<EnterMemberId> {
  EnterMemberIdViewModel get model => widget.model;

  Future<void> _submit() async {
    try {
      if (this.model.successfullyValidatedInsurance) {
        CostEstimate.show(context: context, insuranceInfo: model.insuranceInfo);
      } else {
        await model.calculateCostWithInsurance();
      }
    } catch (e) {
      model.updateWith(successfullyValidatedInsurance: false, errorMessage: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Determine Insurance Cost",
          theme: Theme.of(context),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if (tempUserProvider.consult != null) {
                    PatientDashboardScreen.show(
                        context: context, pushReplaceNamed: true);
                  } else {
                    Navigator.pop(context);
                  }
                })
          ]),
      body: KeyboardDismisser(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
        height: 32,
      ),
      Center(
        child: Text(
          "Enter your Member ID",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(height: 8),
      _buildMemberIDForm(),
      if (model.showErrorMessage || model.successfullyValidatedInsurance)
        ..._buildResponseLabel(),
      SizedBox(height: 16),
      _buildVerifyButton(),
      SizedBox(height: 16),
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
      onSubmitted: (state) async {
        await _submit();
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

  Widget _buildVerifyButton() {
    return ReusableRaisedButton(
      title: this.model.continueBtnText,
      onPressed: _submit,
    );
  }

  List<Widget> _buildResponseLabel() {
    return [
      SizedBox(
        height: 24,
      ),
      Center(
        child: Text(
          "${model.labelText}",
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.center,
        ),
      ),
      SizedBox(height: 8),
    ];
  }
}
