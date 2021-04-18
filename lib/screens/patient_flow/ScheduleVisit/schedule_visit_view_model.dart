import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class ScheduleVisitViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final Consult consult;
  bool isLoading;

  ScheduleVisitViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.consult,
    this.isLoading = false,
  });

  Future<String> getScheduleUrl() async {
    this.updateWith(isLoading: true);
    final callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'retrieveScheduleUrl')
          ..timeout = const Duration(seconds: 30);

    Map<String, dynamic> parameters = {};

    parameters = <String, dynamic>{
      'provider_uid': this.consult.providerId,
    };

    final HttpsCallableResult result = await callable.call(parameters);

    this.updateWith(isLoading: false);

    if (result.data["data"] != null) {
      return result.data["data"];
    }

    return "true";
  }

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
