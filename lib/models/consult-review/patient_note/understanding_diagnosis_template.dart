import 'package:flutter/foundation.dart';

class UnderstandingDiagnosisTemplate {
  Map<String, String> template;

  UnderstandingDiagnosisTemplate({
    @required this.template,
  });

  factory UnderstandingDiagnosisTemplate.fromMap(String data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["template"] = data;

    return UnderstandingDiagnosisTemplate(
      template: template,
    );
  }
}
