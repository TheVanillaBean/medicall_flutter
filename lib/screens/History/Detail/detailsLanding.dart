import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/History/Detail/buildDetailTab.dart';
import 'package:Medicall/screens/History/Detail/prescriptions.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/presentation/medicall_icons_icons.dart' as CustomIcons;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DetailsLandingScreen extends StatelessWidget {
  final bool isDone;
  const DetailsLandingScreen({Key key, @required this.isDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MedicallUser medicallUser = Provider.of<UserProvider>(context, listen: false).medicallUser;
    Database db = Provider.of<Database>(context, listen: false);
    Map consultSnapshot = db.consultSnapshot.data;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            medicallUser.type == 'provider' &&
                    consultSnapshot.containsKey('exam') &&
                    consultSnapshot['exam'].length > 0
                ? Container(
                    height: 50,
                    width: ScreenUtil.screenWidthDp,
                    color: Colors.white.withAlpha(50),
                    child: FlatButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => BuildDetailTab(
                          //             keyStr: 'details',
                          //             indx: 0,
                          //           )),
                          // );
                        },
                        child: Stack(
                          alignment: Alignment.centerRight,
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned(
                              left: 20,
                              child: Text(
                                'Exam',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            Positioned(
                              top: 17,
                              child: Text(
                                consultSnapshot['exam'][0],
                                style: TextStyle(color: Colors.blueGrey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )),
                  )
                : Container(),
            consultSnapshot.containsKey('follow_up') &&
                    consultSnapshot['follow_up'].length > 0
                ? Container(
                    height: 50,
                    width: ScreenUtil.screenWidthDp,
                    color: Colors.white.withAlpha(50),
                    child: FlatButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => BuildDetailTab(
                          //             keyStr: 'details',
                          //             indx: 0,
                          //           )),
                          // );
                        },
                        child: Stack(
                          alignment: Alignment.centerRight,
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned(
                              left: 20,
                              child: Text(
                                'Follow up',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            Positioned(
                              top: 17,
                              child: Text(
                                consultSnapshot['follow_up'][0],
                                style: TextStyle(color: Colors.blueGrey),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        )),
                  )
                : Container(),
            consultSnapshot.containsKey('diagnosis') &&
                    consultSnapshot['diagnosis'].length > 0
                ? Container(
                    height: 50,
                    width: ScreenUtil.screenWidthDp,
                    color: Colors.white.withAlpha(50),
                    child: FlatButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => BuildDetailTab(
                          //             keyStr: 'details',
                          //             indx: 0,
                          //           )),
                          // );
                        },
                        child: Stack(
                          alignment: Alignment.centerRight,
                          fit: StackFit.expand,
                          children: <Widget>[
                            Positioned(
                              left: 20,
                              child: Text(
                                'Diagnosis',
                                style: TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                            Positioned(
                              top: 17,
                              child: Text(
                                consultSnapshot['diagnosis'],
                                style: TextStyle(color: Colors.blueGrey),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        )),
                  )
                : Container(),
            Container(
              height: 100,
              width: ScreenUtil.screenWidthDp,
              color: Colors.lightBlue.withAlpha(50),
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuildDetailTab(
                                keyStr: 'details',
                                indx: 0,
                              )),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        child: Icon(
                          CustomIcons.MedicallIcons.clipboard,
                          color: Colors.blueGrey.withAlpha(100),
                        ),
                      ),
                      Positioned(
                        top: 45,
                        child: Text(
                          'Review Information',
                          style: TextStyle(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              height: 100,
              width: ScreenUtil.screenWidthDp,
              color: Colors.lightBlue.withAlpha(50),
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrescriptionsScreen(
                                isDone: this.isDone,
                              )),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        child: Icon(
                          CustomIcons.MedicallIcons.medkit,
                          color: Colors.blueGrey.withAlpha(100),
                        ),
                      ),
                      Positioned(
                        top: 43,
                        child: Text(
                          'Prescriptions',
                          style: TextStyle(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              height: 100,
              width: ScreenUtil.screenWidthDp,
              color: Colors.lightBlue.withAlpha(50),
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuildDetailTab(
                                keyStr: 'Doctor Note',
                                indx: 0,
                              )),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        child: Icon(
                          CustomIcons.MedicallIcons.clipboard_2,
                          color: Colors.blueGrey.withAlpha(100),
                        ),
                      ),
                      Positioned(
                        top: 45,
                        child: Text(
                          'Doctor Note',
                          style: TextStyle(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              height: 100,
              width: ScreenUtil.screenWidthDp,
              color: Colors.lightBlue.withAlpha(50),
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuildDetailTab(
                                keyStr: 'Educational Information',
                                indx: 0,
                              )),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        child: Icon(
                          Icons.local_library,
                          color: Colors.blueGrey.withAlpha(100),
                        ),
                      ),
                      Positioned(
                        top: 45,
                        child: Text(
                          'Educational Information',
                          style: TextStyle(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              height: 100,
              width: ScreenUtil.screenWidthDp,
              color: Colors.lightBlue.withAlpha(50),
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BuildDetailTab(
                                keyStr: 'chat',
                                indx: 0,
                                isDone: this.isDone,
                              )),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned(
                        left: 20,
                        child: Icon(
                          Icons.chat,
                          color: Colors.blueGrey.withAlpha(100),
                        ),
                      ),
                      Positioned(
                        top: 42,
                        child: Text(
                          medicallUser.type == 'patient'
                              ? 'Message Doctor'
                              : 'Message Patient',
                          style: TextStyle(color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
