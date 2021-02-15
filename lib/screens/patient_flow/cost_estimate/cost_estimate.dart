import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

import 'cost_estimate_view_model.dart';

class CostEstimate extends StatefulWidget {
  final CostEstimateViewModel model;

  const CostEstimate({@required this.model});

  static Widget create(
    BuildContext context,
    Consult consult,
    InsuranceInfo insurance,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<CostEstimateViewModel>(
      create: (context) => CostEstimateViewModel(
        auth: auth,
        userProvider: userProvider,
        consult: consult,
        insurance: insurance,
      ),
      child: Consumer<CostEstimateViewModel>(
        builder: (_, model, __) => CostEstimate(
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
    InsuranceInfo insuranceInfo,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.verifyInsurance,
      arguments: {
        'consult': consult,
        'insurance': insuranceInfo,
      },
    );
  }

  @override
  _CostEstimateState createState() => _CostEstimateState();
}

class _CostEstimateState extends State<CostEstimate> {
  CostEstimateViewModel get model => widget.model;

  Future<void> _submit() async {
    try {
      if (this.model.showCostLabel) {
        model.consult.price = model.estimatedCost;
        StartVisitScreen.show(
          context: context,
          consult: model.consult,
        );
      } else {
        await model.calculateCostWithInsurance();
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TempUserProvider tempUserProvider =
        Provider.of<TempUserProvider>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Your Insurance Cost",
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
      if (model.showCostLabel) ..._buildCostLabel(),
      SizedBox(height: 16),
      _buildCalculateButton(),
      if (true) ..._buildReferralUI(),
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
      readOnly: model.showCostLabel,
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

  List<Widget> _buildReferralUI() {
    return [
      SizedBox(
        height: 24,
      ),
      Center(
        child: Text(
          "Referral Needed:",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: Text(
          "Would you like us to send your PCP an email requesting a referral so see this doctor or would you like to proceed with the visit without using insurance (\$75 cost)?",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Request referral",
          onPressed: () => {},
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed without insurance",
          onPressed: () => {},
        ),
      ),
    ];
  }
}
