class UnderstandingDiagnosisTemplate {
  Map<String, String> template;

  UnderstandingDiagnosisTemplate({
    this.template = const {},
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

  Map<String, dynamic> toMap() {
    dynamic e = <String, dynamic>{
      'template': template,
    };
    return e;
  }
}
