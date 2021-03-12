import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CostEstimateViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final Consult consult;
  final InsuranceInfo insuranceInfo;

  bool isLoading;
  bool showWaiver;
  bool waiverCheck;

  bool requestedCostEstimate;

  CostEstimateViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.consult,
    @required this.insuranceInfo,
    this.isLoading = false,
    this.showWaiver = false,
    this.waiverCheck = false,
    this.requestedCostEstimate = false,
  });

  bool get costEstimateGreaterThanSelfPay {
    return this.insuranceInfo.coverageResponse ==
            CoverageResponse.ValidCostEstimate &&
        this.insuranceInfo.costEstimate > 75;
  }

  bool get costEstimateLessThanSelfPay {
    return this.insuranceInfo.coverageResponse ==
            CoverageResponse.ValidCostEstimate &&
        this.insuranceInfo.costEstimate < 75;
  }

  Future<bool> requestCostEstimate() async {
    this.updateWith(isLoading: true, requestedCostEstimate: true);
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'requestCostEstimate')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': this.userProvider.user.uid,
      'provider_uid': this.consult.providerId,
      'member_id': this.insuranceInfo.memberId,
      'insurance': this.insuranceInfo.insurance,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["data"] != "Service OK") {
      this.updateWith(requestedCostEstimate: false);
      throw "There was an issue requesting a cost estimate for you. Please contact omar@medicall.com";
    }

    return true;
  }

  Future<bool> requestReferral() async {
    this.updateWith(isLoading: true);
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'requestReferral')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': this.userProvider.user.uid,
      'provider_uid': this.consult.providerId,
      'member_id': this.insuranceInfo.memberId,
      'insurance': this.insuranceInfo.insurance,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["data"] != "Service OK") {
      throw "There was an issue requesting a referral for you. Please contact omar@medicall.com";
    }

    return true;
  }

  void updateWith({
    bool isLoading,
    bool showWaiver,
    bool waiverCheck,
    bool requestedCostEstimate,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    this.showWaiver = showWaiver ?? this.showWaiver;
    this.waiverCheck = waiverCheck ?? this.waiverCheck;
    this.requestedCostEstimate =
        requestedCostEstimate ?? this.requestedCostEstimate;
    notifyListeners();
  }
}
