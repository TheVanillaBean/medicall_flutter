import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/screens/patient_flow/start_visit/start_visit.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestReferral extends StatefulWidget {
  final Consult consult;
  final InsuranceInfo insuranceInfo;

  const RequestReferral({
    @required this.consult,
    @required this.insuranceInfo,
  });

  static Future<void> show({
    BuildContext context,
    bool pushReplaceNamed = true,
    Consult consult,
    InsuranceInfo insuranceInfo,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.requestReferral,
      arguments: {
        'consult': consult,
        'insurance_info': insuranceInfo,
      },
    );
  }

  @override
  _RequestReferralState createState() => _RequestReferralState();
}

class _RequestReferralState extends State<RequestReferral> {
  bool isLoading = false;
  bool showNonValidUI = false;

  Future<void> _viewOutOfNetworkProviders(
      BuildContext context, String mailingState) async {
    SelectProviderScreen.show(
      context: context,
      symptom: widget.consult.symptom,
      insurance: widget.insuranceInfo.insurance,
      state: mailingState,
      filter: SelectProviderFilter.OutOfNetwork,
    );
  }

  Future<bool> requestReferral(
      UserProvider userProvider, FirestoreDatabase firestoreDatabase) async {
    this.updateWith(isLoading: true);
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'requestReferral')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': userProvider.user.uid,
      'provider_uid': widget.consult.providerId,
      'member_id': widget.insuranceInfo.memberId,
      'insurance': widget.insuranceInfo.insurance,
      'pcp_name': widget.insuranceInfo.pcpName,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["data"] != "Service OK") {
      throw "There was an issue requesting a referral for you. Please contact omar@medicall.com";
    }

    if (widget.insuranceInfo.costEstimate > -1) {
      widget.consult.price = widget.insuranceInfo.costEstimate;
    }
    widget.consult.insurancePayment = true;
    widget.consult.insuranceInfo = widget.insuranceInfo;
    widget.consult.state = ConsultStatus.ReferralRequested;

    firestoreDatabase.saveConsult(consult: widget.consult);

    return true;
  }

  Future<void> _submitReferral(
    BuildContext context,
    UserProvider userProvider,
    FirestoreDatabase firestoreDatabase,
  ) async {
    this.updateWith(showNonValidUI: false);
    try {
      if (await this.requestReferral(userProvider, firestoreDatabase)) {
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
            consult: widget.consult,
          );
          return false;
        } else {
          return false;
        }
      } else {
        AppUtil().showFlushBar(
            "There was an issue requesting a referral for you. Please contact omar@medicall.com",
            context);
        this.updateWith(isLoading: false);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  bool get pcpValid {
    return widget.insuranceInfo.pcpName.isNotEmpty;
  }

  void updateWith({
    bool isLoading,
    bool showNonValidUI,
  }) {
    setState(() {
      this.isLoading = isLoading ?? this.isLoading;
      this.showNonValidUI = showNonValidUI ?? this.showNonValidUI;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final FirestoreDatabase firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Request a Referral",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
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
              children: _buildPCPValidationUI(userProvider, firestoreDatabase),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPCPValidationUI(
      UserProvider userProvider, FirestoreDatabase firestoreDatabase) {
    List<Widget> ui = [];
    if (this.pcpValid) {
      ui.addAll([
        Center(
          child: Text(
            "Is ${widget.insuranceInfo.pcpName} your Primary Care Provider (PCP)?",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        ReusableRaisedButton(
          title: "Yes",
          onPressed: widget.consult.state != ConsultStatus.ReferralRequested &&
                  !isLoading
              ? () => _submitReferral(context, userProvider, firestoreDatabase)
              : null,
        ),
        SizedBox(height: 12),
        ReusableRaisedButton(
          title: "No",
          onPressed: () => this.updateWith(showNonValidUI: true),
        ),
        SizedBox(
          height: 16,
        ),
      ]);
    }
    ui.addAll([
      if (this.showNonValidUI || !this.pcpValid)
        ..._buildNonVerifiedPCPUI(userProvider, firestoreDatabase),
      if (this.isLoading)
        Center(
          child: CircularProgressIndicator(),
        ),
    ]);

    return ui;
  }

  List<Widget> _buildNonVerifiedPCPUI(
      UserProvider userProvider, FirestoreDatabase firestoreDatabase) {
    String pcpNotValid =
        "We did not receive back a valid primary care provider for your insurance plan. You will have to contact your insurance company and verify that you have a valid PCP on file. ";
    String incorrectPCP =
        "In order for your insurance to bill properly, you must contact your insurance company and update your PCP. If you do not want to do that, you can still proceed without using insurance.";

    //if this.pcpValid is false, then a pcp was not successfully returned back from the Eligible request in Enter Member ID. So the patient is not even asked if that PCP is valid because one was not returned. In this case, show a different message.
    return [
      Center(
        child: Text(
          this.pcpValid ? incorrectPCP : pcpNotValid,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      SizedBox(
        height: 16,
      ),
      SizedBox(height: 12),
      Center(
        child: ReusableRaisedButton(
          title: "Proceed without insurance for \$75+",
          onPressed: () => _viewOutOfNetworkProviders(
              context, userProvider.user.mailingState),
        ),
      ),
      SizedBox(
        height: 16,
      ),
    ];
  }
}
