import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/routing/router.dart';
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

  @override
  _CostEstimateState createState() => _CostEstimateState();
}

class _CostEstimateState extends State<CostEstimate> {
  final TextEditingController _pcpController = TextEditingController();
  final FocusNode _pcpFocusNode = FocusNode();

  CostEstimateViewModel get model => widget.model;

  Future<void> _submit() async {
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

  Future<void> _viewOutOfNetworkProviders() async {
    SelectProviderScreen.show(
      context: context,
      symptom: model.consult.symptom,
      insurance: model.insuranceInfo.insurance,
      state: model.userProvider.user.mailingState,
      filter: SelectProviderFilter.OutOfNetwork,
    );
  }

  Future<void> _submitReferral() async {
    try {
      if (await this.model.requestReferral()) {
        bool didPressYes = await PlatformAlertDialog(
          title: "Proceed with visit",
          content:
              "You have successfully requested a referral and you will receive a follow up email within 24 hours. In the meantime, you can still proceed with filling out visit information. You will only be asked to pay once your referral is approved.",
          defaultActionText: "Yes, proceed",
          cancelActionText: "No, stay",
        ).show(context);

        if (didPressYes) {
          StartVisitScreen.show(
            context: context,
            consult: model.consult,
          );
          return false;
        } else {
          return false;
        }
      } else {
        AppUtil().showFlushBar(
            "There was an issue requesting a referral for you. Please contact omar@medicall.com",
            context);
        model.updateWith(isLoading: false);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  Future<void> _obtainTrueCostEstimate() async {
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
      if (model.insuranceInfo.coverageResponse == CoverageResponse.Medicare)
        ..._buildMedicareUI(),
      if (model.costEstimateGreaterThanSelfPay)
        ..._buildEstimateGreaterThanSelfPayUI()
      else if (model.costEstimateLessThanSelfPay)
        ..._buildValidCostUI()
      else if (model.insuranceInfo.coverageResponse ==
          CoverageResponse.NoCostEstimate)
        ..._buildInvalidCostUI()
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

  Widget _buildOONButton() {
    return Center(
      child: ReusableRaisedButton(
        title: "Proceed with out-of-network providers",
        onPressed: _viewOutOfNetworkProviders,
      ),
    );
  }

  List<Widget> _buildValidCostUI() {
    return [
      Center(
        child: Text(
          "Your real-time cost estimate:",
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

  List<Widget> _buildMedicareUI() {
    return [
      Center(
        child: Text(
          "Due to this insurance being Medicare, the cost cannot be determined until the final billing process. As such, we will place a \$20 hold on your card during the payment step. We will send you the cost once your doctors billing staff completes the billing for this visit. We know this seems odd, but it is unfortunately the way Medicare billing is processed.",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(height: 8),
      _buildContinueButton(),
      SizedBox(height: 12),
    ];
  }

  List<Widget> _buildInvalidCostUI() {
    return [
      Center(
        child: Text(
          "We were not able to determine your real-time cost. You now have an option to obtain a true cost estimate from your doctor or proceed with out-of-network providers.\n\n"
          "Please select how you would like to proceed:",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: ReusableRaisedButton(
          title: "Obtain true cost estimate",
          onPressed:
              !model.requestedCostEstimate ? _obtainTrueCostEstimate : null,
        ),
      ),
      SizedBox(height: 12),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed out-of-network",
          onPressed: _viewOutOfNetworkProviders,
        ),
      ),
    ];
  }

  List<Widget> _buildEstimateGreaterThanSelfPayUI() {
    return [
      Center(
        child: Text(
          "Your real time cost estimate: \$${model.insuranceInfo.costEstimate}",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: Text(
          "It appears that your real time cost estimate is greater than \$75. To lower your cost, you have an option to choose out-of-network providers that may offer you greater savings compared to in-network providers contracted with your insurance.\n\nPlease select how you would like to proceed:",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      _buildOONButton(),
      SizedBox(height: 12),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed with my insurance",
          onPressed: _submit,
        ),
      ),
    ];
  }

  //Referral UI

  List<Widget> _buildReferralUI() {
    List<Widget> referralUI = [];
    if (model.insuranceInfo.providerName != null) {
      referralUI.addAll(_buildPCPValidationUI());
      if (model.showPCPTextField) {
        referralUI.add(_buildPCPTextField());
      }
    } else {
      referralUI.add(_buildPCPTextField());
    }

    if (model.pcp.isNotEmpty) {
      referralUI.addAll(_buildRequestReferralUI());
    }

    return referralUI;
  }

  List<Widget> _buildPCPValidationUI() {
    return [
      Center(
        child: Text(
          "Is ${model.insuranceInfo.providerName} your Primary Care Provider (PCP)?",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      ReusableRaisedButton(
        title: "Yes",
        onPressed: () => model.updateWith(
            showPCPTextField: false, pcp: model.insuranceInfo.providerName),
      ),
      SizedBox(height: 12),
      ReusableRaisedButton(
        title: "No",
        onPressed: () => model.updateWith(showPCPTextField: true),
      ),
      SizedBox(
        height: 16,
      ),
    ];
  }

  Widget _buildPCPTextField() {
    return Center(
      child: TextField(
        controller: _pcpController,
        focusNode: _pcpFocusNode,
        autocorrect: false,
        style: Theme.of(context).textTheme.bodyText1,
        keyboardType: TextInputType.name,
        onChanged: model.updatePCP,
        decoration: InputDecoration(
          labelText: 'Full Name',
          hintText: 'Jane Doe',
          fillColor: Colors.grey.withAlpha(40),
          filled: false,
          prefixIcon: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          errorText: model.pcpErrorText,
          enabled: !model.isLoading,
        ),
      ),
    );
  }

  List<Widget> _buildRequestReferralUI() {
    return [
      Center(
        child: Text(
          "Your real-time cost estimate:",
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
          "Your insurance plan is an HMO, which means that you need a referral from your primary care provider (PCP) before your insurance will pay for this visit (i.e. your PCP has to explicitly approve this visit). Would you like us to do this on your behalf? You can still proceed with this visit, but you will only be required to pay once a referral is granted.",
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
      SizedBox(height: 12),
      _buildOONButton(),
    ];
  }
}
