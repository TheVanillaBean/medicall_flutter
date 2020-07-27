import 'package:Medicall/services/auth.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';

class ImmediateMedicalCareViewModel with ChangeNotifier {
  final FirestoreDatabase database;
  final UserProvider userProvider;
  final AuthBase auth;

  String documentationText = "";

  final TextEditingController documentationTextController =
      TextEditingController();

  final FocusNode documentationTextFocusNode = FocusNode();

  @override
  void dispose() {
    documentationTextController.dispose();
  }

  ImmediateMedicalCareViewModel(
      {@required this.database,
      @required this.userProvider,
      @required this.auth});

  void updateWith({
    String documentationText,
  }) {
    this.documentationText = documentationText ?? this.documentationText;
    notifyListeners();
  }

  void updateDocumentationText(String documentationText) =>
      updateWith(documentationText: documentationText);
}
