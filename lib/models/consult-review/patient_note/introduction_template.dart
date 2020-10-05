class IntroductionTemplate {
  Map<String, String> template;

  IntroductionTemplate({
    this.template = const {},
  });

  factory IntroductionTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["Template"] = data["Template"];

    return IntroductionTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
