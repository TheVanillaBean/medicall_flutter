import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class DashboardStateModel with ChangeNotifier {
  final AuthBase auth;
  final UserProvider userProvider;

  DashboardStateModel({
    @required this.auth,
    @required this.userProvider,
  });

  void updateWith() {}
}
