import 'package:Medicall/screens/Login/index.dart';
import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage.create(context)),
                  );
                },
                icon: Icon(Icons.arrow_back),
              );
            },
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  'assets/icon/logo_fore.png',
                ),
              ),
              Text(
                'Leading Local Dematologists. Anytime.',
                style: TextStyle(fontSize: 18),
              ),
              Container(
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
              ),
              SizedBox(height: 80),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/symptoms');
                },
                padding: EdgeInsets.fromLTRB(35, 15, 35, 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0)),
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
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Already have an account?'),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage.create(context)),
                        );
                      },
                      child: Text(
                        'Click here',
                        style: TextStyle(decoration: TextDecoration.underline),
                      )),
                ],
              )
            ],
          ),
        ));
  }
}
