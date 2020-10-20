import 'dart:async';
import 'dart:typed_data';

import 'package:Medicall/common_widgets/asset_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/asset_picker/delegates/sort_path_delegate.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'asset_picker_provider_base.dart';

/// [ChangeNotifier] for assets picker.
/// 资源选择器的 provider model
class AssetPickerProvider extends AssetPickerProviderBase {
  /// Call [getAssetList] with route duration when constructing.
  /// 构造时根据路由时长延时获取资源
  AssetPickerProvider({
    maxAssets = 9,
    pageSize = 320,
    pathThumbSize = 80,
    requestType = RequestType.image,
    sortPathDelegate = SortPathDelegate.common,
    filterOptions,
    List<AssetEntity> selectedAssets,
    Duration routeDuration,
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
    Future<void>.delayed(routeDuration).then(
      (dynamic _) async {
        await getAssetPathList();
        await getAssetList();
      },
    );
  }

  /// If path switcher opened.
  /// 是否正在进行路径选择
  bool _isSwitchingPath = false;

  bool get isSwitchingPath => _isSwitchingPath;

  set isSwitchingPath(bool value) {
    assert(value != null);
    if (value == _isSwitchingPath) {
      return;
    }
    _isSwitchingPath = value;
    notifyListeners();
  }

  /// Map for all path entity.
  /// 所有包含资源的路径里列表
  ///
  /// Using [Map] in order to save the thumb data for the first asset under the path.
  /// 使用[Map]来保存路径下第一个资源的缩略数据。
  final Map<AssetPathEntity, Uint8List> _pathEntityList =
      <AssetPathEntity, Uint8List>{};

  Map<AssetPathEntity, Uint8List> get pathEntityList => _pathEntityList;

  /// Path entity currently using.
  /// 正在查看的资源路径
  AssetPathEntity _currentPathEntity;

  AssetPathEntity get currentPathEntity => _currentPathEntity;

  set currentPathEntity(AssetPathEntity value) {
    assert(value != null);
    if (value == _currentPathEntity) {
      return;
    }
    _currentPathEntity = value;
    notifyListeners();
  }

  /// Get assets path entities.
  /// 获取所有的资源路径
  Future<void> getAssetPathList() async {
    /// Initial base options.
    /// Enable need title for audios and image to get proper display.
    final FilterOptionGroup options = FilterOptionGroup()
      ..setOption(
        AssetType.audio,
        const FilterOption(needTitle: true),
      )
      ..setOption(
        AssetType.image,
        const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      );

    /// Merge user's filter option into base options if it's not null.
    if (filterOptions != null) {
      options.merge(filterOptions);
    }

    final List<AssetPathEntity> _list = await PhotoManager.getAssetPathList(
      type: requestType,
      filterOption: options,
    );

    /// Sort path using sort path delegate.
    Constants.sortPathDelegate.sort(_list);

    for (final AssetPathEntity pathEntity in _list) {
      // Use sync method to avoid unnecessary wait.
      _pathEntityList[pathEntity] = null;
      if (requestType != RequestType.audio) {
        getFirstThumbFromPathEntity(pathEntity).then((Uint8List data) {
          _pathEntityList[pathEntity] = data;
        });
      }
    }

    /// Set first path entity as current path entity.
    if (_pathEntityList.isNotEmpty) {
      _currentPathEntity ??= pathEntityList.keys.elementAt(0);
    }
  }

  /// Get assets list from current path entity.
  /// 从当前已选路径获取资源列表
  Future<void> getAssetList() async {
    if (_pathEntityList.isNotEmpty) {
      _currentPathEntity = pathEntityList.keys.elementAt(0);
      totalAssetsCount = currentPathEntity.assetCount;
      getAssetsFromEntity(0, currentPathEntity);
      // Update total assets count.
    } else {
      isAssetsEmpty = true;
    }
  }

  /// Get thumb data from the first asset under the specific path entity.
  /// 获取指定路径下的第一个资源的缩略数据
  Future<Uint8List> getFirstThumbFromPathEntity(
      AssetPathEntity pathEntity) async {
    final AssetEntity asset =
        (await pathEntity.getAssetListRange(start: 0, end: 1)).elementAt(0);
    final Uint8List assetData =
        await asset.thumbDataWithSize(pathThumbSize, pathThumbSize);
    return assetData;
  }

  /// Get assets under the specific path entity.
  /// 获取指定路径下的资源
  Future<void> getAssetsFromEntity(int page, AssetPathEntity pathEntity) async {
    currentAssets = (await pathEntity.getAssetListPaged(
            page, pageSize ?? pathEntity.assetCount))
        .toList();
    hasAssetsToDisplay = currentAssets?.isNotEmpty ?? false;
    notifyListeners();
  }

  /// Load more assets.
  /// 加载更多资源
  Future<void> loadMoreAssets() async {
    final List<AssetEntity> assets = (await currentPathEntity.getAssetListPaged(
      currentAssetsListPage,
      pageSize,
    ))
        .toList();
    if (assets.isNotEmpty && currentAssets.contains(assets[0])) {
      return;
    } else {
      final List<AssetEntity> tempList = <AssetEntity>[];
      tempList.addAll(currentAssets);
      tempList.addAll(assets);
      currentAssets = tempList;
    }
  }

  /// Switch path entity.
  /// 切换路径
  void switchPath(AssetPathEntity pathEntity) {
    _isSwitchingPath = false;
    _currentPathEntity = pathEntity;
    totalAssetsCount = pathEntity.assetCount;
    notifyListeners();
    getAssetsFromEntity(0, currentPathEntity);
  }
}
