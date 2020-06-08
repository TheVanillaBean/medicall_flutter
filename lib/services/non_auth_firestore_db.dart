import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/services/firestore_service.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Future<void> setUser(MedicallUser user);
  Stream<List<Symptom>> symptomsStream();
  Future<List<String>> getAllProviderAddresses();
  Stream<List<MedicallUser>> getAllProviders();
  Stream<MedicallUser> providerStream({String uid});
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  Future<void> setUser(MedicallUser user) => _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.toMap(),
      );

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

  @override
  Stream<MedicallUser> providerStream({String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => MedicallUser.fromMap(data, documentId),
      );
}
