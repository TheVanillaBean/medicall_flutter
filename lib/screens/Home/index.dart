import 'package:Medicall/models/medicall_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
// import 'dart:async';
// import 'homeAnimation.dart';
import 'package:Medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:Medicall/components/DrawerMenu.dart';
import 'package:Medicall/globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
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

    _screenController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    _buttonController = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    fadeScreenAnimation = ColorTween(
      begin: const Color.fromRGBO(255, 255, 255, 1.0),
      end: const Color.fromRGBO(255, 255, 255, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: Curves.ease,
      ),
    );
    containerGrowAnimation = CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeIn,
    );

    buttonGrowAnimation = CurvedAnimation(
      parent: _screenController,
      curve: Curves.easeOut,
    );
    containerGrowAnimation.addListener(() {
      this.setState(() {});
    });
    containerGrowAnimation.addStatusListener((AnimationStatus status) {});

    listTileWidth = Tween<double>(
      begin: 1000.0,
      end: 600.0,
    ).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: Interval(
          0.225,
          0.600,
          curve: Curves.easeIn,
        ),
      ),
    );

    listSlideAnimation = AlignmentTween(
      begin: Alignment.center,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: Interval(
          0.325,
          0.700,
          curve: Curves.ease,
        ),
      ),
    );
    buttonSwingAnimation = AlignmentTween(
      begin: Alignment.center,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: Interval(
          0.225,
          0.600,
          curve: Curves.ease,
        ),
      ),
    );
    listSlidePosition = EdgeInsetsTween(
      begin: const EdgeInsets.only(bottom: 16.0),
      end: const EdgeInsets.only(bottom: 80.0),
    ).animate(
      CurvedAnimation(
        parent: _screenController,
        curve: Interval(
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

    return (WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Welcome to Medicall',
            style: TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          leading: Text('', style: TextStyle(color: Colors.black26)),
        ),
        drawer: DrawerMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(
              CustomIcons.MedicallApp.logo_m,
              size: 35.0,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          );
        }),
        body: Container(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.find_in_page, size: 150.0, color: Colors.black12),
                  Text(medicallUser.firstName +
                      ' ' +
                      medicallUser.lastName)
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
