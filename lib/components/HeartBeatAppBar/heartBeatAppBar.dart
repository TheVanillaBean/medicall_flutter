import 'package:Medicall/components/heartBeatPage.dart';
import 'package:flutter/material.dart';

class HeartBeatAppBar extends StatelessWidget {
  final int from, to;

  HeartBeatAppBar({this.from, @required this.to});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.all(9),
      height: 55.0,
      child: HeartBeatAppBarContent(
        MediaQuery.of(context).size,
        from: this.from == null ? this.to : this.from,
        to: to,
      ),
    );
  }
}

class HeartBeatAppBarContent extends StatefulWidget {
  final Size device;
  // Starting activated Icon
  final int from;
  // Icon that the Strating activated Icon will be animated to
  final int to;

  HeartBeatAppBarContent(this.device, {@required this.from, this.to});

  @override
  _HeartBeatAppBarContentState createState() => _HeartBeatAppBarContentState();
}

class _HeartBeatAppBarContentState extends State<HeartBeatAppBarContent>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _activatingOpacity;
  Animation<double> _deactivatingOpacity;

  int _activated;
  int _nextActivated;

  Opacity fadableIcon(final Widget icon, final int index) {
    // Will animate the opacity from 1.0 to 0.5
    if (index == _activated)
      return Opacity(
        opacity: _deactivatingOpacity.value,
        child: icon,
      );

    // Will animate the opacity from 0.5 to 1.0
    if (index == _nextActivated)
      return Opacity(
        opacity: _activatingOpacity.value,
        child: icon,
      );

    // Default returns the icon with opacity 0.5
    return Opacity(
      opacity: 0.5,
      child: icon,
    );
  }

  void _startAnimation(int activated) {
    if (!_animationController.isAnimating && activated != _activated) {
      // Calculates  animation duration depending on how distant the 2 icons are
      // from each other

      _animationController.duration = Duration(milliseconds: 1000);

      setState(() => _nextActivated = activated);

      _animationController.forward();

      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _activated = activated;
            _nextActivated = 0;
          });
          _animationController.reset();
        }
      });
    }
  }

  navigateToScreen(
    BuildContext context, {
    int from,
    @required int to,
    Widget nextPageBody,
  }) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
          pageBuilder: (context, _, __) =>
              HeartBeatPage(body: nextPageBody, from: from, to: to)),
    );

    // In case the page gets popped, this will allow the animation to happen backwards.
    setState(() {
      _activated = to;
    });
    _startAnimation(widget.to);
  }

  @override
  void initState() {
    super.initState();
    print(widget.device.width);

    _activated = widget.from;
    _nextActivated = 0;

    _animationController = AnimationController(
      vsync: this,
    );

    _deactivatingOpacity = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _activatingOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // _heartBeatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(
    //     parent: _animationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );

    if (!(widget.from == null)) {
      _startAnimation(widget.to);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTapUp: (details) {
            navigateToScreen(context,
                from: _activated,
                to: 0,
                nextPageBody: HeartBeatPage.defaultPages[0]);
          },
          child: Container(
            child: fadableIcon(
              Column(
                children: <Widget>[
                  Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                  ),
                  Text(
                    'Care',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              0,
            ),
          ),
        ),
        GestureDetector(
          onTapUp: (details) {
            navigateToScreen(context,
                from: _activated,
                to: 1,
                nextPageBody: HeartBeatPage.defaultPages[1]);
          },
          child: Container(
            child: fadableIcon(
              Column(
                children: <Widget>[
                  Icon(
                    Icons.history,
                    color: Colors.white,
                  ),
                  Text(
                    'History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              1,
            ),
          ),
        ),
        GestureDetector(
          onTapUp: (details) {
            navigateToScreen(context,
                from: _activated,
                to: 2,
                nextPageBody: HeartBeatPage.defaultPages[2]);
          },
          child: fadableIcon(
            Column(
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
                Text(
                  'Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            2,
          ),
        ),
      ],
    );
  }
}
