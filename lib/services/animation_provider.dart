import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

abstract class AnimationProvider {
  ControlledAnimation returnAnimation({tween});
  MultiTrackTween returnMultiTrackTween(List<Color> _colors);
}

class MyAnimationProvider implements AnimationProvider {
  MultiTrackTween returnMultiTrackTween(List<Color> _colors) {
    return MultiTrackTween([
      Track("color1").add(
          Duration(seconds: 3), ColorTween(begin: _colors[0], end: _colors[1])),
      Track("color2").add(
          Duration(seconds: 3), ColorTween(begin: _colors[2], end: _colors[3]))
    ]);
  }

  ControlledAnimation returnAnimation({tween}) {
    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [animation["color1"], animation["color2"]])),
        );
      },
    );
  }
}
