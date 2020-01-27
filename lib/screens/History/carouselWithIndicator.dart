import 'dart:typed_data';

import 'package:Medicall/services/extimage_provider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
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
  int _current = 0;
  PageController _pageController;
  List<Uint8List> _listaU8L;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _current,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  convertImages() async {
    List<Asset> assetList = [];
    _listaU8L = [];
    for (var i = 0; i < widget.imgList.length; i++) {
      assetList.add(widget.imgList[i]);
    }
    for (var i = 0; i < assetList.length; i++) {
      ByteData bd = await assetList[i]
          .getThumbByteData(400, 800, quality: 70); // width and height
      Uint8List a2 = bd.buffer.asUint8List();
      if (!_listaU8L.contains(a2)) {
        _listaU8L.add(a2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var _extImageProvider = Provider.of<ExtImageProvider>(context);
    return FutureBuilder(
        future: convertImages(), // a Future<String> or null
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
                          position: _current.toDouble(),
                          decorator: DotsDecorator(
                              activeColor:
                                  Theme.of(context).colorScheme.secondary),
                        ),
                      )
                    ],
                  )
                : _extImageProvider.returnMemoryImage(_listaU8L[0],
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    memCache: true, initGestureConfigHandler: (state) {
                    return GestureConfig(
                        inPageView: true,
                        initialScale: 1.0,
                        cacheGesture: false);
                  });
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
