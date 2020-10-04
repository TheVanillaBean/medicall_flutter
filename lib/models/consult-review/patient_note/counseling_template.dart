import 'package:flutter/foundation.dart';

class CounselingTemplate {
  Map<String, String> template;

  CounselingTemplate({
    @required this.template,
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
}
