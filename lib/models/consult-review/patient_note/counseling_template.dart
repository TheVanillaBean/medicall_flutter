class CounselingTemplate {
  Map<String, String> template;

  CounselingTemplate({
    this.template = const {},
  });

  factory CounselingTemplate.fromMap(String data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["template"] = data;

    return CounselingTemplate(
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
