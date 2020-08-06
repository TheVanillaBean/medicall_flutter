import 'package:Medicall/models/consult_model.dart';
import 'package:flutter/foundation.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

// Properties
abstract class ConsultPhotosProperties {
  static String get photoDots => 'dots_indicator';
  static String get photoRoot => 'root';
}

class ConsultPhotosViewModel extends PropertyChangeNotifier {
  double imageIndex = 0;
  double imagesCount = 0;

  final Consult consult;

  ConsultPhotosViewModel({@required this.consult});

  void updateDotsIndicator({double imagesCount, double index}) {
    this.imageIndex = index ?? this.imageIndex;
    this.imagesCount = imagesCount ?? this.imagesCount;
    notifyListeners(ConsultPhotosProperties.photoDots);
  }
}
