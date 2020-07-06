import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Login/login.dart';
import 'package:Medicall/screens/Registration/Provider/provider_registration.dart';
import 'package:Medicall/screens/Symptoms/symptoms.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushReplacementNamed(Routes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(""),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: buildChildren(context),
          ),
        ),
      ),
    );
  }

  List<Widget> buildChildren(BuildContext context) {
    return <Widget>[
      SizedBox(
        width: 120,
        height: 120,
        child: Image.asset(
          'assets/icon/logo_fore.png',
        ),
      ),
      Text(
        'Leading Local Dermatologists. Anytime.',
        style: TextStyle(fontSize: 18),
      ),
      buildStepsList(),
      SizedBox(height: 30),
      buildGetStartedBtn(context),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Already have an account?'),
          GestureDetector(
              onTap: () {
                LoginScreen.show(context: context);
              },
              child: Text(
                'Click here',
                style: TextStyle(decoration: TextDecoration.underline),
              )),
        ],
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                ProviderRegistrationScreen.show(context: context);
                //Navigator.of(context).pushNamed('/provider-registration');
              },
              child: Text(
                'Register',
                style: TextStyle(decoration: TextDecoration.underline),
              )),
          Text(' as a provider'),
          SizedBox(height: 10),
        ],
      ),
    ];
  }

  Widget buildGetStartedBtn(BuildContext context) {
    return FlatButton(
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        SymptomsScreen.show(context: context);
      },
      padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
      child: Column(
        children: <Widget>[
          Text(
            'Let\'s get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            '(it\'s free to explore)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStepsList() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(50, 80, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                'Choose your visit and doctor',
                style: TextStyle(fontSize: 16),
              )),
          Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                'Answer a few questions',
                style: TextStyle(fontSize: 16),
              )),
          Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                'Payment',
                style: TextStyle(fontSize: 16),
              )),
          Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                'Personalized treatment plan',
                style: TextStyle(fontSize: 16),
              )),
          Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                '*Prescriptions delivered if needed',
                style: TextStyle(fontSize: 12),
              )),
        ],
      ),
    );
  }
}
