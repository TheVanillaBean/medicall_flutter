import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';

class EmailAssistantViewModel with EmailAndPasswordValidators, ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;
  Consult consult;
  String assistantEmail;
  List<String> selectReasons = [
    'Coordinate an office visit',
    'Coordinate referral',
    'Pharmacy issue',
    'Upload patient note to EHR',
    'Other',
  ];
  String selectedReason;
  bool checkValue = false;
  bool submitted = false;

  EmailAssistantViewModel({
    @required this.consult,
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.assistantEmail = "",
    this.selectedReason = "",
    this.checkValue = false,
    this.submitted = false,
  });

  void updateCheckValue(bool checkValue) => updateWith(checkValue: checkValue);
  void updateSubmitted(bool submitted) => updateWith(submitted: submitted);

  bool get canSubmit {
    return emailValidator.isValid(assistantEmail) && !this.submitted;
  }

  Future<void> sendSecureEmail() async {
    updateWith(submitted: true);

    ProviderUser user = userProvider.user;

    user.assistantEmail = this.assistantEmail;

    await updateUser(user);

    await sendEmail();

    updateWith(submitted: false, checkValue: false);
  }

  Future<void> updateUser(ProviderUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }

  Future<void> sendEmail() async {}

  String get emailErrorText {
    bool showErrorText =
        this.submitted && !emailValidator.isValid(assistantEmail);
    return showErrorText ? invalidEmailErrorText : null;
  }

  void updateAssistantEmail(String assistantEmail) =>
      updateWith(assistantEmail: assistantEmail);

  void updateWith({
    Consult consult,
    String assistantEmail,
    String selectedReason,
    bool checkValue,
    bool submitted,
  }) {
    this.consult = consult ?? this.consult;
    this.assistantEmail = assistantEmail ?? this.assistantEmail;
    this.selectedReason = selectedReason ?? this.selectedReason;
    this.checkValue = checkValue ?? this.checkValue;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }
}
