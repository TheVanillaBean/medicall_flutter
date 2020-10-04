import 'package:flutter/foundation.dart';

class IntroductionTemplate {
  Map<String, String> template;

  IntroductionTemplate({
    @required this.template,
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
}
