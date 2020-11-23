import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

abstract class EmailAssistantReasons {
  static const Visit_Office = "Coordinate an office visit";
  static const Coordinate_Referral = "Coordinate referral";
  static const Pharmacy_Issue = "Pharmacy issue";
  static const Upload_Patient_Note = "Upload patient note to EHR";
  static const Other = "Other";
  static const allReasons = [
    Visit_Office,
    Coordinate_Referral,
    Pharmacy_Issue,
    Upload_Patient_Note,
    Other,
  ];
}

class EmailAssistantViewModel with EmailAndPasswordValidators, ChangeNotifier {
  final FirestoreDatabase firestoreDatabase;
  final UserProvider userProvider;
  Consult consult;
  String assistantEmail;
  List<String> selectReasons = EmailAssistantReasons.allReasons;
  String selectedReason;
  bool checkValue = false;
  bool submitted = false;

  String emailNote;

  EmailAssistantViewModel({
    @required this.consult,
    @required this.firestoreDatabase,
    @required this.userProvider,
    this.assistantEmail = "",
    this.selectedReason = "",
    this.emailNote = "",
    this.checkValue = false,
    this.submitted = false,
  }) {
    this.assistantEmail =
        (this.userProvider.user as ProviderUser).assistantEmail ?? "";
    notifyListeners();
  }

  bool get includeTextBox {
    return this.selectReasons.contains(this.selectedReason);
  }

  bool get canSubmit {
    return emailValidator.isValid(assistantEmail) && !this.submitted;
  }

  Future<void> sendSecureEmail() async {
    updateWith(submitted: true);

    ProviderUser user = userProvider.user;

    user.assistantEmail = this.assistantEmail;

    await updateUser(user);

    try {
      await sendEmail();
    } catch (e) {
      updateWith(submitted: false);
      throw e;
    }

    updateWith(checkValue: false);
  }

  Future<void> updateUser(ProviderUser user) async {
    await firestoreDatabase.setUser(user);
    userProvider.user = user;
  }

  Future<void> sendEmail() async {
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'sendAssistantEmail')
          ..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'consultId': this.consult.uid,
        'reason': this.selectedReason,
        'sendNoteCopy': this.checkValue,
        'additionalNote': this.emailNote,
      },
    );

    if (result.data == null) {
      throw "Failed to send email";
    }

    if (result.data["data"] as String != "Service OK") {
      throw "There was an error sending the email";
    }
  }

  String get emailErrorText {
    bool showErrorText =
        this.submitted && !emailValidator.isValid(assistantEmail);
    return showErrorText ? invalidEmailErrorText : null;
  }

  void updateCheckValue(bool checkValue) {
    if (checkValue != null &&
        !checkValue &&
        this.selectedReason == EmailAssistantReasons.Upload_Patient_Note) {
      throw "You must send a copy of the patient note when selecting this reason";
    }
    updateWith(checkValue: checkValue);
  }

  void updateSubmitted(bool submitted) => updateWith(submitted: submitted);
  void updateEmailNote(String note) => updateWith(emailNote: note);
  void updateAssistantEmail(String assistantEmail) =>
      updateWith(assistantEmail: assistantEmail);

  void updateWith({
    Consult consult,
    String assistantEmail,
    String selectedReason,
    String emailNote,
    bool checkValue,
    bool submitted,
  }) {
    this.consult = consult ?? this.consult;
    this.assistantEmail = assistantEmail ?? this.assistantEmail;
    this.selectedReason = selectedReason ?? this.selectedReason;
    this.checkValue = checkValue ?? this.checkValue;
    this.submitted = submitted ?? this.submitted;
    this.emailNote = emailNote ?? this.emailNote;
    if (this.selectedReason == EmailAssistantReasons.Upload_Patient_Note) {
      this.checkValue = true;
    }
    notifyListeners();
  }
}
