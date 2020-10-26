import 'package:Medicall/common_widgets/camera_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/camera_picker/widget/camera_picker.dart';
import 'package:flutter/cupertino.dart';

class ImagePicker {
  static Future<AssetEntity> pickSingleImage({BuildContext context}) async {
    final List<AssetEntity> result = await CameraPicker.pickFromCamera(
      context,
      isAllowRecording: false,
      cameraTextDelegate: EnglishCameraPickerTextDelegate(),
      maxAssets: 1,
    );
    if (result == null || result.length == 0) {
      throw "Error retrieving images";
    }

    return result.first;
  }

  static Future<List<AssetEntity>> pickImages(
      {BuildContext context, int maxImages}) async {
    final List<AssetEntity> result = await CameraPicker.pickFromCamera(
      context,
      isAllowRecording: false,
      cameraTextDelegate: EnglishCameraPickerTextDelegate(),
      maxAssets: 1,
    );
    if (result == null || result.length == 0) {
      throw "Error retrieving images";
    }

    return result;
  }
}
