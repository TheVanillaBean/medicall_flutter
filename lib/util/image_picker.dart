import 'dart:typed_data';

import 'package:Medicall/common_widgets/camera_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/camera_picker/widget/camera_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      maxAssets: 4,
    );
    if (result == null || result.length == 0) {
      throw "Error retrieving images";
    }

    return result;
  }
}

class AssetEntityImage extends StatelessWidget {
  final AssetEntity asset;
  final double width;
  final double height;

  const AssetEntityImage({
    @required this.asset,
    @required this.width,
    @required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: asset.thumbDataWithSize(
        (height * 0.2).toInt(),
        (height * 0.2).toInt(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data != null) {
            return Image.memory(
              snapshot.data,
              height: height * 0.2,
              width: height * 0.2,
              fit: BoxFit.fill,
            );
          } else {
            return Center(
              child: Text("Failed to load image :("),
            );
          }
        }
      },
    );
  }
}
