import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CarouselWithIndicator extends StatefulWidget {
  final List<String> imgList;
  CarouselWithIndicator({Key key, @required this.imgList}) : super(key: key);
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ExtendedImageGesturePageView.builder(
          itemBuilder: (BuildContext context, int index) {
            var item = widget.imgList[index];
            Widget image = ExtendedImage.network(
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
            image = Container(
              child: image,
            );
            if (index == _current) {
              return Hero(
                tag: item + index.toString(),
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
          controller: PageController(
            initialPage: _current,
          ),
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
