import 'package:Medicall/common_widgets/asset_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/asset_picker/delegates/sort_path_delegate.dart';
import 'package:Medicall/common_widgets/asset_picker/provider/asset_picker_provider_base.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// [ChangeNotifier] for assets picker.
class BottomBarProvider extends AssetPickerProviderBase {
  BottomBarProvider({
    maxAssets = 9,
    pageSize = 320,
    pathThumbSize = 80,
    requestType = RequestType.image,
    sortPathDelegate = SortPathDelegate.common,
    filterOptions,
    List<AssetEntity> selectedAssets,
  }) : super(
          maxAssets: maxAssets,
          pageSize: pageSize,
          pathThumbSize: pathThumbSize,
          requestType: requestType,
          sortPathDelegate: sortPathDelegate,
          filterOptions: filterOptions,
          selectedAssets: selectedAssets,
        ) {
    if (selectedAssets?.isNotEmpty ?? false) {
      selectedAssets = List<AssetEntity>.from(selectedAssets);
    }
    Constants.sortPathDelegate = sortPathDelegate ?? SortPathDelegate.common;
  }
}
