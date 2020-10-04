import 'package:flutter/foundation.dart';

class ConclusionTemplate {
  Map<String, String> template;

  ConclusionTemplate({
    @required this.template,
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
}
