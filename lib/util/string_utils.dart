import 'package:flutter/foundation.dart';

class StringUtils {
  static String getFormattedProviderName({
    @required String firstName,
    @required String lastName,
    @required String professionalTitle,
  }) {
    return '${capitalize(firstName)} ${capitalize(lastName)}, $professionalTitle';
  }

  static String capitalize(String s) {
    return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }

  static final emailRegex =
      '^([\\w\\d\\-\\+]+)(\\.+[\\w\\d\\-\\+%]+)*@([\\w\\-]+\\.){1,5}(([A-Za-z]){2,30}|xn--[A-Za-z0-9]{1,26})\$';

  ///
  /// Checks whether the given string [s] is a email address
  ///
  static bool isEmail(String s) {
    var regExp = RegExp(emailRegex);
    return regExp.hasMatch(s);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
