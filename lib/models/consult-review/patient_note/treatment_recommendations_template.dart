import 'package:flutter/foundation.dart';

class TreatmentRecommendationsTemplate {
  Map<String, String> template;

  TreatmentRecommendationsTemplate({
    @required this.template,
  });

  factory TreatmentRecommendationsTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};

    template = data.map(
      (key, value) => MapEntry(
        key,
        value as String,
      ),
    );

    return TreatmentRecommendationsTemplate(
      template: template,
    );
  }
}
