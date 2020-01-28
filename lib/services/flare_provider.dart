import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flare_flutter/flare_actor.dart';

abstract class FlareProvider {
  SplashScreen returnFlareSplash(
      {name, next, isLoading, background, startAnimation});
  FlareActor returnFlareActor(src, {fit, snapToEnd, animation});
}

class MyFlareProvider implements FlareProvider {
  SplashScreen returnFlareSplash(
      {name, next, isLoading, background, startAnimation}) {
    return SplashScreen.navigate(
      name: name,
      next: next,
      isLoading: isLoading,
      backgroundColor: background,
      startAnimation: startAnimation,
    );
  }

  FlareActor returnFlareActor(src, {fit, snapToEnd, animation}) {
    return FlareActor(
      src,
      fit: fit,
      snapToEnd: snapToEnd,
      animation: animation,
    );
  }
}
