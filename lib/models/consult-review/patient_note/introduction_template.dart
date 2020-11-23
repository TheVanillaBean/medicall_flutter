class IntroductionTemplate {
  Map<String, String> template;

  IntroductionTemplate({
    this.template = const {},
  });

  String get body {
    return template.values.first;
  }

  factory IntroductionTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    if (data.isNotEmpty) {
      template["Template"] = data["Template"];
    }
    return IntroductionTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
