import 'package:Medicall/screens/Dashboard/patient_dashboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmConsult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          title: Text(
            'Consult confirmed',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    fontSize: 32.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'You have completed your visit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
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
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 20),
                  child: Text(
                    'You will now be directed to your dashboard. You will be able to review this visit, message your doctor, get updates, and explore other services.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'SourceSansPro',
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Thank You for choosing Medicall!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SourceSansPro',
                      fontSize: 18.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: RaisedButton(
                    onPressed: () =>
                        PatientDashboardScreen.show(context: context),
                    shape: StadiumBorder(),
                    color: Colors.green,
                    textColor: Colors.white,
                    child: Text('Go to Dashboard'),
                  ),
                ),
              ],
            ),
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
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'SourceSansPro',
            fontSize: 18.0,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'SourceSansPro',
            fontSize: 13.0,
            color: Colors.grey,
          ),
        ),
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 38,
        ),
      );
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      dense: true,
      title: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'SourceSansPro',
          fontSize: 18.0,
          color: Colors.grey,
        ),
      ),
      leading: Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 38,
      ),
    );
  }
}
