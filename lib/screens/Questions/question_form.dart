import 'package:Medicall/models/screening_question_model.dart';
import 'package:Medicall/screens/Questions/questions_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

import 'grouped_checkbox.dart';

class QuestionForm extends StatefulWidget {
  final Question question;
  final QuestionsViewModel questionsViewModel;

  QuestionForm({@required this.question, @required this.questionsViewModel});

  static Widget create(BuildContext context, Question question,
      QuestionsViewModel questionsViewModel) {
    return PropertyChangeConsumer<QuestionsViewModel>(
      properties: [QuestionVMProperties.questionFormWidget],
      builder: (context, model, properties) {
        return QuestionForm(
          question: question,
          questionsViewModel: questionsViewModel,
        );
      },
    );
  }

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  Question get question => widget.question;
  QuestionsViewModel get model => widget.questionsViewModel;

  @override
  Widget build(BuildContext context) {
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
