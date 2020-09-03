import 'package:Medicall/models/patient_user_model.dart';
import 'package:Medicall/models/provider_user_model.dart';
import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user_model_base.dart';
import 'package:Medicall/models/version.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Future<VersionInfo> versionInfoStream();
  Future<void> setUser(MedicallUser user);
  Stream<List<Symptom>> symptomsStream();
  Future<List<String>> getAllProviderAddresses();
  Stream<List<ProviderUser>> getAllProviders();
  Stream<MedicallUser> providerStream({String uid});
}

class NonAuthFirestoreDB implements NonAuthDatabase {
  final _service = FirestoreService.instance;

  @override
  Future<VersionInfo> versionInfoStream() => _service
      .documentStream(
        path: FirestorePath.version(),
        builder: (data, documentId) =>
            VersionInfo.fromMap(data: data, documentId: documentId),
      )
      .first;

  Future<void> setUser(MedicallUser user) => _service.setData(
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
        queryBuilder: (query) => query
            .where(
              'type',
              isEqualTo: EnumToString.parse(USER_TYPE.PROVIDER),
            )
            .where("stripe_connect_authorized", isEqualTo: true),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );

  @override
  Stream<ProviderUser> providerStream({String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );
}
