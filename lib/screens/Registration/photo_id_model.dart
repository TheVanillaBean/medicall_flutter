import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PhotoIdScreenModel with ChangeNotifier {
  final ExtImageProvider
      extImageProvider; // We can make this a final variable because we can set it in the create() method
  TempUserProvider
      tempUserProvider; //This is not final because we will update the provider with the right tempUserProvider after the create() method finishes.
  List<Asset> images;
  List<Asset> govIdImage;
  List<Asset> profileImage;
  String error;

  PhotoIdScreenModel({
    @required this.extImageProvider,
    this.tempUserProvider,
    this.images = const [],
    this.govIdImage = const [],
    this.profileImage = const [],
    this.error = '',
  });

  //The reason it is best to create a separate function to set the provider is because if we do it in the updateWith, then notifyListeners is called and that is not necessary here. We don't need to the UI to rebuild yet, we are jts setting a provider.
  void setTempUserProvider(TempUserProvider tempUserProvider) {
    this.tempUserProvider = tempUserProvider;
  }

  //Provider's don't need to go here because the provider itself has it's fields updated based on the fields updated here.
  //So if tempUserProvider
  void updateWith({
    List<Asset> images,
    List<Asset> govIdImage,
    List<Asset> profileImage,
    String error,
  }) {
//    this.images = images ?? this.images; //Previous code
//    this.tempUserProvider.updateWith(images: images ?? this.images); //New code
    //So the provider is updated based of the fields in this function (images, govIdImage, etc.), but there is no reason to actually include the provider as an argument in this function.
    this.govIdImage = govIdImage ?? this.govIdImage;
    this.profileImage = profileImage ?? this.profileImage;
    this.error = error ?? this.error;
    notifyListeners();
  }
}
