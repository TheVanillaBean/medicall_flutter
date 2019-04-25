import 'package:flutter/material.dart';

class ConfirmConsultScreen extends StatelessWidget {
  const ConfirmConsultScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Consult Review',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () {
          Navigator.pushNamed(context, 'history');
        },
        //Navigator.pushNamed(context, '/history'), // Switch tabs

        child: Text(
          'REVIEW',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Text('data')
    );
  }
}