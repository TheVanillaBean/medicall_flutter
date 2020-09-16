import 'package:flutter/foundation.dart';

class VersionInfo {
  final String androidUrl;
  final String iosUrl;
  final String iosVersionNumber;
  final String androidVersionNumber;

  VersionInfo({
    @required this.androidUrl,
    @required this.iosUrl,
    @required this.iosVersionNumber,
    @required this.androidVersionNumber,
  });

  factory VersionInfo.fromMap({Map<String, dynamic> data, String documentId}) {
    if (data == null) {
      return null;
    }
    final String androidUrl = data['android_url'];
    final String iosUrl = data['ios_url'];
    final String iosVersionNumber = data['ios_version_number'];
    final String androidVersionNumber = data['android_version_number'];

    return VersionInfo(
      androidUrl: androidUrl,
      iosUrl: iosUrl,
      iosVersionNumber: iosVersionNumber,
      androidVersionNumber: androidVersionNumber,
    );
  }
}
