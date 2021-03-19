import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class EnterMemberIdViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  final Consult consult;
  final String insurance;

  String memberId;
  String errorMessage;
  bool isLoading;
  InsuranceInfo insuranceInfo;

  EnterMemberIdViewModel({
    @required this.database,
    @required this.userProvider,
    @required this.consult,
    @required this.insurance,
    this.memberId = "",
    this.errorMessage = "",
    this.isLoading = false,
    this.insuranceInfo,
  }) {
    this.memberId = (userProvider.user as PatientUser).memberId;
  }

  Future<bool> calculateCostWithInsurance() async {
    this.updateWith(isLoading: true);
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'retrieveCoverage')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': this.userProvider.user.uid,
      'provider_uid': this.consult.providerId,
      'member_id': this.memberId,
      'insurance': this.insurance,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["error"] && result.data["code"] != 5) {
      if (result.data["code"] == 2) {
        throw result.data["message"]["message"];
      } else {
        throw result.data["message"];
      }
    }

    InsuranceInfo insuranceInfo;

    if (result.data["code"] == 2) {
      insuranceInfo = InsuranceInfo(
        memberId: memberId,
        coverageResponse: CoverageResponse.ReferralNeeded,
        insurance: this.insurance,
        pcpName:
            "${result.data["referral_info"]["first_name"]} ${result.data["referral_info"]["last_name"]}",
        costEstimate: result.data["cost_estimate"] ?? -1,
      );
    } else if (result.data["code"] == 1) {
      insuranceInfo = InsuranceInfo(
        memberId: memberId,
        coverageResponse: CoverageResponse.ValidCostEstimate,
        insurance: this.insurance,
        costEstimate: result.data["cost_estimate"] ?? -1,
      );
    } else if (result.data["code"] == 5) {
      insuranceInfo = InsuranceInfo(
        memberId: memberId,
        coverageResponse: CoverageResponse.NoCostEstimate,
        insurance: this.insurance,
        costEstimate: -1,
      );
    }

    //Medicare is handled differently so override the above conditions if Medicare visit
    if (this.insurance == "AARP Medicare Replacement") {
      insuranceInfo = InsuranceInfo(
        memberId: memberId,
        coverageResponse: CoverageResponse.Medicare,
        insurance: this.insurance,
        costEstimate: -1,
      );
    }

    this.updateWith(insuranceInfo: insuranceInfo);

    return true;
  }

  Future<void> saveMemberId() async {
    (userProvider.user as PatientUser).memberId = this.memberId;
    await database.setUser(userProvider.user);
  }

  void updateMemberID(String memberId) => updateWith(memberId: memberId);

  void updateWith({
    String memberId,
    bool isLoading,
    InsuranceInfo insuranceInfo,
  }) {
    this.memberId = memberId ?? this.memberId;
    this.isLoading = isLoading ?? this.isLoading;
    this.insuranceInfo = insuranceInfo ?? this.insuranceInfo;
    notifyListeners();
  }
}
