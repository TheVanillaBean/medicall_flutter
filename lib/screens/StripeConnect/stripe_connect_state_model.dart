import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/secrets.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:fluri/fluri.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

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

    Uuid uuid = Uuid();
    String state = uuid.v1();

    final Map<String, Iterable<String>> queryParams = {
      "client_id": [stripeClientID],
      "state": [state],
      "redirect_uri": [stripeConnectRedirectURl],
      'stripe_user[business_type]': ['individual'],
      'stripe_user[first_name]': [medicallUser.firstName],
      'stripe_user[last_name]': [medicallUser.lastName],
      'stripe_user[email]': [medicallUser.email],
      'stripe_user[country]': ["USA"],
    };

    Fluri fluri = new Fluri()
      ..scheme = 'https'
      ..host = 'connect.stripe.com'
      ..path = 'express/oauth/authorize';

    fluri.queryParametersAll = queryParams;

    String url = fluri.toString();

    updateWith(submitted: false);

    return url;

//    return "https://connect.stripe.com/express/oauth/authorize/?$urlParams";
  }

  void updateWith({
    bool submitted,
  }) {
    this.submitted = submitted ?? this.submitted;
  }
}
