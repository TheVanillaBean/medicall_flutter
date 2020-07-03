import 'package:Medicall/models/question_model.dart';
import 'package:meta/meta.dart';

class ScreeningQuestions {
  final List<Question> screeningQuestions;

  ScreeningQuestions({
    @required this.screeningQuestions,
  });

  factory ScreeningQuestions.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    final questions = (data['screening_question'] as List ?? [])
        .map((v) => Question.fromMap(v))
        .toList();

    return ScreeningQuestions(
      screeningQuestions: questions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'screening_question': screeningQuestions.map((q) => q.toMap()).toList(),
    };
  }
}
