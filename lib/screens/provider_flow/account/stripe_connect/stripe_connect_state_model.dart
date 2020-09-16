import 'dart:convert';
import 'dart:io';

import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class StripeConnectStateModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  bool isLoading;

  StripeConnectStateModel({
    @required this.auth,
    @required this.userProvider,
    this.isLoading = false,
  });

  Future<String> getStripeConnectURL() async {
    updateWith(isLoading: true);

    String idToken = await auth.currentUserIdToken();

    final response = await http.get(
      'https://us-central1-telmed-216305.cloudfunctions.net/api/stripe/authorize',
      headers: {HttpHeaders.authorizationHeader: "Bearer $idToken"},
    );

    updateWith(isLoading: false);

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      String url = responseJson['url'];
      return url;
    }

    return "";
  }

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
