import 'package:Medicall/models/version.dart';
import 'package:Medicall/services/non_auth_firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';
import 'package:provider/provider.dart';
import 'package:version/version.dart';

class VersionChecker extends StatefulWidget {
  final WidgetBuilder landingPageBuilder;

  const VersionChecker({@required this.landingPageBuilder});

  @override
  _VersionCheckerState createState() => _VersionCheckerState();
}

class _VersionCheckerState extends State<VersionChecker> {
  bool isLoading = false;
  bool versionIsCurrent = false;
  bool error = false;

  @override
  void initState() {
    super.initState();
    final NonAuthDatabase db =
        Provider.of<NonAuthDatabase>(context, listen: false);
    checkVersion(db);
  }

  Future<void> checkVersion(NonAuthDatabase db) async {
    try {
      String appVersion = await GetVersion.projectVersion;

      VersionInfo version = await db.versionInfoStream();

      Version currentVersion = Version.parse(appVersion);
      Version latestVersion = Version.parse(version.iosVersionNumber);

      if (currentVersion >= latestVersion) {
        versionIsCurrent = true;
      } else {
        versionIsCurrent = true;

//        NativeUpdater.displayUpdateAlert(
//          context,
//          forceUpdate: true,
//          appStoreUrl: version.iosUrl,
//          playStoreUrl: version.androidUrl,
//          iOSDescription:
//              "Major changes have been made since the version you currently have. You will have to upgrade before continuing to use the app.",
//          iOSUpdateButtonLabel: 'Upgrade',
//          iOSCloseButtonLabel: 'Exit',
//        );
      }
    } on PlatformException {
      error = true;
    }

    if (!mounted) return;

    setState(() {
      isLoading = isLoading;
      versionIsCurrent = versionIsCurrent;
      error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      if (versionIsCurrent) {
        return widget.landingPageBuilder(context);
      }
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
