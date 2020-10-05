class ConclusionTemplate {
  Map<String, String> template;

  ConclusionTemplate({
    this.template = const {},
  });

  factory ConclusionTemplate.fromMap(String data) {
    if (data == null) {
      return null;
    }

    Map<String, String> template = {};
    template["template"] = data;

    return ConclusionTemplate(
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
