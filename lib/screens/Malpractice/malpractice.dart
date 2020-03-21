import 'package:Medicall/screens/Malpractice/malpractice_model.dart';
import 'package:Medicall/services/temp_user_provider.dart';
import 'package:Medicall/util/app_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class MalpracticeScreen extends StatefulWidget {
  final MalpracticeScreenModel model;

  static Widget create(BuildContext context) {
    return Provider<MalpracticeScreenModel>(
      create: (context) => MalpracticeScreenModel(),
      child: Consumer<MalpracticeScreenModel>(
        builder: (_, model, __) => MalpracticeScreen(
          model: model,
        ),
      ),
    );
  }

  MalpracticeScreen({@required this.model});
  @override
  _MalpracticeScreenState createState() => _MalpracticeScreenState();
}

class _MalpracticeScreenState extends State<MalpracticeScreen> {
  MalpracticeScreenModel get model => widget.model;
  GlobalKey<FormBuilderState> userRegKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TempUserProvider tempUserProvider;

  @override
  Widget build(BuildContext context) {
    tempUserProvider = Provider.of<TempUserProvider>(context, listen: false);
    model.setTempUserProvider(tempUserProvider);
    List<Widget> questionList = [];
    ValueChanged _onChangedCheckBox = (val) {
      if (val.length >= 2 && val[1] == 'Yes') {
        val.removeAt(0);
      }
      if (val.length >= 2 && val[1] == 'No') {
        val.removeAt(0);
      }
    };

    for (var i = 0; i < tempUserProvider.malpracticeQuestions.length; i++) {
      List<dynamic> _options =
          tempUserProvider.malpracticeQuestions[i]['options'];
      questionList
          .add(Text(tempUserProvider.malpracticeQuestions[i]['question']));
      questionList.add(FormBuilderCheckboxList(
        leadingInput: true,
        initialValue: tempUserProvider.malpracticeQuestions[i]['answer'],
        attribute: 'question' + i.toString(),
        decoration: InputDecoration(border: InputBorder.none),
        validators: [
          FormBuilderValidators.required(),
        ],
        onChanged: _onChangedCheckBox,
        options: _options
            .map((lang) => FormBuilderFieldOption(value: lang))
            .toList(),
      ));
      questionList.add(SizedBox(height: 40));
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Malpractice Questions'),
        ),
        bottomNavigationBar: FlatButton(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          onPressed: () {
            bool successfullySaveForm =
                userRegKey.currentState.saveAndValidate();
            if (successfullySaveForm &&
                userRegKey.currentState.value['question0'].length > 0 &&
                userRegKey.currentState.value['question1'].length > 0 &&
                userRegKey.currentState.value['question2'].length > 0) {
              Navigator.of(context).pushNamed('/phoneAuth');
            } else {
              if (userRegKey.currentState.value['question0'].length == 0) {
                AppUtil()
                    .showFlushBar('Please provide question 1 answer.', context);
              }
              if (userRegKey.currentState.value['questions1'].length == 0) {
                AppUtil()
                    .showFlushBar('Please provide question 2 answer.', context);
              }
              if (userRegKey.currentState.value['question2'].length == 0) {
                AppUtil()
                    .showFlushBar('Please provide question 3 answer.', context);
              }
            }
          }, // Switch tabs

          child: Text(
            'CONTINUE',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              letterSpacing: 2,
            ),
          ),
        ),
        body: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: FormBuilder(
              key: userRegKey,
              onChanged: (map) {
                var i = 0;
                map.forEach((k, v) {
                  tempUserProvider.malpracticeQuestions[i]['answer'] = v;
                  i++;
                });
              },
              autovalidate: false,
              child: Column(children: questionList),
            ),
          ),
        ));
  }

  bool get claims {
    return userRegKey.currentState.value['question0'];
  }

  bool get settlements {
    return userRegKey.currentState.value['question1'];
  }

  bool get convictions {
    return userRegKey.currentState.value['question2'];
  }
}
