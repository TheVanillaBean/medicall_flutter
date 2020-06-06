import 'dart:io';
import 'dart:typed_data';
import 'package:Medicall/common_widgets/carousel/carousel_state.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

abstract class ExtImageProvider {
  PageController pageController;
  List<Uint8List> listaU8L;
  List<Asset> currentAssetList;
  List<Asset> assetList;
  Map convertedImages;
  setChatImage();
  File chatMedia;
  CupertinoOptions pickImagesCupertinoOptions(
      {String backgroundColor,
      String selectionFillColor,
      String selectionShadowColor,
      String selectionStrokeColor,
      String selectionTextColor,
      String selectionCharacter,
      String takePhotoIcon,
      bool autoCloseOnSelectionLimit});
  MaterialOptions pickImagesMaterialOptions(
      {String actionBarColor,
      String actionBarTitle,
      bool lightStatusBar,
      String statusBarColor,
      String actionBarTitleColor,
      String allViewTitle,
      bool startInAllView,
      bool useDetailsView,
      String selectCircleStrokeColor,
      String selectionLimitReachedText,
      String textOnNothingSelected,
      String backButtonDrawable,
      String okButtonDrawable,
      bool autoCloseOnSelectionLimit});
  Future<bool> convertImages(BuildContext context);
  clearImageMemory();
  Future<List<Asset>> pickImages(
      List<Asset> _images,
      int _maxImages,
      bool _enableCamera,
      CupertinoOptions _cupertinoOptions,
      MaterialOptions _materialOptions,
      BuildContext context);
  ExtendedImage returnNetworkImage(String url,
      {double height,
      double width,
      BoxFit fit,
      bool cache,
      ExtendedImageMode mode,
      GestureConfig Function(ExtendedImageState) initGestureConfigHandler});
  ExtendedImage returnMemoryImage(Uint8List src,
      {double height,
      double width,
      BoxFit fit,
      bool memCache,
      ExtendedImageMode mode,
      GestureConfig Function(ExtendedImageState) initGestureConfigHandler});
  AssetThumb returnAssetThumb(
      {Key key,
      Asset asset,
      int width,
      int height,
      int quality = 100,
      Widget spinner = const Center(child: SizedBox(width: 50, height: 50))});

  ExtendedImageGesturePageView returnBuilder(
      BuildContext context, List<dynamic> itemList);
}

class ExtendedImageProvider implements ExtImageProvider {
  @override
  List<Uint8List> listaU8L = [];
  @override
  PageController pageController = PageController();
  @override
  List<Asset> currentAssetList = [];
  @override
  List<Asset> assetList = [];
  @override
  Map convertedImages = {};
  @override
  File chatMedia;
  @override
  MaterialOptions pickImagesMaterialOptions(
      {String actionBarColor,
      String actionBarTitle,
      bool lightStatusBar,
      String statusBarColor,
      String actionBarTitleColor,
      String allViewTitle,
      bool startInAllView,
      bool useDetailsView,
      String selectCircleStrokeColor,
      String selectionLimitReachedText,
      String textOnNothingSelected,
      String backButtonDrawable,
      String okButtonDrawable,
      bool autoCloseOnSelectionLimit}) {
    return MaterialOptions(
        actionBarColor: actionBarColor,
        actionBarTitle: actionBarTitle,
        lightStatusBar: lightStatusBar,
        statusBarColor: statusBarColor,
        actionBarTitleColor: actionBarTitleColor,
        allViewTitle: allViewTitle,
        startInAllView: startInAllView,
        useDetailsView: useDetailsView,
        selectCircleStrokeColor: selectCircleStrokeColor,
        selectionLimitReachedText: selectionLimitReachedText,
        textOnNothingSelected: textOnNothingSelected,
        backButtonDrawable: backButtonDrawable,
        okButtonDrawable: okButtonDrawable,
        autoCloseOnSelectionLimit: autoCloseOnSelectionLimit);
  }

  @override
  ExtendedImage returnNetworkImage(String _url,
      {double height,
      double width,
      BoxFit fit,
      bool cache = true,
      ExtendedImageMode mode,
      GestureConfig Function(ExtendedImageState) initGestureConfigHandler}) {
    return ExtendedImage.network(
      _url,
      height: height,
      width: width,
      fit: fit,
      enableSlideOutPage: true,
      cache: cache,
      mode: mode,
      initGestureConfigHandler: initGestureConfigHandler,
    );
  }

