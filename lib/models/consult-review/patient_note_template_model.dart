import 'package:flutter/foundation.dart';

class PatientTemplateNote {
  String intro;
  String conclusion;
  Map<String, String> body;

  PatientTemplateNote(
      {@required this.intro, @required this.conclusion, @required this.body});

  factory PatientTemplateNote.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final String intro = data['Intro'] as String;

    final String conclusion = data['Conclusion'] as String;

    final Map<String, String> body = (data['Body'] as Map).map(
      (key, value) => MapEntry(
        key as String,
        value as String,
      ),
    );

    return PatientTemplateNote(
      intro: intro,
      body: body,
      conclusion: conclusion,
    );
  }
}
