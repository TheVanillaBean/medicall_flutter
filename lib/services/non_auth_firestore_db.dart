import 'package:Medicall/models/symptoms.dart';
import 'package:Medicall/services/firestore_service.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Stream<List<Symptom>> symptomsStream();
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  Stream<List<Symptom>> symptomsStream() => _service.collectionStream(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );
}
