import 'package:flutter/cupertino.dart';

class MakePaymentViewModel with ChangeNotifier {
  bool isLoading;

  MakePaymentViewModel({
    this.isLoading = false,
  });

  void updateWith({
    bool isLoading,
  }) {
    this.isLoading = isLoading ?? this.isLoading;
    notifyListeners();
  }
}
