import 'dart:convert';
import 'dart:io';

import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class NylasConnectViewModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;
  final String nylasConnectUrl;
  bool isLoading;

  NylasConnectViewModel({
    @required this.auth,
    @required this.userProvider,
    @required this.nylasConnectUrl,
    this.isLoading = false,
  });

  Future<String> getNylasConnectURL() async {
    updateWith(isLoading: true);

    String idToken = await auth.currentUserIdToken();

    final response = await http.get(
      this.nylasConnectUrl,
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
