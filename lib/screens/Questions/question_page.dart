import 'package:Medicall/common_widgets/custom_raised_button.dart';
import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/grouped_checkbox.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuestionPage extends StatefulWidget {
  final QuestionsViewModel model;
  final Question question;

  const QuestionPage({
    @required this.question,
    @required this.model,
  });

  static Widget create(
    BuildContext context,
    Question question,
  ) {
    final QuestionsViewModel questionsViewModel =
        Provider.of<QuestionsViewModel>(context, listen: false);
    return QuestionPage(
      model: questionsViewModel,
      question: question,
    );
  }

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  Question get question => widget.question;
  QuestionsViewModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
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
              child: Text(widget.question.question),
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
            itemList: model.getOptionsList(question),
            checkedItemList: model.optionsCheckedList,
            orientation: CheckboxOrientation.VERTICAL,
            checkColor: Colors.white,
            activeColor: Colors.blueAccent,
            onChanged: (itemList) {
              setState(() {
                print('SELECTED ITEM LIST $itemList');
              });
            },
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Expanded(
          flex: 1,
          child: CustomRaisedButton(
            color: Colors.blue,
            borderRadius: 24,
            child: Text(
              "Continue",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => model.nextPage(),
          ),
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
        CustomRaisedButton(
          color: Colors.blue,
          borderRadius: 24,
          child: Text(
            "Continue",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => model.nextPage(),
        ),
      ],
    );
  }

  Widget _buildFRTextField() {
    return TextField(
      controller: _inputController,
      focusNode: _inputFocusNode,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      maxLines: 8,
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
        labelText: 'Enter response',
        alignLabelWithHint: true,
        errorText: model.inputErrorText,
        enabled: model.isLoading == false,
      ),
    );
  }
}
