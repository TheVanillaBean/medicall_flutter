import 'package:flutter/material.dart';

class CarouselState with ChangeNotifier {
  CarouselState();

  double _currentImageIndex = 0;

  void setDotsIndex(double index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  double get getDotsIndex => _currentImageIndex;
}
