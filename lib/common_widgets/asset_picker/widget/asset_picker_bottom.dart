import 'dart:io';

import 'package:Medicall/common_widgets/asset_picker/constants/constants.dart';
import 'package:Medicall/common_widgets/asset_picker/constants/enums.dart';
import 'package:Medicall/common_widgets/asset_picker/constants/extensions.dart';
import 'package:Medicall/common_widgets/asset_picker/constants/screens.dart';
import 'package:Medicall/common_widgets/asset_picker/provider/asset_entity_image_provider.dart';
import 'package:Medicall/common_widgets/asset_picker/provider/asset_picker_provider_base.dart';
import 'package:Medicall/common_widgets/asset_picker/provider/asset_picker_viewer_provider.dart';
import 'package:Medicall/common_widgets/asset_picker/widget/asset_picker_viewer.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class BottomBar extends StatefulWidget {
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAssets;
  final AssetPickerProviderBase selectorProvider;
  final ThemeData themeData;
  final List<int> previewThumbSize;
  final SpecialPickerType specialPickerType;
  final bool displayOnTop;

  const BottomBar({
    Key key,
    @required this.assets,
    @required this.themeData,
    this.displayOnTop = false,
    this.previewThumbSize,
    this.selectedAssets,
    this.selectorProvider,
    this.specialPickerType,
  }) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  AssetPickerViewerProvider provider;
  bool isDisplayingDetail = true;
  AssetEntity get currentAsset =>
      widget.assets.elementAt(widget.selectorProvider.currentIndex);
  double get bottomDetailHeight => widget.displayOnTop ? 160 : 140;
  bool get isAppleOS => Platform.isIOS || Platform.isMacOS;

  @override
  void initState() {
    super.initState();

    if (widget.selectedAssets != null) {
      provider = AssetPickerViewerProvider(widget.selectedAssets);
    }
  }

  Widget _buildBottomBarContainer(BuildContext context) {
    double topPadding = widget.displayOnTop ? 16 : 0;
    return Container(
      padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
      color: widget.themeData.canvasColor.withOpacity(0.85),
      child: Column(
        children: <Widget>[
          ChangeNotifierProvider<AssetPickerViewerProvider>.value(
            value: provider,
            child: SizedBox(
              height: widget.displayOnTop ? 110 : 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(5, topPadding, 5, 0),
                itemCount: widget.selectedAssets.length,
                itemBuilder: _bottomDetailItem,
              ),
            ),
          ),
          Container(
            height: 1.0,
            color: widget.themeData.dividerColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Spacer(),
                  if (isAppleOS && provider != null)
                    ChangeNotifierProvider<AssetPickerViewerProvider>.value(
                      value: provider,
                      child: confirmButton(context),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomDetailItem(BuildContext _, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: StreamBuilder<int>(
          initialData: widget.selectorProvider.currentIndex,
          stream: widget.selectorProvider.pageStreamController.stream,
          builder: (BuildContext _, AsyncSnapshot<int> snapshot) {
            final AssetEntity asset = widget.selectedAssets.elementAt(index);
            final bool isViewing = asset == currentAsset;
            return GestureDetector(
              onTap: () async {
                if (widget.assets == widget.selectedAssets) {
                  final List<AssetEntity> result =
                      await AssetPickerViewer.pushToViewer(
                    context,
                    currentIndex: 0,
                    assets: widget.selectorProvider.selectedAssets,
                    previewThumbSize: widget.previewThumbSize,
                    selectedAssets: widget.selectorProvider.selectedAssets,
                    selectorProvider: widget.selectorProvider,
                    themeData: widget.themeData,
                  );
                  if (result != null) {
                    Navigator.of(context).pop(result);
                  }
                }
              },
              child: Selector<AssetPickerViewerProvider, List<AssetEntity>>(
                selector: (
                  BuildContext _,
                  AssetPickerViewerProvider provider,
                ) =>
                    provider.currentlySelectedAssets,
                builder: (
                  BuildContext _,
                  List<AssetEntity> currentlySelectedAssets,
                  Widget __,
                ) {
                  final bool isSelected =
                      currentlySelectedAssets.contains(asset);
                  return Stack(
                    children: <Widget>[
                      () {
                        Widget item;
                        switch (asset.type) {
                          case AssetType.other:
                            item = const SizedBox.shrink();
                            break;
                          case AssetType.image:
                            item = _imagePreviewItem(asset);
                            break;
                          case AssetType.video:
                            item = _videoPreviewItem(asset);
                            break;
                          case AssetType.audio:
                            item = _audioPreviewItem(asset);
                            break;
                        }
                        return item;
                      }(),
                      AnimatedContainer(
                        duration: kThemeAnimationDuration,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          border: isViewing
                              ? Border.all(
                                  color: widget.themeData.colorScheme.secondary,
                                  width: 2.0,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : widget.themeData.colorScheme.surface
                                  .withOpacity(0.54),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget confirmButton(BuildContext context) =>
      ChangeNotifierProvider<AssetPickerViewerProvider>.value(
        value: provider,
        child: Consumer<AssetPickerViewerProvider>(
          builder: (
            BuildContext _,
            AssetPickerViewerProvider provider,
            Widget __,
          ) {
            return MaterialButton(
              minWidth: () {
                if (widget.specialPickerType ==
                    SpecialPickerType.wechatMoment) {
                  return 48.0;
                }
                return provider.isSelectedNotEmpty ? 48.0 : 20.0;
              }(),
              height: 32.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              color: () {
                if (widget.specialPickerType ==
                    SpecialPickerType.wechatMoment) {
                  return widget.themeData.colorScheme.secondary;
                }
                return provider.isSelectedNotEmpty
                    ? widget.themeData.colorScheme.secondary
                    : widget.themeData.dividerColor;
              }(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Text(
                () {
                  if (widget.specialPickerType ==
                      SpecialPickerType.wechatMoment) {
                    return Constants.textDelegate.confirm;
                  }
                  if (provider.isSelectedNotEmpty) {
                    return '${Constants.textDelegate.confirm}'
                        '(${provider.currentlySelectedAssets.length}'
                        '/'
                        '${widget.selectorProvider.maxAssets})';
                  }
                  return Constants.textDelegate.confirm;
                }(),
                style: TextStyle(
                  color: () {
                    if (widget.specialPickerType ==
                        SpecialPickerType.wechatMoment) {
                      return widget.themeData.textTheme.bodyText1.color;
                    }
                    return provider.isSelectedNotEmpty
                        ? widget.themeData.textTheme.bodyText1.color
                        : widget.themeData.textTheme.caption.color;
                  }(),
                  fontSize: 17.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                if (widget.specialPickerType ==
                    SpecialPickerType.wechatMoment) {
                  Navigator.of(context).pop(<AssetEntity>[currentAsset]);
                  return;
                }
                if (provider.isSelectedNotEmpty) {
                  Navigator.of(context).pop(provider.currentlySelectedAssets);
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          },
        ),
      );

  Widget _audioPreviewItem(AssetEntity asset) {
    return ColoredBox(
      color: context.themeData.dividerColor,
      child: const Center(child: Icon(Icons.audiotrack)),
    );
  }

  /// Preview item widgets for images.
  Widget _imagePreviewItem(AssetEntity asset) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: ExtendedImage(
          image: AssetEntityImageProvider(
            asset,
            isOriginal: false,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Preview item widgets for video.
  Widget _videoPreviewItem(AssetEntity asset) {
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          _imagePreviewItem(asset),
          Center(
            child: Icon(
              Icons.video_library,
              color: widget.themeData.colorScheme.surface.withOpacity(0.54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.displayOnTop) {
      return AnimatedPositioned(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        top: isDisplayingDetail
            ? 0
            : -(Screens.bottomSafeHeight + bottomDetailHeight),
        left: 0.0,
        right: 0.0,
        height: Screens.bottomSafeHeight + bottomDetailHeight,
        child: _buildBottomBarContainer(context),
      );
    } else {
      return AnimatedPositioned(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        bottom: isDisplayingDetail
            ? 0
            : -(Screens.bottomSafeHeight + bottomDetailHeight),
        left: 0.0,
        right: 0.0,
        height: Screens.bottomSafeHeight + bottomDetailHeight,
        child: _buildBottomBarContainer(context),
      );
    }
  }
}
