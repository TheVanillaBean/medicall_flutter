import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/screening_questions_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Future<void> setUser(User user);
  Stream<List<Symptom>> symptomsStream();
  Future<List<ScreeningQuestions>> getScreeningQuestions({String symptomName});
  Future<List<String>> getAllProviderAddresses();
  Stream<List<ProviderUser>> getAllProviders();
  Stream<User> providerStream({String uid});
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  Future<void> setUser(User user) => _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.type == USER_TYPE.PATIENT
            ? (user as PatientUser).toMap()
            : (user as ProviderUser).toMap(),
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
        queryBuilder: (query) => query.where(
          'type',
          isEqualTo: EnumToString.parse(USER_TYPE.PROVIDER),
        ),
        builder: (data, documentId) => data["address"].toString(),
      )
      .first;

  @override
  Stream<List<ProviderUser>> getAllProviders() => _service.collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where(
          'type',
          isEqualTo: EnumToString.parse(USER_TYPE.PROVIDER),
        ),
        builder: (data, documentId) => User.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );

  @override
  Stream<ProviderUser> providerStream({String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => User.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );
}
