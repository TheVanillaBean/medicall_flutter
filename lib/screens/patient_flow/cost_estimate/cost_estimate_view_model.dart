import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CostEstimateViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final Consult consult;

  String memberId;
  int estimatedCost;
  bool isLoading;

  CostEstimateViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.consult,
    this.memberId = "",
    this.estimatedCost = 0,
    this.isLoading = false,
  });

  Future<void> calculateCostWithInsurance() async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'calculateCostWithInsurance')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'patient_id': this.userProvider.user.uid,
      'provider_uid': this.consult.providerId,
      'member_id': this.memberId,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    if (!result.data["success"]) {
      throw "There was an error calculating the cost for this visit";
    }

    this.updateWith(
        estimatedCost: result.data["cost_estimates"][0]["cost_estimate"]);
  }

  bool get showCostLabel {
    return estimatedCost > 0;
  }

  void updateMemberID(String memberId) => updateWith(memberId: memberId);

  void updateWith({
    String memberId,
    int estimatedCost,
    bool isLoading,
  }) {
    this.memberId = memberId ?? this.memberId;
    this.estimatedCost = estimatedCost ?? this.estimatedCost;
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
