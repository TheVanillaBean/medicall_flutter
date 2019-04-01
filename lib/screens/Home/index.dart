import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import 'homeAnimation.dart';
import '../../presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:medicall/components/DrawerMenu.dart';
import '../../globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Animation<double> containerGrowAnimation;
  AnimationController _screenController;
  AnimationController _buttonController;
  Animation<double> buttonGrowAnimation;
  Animation<double> listTileWidth;
  Animation<Alignment> listSlideAnimation;
  Animation<Alignment> buttonSwingAnimation;
  Animation<EdgeInsets> listSlidePosition;
  Animation<Color> fadeScreenAnimation;
  var animateStatus = 0;

  @override
  void initState() {
    super.initState();
    _screenController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1500), vsync: this);

    fadeScreenAnimation = new ColorTween(
      begin: const Color.fromRGBO(255, 255, 255, 1.0),
      end: const Color.fromRGBO(255, 255, 255, 0.0),
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: Curves.ease,
      ),
    );
    containerGrowAnimation = new CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeIn,
    );

    buttonGrowAnimation = new CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );
    containerGrowAnimation.addListener(() {
      this.setState(() {});
    });
    containerGrowAnimation.addStatusListener((AnimationStatus status) {});

    listTileWidth = new Tween<double>(
      begin: 1000.0,
      end: 600.0,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.225,
          0.600,
          curve: Curves.easeIn,
        ),
      ),
    );

    listSlideAnimation = new AlignmentTween(
      begin: Alignment.center,
      end: Alignment.center,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.325,
          0.700,
          curve: Curves.ease,
        ),
      ),
    );
    buttonSwingAnimation = new AlignmentTween(
      begin: Alignment.center,
      end: Alignment.center,
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.225,
          0.600,
          curve: Curves.ease,
        ),
      ),
    );
    listSlidePosition = new EdgeInsetsTween(
      begin: const EdgeInsets.only(bottom: 16.0),
      end: const EdgeInsets.only(bottom: 80.0),
    ).animate(
      new CurvedAnimation(
        parent: _screenController,
        curve: new Interval(
          0.325,
          0.800,
          curve: Curves.ease,
        ),
      ),
    );
    _screenController.forward();
  }

  @override
  void dispose() {
    _screenController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.3;
    Size screenSize = MediaQuery.of(context).size;

    return (new WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color.fromRGBO(35, 179, 232, 1),
          title: new Text(
            'Welcome to Medicall',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          leading: new Text('', style: TextStyle(color: Colors.black26)),
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
            backgroundColor: Color.fromRGBO(241, 100, 119, 0.8),
            foregroundColor: Colors.white,
          );
        }),
        body: new Container(
          width: screenSize.width,
          height: screenSize.height,
          child: new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Icon(Icons.find_in_page,
                      size: 150.0, color: Colors.black12),
                  new Text('You are logged in as ' + globals.currentUser.displayName),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
