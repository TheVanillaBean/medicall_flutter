import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/Login/login.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms.dart';
import 'package:Medicall/util/introduction_screen/introduction_screen.dart';
import 'package:Medicall/util/introduction_screen/model/page_decoration.dart';
import 'package:Medicall/util/introduction_screen/model/page_view_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeScreen extends StatelessWidget {
  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushReplacementNamed(Routes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    double logoHeight = ScreenUtil.screenHeight * .05;
    double pictureHeight = ScreenUtil.screenHeight * .15;
    return Scaffold(
      body: Stack(
        children: [
          IntroductionScreen(
            pages: [
              PageViewModel(
                title: "Online Visit",
                body:
                    "Medicall's network of local providers can help you today. No more waiting rooms. Just fill out a few questions and your doctor will reply with a written response within 24 hours.",
                image: Column(
                  children: [
                    SizedBox(
                      width: 160,
                      height: 100,
                      child: Image.asset(
                        'assets/icon/letter_mark.png',
                      ),
                    ),
                    Image.asset("assets/images/doctors.png", height: 200)
                  ],
                ),
                decoration: PageDecoration(
                  pageColor: Colors.white,
                ),
              ),
              PageViewModel(
                title: "No Insurance Required",
                body:
                    "Low cost visit fee. No insurance headaches. Just transparent pricing.",
                image: Center(
                  child:
                      Image.asset("assets/images/insurance.png", height: 250),
                ),
                decoration: PageDecoration(
                  pageColor: Colors.white,
                ),
              ),
              PageViewModel(
                title: "Free 2-day Shipping",
                body:
                    "If you need a prescription, we offer them at wholesale prices and ship them to your door for free.",
                image: Center(
                  child: Image.asset("assets/images/shipping.png", height: 250),
                ),
                decoration: PageDecoration(
                  pageColor: Colors.white,
                ),
              ),
            ],
            onDone: () => SymptomsScreen.show(context: context),
            next: Icon(Icons.navigate_next),
            done: Text(
              "Let's Get Started!",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            dotsDecorator: DotsDecorator(
              size: Size.square(10.0),
              activeSize: Size(20.0, 10.0),
              activeColor: Theme.of(context).colorScheme.primary,
              color: Colors.black26,
              spacing: EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 10,
            child: FlatButton(
              child: Text("Login"),
              onPressed: () => LoginScreen.show(context: context),
            ),
          ),
        ],
      ),
    );
  }
}
