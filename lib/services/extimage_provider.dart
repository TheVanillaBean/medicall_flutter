import 'dart:typed_data';
import 'package:Medicall/models/carousel_state.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

abstract class ExtImageProvider {
  PageController pageController;
  List<Uint8List> listaU8L;
  int currentPage;
  List<Asset> assetList;
  Map convertedImages;
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
  convertImages(BuildContext context);
  clearImageMemory();
  Future<List<Asset>> pickImages(
      List<Asset> _images,
      int _maxImages,
      bool _enableCamera,
      CupertinoOptions _cupertinoOptions,
      MaterialOptions _materialOptions,
      BuildContext context);
  ExtendedImage returnNetworkImage(String url,
      {double height, double width, BoxFit fit, bool cache});
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
  int currentPage = 0;
  @override
  List<Asset> assetList = [];
  @override
  Map convertedImages = {};
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
      {double height, double width, BoxFit fit, bool cache = true}) {
    return ExtendedImage.network(_url,
        height: height, width: width, fit: fit, cache: cache);
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

  convertImages(BuildContext context) async {
    for (var i = 0; i < assetList.length; i++) {
      if (!convertedImages.containsKey(assetList[i].name)) {
        ByteData bd = await assetList[i].getThumbByteData(
            MediaQuery.of(context).size.width.toInt(),
            MediaQuery.of(context).size.height.toInt(),
            quality: 70); // width and height
        Uint8List a2 = bd.buffer.asUint8List();
        convertedImages[assetList[i].name] = a2;
        listaU8L.add(a2);
      }
    }
    assetList = [];
  }

  Future<List<Asset>> pickImages(
      List<Asset> _images,
      int _maxImages,
      bool _enableCamera,
      CupertinoOptions _cupertinoOptions,
      MaterialOptions _materialOptions,
      BuildContext context) {
    return MultiImagePicker.pickImages(
        selectedAssets: _images,
        maxImages: _maxImages,
        enableCamera: true,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: 'chat'),
        materialOptions: MaterialOptions(
            actionBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            statusBarColor:
                '#${Theme.of(context).colorScheme.primary.value.toRadixString(16).toUpperCase().substring(2)}',
            lightStatusBar: false,
            autoCloseOnSelectionLimit: true,
            startInAllView: true,
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
    return ExtendedImage.memory(
      _src,
      height: height,
      width: width,
      fit: fit,
      mode: mode,
      enableMemoryCache: memCache,
      initGestureConfigHandler: initGestureConfigHandler,
    );
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

        image = Container(
          child: image,
        );
        if (_index == _carouselState.getDotsIndex) {
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
