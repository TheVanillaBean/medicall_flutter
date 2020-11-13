import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.aboutUs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "About",
        theme: Theme.of(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Medicall is a Boston-based leading online telemedicine platform that connects patients with leading "
                "local doctors. Get the convenience of an online visit with the comfort of knowing the you can "
                "see your doctor if needed. It was founded in 2019 by a group of Harvard doctors and MIT engineers.",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
