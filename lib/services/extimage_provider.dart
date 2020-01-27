import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

abstract class ExtImageProvider {
  PageController pageController;
  List<Uint8List> listaU8L;
  int currentImageIndex;
  ExtendedImage returnNetworkImage(String url,
      {double height, double width, BoxFit fit, bool cache});
  ExtendedImage returnMemoryImage(Uint8List src,
      {double height,
      double width,
      BoxFit fit,
      bool memCache,
      ExtendedImageMode mode,
      GestureConfig Function(ExtendedImageState) initGestureConfigHandler});
  ExtendedImageGesturePageView returnBuilder(
      BuildContext context, List<dynamic> itemList);
}

class ExtendedImageProvider implements ExtImageProvider {
  @override
  List<Uint8List> listaU8L = [];
  @override
  PageController pageController = PageController();
  @override
  int currentImageIndex = 0;

  @override
  ExtendedImage returnNetworkImage(String _url,
      {double height, double width, BoxFit fit, bool cache}) {
    return ExtendedImage.network(_url,
        height: height, width: width, fit: fit, cache: cache);
  }

  ExtendedImage returnMemoryImage(Uint8List _src,
      {double height,
      double width,
      BoxFit fit,
      bool memCache,
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
        if (_index == currentImageIndex) {
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
        // setState(() {
        //   _current = index;
        // });
        //rebuild.add(index);
      },
      controller: pageController,
      scrollDirection: Axis.horizontal,
    );
  }
}
