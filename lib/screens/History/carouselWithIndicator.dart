import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CarouselWithIndicator extends StatefulWidget {
  final List<dynamic> imgList;
  CarouselWithIndicator({Key key, @required this.imgList}) : super(key: key);
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;
  PageController _pageController;

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

  @override
  Widget build(BuildContext context) {
    return widget.imgList.length > 0
        ? Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ExtendedImageGesturePageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  Widget image;
                  var item = widget.imgList[index];
                  if (item.runtimeType == String) {
                    image = ExtendedImage.network(
                      item,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.gesture,
                      cache: true,
                      enableMemoryCache: true,
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                            inPageView: true,
                            initialScale: 1.0,
                            cacheGesture: false);
                      },
                    );
                  } else {
                    image = ExtendedImage.memory(
                      item,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.gesture,
                      enableMemoryCache: true,
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                            inPageView: true,
                            initialScale: 1.0,
                            cacheGesture: false);
                      },
                    );
                  }

                  image = Container(
                    child: image,
                  );
                  if (index == _current) {
                    return Hero(
                      tag: index.toString(),
                      child: image,
                    );
                  } else {
                    return image;
                  }
                },
                itemCount: widget.imgList.length,
                onPageChanged: (int index) {
                  setState(() {
                    _current = index;
                  });
                  //rebuild.add(index);
                },
                controller: _pageController,
                scrollDirection: Axis.horizontal,
              ),
              Positioned(
                bottom: 20,
                child: DotsIndicator(
                  dotsCount: widget.imgList.length,
                  position: _current.toDouble(),
                  decorator: DotsDecorator(
                      activeColor: Theme.of(context).colorScheme.secondary),
                ),
              )
            ],
          )
        : Center(
            child: Container(
              
              child: Text('There are no images here.'),
            ),
          );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}
