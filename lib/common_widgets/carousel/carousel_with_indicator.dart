import 'package:Medicall/common_widgets/carousel/carousel_state.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarouselWithIndicator extends StatelessWidget {
  final List imgList;
  final String from;
  final PageController pageCntrl;
  const CarouselWithIndicator(
      {Key key, this.imgList, this.from, this.pageCntrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _extImageProvider = Provider.of<ExtImageProvider>(context);
    CarouselState _carouselState = Provider.of<CarouselState>(context);
    if (imgList != null && imgList.length > 0) {
      if (imgList[0].runtimeType == String) {
        return FadeInPlace(
          2.0,
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _extImageProvider.returnBuilder(context, imgList),
              Positioned(
                bottom: 20,
                child: DotsIndicator(
                  dotsCount: imgList.length,
                  position: _carouselState.getDotsIndex(imgList.length),
                  decorator: DotsDecorator(
                      activeColor: Theme.of(context).colorScheme.secondary),
                ),
              )
            ],
          ),
        );
      }
      return from != 'buildQuestions'
          ? FadeInPlace(
              1.0,
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _extImageProvider.returnBuilder(context, imgList),
                  Positioned(
                    bottom: 20,
                    child: DotsIndicator(
                      dotsCount: imgList.length,
                      position: _carouselState.getDotsIndex(imgList.length),
                      decorator: DotsDecorator(
                          activeColor: Theme.of(context).colorScheme.secondary),
                    ),
                  )
                ],
              ),
            )
          : imgList.length == 1
              ? _extImageProvider.returnMemoryImage(
                  _extImageProvider.convertedImages[imgList[0].name],
                  fit: BoxFit.cover,
                  mode: ExtendedImageMode.gesture,
                  memCache: true, initGestureConfigHandler: (state) {
                  return GestureConfig(
                      inPageView: true, initialScale: 1.0, cacheGesture: false);
                })
              : _extImageProvider.convertedImages.length > 0
                  ? FadeInPlace(
                      1.0,
                      Container(
                        child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.88,
                            padding: const EdgeInsets.all(0.0),
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: imgList.map((asset) {
                              if (_extImageProvider.convertedImages
                                  .containsKey(asset.name)) {
                                return _extImageProvider.returnMemoryImage(
                                    _extImageProvider
                                        .convertedImages[asset.name],
                                    fit: BoxFit.cover,
                                    mode: ExtendedImageMode.gesture,
                                    memCache: true,
                                    initGestureConfigHandler: (state) {
                                  return GestureConfig(
                                      inPageView: true,
                                      initialScale: 1.0,
                                      cacheGesture: false);
                                });
                              } else {
                                return CircularProgressIndicator();
                              }
                            }).toList()),
                      ),
                    )
                  : Container();
    } else {
      return Center(
        child: Text('No images to display.'),
      );
    }
  }
}
