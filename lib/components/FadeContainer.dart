import 'package:flutter/material.dart';

class FadeBox extends StatelessWidget {
  final Animation<double> containerGrowAnimation;
  final Animation<Color> fadeScreenAnimation;
  FadeBox({this.containerGrowAnimation, this.fadeScreenAnimation});
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return (Hero(
        tag: 'fade',
        child: Container(
          width: containerGrowAnimation.value < 1 ? screenSize.width : 0.0,
          height: containerGrowAnimation.value < 1 ? screenSize.height : 0.0,
          decoration: BoxDecoration(
            color: fadeScreenAnimation.value,
          ),
        )));
  }
}
