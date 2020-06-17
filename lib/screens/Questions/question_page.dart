import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/grouped_checkbox.dart';
import 'package:Medicall/screens/Questions/question_page_view_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionPage extends StatefulWidget {
  final QuestionPageViewModel model;

  const QuestionPage({
    @required this.model,
  });

  static Widget create(
    BuildContext context,
    Question question,
  ) {
    final QuestionsViewModel questionsViewModel =
        Provider.of<QuestionsViewModel>(context, listen: false);
    return ChangeNotifierProvider<QuestionPageViewModel>(
      create: (context) => QuestionPageViewModel(
        questionsViewModel: questionsViewModel,
        question: question,
      ),
      child: Consumer<QuestionPageViewModel>(
        builder: (_, model, __) => QuestionPage(
          model: model,
        ),
      ),
    );
  }

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Question get question => widget.model.question;
  QuestionPageViewModel get model => widget.model;

  @override
  void dispose() {
    model.inputController.dispose();
    model.inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    model.questionsViewModel.questionPageViewModel = model;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
              alignment: Alignment.topCenter,
              child: Text(question.question),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.all(20),
              child: _buildOption(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context) {
    if (question.type == "FR") {
      return _buildFreeResponseOption(context);
    }
    return _buildMultipleChoiceOption(context);
  }

  Widget _buildMultipleChoiceOption(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 9,
          child: GroupedCheckbox(
            itemList: model.optionsList,
            checkedItemList: model.selectedOptionsList,
            orientation: CheckboxOrientation.VERTICAL,
            checkColor: Colors.white,
            activeColor: Colors.blueAccent,
            onChanged: model.checkedItemsChanged,
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Expanded(
          flex: 1,
          child: _buildNavigationButtons(),
        ),
      ],
    );
  }

  Widget _buildFreeResponseOption(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildFRTextField(),
        SizedBox(
          height: 24,
        ),
        Expanded(
          flex: 1,
          child: _buildNavigationButtons(),
        ),
      ],
    );
  }

  Widget _buildFRTextField() {
    return TextField(
      controller: model.inputController,
      focusNode: model.inputFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      maxLines: 8,
      onChanged: model.updateInput,
      style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1)),
      decoration: InputDecoration(
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          color: Color.fromRGBO(100, 100, 100, 1),
        ),
        filled: true,
        fillColor: Colors.grey.withAlpha(50),
        labelText: "Enter response",
        alignLabelWithHint: true,
        errorText: model.inputErrorText,
        enabled: model.submitted == false,
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
            onPressed: model.questionsViewModel.canAccessPrevious
                ? () => model.questionsViewModel.previousPage()
                : null,
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
              "Next",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: model.questionsViewModel.canAccessNext
                ? () => model.questionsViewModel.nextPage()
                : null,
          ),
        ),
      ],
    );
  }
}
