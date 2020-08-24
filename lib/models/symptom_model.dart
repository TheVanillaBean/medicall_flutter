import 'package:meta/meta.dart';

class Symptom {
  final String name;
  final String description;
  final String duration;
  final int price;
  final String category;
  final String commonMedications;

  Symptom({
    @required this.name,
    @required this.description,
    @required this.duration,
    @required this.price,
    @required this.category,
    @required this.commonMedications,
  });

  factory Symptom.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String description = data['description'];
    final String duration = data['duration'];
    final int price = data['price'];
    final String category = data['category'] ?? "None";
    final String commonMedications = data['common_medications'] ?? "";

    return Symptom(
      name: documentId,
      description: description,
      duration: duration,
      price: price,
      category: category,
      commonMedications: commonMedications,
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
