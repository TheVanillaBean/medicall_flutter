import 'package:flutter/foundation.dart';

class StringUtils {
  static String getFormattedProviderName({
    @required String firstName,
    @required String lastName,
    @required String titles,
  }) {
    return '${capitalize(firstName)} ${capitalize(lastName)} $titles';
  }

  static String capitalize(String s) {
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }
}
