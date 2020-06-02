import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CongratsScreen extends StatelessWidget {
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
          'Congratulations!',
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
      SizedBox(
        height: height * 0.15,
      ),
      Text(
        "You have completed your visit! Please allow 24 hours for the doctor to respond.",
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
          "Go to your dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
            letterSpacing: 1.3,
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("/dashboard");
        },
      )
    ];
  }
}
