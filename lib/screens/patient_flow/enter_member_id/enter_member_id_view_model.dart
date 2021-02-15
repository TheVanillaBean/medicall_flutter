import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class EnterMemberIdViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final Consult consult;
  final String insurance;

  String memberId;
  String errorMessage;
  bool isLoading;
  bool successfullyValidatedInsurance;

  EnterMemberIdViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.consult,
    @required this.insurance,
    this.memberId = "",
    this.errorMessage = "",
    this.isLoading = false,
    this.successfullyValidatedInsurance = false,
  });

  Future<void> calculateCostWithInsurance() async {
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

    if (result.data["error"]) {
      throw result.data["message"]["message"];
    }

    this.updateWith(successfullyValidatedInsurance: true, errorMessage: "");
  }

  String get continueBtnText {
    return this.successfullyValidatedInsurance
        ? "Continue"
        : "Verify Insurance";
  }

  String get labelText {
    return this.successfullyValidatedInsurance
        ? "Your insurance has been successfully verified! Press continue to be shown your cost estimate."
        : this.errorMessage;
  }

  bool get showErrorMessage {
    return this.errorMessage.length > 0;
  }

  void updateMemberID(String memberId) => updateWith(memberId: memberId);

  void updateWith({
    String memberId,
    String errorMessage,
    bool successfullyValidatedInsurance,
    bool isLoading,
  }) {
    this.memberId = memberId ?? this.memberId;
    this.errorMessage = errorMessage ?? this.errorMessage;
    this.isLoading = isLoading ?? this.isLoading;
    this.successfullyValidatedInsurance =
        successfullyValidatedInsurance ?? this.successfullyValidatedInsurance;
    notifyListeners();
  }
}
