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
    InsuranceInfo insuranceInfo,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return ChangeNotifierProvider<CostEstimateViewModel>(
      create: (context) => CostEstimateViewModel(
        auth: auth,
        userProvider: userProvider,
        consult: consult,
        insuranceInfo: insuranceInfo,
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
      Routes.costEstimate,
      arguments: {
        'consult': consult,
        'insurance_info': insuranceInfo,
      },
    );
  }

  @override
  _CostEstimateState createState() => _CostEstimateState();
}

class _CostEstimateState extends State<CostEstimate> {
  CostEstimateViewModel get model => widget.model;

  Future<void> _submit() async {
    if (model.insuranceInfo.costEstimate > -1) {
      model.consult.price = model.insuranceInfo.costEstimate;
    }
    model.consult.insurancePayment = true;
    model.consult.insuranceInfo = model.insuranceInfo;
    StartVisitScreen.show(
      context: context,
      consult: model.consult,
    );
  }

  Future<void> _submitReferral() async {}

  Future<void> _proceedWithoutInsurance() async {
    StartVisitScreen.show(
      context: context,
      consult: model.consult,
    );
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
      if (model.insuranceInfo.coverageResponse ==
          CoverageResponse.ValidCostEstimate)
        ..._buildValidCostLabel()
      else if (model.insuranceInfo.coverageResponse ==
          CoverageResponse.ReferralNeeded)
        ..._buildReferralUI(),
      SizedBox(height: 16),
      if (model.isLoading)
        Center(
          child: CircularProgressIndicator(),
        ),
    ];
  }

  Widget _buildContinueButton() {
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: _submit,
    );
  }

  List<Widget> _buildValidCostLabel() {
    return [
      Center(
        child: Text(
          "Your real time cost estimate:",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Center(
        child: Text(
          "\$${model.insuranceInfo.costEstimate}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 8),
      _buildContinueButton(),
    ];
  }

  List<Widget> _buildReferralUI() {
    return [
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
          "Your insurance plan is an HMO, which means that you need a referral from your primary care provider (PCP) before your insurance will pay for this visit (i.e. your PCP has to explicitly approve this visit). Would you like us to do this on your behalf? By doing so, you will have to pay our full price of \$75.00 right now, but when we handle the insurance processing, we will reimburse your account with the appropriate funds based on what your insurance covers. This is a tedious process, but our aim is to make it as transparent as possible. If you have any questions, please email omar@medicall.com and we will respond quickly. You also have the option to proceed without using insurance.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Request referral",
          onPressed: _submitReferral,
        ),
      ),
      SizedBox(
        height: 12,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed without insurance",
          onPressed: _proceedWithoutInsurance,
        ),
      ),
    ];
  }
}
