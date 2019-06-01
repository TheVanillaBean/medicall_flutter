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
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String otpWaitTimeLabel = '';
  bool _isMobileNumberEnter = false;

  final _teOtpDigitOne = TextEditingController();
  final _teOtpDigitTwo = TextEditingController();
  final _teOtpDigitThree = TextEditingController();
  final _teOtpDigitFour = TextEditingController();
  final _teOtpDigitFive = TextEditingController();
  final _teOtpDigitSix = TextEditingController();

  FocusNode _focusNodeDigitOne = FocusNode();
  FocusNode _focusNodeDigitTwo = FocusNode();
  FocusNode _focusNodeDigitThree = FocusNode();
  FocusNode _focusNodeDigitFour = FocusNode();
  FocusNode _focusNodeDigitFive = FocusNode();
  FocusNode _focusNodeDigitSix = FocusNode();

  FirebasePhoneUtil presenter;

  @override
  Widget build(BuildContext context) {
    var otpBox = Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: _teOtpDigitOne,
            focusNode: _focusNodeDigitOne,
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: _teOtpDigitTwo,
            focusNode: _focusNodeDigitTwo,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: _teOtpDigitThree,
            focusNode: _focusNodeDigitThree,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: _teOtpDigitFour,
            focusNode: _focusNodeDigitFour,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: _teOtpDigitFive,
            focusNode: _focusNodeDigitFive,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: TextFormField(
            controller: _teOtpDigitSix,
            focusNode: _focusNodeDigitSix,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    var form = Column(
      children: <Widget>[
        Container(
          alignment: FractionalOffset.center,
          margin: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 0.0),
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.all(
              const Radius.circular(3.0),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Enter your verification code',
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  child: otpBox,
                ),
                SizedBox(
                  width: 0.0,
                  height: 20.0,
                ),
                Text(
                  otpWaitTimeLabel,
                ),
                GestureDetector(
                  onTap: () {
                    _submit();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 20.0),
                    padding: EdgeInsets.all(15.0),
                    alignment: FractionalOffset.center,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(3.0)),
                    ),
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(
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

    var screenRoot = Container(
      height: double.maxFinite,
      alignment: FractionalOffset.center,
      child: SingleChildScrollView(
        child: Center(
          child: form,
        ),
      ),
    );
    return WillPopScope(
        onWillPop: () async {
          print('back');
          return true;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF2B2B2B),
          appBar: null,
          key: _scaffoldKey,
          body: ProgressHUD(
            child: screenRoot,
            inAsyncCall: _isLoading,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
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
      showAlert('Please your verification code');
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
    var sub = CountDown(Duration(minutes: 5)).stream.listen(null);
    sub.onData((Duration d) {
      if (!this.mounted) return;
      setState(() {
        int sec = d.inSeconds % 60;
        otpWaitTimeLabel = d.inMinutes.toString() + ':' + sec.toString();
      }
      );
    });
    sub.cancel();
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
