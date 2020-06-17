import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/consult_model.dart';
import 'package:Medicall/routing/router.dart';
import 'package:Medicall/screens/Questions/progress_bar.dart';
import 'package:Medicall/screens/Questions/question_page.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:Medicall/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionsScreen extends StatelessWidget {
  final QuestionsViewModel model;
  final Consult consult;

  static Widget create(
    BuildContext context,
    Consult consult,
  ) {
    final AuthBase auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<QuestionsViewModel>(
      create: (context) => QuestionsViewModel(
        auth: auth,
        consult: consult,
      ),
      child: Consumer<QuestionsViewModel>(
        builder: (_, model, __) => QuestionsScreen(
          consult: consult,
          model: model,
        ),
      ),
    );
  }

  static Future<void> show({
    @required BuildContext context,
    @required Consult consult,
  }) async {
    await Navigator.of(context).pushNamed(
      Routes.questions,
      arguments: {
        'consult': consult,
      },
    );
  }

  QuestionsScreen({
    @required this.model,
    @required this.consult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedProgressbar(value: model.progress),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: model.controller,
        itemCount: this.consult.questions.length + 1,
        onPageChanged: this.model.pageChanged,
        itemBuilder: (BuildContext context, int idx) {
          if (idx == this.consult.questions.length) {
            return reviewPage(context);
          } else {
            final questionPage = QuestionPage.create(
              context,
              this.consult.questions[idx],
            );
            return questionPage;
          }
        },
      ),
    );
  }

  Widget reviewPage(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                alignment: Alignment.topCenter,
                child: Text(
                  'Congratulations! You have finished this questionnaire.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            Expanded(
              flex: 8,
              child: Container(
                padding: EdgeInsets.all(20),
                child: _buildNavigationButtonsa(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtonsa() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: CustomRaisedButton(
            color: Colors.blue,
            borderRadius: 24,
            child: Text(
              "Previous",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => model.previousPage(),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 1,
          child: CustomRaisedButton(
            color: Colors.blue,
            borderRadius: 24,
            child: Text(
              "Complete",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => model.createConsult(),
          ),
        ),
      ],
    );
  }
}
