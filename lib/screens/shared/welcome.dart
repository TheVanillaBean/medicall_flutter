import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Shared/Login/login.dart';
import 'package:Medicall/screens/patient_flow/symptoms_list/symptoms.dart';
import 'package:Medicall/screens/provider_flow/registration/provider_registration.dart';
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
    return Scaffold(
        body: Stack(
      children: [
        IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Online Visit",
              body:
                  "Medicall's network of local providers can help you today. No picking up the phone. No more waiting room. Your doctor will reply with a written response within 24 hours.",
              image: Column(
                children: [
                  SizedBox(
                    width: 160,
                    height: 100,
                    child: Image.asset(
                      'assets/icon/letter_mark.png',
                    ),
                  ),
                  Image.asset("assets/images/doctors.png", height: 200.0)
                ],
              ),
              // footer: ReusableRaisedButton(
              //   title: "Login",
              //   onPressed: () => LoginScreen.show(context: context),
              //   width: 140,
              //   color: Theme.of(context).disabledColor.withAlpha(70),
              //   outlined: true,
              // ),
              decoration: PageDecoration(
                pageColor: Colors.white,
              ),
            ),
            PageViewModel(
              title: "No Insurance Required",
              body:
                  "Low cost visit fee. No insurance headaches. Just transparent pricing.",
              image: Center(
                  child: Image.asset("assets/images/insurance.png",
                      height: 250.0)),
              decoration: PageDecoration(
                pageColor: Colors.white,
              ),
            ),
            PageViewModel(
              title: "Free 2-day Shipping",
              body:
                  "If you need a prescription, we offer them at wholesale price and ship them to your door for free.",
              image: Center(
                  child:
                      Image.asset("assets/images/shipping.png", height: 250.0)),
              decoration: PageDecoration(
                pageColor: Colors.white,
              ),
            ),
          ],
          onDone: () => SymptomsScreen.show(context: context),
          next: Icon(Icons.navigate_next),
          done: Text("Let's Get Started!",
              style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: DotsDecorator(
              size: Size.square(10.0),
              activeSize: Size(20.0, 10.0),
              activeColor: Theme.of(context).colorScheme.primary,
              color: Colors.black26,
              spacing: EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
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
    ));
  }

  List<Widget> buildChildren(BuildContext context) {
    return <Widget>[
      Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 140,
              child: Image.asset(
                'assets/icon/letter_mark.png',
              ),
            ),
            Text(
              'Leading Local Providers',
              style: TextStyle(
                  fontSize: 18, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
      buildStepsList(context),
      buildGetStartedBtn(context),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ReusableRaisedButton(
            title: "Login",
            onPressed: () => LoginScreen.show(context: context),
            width: 140,
            color: Theme.of(context).disabledColor.withAlpha(70),
            outlined: true,
          ),
          ReusableRaisedButton(
            title: "For Providers",
            onPressed: () => ProviderRegistrationScreen.show(context: context),
            width: 140,
            color: Theme.of(context).disabledColor.withAlpha(70),
            outlined: true,
          ),
        ],
      )
    ];
  }

  Widget buildGetStartedBtn(BuildContext context) {
    return ReusableRaisedButton(
      title: "Let\'s get started! \n It\'s free to explore",
      height: 80,
      onPressed: () => SymptomsScreen.show(context: context),
    );
  }

  Widget buildStepsList(context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(50, 0, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text("1",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                Text(
                  'Choose your visit and provider',
                  style: TextStyle(
                      fontSize: 18, color: Colors.black.withAlpha(140)),
                )
              ],
            ),
          ),
          // RotationTransition(
          //   turns: AlwaysStoppedAnimation(90 / 360),
          //   child: Text(
          //     "--->",
          //     style: TextStyle(fontSize: 21, color: Colors.black26),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text("2",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                Text(
                  'Answer a few questions',
                  style: TextStyle(
                      fontSize: 18, color: Colors.black.withAlpha(140)),
                )
              ],
            ),
          ),
          // RotationTransition(
          //   turns: AlwaysStoppedAnimation(90 / 360),
          //   child: Text(
          //     "--->",
          //     style: TextStyle(fontSize: 21, color: Colors.black26),
          //   ),
          // ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text("3",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                Text(
                  'Make a payment',
                  style: TextStyle(
                      fontSize: 18, color: Colors.black.withAlpha(140)),
                )
              ],
            ),
          ),
          // RotationTransition(
          //   turns: AlwaysStoppedAnimation(90 / 360),
          //   child: Text(
          //     "--->",
          //     style: TextStyle(fontSize: 21, color: Colors.black26),
          //   ),
          // ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text("4",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                Text(
                  'Personalized treatment plan',
                  style: TextStyle(
                      fontSize: 18, color: Colors.black.withAlpha(140)),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
              child: Text(
                '*Prescriptions delivered if needed',
                style:
                    TextStyle(fontSize: 12, color: Colors.black.withAlpha(140)),
              )),
        ],
      ),
    );
  }
}
