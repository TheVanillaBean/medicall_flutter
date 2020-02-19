import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PhotoIdScreenModel with EmailAndPasswordValidators, ChangeNotifier {
  ExtImageProvider extImageProvider;
  List<Asset> images = List<Asset>();
  List<Asset> govIdImage = List<Asset>();
  List<Asset> profileImage = List<Asset>();
  String error = '';


  PhotoIdScreenModel({
    @required this.extImageProvider,
    this.images,
    this.govIdImage,
    this.profileImage,
    this.error,
  });

  void updateWith({
    ExtImageProvider extImageProvider,
    List<Asset> images,
    List<Asset> govIdImage,
    List<Asset> profileImage,
    String error,
  }) {
    this.extImageProvider = extImageProvider ?? this.extImageProvider;
    this.images = images ?? this.images;
    this.govIdImage = govIdImage ?? this.govIdImage;
    this.profileImage = profileImage ?? this.profileImage;
    this.error = error ?? this.error;
    notifyListeners();
  }
}
