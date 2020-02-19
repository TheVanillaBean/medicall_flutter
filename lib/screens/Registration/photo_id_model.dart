import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PhotoIdScreenModel with ChangeNotifier {
  ExtImageProvider extImageProvider;
  TempUserProvider tempUserProvider;
  List<Asset> images;
  List<Asset> govIdImage;
  List<Asset> profileImage;
  String error;


  PhotoIdScreenModel({
    @required this.extImageProvider,
    @required this.tempUserProvider,
    this.images = const [],
    this.govIdImage = const [],
    this.profileImage = const [],
    this.error = '',
  });

  void updateWith({
    ExtImageProvider extImageProvider,
    TempUserProvider tempUserProvider,
    List<Asset> images,
    List<Asset> govIdImage,
    List<Asset> profileImage,
    String error,
  }) {
    this.extImageProvider = extImageProvider ?? this.extImageProvider;
    this.tempUserProvider = tempUserProvider ?? this.tempUserProvider;
    this.images = images ?? this.images;
    this.govIdImage = govIdImage ?? this.govIdImage;
    this.profileImage = profileImage ?? this.profileImage;
    this.error = error ?? this.error;
    notifyListeners();
  }
}
