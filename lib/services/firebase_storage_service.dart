import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

import 'firestore_path.dart';

class FirebaseStorageService {
  FirebaseStorageService({@required this.uid}) : assert(uid != null);
  final String uid;

  Future<String> uploadProfileImage({
    @required Asset asset,
  }) async {
    ByteData byteData = await getAccurateByteData(asset);
    Uint8List imageData = byteData.buffer.asUint8List();
    String assetName = getImageName(asset.name);
    return await upload(
      data: imageData,
      path: FirestorePath.userProfileImage(uid: uid, assetName: assetName),
      contentType: 'image/jpg',
    );
  }

  Future<String> uploadConsultPhoto({
    @required String consultId,
    @required String name,
    @required ByteData byteData,
  }) async {
//    ByteData byteData = await getAccurateByteData(asset);
    Uint8List imageData = byteData.buffer.asUint8List();
    String assetName = getImageName(name);
    return await upload(
      data: imageData,
      path: FirestorePath.consultPhotoQuestion(
          consultID: consultId, assetName: assetName),
      contentType: 'image/jpg',
    );
  }

  /// Generic file upload for any [path] and [contentType]
  Future<String> upload({
    @required Uint8List data,
    @required String path,
    @required String contentType,
  }) async {
    print('uploading to: $path');
    final storageReference = FirebaseStorage.instance.ref().child(path);
    final uploadTask = storageReference.putData(
        data, StorageMetadata(contentType: contentType));
    final snapshot = await uploadTask.onComplete;
    if (snapshot.error != null) {
      print('upload error code: ${snapshot.error}');
      throw snapshot.error;
    }
    // Url used to download file/image
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('downloadUrl: $downloadUrl');
    return downloadUrl;
  }

  Future<String> getSymptomPhotoURL({String symptom}) async {
    final path = FirestorePath.symptomPhoto(symptom: symptom);
    final storageReference = FirebaseStorage.instance.ref().child(path);
    return await storageReference.getDownloadURL();
  }

  //helper methods

  //The purpose of this function is too ensure the image that gets uploaded
  //is no greater than 300k bytes. By setting quality to something standard,
  //the size is not guaranteed. An image uploaded by a phone with a low resolution
  //would produce an even lower size bytedata. This function ensures consistency.
  static Future<ByteData> getAccurateByteData(Asset asset) async {
    ByteData byteData;
    int size = 0; // represents the size of the image in bytes
    int quality = 100;

    do {
      byteData = await asset.getByteData(quality: quality);
      size = byteData.buffer.lengthInBytes;
      quality = quality - 10;
    } while (size > 500000 && quality > 40);

    return byteData;
  }

  static String getImageName(String assetName) {
    Uuid uuid = Uuid();
    return assetName.split(".").first +
        uuid.v1(); //image name without extension
  }
}
