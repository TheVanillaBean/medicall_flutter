import 'package:Medicall/models/questionnaire/question_model.dart';

class Option {
  String value;
  bool hasSubQuestions;
  List<Question> subQuestions;

  Option({
    this.value,
    this.hasSubQuestions,
    this.subQuestions,
  });

  factory Option.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String value = data['value'];
    final bool hasSubQuestions = data['has_sub_questions'] ?? false;
    final subQuestions = (data['sub_questions'] as List ?? [])
        .map((v) => Question.fromMap(v))
        .toList();

    return Option(
      value: value,
      hasSubQuestions: hasSubQuestions,
      subQuestions: subQuestions,
    );
  }

  Map<String, dynamic> toMap() {
    if (this.hasSubQuestions) {
      var g = <String, dynamic>{
        'value': this.value,
        'has_sub_questions': true,
        'sub_questions': this.subQuestions.map((q) => q.toMap()).toList(),
      };
      return g;
    } else {
      var g = <String, dynamic>{
        'value': this.value,
      };
      return g;
    }
  }
}
