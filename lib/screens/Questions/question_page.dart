import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/grouped_checkbox.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

class QuestionPage extends StatefulWidget {
  final Question question;

  const QuestionPage({@required this.question});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Question get question => widget.question;

//  @override
//  void dispose() {
//    model.inputController.dispose();
//    model.inputFocusNode.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    final QuestionsViewModel model =
        PropertyChangeProvider.of<QuestionsViewModel>(
      context,
      properties: [QuestionVMProperties.questionPage],
    ).value;
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
              child: Text(this.question.question),
            ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.all(20),
              child: _buildOption(context, model),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, QuestionsViewModel model) {
    if (this.question.type == "FR") {
      return _buildFreeResponseOption(context, model);
    }
    return _buildMultipleChoiceOption(context, model);
  }

  Widget _buildMultipleChoiceOption(
      BuildContext context, QuestionsViewModel model) {
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
      ],
    );
  }

  Widget _buildFreeResponseOption(
      BuildContext context, QuestionsViewModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildFRTextField(model),
      ],
    );
  }

  Widget _buildFRTextField(QuestionsViewModel model) {
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
      ),
    );
  }
}