  CupertinoOptions pickImagesCupertinoOptions(
      {String backgroundColor,
      String selectionFillColor,
      String selectionShadowColor,
      String selectionStrokeColor,
      String selectionTextColor,
      String selectionCharacter,
      String takePhotoIcon,
      bool autoCloseOnSelectionLimit}) {
    return CupertinoOptions(
        autoCloseOnSelectionLimit: autoCloseOnSelectionLimit,
        backgroundColor: backgroundColor,
        selectionFillColor: selectionFillColor,
        selectionShadowColor: selectionShadowColor,
        selectionStrokeColor: selectionStrokeColor,
        selectionTextColor: selectionTextColor,
        selectionCharacter: selectionCharacter,
        takePhotoIcon: takePhotoIcon);
  }

  AssetThumb returnAssetThumb(
      {Key key,
      Asset asset,
      int width,
      int height,
      int quality = 100,
      Widget spinner = const Center(child: SizedBox(width: 50, height: 50))}) {
    return AssetThumb(
      key: key,
      asset: asset,
      width: width,
      height: height,
      quality: quality,
      spinner: spinner,
    );
  }

  clearImageMemory() {
    assetList = [];
    listaU8L = [];
    convertedImages = {};
  }

  Future<bool> convertImages(BuildContext context) async {
    if (assetList.length > 0) {
      for (var i = 0; i < assetList.length; i++) {
        if (!convertedImages.containsKey(assetList[i].name)) {
          await assetList[i]
              .getThumbByteData(MediaQuery.of(context).size.width.toInt(),
                  MediaQuery.of(context).size.height.toInt(),
                  quality: 70)
              .then((bd) {
            Uint8List a2 = bd.buffer.asUint8List();
            convertedImages[assetList[i].name] = a2;
            listaU8L.add(a2);
          });
        }
      }
    }
    return true;
  }

  setChatImage() async {
    chatMedia = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 400,
      maxWidth: 400,
    );
  }

  Future<List<Asset>> pickImages(
      List<Asset> _images,
      int _maxImages,
      bool _enableCamera,
      CupertinoOptions _cupertinoOptions,
      MaterialOptions _materialOptions,
      BuildContext context) async {
    return MultiImagePicker.pickImages(
        selectedAssets: _images,
        maxImages: _maxImages,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
        materialOptions: MaterialOptions(
            autoCloseOnSelectionLimit: true,
            startInAllView: true,
            useDetailsView: false,
            actionBarTitle: 'Select Images',
            allViewTitle: 'All Photos'));
  }

  ExtendedImage returnMemoryImage(Uint8List _src,
      {double height,
      double width,
      BoxFit fit,
      bool memCache = true,
      ExtendedImageMode mode,
      GestureConfig Function(ExtendedImageState) initGestureConfigHandler}) {
    if (_src != null) {
      return ExtendedImage.memory(
        _src,
        height: height,
        width: width,
        fit: fit,
        mode: mode,
        enableMemoryCache: memCache,
        initGestureConfigHandler: initGestureConfigHandler,
      );
    } else {
      return null;
    }
  }

  ExtendedImageGesturePageView returnBuilder(
      BuildContext _context, List<dynamic> _itemList) {
    CarouselState _carouselState =
        Provider.of<CarouselState>(_context, listen: false);

    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext _context, int _index) {
        Widget image;
        var item = _itemList[_index];
        if (item.runtimeType == String) {
          image = ExtendedImage.network(
            item,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.gesture,
            cache: true,
            enableMemoryCache: true,
            initGestureConfigHandler: (state) {
              return GestureConfig(
                  inPageView: true, initialScale: 1.0, cacheGesture: false);
            },
          );
        } else {
          if (convertedImages.containsKey(_itemList[_index].name)) {
            image = ExtendedImage.memory(
              convertedImages[_itemList[_index].name],
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              enableMemoryCache: true,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                    inPageView: true, initialScale: 1.0, cacheGesture: false);
              },
            );
          } else {
            image = ExtendedImage.memory(
              listaU8L[_index],
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
              enableMemoryCache: true,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                    inPageView: true, initialScale: 1.0, cacheGesture: false);
              },
            );
          }
        }

        image = Container(
          child: image,
        );
        if (_index == _carouselState.getDotsIndex(_itemList.length)) {
          return Hero(
            tag: _index.toString(),
            child: image,
          );
        } else {
          return image;
        }
      },
      itemCount: _itemList.length,
      onPageChanged: (int index) {
        _carouselState.setDotsIndex(index.toDouble());
      },
      controller: pageController,
      scrollDirection: Axis.horizontal,
    );
  }
}
