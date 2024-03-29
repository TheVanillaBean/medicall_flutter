import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/Login/login.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static Future<void> show({BuildContext context}) async {
    await Navigator.of(context).pushReplacementNamed(Routes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 35),
            child: IntroductionScreen(
              pages: [
                PageViewModel(
                  title: "Online Visit",
                  body:
                      "Medicall's network of local providers can help you today. No more waiting rooms. Just fill out a few questions and your doctor will reply with a written response within 24 hours.",
                  image: Column(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 80,
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
                  title: "Use Your Insurance",
                  body:
                      "Use your insurance coverage to get your visit covered! No insurance? No problem! Get a visit for a low price today.",
                  image: Center(
                    child:
                        Image.asset("assets/images/insurance.png", height: 250),
                  ),
                  decoration: PageDecoration(
                    pageColor: Colors.white,
                  ),
                ),
                PageViewModel(
                  title: "Send Your Prescription Anywhere",
                  body:
                      "If you need a prescription, we can send it the pharmacy of your choice. That includes a pharmacy down the street or a mail order pharmacy that will deliver to your door.",
                  image: Center(
                    child:
                        Image.asset("assets/images/shipping.png", height: 250),
                  ),
                  decoration: PageDecoration(
                    pageColor: Colors.white,
                  ),
                ),
              ],
              onDone: () => SymptomsScreen.show(context: context),
              next: Icon(Icons.navigate_next),
              done: Text(
                "Let's Go!",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              showSkipButton: true,
              onSkip: () => LoginScreen.show(context: context),
              skip: Text(
                "Login",
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FlatButton(
              child: Text("Register as a healthcare provider"),
              onPressed: () =>
                  ProviderRegistrationScreen.show(context: context),
            ),
          ),
        ],
      ),
    );
  }
}
