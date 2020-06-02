import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Personal Information',
        ),
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
      CustomRaisedButton(
        height: 50,
        color: Colors.blue,
        child: Text(
          "Looks Good!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            letterSpacing: 1.3,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("/consultReview");
        },
      )
    ];
  }
}
