import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// [ChangeNotifier] for assets picker.
/// 资源选择器的 provider model
class CameraPickerProvider extends ChangeNotifier {
  CameraPickerProvider({this.selectedAssets});

  List<AssetEntity> selectedAssets = [];

  void updateSelectedAssetsWith(
    List<AssetEntity> selectedAssets,
  ) {
    this.selectedAssets = selectedAssets;
    notifyListeners();
  }
}
