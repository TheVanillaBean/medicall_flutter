import 'package:Medicall/models/option_model.dart';

class Question {
  String question;
  String type;
  List<Option> options;

  Question({
    this.options,
    this.question,
    this.type,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final question = data['question'] ?? '';
    final type = data['type'] ?? '';

    final options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();

    return Question(
      question: question,
      type: type,
      options: options,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': question,
      'type': type,
      'options': options,
    };
  }
}

class Answer {
  List<String> answer;

  Answer({this.answer});

  factory Answer.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final answer = data['answer'] ?? [];
    return Answer(answer: answer);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'answer': answer,
    };
  }
}
