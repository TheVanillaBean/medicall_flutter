import 'package:Medicall/models/screening_question_model.dart';
import 'package:meta/meta.dart';

class Symptom {
  final String name;
  final String description;
  final String duration;
  final int price;
  final List<Question> screeningQuestions;

  Symptom({
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.price,
    @required this.screeningQuestions,
  });

  factory Symptom.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String description = data['description'];
    final String duration = data['duration'];
    final int price = data['price'];

    final questions = (data['screening_question'] as List ?? [])
        .map((v) => Question.fromMap(v))
        .toList();

    return Symptom(
      name: documentId,
      description: description,
      duration: duration,
      price: price,
      screeningQuestions: questions,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'duration': duration,
      'price': price,
      'screening_question': screeningQuestions.map((q) => q.toMap()).toList(),
    };
  }

  @override
  String toString() =>
      'name: $name, description: $description, duration: $duration, price: $price';
}
