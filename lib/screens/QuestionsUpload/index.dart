import 'package:flutter/material.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;

class QuestionsUploadScreen extends StatefulWidget {
  @override
  _QuestionsUploadScreenState createState() => _QuestionsUploadScreenState();
}

class _QuestionsUploadScreenState extends State<QuestionsUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(35, 179, 232, 1),
          title: new Text(
            'Select or Take Pictures',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: new FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Color.fromRGBO(35, 179, 232, 1),
          onPressed: () => Navigator.pushNamed(context, '/history'), // Switch tabs

          child: Text(
            'CONTINUE',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a pictures'),
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Select from Album'),
            ),
            
          ],
        ),
      );
  }
}
