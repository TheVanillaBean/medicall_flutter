import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class StripeConnectStateModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  bool submitted;

  StripeConnectStateModel({
    @required this.auth,
    @required this.userProvider,
    this.submitted = false,
  });

  String getStripeConnectURL() {
    updateWith(submitted: true);
    MedicallUser medicallUser = userProvider.medicallUser;


    const paramters = [
      ""
    ]

    return "";
  }

  void updateWith({
    bool submitted,
  }) {
    this.submitted = submitted ?? this.submitted;
  }
}
