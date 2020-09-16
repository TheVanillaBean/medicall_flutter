import 'dart:async';

import 'package:Medicall/services/database.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  Future<void> deleteCard(String pmID) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'deletePaymentMethod',
    )..timeout = const Duration(seconds: 30);

    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'pmID': pmID,
      },
    );

    updateWith(isLoading: true, refreshCards: true);
  }

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
