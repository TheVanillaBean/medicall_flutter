import 'package:Medicall/models/global_nav_key.dart';
import 'package:Medicall/models/medicall_user_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:Medicall/util/introduction_screen/introduction_screen.dart';
import 'package:Medicall/util/introduction_screen/model/page_decoration.dart';
import 'package:Medicall/util/introduction_screen/model/page_view_model.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:oktoast/oktoast.dart';
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
  Map globalKeyList = {};
  int currentPage = 0;
  GlobalKey<FormBuilderState> questionsFormKey = GlobalKey();
  bool autoValidate = true;
  bool readOnly = false;
  double formSpacing = 20;
  var screeningQuestions;
  var ranOnce = false;
  var auth = Provider.of<AuthBase>(GlobalNavigatorKey.key.currentContext);
  var medicalHistoryQuestions;
  bool showSegmentedControl = true;
  List<dynamic> combinedList = [];

  @override
  void initState() {
    super.initState();
    if (medicallUser.hasMedicalHistory) {
      combinedList = [
        ...auth.newConsult.screeningQuestions,
        ...auth.newConsult.uploadQuestions
      ];
    } else {
      auth.newConsult.consultType = "Medical History";
      combinedList = [
        ...auth.newConsult.historyQuestions,
      ];
    }

    for (var i = 0; i < combinedList.length; i++) {
      globalKeyList['questionKey' + i.toString()] =
          GlobalKey<FormBuilderState>();
    }
  }

  Future<void> _onIntroEnd() async {
    //await setConsult(context);
    if (auth.newConsult.consultType == 'Medical History') {
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
                    "Continue to " + auth.newConsult.consultType == 'Lesion'
                        ? 'Spot'
                        : "Continue to " +
                            auth.newConsult.consultType +
                            ' treatment'),
                onPressed: () async {
                  await auth.addUserMedicalHistory();
                  GlobalNavigatorKey.key.currentState.pop();
                  GlobalNavigatorKey.key.currentState
                      .pushReplacementNamed('/questionsScreen');
                },
              ),
            ],
          );
        },
      );
    } else {
      auth.newConsult.consultType = auth.newConsult.consultType;
      //switch for if provider has already been selected
      if (auth.newConsult == null || auth.newConsult.provider == null) {
        GlobalNavigatorKey.key.currentState.pushNamed(
          '/selectProvider',
        );
      } else {
        GlobalNavigatorKey.key.currentState.pushNamed(
          '/consultReview',
        );
      }
    }
  }

  void _checkQuestion(index, context) {
    setState(() {
      currentPage = index;
    });
    var tabController = context.state.questionsFormKey.currentContext.state;
    var listKeys = [];
    var currentKeys = [];
    for (var i = 0; i < combinedList.length; i++) {
      if (combinedList[i]['visible']) {
        var keyObj = 'questionKey' + i.toString();
        listKeys.add(combinedList[i]);
        currentKeys.add(globalKeyList[keyObj]);
      }
    }
    var formAnswer = listKeys[index != 0 ? index - 1 : index]['answer'];
    var currentState = currentKeys[index].currentState;

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
            listKeys[index != 0 ? index - 1 : index]['image'].length > 0) {
      tabController.pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
    } else {
      tabController.pageController.animateToPage(
        index != 0 ? index - 1 : index,
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      showToast('Please fill out the required question.',
          position: ToastPosition(align: Alignment.center));
    }
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
    );

    List<PageViewModel> pageViewList = [];
    if (combinedList != null) {
      for (var i = 0; i < combinedList.length; i++) {
        if (combinedList[i]['visible']) {
          pageViewList.add(PageViewModel(
              titleWidget: SizedBox(),
              bodyWidget: BuildQuestions(
                data: {
                  'data': combinedList[i],
                  'questionIndex': 'screening_questions',
                  'dynamicAdd': null,
                  'parent': context,
                  'widget': widget,
                  'questions': combinedList,
                  'key': globalKeyList['questionKey' + i.toString()],
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
          onPressed: () => GlobalNavigatorKey.key.currentState.pop(false),
        ),
        title: Text(auth.newConsult.consultType == 'Lesion'
            ? 'Spot' +
                ' Question: ' +
                (currentPage + 1).toString() +
                '/' +
                pageViewList.length.toString()
            : auth.newConsult.consultType +
                ' Question: ' +
                (currentPage + 1).toString() +
                '/' +
                pageViewList.length.toString()),
      ),
      body: pageViewList.length > 0
          ? IntroductionScreen(
              pages: pageViewList,
              key: questionsFormKey,
              onDone: () => _onIntroEnd(),
              //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
              showSkipButton: false,
              skipFlex: 0,
              nextFlex: 0,
              onChange: (i) => _checkQuestion(i, context),
              skip: Text(
                'Skip',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              next: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.0,
                      style: BorderStyle.solid),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.secondary,
                ),
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
                activeColor: Theme.of(context).primaryColor,
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
