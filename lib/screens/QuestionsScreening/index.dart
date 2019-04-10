import 'package:flutter/material.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:medicall/models/question_model.dart';

class QuestionsScreeningScreen extends StatefulWidget {
  @override
  _QuestionsScreeningScreenState createState() =>
      _QuestionsScreeningScreenState();
}

class _QuestionsScreeningScreenState extends State<QuestionsScreeningScreen> {
  var _questions = Questions(questions: [
    Question(
        question: 'How long has this lesion been there? (patient selects one)',
        options: [
          '14 days or less',
          'Between 2 weeks and 6 months',
          'Between 6 months and 2 years',
          'Between 2 years and 10 years',
          'As long as I can remember',
          'I’m not sure',
        ],
        type: 'multipleChoice',
        userData: '14 days or less'),
    Question(
        question:
            'Do any of the following symptoms apply to this skin lesion? (Patient checks all that apply)',
        options: [
          'Pain',
          'Itching',
          'Bleeding',
          'Scabbing',
          'Recent change in size',
          'Recent change in color',
        ],
        type: 'multipleChoice',
        userData: 'Pain'),
    Question(
        question: 'Have you ever been diagnosed with a skin cancer before?',
        options: [
          'Yes',
          'No',
        ],
        type: 'multipleChoice',
        userData: 'No'),
    Question(
        question: 'Does anyone in your family have a history of melanoma',
        options: [
          'Yes',
          'No',
        ],
        type: 'multipleChoice',
        userData: 'No'),
    Question(
        question:
            'Are you on medications that decrease the function of your immune system?',
        options: [
          'Yes',
          'No',
        ],
        type: 'multipleChoice',
        userData: 'No'),
    Question(
        question:
            'Is there anything else you want us to know about this skin lesion?',
        options: [],
        type: 'input',
        userData: ''),
  ]);

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
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Screening Questions',
          style: new TextStyle(
            fontSize:
                Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
          ),
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: new FlatButton(
        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
        color: Color.fromRGBO(35, 179, 232, 1),
        onPressed: () => Navigator.pushNamed(context, '/selectProvider'),
        child: Text(
          'CONTINUE',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      body: new Container(
        child: _buildQuestions(context),
      ),
    );
  }
}
