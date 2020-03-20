import 'package:Medicall/models/consult_data_model.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/screens/Symptoms/medical_history_state.dart';
import 'package:Medicall/services/database.dart';
import 'package:Medicall/services/extimage_provider.dart';
import 'package:Medicall/services/user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:Medicall/util/introduction_screen/introduction_screen.dart';
import 'package:Medicall/util/introduction_screen/model/page_decoration.dart';
import 'package:Medicall/util/introduction_screen/model/page_view_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import 'buildQuestions.dart';

class QuestionsScreen extends StatefulWidget {
  final data;
  QuestionsScreen({
    Key key,
    this.data,
  }) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  Map _globalKeyList = {};
  int _currentPage = 0;
  PageController _pageController = PageController(initialPage: 0);
  var _currentQuestions = 'symptom';
  Database _db;
  ExtImageProvider _extImageProvider;
  List<dynamic> _combinedList = [];

  @override
  void initState() {
    super.initState();
    clearMemoryImageCache();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Future<void> _onIntroEnd(context, questionsLength) async {
    //await setConsult(context);
    if (_checkQuestion(questionsLength, context, questionsLength)) {
      if (_currentQuestions == 'Medical History') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text("Medical History Complete"),
              content: Text(
                  "Thank you for filling out your account medical history, this is now saved to your account, it will only need to be updated if you have changes in your medical history."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                      "Continue to " + _db.newConsult.consultType == 'Lesion'
                          ? 'Spot'
                          : "Continue to " +
                              _db.newConsult.consultType +
                              ' treatment'),
                  onPressed: () async {
                    medicallUser.hasMedicalHistory = true;
                    await _db.addUserMedicalHistory(medicallUser);
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushReplacementNamed('/questionsScreen');
                  },
                ),
              ],
            );
          },
        );
      } else {
        _db.newConsult.consultType = _db.newConsult.consultType;
        //switch for if provider has already been selected
        if (_db.newConsult == null || _db.newConsult.provider == null) {
          Navigator.of(context).pushNamed(
            '/selectProvider',
          );
        } else {
          Navigator.of(context).pushNamed(
            '/consultReview',
          );
        }
      }
    }
  }

  bool _checkQuestion(index, context, questionsLength) {
    if (index != questionsLength) {
      setState(() {
        _currentPage = index;
      });
    }
    var listKeys = [];
    var currentKeys = [];
    for (var i = 0; i < _combinedList.length; i++) {
      if (_combinedList[i]['visible']) {
        var keyObj = 'questionKey' + i.toString();
        listKeys.add(_combinedList[i]);
        currentKeys.add(_globalKeyList[keyObj]);
      }
    }
    var formAnswer = listKeys[index != 0 ? index - 1 : index]['answer'];
    var currentState;
    if (index != questionsLength) {
      currentState = currentKeys[index].currentState;
    } else {
      currentState = currentKeys[index - 1].currentState;
    }
    if (formAnswer != null &&
        formAnswer.length > 0 &&
        formAnswer[0] != null &&
        currentState != null &&
        currentState.value['question0'] != formAnswer) {
      currentState.value['question0'] = formAnswer;
    }

    if (formAnswer != null &&
            formAnswer.length > 0 &&
            formAnswer[0] != null &&
            currentState != null &&
            currentState.value['question0'] == formAnswer ||
        listKeys[index != 0 ? index - 1 : index].containsKey('image') &&
            listKeys[index != 0 ? index - 1 : index]['image'].length > 0 ||
        listKeys[index != 0 ? index - 1 : index].containsKey('not_required') &&
            listKeys[index != 0 ? index - 1 : index]['not_required'] == true) {
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      return true;
    } else {
      if (index != questionsLength) {
        _pageController.animateToPage(
          index != 0 ? index - 1 : index,
          duration: Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      }
      AppUtil().showFlushBar('Please fill out the required question.', context);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    medicallUser = Provider.of<UserProvider>(context).medicallUser;
    _db = Provider.of<Database>(context);
    MedicalHistoryState _newMedicalHistory =
        Provider.of<MedicalHistoryState>(context, listen: false);
    _extImageProvider = Provider.of<ExtImageProvider>(context);
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
    );
    if (medicallUser.hasMedicalHistory &&
        !_newMedicalHistory.getnewMedicalHistory()) {
      _combinedList = [
        ..._db.newConsult.screeningQuestions,
        ..._db.newConsult.uploadQuestions
      ];
    } else {
      _currentQuestions = "Medical History";
      _combinedList = [
        ..._db.newConsult.historyQuestions,
      ];
    }
    for (var i = 0; i < _combinedList.length; i++) {
      _globalKeyList['questionKey' + i.toString()] =
          GlobalKey<FormBuilderState>();
    }

    List<PageViewModel> pageViewList = [];
    if (_combinedList != null) {
      for (var i = 0; i < _combinedList.length; i++) {
        if (_combinedList[i]['visible']) {
          pageViewList.add(PageViewModel(
              titleWidget: SizedBox(),
              bodyWidget: BuildQuestions(
                data: {
                  'data': _combinedList[i],
                  'questionIndex': 'screening_questions',
                  'dynamicAdd': null,
                  'parent': context,
                  'widget': widget,
                  'questions': _combinedList,
                  'key': _globalKeyList['questionKey' + i.toString()],
                },
              ),
              decoration: pageDecoration));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _extImageProvider.clearImageMemory();
            if (_newMedicalHistory.getnewMedicalHistory()) {
              _newMedicalHistory.setnewMedicalHistory(false);
            }
            _db.newConsult = ConsultData();

            Navigator.of(context).pop(false);
          },
        ),
        title: Text(_currentQuestions == 'symptom'
            ? _db.newConsult.consultType == 'Lesion'
                ? 'Spot' +
                    ' Question: ' +
                    (_currentPage + 1).toString() +
                    '/' +
                    pageViewList.length.toString()
                : _db.newConsult.consultType +
                    ' Question: ' +
                    (_currentPage + 1).toString() +
                    '/' +
                    pageViewList.length.toString()
            : "Medical History Question: " +
                (_currentPage + 1).toString() +
                '/' +
                pageViewList.length.toString()),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: pageViewList.length > 0
            ? IntroductionScreen(
                pages: pageViewList,
                pageController: _pageController,
                onDone: () => _onIntroEnd(context, pageViewList.length),
                //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
                showSkipButton: true,
                curve: Curves.easeInOutSine,
                skipFlex: 0,
                nextFlex: 0,
                onChange: (i) =>
                    _checkQuestion(i, context, pageViewList.length),

                skip: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    if (_currentPage == 0) {
                      _extImageProvider.clearImageMemory();
                      Navigator.of(context).pop(false);
                    } else {
                      _pageController.previousPage(
                          curve: Curves.ease, duration: Duration(seconds: 1));
                    }
                  },
                ),
                next: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                done: Text(
                  'Finish',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold),
                ),
                dotsFlex: 1,
                dotsDecorator: DotsDecorator(
                  size: Size(10.0, 10.0),
                  spacing: EdgeInsets.all(1),
                  color: Colors.grey,
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeSize: Size(22.0, 10.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
  }
}
