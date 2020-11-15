class TreatmentRecommendationsTemplate {
  Map<String, String> template;

  TreatmentRecommendationsTemplate({
    this.template = const {},
  });

  String get body {
    return template.values.first;
  }

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

  Map<String, dynamic> toMap() {
    return template;
  }
}
