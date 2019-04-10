import 'package:flutter/material.dart';
import 'package:medicall/components/DrawerMenu.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:medicall/screens/QuestionsScreening/index.dart';

class DoctorsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Scaffold(
        //App Bar
        appBar: new AppBar(
          leading: new BackButton(),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(35, 179, 232, 1),
          title: new Text(
            'Find a Doctor',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        drawer: new DrawerMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(builder: (BuildContext context) {
          return new FloatingActionButton(
            child: new Icon(
              CustomIcons.MedicallApp.logo_m,
              size: 35.0,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            backgroundColor: Color.fromRGBO(241, 100, 119, 1),
            foregroundColor: Colors.white,
          );
        }),
        //Content of tabs
        body: new Stack(
          children: <Widget>[
            new OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return Container(
                  child: GridView.count(
                    crossAxisCount: orientation == Orientation.portrait ? 3 : 6,
                    childAspectRatio: 1.0,
                    padding: orientation == Orientation.portrait
                        ? EdgeInsets.fromLTRB(10, 60, 10, 10)
                        : EdgeInsets.fromLTRB(10, 30, 10, 10),
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    // Generate 100 Widgets that display their index in the List
                    children: [
                      RaisedButton(
                        child: Text(
                          'Acne',
                          textScaleFactor:
                              orientation == Orientation.portrait ? 1 : 0.8,
                          semanticsLabel: 'Acne',
                          style: TextStyle(
                            color: Colors.black26,
                          ),
                        ),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Hair Loss',
                            semanticsLabel: 'Hair Loss',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Cold Sore',
                            semanticsLabel: 'Cold Sore',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Cosmetic',
                            semanticsLabel: 'Cosmetic',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Anti-Aging',
                            semanticsLabel: 'Anti-Aging',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Nail',
                            semanticsLabel: 'Nail',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(35, 179, 232, 1),
                        child: Text(
                          'Lesion',
                          semanticsLabel: 'Lesion',
                          textScaleFactor:
                              orientation == Orientation.portrait ? 1 : 0.8,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  QuestionsScreeningScreen(),
                            )),
                      ),
                      RaisedButton(
                        child: Text('Rash',
                            semanticsLabel: 'Rash',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      ),
                      RaisedButton(
                        child: Text('Other',
                            semanticsLabel: 'Other',
                            textScaleFactor:
                                orientation == Orientation.portrait ? 1 : 0.8,
                            style: TextStyle(color: Colors.black26)),
                        onPressed: () {
                          // Perform some action
                        },
                      )
                    ],
                  ),
                );
              },
            ),
            OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return Container(
                  child: Container(
                      alignment: Alignment.topCenter,
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                      height: orientation == Orientation.portrait
                          ? 60 : 20,
                      padding: orientation == Orientation.portrait
                          ? EdgeInsets.fromLTRB(0, 20, 0, 0)
                          : EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        'Please select why you need a doctor,',
                        textAlign: TextAlign.center,
                      )),
                );
              },
            ),
          ],
        ),
      );
}
