import 'package:Medicall/common_widgets/custom_app_bar.dart';
import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/common_widgets/reusable_raised_button.dart';
import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    //UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.getAppBar(
        type: AppBarType.Back,
        title: "Personal Information",
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
      Text(
        "Does everything look correct?",
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Text(
        "*This is where the user will be able to review the OCR and add photo upload.",
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Align(
        alignment: FractionalOffset.bottomCenter,
        child: ReusableRaisedButton(
          title: 'Looks Good!',
          onPressed: () {
            Navigator.of(context).pushNamed("/consultReview");
          },
        ),
      )
    ];
  }
}
