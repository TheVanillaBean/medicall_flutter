import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.contactUs,
    );
  }

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open URL';
    }
  }

  void _launchCaller(int number) async {
    var url = 'tel:${number.toString()}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not place Call';
    }
  }

  void _launchEmail(String emailId) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'omar@medicall.com',
      query: 'subject=Medicall App Feedback', //add subject and body here
    );

    var url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not send E-mail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Contact Us",
        theme: Theme.of(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                '(480)861-0816',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                _launchCaller(4808610816);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'omar@medicall.com',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                _launchEmail('omar@medicall.com');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'www.medicall.com',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                _launchUrl('https://medicall.com');
              },
            ),
          ],
        ),
      ),
    );
  }
}
