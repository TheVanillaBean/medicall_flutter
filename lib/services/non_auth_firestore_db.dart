import 'package:Medicall/models/symptom_model.dart';
import 'package:Medicall/models/user/patient_user_model.dart';
import 'package:Medicall/models/user/provider_user_model.dart';
import 'package:Medicall/models/user/user_model_base.dart';
import 'package:Medicall/models/version.dart';
import 'package:Medicall/services/firestore_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firestore_path.dart';

abstract class NonAuthDatabase {
  Future<VersionInfo> versionInfoStream();
  Future<void> setUser(MedicallUser user, {bool merge = false});
  Future<List<String>> symptomsListByName();
  Stream<List<Symptom>> symptomsStream();
  Future<List<String>> getAllProviderStates();
  Stream<List<ProviderUser>> getAllProvidersWithInsurance(
      {String state, String symptom, String insurance});
  Stream<List<ProviderUser>> getAllProvidersWithoutInsurance(
      {String state, String symptom, String insurance});
  Stream<MedicallUser> providerStream({String uid});
  Future<String> getSymptomPhotoURL({String symptom});
  Future<void> addEmailToWaitList({String email, String state});
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

  Future<void> setUser(MedicallUser user, {bool merge = false}) =>
      _service.setData(
        path: FirestorePath.user(user.uid),
        data: user.type == USER_TYPE.PATIENT
            ? (user as PatientUser).toMap()
            : (user as ProviderUser).toMap(),
        merge: merge,
      );

  @override
  Future<List<String>> symptomsListByName() => _service
      .collectionStream(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => documentId,
      )
      .first;

  @override
  Stream<List<Symptom>> symptomsStream() => _service.collectionStream(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  @override
  Future<List<String>> getAllProviderStates() => _service
      .collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query.where(
          'type',
          isEqualTo: EnumToString.convertToString(USER_TYPE.PROVIDER),
        ),
        builder: (data, documentId) => data["mailing_state"].toString(),
      )
      .first;

  @override
  Stream<List<ProviderUser>> getAllProvidersWithInsurance(
          {String state, String symptom, String insurance}) =>
      _service.collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query
            .where(
              'type',
              isEqualTo: EnumToString.convertToString(USER_TYPE.PROVIDER),
            )
            .where("stripe_connect_authorized", isEqualTo: true)
            .where("mailing_state", isEqualTo: state)
            .where("selected_services", arrayContains: symptom)
            .where("accepted_insurances", arrayContains: insurance),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );

  @override
  Stream<List<ProviderUser>> getAllProvidersWithoutInsurance(
          {String state, String symptom, String insurance}) =>
      _service.collectionStream(
        path: FirestorePath.users(),
        queryBuilder: (query) => query
            .where(
              'type',
              isEqualTo: EnumToString.convertToString(USER_TYPE.PROVIDER),
            )
            .where("stripe_connect_authorized", isEqualTo: true)
            .where("mailing_state", isEqualTo: state)
            .where("selected_services", arrayContains: symptom)
            .where("accepted_insurances", whereNotIn: [insurance]),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );

  @override
  Stream<ProviderUser> providerStream({String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => MedicallUser.fromMap(
            userType: USER_TYPE.PROVIDER, data: data, uid: documentId),
      );

  @override
  Future<String> getSymptomPhotoURL({String symptom}) async {
    final path = FirestorePath.symptomPhoto(symptom: symptom);
    final storageReference = FirebaseStorage.instance.ref().child(path);
    return await storageReference.getDownloadURL();
  }

  @override
  Future<void> addEmailToWaitList({String email, String state}) async {
    final waitListObj = {"email": email, "state": state};
    _service.setData(
      path: FirestorePath.waitList(email),
      data: waitListObj,
    );
  }
}
