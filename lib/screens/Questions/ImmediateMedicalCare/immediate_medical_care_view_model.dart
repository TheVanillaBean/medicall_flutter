import 'package:flutter/material.dart';

class ImmediateMedicalCareViewModel with ChangeNotifier {
  bool documentationUpdated = false;
  String documentationText;

  ImmediateMedicalCareViewModel({
    this.documentationText = "",
  });

  void updateWith({
    String documentationText,
  }) {
    this.documentationText = documentationText ?? this.documentationText;
    documentationUpdated = true;
    notifyListeners();
  }

  void updateDocumentationText(String documentationText) =>
      updateWith(documentationText: documentationText);
}
