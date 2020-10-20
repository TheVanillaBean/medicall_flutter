import 'dart:async';

///
/// [Author] Alex (https://github.com/Alex525)
/// [Date] 2020/3/31 15:28
///
import 'dart:math' as math;

import 'package:Medicall/common_widgets/asset_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/asset_picker/delegates/sort_path_delegate.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// [ChangeNotifier] for assets picker.
/// 资源选择器的 provider model
abstract class AssetPickerProviderBase extends ChangeNotifier {
  AssetPickerProviderBase({
    this.maxAssets = 9,
    this.pageSize = 320,
    this.pathThumbSize = 80,
    this.requestType = RequestType.image,
    this.sortPathDelegate = SortPathDelegate.common,
    this.filterOptions,
    List<AssetEntity> selectedAssets,
  });

  /// [StreamController] for viewing page index update.
  ///
  /// The main purpose is narrow down build parts when page index is changing, prevent
  /// widely [setState] and causing other widgets rebuild.
  final StreamController<int> pageStreamController =
      StreamController<int>.broadcast();

  /// [PageController] for assets preview [PageView].
  PageController pageController;

  /// Current previewing index.
  int currentIndex;

  /// Maximum count for asset selection.
  final int maxAssets;

  /// Assets should be loaded per page.
  final int pageSize;

  /// Thumb size for path selector.
  final int pathThumbSize;

  /// Request assets type.
  final RequestType requestType;

  /// Delegate to sort asset path entities.
  final SortPathDelegate sortPathDelegate;

  /// Filter options for the picker.
  ///
  /// Will be merged into the base configuration.
  final FilterOptionGroup filterOptions;

  /// Clear all fields when dispose.
  @override
  void dispose() {
    pageStreamController.close();
    _isAssetsEmpty = false;
    _currentAssets = null;
    _selectedAssets.clear();
    super.dispose();
  }

  /// Whether there're any assets on the devices.
  bool _isAssetsEmpty = false;

  bool get isAssetsEmpty => _isAssetsEmpty;

  set isAssetsEmpty(bool value) {
    if (value == null || value == _isAssetsEmpty) {
      return;
    }
    _isAssetsEmpty = value;
    notifyListeners();
  }

  bool _hasAssetsToDisplay = false;

  bool get hasAssetsToDisplay => _hasAssetsToDisplay;

  set hasAssetsToDisplay(bool value) {
    assert(value != null);
    if (value == _hasAssetsToDisplay) {
      return;
    }
    _hasAssetsToDisplay = value;
    notifyListeners();
  }

  bool get hasMoreToLoad => _currentAssets.length < _totalAssetsCount;

  int get currentAssetsListPage =>
      (math.max(1, _currentAssets.length) / pageSize).ceil();

  int _totalAssetsCount = 0;

  int get totalAssetsCount => _totalAssetsCount;

  set totalAssetsCount(int value) {
    assert(value != null);
    if (value == _totalAssetsCount) {
      return;
    }
    _totalAssetsCount = value;
    notifyListeners();
  }

  List<AssetEntity> _currentAssets;

  List<AssetEntity> get currentAssets => _currentAssets;

  set currentAssets(List<AssetEntity> value) {
    assert(value != null);
    if (value == _currentAssets) {
      return;
    }
    _currentAssets = List<AssetEntity>.from(value);
    notifyListeners();
  }

  List<AssetEntity> _selectedAssets = <AssetEntity>[];

  List<AssetEntity> get selectedAssets => _selectedAssets;

  set selectedAssets(List<AssetEntity> value) {
    assert(value != null);
    if (value == _selectedAssets) {
      return;
    }
    _selectedAssets = List<AssetEntity>.from(value);
    notifyListeners();
  }

  bool get isSelectedNotEmpty => selectedAssets.isNotEmpty;

  void selectAsset(AssetEntity item) {
    if (selectedAssets.length == maxAssets || selectedAssets.contains(item)) {
      return;
    }
    final List<AssetEntity> _set = List<AssetEntity>.from(selectedAssets);
    _set.add(item);
    selectedAssets = _set;
  }

  void unSelectAsset(AssetEntity item) {
    final List<AssetEntity> _set = List<AssetEntity>.from(selectedAssets);
    _set.remove(item);
    selectedAssets = _set;
  }
}
