import 'package:Medicall/models/medicall_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {
  MedicallUser currentMedicallUser;
}

class FirestoreDatabase implements Database {
  MedicallUser currentMedicallUser;

  FirestoreDatabase();

  Future<void> _setData({String path, Map<String, dynamic> data}) async {
    final reference = Firestore.instance.document(path);
    print('$path: $data');
    await reference.setData(data);
  }
}
