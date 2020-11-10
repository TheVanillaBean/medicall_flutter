class FurtherTestingTemplate {
  Map<String, String> template;

  FurtherTestingTemplate({
    this.template = const {},
  });

  String get body {
    return template.values.first;
  }

  factory FurtherTestingTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    if (data.isNotEmpty) {
      template["Template"] = data["Template"];
    }

    return FurtherTestingTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
