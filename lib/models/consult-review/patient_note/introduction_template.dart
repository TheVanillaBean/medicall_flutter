class IntroductionTemplate {
  Map<String, String> template;

  IntroductionTemplate({
    this.template = const {},
  });

  factory IntroductionTemplate.fromMap(String data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["template"] = data;

    return IntroductionTemplate(
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
