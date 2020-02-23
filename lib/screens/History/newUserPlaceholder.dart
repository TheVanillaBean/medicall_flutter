import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/doctorSearch.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/util/app_util.dart' as AppUtils;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;

class NewUserPlaceHolder extends StatelessWidget {
  final MedicallUser medicallUser;
  const NewUserPlaceHolder({Key key, @required this.medicallUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      medicallUser.type == 'patient'
          ? Stack(
              children: <Widget>[
                Container(
                  height: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? ScreenUtil.screenHeightDp -
                          135 -
                          ScreenUtil.statusBarHeight
                      : ScreenUtil.screenHeightDp -
                          135 -
                          ScreenUtil.statusBarHeight,
                  width: ScreenUtil.screenWidth,
                  child: CustomPaint(
                    foregroundPainter: CurvePainter(),
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? 10
                      : 0,
                  right: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenWidthDp) / 5
                      : (ScreenUtil.screenWidthDp - 260) / 2,
                  child: Text(
                    'Connect with local doctors now!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 10
                      : 25,
                  right: (ScreenUtil.screenWidthDp - 85) / 2,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.live_help,
                        size: 60,
                        color: Colors.purple.withAlpha(140),
                      ),
                      Text('Select medical \nconcern',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ))
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 2.9
                      : (ScreenUtil.screenHeightDp - 150) / 2.5,
                  left: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? 30
                      : (ScreenUtil.screenWidthDp) * 0.1,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.medkit,
                        size: 60,
                        color: Colors.redAccent.withAlpha(200),
                      ),
                      Text(
                        'If needed meds\nare delivered',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 2.9
                      : (ScreenUtil.screenHeightDp - 150) / 2.5,
                  right: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? 30
                      : (ScreenUtil.screenWidthDp) * 0.1,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.clipboard_1,
                        size: 60,
                        color: Colors.green.withAlpha(200),
                      ),
                      Text(
                        'Answer\nquestions',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 1.8
                      : (ScreenUtil.screenHeightDp) / 2.9,
                  left: (ScreenUtil.screenWidthDp - 100) / 2,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.stethoscope,
                        size: 60,
                        color: Colors.blueAccent.withAlpha(200),
                      ),
                      Text(
                        'Doctor reviews &\n provides diagnosis',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Stack(
              children: <Widget>[
                Container(
                  height: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? ScreenUtil.screenHeightDp -
                          80 -
                          ScreenUtil.statusBarHeight
                      : ScreenUtil.screenHeightDp -
                          50 -
                          ScreenUtil.statusBarHeight,
                  width: ScreenUtil.screenWidth,
                  child: CustomPaint(
                    foregroundPainter: CurvePainter(),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Connect with patients now!',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    Container(
                      width: ScreenUtil.screenWidthDp,
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(50),
                        border: Border.all(
                            color: Colors.grey.withAlpha(100),
                            style: BorderStyle.solid,
                            width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Text(
                        'You will now show up in our network when patients request for care. Once a patient selects you, a record of that request will show up here. By tapping on a request once it shows up in "History" you will be able to see detailed answers/photos from the patient, chat directly, and provide a prescription to them if needed.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 6
                      : 25,
                  right: (ScreenUtil.screenWidthDp - 85) / 2,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.live_help,
                        size: 60,
                        color: Colors.purple.withAlpha(140),
                      ),
                      Text('Receive patient \nrequests',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ))
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 2.5
                      : (ScreenUtil.screenHeightDp - 80) / 2.5,
                  left: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? 30
                      : (ScreenUtil.screenWidthDp) * 0.1,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.medkit,
                        size: 60,
                        color: Colors.redAccent.withAlpha(200),
                      ),
                      Text(
                        'Provide\nprescription\nif needed',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 2.5
                      : (ScreenUtil.screenHeightDp - 80) / 2.5,
                  right: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? 30
                      : (ScreenUtil.screenWidthDp) * 0.1,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.clipboard_1,
                        size: 60,
                        color: Colors.green.withAlpha(200),
                      ),
                      Text(
                        'View request\ndetails',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil.mediaQueryData.orientation ==
                          Orientation.portrait
                      ? (ScreenUtil.screenHeightDp) / 1.5
                      : (ScreenUtil.screenHeightDp) / 1.8,
                  left: (ScreenUtil.screenWidthDp - 100) / 2,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        CustomIcons.MedicallIcons.stethoscope,
                        size: 60,
                        color: Colors.blueAccent.withAlpha(200),
                      ),
                      Text(
                        'Review &\n provide diagnosis',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.of(context).pushReplacementNamed('/symptoms');
            },
            color: Colors.green,
            child: Text(
              'Get Care',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DoctorSearch()),
              );
            },
            color: Colors.blueAccent,
            child: Text(
              'Find Doctor',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 160,
            child: Text(
              'I have a specific issue and am open\nto which doctor I connect with',
              style: TextStyle(
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Container(
            width: 165,
            child: Text(
              'select this if you have a specific\ndoctor you want to connect with',
              style: TextStyle(
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]));
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path;
    Path path1;
    Path path2;
    //Path path3;

    // The arrows usually looks better with rounded caps.
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    /// Draw a single arrow.

    path = Path();

    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path.moveTo(size.width * 0.61, size.height * 0.25);
      path.relativeCubicTo(10, 0, size.width * 0.26, 0, size.width * 0.25, 100);
    } else {
      path.moveTo(size.width * 0.57, size.height * 0.25);
      path.relativeCubicTo(140, 0, size.width * 0.28, 0, size.width * 0.28, 35);
    }
    path = AppUtils.ArrowPath.make(
      path: path,
      tipLength: 5,
    );
    canvas.drawPath(path, paint..color = Colors.blue.withAlpha(100));

    path1 = Path();
    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path1.moveTo(size.width * 0.85, size.height / 1.55);
      path1.relativeCubicTo(0, 60, 0, 115, -80, 115);
    } else {
      path1.moveTo(size.width * 0.85, size.height / 1.28);
      path1.relativeCubicTo(0, 20, 0, 30, -160, 25);
    }

    path1 = AppUtils.ArrowPath.make(
      path: path1,
      tipLength: 5,
    );
    canvas.drawPath(path1, paint..color = Colors.blue.withAlpha(100));

    path2 = Path();
    if (ScreenUtil.mediaQueryData.orientation == Orientation.portrait) {
      path2.moveTo(size.width * 0.35, size.height / 1.16);
      path2.relativeCubicTo(0, 0, -80, 0, -70, -125);
    } else {
      path2.moveTo(size.width * 0.4, size.height / 1.14);
      path2.relativeCubicTo(-20, 0, -160, 10, -160, -25);
    }

    path2 = AppUtils.ArrowPath.make(
      path: path2,
      tipLength: 5,
    );
    canvas.drawPath(path2, paint..color = Colors.blue.withAlpha(100));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}