class FurtherTestingTemplate {
  Map<String, String> template;

  FurtherTestingTemplate({
    this.template = const {},
  });

  factory FurtherTestingTemplate.fromMap(String data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["template"] = data;

    return FurtherTestingTemplate(
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
