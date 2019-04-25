import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/count/countdown_base.dart';
import 'package:Medicall/util/firebase_listenter.dart';
import 'package:Medicall/util/firebase_phone_util.dart';
import 'package:Medicall/components/progress_hud.dart';
//import 'package:Medicall/screens/Registration/index.dart';
import 'package:Medicall/globals.dart' as globals;

class OtpVerificationScreen extends StatefulWidget {
  OtpVerificationScreen({Key key}) : super(key: key);

  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    implements FirebaseAuthListener {
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String otpWaitTimeLabel = "";
  bool _isMobileNumberEnter = false;

  final _teOtpDigitOne = TextEditingController();
  final _teOtpDigitTwo = TextEditingController();
  final _teOtpDigitThree = TextEditingController();
  final _teOtpDigitFour = TextEditingController();
  final _teOtpDigitFive = TextEditingController();
  final _teOtpDigitSix = TextEditingController();

  FocusNode _focusNodeDigitOne = new FocusNode();
  FocusNode _focusNodeDigitTwo = new FocusNode();
  FocusNode _focusNodeDigitThree = new FocusNode();
  FocusNode _focusNodeDigitFour = new FocusNode();
  FocusNode _focusNodeDigitFive = new FocusNode();
  FocusNode _focusNodeDigitSix = new FocusNode();

  FirebasePhoneUtil presenter;

  @override
  Widget build(BuildContext context) {
    var otpBox = new Row(
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            textAlign: TextAlign.center,
            controller: _teOtpDigitOne,
            focusNode: _focusNodeDigitOne,
            keyboardType: TextInputType.number,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitTwo,
            focusNode: _focusNodeDigitTwo,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitThree,
            focusNode: _focusNodeDigitThree,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFour,
            focusNode: _focusNodeDigitFour,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFive,
            focusNode: _focusNodeDigitFive,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitSix,
            focusNode: _focusNodeDigitSix,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    var form = new Column(
      children: <Widget>[
        new Container(
          alignment: FractionalOffset.center,
          margin: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 0.0),
          padding: EdgeInsets.all(20.0),
          decoration: new BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: new BorderRadius.all(
              const Radius.circular(3.0),
            ),
          ),
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Text(
                  "Enter your verification code",
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  child: otpBox,
                ),
                new SizedBox(
                  width: 0.0,
                  height: 20.0,
                ),
                new Text(
                  otpWaitTimeLabel,
                ),
                new GestureDetector(
                  onTap: () {
                    _submit();
                  },
                  child: new Container(
                    margin: EdgeInsets.only(top: 20.0),
                    padding: EdgeInsets.all(15.0),
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      color: Colors.teal,
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(3.0)),
                    ),
                    child: Text(
                      "SUBMIT",
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    var screenRoot = new Container(
      height: double.maxFinite,
      alignment: FractionalOffset.center,
      child: new SingleChildScrollView(
        child: new Center(
          child: form,
        ),
      ),
    );
    return new WillPopScope(
        onWillPop: () async {
          print("back");
          return true;
        },
        child: new Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          appBar: null,
          key: _scaffoldKey,
          body: ProgressHUD(
            child: screenRoot,
            inAsyncCall: _isLoading,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.indigo),
            opacity: 0.0,
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _teOtpDigitOne.dispose();
  }

  void showLoader() {
    setState(() => _isLoading = true);
  }

  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlert(msg);
    });
  }

  void closeLoader() {
    setState(() => _isLoading = false);
  }

  @override
  onError(String msg) {
    showAlert(msg);
    closeLoader();
  }

  void _submit() {
    if (_isMobileNumberEnter) {
      showLoader();
      presenter.verifyOtp(_teOtpDigitOne.text +
          _teOtpDigitTwo.text +
          _teOtpDigitThree.text +
          _teOtpDigitFour.text +
          _teOtpDigitFive.text +
          _teOtpDigitSix.text);
    } else {
      showAlert("Please your verification code");
    }
  }

  void changeFocusListener(
      TextEditingController teOtpDigitOne, FocusNode focusNodeDigitTwo) {
    teOtpDigitOne.addListener(() {
      if (teOtpDigitOne.text.length > 0 && focusNodeDigitTwo != null) {
        FocusScope.of(context).requestFocus(focusNodeDigitTwo);
      }
      setState(() {});
    });
  }

  void checkFiled(TextEditingController teController) {
    teController.addListener(() {
      if (_teOtpDigitOne.text.isNotEmpty &&
          _teOtpDigitTwo.text.isNotEmpty &&
          _teOtpDigitThree.text.isNotEmpty &&
          _teOtpDigitFour.text.isNotEmpty &&
          _teOtpDigitFive.text.isNotEmpty &&
          _teOtpDigitSix.text.isNotEmpty) {
        _isMobileNumberEnter = true;
      } else {
        _isMobileNumberEnter = false;
      }
      setState(() {});
    });
  }

  void startTimer() {
    var sub = new CountDown(new Duration(minutes: 5)).stream.listen(null);
    sub.onData((Duration d) {
      if (!this.mounted) return;
      setState(() {
        int sec = d.inSeconds % 60;
        otpWaitTimeLabel = d.inMinutes.toString() + ":" + sec.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    presenter = FirebasePhoneUtil();
    presenter.setScreenListener(this);
    changeFocusListener(_teOtpDigitOne, _focusNodeDigitTwo);
    changeFocusListener(_teOtpDigitTwo, _focusNodeDigitThree);
    changeFocusListener(_teOtpDigitThree, _focusNodeDigitFour);
    changeFocusListener(_teOtpDigitFour, _focusNodeDigitFive);
    changeFocusListener(_teOtpDigitFive, _focusNodeDigitSix);

    checkFiled(_teOtpDigitOne);
    checkFiled(_teOtpDigitTwo);
    checkFiled(_teOtpDigitThree);
    checkFiled(_teOtpDigitFour);
    checkFiled(_teOtpDigitFive);
    checkFiled(_teOtpDigitSix);
    startTimer();
  }

  @override
  verificationCodeSent(int forceResendingToken) {}

  @override
  onLoginUserVerified(FirebaseUser currentUser) async {
    //Navigator.pushNamed(context, '/registration');
    globals.currentFirebaseUser = currentUser;
    Navigator.pushNamed(context, '/registration');
  }
}
