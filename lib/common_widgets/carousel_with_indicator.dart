import 'dart:typed_data';

import 'package:Medicall/services/extimage_provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarouselWithIndicator extends StatefulWidget {
  final List<dynamic> imgList;
  final String from;
  CarouselWithIndicator({Key key, @required this.imgList, this.from})
      : super(key: key);
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _extImageProvider = Provider.of<ExtImageProvider>(context);
    _extImageProvider.assetList = widget.imgList;
    return FutureBuilder(
        future: _extImageProvider
            .convertImages(context), // a Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return widget.from != 'buildQuestions'
                ? Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      _extImageProvider.returnBuilder(context, widget.imgList),
                      Positioned(
                        bottom: 20,
                        child: DotsIndicator(
                          dotsCount: widget.imgList.length,
                          position:
                              _extImageProvider.currentImageIndex.toDouble(),
                          decorator: DotsDecorator(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary),
                        ),
                      )
                    ],
                  )
                : _extImageProvider.listaU8L.length == 1
                    ? _extImageProvider.returnMemoryImage(
                        _extImageProvider.listaU8L[0],
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        memCache: true, initGestureConfigHandler: (state) {
                        return GestureConfig(
                            inPageView: true,
                            initialScale: 1.0,
                            cacheGesture: false);
                      })
                    : Container(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            padding: const EdgeInsets.all(0.0),
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: _extImageProvider.listaU8L
                                .map((Uint8List _uint8image) {
                              return _extImageProvider.returnMemoryImage(
                                  _uint8image,
                                  fit: BoxFit.contain,
                                  mode: ExtendedImageMode.gesture,
                                  memCache: true,
                                  initGestureConfigHandler: (state) {
                                return GestureConfig(
                                    inPageView: true,
                                    initialScale: 1.0,
                                    cacheGesture: false);
                              });
                            }).toList()),
                      );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Container();
        });
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}
