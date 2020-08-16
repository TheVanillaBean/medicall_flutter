import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmConsult extends StatelessWidget {
  static Future<void> show({
    BuildContext context,
  }) async {
    await Navigator.of(context).pushReplacementNamed(
      Routes.confirmConsult,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: CustomAppBar.getAppBar(
          type: AppBarType.Back,
          title: "Consult Confirmed",
          theme: Theme.of(context),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                'You have completed your visit:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ConfirmConsultListItem(
                      title: "Choose your visit and doctor",
                    ),
                    ConfirmConsultListItem(
                      title: "Answer a few questions",
                    ),
                    ConfirmConsultListItem(
                      title: "Payment",
                    ),
                    ConfirmConsultListItem(
                        title: "Personalized treatment plan",
                        subtitle: "*Prescriptions delivered if needed"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
                child: Text(
                  'You will now be directed to your dashboard, where you can review this visit, message your doctor, get updates, and explore other services.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Thank You for choosing Medicall!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ReusableRaisedButton(
                    title: 'Go to Dashboard',
                    onPressed: () =>
                        PatientDashboardScreen.show(context: context),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ));
  }
}

class ConfirmConsultListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  const ConfirmConsultListItem({
    @required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitle != null)
      return ListTile(
        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
        dense: true,
        title: Transform(
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline5,
          ),
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
        ),
        subtitle: Transform(
          child: Text(
            subtitle,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.caption.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
          ),
          transform: Matrix4.translationValues(-16, 0.0, 0.0),
        ),
        leading: Icon(
          Icons.check,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      );
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      dense: true,
      title: Transform(
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.headline5,
        ),
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
      ),
      leading: Icon(
        Icons.check,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
    );
  }
}
