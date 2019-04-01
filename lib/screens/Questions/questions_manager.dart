import 'package:flutter/material.dart';

import 'package:medicall/components/DrawerMenu.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:medicall/screens/Questions/Screening/index.dart';
import 'package:medicall/screens/Questions/History/index.dart';
import 'package:medicall/screens/Questions/Uploads/index.dart';
import 'package:medicall/screens/Questions/question_model.dart';
import 'package:medicall/presentation/medicall_app_icons.dart' as CustomIcons;

class QuestionsManager extends StatefulWidget {
  final String title;
  final String symptom;
  QuestionsManager(this.title, this.symptom);
  @override
  _QuestionsManagerState createState() => _QuestionsManagerState();
}

class _QuestionsManagerState extends State<QuestionsManager>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  TabController _tabController;
  var myTabs;
  Questions _questions = Questions(questions: [
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

  @override
  void initState() {
    super.initState();
    myTabs = [
      new GestureDetector(
        onTap: () {
          _tabIndex = 0;
        },
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              width: 39,
              height: 39,
              color: Colors.transparent,
              child: new Tab(
                text: "1",
              ),
            ),
          ],
        ),
      ),
      new GestureDetector(
        onTap: () {
          _tabIndex = 0;
        },
        child: new Container(
          width: 39,
          height: 39,
          color: Colors.transparent,
          child: new Tab(
            text: "2",
          ),
        ),
      ),
      new GestureDetector(
        onTap: () {
          _tabIndex = 0;
        },
        child: new Container(
          width: 39,
          height: 39,
          color: Colors.transparent,
          child: new Tab(
            text: "3",
          ),
        ),
      ),
    ];

    _tabController =
        TabController(initialIndex: 0, length: myTabs.length, vsync: this);

    // void _handleTabSelection() {
    //   setState(() {
    //     _tabController.index = _tabIndex;
    //   });
    // }

    //_tabController.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        drawer: new DrawerMenu(),
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.title),
          backgroundColor: Color.fromRGBO(35, 179, 232, 1),
          centerTitle: true,
          leading: new BackButton(),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          bottom: TabBar(
            isScrollable: true,
            indicatorWeight: 0,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            indicator: new BubbleTabIndicator(
              indicatorHeight: 39,
              padding: EdgeInsets.all(0),
              tabBarIndicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Color.fromRGBO(12, 153, 186, 1),
            ),
            controller: _tabController,
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            new QuestionsScreeningScreen(_questions),
            new QuestionsHistoryScreen(),
            new QuestionsUploadsScreen(),
          ],
        ),
        bottomNavigationBar: new FlatButton(
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          color: Color.fromRGBO(35, 179, 232, 1),
          onPressed: () => _tabController
              .animateTo((_tabController.index + 1) % 3), // Switch tabs

          child: Text(
            'CONTINUE',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class StrikeThroughDecoration extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _StrikeThroughPainter();
  }
}

class _StrikeThroughPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 1.0
      ..color = Colors.blue[100]
      ..style = PaintingStyle.fill;

    final rect = offset & configuration.size;
    canvas.drawLine(new Offset(rect.left, rect.top + rect.height / 2),
        new Offset(rect.right, rect.top + rect.height / 2), paint);
    canvas.restore();
  }
}
