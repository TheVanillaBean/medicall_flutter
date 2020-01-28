import 'package:flutter/material.dart';

class CarouselState with ChangeNotifier {
  CarouselState();

  double _currentImageIndex = 0;

  void setDotsIndex(double index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  double getDotsIndex(int length) {
    if (_currentImageIndex > length - 1) {
      _currentImageIndex = 0.0;
    }
    return _currentImageIndex;
  }
}
