import 'package:Medicall/models/option_model.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Question {
  String question;
  String type;
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
    final type = data['type'] ?? '';

    final options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();

    Answer answer;
    if (data['answer'] != null) {
      answer = Answer.fromMap(data);
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
    return <String, dynamic>{
      'question': question,
      'type': type,
      'required': required,
      'placeholder_image': placeholderImage,
      'max_images': maxImages,
      'options': options.map((opt) => opt.toMap()).toList(),
      'answer': answer != null ? answer.toMap() : null,
    };
  }
}

class Answer {
  List<String> answer;
  List<Asset> images; //if it is a photo question. Not serialized.

  Answer({this.answer, this.images = const []});

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
