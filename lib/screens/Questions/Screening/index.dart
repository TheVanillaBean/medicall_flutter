import 'package:flutter/material.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:medicall/screens/Questions/question_model.dart';

class QuestionsScreeningScreen extends StatelessWidget {
  final Questions _questions;

  QuestionsScreeningScreen(this._questions) {
    print(_questions);
  }

  _questionBuilder(context, index) {
    final item = _questions.questions[index];
    List<DropdownMenuItem<dynamic>> newOptions = [];
    for (var i = 0; i < item.options.length; i++) {
      newOptions.add(DropdownMenuItem(
        value: item.options[i],
        child: new Text(item.options[i]),
      ));
    }
    if (item.type == 'switch') {
      return SwitchListTile(
          title: Text(item.question),
          value: item.userData,
          onChanged: (val) {
            //setState(() => _user.passions[User.PassionCooking] = val);
            print(item.userData);
          });
    } else if (item.type == 'multipleChoice') {
      return FormField(
        builder: (FormFieldState state) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: <Widget>[
                Text(item.question),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: '',
                  ),
                  isEmpty: item.userData == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton(
                      value: item.userData,
                      isDense: true,
                      onChanged: (dynamic newValue) {
                        item.userData = newValue;
                        state.didChange(newValue);
                      },
                      items: newOptions,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (item.type == 'input') {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
        child: Column(
          children: <Widget>[
            new Text(item.question),
            new TextFormField(
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      );
    }
  }

  _buildQuestions(context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build
      itemCount: _questions.questions.length,
      // Provide a builder function. This is where the magic happens! We'll
      // convert each item into a Widget based on the type of item it is.
      itemBuilder: (context, index) => _questionBuilder(context, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildQuestions(context),
    );
  }
}
