import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/firestore_service.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Future<void> setUser(User user);
  Stream<List<Symptom>> symptomsStream();
  Future<List<ScreeningQuestions>> getScreeningQuestions({String symptomName});
  Future<List<String>> getAllProviderAddresses();
  Stream<List<User>> getAllProviders();
  Stream<User> providerStream({String uid});
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  Future<void> setUser(User user) => _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.toMap(),
      );

  @override
  Stream<List<Symptom>> symptomsStream() => _service.collectionStream(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  @override
  Future<List<ScreeningQuestions>> getScreeningQuestions(
          {String symptomName}) =>
      _service
          .collectionStream(
            path: FirestorePath.screeningQuestions(symptomName),
            builder: (data, documentId) =>
                ScreeningQuestions.fromMap(data, documentId),
          )
          .first;

  @override
  Future<List<String>> getAllProviderAddresses() => _service
      .collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where('type', isEqualTo: "provider"),
        builder: (data, documentId) => data["address"].toString(),
      )
      .first;

  @override
  Stream<List<User>> getAllProviders() => _service.collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where('type', isEqualTo: "provider"),
        builder: (data, documentId) =>
            User.fromMap(userType: "Provider", data: data, uid: documentId),
      );

  @override
  Stream<User> providerStream({String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) =>
            User.fromMap(userType: "Provider", data: data, uid: documentId),
      );
}
