import 'package:Medicall/models/option_model.dart';

class Question {
  String question;
  String type;
  List<Option> options;
  Answer answer;

  Question({
    this.options,
    this.question,
    this.type,
    this.answer,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final question = data['question'] ?? '';
    final type = data['type'] ?? '';

    final options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();

    Answer answer;
    if (data['answer'] != null) {
      answer = Answer.fromMap(data);
    }

    return Question(
      question: question,
      type: type,
      options: options,
      answer: answer,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'question': question,
      'type': type,
      'options': options.map((opt) => opt.toMap()).toList(),
      'answer': answer != null ? answer.toMap() : null,
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
