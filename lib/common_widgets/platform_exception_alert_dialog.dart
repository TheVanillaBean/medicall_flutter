import 'package:Medicall/common_widgets/platform_alert_dialog.dart';
import 'package:Medicall/util/firebase_auth_codes.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  final String title;
  final PlatformException exception;

  PlatformExceptionAlertDialog({
    @required this.title,
    @required this.exception,
  }) : super(
          title: title,
          content: _message(exception),
          defaultActionText: 'OK',
        );

  static String _message(PlatformException exception) {
    return FirebaseAuthCodes.errors[exception.code] ?? exception.message;
  }
}
