import 'package:Medicall/models/questionnaire/option_model.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';

enum Q_TYPE { MC, SC, FR, PHOTO }

extension EnumParser on String {
  Q_TYPE toQType() {
    return Q_TYPE.values.firstWhere(
        (e) => e.toString().toLowerCase() == 'Q_TYPE.$this'.toLowerCase(),
        orElse: () => null); //return null if not found
  }
}

class Question {
  String question;
  Q_TYPE type;
  List<Option> options;
  Answer answer;

  int maxImages;
  String placeholderImage;
  bool required;

  Question({
    this.options,
    this.question,
    this.type,
    this.answer,
    this.maxImages,
    this.placeholderImage,
    this.required,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final question = data['question'] ?? '';
    final Q_TYPE type = (data['type'] as String).toQType() ?? null;

    final options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();

    Answer answer;
    if (data['answer'] != null) {
      answer = Answer.fromMap(data['answer']);
    }

    final required = data["required"] ?? true;
    final String placeholderImage = data['placeholder_image'] ?? '';
    final int maxImages = data['max_images'] ?? 0;

    return Question(
      question: question,
      type: type,
      options: options,
      answer: answer,
      required: required,
      placeholderImage: placeholderImage,
      maxImages: maxImages,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> toStringMap = <String, dynamic>{
      'question': question,
      'type': EnumToString.parse(type),
      'answer': answer != null ? answer.toMap() : null,
    };
    if (type == Q_TYPE.MC || type == Q_TYPE.SC) {
      toStringMap.addAll(<String, dynamic>{
        'options': options.map((opt) => opt.toMap()).toList(),
      });
    }
    if (type == Q_TYPE.PHOTO) {
      toStringMap.addAll(<String, dynamic>{
        'required': required,
        'placeholder_image': placeholderImage,
        'max_images': maxImages,
      });
    }
    return toStringMap;
  }
}

class Answer {
  List<String> answer;
  List<Map<String, ByteData>>
      images; //if it is a photo question. Not serialized.

  Answer({this.answer, this.images = const []});

  factory Answer.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final answer =
        (data['answer'] as List).map((q) => q.toString()).toList() ?? [];
    return Answer(answer: answer);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'answer': answer,
    };
  }
}
