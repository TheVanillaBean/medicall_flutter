import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/insurance_info.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/foundation.dart';

class CostEstimateViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final Consult consult;
  final InsuranceInfo insuranceInfo;

  bool isLoading;

  CostEstimateViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.consult,
    @required this.insuranceInfo,
    this.isLoading = false,
  });

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
