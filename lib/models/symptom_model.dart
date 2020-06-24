import 'package:meta/meta.dart';

class Symptom {
  final String name;
  final String description;
  final String duration;
  final int price;

  Symptom({
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.price,
  });

  factory Symptom.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String description = data['description'];
    final String duration = data['duration'];
    final int price = data['price'];

    return Symptom(
      name: documentId,
      description: description,
      duration: duration,
      price: price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'description': description,
      'duration': duration,
      'price': price,
    };
  }

  @override
  String toString() =>
      'name: $name, description: $description, duration: $duration, price: $price';
}
