import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Database {}

class FirestoreDatabase implements Database {
  String uid;

  FirestoreDatabase();

  Future<void> _setData({String path, Map<String, dynamic> data}) async {
    final reference = Firestore.instance.document(path);
    print('$path: $data');
    await reference.setData(data);
  }
}
