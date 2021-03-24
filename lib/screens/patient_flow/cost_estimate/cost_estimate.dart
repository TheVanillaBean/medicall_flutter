import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/cost_estimate/request_referral.dart';
import 'package:Medicall/screens/patient_flow/dashboard/patient_dashboard.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';

import 'cost_estimate_view_model.dart';

class CostEstimate extends StatelessWidget {
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
    final FirestoreDatabase database =
        Provider.of<FirestoreDatabase>(context, listen: false);
    return ChangeNotifierProvider<CostEstimateViewModel>(
      create: (context) => CostEstimateViewModel(
        auth: auth,
        userProvider: userProvider,
        firestoreDatabase: database,
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

  Future<void> _submit(BuildContext context) async {
    if (model.insuranceInfo.costEstimate > -1) {
      model.consult.price = model.insuranceInfo.costEstimate;
    }
    if (model.insuranceInfo.coverageResponse == CoverageResponse.Medicare) {
      model.consult.price = 20;
    }
    model.consult.insurancePayment = true;
    model.consult.insuranceInfo = model.insuranceInfo;
    StartVisitScreen.show(
      context: context,
      consult: model.consult,
    );
  }

  Future<void> _viewOutOfNetworkProviders(BuildContext context) async {
    SelectProviderScreen.show(
      context: context,
      symptom: model.consult.symptom,
      insurance: model.insuranceInfo.insurance,
      state: model.userProvider.user.mailingState,
      filter: SelectProviderFilter.OutOfNetwork,
    );
  }

  Future<void> _obtainTrueCostEstimate(BuildContext context) async {
    try {
      if (await this.model.requestCostEstimate()) {
        AppUtil().showFlushBar(
            "You have successfully requested a cost estimate. You will receive a response email within 48 hours.",
            context);
      } else {
        AppUtil().showFlushBar(
            "There was an issue requesting a a cost estimate for you. Please contact omar@medicall.com",
            context);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _navigateToRequestReferral(BuildContext context) async {
    RequestReferral.show(
        context: context,
        consult: this.model.consult,
        insuranceInfo: this.model.insuranceInfo);
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
                children: _buildChildren(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return <Widget>[
      SizedBox(
        height: 32,
      ),
      if (model.insuranceInfo.coverageResponse == CoverageResponse.Medicare)
        ..._buildMedicareUI(context),
      if (model.costEstimateGreaterThanSelfPay)
        ..._buildEstimateGreaterThanSelfPayUI(context)
      else if (model.costEstimateLessThanSelfPay)
        ..._buildValidCostUI(context)
      else if (model.insuranceInfo.coverageResponse ==
          CoverageResponse.NoCostEstimate)
        ..._buildInvalidCostUI(context)
      else if (model.insuranceInfo.coverageResponse ==
          CoverageResponse.ReferralNeeded)
        ..._buildRequestReferralUI(context),
      SizedBox(height: 16),
      if (model.isLoading)
        Center(
          child: CircularProgressIndicator(),
        ),
    ];
  }

  Widget _buildContinueButton(BuildContext context) {
    return ReusableRaisedButton(
      title: "Continue",
      onPressed: () => _submit(context),
    );
  }

  Widget _buildOONButton(BuildContext context) {
    return Center(
      child: ReusableRaisedButton(
        title: "Proceed without insurance for \$75+",
        onPressed: () => _viewOutOfNetworkProviders(context),
      ),
    );
  }

  List<Widget> _buildValidCostUI(BuildContext context) {
    return [
      Center(
        child: Text(
          "Your cost for this visit:",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      Center(
        child: Text(
          "\$${model.insuranceInfo.costEstimate}",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 16),
      _buildContinueButton(context),
    ];
  }

  List<Widget> _buildMedicareUI(BuildContext context) {
    return [
      Center(
        child: Text(
          "Due to this insurance being Medicare, the cost cannot be determined until the final billing process. As such, we will place a \$20 hold on your card during the payment step. We will send you the cost once your doctors billing staff completes the billing for this visit. We know this seems odd, but it is unfortunately the way Medicare billing is processed.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 8),
      _buildContinueButton(context),
      SizedBox(height: 12),
    ];
  }

  List<Widget> _buildInvalidCostUI(BuildContext context) {
    return [
      Center(
        child: Text(
          "We were not able to determine the cost for your visit. "
          "You can get a visit now without using insurance or you "
          "can contact this doctor’s office to get the visit cost "
          "(may take up to 1 business day).\n",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Obtain visit cost",
          onPressed: !model.requestedCostEstimate
              ? () => _obtainTrueCostEstimate(context)
              : null,
        ),
      ),
      SizedBox(height: 16),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed without insurance for \$75+",
          onPressed: () => _viewOutOfNetworkProviders(context),
        ),
      ),
    ];
  }

  List<Widget> _buildEstimateGreaterThanSelfPayUI(BuildContext context) {
    return [
      Center(
        child: Text(
          "Your cost for this visit: \$${model.insuranceInfo.costEstimate}",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: Text(
          "To lower your cost, you have an option to proceed without insurance, "
          "which is cheaper in your case (as low as \$75) compared to in-network providers contracted "
          "with your insurance.\n",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      _buildOONButton(context),
      SizedBox(height: 12),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed with my insurance",
          onPressed: () => _submit(context),
        ),
      ),
    ];
  }

  List<Widget> _buildRequestReferralUI(BuildContext context) {
    return [
      Center(
        child: Text(
          "Your cost for this visit:",
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
          "Your insurance company requires a referral. You can still complete today’s visit, but your doctor will not review it (and you will not be charged) until the insurance company approves the referral. If you do not want to wait for a referral, you can proceed without insurance for as low as \$75.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Request referral",
          onPressed: model.consult.state != ConsultStatus.ReferralRequested
              ? () => _navigateToRequestReferral(context)
              : null,
        ),
      ),
      SizedBox(height: 12),
      _buildOONButton(context),
    ];
  }
}
