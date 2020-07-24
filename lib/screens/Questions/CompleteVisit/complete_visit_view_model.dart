import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/cupertino.dart';

class CompleteVisitViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  final AuthBase auth;

  bool checkValue;
  bool submitted;

  CompleteVisitViewModel(
      {@required this.database,
      @required this.userProvider,
      @required this.auth,
      this.checkValue = false,
      this.submitted = false});

  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);
  void updateSubmitted(bool submitted) => updateWith(submitted: submitted);

  void updateWith({
    bool checkValue,
    bool submitted,
  }) {
    this.checkValue = checkValue ?? this.checkValue;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
