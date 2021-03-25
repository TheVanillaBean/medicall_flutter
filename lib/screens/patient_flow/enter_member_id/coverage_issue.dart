import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/patient_flow/select_provider/select_provider.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoverageIssue extends StatefulWidget {
  final String errorMessage;
  final Consult consult;
  final String insurance;
  final String memberId;

  const CoverageIssue({
    @required this.errorMessage,
    @required this.consult,
    @required this.insurance,
    @required this.memberId,
  });

  static Future<void> show({
    BuildContext context,
    String errorMessage,
    Consult consult,
    String insurance,
    String memberId,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.coverageIssue,
      arguments: {
        'errorMessage': errorMessage,
        'consult': consult,
        'insurance': insurance,
        'memberId': memberId,
      },
    );
  }

  @override
  _CoverageIssueState createState() => _CoverageIssueState();
}

class _CoverageIssueState extends State<CoverageIssue> {
  bool isLoading = false;
  bool requestedSupport = false;

  Future<void> _viewOutOfNetworkProviders(UserProvider userProvider) async {
    SelectProviderScreen.show(
      context: context,
      symptom: widget.consult.symptom,
      insurance: widget.insurance,
      state: userProvider.user.mailingState,
      filter: SelectProviderFilter.OutOfNetwork,
    );
  }

  Future<void> saveMemberId(
    UserProvider userProvider,
    FirestoreDatabase firestoreDatabase,
  ) async {
    (userProvider.user as PatientUser).memberId = widget.memberId;
    await firestoreDatabase.setUser(userProvider.user);
  }

  Future<bool> requestMedicallSupport(UserProvider userProvider) async {
    this.updateWith(isLoading: true, requestedSupport: true);
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'requestMedicallSupport')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': userProvider.user.uid,
      'provider_uid': widget.consult.providerId,
      'member_id': widget.memberId,
      'insurance': widget.insurance,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["data"] != "Service OK") {
      this.updateWith(requestedSupport: false);
      throw "There was an issue requesting Medicall support for you. Please contact omar@medicall.com";
    }

    return true;
  }

  Future<void> _requestPressed(
      UserProvider userProvider, FirestoreDatabase database) async {
    try {
      if (await this.requestMedicallSupport(userProvider)) {
        await this.saveMemberId(userProvider, database);
        AppUtil().showFlushBar(
            "You have successfully requested Medicall support. You will receive a response email within 24 hours.",
            context);
      } else {
        AppUtil().showFlushBar(
            "There was an issue requesting Medicall support for you. Please contact omar@medicall.com",
            context);
      }
    } catch (e) {
      AppUtil().showFlushBar(e, context);
    }
  }

  void updateWith({
    bool isLoading,
    bool requestedSupport,
  }) {
    setState(() {
      this.isLoading = isLoading ?? this.isLoading;
      this.requestedSupport = requestedSupport ?? this.requestedSupport;
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
        title: "Coverage Issue",
        theme: Theme.of(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Center(
              child: Text(
                "${widget.errorMessage}",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                "Would you like to email Medicall customer support and/or proceed without insurance for as low as \$75?\n\n"
                "Please select how you would like to proceed:",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: ReusableRaisedButton(
                title: "Email Support",
                onPressed: !this.requestedSupport
                    ? () => _requestPressed(userProvider, firestoreDatabase)
                    : null,
              ),
            ),
            SizedBox(height: 12),
            Center(
              child: ReusableRaisedButton(
                title: "Proceed without insurance for \$75+",
                onPressed: () => _viewOutOfNetworkProviders(userProvider),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            if (this.isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
