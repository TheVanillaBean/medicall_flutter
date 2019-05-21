import 'package:flutter/material.dart';
import './InputFields.dart';

class FormContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Form(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              InputFieldArea(
                hint: 'Username',
                obscure: false,
                icon: Icons.person_outline,
              ),
              InputFieldArea(
                hint: 'Password',
                obscure: true,
                icon: Icons.lock_outline,
              ),
            ],
          )),
        ],
      ),
    ));
  }
}
