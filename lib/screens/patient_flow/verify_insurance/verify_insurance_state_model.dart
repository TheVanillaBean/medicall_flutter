import 'package:Medicall/services/auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class VerifyInsuranceStateModel with ChangeNotifier {
  final AuthBase auth;
  bool isLoading;

  VerifyInsuranceStateModel({
    @required this.auth,
    this.isLoading = false,
  });

  Future<String> getURL() async {
    updateWith(isLoading: true);

    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'getEligibleSessionToken')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call();

    print(result.data);

    String url =
        'https://insurance-fc912.firebaseapp.com/?sessionToken=${result.data['session_token']}';

    return url;
  }

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
