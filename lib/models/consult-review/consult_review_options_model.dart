import 'package:flutter/foundation.dart';

class ConsultReviewOptions {
  Map<String, List<String>> ddxOptions;
  List<String> diagnosisList;

  ConsultReviewOptions(
      {@required this.ddxOptions, @required this.diagnosisList});

  factory ConsultReviewOptions.fromMap(
      Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }

    final List<String> diagnosisList = (data['diagnosis-options'] as List)
        .map((item) => item.toString())
        .toList();
    final Map<String, List<String>> ddxOptions =
        (data['ddx-options'] as Map).map((key, value) {
      List<String> diagnosisList =
          (value as List).map((d) => d.toString()).toList();
      return MapEntry(
        key,
        diagnosisList,
      );
    });

    return ConsultReviewOptions(
      diagnosisList: diagnosisList,
      ddxOptions: ddxOptions,
    );
  }
}
