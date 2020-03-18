import 'dart:math' as math;
import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AppUtil {
  static final AppUtil _instance = AppUtil.internal();
  static bool networkStatus;

  AppUtil.internal();

  factory AppUtil() {
    return _instance;
  }

  bool isNetworkWorking() {
    return networkStatus;
  }

  Flushbar showFlushBar(e, context) {
    String exMsg;
    if (e.runtimeType == String) {
      exMsg = e;
      if (exMsg == 'Given String is empty or null') {
        exMsg =
            "You did not provide a valid username and password, please try again.";
      }
      return Flushbar(
        message: exMsg,
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.GROUNDED,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        duration: Duration(seconds: 5),
      )..show(context);
    } else {
      exMsg = e.message;
      return Flushbar(
        message: exMsg,
        flushbarPosition: FlushbarPosition.TOP,
        flushbarStyle: FlushbarStyle.FLOATING,
        borderRadius: 8,
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        overlayColor: Colors.black.withAlpha(100),
        margin: EdgeInsets.all(5),
        overlayBlur: 2.0,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  double initScale({Size imageSize, Size size, double initialScale}) {
    var n1 = imageSize.height / imageSize.width;
    var n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes =
          applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
  }
}

class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeIn(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(
          Duration(milliseconds: 500), Tween(begin: 130.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}

class FadeInPlace extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeInPlace(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: child,
      ),
    );
  }
}

class FadeOut extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeOut(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 1.0, end: 0.0)),
      Track("translateX").add(
          Duration(milliseconds: 500), Tween(begin: 0.0, end: -130.0),
          curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (300 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}

class ArrowPath {
  /// Add an arrow to the end of the last drawn curve in the given path.
  ///
  /// The returned path is moved to the end of the curve. Always add the arrow before moving the path, not after, else the move will be lost.
  /// After adding the arrow you can move the path, draw more and apply an arrow to the new drawn part.
  ///
  /// If [isDoubleSided] is true (default to false), an arrow will also be added to the beginning of the first drawn curve.
  ///
  /// [tipLength] is the length (in pixels) of each of the 2 lines making the arrow.
  ///
  /// [tipAngle] is the angle (in radians) between each of the 2 lines making the arrow and the curve at this point.
  ///
  /// If [isAdjusted] is true (default to true), the tip of the arrow will be rotated (not following the tangent perfectly).
  /// This improves the look of the arrow when the end of the curve as a strong curvature.
  /// Can be disabled to save performance when the arrow is flat.
  static Path make({
    @required Path path,
    double tipLength = 15,
    double tipAngle = math.pi * 0.2,
    bool isDoubleSided = false,
    bool isAdjusted = true,
  }) =>
      _make(path, tipLength, tipAngle, isDoubleSided, isAdjusted);

  static Path _make(Path path, double tipLength, double tipAngle,
      bool isDoubleSided, bool isAdjusted) {
    PathMetric lastPathMetric;
    PathMetric firstPathMetric;
    Offset tipVector;
    Tangent tan;
    double adjustmentAngle = 0;

    double angle = math.pi - tipAngle;
    lastPathMetric = path.computeMetrics().last;
    if (isDoubleSided) {
      firstPathMetric = path.computeMetrics().first;
    }

    tan = lastPathMetric.getTangentForOffset(lastPathMetric.length);

    final Offset originalPosition = tan.position;

    if (isAdjusted && lastPathMetric.length > 10) {
      Tangent tanBefore =
          lastPathMetric.getTangentForOffset(lastPathMetric.length - 5);
      adjustmentAngle = _getAngleBetweenVectors(tan.vector, tanBefore.vector);
    }

    tipVector = _rotateVector(tan.vector, angle - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    tipVector = _rotateVector(tan.vector, -angle - adjustmentAngle) * tipLength;
    path.moveTo(tan.position.dx, tan.position.dy);
    path.relativeLineTo(tipVector.dx, tipVector.dy);

    if (isDoubleSided) {
      tan = firstPathMetric.getTangentForOffset(0);
      if (isAdjusted && firstPathMetric.length > 10) {
        Tangent tanBefore = firstPathMetric.getTangentForOffset(5);
        adjustmentAngle = _getAngleBetweenVectors(tan.vector, tanBefore.vector);
      }

      tipVector =
          _rotateVector(-tan.vector, angle - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);

      tipVector =
          _rotateVector(-tan.vector, -angle - adjustmentAngle) * tipLength;
      path.moveTo(tan.position.dx, tan.position.dy);
      path.relativeLineTo(tipVector.dx, tipVector.dy);
    }

    path.moveTo(originalPosition.dx, originalPosition.dy);

    return path;
  }

  static Offset _rotateVector(Offset vector, double angle) => Offset(
        math.cos(angle) * vector.dx - math.sin(angle) * vector.dy,
        math.sin(angle) * vector.dx + math.cos(angle) * vector.dy,
      );

  static double _getVectorsDotProduct(Offset vector1, Offset vector2) =>
      vector1.dx * vector2.dx + vector1.dy * vector2.dy;

  // Clamp to avoid rounding issues when the 2 vectors are equal.
  static double _getAngleBetweenVectors(Offset vector1, Offset vector2) =>
      math.acos((_getVectorsDotProduct(vector1, vector2) /
              (vector1.distance * vector2.distance))
          .clamp(-1.0, 1.0));
}
