import 'dart:async';

import 'package:Medicall/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';

class PaymentDetailViewModel with ChangeNotifier {
  String uid;
  FirestoreDatabase database;

  bool isLoading;
  bool refreshCards;

  // ignore: close_sinks
  StreamController<List<PaymentMethod>> paymentMethodsStream =
      StreamController();

  PaymentDetailViewModel({
    @required this.uid,
    @required this.database,
    this.isLoading = false,
    this.refreshCards = true,
  });

  void refreshCardsStream() async {
    paymentMethodsStream.add(await database.getUserCardSources(uid));
    updateWith(isLoading: false, refreshCards: false);
  }

  void updateWith({bool isLoading, bool refreshCards}) {
    this.isLoading = isLoading ?? this.isLoading;
    this.refreshCards = refreshCards ?? this.refreshCards;
    notifyListeners();
  }
}
