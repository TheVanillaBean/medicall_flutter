import 'package:flutter/foundation.dart';

class FurtherTestingTemplate {
  Map<String, String> template;

  FurtherTestingTemplate({
    @required this.template,
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
}
