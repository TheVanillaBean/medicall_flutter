class ConclusionTemplate {
  Map<String, String> template;

  ConclusionTemplate({
    this.template = const {},
  });

  factory ConclusionTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["Template"] = data["Template"];

    return ConclusionTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
