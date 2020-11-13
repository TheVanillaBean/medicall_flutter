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
                "Medicall connects you with local board-certified doctors 24/7/365 through the convenience of your mobile device. You can avoid the hassle, wait and cost of an in-person visit.\n\n" +
                    "Doctors on Medicall can diagnose, recommend treatment and prescribe medications, if medically necessary, for many dermatology issues, including:\n" +
                    "- Concerning spots\n- Rashes\n- Hair loss\n- Acne\n- Rosacea\n- Psoriasis\n- Cosmetic concerns\n- Nail changes\n- Cold sores\nand more...\n\n" +
                    "HOW DOES IT WORK?\nRequest a visit - Open the Medicall App, select the reason you are selecting medical care for, select a provider in your area, provide medical history, and pay for the visit.\n\n" +
                    "Obtain a medical consultation - Your doctor will review the information you provide, reply in less than 24 hours and provide a medical opinion. Your doctor will discuss their findings, answer any questions you might have and recommend next steps.\n\n" +
                    "Get the prescription you need - If medically necessary, we can have the prescription delivered to your door with free 2 day shipping. We negotiate special prices with our mail order pharmacy partner to ensure you get the lowest prices available in the nation.\n\n" +
                    "HOW MUCH DOES A VISIT COST?\nVisits start from \$39 depending on the service request. This is less than most insurance co-pays.\n\n" +
                    "WHAT ABOUT PRESCRIPTIONS?\nVisits do not include the cost of prescriptions. Through our pharmacy partners, we offer free 2-day shipping on prescriptions.\n\n" +
                    "WHO ARE THE DOCTORS?\nThe doctors on our platform are leading board-certified doctors in your area. We allow you to select the doctor of your choice before proceeding with your visit.\n\n" +
                    "WHERE IS MEDICALL AVAILABLE?\nMedicall is currently available in the following states: California, Colorado, Connecticut, Florida, Georgia, Illinois, Kentucky, Maine, Massachusetts, Michigan, Missouri, Montana, Nebraska, Nevada, New York, North Carolina, Ohio, Pennsylvania, South Carolina, Tennessee, Texas, Washington (state), Wisconsin, Wyoming.\n\n",
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
