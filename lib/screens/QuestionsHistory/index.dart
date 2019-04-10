import 'package:flutter/material.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;
import 'package:medicall/models/question_model.dart';
import 'package:medicall/models/providers_model.dart';

class QuestionsHistoryScreen extends StatefulWidget {
  @override
  _QuestionsHistoryScreenState createState() => _QuestionsHistoryScreenState();
}

class _QuestionsHistoryScreenState extends State<QuestionsHistoryScreen> {
  Questions _questions = Questions(questions: []);
  Providers _providers = Providers(providers: [
    Provider(
        prefix: 'Dr.',
        firstName: 'Layla',
        lastName: 'Smith',
        address: '2131 S Sunset Dr California 82934',
        rating: '5'),
  ]);

  @override
  void initState() {
    super.initState();
    _questions.questions.add(Question(
        question: 'Have you previously seen ' +
            _providers.providers[0].prefix +
            ' ' +
            _providers.providers[0].firstName +
            ' ' +
            _providers.providers[0].lastName,
        options: [
          'Yes',
          'No',
        ],
        type: 'multipleChoice',
        userData: 'No'));
    _questions.questions.add(Question(
        question:
            'Do you have any of the following medical conditions? (you\'ll have a chance to tell your doctor about other medical conditions later.)',
        options: [
          'Asthma',
          'Dermatomyositis',
          'Diabetes',
          'Eczema (atopic dermatitis)',
          'Food allergies',
          'Glaucoma (increased eye pressure)',
          'Lupus',
          'Psoriasis',
          'Rheumatoid arthritis',
          'History of skin cancer',
          'Neuromuscular disorders',
          'Rosacea',
          'Seasonal allergies',
          'None of the above'
        ],
        type: 'multipleChoice',
        userData: 'None of the above'));
    _questions.questions.add(Question(
        question:
            'Do you have any other current medical conditions or important past medical history? (anything for which you see a doctor or take medication is useful to know)',
        options: [
        ],
        type: 'input',
        userData: ''));
        _questions.questions.add(Question(
        question:
            'Are there any medication that you take or use regularly? (Including over-the-counter medications and supplements)',
        options: [
          'Yes',
          'No'
        ],
        type: 'multipleChoice',
        userData: 'No'));
        _questions.questions.add(Question(
        question:
            'What type of prescription coverage do you have?',
        options: [
          'Brand name and generic',
          'Generic only',
          'Medicaid',
          'I don\'t know',
          'I don’t have health insurance',
        ],
        type: 'multipleChoice',
        userData: 'I don\'t know'));
        _questions.questions.add(Question(
        question:
            'Is there anything else you\'d like to ask or share with your doctor? (it is optional)',
        options: [
        ],
        type: 'input',
        userData: ''));
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
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(35, 179, 232, 1),
        title: new Text(
          'Medical History Questions',
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
        onPressed: () => Navigator.pushNamed(context, '/questionsUpload'),
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
