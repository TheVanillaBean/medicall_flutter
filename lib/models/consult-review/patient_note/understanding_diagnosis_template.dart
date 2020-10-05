class UnderstandingDiagnosisTemplate {
  Map<String, String> template;

  UnderstandingDiagnosisTemplate({
    this.template = const {},
  });

  factory UnderstandingDiagnosisTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["Template"] = data["Template"];

    return UnderstandingDiagnosisTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
