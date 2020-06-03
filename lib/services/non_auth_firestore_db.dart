import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/symptoms.dart';
import 'package:Medicall/services/firestore_service.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Stream<List<Symptom>> symptomsStream();
  Future<List<String>> getAllProviderAddresses();
  Stream<List<MedicallUser>> getAllProviders();
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  @override
  Stream<List<Symptom>> symptomsStream() => _service.collectionStream(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  @override
  Future<List<String>> getAllProviderAddresses() => _service
      .collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where('type', isEqualTo: "provider"),
        builder: (data, documentId) => data["address"].toString(),
      )
      .first;

  @override
  Stream<List<MedicallUser>> getAllProviders() => _service.collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where('type', isEqualTo: "provider"),
        builder: (data, documentId) => MedicallUser.fromMap(data, documentId),
      );
}
