class CounselingTemplate {
  Map<String, String> template;

  CounselingTemplate({
    this.template = const {},
  });

  factory CounselingTemplate.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    if (data.isNotEmpty) {
      template["Template"] = data["Template"];
    }

    return CounselingTemplate(
      template: template,
    );
  }

  Map<String, dynamic> toMap() {
    return template;
  }
}
