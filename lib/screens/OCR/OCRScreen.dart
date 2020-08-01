import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:flutter/material.dart';

class OCRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    //UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Almost Done!",
        theme: Theme.of(context),
      ),
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(width * .1),
            child: Column(
              children: _buildChildren(context: context, height: height),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren({BuildContext context, double height}) {
    return [
      SizedBox(
        height: height * 0.15,
      ),
      Text(
        "Take photo of your ID for OCR. \n *Not implemented as this is just for flow proof of concept.",
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      ReusableRaisedButton(
        title: 'Continue',
        onPressed: () {
          Navigator.of(context).pushNamed("/personalInfo");
        },
      )
    ];
  }
}
